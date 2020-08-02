#include <linux/string.h>
#include <linux/kernel.h>
#include <linux/string.h>
#include <linux/sched/clock.h>

#define BUF_SIZE 1024*1024
#define LOOP_NUM 1024

// Expects 8 byte aligned
double memmove_buf[BUF_SIZE * 2 / 8];

static __init int memmove_test(void)
{
	int i;
	u64 start, end;
	char *buf = (char*)memmove_buf;

	memset(buf, 1, BUF_SIZE * 2);

	printk(KERN_CONT "memmove perf test. %d bytes buffer %d loop.\n", BUF_SIZE, LOOP_NUM);

	start = local_clock();
	for (i = 0; i < LOOP_NUM; i++) {
		memmove(&buf[0], &buf[BUF_SIZE], BUF_SIZE);
	}
	end = local_clock();
	
	printk(KERN_CONT "memmove no-overlap: %llu nsecs\n", end - start);

	start = local_clock();
	for (i = 0; i < LOOP_NUM; i++) {
		memmove(&buf[0], &buf[BUF_SIZE / 2], BUF_SIZE);
	}
	end = local_clock();
	
	printk(KERN_CONT "memmove overlap dst < src: %llu nsecs\n", end - start);

	start = local_clock();
	for (i = 0; i < LOOP_NUM; i++) {
		memmove(&buf[BUF_SIZE / 2], &buf[0], BUF_SIZE);
	}
	end = local_clock();
	
	printk(KERN_CONT "memmove overlap dst > src: %llu nsecs\n", end - start);

	printk(KERN_CONT "Dummy print %d\n", buf[0]);
	return 0;
}
early_initcall(memmove_test);
