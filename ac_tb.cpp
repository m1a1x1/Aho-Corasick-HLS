#include "HLS/hls.h"   
#include "HLS/stdio.h"
#include <stdint.h>
#include <stdlib.h> 
#include "HLS/ac_int.h"
#include <string>
#include <vector>

#include "ac.h"

using namespace std;

#ifndef FPGA_ONLY
InfoAC::InfoAC(){
  //Init info 
  for( int i = 0; i < RULE_MODULE_CNT; i++ ){
    module_info[i].word_in_module = 0;
    for( int j = 0; j < TILE_CNT; j++ ){
       module_info[i].node_busy[j] = 0;
    }
  }
  //Init mem
  for( int i = 0; i < RULE_MODULE_CNT; i++ ){
    for( int j = 0; j < TILE_CNT; j++ ){
      for( int k = 0; k < MEM_WIDTH; k++ ){
        mem[i][j][k].ptr[0] = 0; 
        mem[i][j][k].ptr[1] = 0; 
        mem[i][j][k].ptr[2] = 0; 
        mem[i][j][k].ptr[3] = 0;
        mem[i][j][k].pmv    = 0;
      }
    }
  }
}

int InfoAC::SetWord( const std::string & word ){
  int w_length = word.size() - 1;
  if( w_length > 12 ){
    printf( "Error: word length must be less 13!!!" );
    return -1;
  }

  int module_busy = 0;
  for( int i = 0; i < RULE_MODULE_CNT; i++ ){
    if( module_info[i].word_in_module >= 24 )
      module_busy++;
  }
  if( module_busy == RULE_MODULE_CNT ){
    printf( "Error: all modules is busy!!!" );
    return -1;
  } 
  int ptr[TILE_CNT] = {0};
  int symbol_num = 0;
  for( char character : word ){
     uint8 symbol ( character );

     for( int i = 0; i < TILE_CNT; i++ ){
       uint2  part = symbol.slc<2>(i << 1);
       int local_ptr = mem[module_busy][i][ptr[i]].ptr[part];

       if( local_ptr == 0 ){
         module_info[module_busy].node_busy[i]++;
         mem[module_busy][i][ptr[i]].ptr[part] = module_info[module_busy].node_busy[i];
         if( symbol_num == w_length ){
           mem[module_busy][i][ptr[i]].pmv = ( 1 << module_info[module_busy].word_in_module ) |  
                                             mem[module_busy][i][ptr[i]].pmv;
           module_info[module_busy].node_busy[i]--;
           mem[module_busy][i][ptr[i]].ptr[part] = 0;
         } 
         ptr[i] = module_info[module_busy].node_busy[i];
       }
       else{
         if( symbol_num == w_length )
           mem[module_busy][i][ptr[i]].pmv = ( 1 << module_info[module_busy].word_in_module ) | 
                                             mem[module_busy][i][ptr[i]].pmv; 
         ptr[i] = local_ptr; 
       }
     }
     symbol_num++;
  }
  word_info wi;
  wi.num_module = module_busy;
  wi.word_id    = 1 << module_info[module_busy].word_in_module;
  words[word]   = wi;
  module_info[module_busy].word_in_module++;
  return 0;
}

void InfoAC::PrintTitleContent( int module_num, int title_num ){
  for( int i = 0; i < MEM_WIDTH; i++ ){
    printf("| %4d | %4d | %4d | %4d | %3x |\n", mem[module_num][title_num][i].ptr[0],
                                           mem[module_num][title_num][i].ptr[1],
                                           mem[module_num][title_num][i].ptr[2],
                                           mem[module_num][title_num][i].ptr[3],
                                           mem[module_num][title_num][i].pmv   );
  }
}

void InfoAC::PrintModuleContent( int module_num ){
  for(int i = 0; i < TILE_CNT; i++ ){
    printf("Tile #%d\n", i );
    printf("+++++++++++++++++++++++++++++++\n");
    PrintTitleContent( module_num, i );
  }
}

void InfoAC::PrintBinString( const std::string & word ){
  
  cout << "Word: " << word << endl;
  for (char c : word ){
    printf( PRINTF_BINARY_PATTERN_INT8 "\n", PRINTF_BYTE_TO_BINARY_INT8(c) );   
  }
}

void InfoAC::PrintWordsContent(){
  cout << "### Words in memory ###" << endl;
  for (std::map<std::string, word_info>::iterator it=words.begin(); it!=words.end(); it++)
    std::cout << it->first << " :"  << " " << it->second.word_id
                           << " "<< it->second.num_module << std::endl;
}

void InfoAC::SearchInString( const std::string & text ){
  cout << "### Find string in word ref###" << endl;
  #pragma omp for
  for(std::map<std::string, word_info>::iterator it=words.begin(); it!=words.end(); it++){
    size_t pos = text.find(it->first);
    if( pos != std::string::npos ){
      std::cout << "String: " << it->first << ", pos: " << pos << std::endl; 
    }
  }
}

ac_word InfoAC::GetInfo( const csr_ac & csr ){
  return mem[csr.rule_module_num][csr.title_num][csr.node_addr];  
}
 
std::string InfoAC::WordInfoToWord( const word_info & wi ){
  for (std::map<std::string, word_info>::iterator it=words.begin(); it!=words.end(); it++)
    if( ( wi.word_id == it->second.word_id ) &
        ( wi.num_module == it->second.num_module  ) )
       return it->first;
  return "No this word in modules!";  
}
#endif
