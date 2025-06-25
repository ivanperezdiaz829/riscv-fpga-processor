/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
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

#ifndef __DATA_SINK_UTIL_H__
#define __DATA_SINK_UTIL_H__

#include "data_sink_regs.h"

#define DATA_SINK_ID                101

/****************************************************  
 * Public API                                       *
 ****************************************************/

/*************************
 * Reset & Configuration
 *************************/
 
// Reset the data source, including all internal counters.
void data_sink_reset(alt_u32 base);

// Initialize the Data Source
int data_sink_init(alt_u32 base);

// Get the Data Source ID
int data_sink_get_id(alt_u32 base);

// Returns 1 if the data source supports packets.
int data_sink_get_supports_packets(alt_u32 base);

// Returns the number of channels the data source supports.
int data_sink_get_num_channels(alt_u32 base);

// Returns the number of symbols per cycles that the data source supports.
int data_sink_get_symbols_per_cycle(alt_u32 base);

// Get & set the enable bit.  When not enabled, the data 
// sink will not send data, regardless of the commands.
int data_sink_get_enable(alt_u32 base);
void data_sink_set_enable(alt_u32 base, alt_u32 value);

// Get & set the throttle.  Throttle is an integer between 
// 0 and 256, inclusively, where the data sink sends at 
// a rate of throttle/256.  
void data_sink_set_throttle(alt_u32 base, alt_u32 value);
int data_sink_get_throttle(alt_u32 base);

/*************************
 * Operational
 *************************/

// Return the count of packets for the given channel
int data_sink_get_packet_count(alt_u32 base, alt_u32 channel);

// Return the count of symbols for the given channel
int data_sink_get_symbol_count(alt_u32 base, alt_u32 channel);

// Return the count of errors for the given channel
int data_sink_get_error_count(alt_u32 base, alt_u32 channel);

// Get the execption from the head of the exception queue, returns
// 0 if there's no exception.
int data_sink_get_exception(alt_u32 base);

/*************************
 * Utility
 *************************/
 
// Returns '1' if there's any exception at all.
int data_sink_exception_is_exception(int exception);

// Returns '1' if there's a data error.
int data_sink_exception_has_data_error(int exception);

// Returns '1' if there was a missing SOP error
int data_sink_exception_has_missing_sop(int exception);

// Returns '1' if there was a missing EOP error
int data_sink_exception_has_missing_eop(int exception);

// Returns the signalled error
int data_sink_exception_signalled_error(int exception);

// Returns the channel the exception was on
int data_sink_exception_channel(int exception);

#endif /* __DATA_SINK_UTIL_H__ */
