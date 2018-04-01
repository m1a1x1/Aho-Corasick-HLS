#include <stdint.h>
#include <stdlib.h>

#include <fcntl.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <unistd.h>
 
#include <fstream>
#include <iostream>

#include "common_ac.h" 
#include "ac.h" 

#define GET_MASK(y) ( ( 1 << y ) - 1 )
#define MODULE_CNT 2
using namespace std;

int ReadingSearchStrings( const string & fn, InfoAC & info_ac ){
  ifstream input( fn );
  if( !input.is_open() ){
    return -1;
  }

  cout << "Fill tile, from " << fn << " file ..." << endl;
  string line;
  while( getline( input, line ) ){
    info_ac.SetWord(line);
  }
  cout << "Finish filling " << endl;
  return 0;
}

void ConfigAcFpgaModule( int f_dev, InfoAC & info_ac ){

  ac_word word;  
  ac_conf acc;
  for( int i = 0; i < MODULE_CNT; i++ ){
    for( int j = 0; j < TILE_CNT; j++ ){
      for( int k = 0; k < MEM_WIDTH; k++ ){
        word = info_ac.GetInfo( i, j, k );

        acc.id        = i;
        acc.tile_addr = j;
        acc.addr      = k;

        acc.pmv = word.pmv;
        acc.ptr = ( word.ptr[3] << 24 ) |
                  ( word.ptr[2] << 16 ) |
                  ( word.ptr[1] << 8 ) | 
                  ( word.ptr[0] );
        ioctl( f_dev, IOCTL_SET_CONF, &acc );
      }
    }
  }      
}


void PrintResult( int read_len, uint64_t * res_buffer, InfoAC & info_ac ){
    word_info rs;

    for( int i = 0; i < read_len/sizeof(uint64_t); i++ ){
       rs.num_module = *( res_buffer + i ) & GET_MASK(8);  
       rs.word_id = ( *( res_buffer + i ) >> 8 ) & GET_MASK(32);  
       cout << "PVM: " << rs.word_id
            << " Word: " << info_ac.WordInfoToWord( rs ) << endl;
    } 
}


int main(){
  InfoAC info_ac;
  size_t read_len = getpagesize();
  int f_dev = open("/dev/ac_dev", O_RDWR );

  if( f_dev < 0 ){
    cout << "No such device!" << endl;
    return -1;
  }

  if( ReadingSearchStrings( "words", info_ac ) < 0 ){
    cout << "Not whith search words!" << endl;
    return -1;
  }

  ConfigAcFpgaModule( f_dev, info_ac );

  size_t p_size = getpagesize(); 
  uint64_t * res_buffer = ( uint64_t *) malloc( p_size  );

  while( read_len == p_size ){
    read_len = read( f_dev, res_buffer, p_size );
    PrintResult( read_len, res_buffer, info_ac );
  }

  if( read_len != 0 ){
    PrintResult( read_len, res_buffer, info_ac );
  }
  cout << "Exit!" << endl;

  free( res_buffer );
  return 0;
}
