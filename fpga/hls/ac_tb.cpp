#ifndef __APP__
  #include "HLS/hls.h"   
  #include "HLS/stdio.h"
  #include "HLS/ac_int.h"
#else
  #include "stdio.h"
#include <iostream>
#endif
#include <stdint.h>
#include <stdlib.h> 
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
    if( module_info[i].word_in_module >= sizeof(pmv_t)*8 ){
      module_busy++;
    }      
    for( int j = 0; j < TILE_CNT; j++ ){
      if( ( module_info[i].node_busy[j] + w_length ) >= MEM_WIDTH ){
        module_busy++;
        break;
      }
    }
  }
  if( module_busy == ( RULE_MODULE_CNT - 1 ) ){
    printf( "Error: all modules is busy!!!" );
    return -1;
  } 
  int ptr[TILE_CNT] = {0};
  int symbol_num = 0;
  for( char character : word ){
#ifndef __APP__
     uint8 symbol ( character );
#else
     uint8_t symbol = character;
#endif

     for( int i = 0; i < TILE_CNT; i++ ){
#ifndef __APP__
         uint2  part = symbol.slc<2>(i << 1);
#else
         uint8_t part = ( symbol >> i * 2  ) & 0x3;
#endif
       int local_ptr = mem[module_busy][i][ptr[i]].ptr[part];

       if( local_ptr == 0 ){
         module_info[module_busy].node_busy[i]++;
         mem[module_busy][i][ptr[i]].ptr[part] = module_info[module_busy].node_busy[i];
         if( symbol_num == w_length ){
           mem[module_busy][i][ptr[i]].pmv = ( 1 << module_info[module_busy].word_in_module ) |  
                                             mem[module_busy][i][ptr[i]].pmv;
           module_info[module_busy].node_busy[i]--;
           mem[module_busy][i][ptr[i]].ptr[part] = 1;
         } 
         ptr[i] = module_info[module_busy].node_busy[i];
       } else {
         if( ( symbol_num > 0 ) && ( local_ptr == 1 ) ){
           module_info[module_busy].node_busy[i]++;
           mem[module_busy][i][ptr[i]].ptr[part] = module_info[module_busy].node_busy[i];
           local_ptr =  module_info[module_busy].node_busy[i];
         } 
         if( symbol_num == w_length ){
           mem[module_busy][i][ptr[i]].pmv = ( 1 << module_info[module_busy].word_in_module ) | 
                                             mem[module_busy][i][ptr[i]].pmv; 
           }
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

void InfoAC::PrintTitleContent( int module_num, int tile_num ){
  for( int i = 0; i < MEM_WIDTH; i++ ){
    printf("| %4d | %4d | %4d | %4d | %3x |\n", mem[module_num][tile_num][i].ptr[0],
                                           mem[module_num][tile_num][i].ptr[1],
                                           mem[module_num][tile_num][i].ptr[2],
                                           mem[module_num][tile_num][i].ptr[3],
                                           mem[module_num][tile_num][i].pmv   );
  }
}

void InfoAC::PrintModuleContent( int module_num ){
  for(int i = 0; i < TILE_CNT; i++ ){
    printf("Tile #%d\n", i );
    printf("+++++++++++++++++++++++++++++++++++\n");
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

void InfoAC::SoftFind( const std::string & text ){
  #pragma omp for
  for(std::map<std::string, word_info>::iterator it=words.begin(); it!=words.end(); it++){
    size_t pos = text.find(it->first);
    while( pos != std::string::npos ){
      sw_result[it->first]++;
      sw_total++;
      pos = text.find(it->first, pos + 1 );
    }
  }
}

void InfoAC::HwFind( const std::string & word ){
  hw_result[word]++;
  hw_total++;
}

void InfoAC::PrintTotalFind(){
  cout << "Total find: " << endl;
  cout << "SW total: " << sw_total << endl;
  cout << "HW total: " << hw_total << endl;
}


void InfoAC::PrintResult(){
  std::cout << "### FIND RESULT ###"  << std::endl;
  printf("| %14s | %6s | %6s |\n", "String", "Soft", "FPGA" );
  for(std::map<std::string, word_info>::iterator it=words.begin(); it!=words.end(); it++){
    printf("| %14s | %6d | %6d |\n", it->first.c_str(), sw_result[it->first], hw_result[it->first] );
  }
}

#ifndef __APP__
  ac_word InfoAC::GetInfo( const csr_ac & csr ){
    return mem[csr.rule_module_num][csr.tile_num][csr.node_addr];  
  }
#else
  ac_word InfoAC::GetInfo( const uint8_t & module,
                           const uint8_t & tile_num,
                           const uint8_t & addr ){
    return mem[module][tile_num][addr]; 
  } 
#endif
 
std::string InfoAC::WordInfoToWord( const word_info & wi ){
  for (std::map<std::string, word_info>::iterator it=words.begin(); it!=words.end(); it++)
    if( ( wi.word_id == it->second.word_id ) &
        ( wi.num_module == it->second.num_module  ) )
       return it->first;
  return "No this word in modules!";  
}
#endif
