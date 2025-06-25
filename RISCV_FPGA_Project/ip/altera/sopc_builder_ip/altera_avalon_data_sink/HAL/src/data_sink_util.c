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

#include "data_sink_util.h"
#include "data_sink_regs.h"

/*************************
 * Private Utility Functions
 *************************/
int data_sink_io_rd(alt_u32 base, alt_u32 address, alt_u32 mask, alt_u32 rightbit) {
    return (IORD(base, address) & mask) >> rightbit;
}

int data_sink_io_wr(alt_u32 base, alt_u32 address, alt_u32 value) {
    IOWR(base, address, value);
    return value;
}

int data_sink_io_rmw(alt_u32 base, alt_u32 address, alt_u32 value, alt_u32 mask, alt_u32 rightbit)
{
    alt_u32 rd = IORD(base, address) & ~mask;
    alt_u32 wr  = ((value << rightbit) & mask) | rd;
    IOWR(base, address, wr);
    return wr;
}

/*************************
 * Reset & Configuration
 *************************/
 
void data_sink_reset(alt_u32 base) {
    data_sink_io_rmw(base, DATA_SINK_CONTROL_REG, 1, DATA_SINK_RESET_MSK, DATA_SINK_RESET_RT);
    data_sink_io_rmw(base, DATA_SINK_CONTROL_REG, 0, DATA_SINK_RESET_MSK, DATA_SINK_RESET_RT);
}

int data_sink_init(alt_u32 base) {
    int x = data_sink_get_id(base); 
    if (x != DATA_SINK_ID)
      return 0;

    data_sink_reset(base);

    data_sink_set_enable(base, 0);
    if (data_sink_get_enable(base) != 0) {
       return 0;
    }

    data_sink_set_throttle(base, 256);
    if (data_sink_get_throttle(base) != 256) {
       return 0;
    }

    return 1;
}

int data_sink_get_id(alt_u32 base) {
    return data_sink_io_rd(base, DATA_SINK_STATUS_REG, DATA_SINK_ID_MSK, DATA_SINK_ID_RT);
}

int data_sink_get_supports_packets(alt_u32 base) {
    return data_sink_io_rd(base, DATA_SINK_STATUS_REG, DATA_SINK_SUPPORTPACKETS_MSK, DATA_SINK_SUPPORTPACKETS_RT);
}

int data_sink_get_num_channels(alt_u32 base) {
    return data_sink_io_rd(base, DATA_SINK_STATUS_REG, DATA_SINK_NUMCHANNELS_MSK, DATA_SINK_NUMCHANNELS_RT);
}

int data_sink_get_symbols_per_cycle(alt_u32 base) {
    return data_sink_io_rd(base, DATA_SINK_STATUS_REG, DATA_SINK_NUMSYMBOLS_MSK, DATA_SINK_NUMSYMBOLS_RT);
}


int data_sink_get_enable(alt_u32 base) {
    return data_sink_io_rd(base, DATA_SINK_CONTROL_REG, DATA_SINK_ENABLE_MSK, DATA_SINK_ENABLE_RT);
}

void data_sink_set_enable(alt_u32 base, alt_u32 value){
    data_sink_io_rmw(base, DATA_SINK_CONTROL_REG, value, DATA_SINK_ENABLE_MSK, DATA_SINK_ENABLE_RT);
}

int data_sink_get_throttle(alt_u32 base) {
    return data_sink_io_rd(base, DATA_SINK_CONTROL_REG, DATA_SINK_THROTTLE_MSK, DATA_SINK_THROTTLE_RT);
}

void data_sink_set_throttle(alt_u32 base, alt_u32 value) {
    data_sink_io_rmw(base, DATA_SINK_CONTROL_REG, value, DATA_SINK_THROTTLE_MSK, DATA_SINK_THROTTLE_RT);
}

/*************************
 * Operational
 *************************/

int data_sink_get_packet_count(alt_u32 base, alt_u32 channel) {
    data_sink_io_rmw(base, DATA_SINK_INDIRECT_SELECT_REG, channel, DATA_SINK_IND_CHANNEL_MSK, DATA_SINK_IND_CHANNEL_RT);
    return data_sink_io_rd(base, DATA_SINK_INDIRECT_COUNT_REG, DATA_SINK_IND_PACKET_MSK, DATA_SINK_IND_PACKET_RT);
}

int data_sink_get_symbol_count(alt_u32 base, alt_u32 channel) {
    data_sink_io_rmw(base, DATA_SINK_INDIRECT_SELECT_REG, channel, DATA_SINK_IND_CHANNEL_MSK, DATA_SINK_IND_CHANNEL_RT);
    return data_sink_io_rd(base, DATA_SINK_INDIRECT_COUNT_REG, DATA_SINK_IND_SYMBOL_MSK, DATA_SINK_IND_SYMBOL_RT);
}

int data_sink_get_error_count(alt_u32 base, alt_u32 channel) {
    data_sink_io_rmw(base, DATA_SINK_INDIRECT_SELECT_REG, channel, DATA_SINK_IND_CHANNEL_MSK, DATA_SINK_IND_CHANNEL_RT);
    return data_sink_io_rd(base, DATA_SINK_INDIRECT_SELECT_REG, DATA_SINK_IND_ERROR_MSK, DATA_SINK_IND_ERROR_RT);
}   

int data_sink_get_exception(alt_u32 base) {
    return     IORD(base, DATA_SINK_EXCEPTION_REG);
}

/*************************
 * Utility
 *************************/
 
int data_sink_exception_is_exception(int exception) {
    return (exception != 0);
}

int data_sink_exception_has_data_error(int exception){
    return ((exception & DATA_SINK_EXC_DATAERROR_MSK) != 0);
}

int data_sink_exception_has_missing_sop(int exception){
    return ((exception & DATA_SINK_EXC_MISSINGSOP_MSK) != 0);
}

int data_sink_exception_has_missing_eop(int exception){
    return ((exception & DATA_SINK_EXC_MISSINGEOP_MSK) != 0);
}

int data_sink_exception_signalled_error(int exception){
    return ((exception & DATA_SINK_EXC_SIGERROR_MSK) >> DATA_SINK_EXC_SIGERROR_RT);
}

int data_sink_exception_channel(int exception){
    return ((exception & DATA_SINK_EXC_CHANNEL_MSK) >> DATA_SINK_EXC_CHANNEL_RT);
}

