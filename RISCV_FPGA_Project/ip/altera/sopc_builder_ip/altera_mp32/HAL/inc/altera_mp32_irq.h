/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2009 Altera Corporation, San Jose, California, USA.           *
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
******************************************************************************/

/*
 * Support for the Mp32 internal interrupt controller in compatibility mode.
 */

#ifndef __ALT_MP32_IRQ_H_
#define __ALT_MP32_IRQ_H_

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/*
 * The macro ALTERA_MP32_IRQ_INSTANCE is used by the alt_irq_init()
 * function in the auto-generated file alt_sys_init.c to create an
 * instance of this interrupt controller device driver state if this
 * module contains an interrupt controller.
 * Only one instance of a MIPS32 is allowed so this macro is just empty.
 */

#define ALTERA_MP32_IRQ_INSTANCE(name, state)

/*
 * altera_mp32_irq_init() is called by the auto-generated function 
 * alt_irq_init() once for the Mp32 if it contains an interrupt controller.
 * The altera_mp32_irq_init() routine is called using the 
 * ALTERA_MP32_IRQ_INIT macro given below.
 */

extern void altera_mp32_irq_init( void );

/*
 * The macro ALTERA_MP32_IRQ_INIT is used by the alt_irq_init() routine
 * in the auto-generated file alt_sys_init.c to initialize an instance
 * of the interrupt controller device driver state.
 */

#define ALTERA_MP32_IRQ_INIT(name, state) altera_mp32_irq_init()

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ALT_MP32_IRQ_H_ */
