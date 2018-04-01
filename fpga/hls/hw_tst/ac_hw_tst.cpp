#include <stdint.h>
#include <stdlib.h> 

#include "HLS/stdio.h"
#include "HLS/hls.h"   
#include "HLS/ac_int.h"


#define STR "aabbccddee"
#define LEN sizeof(STR)/sizeof(char)
typedef ihc::stream_out< char, ihc::usesPackets<true> > ast_src;


hls_avalon_slave_component 
component
void gen_pattern( ast_src & src){
  char * str = STR; 
  for( uint8_t i = 0; i < LEN; i++){
    src.write( str[i], i == 0, i == ( LEN -1 ) ); 
  }
}


int main( ){
  ast_src src;
  gen_pattern( src );
  bool sop = false;
  bool eop = false;
  for( uint8_t i = 0; i < LEN; i++){
     std::cout << src.read( sop, eop )
               << " sop: " << sop 
               << " eop: " << eop << std::endl;
  }
}
