// ********************************************************************************
// DisplayPort Core test code configuration
//
// All rights reserved. Property of Bitec.
// Restricted rights to use, duplicate or disclose this code are
// granted through contract.
//
// (C) Copyright Bitec 2012
//    All rights reserved
//
// Author         : $Author: dwang $ @ bitec-dsp.com
// Department     :
// Date           : $Date: 2013/09/05 $
// Revision       : $Revision: #1 $
// URL            : $URL: svn://10.8.0.1/share/svn/dp_sw/trunk/dp_demo/config.h $
//
// Description:
//
// ********************************************************************************

#define BITEC_AUX_DEBUG             1 // Set to 1 to enable AUX CH traffic monitoring
#define BITEC_STATUS_DEBUG          1 // Set to 1 to enable MSA and link status monitoring

#define BITEC_RX_GPUMODE            0 // Set to 1 to enable Sink GPU-mode

// RX Capabilities (for Sink GPU-mode)
#define BITEC_RX_CAPAB_MST          1 // Set to 1 to enable MST support
#define BITEC_FAST_LT_SUPPORT       1 // Set to 1 to enable Fast Linki Training support
#define BITEC_EDID_800X600_AUDIO    1 // Set to 1 to use an EDID with max resolution 800 x 600



