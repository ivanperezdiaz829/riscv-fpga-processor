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
* altera_avalon_mailbox.h                                                     *
*                                                                             *
* Public interfaces to the Software Mailbox component                         *
*                                                                             *
******************************************************************************/
#ifndef __ALTERA_AVALON_MAILBOX_H__
#define __ALTERA_AVALON_MAILBOX_H__
#include "priv/alt_dev_llist.h"
#include "sys/alt_dev.h"
#include "os/alt_sem.h"
#include "altera_avalon_mutex.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/*
 * The function alt_find_dev() is used to search the device list "list" to
 * locate a device named "name". If a match is found, then a pointer to the
 * device is returned, otherwise NULL is returned.
 */

/*extern alt_dev* alt_find_dev (const char* name, alt_llist* list);*/

/*
 * Mailbox Device Structure
 */
typedef struct alt_mailbox_dev
{
  alt_llist           llist;
  const char*         name;
  alt_u32*volatile *  write_ptr;
  alt_u32*volatile *  read_ptr;
  alt_u32*            mailbox_mem_start_ptr;
  alt_u32*            mailbox_mem_end_ptr;
  alt_mutex_dev       write_mutex;
  alt_mutex_dev       read_mutex;
} alt_mailbox_dev;

/*
 * Prototypes
 */
alt_mailbox_dev* altera_avalon_mailbox_open (const char* name);
void altera_avalon_mailbox_close (alt_mailbox_dev* dev);
int altera_avalon_mailbox_post (alt_mailbox_dev* dev, alt_u32 msg);
alt_u32 altera_avalon_mailbox_pend (alt_mailbox_dev* dev);
alt_u32 altera_avalon_mailbox_get (alt_mailbox_dev* dev, int* err);
int alt_avalon_mailbox_init (alt_mailbox_dev* dev);

/*
*   Macros used by alt_sys_init.c
*
*/
#define ALTERA_AVALON_MAILBOX_INSTANCE(name, dev)                       \
static alt_mailbox_dev dev =                                            \
{                                                                       \
  ALT_LLIST_ENTRY,                                                      \
  name##_NAME,                                                          \
  ((alt_u32**)(name##_MAILBOX_MEMORY_ADDR)),                    \
  ((alt_u32**)(name##_MAILBOX_MEMORY_ADDR)) + 1,                \
  ((alt_u32*)name##_MAILBOX_MEMORY_ADDR) + 2,                   \
  (alt_u32*)(name##_MAILBOX_MEMORY_ADDR + 						\
  		name##_MAILBOX_MEMORY_SIZE - 4),						\
  {                                                                     \
    ALT_LLIST_ENTRY,                                                    \
    name##_NAME "_mutex_0",                                             \
    ((void*)( name##_BASE))                                             \
  },                                                                    \
  {                                                                     \
    ALT_LLIST_ENTRY,                                                    \
    name##_NAME "_mutex_1",                                             \
    (((void*)( name##_BASE))+8)                                         \
  },                                                                    \
};                                                                      \

#define ALTERA_AVALON_MAILBOX_INIT(name, dev) \
  alt_avalon_mailbox_init(&dev) 

#ifdef __cplusplus
}
#endif

#endif /* __ALTERA_AVALON_MAILBOX_H__ */
