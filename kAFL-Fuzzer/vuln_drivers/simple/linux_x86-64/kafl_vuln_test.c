#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/proc_fs.h>
#include <linux/string.h>
#include <linux/vmalloc.h>
#include <asm/uaccess.h>
#include <linux/version.h>
#include <linux/slab.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Sergej Schumilo");
MODULE_DESCRIPTION("kAFL Test Module");

#define MAX_LEN		128
#define NAME	    "kafl_vuln"

ssize_t write_info(struct file *filp, const char __user *buff, size_t len, loff_t *data);

struct proc_dir_entry *proc_file_entry;

static const struct proc_ops proc_ops = {
	.proc_flags = 0,
	.proc_write = write_info,
};

int init_mod( void )
{
	proc_file_entry = proc_create(NAME, 0666, NULL, &proc_ops);
	if(proc_file_entry == NULL)
		return -ENOMEM;
	return 0;
}

void cleanup_mod( void )
{
	remove_proc_entry(NAME, NULL);
	printk(KERN_INFO "/proc/%s removed.\n", NAME);
}

module_init(init_mod);
module_exit(cleanup_mod);

ssize_t write_info(struct file *filp, const char __user *buff, size_t len, loff_t *data) {
	char input[256];
	int *array = (int *)kmalloc(1332, GFP_KERNEL);
	
	if (len >= 256){
		return -EFAULT;
	}
	
	if (copy_from_user(input, buff, len)) {
		return -EFAULT;
	}
	
	if(input[0] == 'K')
		if(input[1] == 'E')
			if(input[2] == 'R')
				if(input[3] == 'N')
					if(input[4] == 'E')
						if(input[5] == 'L')
							if(input[6] == 'A')
								if(input[7] == 'F')
									if(input[8] == 'L')
										panic(KERN_INFO "KAFL...\n"); /* boom! bug incoming... */
	if(input[0] == 'S')
		if(input[1] == 'E')
			if(input[2] == 'R')
				if(input[3] == 'G')
					if(input[4] == 'E')		
						if(input[5] == 'J')
							panic(KERN_INFO "SERGEJ...\n");

	if(input[0] == 'K'){
    	if(input[1] == 'A'){
        	if(input[2] == 'S'){
            	if(input[3] == 'A'){
                	if(input[4] == 'N'){
						kfree(array);
						array[0] = 1234;
					}
				}
        	}
        }
	}
	kfree(array);
	return len;

}

