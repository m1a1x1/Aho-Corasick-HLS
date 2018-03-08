#ifndef _AC_
#define _AC_

#include <map>
#include <streambuf>

#define PRINTF_BINARY_PATTERN_INT8 "%c%c%c%c%c%c%c%c"
#define PRINTF_BYTE_TO_BINARY_INT8(i)    \
    (((i) & 0x80ll) ? '1' : '0'), \
    (((i) & 0x40ll) ? '1' : '0'), \
    (((i) & 0x20ll) ? '1' : '0'), \
    (((i) & 0x10ll) ? '1' : '0'), \
    (((i) & 0x08ll) ? '1' : '0'), \
    (((i) & 0x04ll) ? '1' : '0'), \
    (((i) & 0x02ll) ? '1' : '0'), \
    (((i) & 0x01ll) ? '1' : '0')


#define RULE_MODULE_CNT 32 
#define TILE_CNT        4
#define MEM_WIDTH       256

typedef uint24 pmv_t;
typedef uint8  ptr_t;
typedef struct{
  ptr_t ptr[4]; 
  pmv_t pmv;
} ac_word;


typedef struct{
  uint8   rule_module_num;
  uint2   title_num;
  uint8   node_addr;
  ac_word node;
  bool conf;
} csr_ac;

typedef struct{
  int node_busy[TILE_CNT];
  int word_in_module;
} rule_module_info;

typedef struct{
  uint8  rule_module_num;
  uint12 pvm;
  uint32 offset; 
} find_info;

typedef struct{
  int word_id;
  int num_module;
} word_info;

#ifndef FPGA_ONLY
class InfoAC{
  private:
    ac_word mem [RULE_MODULE_CNT][TILE_CNT][MEM_WIDTH];
    rule_module_info module_info[RULE_MODULE_CNT]; 
    std::map<std::string, word_info> words;       
  public:
    InfoAC();
    int SetWord( const std::string & word );
    void PrintTitleContent( int module_num, int title_num );
    void PrintModuleContent( int module_num );
    void PrintBinString( const std::string & word );
    void PrintWordsContent();
    void SearchInString( const std::string & text );
    ac_word GetInfo( const csr_ac & csr );
    std::string WordInfoToWord( const word_info & wi );
};
#endif
#endif
