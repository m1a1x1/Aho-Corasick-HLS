typedef struct {
  uint8_t  tile_addr;
  uint32_t pmv;
  uint32_t ptr;
  uint8_t  id;
  uint8_t  addr;
} ac_conf;

#define IOC_MAGIC 'h' 
#define IOCTL_SET_CONF _IOW( IOC_MAGIC, 1, ac_conf ) 



