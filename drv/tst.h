#define  DEVICE_NAME "ac_dev"   
#define  CLASS_NAME  "ac_class"

#define SIZE_DESC  0x40 
#define DESC_ADDR 0x40000000

#define AC_REGS_LEN 0x80

// Ac Module
#define TILE_ADDR 0x8
#define ID_ADDR   0xe
#define CONF_ADDR 0x10

// AC Handler
#define START_ADDR   0x2
#define IRQ_ADDR     0x4
#define RETURN_ADDR  0x8
#define PMV_ADDR     0xd
#define PTR_ADDR     0xc
#define CNT_RES_ADDR 0xa 

// HLS CTL
#define CTL_DMA_ADDR 0x0

#define START   1
#define IRQ_ON  1
#define IRQ_OFF 0
#define EOF            ( 0 )

#define BUFFER_SIZE 128*sizeof(uint64_t)
#define BUFFER_CNT 16

void fpga_write(int reg, u32 val, void* fpga_regs);
uint32_t fpga_read(int reg, void* fpga_regs );

typedef struct {
  dma_addr_t      phys_addr;
  unsigned char * virt_addr;
} dma_buffer;


struct tst_data{
  int               majorNumber;                  
  int               numberOpens;              
  struct class  *   charClass; 
  struct device *   charDevice;
  char *            DeviceName;
  char *            DeviceClass;
  void *            ah_ctl;
  void *            ah_regs;
  void *            ah_handler;
  phys_addr_t       desc_phys;
  struct cdev       c_dev;
  int               irq;
  atomic_t          irq_cnt;
  atomic_t          read_ptr;
  atomic_t          search_cnt;
  wait_queue_head_t wq_irq;
  uint32_t          ah_module_cnt;    
  dma_buffer        dma_buffers[BUFFER_CNT];
};




struct ac_conf{
  uint32_t id;
};
