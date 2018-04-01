#include <stdint.h>
#include <stdlib.h> 
#include <fstream>

#include "HLS/stdio.h"
#include "HLS/hls.h"   
#include "HLS/ac_int.h"

#include "ac.h"

#define MEM_ATTR  hls_memory hls_singlepump\
                //  hls_bankwidth(8) hls_numbanks(RULE_MODULE_CNT*TILE_CNT/2)
using namespace std;

typedef ihc::stream_in<uint8, ihc::usesValid<true>, ihc::usesPackets<true> > ast_snk;
typedef ihc::stream_out<find_info > ast_src;


typedef ihc::stream_in<uint64_t, ihc::usesValid<true>, ihc::buffer<32> > ast_res;
typedef ihc::mm_master<uint64_t, ihc::aspace<1>,ihc::awidth<32>, ihc::readwrite_mode<writeonly>, 
                      ihc::dwidth<64>, ihc::latency<0>, ihc::waitrequest<true>,
                      ihc::maxburst<1> > amm;

hls_avalon_slave_component 
component
uint32_t ah_handler( ast_res & str_in,
                     amm         & amm_res,
                     hls_avalon_slave_register_argument uint32_t res_cnt ){


  bool success = false;
  uint64_t symbol = str_in.tryRead( success );
  while( res_cnt != ( PAGE_SIZE - 1 ) ){
    if( success ){
      amm_res[res_cnt] = symbol;
      res_cnt++; 
    }
    symbol = str_in.tryRead( success );
  }
  return res_cnt;
}  


#ifdef FPGA_ONLY
hls_always_run_component
#endif
hls_avalon_slave_component 
component
void ah_module( ast_snk &str_in, ast_src &result,
                hls_avalon_slave_register_argument uint2   tile_num,
                hls_avalon_slave_register_argument uint8   node_addr,
                hls_avalon_slave_register_argument ac_word node,
                hls_avalon_slave_register_argument uint8   id,
                hls_avalon_slave_register_argument bool    conf ){

  MEM_ATTR static ac_word mem [TILE_CNT][MEM_WIDTH] __attribute__((bank_bits(9,8),bankwidth(8)));
  hls_register static ptr_t next_state[TILE_CNT];  
  if( conf ){
    mem[tile_num][node_addr] = node;
  }

  bool success = false;
  bool sop = false;
  bool eop = false;
  uint8 symbol = str_in.tryRead( success ,sop, eop );
  pmv_t pmv[TILE_CNT] = {-1};

  while( success ){
    #pragma ivdep array(mem)
    #pragma unroll TILE_CNT
    #pragma II 1
    for( uint3 j = 0; j < TILE_CNT; j++ ){
      if( sop ){
        next_state[j] = 0;
      }
      ac_word node = mem[j][next_state[j] & 0xff ];
      next_state[j] = node.ptr[ symbol.slc<2>(j << 1) ];
      pmv[j] = node.pmv;
    }

    find_info fi;
    fi.pmv = pmv[0] & pmv[1] & pmv[2] & pmv[3];
    fi.rule_module_num = id;
    if( fi.pmv != 0 )
      result.write( fi ); 

    symbol = str_in.tryRead( success ,sop, eop );
    }
}
#ifndef FPGA_ONLY
#ifdef  TB_AH
int main( ){
  InfoAC info_ac;

  ifstream input( "words" );
  if( !input.is_open() ){
    cout << "Not such file!" << endl;
    return -1;
  }
 
  string line;
  while( getline( input, line ) ){
    info_ac.SetWord(line);
  }

  cout << "### String ###" << endl;

  ifstream t("file");
  if( !input.is_open() ){
    cout << "Not such file!" << endl;
    return -1;
  }

  string buffer ((std::istreambuf_iterator<char>(t)), std::istreambuf_iterator<char>());
  info_ac.PrintBinString( buffer );
  info_ac.PrintWordsContent();
  info_ac.SearchInString( buffer );
  //info_ac.PrintModuleContent( 0 );

  csr_ac csr;
  ast_snk snk;
  ast_src src;
  for( int i = 0; i < 1; i++ ){
    for( int j = 0; j < TILE_CNT; j++ ){
      for( int k = 0; k < MEM_WIDTH; k++ ){
        csr.conf = true;
        csr.rule_module_num = i;
        csr.tile_num = j;
        csr.node_addr = k;
        csr.node = info_ac.GetInfo( csr );
        //ihc_hls_enqueue_noret( aho_corasik, snk, src, csr );
        ah_module( snk, src, csr );
      }
    }
  }
  csr.conf = false;
  
  cout << "!!! Start !!!" << endl;
  for (int i = 0; i < buffer.length(); i++){
    snk.write( buffer[i], i == 0, ( i == buffer.length() - 1)  );
  }
  /*
  for (int i = 0; i < buffer.length(); i++){
    ihc_hls_enqueue_noret( aho_corasik, snk, src, csr );
  }*/
  //ihc_hls_enqueue_noret( aho_corasik, snk, src, csr  );

  cout << "!!! Run !!!" << endl;
  ah_module( snk, src, csr );
  //ihc_hls_component_run_all( aho_corasik );


  bool success = false;
  word_info wi;
  find_info rs = src.tryRead( success );
  wi.word_id = rs.pmv;
  wi.num_module = 0;

  cout << "!!! Result !!!" << endl;
  while( success ){
    cout << "PVM: " << rs.pmv
         << " Word: " << info_ac.WordInfoToWord( wi ) << endl;
    find_info rs = src.tryRead( success );
    wi.word_id = rs.pmv;
    wi.num_module = 0;
  }
}
#else
int main( ){
  uint64_t A[PAGE_SIZE];
  ast_res snk;

  amm a(A,sizeof(uint64_t)*PAGE_SIZE ); 
  for( uint32_t i = 0;  i < PAGE_SIZE; i++ ){
    snk.write( i );
  }
  ah_handler( snk, a, 0 );  

}
#endif
#endif
