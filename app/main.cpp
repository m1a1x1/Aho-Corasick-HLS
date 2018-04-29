#include <stdint.h>
#include <stdlib.h>

#include <time.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
 
#include <fstream>
#include <iostream>

#include "common_ac.h" 
#include "ac.h" 

#define NSEC_PER_SEC 1000000000

#define MAP_SIZE           (4096)
#define MAP_MASK           (MAP_SIZE-1)
#define GET_MASK(y) ( ( 1 << y ) - 1 )
using namespace std;

uint64_t timespec_to_ns( struct timespec ts ){
  return ( ts.tv_sec * NSEC_PER_SEC ) + ts.tv_nsec;
}

double GetFPGATime(){
  void *map_page_addr, *map_byte_addr; 
  uint32_t hw_tick;
  int fd = open( "/dev/mem", O_RDWR | O_SYNC );
  off_t byte_addr = 0xC0002000;
 
  if( fd < 0 ) {
    perror( "open" );
    exit( -1 ); 
  }

  map_page_addr = mmap( 0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, byte_addr & ~MAP_MASK );
  if( map_page_addr == MAP_FAILED ) {
    perror( "mmap" );
    exit( -1 ); 
  }

  map_byte_addr = map_page_addr + (byte_addr & MAP_MASK);

  hw_tick = *( ( uint32_t *) map_byte_addr );

  if( munmap( map_page_addr, MAP_SIZE ) ) {
    perror( "munmap" );
    exit( -1 ); 
  }

  close( fd );

  return hw_tick*(1/156.25e6)*1e6;
}

timespec TimeDiff(timespec start, timespec end){
   timespec temp;
   if( (end.tv_nsec-start.tv_nsec) < 0) {
     temp.tv_sec = end.tv_sec-start.tv_sec - 1;
     temp.tv_nsec = 1000000000 + end.tv_nsec - start.tv_nsec;
   } else {
     temp.tv_sec = end.tv_sec - start.tv_sec;
     temp.tv_nsec = end.tv_nsec - start.tv_nsec;
   }
   return temp;
}

int ReadingSearchStrings( const string & fn, InfoAC & info_ac ){
  ifstream input( fn );
  if( !input.is_open() ){
    return -1;
  }

  cout << "Fill tile, from " << fn << " file ..." << endl;
  string line;
  while( getline( input, line ) ){
    if( info_ac.SetWord(line) < 0 ){
      cout << "Can't load this word: " << line << endl;
    }
  }
  cout << "Finish filling " << endl;
  //info_ac.PrintWordsContent();
  return 0;
}

void ConfigAcFpgaModule( int f_dev, InfoAC & info_ac ){

  ac_word word;  
  ac_conf acc;
  for( int i = 0; i < RULE_MODULE_CNT; i++ ){
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
    string word;
    for( int i = 0; i < read_len/sizeof(uint64_t); i++ ){
       //cout << *( res_buffer + i ) << endl;
       rs.num_module = *( res_buffer + i ) & GET_MASK(8);  
       rs.word_id = ( *( res_buffer + i ) >> 32 ) & GET_MASK(32);  
       //cout << "PVM: " << rs.word_id
       //     << " Word: " << info_ac.WordInfoToWord( rs ) << endl;
       info_ac.HwFind( info_ac.WordInfoToWord( rs ) ); 
    } 
}


double PrintSummary( InfoAC & info_ac ){
  struct timespec start, stop;
  double sw_time, hw_time;

  ifstream t("/dev/test_ram");
  if( !t.is_open() ){
    cout << "Not such file /dev/test_ram!" << endl;
    return -1;
  }

  string buffer ((std::istreambuf_iterator<char>(t)), std::istreambuf_iterator<char>());

  clock_gettime( CLOCK_REALTIME, &start );
  info_ac.SoftFind( buffer );
  clock_gettime( CLOCK_REALTIME, &stop );

  // Convert to microseconds
  sw_time = timespec_to_ns( TimeDiff( start, stop ) ) * 1e6;
  hw_time = GetFPGATime();

  info_ac.PrintResult();
  info_ac.PrintTotalFind();
  cout << "Time 'software find' vs 'FPGA find': " << endl;
  cout << "SW : " << sw_time << endl;
  cout << "HW : " << hw_time << endl;
}

int main(){
  InfoAC info_ac;
  size_t read_len = 100*getpagesize();
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

  size_t p_size = 100*getpagesize(); 
  uint64_t * res_buffer = ( uint64_t *) malloc( p_size  );

  while( read_len == p_size ){
    read_len = read( f_dev, res_buffer, p_size );
    //printf( "LEN: %d\n", read_len );
    //cout << *( res_buffer ) << endl;
    PrintResult( read_len, res_buffer, info_ac );
  }

  PrintSummary( info_ac );

  cout << "Exit!" << endl;

  free( res_buffer );
  return 0;
}
