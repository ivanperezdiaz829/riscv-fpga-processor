/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2005 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
* altera_avalon_mailbox.c                                                     *
*                                                                             *
* API for manipulating the software mailbox associated with the mailbox       *
* component                                                                   *
*                                                                             *
*****************************************************************************/
#include <stddef.h>
#include <errno.h>
#include "nios2.h"
#include "alt_types.h"
#include "sys/alt_errno.h"
#include "priv/alt_file.h"
#include "altera_avalon_mailbox.h"
#include "altera_avalon_mailbox_regs.h"
#include "io.h"

/*
 * The list of registered mutex components.
 */

ALT_LLIST_HEAD(alt_mailbox_list);

/*
 * Register a Mutex device
 */
int alt_avalon_mailbox_init (alt_mailbox_dev* dev)
{
  int ret_code;
  alt_mutex_dev* write_mutex, *read_mutex;
  extern alt_llist alt_mailbox_list;

  ret_code = alt_avalon_mutex_reg( &dev->write_mutex );

  if (!ret_code)
  {
    ret_code = alt_avalon_mutex_reg( &dev->read_mutex );
  }

  if (!ret_code)
  {
    ret_code = alt_dev_llist_insert((alt_dev_llist*) dev, &alt_mailbox_list);
  }

  if (!ret_code)
  {
    write_mutex = altera_avalon_mutex_open(dev->write_mutex.name);
    if (write_mutex)
    {
      read_mutex = altera_avalon_mutex_open(dev->read_mutex.name);
      if (read_mutex)
      {
        while (altera_avalon_mutex_first_lock(write_mutex))
        {
          if (!altera_avalon_mutex_trylock(write_mutex, 1))
          {
            IOWR((alt_u32)(dev->write_ptr), 0,
              (alt_u32) dev->mailbox_mem_start_ptr);
            altera_avalon_mutex_unlock(write_mutex);
          }
        }

        while (altera_avalon_mutex_first_lock(read_mutex))
        {
          if (!altera_avalon_mutex_trylock(read_mutex, 1))
          {
            IOWR((alt_u32)(dev->read_ptr), 0,
              (alt_u32) dev->mailbox_mem_start_ptr);
            altera_avalon_mutex_unlock(read_mutex);
          }
        }
      }
    }
  }
  return ret_code;
}


/*
 * altera_avalon_mailbox_open - Retrieve a pointer to the hardware mailbox
 *
 * Search the list of registered mailboxes for one with the supplied name.
 *
 * The return value will be NULL on failure, and non-NULL otherwise.
 */
alt_mailbox_dev* altera_avalon_mailbox_open (const char* name)
{
  alt_mailbox_dev* dev;

  dev = (alt_mailbox_dev*) alt_find_dev (name, &alt_mailbox_list);

  if (NULL == dev)
  {
    ALT_ERRNO = ENODEV;
  }

  return dev;

}

/*
 * altera_avalon_mailbox_close - Does nothing at the moment, but included for 
 * completeness
 *
 */
void altera_avalon_mailbox_close (alt_mailbox_dev* dev)
{
  return;
}

/*
 * alt_mailbox_increment_ptr
 *
 * Increment one of the pointers and if that would take it beyond the end
 * of the shared memory put it at the start
 */
static inline alt_u32* alt_mailbox_increment_ptr(alt_mailbox_dev* dev, alt_u32* ptr)
{
  ptr += 1;

  if (ptr > dev->mailbox_mem_end_ptr)
  {
    ptr = dev->mailbox_mem_start_ptr;
  }

  return ptr;
}

/*
 * altera_avalon_mailbox_post 
 * 
 * Post a message to the mailbox
 *
 */
int altera_avalon_mailbox_post (alt_mailbox_dev* dev, alt_u32 msg)
{
  int ret_code = 0;
  alt_u32* temp;
  alt_u32* next_write;

  /*
  *   Claim the Mutex on the write pointer 
  *
  *   The mutex function takes care of the thread sempahore if running
  *   in a multi-threaded environment
  */
  altera_avalon_mutex_lock( &dev->write_mutex, 1 );

  temp = (alt_u32 *) IORD(dev->write_ptr, 0);
  next_write = alt_mailbox_increment_ptr(dev, temp);

  if (next_write == ((alt_u32 *)IORD(dev->read_ptr, 0)) )
  {
    ALT_ERRNO = EWOULDBLOCK;
    ret_code = -EWOULDBLOCK;
  }
  else
  {
    IOWR(temp, 0, msg);
    IOWR((alt_u32)(dev->write_ptr), 0, (alt_u32)next_write);
  }

  altera_avalon_mutex_unlock( &dev->write_mutex );

  return ret_code;

}

/*
 * altera_avalon_mailbox_pend 
 * 
 * Block until a message is available in the mailbox
 *
 */
alt_u32 altera_avalon_mailbox_pend (alt_mailbox_dev* dev)
{
  alt_u32 msg;
  alt_u32* temp;

  /*
  *   Claim the Mutex on the read pointer
  *
  *   The mutex function takes care of the thread sempahore if running
  *   in a multi-threaded environment
  */
  altera_avalon_mutex_lock( &dev->read_mutex, 1 );

  temp = (alt_u32 *)IORD(dev->read_ptr, 0);

  while ( (alt_u32 *)(IORD(dev->write_ptr, 0)) == temp );

  msg = IORD(temp, 0);

  IOWR( (alt_u32)(dev->read_ptr), 0,
    (alt_u32)(alt_mailbox_increment_ptr(dev, temp)) );

  altera_avalon_mutex_unlock( &dev->read_mutex );

  return msg;

}

/*
 * altera_avalon_mailbox_get
 * 
 * If a message is available in the mailbox return it otherwise return NULL
 * i.e. this is Non-Blocking
 *
 */
alt_u32 altera_avalon_mailbox_get (alt_mailbox_dev* dev, int* err)
{
  alt_u32 msg;
  alt_u32* temp;
  *err = 0;

  /*
  *   Claim the Mutex on the read pointer 
  *
  *   The mutex function takes care of the thread sempahore if running
  *   in a multi-threaded environment
  */
  altera_avalon_mutex_lock( &dev->read_mutex, 1 );

  temp = (alt_u32 *)IORD(dev->read_ptr, 0);

  if ( (alt_u32 *)(IORD(dev->write_ptr, 0)) == temp )
  {
    *err = -EWOULDBLOCK;
    ALT_ERRNO = EWOULDBLOCK;
    msg = 0;
  }
  else
  {
    msg = IORD(temp, 0);
    IOWR(dev->read_ptr, 0,
      (alt_u32)(alt_mailbox_increment_ptr(dev, temp)) );
  }

  altera_avalon_mutex_unlock( &dev->read_mutex );

  return msg;

}



