#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/io.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/miscdevice.h>
#include <linux/mm.h>
#include <linux/wait.h>
#include <linux/sched.h>
#include <linux/types.h>
#include <linux/dma-mapping.h>

#include "dma_test_mem_map.h"

/* prototypes */
static struct platform_driver the_platform_driver;

/* globals */
static struct platform_device *test_module_dev = NULL;
static int g_platform_probe_flag;
static int g_test_driver_base_addr;
static int g_test_driver_size;
//static int g_test_driver_irq;
static void *g_ioremap_addr;
//static void *g_ram_base;

static dma_addr_t ram_phys_addr;
static void *ram_virt_addr;

//
// misc device: RAM
//
#define IO_BUF_SIZE 8  // UVAGA
struct ram_dev {
	unsigned long open_count;
	unsigned long release_count;
	unsigned long read_count;
	unsigned long write_count;
	unsigned long read_byte_count;
	unsigned long write_byte_count;
	unsigned char io_buf[IO_BUF_SIZE];
};

static struct ram_dev the_ram_dev = {
	.open_count = 0,
	.release_count = 0,
	.read_count = 0,
	.write_count = 0,
	.read_byte_count = 0,
	.write_byte_count = 0,
	.io_buf = {0},
};

static ssize_t ram_dev_write(struct file *fp, const char __user *user_buffer,
		   size_t count, loff_t *offset)
{
	struct ram_dev *dev = fp->private_data;
	loff_t max_offset = RAM_SPAN;
	loff_t next_offset = *offset + count;
	size_t temp_count;
	void *ram_ptr;

	//pr_info("ram_dev_write enter\n");
	//pr_info("         fp = 0x%08X\n", (uint32_t)fp);
	//pr_info("user_buffer = 0x%08X\n", (uint32_t)user_buffer);
	//pr_info("      count = 0x%08X\n", (uint32_t)count);
	//pr_info("    *offset = 0x%08X\n", (uint32_t)*offset);
	
	dev->write_count++;

	if (*offset > max_offset) {
		pr_info("ram_dev_write offset > max_offset exit\n");
		return -EINVAL;
	}

	if (*offset == max_offset) {
		pr_info("ram_dev_write offset == max_offset exit\n");
		return -ENOSPC;
	}

	if (next_offset > max_offset)
		count -= next_offset - max_offset;

	temp_count = count;
	ram_ptr = g_ioremap_addr + RAM_OFST;
	ram_ptr += *offset;

	while (temp_count > 0) {
		int this_loop_count = IO_BUF_SIZE;
		if (temp_count < IO_BUF_SIZE)
			this_loop_count = temp_count;

		if (copy_from_user
		    (&dev->io_buf, user_buffer, this_loop_count)) {
			pr_info("ram_dev_write copy_from_user exit\n");
			return -EFAULT;
		}
		memcpy_toio(ram_ptr, &dev->io_buf, this_loop_count);
		temp_count -= this_loop_count;
		user_buffer += this_loop_count;
		ram_ptr += this_loop_count;
	}

	dev->write_byte_count += count;
	*offset += count;

	pr_info("ram_dev_write exit\n");
	return count;
}

static ssize_t ram_dev_read(struct file *fp, char __user *user_buffer,
		  size_t count, loff_t *offset)
{
	struct ram_dev *dev = fp->private_data;
	loff_t max_offset = RAM_SPAN;
	loff_t next_offset = *offset + count;
	size_t temp_count;
	void *ram_ptr;

	//pr_info("ram_dev_read enter\n");
	//pr_info("         fp = 0x%08X\n", (uint32_t)fp);
	//pr_info("user_buffer = 0x%08X\n", (uint32_t)user_buffer);
	//pr_info("      count = 0x%08X\n", (uint32_t)count);
	//pr_info("    *offset = 0x%08X\n", (uint32_t)*offset);

	dev->read_count++;

	if (*offset > max_offset) {
		pr_info("ram_dev_read offset > max_offset exit\n");
		return -EINVAL;
	}

	if (*offset == max_offset) {
		//pr_info("ram_dev_read offset == max_offset exit\n");
		return 0;
	}

	if (next_offset > max_offset)
		count -= next_offset - max_offset;

	temp_count = count;
	ram_ptr = g_ioremap_addr + RAM_OFST;
	ram_ptr += *offset;

	while (temp_count > 0) {
		int this_loop_count = IO_BUF_SIZE;
		if (temp_count < IO_BUF_SIZE)
			this_loop_count = temp_count;

		memcpy_fromio(&dev->io_buf, ram_ptr, this_loop_count);
		if (copy_to_user(user_buffer, &dev->io_buf, this_loop_count)) {
			pr_info("ram_dev_read copy_to_user exit\n");
			return -EFAULT;
		}
		temp_count -= this_loop_count;
		user_buffer += this_loop_count;
		ram_ptr += this_loop_count;
	}

	dev->read_byte_count += count;
	*offset += count;

	//pr_info("ram_dev_read exit\n");
	return count;
}

static int ram_dev_open(struct inode *ip, struct file *fp)
{
	struct ram_dev *dev = &the_ram_dev;
	//pr_info("ram_dev_open enter\n");
	//pr_info("ip = 0x%08X\n", (uint32_t)ip);
	//pr_info("fp = 0x%08X\n", (uint32_t)fp);

	fp->private_data = dev;
	dev->open_count++;

	//pr_info("ram_dev_open exit\n");
	return 0;
}

static int ram_dev_release(struct inode *ip, struct file *fp)
{
	struct ram_dev *dev = fp->private_data;
	//pr_info("ram_dev_release enter\n");
	//pr_info("ip = 0x%08X\n", (uint32_t)ip);
	//pr_info("fp = 0x%08X\n", (uint32_t)fp);

	dev->release_count++;

	//pr_info("ram_dev_release exit\n");
	return 0;
}

static const struct file_operations ram_dev_fops = {
	.owner = THIS_MODULE,
	.open = ram_dev_open,
	.release = ram_dev_release,
	.read = ram_dev_read,
	.write = ram_dev_write,
};

static struct miscdevice ram_dev_device = {
	.minor = MISC_DYNAMIC_MINOR,
	.name = "test_ram",
	.fops = &ram_dev_fops,
};

static int platform_probe(struct platform_device *pdev)
{
	int ret_val;
//	struct resource *r;

	pr_info("platform_probe enter\n");

	ret_val = -EBUSY;

	if (g_platform_probe_flag != 0)
		goto bad_exit_return;

	ret_val = -EINVAL;

//	/* get our first memory resource */
//	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
//	if (r == NULL) {
//		pr_err("IORESOURCE_MEM, 0 does not exist\n");
//		goto bad_exit_return;
//	}

	//g_test_driver_base_addr = r->start;
	g_test_driver_base_addr = DEV_BASE_ADDR;
	//g_test_driver_size = resource_size(r);
	g_test_driver_size = 0x6000;

	ret_val = -EBUSY;

	/* reserve our memory region */
	dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
	ram_virt_addr = dmam_alloc_coherent(&pdev->dev, RAM_SPAN, &ram_phys_addr, GFP_KERNEL);

	if (ram_virt_addr == NULL) {
		pr_err("dmam_alloc_coherent failed: ram_virt_addr\n");
		goto bad_exit_return;
	}

	//g_ram_base = g_ioremap_addr + RAM_OFST;
	//g_ram_base = ram_virt_addr;
	g_ioremap_addr = ram_virt_addr;

	pr_info("ram_phys_addr = 0x%08X\n", (uint32_t)ram_phys_addr);
	//pr_info("ram_virt_addr = 0x%08X\n", (uint32_t)ram_virt_addr);

	ret_val = -EBUSY;

	/* register misc device RAM */
	ret_val = misc_register(&ram_dev_device);
	if (ret_val != 0) {
		pr_warn("Could not register device \"test_ram\"...");
		goto bad_exit_return;
	}
	
	g_platform_probe_flag = 1;
	pr_info("platform_probe exit\n");
	return 0;

bad_exit_return:
	pr_info("platform_probe bad_exit\n");
	return ret_val;
}

static int platform_remove(struct platform_device *pdev)
{
//	uint32_t io_result;
	pr_info("platform_remove enter\n");

	misc_deregister(&ram_dev_device);

	dmam_free_coherent(&pdev->dev, RAM_SPAN, ram_virt_addr, ram_phys_addr);

	//pr_info("\n");
	//pr_info("ram_dev stats:\n");
	//pr_info("      open_count = %lu\n", the_ram_dev.open_count);
	//pr_info("   release_count = %lu\n", the_ram_dev.release_count);
	//pr_info("      read_count = %lu\n", the_ram_dev.read_count);
	//pr_info("     write_count = %lu\n", the_ram_dev.write_count);
	//pr_info(" read_byte_count = %lu\n", the_ram_dev.read_byte_count);
	//pr_info("write_byte_count = %lu\n", the_ram_dev.write_byte_count);
	//pr_info("\n");

	g_platform_probe_flag = 0;

	pr_info("platform_remove exit\n");
	return 0;
}

static struct platform_driver the_platform_driver = {
	.probe = platform_probe,
	.remove = platform_remove,
	.driver = {
		   .name = "test_module_pl",
		   .owner = THIS_MODULE,
		   },
};

static int test_init(void)
{
	int ret_val;
	pr_info("test_init enter\n");

	ret_val = platform_driver_register(&the_platform_driver);
	if (ret_val != 0) {
		pr_err("platform_driver_register returned %d\n", ret_val);
		return ret_val;
	}

	/* test: START */
	test_module_dev = platform_device_alloc("test_module_pl", 1);
	if (test_module_dev == NULL) {
		pr_err("platform_device_alloc returned NULL\n");
		ret_val = -ENOMEM;
		platform_driver_unregister(&the_platform_driver);
		return ret_val;
	}

	ret_val = platform_device_add(test_module_dev);
	if (ret_val != 0) {
		pr_err("platform_device_add returned %d\n", ret_val);
		platform_device_put(test_module_dev);
		platform_driver_unregister(&the_platform_driver);
		return ret_val;
	}
	/* test: END */

	pr_info("test_init exit\n");
	return 0;
}

static void test_exit(void)
{
	pr_info("test_exit enter\n");

	platform_device_unregister(test_module_dev);
	platform_driver_unregister(&the_platform_driver);

	pr_info("test_exit exit\n");
}

module_init(test_init);
module_exit(test_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("author");
MODULE_DESCRIPTION("test kernel module fo innovate FPGA");
MODULE_VERSION("1.0");


