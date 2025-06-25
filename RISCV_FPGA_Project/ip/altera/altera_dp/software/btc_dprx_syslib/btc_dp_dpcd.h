// ********************************************************************************
// DisplayPort Sink/Source System Library DPCD location map
//
// All rights reserved. Property of Bitec.
// Restricted rights to use, duplicate or disclose this code are
// granted through contract.
//
// (C) Copyright Bitec 2012
//    All rights reserved
//
// Author         : $Author: jschleic $ @ bitec-dsp.com
// Department     :
// Date           : $Date: 2013/08/13 $
// Revision       : $Revision: #1 $
// URL            : $URL: svn://10.8.0.1/share/svn/dp_sw/trunk/btc_dprx_syslib/btc_dp_dpcd.h $
//
// Description:
//
// ********************************************************************************

#ifndef _BTC_DP_DPCD_INCLUDE
#define _BTC_DP_DPCD_INCLUDE

#define DPCP_ADDR_DPCD_REV                        0x0000
#define DPCP_ADDR_MAX_LINK_RATE                   0x0001
#define DPCP_ADDR_MAX_LANE_COUNT                  0x0002
#define DPCP_ADDR_MAX_DOWNSPREAD                  0x0003
#define DPCP_ADDR_NORP                            0x0004
#define DPCP_ADDR_DOWNSTREAMPORT_PRESENT          0x0005
#define DPCP_ADDR_MAIN_LINK_CHANNEL_CODING        0x0006
#define DPCP_ADDR_DOWN_STREAM_PORT_COUNT          0x0007
#define DPCP_ADDR_RECEIVE_PORT0_CAP_0             0x0008
#define DPCP_ADDR_RECEIVE_PORT0_CAP_1             0x0009
#define DPCP_ADDR_RECEIVE_PORT1_CAP_0             0x000A
#define DPCP_ADDR_RECEIVE_PORT1_CAP_1             0x000B
#define DPCP_ADDR_I2C_SPEED                       0x000C
#define DPCP_ADDR_EDP_CONFIGURATION_CAP           0x000D
#define DPCP_ADDR_TRAINING_AUX_RD_INTERVAL        0x000E
#define DPCP_ADDR_ADAPTER_CAP                     0x000F

#define DPCP_ADDR_FAUX_CAP                        0x0020
#define DPCP_ADDR_MST_CAP                         0x0021
#define DPCP_ADDR_N_OF_AUDIO_ENDPOINTS            0x0022

#define DPCP_ADDR_GUID                            0x0030

#define DPCP_ADDR_LINK_BW_SET                     0x0100
#define DPCP_ADDR_LANE_COUNT_SET                  0x0101
#define DPCP_ADDR_TRAINING_PATTERN_SET            0x0102
#define DPCP_ADDR_TRAINING_LANE0_SET              0x0103
#define DPCP_ADDR_TRAINING_LANE1_SET              0x0104
#define DPCP_ADDR_TRAINING_LANE2_SET              0x0105
#define DPCP_ADDR_TRAINING_LANE3_SET              0x0106
#define DPCP_ADDR_DOWNSPREAD_CTRL                 0x0107
#define DPCP_ADDR_MAIN_LINK_CHANNEL_CODING_SET    0x0108
#define DPCP_ADDR_I2C_SPEED1                      0x0109
#define DPCP_ADDR_EDP_CONFIGURATION_SET           0x010A
#define DPCP_ADDR_LINK_QUAL_LANE0_SET             0x010B
#define DPCP_ADDR_LINK_QUAL_LANE1_SET             0x010C
#define DPCP_ADDR_LINK_QUAL_LANE2_SET             0x010D
#define DPCP_ADDR_LINK_QUAL_LANE3_SET             0x010E
#define DPCP_ADDR_TRAINING_LANE0_1_SET2           0x010F
#define DPCP_ADDR_TRAINING_LANE2_3_SET2           0x0110
#define DPCP_ADDR_MSTM_CTRL                       0x0111
#define DPCP_ADDR_AUDIO_DELAY0                    0x0112
#define DPCP_ADDR_AUDIO_DELAY1                    0x0113
#define DPCP_ADDR_AUDIO_DELAY2                    0x0114

#define DPCP_ADDR_ADAPTER_CTRL                    0x01A0
#define DPCP_ADDR_BRANCH_DEVICE_CTRL              0x01A1

#define DPCP_ADDR_PAYLOAD_ALLOCATE_SET            0x01C0
#define DPCP_ADDR_PAYLOAD_ALLOCATE_START_TSLOT    0x01C1
#define DPCP_ADDR_PAYLOAD_ALLOCATE_TSLOT_COUNT    0x01C2

#define DPCP_ADDR_SINK_COUNT                      0x0200
#define DPCP_ADDR_DEVICE_SERVICE_IRQ_VECTOR       0x0201
#define DPCP_ADDR_LANE0_1_STATUS                  0x0202
#define DPCP_ADDR_LANE2_3_STATUS                  0x0203
#define DPCP_ADDR_LANE_ALIGN_STATUS_UPDATED       0x0204
#define DPCP_ADDR_SINK_STATUS                     0x0205
#define DPCP_ADDR_ADJUST_REQUEST_LANE0_1          0x0206
#define DPCP_ADDR_ADJUST_REQUEST_LANE2_3          0x0207

#define DPCP_ADDR_SYMBOL_ERROR_COUNT_LANE0_LS     0x0210
#define DPCP_ADDR_SYMBOL_ERROR_COUNT_LANE0_MS     0x0211
#define DPCP_ADDR_SYMBOL_ERROR_COUNT_LANE1_LS     0x0212
#define DPCP_ADDR_SYMBOL_ERROR_COUNT_LANE1_MS     0x0213
#define DPCP_ADDR_SYMBOL_ERROR_COUNT_LANE2_LS     0x0214
#define DPCP_ADDR_SYMBOL_ERROR_COUNT_LANE2_MS     0x0215
#define DPCP_ADDR_SYMBOL_ERROR_COUNT_LANE3_LS     0x0216
#define DPCP_ADDR_SYMBOL_ERROR_COUNT_LANE3_MS     0x0217

#define DPCP_ADDR_PAYLOAD_TABLE_UPDATE_STATUS     0x02C0
#define DPCP_ADDR_VC_PAYLOAD_ID_SLOT_1            0x02C1
#define DPCP_ADDR_VC_PAYLOAD_ID_SLOT_63           0x02FF

#define DPCP_ADDR_SOURCE_IEEE_OUI_0               0x0300

#define DPCP_ADDR_SINK_IEEE_OUI_0                 0x0400

#define DPCP_SINK_RESERVED_1                      0x040C

#define DPCP_ADDR_BRANCH_IEEE_OUI_0               0x0500

#define DPCP_BRANCH_RESERVED_1                    0x050C

#define DPCP_ADDR_SET_POWER_STATE                 0x0600

#define DPCP_ADDR_DOWN_REQ                        0x1000
#define DPCP_ADDR_DOWN_REP                        0x1400

#define DPCP_ADDR_SINK_COUNT_ESI                  0x2002
#define DPCP_ADDR_DEVICE_SERVICE_IRQ_VECTOR_ESI0  0x2003
#define DPCP_ADDR_DEVICE_SERVICE_IRQ_VECTOR_ESI1  0x2004
#define DPCP_ADDR_LINK_SERVICE_IRQ_VECTOR_ESI0    0x2005
#define DPCP_ADDR_LANE0_1_STATUS_ESI              0x200C
#define DPCP_ADDR_LANE2_3_STATUS_ESI              0x200D
#define DPCP_ADDR_LANE_ALIGN_STATUS_UPDATED_ESI   0x200E
#define DPCP_ADDR_SINK_STATUS_ESI                 0x200F

//------------ Locations not yet handled by Sink follow -----------------//

#define DPCP_ADDR_DWN_STRM_PORT0_CAP              0x0080

#define DPCP_ADDR_TRAINING_SCORE_LANE0            0x0208
#define DPCP_ADDR_TRAINING_SCORE_LANE1            0x0209
#define DPCP_ADDR_TRAINING_SCORE_LANE2            0x020A
#define DPCP_ADDR_TRAINING_SCORE_LANE3            0x020B
#define DPCP_ADDR_TEST_REQUEST                    0x0218
#define DPCP_ADDR_TEST_LINK_RATE                  0x0219
#define DPCP_ADDR_TEST_LANE_COUNT                 0x0220
#define DPCP_ADDR_TEST_PATTERN                    0x0221
#define DPCP_ADDR_TEST_H_TOTAL_LSB                0x0222
#define DPCP_ADDR_TEST_H_TOTAL_MSB                0x0223
#define DPCP_ADDR_TEST_V_TOTAL_LSB                0x0224
#define DPCP_ADDR_TEST_V_TOTAL_MSB                0x0225
#define DPCP_ADDR_TEST_H_START_LSB                0x0226
#define DPCP_ADDR_TEST_H_START_MSB                0x0227
#define DPCP_ADDR_TEST_V_START_LSB                0x0228
#define DPCP_ADDR_TEST_V_START_MSB                0x0229
#define DPCP_ADDR_TEST_HSYNC_LSB                  0x022A
#define DPCP_ADDR_TEST_HSYNC_MSB                  0x022B
#define DPCP_ADDR_TEST_VSYNC_LSB                  0x022C
#define DPCP_ADDR_TEST_VSYNC_MSB                  0x022D
#define DPCP_ADDR_TEST_H_WIDTH_LSB                0x022E
#define DPCP_ADDR_TEST_H_WIDTH_MSB                0x022F
#define DPCP_ADDR_TEST_V_HEIGHT_LSB               0x0230
#define DPCP_ADDR_TEST_V_HEIGHT_MSB               0x0231
#define DPCP_ADDR_TEST_MISC_LSB                   0x0232
#define DPCP_ADDR_TEST_MISC_MSB                   0x0233
#define DPCP_ADDR_TEST_REFRESH_RATE_NUMERATOR     0x0234
#define DPCP_ADDR_TEST_CRC_R_CR_LSB               0x0240
#define DPCP_ADDR_TEST_CRC_R_CR_MSB               0x0241
#define DPCP_ADDR_TEST_CRC_G_Y_LSB                0x0242
#define DPCP_ADDR_TEST_CRC_G_Y_MSB                0x0243
#define DPCP_ADDR_TEST_CRC_B_CB_LSB               0x0244
#define DPCP_ADDR_TEST_CRC_B_CB_MSB               0x0245
#define DPCP_ADDR_TEST_SINK_MISC                  0x0246
#define DPCP_ADDR_PHY_TEST_PATTERN                0x0248
#define DPCP_ADDR_TEST_RESPONSE                   0x0260
#define DPCP_ADDR_TEST_EDID_CHECKSUM              0x0261
#define DPCP_ADDR_TEST_SINK                       0x0270

#endif //#ifndef _BTC_DP_DPCD_INCLUDE
