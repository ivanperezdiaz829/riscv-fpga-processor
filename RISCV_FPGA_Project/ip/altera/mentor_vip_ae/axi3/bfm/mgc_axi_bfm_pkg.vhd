-- *****************************************************************************
--
-- Copyright 2007-2013 Mentor Graphics Corporation
-- All Rights Reserved.
--
-- THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF
-- MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--
-- *****************************************************************************
-- dvc           Version: 20130911_Questa_10.2c
-- *****************************************************************************

-- Title: mgc_axi_bfm_pkg
--
-- This package contains the user APIs.
--
-- For multiple BFMs there can be an array of bus_if records, with the
-- appropriate array member being passed to the read or write procedure

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.all;
package mgc_axi_bfm_pkg is

    -- axi_size_e
    --------------------------------------------------------------------------------
    --  Word size encoding 
    --------------------------------------------------------------------------------
    constant AXI_BYTES_1   : integer := 0;
    constant AXI_BYTES_2   : integer := 1;
    constant AXI_BYTES_4   : integer := 2;
    constant AXI_BYTES_8   : integer := 3;
    constant AXI_BYTES_16  : integer := 4;
    constant AXI_BYTES_32  : integer := 5;
    constant AXI_BYTES_64  : integer := 6;
    constant AXI_BYTES_128 : integer := 7;

    -- axi_prot_e
    --------------------------------------------------------------------------------
    --  Protection type 
    --------------------------------------------------------------------------------
    constant AXI_NORM_SEC_DATA    : integer := 0;
    constant AXI_PRIV_SEC_DATA    : integer := 1;
    constant AXI_NORM_NONSEC_DATA : integer := 2;
    constant AXI_PRIV_NONSEC_DATA : integer := 3;
    constant AXI_NORM_SEC_INST    : integer := 4;
    constant AXI_PRIV_SEC_INST    : integer := 5;
    constant AXI_NORM_NONSEC_INST : integer := 6;
    constant AXI_PRIV_NONSEC_INST : integer := 7;

    -- axi_cache_e
    --------------------------------------------------------------------------------
    --  Cache type
    --------------------------------------------------------------------------------
    constant AXI_NONCACHE_NONBUF             : integer := 0;
    constant AXI_BUF_ONLY                    : integer := 1;
    constant AXI_CACHE_NOALLOC               : integer := 2;
    constant AXI_CACHE_BUF_NOALLOC           : integer := 3;
    constant AXI_CACHE_RSVD0                 : integer := 4;
    constant AXI_CACHE_RSVD1                 : integer := 5;
    constant AXI_CACHE_WTHROUGH_ALLOC_R_ONLY : integer := 6;
    constant AXI_CACHE_WBACK_ALLOC_R_ONLY    : integer := 7;
    constant AXI_CACHE_RSVD2                 : integer := 8;
    constant AXI_CACHE_RSVD3                 : integer := 9;
    constant AXI_CACHE_WTHROUGH_ALLOC_W_ONLY : integer := 10;
    constant AXI_CACHE_WBACK_ALLOC_W_ONLY    : integer := 11;
    constant AXI_CACHE_RSVD4                 : integer := 12;
    constant AXI_CACHE_RSVD5                 : integer := 13;
    constant AXI_CACHE_WTHROUGH_ALLOC_RW     : integer := 14;
    constant AXI_CACHE_WBACK_ALLOC_RW        : integer := 15;

    -- axi_burst_e
    --------------------------------------------------------------------------------
    --  Burst type - determines address calculation
    --------------------------------------------------------------------------------
    constant AXI_FIXED      : integer := 0;
    constant AXI_INCR       : integer := 1;
    constant AXI_WRAP       : integer := 2;
    constant AXI_BURST_RSVD : integer := 3;

    -- axi_response_e
    --------------------------------------------------------------------------------
    --  Response type 
    --------------------------------------------------------------------------------
    constant AXI_OKAY   : integer := 0;
    constant AXI_EXOKAY : integer := 1;
    constant AXI_SLVERR : integer := 2;
    constant AXI_DECERR : integer := 3;

    -- axi_lock_e
    --------------------------------------------------------------------------------
    --  Lock type for atomic accesses
    --------------------------------------------------------------------------------
    constant AXI_NORMAL    : integer := 0;
    constant AXI_EXCLUSIVE : integer := 1;
    constant AXI_LOCKED    : integer := 2;
    constant AXI_LOCK_RSVD : integer := 3;

    -- axi_abstraction_level_e
    --------------------------------------------------------------------------------
    --  Abstraction level control
    --------------------------------------------------------------------------------
    constant AXI_PV       : integer := 0;
    constant AXI_PVT      : integer := 1;
    constant AXI_CC_BURST : integer := 2;
    constant AXI_CC_PHASE : integer := 3;
    constant AXI_CA       : integer := 4;

    -- axi_rw_e
    constant AXI_TRANS_READ  : integer := 0;
    constant AXI_TRANS_WRITE : integer := 1;

    -- axi_error_e
    constant AXI_AWBURST_RSVD        : integer := 0;
    constant AXI_ARBURST_RSVD        : integer := 1;
    constant AXI_AWSIZE_GT_BUS_WIDTH : integer := 2;
    constant AXI_ARSIZE_GT_BUS_WIDTH : integer := 3;
    constant AXI_AWLOCK_RSVD         : integer := 4;
    constant AXI_ARLOCK_RSVD         : integer := 5;
    constant AXI_AWLEN_LAST_MISMATCH : integer := 6;
    constant AXI_AWID_WID_MISMATCH   : integer := 7;
    constant AXI_WSTRB_ILLEGAL       : integer := 8;
    constant AXI_AWCACHE_RSVD        : integer := 9;
    constant AXI_ARCACHE_RSVD        : integer := 10;

    -- axi_assertion_type_e
    --------------------------------------------------------------------------------
    --  Type defining the error messages which can be produced by the <mgc_axi> MVC.
    -- 
    -- Individual error messages can be disabled using the <IF::config_enable_error> array of configuration bits.
    -- 
    --------------------------------------------------------------------------------
    constant AXI_ARESETN_SIGNAL_Z                                                        : integer := 0;
    constant AXI_ARESETN_SIGNAL_X                                                        : integer := 1;
    constant AXI_ACLK_SIGNAL_Z                                                           : integer := 2;
    constant AXI_ACLK_SIGNAL_X                                                           : integer := 3;
    constant AXI_ADDR_FOR_READ_BURST_ACROSS_4K_BOUNDARY                                  : integer := 4;
    constant AXI_ADDR_FOR_WRITE_BURST_ACROSS_4K_BOUNDARY                                 : integer := 5;
    constant AXI_ARADDR_CHANGED_BEFORE_ARREADY                                           : integer := 6;
    constant AXI_ARADDR_UNKN                                                             : integer := 7;
    constant AXI_ARBURST_CHANGED_BEFORE_ARREADY                                          : integer := 8;
    constant AXI_ARBURST_UNKN                                                            : integer := 9;
    constant AXI_ARCACHE_CHANGED_BEFORE_ARREADY                                          : integer := 10;
    constant AXI_ARCACHE_UNKN                                                            : integer := 11;
    constant AXI_ARID_CHANGED_BEFORE_ARREADY                                             : integer := 12;
    constant AXI_ARID_UNKN                                                               : integer := 13;
    constant AXI_ARLEN_CHANGED_BEFORE_ARREADY                                            : integer := 14;
    constant AXI_ARLEN_UNKN                                                              : integer := 15;
    constant AXI_ARLOCK_CHANGED_BEFORE_ARREADY                                           : integer := 16;
    constant AXI_ARLOCK_UNKN                                                             : integer := 17;
    constant AXI_ARPROT_CHANGED_BEFORE_ARREADY                                           : integer := 18;
    constant AXI_ARPROT_UNKN                                                             : integer := 19;
    constant AXI_ARREADY_UNKN                                                            : integer := 20;
    constant AXI_ARSIZE_CHANGED_BEFORE_ARREADY                                           : integer := 21;
    constant AXI_ARSIZE_UNKN                                                             : integer := 22;
    constant AXI_ARUSER_CHANGED_BEFORE_ARREADY                                           : integer := 23;
    constant AXI_ARUSER_UNKN                                                             : integer := 24;
    constant AXI_ARVALID_DEASSERTED_BEFORE_ARREADY                                       : integer := 25;
    constant AXI_ARVALID_HIGH_ON_FIRST_CLOCK_AFTER_RESET                                 : integer := 26;
    constant AXI_ARVALID_UNKN                                                            : integer := 27;
    constant AXI_AWADDR_CHANGED_BEFORE_AWREADY                                           : integer := 28;
    constant AXI_AWADDR_UNKN                                                             : integer := 29;
    constant AXI_AWBURST_CHANGED_BEFORE_AWREADY                                          : integer := 30;
    constant AXI_AWBURST_UNKN                                                            : integer := 31;
    constant AXI_AWCACHE_CHANGED_BEFORE_AWREADY                                          : integer := 32;
    constant AXI_AWCACHE_UNKN                                                            : integer := 33;
    constant AXI_AWID_CHANGED_BEFORE_AWREADY                                             : integer := 34;
    constant AXI_AWID_UNKN                                                               : integer := 35;
    constant AXI_AWLEN_CHANGED_BEFORE_AWREADY                                            : integer := 36;
    constant AXI_AWLEN_UNKN                                                              : integer := 37;
    constant AXI_AWLOCK_CHANGED_BEFORE_AWREADY                                           : integer := 38;
    constant AXI_AWLOCK_UNKN                                                             : integer := 39;
    constant AXI_AWPROT_CHANGED_BEFORE_AWREADY                                           : integer := 40;
    constant AXI_AWPROT_UNKN                                                             : integer := 41;
    constant AXI_AWREADY_UNKN                                                            : integer := 42;
    constant AXI_AWSIZE_CHANGED_BEFORE_AWREADY                                           : integer := 43;
    constant AXI_AWSIZE_UNKN                                                             : integer := 44;
    constant AXI_AWUSER_CHANGED_BEFORE_AWREADY                                           : integer := 45;
    constant AXI_AWUSER_UNKN                                                             : integer := 46;
    constant AXI_AWVALID_DEASSERTED_BEFORE_AWREADY                                       : integer := 47;
    constant AXI_AWVALID_HIGH_ON_FIRST_CLOCK_AFTER_RESET                                 : integer := 48;
    constant AXI_AWVALID_UNKN                                                            : integer := 49;
    constant AXI_BID_CHANGED_BEFORE_BREADY                                               : integer := 50;
    constant AXI_BID_UNKN                                                                : integer := 51;
    constant AXI_BREADY_UNKN                                                             : integer := 52;
    constant AXI_BRESP_CHANGED_BEFORE_BREADY                                             : integer := 53;
    constant AXI_BRESP_UNKN                                                              : integer := 54;
    constant AXI_BUSER_CHANGED_BEFORE_BREADY                                             : integer := 55;
    constant AXI_BUSER_UNKN                                                              : integer := 56;
    constant AXI_BVALID_DEASSERTED_BEFORE_BREADY                                         : integer := 57;
    constant AXI_BVALID_HIGH_ON_FIRST_CLOCK_AFTER_RESET                                  : integer := 58;
    constant AXI_BVALID_UNKN                                                             : integer := 59;
    constant AXI_EXCLUSIVE_READ_ACCESS_MODIFIABLE                                        : integer := 60;
    constant AXI_EXCLUSIVE_READ_BYTES_TRANSFER_EXCEEDS_128                               : integer := 61;
    constant AXI_EXCLUSIVE_WRITE_BYTES_TRANSFER_EXCEEDS_128                              : integer := 62;
    constant AXI_EXCLUSIVE_READ_BYTES_TRANSFER_NOT_POWER_OF_2                            : integer := 63;
    constant AXI_EXCLUSIVE_WRITE_BYTES_TRANSFER_NOT_POWER_OF_2                           : integer := 64;
    constant AXI_EXCLUSIVE_WR_ADDRESS_NOT_SAME_AS_RD                                     : integer := 65;
    constant AXI_EXCLUSIVE_WR_BURST_NOT_SAME_AS_RD                                       : integer := 66;
    constant AXI_EXCLUSIVE_WR_CACHE_NOT_SAME_AS_RD                                       : integer := 67;
    constant AXI_EXCLUSIVE_WRITE_ACCESS_MODIFIABLE                                       : integer := 68;
    constant AXI_EXCLUSIVE_WR_LENGTH_NOT_SAME_AS_RD                                      : integer := 69;
    constant AXI_EXCLUSIVE_WR_PROT_NOT_SAME_AS_RD                                        : integer := 70;
    constant AXI_EXCLUSIVE_WR_SIZE_NOT_SAME_AS_RD                                        : integer := 71;
    constant AXI_EXOKAY_RESPONSE_NORMAL_READ                                             : integer := 72;
    constant AXI_EXOKAY_RESPONSE_NORMAL_WRITE                                            : integer := 73;
    constant AXI_EX_RD_RESP_MISMATCHED_WITH_EXPECTED_RESP                                : integer := 74;
    constant AXI_EX_WR_RESP_MISMATCHED_WITH_EXPECTED_RESP                                : integer := 75;
    constant AXI_EX_RD_EXOKAY_RESP_SLAVE_WITHOUT_EXCLUSIVE_ACCESS                        : integer := 76;
    constant AXI_EX_WRITE_BEFORE_EX_READ_RESPONSE                                        : integer := 77;
    constant AXI_EX_WRITE_EXOKAY_RESP_SLAVE_WITHOUT_EXCLUSIVE_ACCESS                     : integer := 78;
    constant AXI_ILLEGAL_LENGTH_WRAPPING_READ_BURST                                      : integer := 79;
    constant AXI_ILLEGAL_LENGTH_WRAPPING_WRITE_BURST                                     : integer := 80;
    constant AXI_ILLEGAL_RESPONSE_EXCLUSIVE_READ                                         : integer := 81;
    constant AXI_ILLEGAL_RESPONSE_EXCLUSIVE_WRITE                                        : integer := 82;
    constant AXI_PARAM_READ_DATA_BUS_WIDTH                                               : integer := 83;
    constant AXI_PARAM_WRITE_DATA_BUS_WIDTH                                              : integer := 84;
    constant AXI_READ_ALLOCATE_WHEN_NON_MODIFIABLE_12                                    : integer := 85;
    constant AXI_READ_ALLOCATE_WHEN_NON_MODIFIABLE_13                                    : integer := 86;
    constant AXI_READ_ALLOCATE_WHEN_NON_MODIFIABLE_4                                     : integer := 87;
    constant AXI_READ_ALLOCATE_WHEN_NON_MODIFIABLE_5                                     : integer := 88;
    constant AXI_READ_ALLOCATE_WHEN_NON_MODIFIABLE_8                                     : integer := 89;
    constant AXI_READ_ALLOCATE_WHEN_NON_MODIFIABLE_9                                     : integer := 90;
    constant AXI_READ_BURST_LENGTH_VIOLATION                                             : integer := 91;
    constant AXI_READ_BURST_SIZE_VIOLATION                                               : integer := 92;
    constant AXI_READ_DATA_BEFORE_ADDRESS                                                : integer := 93;
    constant AXI_READ_DATA_CHANGED_BEFORE_RREADY                                         : integer := 94;
    constant AXI_READ_DATA_UNKN                                                          : integer := 95;
    constant AXI_RESERVED_ARLOCK_ENCODING                                                : integer := 96;
    constant AXI_READ_RESP_CHANGED_BEFORE_RREADY                                         : integer := 97;
    constant AXI_RESERVED_ARBURST_ENCODING                                               : integer := 98;
    constant AXI_RESERVED_AWBURST_ENCODING                                               : integer := 99;
    constant AXI_RID_CHANGED_BEFORE_RREADY                                               : integer := 100;
    constant AXI_RID_UNKN                                                                : integer := 101;
    constant AXI_RLAST_CHANGED_BEFORE_RREADY                                             : integer := 102;
    constant AXI_RLAST_UNKN                                                              : integer := 103;
    constant AXI_RREADY_UNKN                                                             : integer := 104;
    constant AXI_RRESP_UNKN                                                              : integer := 105;
    constant AXI_RUSER_CHANGED_BEFORE_RREADY                                             : integer := 106;
    constant AXI_RUSER_UNKN                                                              : integer := 107;
    constant AXI_RVALID_DEASSERTED_BEFORE_RREADY                                         : integer := 108;
    constant AXI_RVALID_HIGH_ON_FIRST_CLOCK_AFTER_RESET                                  : integer := 109;
    constant AXI_RVALID_UNKN                                                             : integer := 110;
    constant AXI_UNALIGNED_ADDRESS_FOR_EXCLUSIVE_READ                                    : integer := 111;
    constant AXI_UNALIGNED_ADDRESS_FOR_EXCLUSIVE_WRITE                                   : integer := 112;
    constant AXI_UNALIGNED_ADDR_FOR_WRAPPING_READ_BURST                                  : integer := 113;
    constant AXI_UNALIGNED_ADDR_FOR_WRAPPING_WRITE_BURST                                 : integer := 114;
    constant AXI_WDATA_CHANGED_BEFORE_WREADY_ON_INVALID_LANE                             : integer := 115;
    constant AXI_WDATA_CHANGED_BEFORE_WREADY_ON_VALID_LANE                               : integer := 116;
    constant AXI_WLAST_CHANGED_BEFORE_WREADY                                             : integer := 117;
    constant AXI_WID_CHANGED_BEFORE_WREADY                                               : integer := 118;
    constant AXI_WLAST_UNKN                                                              : integer := 119;
    constant AXI_WID_UNKN                                                                : integer := 120;
    constant AXI_WREADY_UNKN                                                             : integer := 121;
    constant AXI_WRITE_ALLOCATE_WHEN_NON_MODIFIABLE_12                                   : integer := 122;
    constant AXI_WRITE_ALLOCATE_WHEN_NON_MODIFIABLE_13                                   : integer := 123;
    constant AXI_WRITE_ALLOCATE_WHEN_NON_MODIFIABLE_4                                    : integer := 124;
    constant AXI_WRITE_ALLOCATE_WHEN_NON_MODIFIABLE_5                                    : integer := 125;
    constant AXI_WRITE_ALLOCATE_WHEN_NON_MODIFIABLE_8                                    : integer := 126;
    constant AXI_WRITE_ALLOCATE_WHEN_NON_MODIFIABLE_9                                    : integer := 127;
    constant AXI_WRITE_BURST_SIZE_VIOLATION                                              : integer := 128;
    constant AXI_WRITE_DATA_BEFORE_ADDRESS                                               : integer := 129;
    constant AXI_WRITE_DATA_UNKN_ON_INVALID_LANE                                         : integer := 130;
    constant AXI_WRITE_DATA_UNKN_ON_VALID_LANE                                           : integer := 131;
    constant AXI_RESERVED_AWLOCK_ENCODING                                                : integer := 132;
    constant AXI_WRITE_STROBE_ON_INVALID_BYTE_LANES                                      : integer := 133;
    constant AXI_WSTRB_CHANGED_BEFORE_WREADY                                             : integer := 134;
    constant AXI_WSTRB_UNKN                                                              : integer := 135;
    constant AXI_WUSER_CHANGED_BEFORE_WREADY                                             : integer := 136;
    constant AXI_WUSER_UNKN                                                              : integer := 137;
    constant AXI_WVALID_DEASSERTED_BEFORE_WREADY                                         : integer := 138;
    constant AXI_WVALID_HIGH_ON_FIRST_CLOCK_AFTER_RESET                                  : integer := 139;
    constant AXI_WVALID_UNKN                                                             : integer := 140;
    constant AXI_ADDR_ACROSS_4K_WITHIN_LOCKED_WRITE_TRANSACTION                          : integer := 141;
    constant AXI_ADDR_ACROSS_4K_WITHIN_LOCKED_READ_TRANSACTION                           : integer := 142;
    constant AXI_AWID_CHANGED_WITHIN_LOCKED_TRANSACTION                                  : integer := 143;
    constant AXI_ARID_CHANGED_WITHIN_LOCKED_TRANSACTION                                  : integer := 144;
    constant AXI_AWPROT_CHANGED_WITHIN_LOCKED_TRANSACTION                                : integer := 145;
    constant AXI_ARPROT_CHANGED_WITHIN_LOCKED_TRANSACTION                                : integer := 146;
    constant AXI_AWCACHE_CHANGED_WITHIN_LOCKED_TRANSACTION                               : integer := 147;
    constant AXI_ARCACHE_CHANGED_WITHIN_LOCKED_TRANSACTION                               : integer := 148;
    constant AXI_NUMBER_OF_LOCKED_SEQUENCES_EXCEEDS_2                                    : integer := 149;
    constant AXI_LOCKED_WRITE_BEFORE_COMPLETION_OF_PREVIOUS_WRITE_TRANSACTIONS           : integer := 150;
    constant AXI_LOCKED_WRITE_BEFORE_COMPLETION_OF_PREVIOUS_READ_TRANSACTIONS            : integer := 151;
    constant AXI_LOCKED_READ_BEFORE_COMPLETION_OF_PREVIOUS_WRITE_TRANSACTIONS            : integer := 152;
    constant AXI_LOCKED_READ_BEFORE_COMPLETION_OF_PREVIOUS_READ_TRANSACTIONS             : integer := 153;
    constant AXI_NEW_BURST_BEFORE_COMPLETION_OF_UNLOCK_TRANSACTION                       : integer := 154;
    constant AXI_UNLOCKED_WRITE_WHILE_OUTSTANDING_LOCKED_WRITES                          : integer := 155;
    constant AXI_UNLOCKED_WRITE_WHILE_OUTSTANDING_LOCKED_READS                           : integer := 156;
    constant AXI_UNLOCKED_READ_WHILE_OUTSTANDING_LOCKED_WRITES                           : integer := 157;
    constant AXI_UNLOCKED_READ_WHILE_OUTSTANDING_LOCKED_READS                            : integer := 158;
    constant AXI_UNLOCKING_TRANSACTION_WITH_AN_EXCLUSIVE_ACCESS                          : integer := 159;
    constant AXI_FIRST_DATA_ITEM_OF_TRANSACTION_WRITE_ORDER_VIOLATION                    : integer := 160;
    constant AXI_AWLEN_MISMATCHED_WITH_COMPLETED_WRITE_DATA_BURST                        : integer := 161;
    constant AXI_WRITE_LENGTH_MISMATCHED_ACTUAL_LENGTH_OF_WRITE_DATA_BURST_EXCEEDS_AWLEN : integer := 162;
    constant AXI_AWLEN_MISMATCHED_ACTUAL_LENGTH_OF_WRITE_DATA_BURST_EXCEEDS_AWLEN        : integer := 163;
    constant AXI_WLAST_ASSERTED_DURING_DATA_PHASE_OTHER_THAN_LAST                        : integer := 164;
    constant AXI_WRITE_INTERLEAVE_DEPTH_VIOLATION                                        : integer := 165;
    constant AXI_WRITE_RESPONSE_WITHOUT_ADDR                                             : integer := 166;
    constant AXI_WRITE_RESPONSE_WITHOUT_DATA                                             : integer := 167;
    constant AXI_AWVALID_HIGH_DURING_RESET                                               : integer := 168;
    constant AXI_WVALID_HIGH_DURING_RESET                                                : integer := 169;
    constant AXI_BVALID_HIGH_DURING_RESET                                                : integer := 170;
    constant AXI_ARVALID_HIGH_DURING_RESET                                               : integer := 171;
    constant AXI_RVALID_HIGH_DURING_RESET                                                : integer := 172;
    constant AXI_RLAST_VIOLATION                                                         : integer := 173;
    constant AXI_EX_WRITE_AFTER_EX_READ_FAILURE                                          : integer := 174;
    constant AXI_TIMEOUT_WAITING_FOR_WRITE_DATA                                          : integer := 175;
    constant AXI_TIMEOUT_WAITING_FOR_WRITE_RESPONSE                                      : integer := 176;
    constant AXI_TIMEOUT_WAITING_FOR_READ_RESPONSE                                       : integer := 177;
    constant AXI_TIMEOUT_WAITING_FOR_WRITE_ADDR_AFTER_DATA                               : integer := 178;
    constant AXI_DEC_ERR_RESP_FOR_READ                                                   : integer := 179;
    constant AXI_DEC_ERR_RESP_FOR_WRITE                                                  : integer := 180;
    constant AXI_SLV_ERR_RESP_FOR_READ                                                   : integer := 181;
    constant AXI_SLV_ERR_RESP_FOR_WRITE                                                  : integer := 182;
    constant AXI_MINIMUM_SLAVE_ADDRESS_SPACE_VIOLATION                                   : integer := 183;
    constant AXI_ADDRESS_WIDTH_EXCEEDS_64                                                : integer := 184;
    constant AXI_READ_BURST_MAXIMUM_LENGTH_VIOLATION                                     : integer := 185;
    constant AXI_WRITE_BURST_MAXIMUM_LENGTH_VIOLATION                                    : integer := 186;
    constant AXI_WRITE_STROBES_LENGTH_VIOLATION                                          : integer := 187;
    constant AXI_EX_RD_WHEN_EX_NOT_ENABLED                                               : integer := 188;
    constant AXI_EX_WR_WHEN_EX_NOT_ENABLED                                               : integer := 189;
    constant AXI_WRITE_TRANSFER_EXCEEDS_ADDRESS_SPACE                                    : integer := 190;
    constant AXI_READ_TRANSFER_EXCEEDS_ADDRESS_SPACE                                     : integer := 191;
    constant AXI_EXCL_RD_WHILE_EXCL_WR_IN_PROGRESS_SAME_ID                               : integer := 192;
    constant AXI_EXCL_WR_WHILE_EXCL_RD_IN_PROGRESS_SAME_ID                               : integer := 193;
    constant AXI_ILLEGAL_LENGTH_READ_BURST                                               : integer := 194;
    constant AXI_ILLEGAL_LENGTH_WRITE_BURST                                              : integer := 195;
    constant AXI_ARREADY_NOT_ASSERTED_AFTER_ARVALID                                      : integer := 196;
    constant AXI_BREADY_NOT_ASSERTED_AFTER_BVALID                                        : integer := 197;
    constant AXI_AWREADY_NOT_ASSERTED_AFTER_AWVALID                                      : integer := 198;
    constant AXI_RREADY_NOT_ASSERTED_AFTER_RVALID                                        : integer := 199;
    constant AXI_WREADY_NOT_ASSERTED_AFTER_WVALID                                        : integer := 200;
    constant AXI_DEC_ERR_ILLEGAL_FOR_MAPPED_SLAVE_ADDR                                   : integer := 201;
    constant AXI_PARAM_READ_REORDERING_DEPTH_EQUALS_ZERO                                 : integer := 202;
    constant AXI_PARAM_READ_REORDERING_DEPTH_EXCEEDS_MAX_ID                              : integer := 203;
    constant AXI_READ_REORDERING_VIOLATION                                               : integer := 204;


    constant AXI_MAX_BIT_SIZE : integer := 1024;

-- enum: axi_config_e
--
-- An enum which fields corresponding to each configuration parameter of the VIP
--    AXI_CONFIG_SETUP_TIME - 
--         
--             Number of time units for the setup time to the active clock edge of ACLK.
--           
--    AXI_CONFIG_HOLD_TIME - 
--         
--             Number of time units for the hold time to the active clock edge of ACLK.
--           
--    AXI_CONFIG_MAX_TRANSACTION_TIME_FACTOR - 
--          This timeout "config_max_transaction_time_factor" is the timeout that sets the maximum timeout within which any read/write transaction is 
--                expected to occur (and in turn all individual phases as well) of the AXI interface. 
--                This timeout should be set as the maximum duration of read/write. 
--                In short it indicates the maximum duration of a read/write transaction (From start of transaction to end of it).
--                Its default value is 100000 clock cycles
--             
--    AXI_CONFIG_TIMEOUT_MAX_DATA_TRANSFER - 
--          This timeout "config_timeout_max_data_transfer" is actually a configuration which tells about the maximum number of write data beats that the AXI interface
--               can generate as part of write data burst of write transfer. 
--               It is actually not a timeout value and is the maximum number of beats of Write data that are expected. 
--    AXI_CONFIG_BURST_TIMEOUT_FACTOR - 
--         This timeout "config_burst_timeout_factor" represents the maximum delay between the individual phases of the AXI transactions.
--              For example between read address phase and read data phase, write address and Write data phases. 
--              If this delay exceeds between the phases then transaction will be  timed out.
--              Its default value is 10000 clock cycles
--             
--    AXI_CONFIG_MAX_LATENCY_AWVALID_ASSERTION_TO_AWREADY - 
--          A configuration parameter defining the timeout (in clock periods) from the assertion of <AWVALID> to the assertion of <AWREADY> (default 10000).
--         
--         The error message <AXI_AWREADY_NOT_ASSERTED_AFTER_AWVALID> will be issued if this period elapses from the assertion of <AWVALID>.
--         
--    AXI_CONFIG_MAX_LATENCY_ARVALID_ASSERTION_TO_ARREADY - 
--          A configuration parameter defining the timeout (in clock periods) from the assertion of <ARVALID> to the assertion of <ARREADY> (default 10000).
--         
--         The error message <AXI_ARREADY_NOT_ASSERTED_AFTER_ARVALID> will be issued if this period elapses from the assertion of <ARVALID>.
--         
--    AXI_CONFIG_MAX_LATENCY_RVALID_ASSERTION_TO_RREADY - 
--          A configuration parameter defining the timeout (in clock periods) from the assertion of <RVALID> to the assertion of <RREADY> (default 10000).
--         
--         The error message <AXI_RREADY_NOT_ASSERTED_AFTER_RVALID> will be issued if this period elapses from the assertion of <RVALID>.
--         
--    AXI_CONFIG_MAX_LATENCY_BVALID_ASSERTION_TO_BREADY - 
--          A configuration parameter defining the timeout (in clock periods) from the assertion of <BVALID> to the assertion of <BREADY> (default 10000).
--         
--         The error message <AXI_BREADY_NOT_ASSERTED_AFTER_BVALID> will be issued if this period elapses from the assertion of <BVALID>.
--         
--    AXI_CONFIG_MAX_LATENCY_WVALID_ASSERTION_TO_WREADY - 
--          A configuration parameter defining the timeout (in clock periods) from the assertion of <WVALID> to the assertion of <WREADY> (default 10000).
--         
--         The error message <AXI_WREADY_NOT_ASSERTED_AFTER_WVALID> will be issued if this period elapses from the assertion of <WVALID>.
--         
--    AXI_CONFIG_WRITE_CTRL_TO_DATA_MINTIME -  Number of clocks from the start of control to the start of data in a write. This configuration parameter has been deprecated and maintained for backward compatibility. Instead use write_address_to_data_delay variable to control delay between write address phase and write data phase.
--    AXI_CONFIG_MASTER_WRITE_DELAY -  To configure the write sequence item delays to be inserted.
--    AXI_CONFIG_ENABLE_ALL_ASSERTIONS - 
--         
--           Configuration parameter controlling whether the error messages(Assertions) issued from the QVIP are Enabled or Disabled.  
--           By default, it is enabled.
--         
--    AXI_CONFIG_ENABLE_ASSERTION - 
--         
--           An array of configuration parameters controlling whether specific error messages(Assertion) (of type <axi_assertion_type_e>)
--           can be issued by the QVIP. By default, all errors are enabled. To suppress a particular error, set the corresponding bit to 0.
--           e.g. config.m_bfm.set_config_enable_error_index1(AXI_RESET_SIGNAL_Z, 0);
--         
--    AXI_CONFIG_SLAVE_START_ADDR - 
--         
--            A configuration parameter indicating start address for slave.
--           
--    AXI_CONFIG_SLAVE_END_ADDR - 
--         
--            A configuration parameter indicating end address for slave.
--           
--    AXI_CONFIG_READ_DATA_REORDERING_DEPTH - 
--         
--            A configuration parameter defining the read reordering depth of the slave end of the interface (SPEC3(A5.3.1)).
--         
--            Responses from the first <config_read_data_reordering_depth> outstanding read transactions, each with address <ARID> values different from any
--            earlier outstanding read transaction(as seen by the slave) are expected, interleaved at random. A violation causes a <AXI_READ_REORDERING_VIOLATION> error.
--         
--            The default value of <config_read_data_reordering_depth> is (1 << AXI_ID_WIDTH), so that the slave is expected to process all transactions in any order (up to uniqueness of <ARID>).
--         
--            For a given <AXI_ID_WIDTH> parameter value, the maximum possible value of <config_read_data_reordering_depth> is 2**AXI_ID_WIDTH. The <AXI_PARAM_READ_REORDERING_DEPTH_EXCEEDS_MAX_ID>
--            error report will be issued if <config_read_data_reordering_depth> exceeds this value.
--         
--            If the user-supplied value is 0, the <AXI4_PARAM_READ_REORDERING_DEPTH_EQUALS_ZERO> error will be issued, and the value will be set to 1.
--           
--    AXI_CONFIG_MASTER_ERROR_POSITION - 
--         
--             To confgure the type of Master Error.
--           
--    AXI_CONFIG_SUPPORT_EXCLUSIVE_ACCESS - 
--         
--             This configures the support for exclusive slave.
--             If set, it enables the exclusive support in slave.
--             If cleared, it disables the exclusive support and every exclusive read/write will return OKAY response and 
--             exclusive write will update the memory.  
--           
    constant AXI_CONFIG_SETUP_TIME                    : std_logic_vector(7 downto 0) := X"00";
    constant AXI_CONFIG_HOLD_TIME                     : std_logic_vector(7 downto 0) := X"01";
    constant AXI_CONFIG_MAX_TRANSACTION_TIME_FACTOR   : std_logic_vector(7 downto 0) := X"02";
    constant AXI_CONFIG_TIMEOUT_MAX_DATA_TRANSFER     : std_logic_vector(7 downto 0) := X"03";
    constant AXI_CONFIG_BURST_TIMEOUT_FACTOR          : std_logic_vector(7 downto 0) := X"04";
    constant AXI_CONFIG_MAX_LATENCY_AWVALID_ASSERTION_TO_AWREADY : std_logic_vector(7 downto 0) := X"05";
    constant AXI_CONFIG_MAX_LATENCY_ARVALID_ASSERTION_TO_ARREADY : std_logic_vector(7 downto 0) := X"06";
    constant AXI_CONFIG_MAX_LATENCY_RVALID_ASSERTION_TO_RREADY : std_logic_vector(7 downto 0) := X"07";
    constant AXI_CONFIG_MAX_LATENCY_BVALID_ASSERTION_TO_BREADY : std_logic_vector(7 downto 0) := X"08";
    constant AXI_CONFIG_MAX_LATENCY_WVALID_ASSERTION_TO_WREADY : std_logic_vector(7 downto 0) := X"09";
    constant AXI_CONFIG_WRITE_CTRL_TO_DATA_MINTIME    : std_logic_vector(7 downto 0) := X"0A";
    constant AXI_CONFIG_MASTER_WRITE_DELAY            : std_logic_vector(7 downto 0) := X"0B";
    constant AXI_CONFIG_ENABLE_ALL_ASSERTIONS         : std_logic_vector(7 downto 0) := X"0C";
    constant AXI_CONFIG_ENABLE_ASSERTION              : std_logic_vector(7 downto 0) := X"0D";
    constant AXI_CONFIG_SLAVE_START_ADDR              : std_logic_vector(7 downto 0) := X"0E";
    constant AXI_CONFIG_SLAVE_END_ADDR                : std_logic_vector(7 downto 0) := X"0F";
    constant AXI_CONFIG_READ_DATA_REORDERING_DEPTH    : std_logic_vector(7 downto 0) := X"10";
    constant AXI_CONFIG_MASTER_ERROR_POSITION         : std_logic_vector(7 downto 0) := X"11";
    constant AXI_CONFIG_SUPPORT_EXCLUSIVE_ACCESS      : std_logic_vector(7 downto 0) := X"12";
    constant AXI_CONFIG_MAX_OUTSTANDING_WR            : std_logic_vector(7 downto 0) := X"13";
    constant AXI_CONFIG_MAX_OUTSTANDING_RD            : std_logic_vector(7 downto 0) := X"14";

    -- axi_vhd_if_e
    constant AXI_VHD_SET_CONFIG                         : integer := 0;
    constant AXI_VHD_GET_CONFIG                         : integer := 1;
    constant AXI_VHD_CREATE_WRITE_TRANSACTION           : integer := 2;
    constant AXI_VHD_CREATE_READ_TRANSACTION            : integer := 3;
    constant AXI_VHD_SET_ADDR                           : integer := 4;
    constant AXI_VHD_GET_ADDR                           : integer := 5;
    constant AXI_VHD_SET_SIZE                           : integer := 6;
    constant AXI_VHD_GET_SIZE                           : integer := 7;
    constant AXI_VHD_SET_BURST                          : integer := 8;
    constant AXI_VHD_GET_BURST                          : integer := 9;
    constant AXI_VHD_SET_LOCK                           : integer := 10;
    constant AXI_VHD_GET_LOCK                           : integer := 11;
    constant AXI_VHD_SET_CACHE                          : integer := 12;
    constant AXI_VHD_GET_CACHE                          : integer := 13;
    constant AXI_VHD_SET_PROT                           : integer := 14;
    constant AXI_VHD_GET_PROT                           : integer := 15;
    constant AXI_VHD_SET_ID                             : integer := 16;
    constant AXI_VHD_GET_ID                             : integer := 17;
    constant AXI_VHD_SET_BURST_LENGTH                   : integer := 18;
    constant AXI_VHD_GET_BURST_LENGTH                   : integer := 19;
    constant AXI_VHD_SET_DATA_WORDS                     : integer := 20;
    constant AXI_VHD_GET_DATA_WORDS                     : integer := 21;
    constant AXI_VHD_SET_WRITE_STROBES                  : integer := 22;
    constant AXI_VHD_GET_WRITE_STROBES                  : integer := 23;
    constant AXI_VHD_SET_RESP                           : integer := 24;
    constant AXI_VHD_GET_RESP                           : integer := 25;
    constant AXI_VHD_SET_ADDR_USER                      : integer := 26;
    constant AXI_VHD_GET_ADDR_USER                      : integer := 27;
    constant AXI_VHD_SET_READ_OR_WRITE                  : integer := 28;
    constant AXI_VHD_GET_READ_OR_WRITE                  : integer := 29;
    constant AXI_VHD_SET_ADDRESS_VALID_DELAY            : integer := 30;
    constant AXI_VHD_GET_ADDRESS_VALID_DELAY            : integer := 31;
    constant AXI_VHD_SET_DATA_VALID_DELAY               : integer := 32;
    constant AXI_VHD_GET_DATA_VALID_DELAY               : integer := 33;
    constant AXI_VHD_SET_WRITE_RESPONSE_VALID_DELAY     : integer := 34;
    constant AXI_VHD_GET_WRITE_RESPONSE_VALID_DELAY     : integer := 35;
    constant AXI_VHD_SET_ADDRESS_READY_DELAY            : integer := 36;
    constant AXI_VHD_GET_ADDRESS_READY_DELAY            : integer := 37;
    constant AXI_VHD_SET_DATA_READY_DELAY               : integer := 38;
    constant AXI_VHD_GET_DATA_READY_DELAY               : integer := 39;
    constant AXI_VHD_SET_WRITE_RESPONSE_READY_DELAY     : integer := 40;
    constant AXI_VHD_GET_WRITE_RESPONSE_READY_DELAY     : integer := 41;
    constant AXI_VHD_SET_GEN_WRITE_STROBES              : integer := 42;
    constant AXI_VHD_GET_GEN_WRITE_STROBES              : integer := 43;
    constant AXI_VHD_SET_OPERATION_MODE                 : integer := 44;
    constant AXI_VHD_GET_OPERATION_MODE                 : integer := 45;
    constant AXI_VHD_SET_DELAY_MODE                     : integer := 46;
    constant AXI_VHD_GET_DELAY_MODE                     : integer := 47;
    constant AXI_VHD_SET_WRITE_DATA_MODE                : integer := 48;
    constant AXI_VHD_GET_WRITE_DATA_MODE                : integer := 49;
    constant AXI_VHD_SET_DATA_BEAT_DONE                 : integer := 50;
    constant AXI_VHD_GET_DATA_BEAT_DONE                 : integer := 51;
    constant AXI_VHD_SET_TRANSACTION_DONE               : integer := 52;
    constant AXI_VHD_GET_TRANSACTION_DONE               : integer := 53;
    constant AXI_VHD_EXECUTE_TRANSACTION                : integer := 54;
    constant AXI_VHD_GET_RW_TRANSACTION                 : integer := 55;
    constant AXI_VHD_EXECUTE_READ_DATA_BURST            : integer := 56;
    constant AXI_VHD_GET_READ_DATA_BURST                : integer := 57;
    constant AXI_VHD_EXECUTE_WRITE_DATA_BURST           : integer := 58;
    constant AXI_VHD_GET_WRITE_DATA_BURST               : integer := 59;
    constant AXI_VHD_EXECUTE_READ_ADDR_PHASE            : integer := 60;
    constant AXI_VHD_GET_READ_ADDR_PHASE                : integer := 61;
    constant AXI_VHD_EXECUTE_READ_DATA_PHASE            : integer := 62;
    constant AXI_VHD_GET_READ_DATA_PHASE                : integer := 63;
    constant AXI_VHD_EXECUTE_WRITE_ADDR_PHASE           : integer := 64;
    constant AXI_VHD_GET_WRITE_ADDR_PHASE               : integer := 65;
    constant AXI_VHD_EXECUTE_WRITE_DATA_PHASE           : integer := 66;
    constant AXI_VHD_GET_WRITE_DATA_PHASE               : integer := 67;
    constant AXI_VHD_EXECUTE_WRITE_RESPONSE_PHASE       : integer := 68;
    constant AXI_VHD_GET_WRITE_RESPONSE_PHASE           : integer := 69;
    constant AXI_VHD_CREATE_MONITOR_TRANSACTION         : integer := 70;
    constant AXI_VHD_CREATE_SLAVE_TRANSACTION           : integer := 71;
    constant AXI_VHD_PUSH_TRANSACTION_ID                : integer := 72;
    constant AXI_VHD_POP_TRANSACTION_ID                 : integer := 73;
    constant AXI_VHD_GET_WRITE_ADDR_DATA                : integer := 74;
    constant AXI_VHD_GET_READ_ADDR                      : integer := 75;
    constant AXI_VHD_SET_READ_DATA                      : integer := 76;
    constant AXI_VHD_PRINT                              : integer := 77;
    constant AXI_VHD_DESTRUCT_TRANSACTION               : integer := 78;
    constant AXI_VHD_WAIT_ON                            : integer := 79;

    -- axi_wait_e
    constant AXI_CLOCK_POSEDGE        : integer := 0;
    constant AXI_CLOCK_NEGEDGE        : integer := 1;
    constant AXI_CLOCK_ANYEDGE        : integer := 2;
    constant AXI_CLOCK_0_TO_1         : integer := 3;
    constant AXI_CLOCK_1_TO_0         : integer := 4;
    constant AXI_RESET_POSEDGE        : integer := 5;
    constant AXI_RESET_NEGEDGE        : integer := 6;
    constant AXI_RESET_ANYEDGE        : integer := 7;
    constant AXI_RESET_0_TO_1         : integer := 8;
    constant AXI_RESET_1_TO_0         : integer := 9;

    -- axi_operation_mode_e
    constant AXI_TRANSACTION_NON_BLOCKING : integer := 0;
    constant AXI_TRANSACTION_BLOCKING     : integer := 1;

    -- axi_delay_mode_e
    constant AXI_VALID2READY              : integer := 0;
    constant AXI_TRANS2READY              : integer := 1;

    -- axi_write_data_mode_e
    constant AXI_DATA_AFTER_ADDRESS       : integer := 0;
    constant AXI_DATA_WITH_ADDRESS        : integer := 1;

    -- Queue ID
    constant AXI_QUEUE_ID_0 : integer := 0;
    constant AXI_QUEUE_ID_1 : integer := 1;
    constant AXI_QUEUE_ID_2 : integer := 2;
    constant AXI_QUEUE_ID_3 : integer := 3;
    constant AXI_QUEUE_ID_4 : integer := 4;

    -- Parallel path
    type axi_path_t is (
      AXI_PATH_0,
      AXI_PATH_1,
      AXI_PATH_2,
      AXI_PATH_3,
      AXI_PATH_4
    );

    -- Global signal record
    type axi_vhd_if_struct_t is record
        req             : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        ack             : std_logic_vector(AXI_VHD_WAIT_ON downto 0);
        transaction_id  : integer; 
        value_0         : integer;
        value_1         : integer;
        value_2         : integer;
        value_3         : integer;
        value_max       : std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
    end record;

    -- 512 array of records 
    type axi_tr_if_array_t is array(511 downto 0) of axi_vhd_if_struct_t;
    type axi_tr_if_path_array_t is array(axi_path_t) of axi_vhd_if_struct_t;
    type axi_tr_if_path_2d_array_t is array(511 downto 0) of axi_tr_if_path_array_t;

    -- Global signal passed to each API
    signal axi_tr_if_0              : axi_tr_if_array_t;
    signal axi_tr_if_1              : axi_tr_if_array_t;
    signal axi_tr_if_2              : axi_tr_if_array_t;
    signal axi_tr_if_3              : axi_tr_if_array_t;
    signal axi_tr_if_4              : axi_tr_if_array_t;
    signal axi_tr_if_local          : axi_tr_if_path_2d_array_t;

    -- Helper method to convert to integer
    function to_integer (OP: STD_LOGIC_VECTOR) return INTEGER;

    -- API: Master, Slave, Monitor
    -- This procedure sets the configuration of the BFM.
    procedure set_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         bfm_id        : in    integer;
                         signal tr_if  : inout axi_vhd_if_struct_t);

    procedure set_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         bfm_id        : in    integer;
                         path_id       : in    axi_path_t;
                         signal tr_if  : inout axi_vhd_if_struct_t);

    procedure set_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : in    integer;
                         bfm_id        : in    integer;
                         signal tr_if  : inout axi_vhd_if_struct_t);

    procedure set_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : in    integer;
                         bfm_id        : in    integer;
                         path_id       : in    axi_path_t;
                         signal tr_if  : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- This procedure gets the configuration of the BFM.
    procedure get_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : out   std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         bfm_id        : in    integer;
                         signal tr_if  : inout axi_vhd_if_struct_t);

    procedure get_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : out   std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         bfm_id        : in    integer;
                         path_id       : in    axi_path_t;
                         signal tr_if  : inout axi_vhd_if_struct_t);

    procedure get_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : out   integer;
                         bfm_id        : in    integer;
                         signal tr_if  : inout axi_vhd_if_struct_t);

    procedure get_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : out   integer;
                         bfm_id        : in    integer;
                         path_id       : in    axi_path_t;
                         signal tr_if  : inout axi_vhd_if_struct_t);

    -- API: Master
    -- This procedure creates a write transaction with the given parameters.
    procedure create_write_transaction(addr            : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi_path_t;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi_path_t;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in integer;
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in integer;
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi_path_t;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi_path_t;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    -- API: Master
    -- This procedure creates a read transaction with the given parameters.
    procedure create_read_transaction(addr            : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi_path_t;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi_path_t;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in integer;
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in integer;
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi_path_t;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi_path_t;
                                       signal tr_if    : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the addr field of the transaction.
    procedure set_addr(addr                : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_addr(addr                : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_addr(addr                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_addr(addr                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the addr field of the transaction.
    procedure get_addr(addr                : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_addr(addr                : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_addr(addr                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_addr(addr                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the size field of the transaction.
    procedure set_size(size                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_size(size                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the size field of the transaction.
    procedure get_size(size                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_size(size                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the burst field of the transaction.
    procedure set_burst(burst               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_burst(burst               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the burst field of the transaction.
    procedure get_burst(burst               : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_burst(burst               : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the lock field of the transaction.
    procedure set_lock(lock                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_lock(lock                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the lock field of the transaction.
    procedure get_lock(lock                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_lock(lock                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the cache field of the transaction.
    procedure set_cache(cache               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_cache(cache               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the cache field of the transaction.
    procedure get_cache(cache               : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_cache(cache               : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the prot field of the transaction.
    procedure set_prot(prot                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_prot(prot                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the prot field of the transaction.
    procedure get_prot(prot                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_prot(prot                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the id field of the transaction.
    procedure set_id(id                  : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_id(id                  : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_id(id                  : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_id(id                  : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the id field of the transaction.
    procedure get_id(id                  : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_id(id                  : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_id(id                  : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_id(id                  : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the burst_length field of the transaction.
    procedure set_burst_length(burst_length        : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_burst_length(burst_length        : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_burst_length(burst_length        : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_burst_length(burst_length        : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the burst_length field of the transaction.
    procedure get_burst_length(burst_length        : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_burst_length(burst_length        : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_burst_length(burst_length        : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_burst_length(burst_length        : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the data_words field of the transaction.
    procedure set_data_words(data_words          : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the data_words field of the transaction.
    procedure get_data_words(data_words          : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the write_strobes field of the transaction.
    procedure set_write_strobes(write_strobes       : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the write_strobes field of the transaction.
    procedure get_write_strobes(write_strobes       : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the resp field of the transaction.
    procedure set_resp(resp                : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_resp(resp                : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_resp(resp                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_resp(resp                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the resp field of the transaction.
    procedure get_resp(resp                : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_resp(resp                : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_resp(resp                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_resp(resp                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the addr_user field of the transaction.
    procedure set_addr_user(addr_user           : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_addr_user(addr_user           : in    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_addr_user(addr_user           : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_addr_user(addr_user           : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the addr_user field of the transaction.
    procedure get_addr_user(addr_user           : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_addr_user(addr_user           : out    std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_addr_user(addr_user           : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_addr_user(addr_user           : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- This field is set by default when creating a transaction.
    procedure set_read_or_write(read_or_write       : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_read_or_write(read_or_write       : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the read_or_write field of the transaction.
    procedure get_read_or_write(read_or_write       : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_read_or_write(read_or_write       : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the address_valid_delay field of the transaction.
    procedure set_address_valid_delay(address_valid_delay : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_address_valid_delay(address_valid_delay : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the address_valid_delay field of the transaction.
    procedure get_address_valid_delay(address_valid_delay : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_address_valid_delay(address_valid_delay : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the data_valid_delay field of the transaction.
    procedure set_data_valid_delay(data_valid_delay    : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_valid_delay(data_valid_delay    : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_valid_delay(data_valid_delay    : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_valid_delay(data_valid_delay    : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the data_valid_delay field of the transaction.
    procedure get_data_valid_delay(data_valid_delay    : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_valid_delay(data_valid_delay    : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_valid_delay(data_valid_delay    : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_valid_delay(data_valid_delay    : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the write_response_valid_delay field of the transaction.
    procedure set_write_response_valid_delay(write_response_valid_delay: in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_write_response_valid_delay(write_response_valid_delay: in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the write_response_valid_delay field of the transaction.
    procedure get_write_response_valid_delay(write_response_valid_delay: out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_write_response_valid_delay(write_response_valid_delay: out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the address_ready_delay field of the transaction.
    procedure set_address_ready_delay(address_ready_delay : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_address_ready_delay(address_ready_delay : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the address_ready_delay field of the transaction.
    procedure get_address_ready_delay(address_ready_delay : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_address_ready_delay(address_ready_delay : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the data_ready_delay field of the transaction.
    procedure set_data_ready_delay(data_ready_delay    : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_ready_delay(data_ready_delay    : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_ready_delay(data_ready_delay    : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_ready_delay(data_ready_delay    : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the data_ready_delay field of the transaction.
    procedure get_data_ready_delay(data_ready_delay    : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_ready_delay(data_ready_delay    : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_ready_delay(data_ready_delay    : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_ready_delay(data_ready_delay    : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the write_response_ready_delay field of the transaction.
    procedure set_write_response_ready_delay(write_response_ready_delay: in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_write_response_ready_delay(write_response_ready_delay: in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the write_response_ready_delay field of the transaction.
    procedure get_write_response_ready_delay(write_response_ready_delay: out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_write_response_ready_delay(write_response_ready_delay: out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the gen_write_strobes field of the transaction.
    procedure set_gen_write_strobes(gen_write_strobes   : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_gen_write_strobes(gen_write_strobes   : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the gen_write_strobes field of the transaction.
    procedure get_gen_write_strobes(gen_write_strobes   : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_gen_write_strobes(gen_write_strobes   : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the operation_mode field of the transaction.
    procedure set_operation_mode(operation_mode      : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_operation_mode(operation_mode      : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the operation_mode field of the transaction.
    procedure get_operation_mode(operation_mode      : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_operation_mode(operation_mode      : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the delay_mode field of the transaction.
    procedure set_delay_mode(delay_mode          : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_delay_mode(delay_mode          : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the delay_mode field of the transaction.
    procedure get_delay_mode(delay_mode          : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_delay_mode(delay_mode          : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Set the write_data_mode field of the transaction.
    procedure set_write_data_mode(write_data_mode     : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_write_data_mode(write_data_mode     : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the write_data_mode field of the transaction.
    procedure get_write_data_mode(write_data_mode     : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_write_data_mode(write_data_mode     : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave
    -- Set the data_beat_done field of the transaction.
    procedure set_data_beat_done(data_beat_done      : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_beat_done(data_beat_done      : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_beat_done(data_beat_done      : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_data_beat_done(data_beat_done      : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the data_beat_done field of the transaction.
    procedure get_data_beat_done(data_beat_done      : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_beat_done(data_beat_done      : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_beat_done(data_beat_done      : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_data_beat_done(data_beat_done      : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave
    -- Set the transaction_done field of the transaction.
    procedure set_transaction_done(transaction_done    : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure set_transaction_done(transaction_done    : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the transaction_done field of the transaction.
    procedure get_transaction_done(transaction_done    : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    procedure get_transaction_done(transaction_done    : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi_path_t;
                    signal tr_if        : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Execute a transaction defined by the paramters.
    procedure execute_transaction(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure execute_transaction(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Master, Monitor
    -- Get a read_data_burst defined by the paramters.
    procedure get_read_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure get_read_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Execute a write_data_burst defined by the paramters.
    procedure execute_write_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure execute_write_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Execute a read_addr_phase defined by the paramters.
    procedure execute_read_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure execute_read_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Master, Monitor
    -- Get a read_data_phase defined by the paramters.
    procedure get_read_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     last         : out   integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure get_read_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     last         : out    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure get_read_data_phase(transaction_id  : in    integer;
                                     last         : out   integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure get_read_data_phase(transaction_id  : in    integer;
                                     last         : out    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Execute a write_addr_phase defined by the paramters.
    procedure execute_write_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure execute_write_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Master
    -- Execute a write_data_phase defined by the paramters.
    procedure execute_write_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure execute_write_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure execute_write_data_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure execute_write_data_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Master, Monitor
    -- Get a write_response_phase defined by the paramters.
    procedure get_write_response_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure get_write_response_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Slave
    -- Create a slave_transaction defined by the paramters.
    procedure create_slave_transaction(transaction_id  : out    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure create_slave_transaction(transaction_id  : out    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Slave
    -- Execute a read_data_burst defined by the paramters.
    procedure execute_read_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure execute_read_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Slave, Monitor
    -- Get a write_data_burst defined by the paramters.
    procedure get_write_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure get_write_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Slave, Monitor
    -- Get a read_addr_phase defined by the paramters.
    procedure get_read_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure get_read_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Slave
    -- Execute a read_data_phase defined by the paramters.
    procedure execute_read_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure execute_read_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure execute_read_data_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure execute_read_data_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Slave, Monitor
    -- Get a write_addr_phase defined by the paramters.
    procedure get_write_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure get_write_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Slave, Monitor
    -- Get a write_data_phase defined by the paramters.
    procedure get_write_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     last         : out   integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure get_write_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     last         : out    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure get_write_data_phase(transaction_id  : in    integer;
                                     last         : out   integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure get_write_data_phase(transaction_id  : in    integer;
                                     last         : out    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Slave
    -- Execute a write_response_phase defined by the paramters.
    procedure execute_write_response_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure execute_write_response_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Monitor
    -- Create a monitor_transaction defined by the paramters.
    procedure create_monitor_transaction(transaction_id  : out    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure create_monitor_transaction(transaction_id  : out    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Monitor
    -- Get a rw_transaction defined by the paramters.
    procedure get_rw_transaction(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    procedure get_rw_transaction(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi_path_t;
                                     signal tr_if : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Push the transaction_id into the back of the queue.
    procedure push_transaction_id(transaction_id  : in integer;
                           queue_id        : in integer;
                           bfm_id          : in integer;
                           signal tr_if    : inout axi_vhd_if_struct_t);

    procedure push_transaction_id(transaction_id  : in integer;
                           queue_id        : in integer;
                           bfm_id          : in integer;
                           path_id         : in axi_path_t;
                           signal tr_if    : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Pop the transaction_id from the front of the queue.
    procedure pop_transaction_id(transaction_id  : out integer;
                           queue_id        : in integer;
                           bfm_id          : in integer;
                           signal tr_if    : inout axi_vhd_if_struct_t);

    procedure pop_transaction_id(transaction_id  : out integer;
                           queue_id        : in integer;
                           bfm_id          : in integer;
                           path_id         : in axi_path_t;
                           signal tr_if    : inout axi_vhd_if_struct_t);

    -- API: Slave
    -- Returns the address and data of the given byte within a write_data_phase.
    procedure get_write_addr_data(transaction_id  : in  integer;
                    index           : in  integer;
                    byte_index      : in  integer;
                    dynamic_size    : out integer;
                    addr            : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                    data            : out std_logic_vector(7 downto 0);
                    bfm_id          : in  integer;
                    signal tr_if    : inout axi_vhd_if_struct_t);

    procedure get_write_addr_data(transaction_id  : in  integer;
                    index           : in  integer;
                    byte_index      : in  integer;
                    dynamic_size    : out integer;
                    addr            : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                    data            : out std_logic_vector(7 downto 0);
                    bfm_id          : in  integer;
                    path_id         : in  axi_path_t;
                    signal tr_if    : inout axi_vhd_if_struct_t);

    -- API: Slave
    -- Returns the address of the given byte within a read_data transaction.
    procedure get_read_addr(transaction_id  : in  integer;
                    index           : in  integer;
                    byte_index      : in  integer;
                    dynamic_size    : out integer;
                    addr            : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                    bfm_id          : in  integer;
                    signal tr_if    : inout axi_vhd_if_struct_t);

    procedure get_read_addr(transaction_id  : in  integer;
                    index           : in  integer;
                    byte_index      : in  integer;
                    dynamic_size    : out integer;
                    addr            : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                    bfm_id          : in  integer;
                    path_id         : in  axi_path_t;
                    signal tr_if    : inout axi_vhd_if_struct_t);

    -- API: Slave
    -- Set the given data byte within a read transaction.
    procedure set_read_data(transaction_id  : in integer;
                    index           : in integer;
                    byte_index      : in integer;
                    dynamic_size    : in integer;
                    addr            : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                    data            : in std_logic_vector(7 downto 0);
                    bfm_id          : in integer;
                    signal tr_if    : inout axi_vhd_if_struct_t);

    procedure set_read_data(transaction_id  : in integer;
                    index           : in integer;
                    byte_index      : in integer;
                    dynamic_size    : in integer;
                    addr            : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                    data            : in std_logic_vector(7 downto 0);
                    bfm_id          : in integer;
                    path_id         : in axi_path_t;
                    signal tr_if    : inout axi_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Print the transaction identified by the transaction_id.
    procedure print( transaction_id  : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi_vhd_if_struct_t );

    procedure print( transaction_id  : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi_path_t;
                    signal tr_if    : inout axi_vhd_if_struct_t );

    procedure print( transaction_id  : in integer;
                    print_delays    : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi_vhd_if_struct_t );

    procedure print( transaction_id  : in integer;
                    print_delays    : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi_path_t;
                    signal tr_if    : inout axi_vhd_if_struct_t );

    -- API: Master, Slave, Monitor
    -- Remove and clean up the transaction identified by the transaction_id.
    procedure destruct_transaction( transaction_id  : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi_vhd_if_struct_t );

    procedure destruct_transaction( transaction_id  : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi_path_t;
                    signal tr_if    : inout axi_vhd_if_struct_t );

    -- API: Master, Slave, Monitor
    -- Wait for the event specified by the parameters.
    procedure wait_on( phase           : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi_vhd_if_struct_t );

    procedure wait_on( phase           : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi_path_t;
                    signal tr_if    : inout axi_vhd_if_struct_t );

    procedure wait_on( phase           : in integer;
                    count           : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi_vhd_if_struct_t );

    procedure wait_on( phase           : in integer;
                    count           : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi_path_t;
                    signal tr_if    : inout axi_vhd_if_struct_t );

end mgc_axi_bfm_pkg;

-- Procedure implementations:
package body mgc_axi_bfm_pkg is

    ------------------------------------------------------------------------
    -- Id: TI2
    -- Convert passed std_logic_vector into integer.
    -- generate warning message if:
    --  array contains anything other than 0 or 1.
    ------------------------------------------------------------------------
    function to_integer (OP: STD_LOGIC_VECTOR)
      return INTEGER is
      variable result : INTEGER := 0;
      variable tmp_op : STD_LOGIC_VECTOR (OP'range) := OP;
    begin
      if not (Is_X(OP)) then
        for i in OP'range loop
          if OP(i) = '1' then
            result := result + 2**i;
          end if;
        end loop; 
        return result;
      -- OP contains anything other than 0 or 1
      else
      --  assert FALSE
      --    report "Illegal value detected in the conversion of TO_INTEGER"
      --    severity WARNING;
            return 0;
      end if;
    end to_integer;

    procedure set_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         bfm_id       : in integer;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0   <= to_integer(config_name);
      tr_if.value_max <= config_val;
      tr_if.req(AXI_VHD_SET_CONFIG) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_CONFIG) = '1');
      tr_if.req(AXI_VHD_SET_CONFIG) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_CONFIG) = '0');
    end set_config;

    procedure set_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         bfm_id       : in integer;
                         path_id      : in axi_path_t;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0   <= to_integer(config_name);
      tr_if.value_max <= config_val;
      tr_if.req(AXI_VHD_SET_CONFIG) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_CONFIG) = '1');
      tr_if.req(AXI_VHD_SET_CONFIG) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_CONFIG) = '0');
    end set_config;

    procedure set_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : in integer;
                         bfm_id       : in integer;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0   <= to_integer(config_name);
      tr_if.value_max <= conv_std_logic_vector(config_val, AXI_MAX_BIT_SIZE);
      tr_if.req(AXI_VHD_SET_CONFIG) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_CONFIG) = '1');
      tr_if.req(AXI_VHD_SET_CONFIG) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_CONFIG) = '0');
    end set_config;

    procedure set_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : in integer;
                         bfm_id       : in integer;
                         path_id      : in axi_path_t;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0   <= to_integer(config_name);
      tr_if.value_max <= conv_std_logic_vector(config_val, AXI_MAX_BIT_SIZE);
      tr_if.req(AXI_VHD_SET_CONFIG) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_CONFIG) = '1');
      tr_if.req(AXI_VHD_SET_CONFIG) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_CONFIG) = '0');
    end set_config;

    procedure get_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         bfm_id       : in integer;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= to_integer(config_name);
      tr_if.req(AXI_VHD_GET_CONFIG) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_CONFIG) = '1');
      tr_if.req(AXI_VHD_GET_CONFIG) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_CONFIG) = '0');
      config_val := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max;
    end get_config;

    procedure get_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         bfm_id       : in integer;
                         path_id      : in axi_path_t;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= to_integer(config_name);
      tr_if.req(AXI_VHD_GET_CONFIG) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_CONFIG) = '1');
      tr_if.req(AXI_VHD_GET_CONFIG) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_CONFIG) = '0');
      config_val := axi_tr_if_local(bfm_id)(path_id).value_max;
    end get_config;

    procedure get_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : out integer;
                         bfm_id       : in integer;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= to_integer(config_name);
      tr_if.req(AXI_VHD_GET_CONFIG) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_CONFIG) = '1');
      tr_if.req(AXI_VHD_GET_CONFIG) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_CONFIG) = '0');
      config_val := to_integer(axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max);
    end get_config;

    procedure get_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : out integer;
                         bfm_id       : in integer;
                         path_id      : in axi_path_t;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= to_integer(config_name);
      tr_if.req(AXI_VHD_GET_CONFIG) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_CONFIG) = '1');
      tr_if.req(AXI_VHD_GET_CONFIG) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_CONFIG) = '0');
      config_val := to_integer(axi_tr_if_local(bfm_id)(path_id).value_max);
    end get_config;

    procedure create_write_transaction(addr : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(AXI_PATH_0).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi_path_t;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= 0;
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(AXI_PATH_0).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi_path_t;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= 0;
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in integer;
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI_MAX_BIT_SIZE);
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(AXI_PATH_0).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in integer;
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi_path_t;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI_MAX_BIT_SIZE);
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI_MAX_BIT_SIZE);
      tr_if.value_0     <= 0;
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(AXI_PATH_0).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi_path_t;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI_MAX_BIT_SIZE);
      tr_if.value_0     <= 0;
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_write_transaction;

    procedure create_read_transaction(addr : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(AXI_PATH_0).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi_path_t;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= 0;
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(AXI_PATH_0).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi_path_t;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= 0;
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in integer;
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI_MAX_BIT_SIZE);
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(AXI_PATH_0).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in integer;
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi_path_t;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI_MAX_BIT_SIZE);
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI_MAX_BIT_SIZE);
      tr_if.value_0     <= 0;
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(AXI_PATH_0).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi_path_t;
                         signal tr_if : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI_MAX_BIT_SIZE);
      tr_if.value_0     <= 0;
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_read_transaction;

    procedure set_addr(addr       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= addr;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ADDR) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ADDR) = '1');
      tr_if.req(AXI_VHD_SET_ADDR) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ADDR) = '0');
    end set_addr;

    procedure set_addr(addr       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= addr;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ADDR) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ADDR) = '1');
      tr_if.req(AXI_VHD_SET_ADDR) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ADDR) = '0');
    end set_addr;

    procedure set_addr(addr       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(addr, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ADDR) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ADDR) = '1');
      tr_if.req(AXI_VHD_SET_ADDR) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ADDR) = '0');
    end set_addr;

    procedure set_addr(addr       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(addr, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ADDR) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ADDR) = '1');
      tr_if.req(AXI_VHD_SET_ADDR) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ADDR) = '0');
    end set_addr;

    procedure get_addr(addr       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ADDR) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ADDR) = '1');
      tr_if.req(AXI_VHD_GET_ADDR) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ADDR) = '0');
      addr := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max;
    end get_addr;

    procedure get_addr(addr       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ADDR) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ADDR) = '1');
      tr_if.req(AXI_VHD_GET_ADDR) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ADDR) = '0');
      addr := axi_tr_if_local(bfm_id)(path_id).value_max;
    end get_addr;

    procedure get_addr(addr       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ADDR) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ADDR) = '1');
      tr_if.req(AXI_VHD_GET_ADDR) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ADDR) = '0');
      addr := to_integer(axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max);
    end get_addr;

    procedure get_addr(addr       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ADDR) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ADDR) = '1');
      tr_if.req(AXI_VHD_GET_ADDR) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ADDR) = '0');
      addr := to_integer(axi_tr_if_local(bfm_id)(path_id).value_max);
    end get_addr;

    procedure set_size(size       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= size;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_SIZE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_SIZE) = '1');
      tr_if.req(AXI_VHD_SET_SIZE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_SIZE) = '0');
    end set_size;

    procedure set_size(size       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= size;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_SIZE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_SIZE) = '1');
      tr_if.req(AXI_VHD_SET_SIZE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_SIZE) = '0');
    end set_size;

    procedure get_size(size       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_SIZE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_SIZE) = '1');
      tr_if.req(AXI_VHD_GET_SIZE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_SIZE) = '0');
      size := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_size;

    procedure get_size(size       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_SIZE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_SIZE) = '1');
      tr_if.req(AXI_VHD_GET_SIZE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_SIZE) = '0');
      size := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_size;

    procedure set_burst(burst       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= burst;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_BURST) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_BURST) = '1');
      tr_if.req(AXI_VHD_SET_BURST) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_BURST) = '0');
    end set_burst;

    procedure set_burst(burst       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= burst;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_BURST) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_BURST) = '1');
      tr_if.req(AXI_VHD_SET_BURST) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_BURST) = '0');
    end set_burst;

    procedure get_burst(burst       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_BURST) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_BURST) = '1');
      tr_if.req(AXI_VHD_GET_BURST) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_BURST) = '0');
      burst := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_burst;

    procedure get_burst(burst       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_BURST) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_BURST) = '1');
      tr_if.req(AXI_VHD_GET_BURST) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_BURST) = '0');
      burst := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_burst;

    procedure set_lock(lock       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= lock;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_LOCK) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_LOCK) = '1');
      tr_if.req(AXI_VHD_SET_LOCK) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_LOCK) = '0');
    end set_lock;

    procedure set_lock(lock       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= lock;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_LOCK) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_LOCK) = '1');
      tr_if.req(AXI_VHD_SET_LOCK) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_LOCK) = '0');
    end set_lock;

    procedure get_lock(lock       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_LOCK) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_LOCK) = '1');
      tr_if.req(AXI_VHD_GET_LOCK) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_LOCK) = '0');
      lock := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_lock;

    procedure get_lock(lock       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_LOCK) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_LOCK) = '1');
      tr_if.req(AXI_VHD_GET_LOCK) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_LOCK) = '0');
      lock := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_lock;

    procedure set_cache(cache       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= cache;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_CACHE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_CACHE) = '1');
      tr_if.req(AXI_VHD_SET_CACHE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_CACHE) = '0');
    end set_cache;

    procedure set_cache(cache       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= cache;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_CACHE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_CACHE) = '1');
      tr_if.req(AXI_VHD_SET_CACHE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_CACHE) = '0');
    end set_cache;

    procedure get_cache(cache       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_CACHE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_CACHE) = '1');
      tr_if.req(AXI_VHD_GET_CACHE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_CACHE) = '0');
      cache := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_cache;

    procedure get_cache(cache       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_CACHE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_CACHE) = '1');
      tr_if.req(AXI_VHD_GET_CACHE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_CACHE) = '0');
      cache := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_cache;

    procedure set_prot(prot       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= prot;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_PROT) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_PROT) = '1');
      tr_if.req(AXI_VHD_SET_PROT) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_PROT) = '0');
    end set_prot;

    procedure set_prot(prot       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= prot;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_PROT) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_PROT) = '1');
      tr_if.req(AXI_VHD_SET_PROT) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_PROT) = '0');
    end set_prot;

    procedure get_prot(prot       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_PROT) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_PROT) = '1');
      tr_if.req(AXI_VHD_GET_PROT) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_PROT) = '0');
      prot := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_prot;

    procedure get_prot(prot       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_PROT) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_PROT) = '1');
      tr_if.req(AXI_VHD_GET_PROT) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_PROT) = '0');
      prot := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_prot;

    procedure set_id(id       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= id;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ID) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ID) = '1');
      tr_if.req(AXI_VHD_SET_ID) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ID) = '0');
    end set_id;

    procedure set_id(id       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= id;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ID) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ID) = '1');
      tr_if.req(AXI_VHD_SET_ID) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ID) = '0');
    end set_id;

    procedure set_id(id       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(id, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ID) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ID) = '1');
      tr_if.req(AXI_VHD_SET_ID) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ID) = '0');
    end set_id;

    procedure set_id(id       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(id, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ID) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ID) = '1');
      tr_if.req(AXI_VHD_SET_ID) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ID) = '0');
    end set_id;

    procedure get_id(id       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ID) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ID) = '1');
      tr_if.req(AXI_VHD_GET_ID) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ID) = '0');
      id := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max;
    end get_id;

    procedure get_id(id       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ID) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ID) = '1');
      tr_if.req(AXI_VHD_GET_ID) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ID) = '0');
      id := axi_tr_if_local(bfm_id)(path_id).value_max;
    end get_id;

    procedure get_id(id       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ID) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ID) = '1');
      tr_if.req(AXI_VHD_GET_ID) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ID) = '0');
      id := to_integer(axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max);
    end get_id;

    procedure get_id(id       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ID) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ID) = '1');
      tr_if.req(AXI_VHD_GET_ID) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ID) = '0');
      id := to_integer(axi_tr_if_local(bfm_id)(path_id).value_max);
    end get_id;

    procedure set_burst_length(burst_length       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= burst_length;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_BURST_LENGTH) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_BURST_LENGTH) = '1');
      tr_if.req(AXI_VHD_SET_BURST_LENGTH) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_BURST_LENGTH) = '0');
    end set_burst_length;

    procedure set_burst_length(burst_length       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= burst_length;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_BURST_LENGTH) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_BURST_LENGTH) = '1');
      tr_if.req(AXI_VHD_SET_BURST_LENGTH) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_BURST_LENGTH) = '0');
    end set_burst_length;

    procedure set_burst_length(burst_length       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(burst_length, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_BURST_LENGTH) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_BURST_LENGTH) = '1');
      tr_if.req(AXI_VHD_SET_BURST_LENGTH) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_BURST_LENGTH) = '0');
    end set_burst_length;

    procedure set_burst_length(burst_length       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(burst_length, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_BURST_LENGTH) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_BURST_LENGTH) = '1');
      tr_if.req(AXI_VHD_SET_BURST_LENGTH) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_BURST_LENGTH) = '0');
    end set_burst_length;

    procedure get_burst_length(burst_length       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_BURST_LENGTH) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_BURST_LENGTH) = '1');
      tr_if.req(AXI_VHD_GET_BURST_LENGTH) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_BURST_LENGTH) = '0');
      burst_length := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max;
    end get_burst_length;

    procedure get_burst_length(burst_length       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_BURST_LENGTH) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_BURST_LENGTH) = '1');
      tr_if.req(AXI_VHD_GET_BURST_LENGTH) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_BURST_LENGTH) = '0');
      burst_length := axi_tr_if_local(bfm_id)(path_id).value_max;
    end get_burst_length;

    procedure get_burst_length(burst_length       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_BURST_LENGTH) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_BURST_LENGTH) = '1');
      tr_if.req(AXI_VHD_GET_BURST_LENGTH) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_BURST_LENGTH) = '0');
      burst_length := to_integer(axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max);
    end get_burst_length;

    procedure get_burst_length(burst_length       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_BURST_LENGTH) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_BURST_LENGTH) = '1');
      tr_if.req(AXI_VHD_GET_BURST_LENGTH) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_BURST_LENGTH) = '0');
      burst_length := to_integer(axi_tr_if_local(bfm_id)(path_id).value_max);
    end get_burst_length;

    procedure set_data_words(data_words       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= data_words;
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= data_words;
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= data_words;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= data_words;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(data_words, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(data_words, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(data_words, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(data_words, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure get_data_words(data_words       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_WORDS) = '0');
      data_words := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max;
    end get_data_words;

    procedure get_data_words(data_words       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_WORDS) = '0');
      data_words := axi_tr_if_local(bfm_id)(path_id).value_max;
    end get_data_words;

    procedure get_data_words(data_words       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_WORDS) = '0');
      data_words := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max;
    end get_data_words;

    procedure get_data_words(data_words       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_WORDS) = '0');
      data_words := axi_tr_if_local(bfm_id)(path_id).value_max;
    end get_data_words;

    procedure get_data_words(data_words       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_WORDS) = '0');
      data_words := to_integer(axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max);
    end get_data_words;

    procedure get_data_words(data_words       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_WORDS) = '0');
      data_words := to_integer(axi_tr_if_local(bfm_id)(path_id).value_max);
    end get_data_words;

    procedure get_data_words(data_words       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_WORDS) = '0');
      data_words := to_integer(axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max);
    end get_data_words;

    procedure get_data_words(data_words       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_WORDS) = '0');
      data_words := to_integer(axi_tr_if_local(bfm_id)(path_id).value_max);
    end get_data_words;

    procedure set_write_strobes(write_strobes       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= write_strobes;
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= write_strobes;
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= write_strobes;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= write_strobes;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(write_strobes, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(write_strobes, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(write_strobes, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(write_strobes, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure get_write_strobes(write_strobes       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max;
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := axi_tr_if_local(bfm_id)(path_id).value_max;
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max;
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := axi_tr_if_local(bfm_id)(path_id).value_max;
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := to_integer(axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max);
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := to_integer(axi_tr_if_local(bfm_id)(path_id).value_max);
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := to_integer(axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max);
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := to_integer(axi_tr_if_local(bfm_id)(path_id).value_max);
    end get_write_strobes;

    procedure set_resp(resp       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= resp;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_RESP) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_RESP) = '1');
      tr_if.req(AXI_VHD_SET_RESP) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_RESP) = '0');
    end set_resp;

    procedure set_resp(resp       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= resp;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_RESP) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_RESP) = '1');
      tr_if.req(AXI_VHD_SET_RESP) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_RESP) = '0');
    end set_resp;

    procedure set_resp(resp       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= resp;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_RESP) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_RESP) = '1');
      tr_if.req(AXI_VHD_SET_RESP) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_RESP) = '0');
    end set_resp;

    procedure set_resp(resp       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= resp;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_RESP) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_RESP) = '1');
      tr_if.req(AXI_VHD_SET_RESP) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_RESP) = '0');
    end set_resp;

    procedure get_resp(resp       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_RESP) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_RESP) = '1');
      tr_if.req(AXI_VHD_GET_RESP) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_RESP) = '0');
      resp := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_resp;

    procedure get_resp(resp       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_RESP) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_RESP) = '1');
      tr_if.req(AXI_VHD_GET_RESP) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_RESP) = '0');
      resp := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_resp;

    procedure get_resp(resp       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_RESP) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_RESP) = '1');
      tr_if.req(AXI_VHD_GET_RESP) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_RESP) = '0');
      resp := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_resp;

    procedure get_resp(resp       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_RESP) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_RESP) = '1');
      tr_if.req(AXI_VHD_GET_RESP) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_RESP) = '0');
      resp := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_resp;

    procedure set_addr_user(addr_user       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= addr_user;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ADDR_USER) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ADDR_USER) = '1');
      tr_if.req(AXI_VHD_SET_ADDR_USER) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ADDR_USER) = '0');
    end set_addr_user;

    procedure set_addr_user(addr_user       : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= addr_user;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ADDR_USER) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ADDR_USER) = '1');
      tr_if.req(AXI_VHD_SET_ADDR_USER) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ADDR_USER) = '0');
    end set_addr_user;

    procedure set_addr_user(addr_user       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(addr_user, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ADDR_USER) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ADDR_USER) = '1');
      tr_if.req(AXI_VHD_SET_ADDR_USER) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ADDR_USER) = '0');
    end set_addr_user;

    procedure set_addr_user(addr_user       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(addr_user, AXI_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ADDR_USER) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ADDR_USER) = '1');
      tr_if.req(AXI_VHD_SET_ADDR_USER) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ADDR_USER) = '0');
    end set_addr_user;

    procedure get_addr_user(addr_user       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ADDR_USER) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ADDR_USER) = '1');
      tr_if.req(AXI_VHD_GET_ADDR_USER) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ADDR_USER) = '0');
      addr_user := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max;
    end get_addr_user;

    procedure get_addr_user(addr_user       : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ADDR_USER) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ADDR_USER) = '1');
      tr_if.req(AXI_VHD_GET_ADDR_USER) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ADDR_USER) = '0');
      addr_user := axi_tr_if_local(bfm_id)(path_id).value_max;
    end get_addr_user;

    procedure get_addr_user(addr_user       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ADDR_USER) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ADDR_USER) = '1');
      tr_if.req(AXI_VHD_GET_ADDR_USER) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ADDR_USER) = '0');
      addr_user := to_integer(axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max);
    end get_addr_user;

    procedure get_addr_user(addr_user       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ADDR_USER) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ADDR_USER) = '1');
      tr_if.req(AXI_VHD_GET_ADDR_USER) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ADDR_USER) = '0');
      addr_user := to_integer(axi_tr_if_local(bfm_id)(path_id).value_max);
    end get_addr_user;

    procedure set_read_or_write(read_or_write       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= read_or_write;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_READ_OR_WRITE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_READ_OR_WRITE) = '1');
      tr_if.req(AXI_VHD_SET_READ_OR_WRITE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_READ_OR_WRITE) = '0');
    end set_read_or_write;

    procedure set_read_or_write(read_or_write       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= read_or_write;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_READ_OR_WRITE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_READ_OR_WRITE) = '1');
      tr_if.req(AXI_VHD_SET_READ_OR_WRITE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_READ_OR_WRITE) = '0');
    end set_read_or_write;

    procedure get_read_or_write(read_or_write       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_READ_OR_WRITE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_READ_OR_WRITE) = '1');
      tr_if.req(AXI_VHD_GET_READ_OR_WRITE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_READ_OR_WRITE) = '0');
      read_or_write := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_read_or_write;

    procedure get_read_or_write(read_or_write       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_READ_OR_WRITE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_READ_OR_WRITE) = '1');
      tr_if.req(AXI_VHD_GET_READ_OR_WRITE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_READ_OR_WRITE) = '0');
      read_or_write := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_read_or_write;

    procedure set_address_valid_delay(address_valid_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= address_valid_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ADDRESS_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ADDRESS_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_ADDRESS_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ADDRESS_VALID_DELAY) = '0');
    end set_address_valid_delay;

    procedure set_address_valid_delay(address_valid_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= address_valid_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ADDRESS_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ADDRESS_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_ADDRESS_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ADDRESS_VALID_DELAY) = '0');
    end set_address_valid_delay;

    procedure get_address_valid_delay(address_valid_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ADDRESS_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ADDRESS_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_ADDRESS_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ADDRESS_VALID_DELAY) = '0');
      address_valid_delay := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_address_valid_delay;

    procedure get_address_valid_delay(address_valid_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ADDRESS_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ADDRESS_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_ADDRESS_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ADDRESS_VALID_DELAY) = '0');
      address_valid_delay := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_address_valid_delay;

    procedure set_data_valid_delay(data_valid_delay       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_valid_delay;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_DATA_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_VALID_DELAY) = '0');
    end set_data_valid_delay;

    procedure set_data_valid_delay(data_valid_delay       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_valid_delay;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_DATA_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_VALID_DELAY) = '0');
    end set_data_valid_delay;

    procedure set_data_valid_delay(data_valid_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_valid_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_DATA_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_VALID_DELAY) = '0');
    end set_data_valid_delay;

    procedure set_data_valid_delay(data_valid_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_valid_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_DATA_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_VALID_DELAY) = '0');
    end set_data_valid_delay;

    procedure get_data_valid_delay(data_valid_delay       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_DATA_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_VALID_DELAY) = '0');
      data_valid_delay := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_data_valid_delay;

    procedure get_data_valid_delay(data_valid_delay       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_DATA_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_VALID_DELAY) = '0');
      data_valid_delay := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_data_valid_delay;

    procedure get_data_valid_delay(data_valid_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_DATA_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_VALID_DELAY) = '0');
      data_valid_delay := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_data_valid_delay;

    procedure get_data_valid_delay(data_valid_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_DATA_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_VALID_DELAY) = '0');
      data_valid_delay := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_data_valid_delay;

    procedure set_write_response_valid_delay(write_response_valid_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= write_response_valid_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_RESPONSE_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_RESPONSE_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_RESPONSE_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_RESPONSE_VALID_DELAY) = '0');
    end set_write_response_valid_delay;

    procedure set_write_response_valid_delay(write_response_valid_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= write_response_valid_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_RESPONSE_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_RESPONSE_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_RESPONSE_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_RESPONSE_VALID_DELAY) = '0');
    end set_write_response_valid_delay;

    procedure get_write_response_valid_delay(write_response_valid_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_RESPONSE_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_RESPONSE_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_RESPONSE_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_RESPONSE_VALID_DELAY) = '0');
      write_response_valid_delay := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_write_response_valid_delay;

    procedure get_write_response_valid_delay(write_response_valid_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_RESPONSE_VALID_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_RESPONSE_VALID_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_RESPONSE_VALID_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_RESPONSE_VALID_DELAY) = '0');
      write_response_valid_delay := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_write_response_valid_delay;

    procedure set_address_ready_delay(address_ready_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= address_ready_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ADDRESS_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ADDRESS_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_ADDRESS_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_ADDRESS_READY_DELAY) = '0');
    end set_address_ready_delay;

    procedure set_address_ready_delay(address_ready_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= address_ready_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_ADDRESS_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ADDRESS_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_ADDRESS_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_ADDRESS_READY_DELAY) = '0');
    end set_address_ready_delay;

    procedure get_address_ready_delay(address_ready_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ADDRESS_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ADDRESS_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_ADDRESS_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_ADDRESS_READY_DELAY) = '0');
      address_ready_delay := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_address_ready_delay;

    procedure get_address_ready_delay(address_ready_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_ADDRESS_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ADDRESS_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_ADDRESS_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_ADDRESS_READY_DELAY) = '0');
      address_ready_delay := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_address_ready_delay;

    procedure set_data_ready_delay(data_ready_delay       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_ready_delay;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_DATA_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_READY_DELAY) = '0');
    end set_data_ready_delay;

    procedure set_data_ready_delay(data_ready_delay       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_ready_delay;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_DATA_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_READY_DELAY) = '0');
    end set_data_ready_delay;

    procedure set_data_ready_delay(data_ready_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_ready_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_DATA_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_READY_DELAY) = '0');
    end set_data_ready_delay;

    procedure set_data_ready_delay(data_ready_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_ready_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_DATA_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_READY_DELAY) = '0');
    end set_data_ready_delay;

    procedure get_data_ready_delay(data_ready_delay       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_DATA_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_READY_DELAY) = '0');
      data_ready_delay := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_data_ready_delay;

    procedure get_data_ready_delay(data_ready_delay       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_DATA_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_READY_DELAY) = '0');
      data_ready_delay := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_data_ready_delay;

    procedure get_data_ready_delay(data_ready_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_DATA_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_READY_DELAY) = '0');
      data_ready_delay := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_data_ready_delay;

    procedure get_data_ready_delay(data_ready_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_DATA_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_READY_DELAY) = '0');
      data_ready_delay := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_data_ready_delay;

    procedure set_write_response_ready_delay(write_response_ready_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= write_response_ready_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_RESPONSE_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_RESPONSE_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_RESPONSE_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_RESPONSE_READY_DELAY) = '0');
    end set_write_response_ready_delay;

    procedure set_write_response_ready_delay(write_response_ready_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= write_response_ready_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_RESPONSE_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_RESPONSE_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_RESPONSE_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_RESPONSE_READY_DELAY) = '0');
    end set_write_response_ready_delay;

    procedure get_write_response_ready_delay(write_response_ready_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_RESPONSE_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_RESPONSE_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_RESPONSE_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_RESPONSE_READY_DELAY) = '0');
      write_response_ready_delay := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_write_response_ready_delay;

    procedure get_write_response_ready_delay(write_response_ready_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_RESPONSE_READY_DELAY) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_RESPONSE_READY_DELAY) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_RESPONSE_READY_DELAY) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_RESPONSE_READY_DELAY) = '0');
      write_response_ready_delay := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_write_response_ready_delay;

    procedure set_gen_write_strobes(gen_write_strobes       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= gen_write_strobes;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_GEN_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_GEN_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_SET_GEN_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_GEN_WRITE_STROBES) = '0');
    end set_gen_write_strobes;

    procedure set_gen_write_strobes(gen_write_strobes       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= gen_write_strobes;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_GEN_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_GEN_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_SET_GEN_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_GEN_WRITE_STROBES) = '0');
    end set_gen_write_strobes;

    procedure get_gen_write_strobes(gen_write_strobes       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_GEN_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_GEN_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_GET_GEN_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_GEN_WRITE_STROBES) = '0');
      gen_write_strobes := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_gen_write_strobes;

    procedure get_gen_write_strobes(gen_write_strobes       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_GEN_WRITE_STROBES) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_GEN_WRITE_STROBES) = '1');
      tr_if.req(AXI_VHD_GET_GEN_WRITE_STROBES) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_GEN_WRITE_STROBES) = '0');
      gen_write_strobes := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_gen_write_strobes;

    procedure set_operation_mode(operation_mode       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= operation_mode;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_OPERATION_MODE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_OPERATION_MODE) = '1');
      tr_if.req(AXI_VHD_SET_OPERATION_MODE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_OPERATION_MODE) = '0');
    end set_operation_mode;

    procedure set_operation_mode(operation_mode       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= operation_mode;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_OPERATION_MODE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_OPERATION_MODE) = '1');
      tr_if.req(AXI_VHD_SET_OPERATION_MODE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_OPERATION_MODE) = '0');
    end set_operation_mode;

    procedure get_operation_mode(operation_mode       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_OPERATION_MODE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_OPERATION_MODE) = '1');
      tr_if.req(AXI_VHD_GET_OPERATION_MODE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_OPERATION_MODE) = '0');
      operation_mode := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_operation_mode;

    procedure get_operation_mode(operation_mode       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_OPERATION_MODE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_OPERATION_MODE) = '1');
      tr_if.req(AXI_VHD_GET_OPERATION_MODE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_OPERATION_MODE) = '0');
      operation_mode := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_operation_mode;

    procedure set_delay_mode(delay_mode       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= delay_mode;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DELAY_MODE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DELAY_MODE) = '1');
      tr_if.req(AXI_VHD_SET_DELAY_MODE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DELAY_MODE) = '0');
    end set_delay_mode;

    procedure set_delay_mode(delay_mode       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= delay_mode;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DELAY_MODE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DELAY_MODE) = '1');
      tr_if.req(AXI_VHD_SET_DELAY_MODE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DELAY_MODE) = '0');
    end set_delay_mode;

    procedure get_delay_mode(delay_mode       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DELAY_MODE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DELAY_MODE) = '1');
      tr_if.req(AXI_VHD_GET_DELAY_MODE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DELAY_MODE) = '0');
      delay_mode := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_delay_mode;

    procedure get_delay_mode(delay_mode       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DELAY_MODE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DELAY_MODE) = '1');
      tr_if.req(AXI_VHD_GET_DELAY_MODE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DELAY_MODE) = '0');
      delay_mode := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_delay_mode;

    procedure set_write_data_mode(write_data_mode       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= write_data_mode;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_DATA_MODE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_DATA_MODE) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_DATA_MODE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_WRITE_DATA_MODE) = '0');
    end set_write_data_mode;

    procedure set_write_data_mode(write_data_mode       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= write_data_mode;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_WRITE_DATA_MODE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_DATA_MODE) = '1');
      tr_if.req(AXI_VHD_SET_WRITE_DATA_MODE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_WRITE_DATA_MODE) = '0');
    end set_write_data_mode;

    procedure get_write_data_mode(write_data_mode       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_DATA_MODE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_DATA_MODE) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_DATA_MODE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_DATA_MODE) = '0');
      write_data_mode := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_write_data_mode;

    procedure get_write_data_mode(write_data_mode       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_WRITE_DATA_MODE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_DATA_MODE) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_DATA_MODE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_DATA_MODE) = '0');
      write_data_mode := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_write_data_mode;

    procedure set_data_beat_done(data_beat_done       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_beat_done;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_BEAT_DONE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI_VHD_SET_DATA_BEAT_DONE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_BEAT_DONE) = '0');
    end set_data_beat_done;

    procedure set_data_beat_done(data_beat_done       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_beat_done;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_BEAT_DONE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI_VHD_SET_DATA_BEAT_DONE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_BEAT_DONE) = '0');
    end set_data_beat_done;

    procedure set_data_beat_done(data_beat_done       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_beat_done;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_BEAT_DONE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI_VHD_SET_DATA_BEAT_DONE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_DATA_BEAT_DONE) = '0');
    end set_data_beat_done;

    procedure set_data_beat_done(data_beat_done       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_beat_done;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_DATA_BEAT_DONE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI_VHD_SET_DATA_BEAT_DONE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_DATA_BEAT_DONE) = '0');
    end set_data_beat_done;

    procedure get_data_beat_done(data_beat_done       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_BEAT_DONE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI_VHD_GET_DATA_BEAT_DONE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_BEAT_DONE) = '0');
      data_beat_done := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_data_beat_done;

    procedure get_data_beat_done(data_beat_done       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_BEAT_DONE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI_VHD_GET_DATA_BEAT_DONE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_BEAT_DONE) = '0');
      data_beat_done := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_data_beat_done;

    procedure get_data_beat_done(data_beat_done       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_BEAT_DONE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI_VHD_GET_DATA_BEAT_DONE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_DATA_BEAT_DONE) = '0');
      data_beat_done := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_data_beat_done;

    procedure get_data_beat_done(data_beat_done       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_DATA_BEAT_DONE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI_VHD_GET_DATA_BEAT_DONE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_DATA_BEAT_DONE) = '0');
      data_beat_done := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_data_beat_done;

    procedure set_transaction_done(transaction_done       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= transaction_done;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_TRANSACTION_DONE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_TRANSACTION_DONE) = '1');
      tr_if.req(AXI_VHD_SET_TRANSACTION_DONE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_TRANSACTION_DONE) = '0');
    end set_transaction_done;

    procedure set_transaction_done(transaction_done       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= transaction_done;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI_VHD_SET_TRANSACTION_DONE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_TRANSACTION_DONE) = '1');
      tr_if.req(AXI_VHD_SET_TRANSACTION_DONE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_TRANSACTION_DONE) = '0');
    end set_transaction_done;

    procedure get_transaction_done(transaction_done       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_TRANSACTION_DONE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_TRANSACTION_DONE) = '1');
      tr_if.req(AXI_VHD_GET_TRANSACTION_DONE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_TRANSACTION_DONE) = '0');
      transaction_done := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_transaction_done;

    procedure get_transaction_done(transaction_done       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi_path_t;
                          signal tr_if       : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI_VHD_GET_TRANSACTION_DONE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_TRANSACTION_DONE) = '1');
      tr_if.req(AXI_VHD_GET_TRANSACTION_DONE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_TRANSACTION_DONE) = '0');
      transaction_done := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_transaction_done;

    procedure execute_transaction(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_EXECUTE_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_TRANSACTION) = '0');
    end execute_transaction;

    procedure execute_transaction(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_EXECUTE_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_TRANSACTION) = '0');
    end execute_transaction;

    procedure get_read_data_burst(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_READ_DATA_BURST) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_READ_DATA_BURST) = '1');
      tr_if.req(AXI_VHD_GET_READ_DATA_BURST) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_READ_DATA_BURST) = '0');
    end get_read_data_burst;

    procedure get_read_data_burst(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_READ_DATA_BURST) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_READ_DATA_BURST) = '1');
      tr_if.req(AXI_VHD_GET_READ_DATA_BURST) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_READ_DATA_BURST) = '0');
    end get_read_data_burst;

    procedure execute_write_data_burst(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_WRITE_DATA_BURST) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_WRITE_DATA_BURST) = '1');
      tr_if.req(AXI_VHD_EXECUTE_WRITE_DATA_BURST) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_WRITE_DATA_BURST) = '0');
    end execute_write_data_burst;

    procedure execute_write_data_burst(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_WRITE_DATA_BURST) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_WRITE_DATA_BURST) = '1');
      tr_if.req(AXI_VHD_EXECUTE_WRITE_DATA_BURST) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_WRITE_DATA_BURST) = '0');
    end execute_write_data_burst;

    procedure execute_read_addr_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_READ_ADDR_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_READ_ADDR_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_READ_ADDR_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_READ_ADDR_PHASE) = '0');
    end execute_read_addr_phase;

    procedure execute_read_addr_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_READ_ADDR_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_READ_ADDR_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_READ_ADDR_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_READ_ADDR_PHASE) = '0');
    end execute_read_addr_phase;

    procedure get_read_data_phase(transaction_id  : in integer;
                              index           : in  integer; 
                              last            : out integer; 
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI_VHD_GET_READ_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_READ_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_READ_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_READ_DATA_PHASE) = '0');
      last           := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_read_data_phase;

    procedure get_read_data_phase(transaction_id  : in integer;
                              index           : in  integer; 
                              last            : out integer; 
                              bfm_id          : in  integer; 
                              path_id         : in  axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI_VHD_GET_READ_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_READ_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_READ_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_READ_DATA_PHASE) = '0');
      last           := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_read_data_phase;

    procedure get_read_data_phase(transaction_id  : in integer;
                              last            : out integer; 
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_READ_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_READ_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_READ_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_READ_DATA_PHASE) = '0');
      last           := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_read_data_phase;

    procedure get_read_data_phase(transaction_id  : in integer;
                              last            : out integer; 
                              bfm_id          : in  integer; 
                              path_id         : in  axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_READ_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_READ_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_READ_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_READ_DATA_PHASE) = '0');
      last           := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_read_data_phase;

    procedure execute_write_addr_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_WRITE_ADDR_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_WRITE_ADDR_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_WRITE_ADDR_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_WRITE_ADDR_PHASE) = '0');
    end execute_write_addr_phase;

    procedure execute_write_addr_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_WRITE_ADDR_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_WRITE_ADDR_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_WRITE_ADDR_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_WRITE_ADDR_PHASE) = '0');
    end execute_write_addr_phase;

    procedure execute_write_data_phase(transaction_id  : in integer;
                              index           : in  integer; 
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) = '0');
    end execute_write_data_phase;

    procedure execute_write_data_phase(transaction_id  : in integer;
                              index           : in  integer; 
                              bfm_id          : in  integer; 
                              path_id         : in  axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) = '0');
    end execute_write_data_phase;

    procedure execute_write_data_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) = '0');
    end execute_write_data_phase;

    procedure execute_write_data_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_WRITE_DATA_PHASE) = '0');
    end execute_write_data_phase;

    procedure get_write_response_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_WRITE_RESPONSE_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_RESPONSE_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_RESPONSE_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_RESPONSE_PHASE) = '0');
    end get_write_response_phase;

    procedure get_write_response_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_WRITE_RESPONSE_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_RESPONSE_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_RESPONSE_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_RESPONSE_PHASE) = '0');
    end get_write_response_phase;

    procedure create_slave_transaction(transaction_id  : out integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_CREATE_SLAVE_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_SLAVE_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_SLAVE_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_SLAVE_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(AXI_PATH_0).transaction_id;
    end create_slave_transaction;

    procedure create_slave_transaction(transaction_id  : out integer;
                              bfm_id          : in integer;
                              path_id         : in axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_CREATE_SLAVE_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_SLAVE_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_SLAVE_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_SLAVE_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_slave_transaction;

    procedure execute_read_data_burst(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_READ_DATA_BURST) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_READ_DATA_BURST) = '1');
      tr_if.req(AXI_VHD_EXECUTE_READ_DATA_BURST) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_READ_DATA_BURST) = '0');
    end execute_read_data_burst;

    procedure execute_read_data_burst(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_READ_DATA_BURST) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_READ_DATA_BURST) = '1');
      tr_if.req(AXI_VHD_EXECUTE_READ_DATA_BURST) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_READ_DATA_BURST) = '0');
    end execute_read_data_burst;

    procedure get_write_data_burst(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_WRITE_DATA_BURST) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_DATA_BURST) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_DATA_BURST) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_DATA_BURST) = '0');
    end get_write_data_burst;

    procedure get_write_data_burst(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_WRITE_DATA_BURST) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_DATA_BURST) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_DATA_BURST) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_DATA_BURST) = '0');
    end get_write_data_burst;

    procedure get_read_addr_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_READ_ADDR_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_READ_ADDR_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_READ_ADDR_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_READ_ADDR_PHASE) = '0');
    end get_read_addr_phase;

    procedure get_read_addr_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_READ_ADDR_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_READ_ADDR_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_READ_ADDR_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_READ_ADDR_PHASE) = '0');
    end get_read_addr_phase;

    procedure execute_read_data_phase(transaction_id  : in integer;
                              index           : in integer; 
                              bfm_id          : in integer;
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI_VHD_EXECUTE_READ_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_READ_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_READ_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_READ_DATA_PHASE) = '0');
    end execute_read_data_phase;

    procedure execute_read_data_phase(transaction_id  : in integer;
                              index           : in integer; 
                              bfm_id          : in integer;
                              path_id         : in axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI_VHD_EXECUTE_READ_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_READ_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_READ_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_READ_DATA_PHASE) = '0');
    end execute_read_data_phase;

    procedure execute_read_data_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_READ_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_READ_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_READ_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_READ_DATA_PHASE) = '0');
    end execute_read_data_phase;

    procedure execute_read_data_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_READ_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_READ_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_READ_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_READ_DATA_PHASE) = '0');
    end execute_read_data_phase;

    procedure get_write_addr_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_WRITE_ADDR_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_ADDR_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_ADDR_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_ADDR_PHASE) = '0');
    end get_write_addr_phase;

    procedure get_write_addr_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_WRITE_ADDR_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_ADDR_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_ADDR_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_ADDR_PHASE) = '0');
    end get_write_addr_phase;

    procedure get_write_data_phase(transaction_id  : in integer;
                              index           : in integer; 
                              last            : out integer; 
                              bfm_id          : in integer;
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI_VHD_GET_WRITE_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_DATA_PHASE) = '0');
      last           := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_write_data_phase;

    procedure get_write_data_phase(transaction_id  : in integer;
                              index           : in integer; 
                              last            : out integer; 
                              bfm_id          : in integer;
                              path_id         : in axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI_VHD_GET_WRITE_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_DATA_PHASE) = '0');
      last           := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_write_data_phase;

    procedure get_write_data_phase(transaction_id  : in integer;
                              last            : out integer; 
                              bfm_id          : in integer;
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_WRITE_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_DATA_PHASE) = '0');
      last           := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
    end get_write_data_phase;

    procedure get_write_data_phase(transaction_id  : in integer;
                              last            : out integer; 
                              bfm_id          : in integer;
                              path_id         : in axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_WRITE_DATA_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_DATA_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_DATA_PHASE) = '0');
      last           := axi_tr_if_local(bfm_id)(path_id).value_0;
    end get_write_data_phase;

    procedure execute_write_response_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_WRITE_RESPONSE_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_WRITE_RESPONSE_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_WRITE_RESPONSE_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_EXECUTE_WRITE_RESPONSE_PHASE) = '0');
    end execute_write_response_phase;

    procedure execute_write_response_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_EXECUTE_WRITE_RESPONSE_PHASE) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_WRITE_RESPONSE_PHASE) = '1');
      tr_if.req(AXI_VHD_EXECUTE_WRITE_RESPONSE_PHASE) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_EXECUTE_WRITE_RESPONSE_PHASE) = '0');
    end execute_write_response_phase;

    procedure create_monitor_transaction(transaction_id  : out integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_CREATE_MONITOR_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_MONITOR_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_MONITOR_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_CREATE_MONITOR_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(AXI_PATH_0).transaction_id;
    end create_monitor_transaction;

    procedure create_monitor_transaction(transaction_id  : out integer;
                              bfm_id          : in integer;
                              path_id         : in axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_CREATE_MONITOR_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_MONITOR_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_CREATE_MONITOR_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_CREATE_MONITOR_TRANSACTION) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_monitor_transaction;

    procedure get_rw_transaction(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_RW_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_RW_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_GET_RW_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_RW_TRANSACTION) = '0');
    end get_rw_transaction;

    procedure get_rw_transaction(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi_path_t; 
                              signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI_VHD_GET_RW_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_RW_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_GET_RW_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_RW_TRANSACTION) = '0');
    end get_rw_transaction;

    procedure push_transaction_id(transaction_id  : in integer;
                                  queue_id        : in integer;
                                  bfm_id          : in integer; 
                                  signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= queue_id;
      tr_if.req(AXI_VHD_PUSH_TRANSACTION_ID) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_PUSH_TRANSACTION_ID) = '1');
      tr_if.req(AXI_VHD_PUSH_TRANSACTION_ID) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_PUSH_TRANSACTION_ID) = '0');
    end push_transaction_id;

    procedure push_transaction_id(transaction_id  : in integer;
                                  queue_id        : in integer;
                                  bfm_id          : in integer; 
                                  path_id         : in axi_path_t; 
                                  signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= queue_id;
      tr_if.req(AXI_VHD_PUSH_TRANSACTION_ID) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_PUSH_TRANSACTION_ID) = '1');
      tr_if.req(AXI_VHD_PUSH_TRANSACTION_ID) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_PUSH_TRANSACTION_ID) = '0');
    end push_transaction_id;

    procedure pop_transaction_id(transaction_id  : out integer;
                                 queue_id        : in integer;
                                 bfm_id          : in integer; 
                                 signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= queue_id;
      tr_if.req(AXI_VHD_POP_TRANSACTION_ID) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_POP_TRANSACTION_ID) = '1');
      tr_if.req(AXI_VHD_POP_TRANSACTION_ID) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_POP_TRANSACTION_ID) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(AXI_PATH_0).transaction_id;
    end pop_transaction_id;

    procedure pop_transaction_id(transaction_id  : out integer;
                                 queue_id        : in integer;
                                 bfm_id          : in integer; 
                                 path_id         : in axi_path_t;
                                 signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= queue_id;
      tr_if.req(AXI_VHD_POP_TRANSACTION_ID) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_POP_TRANSACTION_ID) = '1');
      tr_if.req(AXI_VHD_POP_TRANSACTION_ID) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_POP_TRANSACTION_ID) = '0');
      transaction_id := axi_tr_if_local(bfm_id)(path_id).transaction_id;
    end pop_transaction_id;

    procedure get_write_addr_data(transaction_id  : in integer;
                                  index           : in integer;
                                  byte_index      : in integer;
                                  dynamic_size    : out integer;
                                  addr            : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                                  data            : out std_logic_vector(7 downto 0);
                                  bfm_id          : in integer;
                                  signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= index;
      tr_if.value_1 <= byte_index;
      tr_if.req(AXI_VHD_GET_WRITE_ADDR_DATA) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_ADDR_DATA) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_ADDR_DATA) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_WRITE_ADDR_DATA) = '0');
      dynamic_size := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
      addr := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max;
      data := conv_std_logic_vector(axi_tr_if_local(bfm_id)(AXI_PATH_0).value_1, 8);
    end get_write_addr_data;

    procedure get_write_addr_data(transaction_id  : in integer;
                                  index           : in integer;
                                  byte_index      : in integer;
                                  dynamic_size    : out integer;
                                  addr            : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                                  data            : out std_logic_vector(7 downto 0);
                                  bfm_id          : in integer;
                                  path_id         : in axi_path_t; 
                                  signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= index;
      tr_if.value_1 <= byte_index;
      tr_if.req(AXI_VHD_GET_WRITE_ADDR_DATA) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_ADDR_DATA) = '1');
      tr_if.req(AXI_VHD_GET_WRITE_ADDR_DATA) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_WRITE_ADDR_DATA) = '0');
      dynamic_size := axi_tr_if_local(bfm_id)(path_id).value_0;
      addr := axi_tr_if_local(bfm_id)(path_id).value_max;
      data := conv_std_logic_vector(axi_tr_if_local(bfm_id)(path_id).value_1, 8);
    end get_write_addr_data;

    procedure get_read_addr(transaction_id  : in integer;
                                  index           : in integer;
                            byte_index      : in integer;
                            dynamic_size    : out integer;
                            addr            : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                            bfm_id          : in integer;
                            signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= index;
      tr_if.value_1 <= byte_index;
      tr_if.req(AXI_VHD_GET_READ_ADDR) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_READ_ADDR) = '1');
      tr_if.req(AXI_VHD_GET_READ_ADDR) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_GET_READ_ADDR) = '0');
      dynamic_size := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_0;
      addr := axi_tr_if_local(bfm_id)(AXI_PATH_0).value_max;
    end get_read_addr;

    procedure get_read_addr(transaction_id  : in integer;
                                  index           : in integer;
                            byte_index      : in integer;
                            dynamic_size    : out integer;
                            addr            : out std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                            bfm_id          : in integer;
                            path_id         : in axi_path_t; 
                            signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= index;
      tr_if.value_1 <= byte_index;
      tr_if.req(AXI_VHD_GET_READ_ADDR) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_READ_ADDR) = '1');
      tr_if.req(AXI_VHD_GET_READ_ADDR) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_GET_READ_ADDR) = '0');
      dynamic_size := axi_tr_if_local(bfm_id)(path_id).value_0;
      addr := axi_tr_if_local(bfm_id)(path_id).value_max;
    end get_read_addr;

    procedure set_read_data(transaction_id  : in integer;
                                  index           : in integer;
                            byte_index      : in integer;
                            dynamic_size    : in integer;
                            addr            : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                            data            : in std_logic_vector(7 downto 0);
                            bfm_id          : in integer;
                            signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= index;
      tr_if.value_1 <= byte_index;
      tr_if.value_2 <= dynamic_size;
      tr_if.value_max <= addr;
      tr_if.value_3 <= to_integer(data);
      tr_if.req(AXI_VHD_SET_READ_DATA) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_READ_DATA) = '1');
      tr_if.req(AXI_VHD_SET_READ_DATA) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_SET_READ_DATA) = '0');
    end set_read_data;

    procedure set_read_data(transaction_id  : in integer;
                                  index           : in integer;
                            byte_index      : in integer;
                            dynamic_size    : in integer;
                            addr            : in std_logic_vector(AXI_MAX_BIT_SIZE-1 downto 0);
                            data            : in std_logic_vector(7 downto 0);
                            bfm_id          : in integer;
                            path_id         : in axi_path_t; 
                            signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= index;
      tr_if.value_1 <= byte_index;
      tr_if.value_2 <= dynamic_size;
      tr_if.value_max <= addr;
      tr_if.value_3 <= to_integer(data);
      tr_if.req(AXI_VHD_SET_READ_DATA) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_READ_DATA) = '1');
      tr_if.req(AXI_VHD_SET_READ_DATA) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_SET_READ_DATA) = '0');
    end set_read_data;

    procedure print(transaction_id  : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= 0;
      tr_if.req(AXI_VHD_PRINT) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_PRINT) = '1');
      tr_if.req(AXI_VHD_PRINT) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_PRINT) = '0');
    end print;

    procedure print(transaction_id  : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi_path_t; 
                    signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= 0;
      tr_if.req(AXI_VHD_PRINT) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_PRINT) = '1');
      tr_if.req(AXI_VHD_PRINT) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_PRINT) = '0');
    end print;

    procedure print(transaction_id  : in integer;
                    print_delays    : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= print_delays;
      tr_if.req(AXI_VHD_PRINT) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_PRINT) = '1');
      tr_if.req(AXI_VHD_PRINT) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_PRINT) = '0');
    end print;

    procedure print(transaction_id  : in integer;
                    print_delays    : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi_path_t; 
                    signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= print_delays;
      tr_if.req(AXI_VHD_PRINT) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_PRINT) = '1');
      tr_if.req(AXI_VHD_PRINT) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_PRINT) = '0');
    end print;

    procedure destruct_transaction(transaction_id  : in integer;
                                   bfm_id          : in integer;
                                   signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.req(AXI_VHD_DESTRUCT_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_DESTRUCT_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_DESTRUCT_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_DESTRUCT_TRANSACTION) = '0');
    end destruct_transaction;

    procedure destruct_transaction(transaction_id  : in integer;
                                   bfm_id          : in integer;
                                   path_id         : in axi_path_t; 
                                   signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.req(AXI_VHD_DESTRUCT_TRANSACTION) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_DESTRUCT_TRANSACTION) = '1');
      tr_if.req(AXI_VHD_DESTRUCT_TRANSACTION) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_DESTRUCT_TRANSACTION) = '0');
    end destruct_transaction;

    procedure wait_on(phase           : in integer;
                      bfm_id          : in integer;
                      signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= phase;
      tr_if.value_1 <= 1;
      tr_if.req(AXI_VHD_WAIT_ON) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_WAIT_ON) = '1');
      tr_if.req(AXI_VHD_WAIT_ON) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_WAIT_ON) = '0');
    end wait_on;

    procedure wait_on(phase           : in integer;
                      bfm_id          : in integer;
                      path_id         : in axi_path_t; 
                      signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= phase;
      tr_if.value_1 <= 1;
      tr_if.req(AXI_VHD_WAIT_ON) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_WAIT_ON) = '1');
      tr_if.req(AXI_VHD_WAIT_ON) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_WAIT_ON) = '0');
    end wait_on;

    procedure wait_on(phase           : in integer;
                      count           : in integer;
                      bfm_id          : in integer;
                      signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= phase;
      tr_if.value_1 <= count;
      tr_if.req(AXI_VHD_WAIT_ON) <= '1';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_WAIT_ON) = '1');
      tr_if.req(AXI_VHD_WAIT_ON) <= '0';
      wait until (axi_tr_if_local(bfm_id)(AXI_PATH_0).ack(AXI_VHD_WAIT_ON) = '0');
    end wait_on;

    procedure wait_on(phase           : in integer;
                      count           : in integer;
                      bfm_id          : in integer;
                      path_id         : in axi_path_t; 
                      signal tr_if    : inout axi_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= phase;
      tr_if.value_1 <= count;
      tr_if.req(AXI_VHD_WAIT_ON) <= '1';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_WAIT_ON) = '1');
      tr_if.req(AXI_VHD_WAIT_ON) <= '0';
      wait until (axi_tr_if_local(bfm_id)(path_id).ack(AXI_VHD_WAIT_ON) = '0');
    end wait_on;

end mgc_axi_bfm_pkg;
