#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <unistd.h>
#include <errno.h>
  
#define MAP_SIZE           (4096)
#define MAP_MASK           (MAP_SIZE-1)


int main( int argc, char *argv[] ) 
{
  int fd;

  if( argc < 2 ) {
    printf( "Usage:\n" );
    printf( "%s byte_addr [write_data]\n", argv[ 0 ] );
    exit( -1 );
  }

  // /dev/mem это файл символьного устройства, являющийся образом физической памяти.
  fd = open( "/dev/mem", O_RDWR | O_SYNC );
  if( fd < 0 ) {
    perror( "open" );
    exit( -1 ); 
  }

  void *map_page_addr, *map_byte_addr; 
  off_t byte_addr;
  
  byte_addr = strtoul( argv[ 1 ], NULL, 0 );

  // Выполняем отображение файла /dev/mem в адресное пространство нашего процесса. Получаем адрес страницы.
  map_page_addr = mmap( 0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, byte_addr & ~MAP_MASK );
  if( map_page_addr == MAP_FAILED ) {
    perror( "mmap" );
    exit( -1 ); 
  }

  // Вычисляем адрес требуемого слова (адрес при этом байтовый) 
  map_byte_addr = map_page_addr + (byte_addr & MAP_MASK);

  uint32_t data;

  // Если аргументов три, значит записываем данные, иначе -- читаем и выводим на экран.
  printf( "%d\n", getpagesize() );
  if( argc > 2 ) {
    data = strtoul( argv[ 2 ], NULL, 0 );
    for( int i = 0; i < getpagesize()/sizeof(uint64_t); i++ ){
      *( ( uint32_t *) map_byte_addr ) = data;
      usleep( 1000 );
    }
  } else {
    data = *( ( uint32_t *) map_byte_addr );
    printf( "data = 0x%08x\n", data );
  }

  // Убираем отображение.
  if( munmap( map_page_addr, MAP_SIZE ) ) {
    perror( "munmap" );
    exit( -1 ); 
  }

  close( fd );
  return 0;
}
