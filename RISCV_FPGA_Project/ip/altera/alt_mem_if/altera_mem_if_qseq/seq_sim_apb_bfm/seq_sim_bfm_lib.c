#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>

#include "vc_hdrs.h"

#include "alt_types.h"

long long current_sim_time;

pthread_mutex_t work_mutex;
pthread_cond_t response_available_cv;
pthread_cond_t request_available_cv;

int request_pending;
svBitVecVal request_addr;
svBitVecVal request_write_val;
unsigned char request_is_write;

int response_pending;
svBitVecVal response_addr;
svBitVecVal response_read_val;
unsigned char response_is_write;

int sequencer_done = 0;

void 
io_write(alt_u32 addr, alt_u32 data, alt_u32 avl_addr)
{
	printf("\tSEQ: Writing 0x%x to 0x%x [avl %0x ]\n", data, addr, avl_addr);

	pthread_mutex_lock(&work_mutex);

	request_addr = (svBitVecVal)addr;

	request_write_val = data;
	request_is_write = 1;

	request_pending = 1;		/* set request flag */

	/* signal request pending */
	pthread_cond_signal(&request_available_cv);

	while (response_pending == 0) {
		printf("\tSEQ: Waiting for read/write response\n");
		pthread_cond_wait(&response_available_cv, &work_mutex);
	}

	printf("\tSEQ: Got write response is_write=%c addr=%x\n",
	     response_is_write ? 'Y' : 'N', response_addr);

	response_pending = 0;		/* clear response flag */

	pthread_mutex_unlock(&work_mutex);
}



alt_u32
io_read(alt_u32 addr, alt_u32 avl_addr)
{
	alt_u32 val;
	
	printf("\tSEQ: Reading from 0x%0x [avl %0x ]\n", addr, avl_addr);

	pthread_mutex_lock(&work_mutex);

	request_addr = (svBitVecVal)addr;
	request_is_write = 0;

	request_pending = 1;		/* set request flag */

	/* signal request pending */
	pthread_cond_signal(&request_available_cv);

	while (response_pending == 0) {
		printf("\tSEQ: Waiting for read response\n");
		pthread_cond_wait(&response_available_cv, &work_mutex);
	}

	printf("\tSEQ: Got read response is_write=%c addr=%x data=%x\n",
	     response_is_write ? 'Y' : 'N', response_addr, response_read_val);

	val = response_read_val;

	response_pending = 0;		/* clear response flag */

	pthread_mutex_unlock(&work_mutex);

	return (alt_u32)val;
}


void
tcldbg_init_status_counters()
{
}

void
tcldbg_initialize()
{
}

void
tclrpt_initialize()
{
}

// Called from C code when it is done
void
bfm_sequencer_is_done()
{
  	printf("\tSEQ: tcl_debug_loop called; Done\n");
	pthread_mutex_lock(&work_mutex);
	sequencer_done = 1;
	/* signal anyone waiting on another request that will now never come */	
	pthread_cond_signal(&request_available_cv);
	pthread_mutex_unlock(&work_mutex);
	pthread_exit(NULL);
}

void
tcl_debug_loop()
{
	bfm_sequencer_is_done();
}

void seq_start(long long sim_time)
{
	pthread_t thread;
	int rc;
	long t;

	int seq_main(void);	/* in sequencer */

	current_sim_time = sim_time;

	/* Initialize mutex and condition variable objects */
	pthread_mutex_init(&work_mutex, NULL);
	pthread_cond_init (&response_available_cv, NULL);
	pthread_cond_init (&request_available_cv, NULL);

	printf("\tBFM: creating thread\n");
	rc = pthread_create(&thread, NULL, seq_main, NULL);
	if (rc != 0) {
		printf("\tERROR; return code from pthread_create() is %d\n", rc);
	}
	printf("\tBFM: thread created\n");
}




void seq_get_request(long long sim_time, unsigned char blocking,
		    /* OUTPUT */unsigned char *request_ready, 		 
		    /* OUTPUT */unsigned char *is_write, 
		    /* OUTPUT */svBitVecVal *addr, 
		    /* OUTPUT */svBitVecVal *data)
{
	/* printf("\tBFM: get_request called\n"); */

	current_sim_time = sim_time;
	
	*request_ready = 0;	/* default is no request */

	pthread_mutex_lock(&work_mutex);

	/* note, we don't block if the sequencer is done, as there will be
	 * no more requests generated
	 */
	while (!sequencer_done && blocking && request_pending == 0) {
		printf("\tBFM: Waiting for read/write request\n");
		pthread_cond_wait(&request_available_cv, &work_mutex);
	}

	if (request_pending) {
	  	*request_ready = 1; /* found a request */
		request_pending = 0;
	} else {
				
		/* printf("\tBFM: get_request no request\n"); */
		pthread_mutex_unlock(&work_mutex);
		return;
	}

	*is_write = request_is_write;
	*addr = request_addr;
	*data = request_write_val;

	pthread_mutex_unlock(&work_mutex);

	printf("\tBFM: get_request retn: is_write=%c addr=%x data=%x\n",
	       *is_write ? 'Y' : 'N', *addr, *data);
}

void
seq_send_response(long long sim_time, unsigned char is_write,
		  const svBitVecVal *addr, const svBitVecVal *data)
{
	printf("\tBFM: send_response called: is_write=%c addr=%x data=%x\n",
	       is_write ? 'Y' : 'N', addr, data);

	current_sim_time = sim_time;
	
	pthread_mutex_lock(&work_mutex);

	response_is_write = is_write;
	response_addr = *addr;
	response_read_val = *data;

	response_pending = 1;

	pthread_cond_signal(&response_available_cv);
	
	pthread_mutex_unlock(&work_mutex);
}

unsigned char
seq_done(long long sim_time)
{
	current_sim_time = sim_time;
	
	return (sequencer_done != 0);
}

/* This calls into SystemVerilog code to get simulation time ($time) */
long long
get_sim_time(void)
{
	return current_sim_time;
}
