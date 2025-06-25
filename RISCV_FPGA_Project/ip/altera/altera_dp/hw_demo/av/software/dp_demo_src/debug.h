// ********************************************************************************
// DisplayPort Core test code debug routines definitions
//
// All rights reserved. Property of Bitec.
// Restricted rights to use, duplicate or disclose this code are
// granted through contract.
//
// (C) Copyright Bitec 2012
//    All rights reserved
//
// Author         : $Author: swbranch $ @ bitec-dsp.com
// Department     :
// Date           : $Date: 2013/08/11 $
// Revision       : $Revision: #1 $
// URL            : $URL: svn://10.8.0.1/share/svn/dp_sw/trunk/dp_demo/debug.h $
//
// Description:
//
// ********************************************************************************

void bitec_dp_dump_aux_debug_init(unsigned int base_addr_csr);
void bitec_dp_dump_aux_debug(unsigned int base_addr_csr, unsigned int base_addr_fifo, unsigned int is_sink);
void bitec_dp_dump_sink_msa(unsigned int base_addr);
void bitec_dp_dump_source_msa(unsigned int base_addr);
void bitec_dp_dump_sink_config(unsigned int base_addr);
void bitec_dp_dump_source_config(unsigned int base_addr);


