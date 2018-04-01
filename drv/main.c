#include <linux/cdev.h>          
#include <linux/init.h>          
#include <linux/platform_device.h>
#include <linux/dma-mapping.h>
#include <linux/string.h>
#include <linux/vmalloc.h>
#include <linux/slab.h>
#include <linux/mm.h>
#include <linux/errno.h>
#include <linux/module.h>        
#include <linux/device.h>        
#include <linux/kernel.h>        
#include <linux/fs.h>            
#include <linux/io.h>            
#include <linux/of.h>            
#include <linux/of_irq.h>
#include <linux/interrupt.h>
#include <linux/wait.h>            
#include <asm/uaccess.h>         
#include "tst.h"
#include "common_ac.h"

void fpga_write(int reg, u32 val, void* fpga_regs){
  iowrite32(val, fpga_regs + 4*reg);
}
uint32_t fpga_read(int reg, void* fpga_regs ){
  return ioread32( fpga_regs + 4*reg );
}

void conf_ah_handler( struct tst_data *td){
  int rd_ptr = atomic_read( &td->read_ptr );
  fpga_write( IRQ_ADDR, IRQ_OFF, td->ah_handler );
  fpga_write( CTL_DMA_ADDR, td->dma_buffers[rd_ptr].phys_addr, td->ah_ctl );
  fpga_write( CNT_RES_ADDR, 0, td->ah_handler );
  fpga_write( IRQ_ADDR, IRQ_ON, td->ah_handler );
  fpga_write( START_ADDR, START, td->ah_handler ); 
}

static int dev_open(struct inode *inodep, struct file *filep){
  struct tst_data *td = container_of(inodep->i_cdev, struct tst_data, c_dev);
  filep->private_data = td;

  if( td->numberOpens != 0 ){
    return -EBUSY;
  }
 
  printk( KERN_INFO "Dev open\n");
  td->numberOpens++;
  conf_ah_handler( td );
  return 0;
}
   
static ssize_t dev_read(struct file *filep, char *buffer, size_t len, loff_t *offset){
   int search_cnt = 0;
   struct tst_data *td = filep->private_data;

   printk( KERN_INFO "Atomic irq: %d rd %d\n", atomic_read( &td->irq_cnt ), atomic_read( &td->read_ptr ));
   wait_event_interruptible( td->wq_irq,
                             atomic_read( &td->irq_cnt ) != atomic_read( &td->read_ptr ) );
   search_cnt = atomic_read( &td->search_cnt);   
   if ( ( copy_to_user( buffer,
                        td->dma_buffers[atomic_read( &td->read_ptr )].virt_addr,
                        search_cnt * sizeof( uint64_t ) ) ) != 0 ){
      printk(KERN_INFO "Copy to user faild" );
      return -EFAULT;
   }
   
  if( atomic_read( &td->read_ptr ) == ( BUFFER_CNT - 1 ) ) 
    atomic_set( &td->read_ptr, 0 );
  else
    atomic_inc( &td->read_ptr );  

   return search_cnt * sizeof(uint64_t);
}
  


int dev_ioctl(struct inode *inodep, struct file *filep, unsigned int num, unsigned long param){
  struct tst_data *td = container_of(inodep->i_cdev, struct tst_data, c_dev);
  uint8_t * ah_regs_ptr;
  ac_conf * user_acc = ( ac_conf * ) param;
  ac_conf acc;
  
  copy_from_user( &acc, user_acc, sizeof( ac_conf ) );
  ah_regs_ptr = ( uint8_t *) td->ah_regs + AC_REGS_LEN * acc.id;

  fpga_write( TILE_ADDR, acc.tile_addr, ah_regs_ptr ); 
  fpga_write( PMV_ADDR, acc.pmv, ah_regs_ptr ); 
  fpga_write( PTR_ADDR, acc.ptr, ah_regs_ptr ); 
  fpga_write( CONF_ADDR, 1, ah_regs_ptr ); 
  fpga_write( ID_ADDR, acc.id, ah_regs_ptr ); 
  fpga_write( MEM_ADDR, acc.addr, ah_regs_ptr ); 
  fpga_write( CONF_ADDR, 0, ah_regs_ptr );
  return 0; 
}


static int creat_buffers( struct platform_device *pdev ){
  int i;
  int ret = 0;
  struct tst_data *td = platform_get_drvdata( pdev );

  for( i = 0; i < BUFFER_CNT; i++  ){
    td->dma_buffers[i].virt_addr = dmam_alloc_coherent( &pdev->dev, BUFFER_SIZE,
                                                         &td->dma_buffers[i].phys_addr, GFP_KERNEL);
    if( !td->dma_buffers[i].virt_addr ){
      dev_err(&pdev->dev, "dmam_alloc_coherent error\n");
      ret = -ENOMEM;
      i--;
      goto free_buf;
    }
  }

  return 0;
free_buf:
  for( ; i >= 0; i-- ){
    dmam_free_coherent( &pdev->dev, BUFFER_SIZE, td->dma_buffers[i].virt_addr, td->dma_buffers[i].phys_addr);
  }
  return ret; 
}


static void free_buffers( struct platform_device *pdev ){
  int i;
  struct tst_data *td = platform_get_drvdata( pdev );
  for( i = 0; i < BUFFER_CNT; i++ ){
    dmam_free_coherent( &pdev->dev, BUFFER_SIZE, td->dma_buffers[i].virt_addr, td->dma_buffers[i].phys_addr);
  }
} 


static irqreturn_t tst_isr(int irq, void *dev_id){
  struct tst_data * td = dev_id; 

  if( atomic_read( &td->irq_cnt ) == ( BUFFER_CNT - 1 ) ) 
    atomic_set( &td->irq_cnt, 0 );
  else
    atomic_inc( &td->irq_cnt ); 
  
  atomic_set( &td->search_cnt,
              fpga_read( CNT_RES_ADDR, td->ah_handler) ); 
  conf_ah_handler( td );
  
  
  wake_up_interruptible(&td->wq_irq);

  return IRQ_HANDLED;
}

static int dev_release(struct inode *inodep, struct file *filep){
   struct tst_data *td = filep->private_data;
   td->numberOpens--;
   return 0;
}

static struct file_operations fops =
{
   .open = dev_open,
   .read = dev_read,
   .unlocked_ioctl= dev_ioctl,
   .release = dev_release,
};

static const struct of_device_id tst_of_match[] = {
	{ .compatible = "zynq,tst", },
	{},
};

MODULE_DEVICE_TABLE(of, tst_of_match);

static int parse_dt( struct platform_device *pdev ){
   int ret = 0;
   struct resource *reg_res;
   struct tst_data *td = platform_get_drvdata( pdev );

   reg_res = platform_get_resource_byname( pdev, IORESOURCE_MEM, "ah_handler" );
   if( !reg_res ){
     return -ENODEV;
   }

   td->ah_handler = devm_ioremap_resource(&pdev->dev, reg_res);
   if( IS_ERR( td->ah_handler ) ){
     dev_err( &pdev->dev, "devm ioremap resource error!" );
     return -ECANCELED;
   }

   reg_res = platform_get_resource_byname( pdev, IORESOURCE_MEM, "ah_csr" );
   if( !reg_res ){
     return -ENODEV;
   }

   td->ah_regs = devm_ioremap_resource(&pdev->dev, reg_res);
   if( IS_ERR( td->ah_regs ) ){
     dev_err( &pdev->dev, "devm ioremap resource error!" );
     return -ECANCELED;
   }

   td->irq = irq_of_parse_and_map(pdev->dev.of_node, 0);
   if( !td->irq ){
     dev_err( &pdev->dev, "Failed to parse and map IRQ");
     return -ECANCELED;
   }

   ret = devm_request_irq(&pdev->dev, td->irq, tst_isr,
	                        IRQF_SHARED, DEVICE_NAME, td );
   if( ret ){
     dev_err( &pdev->dev, "Failed to request IRQ for TST");
     return -ECANCELED;
   }

   if( of_property_read_u32(pdev->dev.of_node, "ah-module-cnt",
                            &td->ah_module_cnt ) ) {
     dev_err(&pdev->dev, "Cannot obtain ah-module-cnt\n");
     return -ENXIO;
   }
return 0;

}

static int tst_probe(struct platform_device *pdev){
   int retval = 0;
   struct tst_data *td = kzalloc( sizeof( struct tst_data ), GFP_KERNEL );

   td->DeviceName  = kmalloc( sizeof( DEVICE_NAME ), GFP_KERNEL );
   td-> DeviceClass = kmalloc( sizeof( CLASS_NAME ), GFP_KERNEL );

   sprintf( td->DeviceName , "%s", DEVICE_NAME );
   sprintf( td->DeviceClass, "%s", CLASS_NAME  );
   
   td->numberOpens = 0;

   platform_set_drvdata( pdev, td );

   init_waitqueue_head(&td->wq_irq); 
   atomic_set( &td->irq_cnt,  0 );
   atomic_set( &td->read_ptr, 0 );
   
   td->majorNumber = register_chrdev(0, td->DeviceName, &fops);
    if( td->majorNumber < 0 ){
      dev_err( &pdev->dev, "Failed to register a major number");
      return td->majorNumber;
   }

   td->charClass = class_create(THIS_MODULE, td->DeviceClass);
   if (IS_ERR(td->charClass)){           
      dev_err( &pdev->dev,"Failed to register device class");
      retval = PTR_ERR(td->charClass);
      goto unreg_dev;    
   }

   cdev_init(&td->c_dev, &fops);
  
   td->charDevice = device_create(td->charClass, NULL, MKDEV(td->majorNumber, 0), NULL, td->DeviceName);
   if (IS_ERR(td->charDevice)){     
      dev_err( &pdev->dev, "Failed to create the device");
      retval = PTR_ERR(td->charDevice);
      goto class_dstr;
   }

   retval = cdev_add(&td->c_dev, MKDEV( td->majorNumber, 0 ), 1);
   if( retval < 0 ){
     goto unreg_dev;
   }
   retval = creat_buffers( pdev );
   if( retval < 0 ){
     goto unreg_dev;
   }

   if( parse_dt( pdev ) < 0 ){
     dev_err( &pdev->dev, "Device tree parse error");
     goto dma_free;
   }
    
   return 0;

dma_free:
  free_buffers( pdev );
dev_dstr:
   device_destroy( td->charClass, MKDEV(td->majorNumber, 0) );    
class_dstr:
   class_destroy(td->charClass);
unreg_dev:
   kfree( td->DeviceName );
   kfree( td->DeviceClass );
   unregister_chrdev( td->majorNumber, td->DeviceName );
   return retval; 
}



static int tst_remove( struct platform_device *pdev ){
   struct tst_data *td;
   td = platform_get_drvdata( pdev );

   if( td->numberOpens == 0 ){
     free_buffers( pdev );
     device_destroy( td->charClass, MKDEV(td->majorNumber, 0) );    
     class_destroy(td->charClass);
     unregister_chrdev(td->majorNumber, td->DeviceName);
     kfree( td->DeviceName );
     kfree( td->DeviceClass );
     cdev_del( &td->c_dev );
     kfree( td );
     printk( KERN_INFO "Remove tst device\n" ); 
     return 0;
   } else {
     printk( KERN_INFO "Device can't remove. Device is busy!\n" );
     return -1;
   }    
}
 
static struct platform_driver tst_driver = {
    .remove = tst_remove,
    .driver = {
        .name   = DEVICE_NAME,
        .owner  = THIS_MODULE,
        .of_match_table = of_match_ptr(tst_of_match),
    },
};

static void __exit tst_exit(void){
   platform_driver_unregister(&tst_driver);
}


static int __init tst_init(void){
   int retval = platform_driver_probe( &tst_driver, tst_probe );

   if( retval < 0 ) {
     printk(KERN_ERR "Failed to probe TST_DEV platform driver\n");
     return retval; 
   }

   printk(KERN_INFO "TST_DEV: device created correctly\n");
   return 0;

}

module_init(tst_init);
module_exit(tst_exit);

MODULE_LICENSE("GPL");           
MODULE_DESCRIPTION("Driver for testing zynq");
