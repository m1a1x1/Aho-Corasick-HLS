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


component
void module_proc(ast_snk &str_in, ast_src &result,
                 hls_avalon_slave_register_argument  csr_ac csr ){

  MEM_ATTR static ac_word mem [TILE_CNT][MEM_WIDTH] __attribute__((bank_bits(9,8),bankwidth(8)));
  hls_register static ptr_t next_state[TILE_CNT];  
  if( csr.conf ){
    mem[csr.title_num][csr.node_addr] = csr.node;
  }

  bool success = false;
  bool sop = false;
  bool eop = false;
  uint8 symbol = str_in.tryRead( success ,sop, eop );
  uint24 pvm[TILE_CNT] = {-1};

  while( success ){
    #pragma ivdep array(mem)
    #pragma unroll TILE_CNT
    #pragma II 1
    for( uint8 j = 0; j < TILE_CNT; j++ ){
      if( sop ){
        next_state[j] = 0;
      }
      ac_word node = mem[j][next_state[j] & 0xff ];
      next_state[j] = node.ptr[ symbol.slc<2>(j << 1) ];
      pvm[j] = node.pmv;
    }

    find_info fi;
    fi.pvm = pvm[0] & pvm[1] & pvm[2] & pvm[3];
    if( fi.pvm != 0 )
      result.write( fi ); 

    symbol = str_in.tryRead( success ,sop, eop );
    }
}

 
/*
// OLD
component
void aho_corasik( ast_snk &str_in,
                  ast_src &result,
                  hls_avalon_slave_register_argument csr_ac csr   ){
  static MEM_ATTR ac_word mem [RULE_MODULE_CNT][TILE_CNT][MEM_WIDTH] __attribute__((bank_bits(14,13,12,11,10,9,8),bankwidth(8)));
;
  if( csr.conf ){
    mem[csr.rule_module_num][csr.title_num][csr.node_addr & 0xff] = csr.node;
    return;
  }
  bool success = false;
  bool sop = false;
  bool eop = false;
  uint8 symbol = str_in.tryRead( success ,sop, eop );
  static uint32 offset;
  static hls_register uint8 next_state[RULE_MODULE_CNT][TILE_CNT];  
  hls_register ac_word node[RULE_MODULE_CNT][TILE_CNT];
  find_info fi[RULE_MODULE_CNT];

  while( success ){
  if( sop ){
    offset = 0;
  }
  #pragma ivdep array(mem)
  #pragma unroll RULE_MODULE_CNT
  //#pragma loop_coalesce
  #pragma II 1
  for( uint8 i = 0; i < RULE_MODULE_CNT; i++ ){
    fi[i].rule_module_num = i;
    fi[i].pvm             = -1; // all = '1
    //#pragma unroll 
    //#pragma ivdep safelen(TILE_CNT)
   // #pragma hls_max_concurrency(1)
    #pragma unroll TILE_CNT
    for( uint8 j = 0; j < TILE_CNT; j++ ){
      if( sop )
        next_state[i][j] = 0;
      //node[i][j] = mem[i & 0xf][j& 0x3][next_state[i][j] & 0x7f];
      node[i][j] = mem[i][j & 0x3 ][next_state[i][j] & 0xff];
      fi[i].pvm = node[i][j].pmv & fi[i].pvm;
      next_state[i][j] = node[i][j].ptr[ symbol.slc<2>(j << 1) ];
    }
    if( fi[i].pvm != 0 ){
      fi[i].offset = offset;
      result.write( fi[i] );
    }
  }
  offset++;
  symbol = str_in.tryRead( success ,sop, eop );
  }
} 
*/
#ifndef FPGA_ONLY
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
        csr.title_num = j;
        csr.node_addr = k;
        csr.node = info_ac.GetInfo( csr );
        //ihc_hls_enqueue_noret( aho_corasik, snk, src, csr );
        module_proc( snk, src, csr );
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
  module_proc( snk, src, csr );
  //ihc_hls_component_run_all( aho_corasik );


  bool success = false;
  word_info wi;
  find_info rs = src.tryRead( success );
  wi.word_id = rs.pvm;
  wi.num_module = 0;

  cout << "!!! Result !!!" << endl;
  while( success ){
    cout << "PVM: " << rs.pvm
         << " Word: " << info_ac.WordInfoToWord( wi ) << endl;
    find_info rs = src.tryRead( success );
    wi.word_id = rs.pvm;
    wi.num_module = 0;
  }
}

#endif
