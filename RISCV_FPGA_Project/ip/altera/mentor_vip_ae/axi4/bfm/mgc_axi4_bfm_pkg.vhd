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

-- Title: mgc_axi4_bfm_pkg
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
package mgc_axi4_bfm_pkg is

    -- axi4_prot_e
    --------------------------------------------------------------------------------
    --  Protection type mapped to the AxPROT signals (SPEC3(A4.7)))
    --  
    -- AXI4_NORM_SEC_DATA - Normal/Secure/Data
    -- AXI4_PRIV_SEC_DATA - Privileged/Secure/Data
    -- AXI4_NORM_NONSEC_DATA - Normal/Non-secure/Data
    -- AXI4_PRIV_NONSEC_DATA - Privileged/Non-secure/Data
    -- AXI4_NORM_SEC_INST - Normal/Secure/Instruction
    -- AXI4_PRIV_SEC_INST - Privileged/Secure/Instruction
    -- AXI4_NORM_NONSEC_INST - Normal/Non-secure/Instruction
    -- AXI4_PRIV_NONSEC_INST - Privileged/Non-secure/Instruction
    --  
    --------------------------------------------------------------------------------
    constant AXI4_NORM_SEC_DATA    : integer := 0;
    constant AXI4_PRIV_SEC_DATA    : integer := 1;
    constant AXI4_NORM_NONSEC_DATA : integer := 2;
    constant AXI4_PRIV_NONSEC_DATA : integer := 3;
    constant AXI4_NORM_SEC_INST    : integer := 4;
    constant AXI4_PRIV_SEC_INST    : integer := 5;
    constant AXI4_NORM_NONSEC_INST : integer := 6;
    constant AXI4_PRIV_NONSEC_INST : integer := 7;

    -- axi4_response_e
    --------------------------------------------------------------------------------
    --  Response type mapped to the xRESP signals (SPEC3(A3.4.4))
    -- 
    -- AXI4_OKAY   - Normal access has been successful, or exclusive access has failed (SPEC3(A3.4.4)).
    -- AXI4_EXOKAY - Exclusive acess okay (SPEC3(A3.4.4)) OR Reserved value if QVIP BFM is configured as axi4lite interface (SPECL(B1.1.1)).
    -- AXI4_SLVERR - Slave signals an error to the originating master.
    -- AXI4_DECERR - Decode error (generally used to indicate that there is no slave at the transaction address).
    --  
    --------------------------------------------------------------------------------
    constant AXI4_OKAY   : integer := 0;
    constant AXI4_EXOKAY : integer := 1;
    constant AXI4_SLVERR : integer := 2;
    constant AXI4_DECERR : integer := 3;

    -- axi4_rw_e
    --------------------------------------------------------------------------------
    --  This is used as the <axi4_master_rw_transaction::read_or_write> argument to the <axi4_master_rw_transaction> transaction to indicate read or write.
    -- 
    -- AXI4_TRANS_READ - read transaction
    -- AXI4_TRANS_WRITE - write transaction
    --  
    --------------------------------------------------------------------------------
    constant AXI4_TRANS_READ  : integer := 0;
    constant AXI4_TRANS_WRITE : integer := 1;

    -- axi4_size_e
    --------------------------------------------------------------------------------
    --  Word-size encoding mapped to the AxSIZE signals (SPEC3(A3.4.1)). 
    -- 
    -- AXI4_BYTES_1 - 3'b000 i.e. 1 byte
    -- AXI4_BYTES_2 - 3'b001 i.e. 2 bytes
    -- AXI4_BYTES_4 - 3'b010 i.e. 4 bytes
    -- AXI4_BYTES_8 - 3'b011 i.e. 8 bytes
    -- AXI4_BYTES_16 - 3'b100 i.e. 16 bytes
    -- AXI4_BYTES_32 - 3'b101 i.e. 32 bytes
    -- AXI4_BYTES_64 - 3'b110 i.e. 64 bytes
    -- AXI4_BYTES_128 - 3'b111 i.e. 128 bytes
    -- 
    --------------------------------------------------------------------------------
    constant AXI4_BYTES_1   : integer := 0;
    constant AXI4_BYTES_2   : integer := 1;
    constant AXI4_BYTES_4   : integer := 2;
    constant AXI4_BYTES_8   : integer := 3;
    constant AXI4_BYTES_16  : integer := 4;
    constant AXI4_BYTES_32  : integer := 5;
    constant AXI4_BYTES_64  : integer := 6;
    constant AXI4_BYTES_128 : integer := 7;

    -- axi4_cache_e
    --------------------------------------------------------------------------------
    --  Cache behaviour type, mapped to the AxCACHE signals (SPEC3(A4.4)).
    -- 
    -- This has identical values to those in AXI3, but the AxCACHE[1] bit is now named 'Modifiable' (SPEC4(A4.3.1))
    -- 
    -- AXI4_NONMODIFIABLE_NONBUF - Non-modifiable and non-bufferable
    -- AXI4_BUF_ONLY - Bufferable only
    -- AXI4_CACHE_2 - Bit pattern 0010
    -- AXI4_CACHE_3 - Bit pattern 0011
    -- AXI4_CACHE_RSVD_4 - Reserved
    -- AXI4_CACHE_RSVD_5 - Reserved
    -- AXI4_CACHE_6 - Bit pattern 0110
    -- AXI4_CACHE_7 - Bit pattern 0111
    -- AXI4_CACHE_RSVD_8 - Reserved
    -- AXI4_CACHE_RSVD_9 - Reserved
    -- AXI4_CACHE_10 - Bit pattern 1010
    -- AXI4_CACHE_11 - Bit pattern 1011
    -- AXI4_CACHE_RSVD_12 - Reserved
    -- AXI4_CACHE_RSVD_13 - Reserved
    -- AXI4_CACHE_14 - Bit pattern 1110
    -- AXI4_CACHE_15 - Bit pattern 1111
    -- 
    --------------------------------------------------------------------------------
    constant AXI4_NONMODIFIABLE_NONBUF : integer := 0;
    constant AXI4_BUF_ONLY             : integer := 1;
    constant AXI4_CACHE_2              : integer := 2;
    constant AXI4_CACHE_3              : integer := 3;
    constant AXI4_CACHE_RSVD_4         : integer := 4;
    constant AXI4_CACHE_RSVD_5         : integer := 5;
    constant AXI4_CACHE_6              : integer := 6;
    constant AXI4_CACHE_7              : integer := 7;
    constant AXI4_CACHE_RSVD_8         : integer := 8;
    constant AXI4_CACHE_RSVD_9         : integer := 9;
    constant AXI4_CACHE_10             : integer := 10;
    constant AXI4_CACHE_11             : integer := 11;
    constant AXI4_CACHE_RSVD_12        : integer := 12;
    constant AXI4_CACHE_RSVD_13        : integer := 13;
    constant AXI4_CACHE_14             : integer := 14;
    constant AXI4_CACHE_15             : integer := 15;

    -- axi4_burst_e
    --------------------------------------------------------------------------------
    --  Burst type mapped to the AxBURST signals to determine address calculation (SPEC3(A3.4.4)). 
    -- 
    -- AXI4_FIXED - Fixed
    -- AXI4_INCR - Incrementing
    -- AXI4_WRAP - Wrap
    -- AXI4_RESERVED - Reserved value. May be enabled by setting the configuration parameter <IF::config_enable_burst_reserved_value>.
    -- 
    --------------------------------------------------------------------------------
    constant AXI4_FIXED    : integer := 0;
    constant AXI4_INCR     : integer := 1;
    constant AXI4_WRAP     : integer := 2;
    constant AXI4_RESERVED : integer := 3;

    -- axi4_lock_e
    --------------------------------------------------------------------------------
    --  Access type mapped to the AxLOCK signals (SPEC3(A7.4)).
    -- 
    -- AXI4_NORMAL - Normal Access, respecting barriers
    -- AXI4_EXCLUSIVE - Exclusive Access, respecting barriers
    -- 
    --------------------------------------------------------------------------------
    constant AXI4_NORMAL    : integer := 0;
    constant AXI4_EXCLUSIVE : integer := 1;

    -- axi4_interface_type_e
    --------------------------------------------------------------------------------
    --  Type to configure the category of the interface (SPEC4(A10.2)) as read/write, read-only or write-only by setting the value of <IF::config_interface_type> configuration parameter.
    -- 
    -- AXI4_READWRITE - Read and Write
    -- AXI4_READONLY - Read Only
    -- AXI4_WRITEONLY - Write Only
    -- 
    --------------------------------------------------------------------------------
    constant AXI4_READWRITE : integer := 0;
    constant AXI4_READONLY  : integer := 1;
    constant AXI4_WRITEONLY : integer := 2;

    -- axi4_error_e
    --------------------------------------------------------------------------------
    --  Type defining the error messages which can be produced by the <mgc_axi4> MVC.
    -- 
    -- Individual error messages can be disabled using the <IF::config_enable_assertion> array of configuration bits.
    -- 
    --------------------------------------------------------------------------------
    constant AXI4_ADDRESS_WIDTH_EXCEEDS_64                               : integer := 0;
    constant AXI4_ARADDR_CHANGED_BEFORE_ARREADY                          : integer := 1;
    constant AXI4_ARADDR_UNKN                                            : integer := 2;
    constant AXI4_ARPROT_CHANGED_BEFORE_ARREADY                          : integer := 3;
    constant AXI4_ARPROT_UNKN                                            : integer := 4;
    constant AXI4_ARREADY_NOT_ASSERTED_AFTER_ARVALID                     : integer := 5;
    constant AXI4_ARREADY_UNKN                                           : integer := 6;
    constant AXI4_ARVALID_DEASSERTED_BEFORE_ARREADY                      : integer := 7;
    constant AXI4_ARVALID_HIGH_ON_FIRST_CLOCK                            : integer := 8;
    constant AXI4_ARVALID_UNKN                                           : integer := 9;
    constant AXI4_AWADDR_CHANGED_BEFORE_AWREADY                          : integer := 10;
    constant AXI4_AWADDR_UNKN                                            : integer := 11;
    constant AXI4_AWPROT_CHANGED_BEFORE_AWREADY                          : integer := 12;
    constant AXI4_AWPROT_UNKN                                            : integer := 13;
    constant AXI4_AWREADY_NOT_ASSERTED_AFTER_AWVALID                     : integer := 14;
    constant AXI4_AWREADY_UNKN                                           : integer := 15;
    constant AXI4_AWVALID_DEASSERTED_BEFORE_AWREADY                      : integer := 16;
    constant AXI4_AWVALID_HIGH_ON_FIRST_CLOCK                            : integer := 17;
    constant AXI4_AWVALID_UNKN                                           : integer := 18;
    constant AXI4_BREADY_NOT_ASSERTED_AFTER_BVALID                       : integer := 19;
    constant AXI4_BREADY_UNKN                                            : integer := 20;
    constant AXI4_BRESP_CHANGED_BEFORE_BREADY                            : integer := 21;
    constant AXI4_BRESP_UNKN                                             : integer := 22;
    constant AXI4_BVALID_DEASSERTED_BEFORE_BREADY                        : integer := 23;
    constant AXI4_BVALID_HIGH_EXITING_RESET                              : integer := 24;
    constant AXI4_BVALID_UNKN                                            : integer := 25;
    constant AXI4_DEC_ERR_RESP_FOR_READ                                  : integer := 26;
    constant AXI4_DEC_ERR_RESP_FOR_WRITE                                 : integer := 27;
    constant AXI4_EXOKAY_RESPONSE_NORMAL_READ                            : integer := 28;
    constant AXI4_EXOKAY_RESPONSE_NORMAL_WRITE                           : integer := 29;
    constant AXI4_INVALID_WRITE_STROBES_ON_UNALIGNED_WRITE_TRANSFER      : integer := 30;
    constant AXI4_MINIMUM_SLAVE_ADDRESS_SPACE_VIOLATION                  : integer := 31;
    constant AXI4_PARAM_READ_DATA_BUS_WIDTH                              : integer := 32;
    constant AXI4_PARAM_WRITE_DATA_BUS_WIDTH                             : integer := 33;
    constant AXI4_READ_DATA_BEFORE_ADDRESS                               : integer := 34;
    constant AXI4_READ_DATA_CHANGED_BEFORE_RREADY                        : integer := 35;
    constant AXI4_READ_DATA_UNKN                                         : integer := 36;
    constant AXI4_READ_RESP_CHANGED_BEFORE_RREADY                        : integer := 37;
    constant AXI4_RREADY_NOT_ASSERTED_AFTER_RVALID                       : integer := 38;
    constant AXI4_RREADY_UNKN                                            : integer := 39;
    constant AXI4_RRESP_UNKN                                             : integer := 40;
    constant AXI4_RVALID_DEASSERTED_BEFORE_RREADY                        : integer := 41;
    constant AXI4_RVALID_HIGH_EXITING_RESET                              : integer := 42;
    constant AXI4_RVALID_UNKN                                            : integer := 43;
    constant AXI4_SLV_ERR_RESP_FOR_READ                                  : integer := 44;
    constant AXI4_SLV_ERR_RESP_FOR_WRITE                                 : integer := 45;
    constant AXI4_TIMEOUT_WAITING_FOR_READ_RESPONSE                      : integer := 46;
    constant AXI4_TIMEOUT_WAITING_FOR_WRITE_RESPONSE                     : integer := 47;
    constant AXI4_WDATA_CHANGED_BEFORE_WREADY_ON_INVALID_LANE            : integer := 48;
    constant AXI4_WDATA_CHANGED_BEFORE_WREADY_ON_VALID_LANE              : integer := 49;
    constant AXI4_WREADY_NOT_ASSERTED_AFTER_WVALID                       : integer := 50;
    constant AXI4_WREADY_UNKN                                            : integer := 51;
    constant AXI4_WRITE_DATA_BEFORE_ADDRESS                              : integer := 52;
    constant AXI4_WRITE_DATA_UNKN_ON_INVALID_LANE                        : integer := 53;
    constant AXI4_WRITE_DATA_UNKN_ON_VALID_LANE                          : integer := 54;
    constant AXI4_WRITE_RESPONSE_WITHOUT_ADDR_DATA                       : integer := 55;
    constant AXI4_WSTRB_CHANGED_BEFORE_WREADY                            : integer := 56;
    constant AXI4_WSTRB_UNKN                                             : integer := 57;
    constant AXI4_WVALID_DEASSERTED_BEFORE_WREADY                        : integer := 58;
    constant AXI4_WVALID_HIGH_ON_FIRST_CLOCK                             : integer := 59;
    constant AXI4_WVALID_UNKN                                            : integer := 60;
    constant MVC_FAILED_POSTCONDITION                                    : integer := 61;
    constant MVC_FAILED_RECOGNITION                                      : integer := 62;
    constant AXI4_DEC_ERR_ILLEGAL_FOR_MAPPED_SLAVE_ADDR                  : integer := 63;
    constant AXI4_AWVALID_HIGH_DURING_RESET                              : integer := 64;
    constant AXI4_WVALID_HIGH_DURING_RESET                               : integer := 65;
    constant AXI4_BVALID_HIGH_DURING_RESET                               : integer := 66;
    constant AXI4_ARVALID_HIGH_DURING_RESET                              : integer := 67;
    constant AXI4_RVALID_HIGH_DURING_RESET                               : integer := 68;
    constant AXI4_TIMEOUT_WAITING_FOR_WRITE_DATA                         : integer := 69;
    constant AXI4_TIMEOUT_WAITING_FOR_WRITE_ADDR_AFTER_DATA              : integer := 70;
    constant AXI4_ARESETN_SIGNAL_Z                                       : integer := 71;
    constant AXI4_ARESETN_SIGNAL_X                                       : integer := 72;
    constant AXI4_ADDR_FOR_READ_BURST_ACROSS_4K_BOUNDARY                 : integer := 73;
    constant AXI4_ADDR_FOR_WRITE_BURST_ACROSS_4K_BOUNDARY                : integer := 74;
    constant AXI4_ARADDR_FALLS_IN_REGION_HOLE                            : integer := 75;
    constant AXI4_ARBURST_CHANGED_BEFORE_ARREADY                         : integer := 76;
    constant AXI4_ARBURST_UNKN                                           : integer := 77;
    constant AXI4_ARCACHE_CHANGED_BEFORE_ARREADY                         : integer := 78;
    constant AXI4_ARCACHE_UNKN                                           : integer := 79;
    constant AXI4_ARID_CHANGED_BEFORE_ARREADY                            : integer := 80;
    constant AXI4_ARID_UNKN                                              : integer := 81;
    constant AXI4_ARLEN_CHANGED_BEFORE_ARREADY                           : integer := 82;
    constant AXI4_ARLEN_UNKN                                             : integer := 83;
    constant AXI4_ARLOCK_CHANGED_BEFORE_ARREADY                          : integer := 84;
    constant AXI4_ARLOCK_UNKN                                            : integer := 85;
    constant AXI4_ARQOS_CHANGED_BEFORE_ARREADY                           : integer := 86;
    constant AXI4_ARQOS_UNKN                                             : integer := 87;
    constant AXI4_ARREGION_CHANGED_BEFORE_ARREADY                        : integer := 88;
    constant AXI4_ARREGION_MISMATCH                                      : integer := 89;
    constant AXI4_ARREGION_UNKN                                          : integer := 90;
    constant AXI4_ARSIZE_CHANGED_BEFORE_ARREADY                          : integer := 91;
    constant AXI4_ARSIZE_UNKN                                            : integer := 92;
    constant AXI4_ARUSER_CHANGED_BEFORE_ARREADY                          : integer := 93;
    constant AXI4_ARUSER_UNKN                                            : integer := 94;
    constant AXI4_AWADDR_FALLS_IN_REGION_HOLE                            : integer := 95;
    constant AXI4_AWBURST_CHANGED_BEFORE_AWREADY                         : integer := 96;
    constant AXI4_AWBURST_UNKN                                           : integer := 97;
    constant AXI4_AWCACHE_CHANGED_BEFORE_AWREADY                         : integer := 98;
    constant AXI4_AWCACHE_UNKN                                           : integer := 99;
    constant AXI4_AWID_CHANGED_BEFORE_AWREADY                            : integer := 100;
    constant AXI4_AWID_UNKN                                              : integer := 101;
    constant AXI4_AWLEN_CHANGED_BEFORE_AWREADY                           : integer := 102;
    constant AXI4_AWLEN_UNKN                                             : integer := 103;
    constant AXI4_AWLOCK_CHANGED_BEFORE_AWREADY                          : integer := 104;
    constant AXI4_AWLOCK_UNKN                                            : integer := 105;
    constant AXI4_AWQOS_CHANGED_BEFORE_AWREADY                           : integer := 106;
    constant AXI4_AWQOS_UNKN                                             : integer := 107;
    constant AXI4_AWREGION_CHANGED_BEFORE_AWREADY                        : integer := 108;
    constant AXI4_AWREGION_MISMATCH                                      : integer := 109;
    constant AXI4_AWREGION_UNKN                                          : integer := 110;
    constant AXI4_AWSIZE_CHANGED_BEFORE_AWREADY                          : integer := 111;
    constant AXI4_AWSIZE_UNKN                                            : integer := 112;
    constant AXI4_AWUSER_CHANGED_BEFORE_AWREADY                          : integer := 113;
    constant AXI4_AWUSER_UNKN                                            : integer := 114;
    constant AXI4_BID_CHANGED_BEFORE_BREADY                              : integer := 115;
    constant AXI4_BID_UNKN                                               : integer := 116;
    constant AXI4_BUSER_CHANGED_BEFORE_BREADY                            : integer := 117;
    constant AXI4_BUSER_UNKN                                             : integer := 118;
    constant AXI4_EXCLUSIVE_READ_ACCESS_MODIFIABLE                       : integer := 119;
    constant AXI4_EXCLUSIVE_READ_BYTES_TRANSFER_EXCEEDS_128              : integer := 120;
    constant AXI4_EXCLUSIVE_WRITE_BYTES_TRANSFER_EXCEEDS_128             : integer := 121;
    constant AXI4_EXCLUSIVE_READ_BYTES_TRANSFER_NOT_POWER_OF_2           : integer := 122;
    constant AXI4_EXCLUSIVE_WRITE_BYTES_TRANSFER_NOT_POWER_OF_2          : integer := 123;
    constant AXI4_EXCLUSIVE_READ_LENGTH_EXCEEDS_16                       : integer := 124;
    constant AXI4_EXCLUSIVE_WR_ADDRESS_NOT_SAME_AS_RD                    : integer := 125;
    constant AXI4_EXCLUSIVE_WR_BURST_NOT_SAME_AS_RD                      : integer := 126;
    constant AXI4_EXCLUSIVE_WR_CACHE_NOT_SAME_AS_RD                      : integer := 127;
    constant AXI4_EXCLUSIVE_WRITE_ACCESS_MODIFIABLE                      : integer := 128;
    constant AXI4_EXCLUSIVE_WR_LENGTH_NOT_SAME_AS_RD                     : integer := 129;
    constant AXI4_EXCLUSIVE_WR_PROT_NOT_SAME_AS_RD                       : integer := 130;
    constant AXI4_EXCLUSIVE_WR_REGION_NOT_SAME_AS_RD                     : integer := 131;
    constant AXI4_EXCLUSIVE_WR_SIZE_NOT_SAME_AS_RD                       : integer := 132;
    constant AXI4_EX_RD_EXOKAY_RESP_EXPECTED_OKAY                        : integer := 133;
    constant AXI4_EX_RD_EXOKAY_RESP_SLAVE_WITHOUT_EXCLUSIVE_ACCESS       : integer := 134;
    constant AXI4_EX_RD_OKAY_RESP_EXPECTED_EXOKAY                        : integer := 135;
    constant AXI4_EX_RD_WHEN_EX_NOT_ENABLED                              : integer := 136;
    constant AXI4_EX_WRITE_BEFORE_EX_READ_RESPONSE                       : integer := 137;
    constant AXI4_EX_WRITE_EXOKAY_RESP_EXPECTED_OKAY                     : integer := 138;
    constant AXI4_EX_WRITE_EXOKAY_RESP_SLAVE_WITHOUT_EXCLUSIVE_ACCESS    : integer := 139;
    constant AXI4_EX_WRITE_OKAY_RESP_EXPECTED_EXOKAY                     : integer := 140;
    constant AXI4_EX_WR_WHEN_EX_NOT_ENABLED                              : integer := 141;
    constant AXI4_ILLEGAL_ARCACHE_VALUE_FOR_CACHEABLE_ADDRESS_REGION     : integer := 142;
    constant AXI4_ILLEGAL_ARCACHE_VALUE_FOR_NON_CACHEABLE_ADDRESS_REGION : integer := 143;
    constant AXI4_ILLEGAL_AWCACHE_VALUE_FOR_CACHEABLE_ADDRESS_REGION     : integer := 144;
    constant AXI4_ILLEGAL_AWCACHE_VALUE_FOR_NON_CACHEABLE_ADDRESS_REGION : integer := 145;
    constant AXI4_ILLEGAL_LENGTH_FIXED_READ_BURST                        : integer := 146;
    constant AXI4_ILLEGAL_LENGTH_FIXED_WRITE_BURST                       : integer := 147;
    constant AXI4_ILLEGAL_LENGTH_WRAPPING_READ_BURST                     : integer := 148;
    constant AXI4_ILLEGAL_LENGTH_WRAPPING_WRITE_BURST                    : integer := 149;
    constant AXI4_ILLEGAL_RESPONSE_EXCLUSIVE_READ                        : integer := 150;
    constant AXI4_ILLEGAL_RESPONSE_EXCLUSIVE_WRITE                       : integer := 151;
    constant AXI4_INVALID_REGION_CARDINALITY                             : integer := 152;
    constant AXI4_INVALID_WRITE_STROBES_ON_ALIGNED_WRITE_TRANSFER        : integer := 153;
    constant AXI4_NON_INCREASING_REGION_SPECIFICATION                    : integer := 154;
    constant AXI4_NON_ZERO_ARQOS                                         : integer := 155;
    constant AXI4_NON_ZERO_AWQOS                                         : integer := 156;
    constant AXI4_OVERLAPPING_REGION                                     : integer := 157;
    constant AXI4_PARAM_READ_REORDERING_DEPTH_EQUALS_ZERO                : integer := 158;
    constant AXI4_PARAM_READ_REORDERING_DEPTH_EXCEEDS_MAX_ID             : integer := 159;
    constant AXI4_READ_ALLOCATE_WHEN_NON_MODIFIABLE_12                   : integer := 160;
    constant AXI4_READ_ALLOCATE_WHEN_NON_MODIFIABLE_13                   : integer := 161;
    constant AXI4_READ_ALLOCATE_WHEN_NON_MODIFIABLE_4                    : integer := 162;
    constant AXI4_READ_ALLOCATE_WHEN_NON_MODIFIABLE_5                    : integer := 163;
    constant AXI4_READ_ALLOCATE_WHEN_NON_MODIFIABLE_8                    : integer := 164;
    constant AXI4_READ_ALLOCATE_WHEN_NON_MODIFIABLE_9                    : integer := 165;
    constant AXI4_READ_BURST_LENGTH_VIOLATION                            : integer := 166;
    constant AXI4_READ_BURST_MAXIMUM_LENGTH_VIOLATION                    : integer := 167;
    constant AXI4_READ_BURST_SIZE_VIOLATION                              : integer := 168;
    constant AXI4_READ_EXCLUSIVE_ENCODING_VIOLATION                      : integer := 169;
    constant AXI4_READ_REORDERING_VIOLATION                              : integer := 170;
    constant AXI4_READ_TRANSFER_EXCEEDS_ADDRESS_SPACE                    : integer := 171;
    constant AXI4_REGION_SMALLER_THAN_4KB                                : integer := 172;
    constant AXI4_RESERVED_ARBURST_ENCODING                              : integer := 173;
    constant AXI4_RESERVED_AWBURST_ENCODING                              : integer := 174;
    constant AXI4_RID_CHANGED_BEFORE_RREADY                              : integer := 175;
    constant AXI4_RID_UNKN                                               : integer := 176;
    constant AXI4_RLAST_CHANGED_BEFORE_RREADY                            : integer := 177;
    constant AXI4_RLAST_UNKN                                             : integer := 178;
    constant AXI4_RUSER_CHANGED_BEFORE_RREADY                            : integer := 179;
    constant AXI4_RUSER_UNKN                                             : integer := 180;
    constant AXI4_UNALIGNED_ADDRESS_FOR_EXCLUSIVE_READ                   : integer := 181;
    constant AXI4_UNALIGNED_ADDRESS_FOR_EXCLUSIVE_WRITE                  : integer := 182;
    constant AXI4_UNALIGNED_ADDR_FOR_WRAPPING_READ_BURST                 : integer := 183;
    constant AXI4_UNALIGNED_ADDR_FOR_WRAPPING_WRITE_BURST                : integer := 184;
    constant AXI4_WLAST_CHANGED_BEFORE_WREADY                            : integer := 185;
    constant AXI4_WLAST_UNKN                                             : integer := 186;
    constant AXI4_WRITE_ALLOCATE_WHEN_NON_MODIFIABLE_12                  : integer := 187;
    constant AXI4_WRITE_ALLOCATE_WHEN_NON_MODIFIABLE_13                  : integer := 188;
    constant AXI4_WRITE_ALLOCATE_WHEN_NON_MODIFIABLE_4                   : integer := 189;
    constant AXI4_WRITE_ALLOCATE_WHEN_NON_MODIFIABLE_5                   : integer := 190;
    constant AXI4_WRITE_ALLOCATE_WHEN_NON_MODIFIABLE_8                   : integer := 191;
    constant AXI4_WRITE_ALLOCATE_WHEN_NON_MODIFIABLE_9                   : integer := 192;
    constant AXI4_WRITE_BURST_LENGTH_VIOLATION                           : integer := 193;
    constant AXI4_WRITE_STROBES_LENGTH_VIOLATION                         : integer := 194;
    constant AXI4_WRITE_USER_DATA_LENGTH_VIOLATION                       : integer := 195;
    constant AXI4_WRITE_BURST_MAXIMUM_LENGTH_VIOLATION                   : integer := 196;
    constant AXI4_WRITE_BURST_SIZE_VIOLATION                             : integer := 197;
    constant AXI4_WRITE_EXCLUSIVE_ENCODING_VIOLATION                     : integer := 198;
    constant AXI4_WRITE_STROBE_FIXED_BURST_VIOLATION                     : integer := 199;
    constant AXI4_WRITE_TRANSFER_EXCEEDS_ADDRESS_SPACE                   : integer := 200;
    constant AXI4_WRONG_ARREGION_FOR_SLAVE_WITH_SINGLE_ADDRESS_DECODE    : integer := 201;
    constant AXI4_WRONG_AWREGION_FOR_SLAVE_WITH_SINGLE_ADDRESS_DECODE    : integer := 202;
    constant AXI4_WUSER_CHANGED_BEFORE_WREADY                            : integer := 203;
    constant AXI4_WUSER_UNKN                                             : integer := 204;
    constant AXI4_EXCL_RD_WHILE_EXCL_WR_IN_PROGRESS_SAME_ID              : integer := 205;
    constant AXI4_EXCL_WR_WHILE_EXCL_RD_IN_PROGRESS_SAME_ID              : integer := 206;
    constant AXI4_RLAST_VIOLATION                                        : integer := 207;
    constant AXI4_WLAST_ASSERTED_DURING_DATA_PHASE_OTHER_THAN_LAST       : integer := 208;


    constant AXI4_MAX_BIT_SIZE : integer := 1024;

-- enum: axi4_config_e
--
-- An enum which fields corresponding to each configuration parameter of the VIP
--    AXI4_CONFIG_INTERFACE_TYPE - 
--          A configuration parameter (of type <axi4_interface_type_e>) defining the interface category: read/write, read only or write only (SPEC4(A10.2)).
--         
--         The value defaults to <AXI4_READWRITE>.
--         
--    AXI4_CONFIG_SETUP_TIME - 
--          The setup-time, in units of simulator time-steps, for all signals. By default this is set to 0. Users should use the
--         <questa_mvc_sv_convert_to_precision> function to set this to the preferred time-interval.
--         See <Configuration of Time-Units> for background on configuration of time-units.
--         
--    AXI4_CONFIG_HOLD_TIME - 
--          The hold-time, in units of simulator time-steps, for all signals. By default this is set to 0. Users should use the
--         <questa_mvc_sv_convert_to_precision> function to set this to the preferred time-interval.
--         See <Configuration of Time-Units> for background on configuration of time-units.
--         
--    AXI4_CONFIG_BURST_TIMEOUT_FACTOR - 
--          The maximum number of clock-periods between phases.
--         
--         This causes a timeout when an unreasonable time passes between transaction phases. It defaults to 10000 clock periods.
--         
--    AXI4_CONFIG_ENABLE_RLAST - 
--          A configuration parameter controlling whether the optional <RLAST> signal is used, or not.
--         
--         <RLAST> is an optional input to the master, because the length of a read burst is always known (SPEC4(A10.3.5)).
--         
--    AXI4_CONFIG_ENABLE_SLAVE_EXCLUSIVE - 
--          A configuration parameter controlling whether the slave supports exclusive accesses. (SPEC3(A7.2.5))
--         
--         By default this is set to true so that the slave will support exclusive accesses by responding with <AXI4_EXOKAY>.
--         
--         The coverage collected by the covergroup <axi4_coverage::axi4_cvg> is affected by this parameter value setting.
--         
--    AXI4_CONFIG_AXI4LITE_INTERFACE - 
--          If user want to use QVIP BFM on the axi4lite interface, then this
--          configuration variable should be set to true.
--         
--    AXI4_CONFIG_AXI4LITE_TR_ID - 
--          Configuration variable to set ID to a fixed value when QVIP BFM is configured as axi4lite
--         
--    AXI4_CONFIG_ENABLE_ALL_ASSERTIONS - 
--          Configuration parameter controlling whether the error messages(Assertions) issued from the QVIP are Enabled or Disabled.  
--              By default, it is enabled.
--           
--    AXI4_CONFIG_ENABLE_ASSERTION - 
--          An array of configuration parameters controlling whether specific error messages(Assertion) can be issued by the QVIP.
--              By default, all errors are enabled. 
--              To suppress a particular error, set the corresponding bit to 0 (false).
--           
--    AXI4_CONFIG_MAX_LATENCY_AWVALID_ASSERTION_TO_AWREADY - 
--          A configuration parameter defining the timeout (in clock periods) from the assertion of <AWVALID> to the assertion of <AWREADY> (default 10000).
--         
--         The error message <AXI4_AWREADY_NOT_ASSERTED_AFTER_AWVALID> will be issued if this period elapses from the assertion of <AWVALID>.
--         
--    AXI4_CONFIG_MAX_LATENCY_ARVALID_ASSERTION_TO_ARREADY - 
--          A configuration parameter defining the timeout (in clock periods) from the assertion of <ARVALID> to the assertion of <ARREADY> (default 10000).
--         
--         The error message <AXI4_ARREADY_NOT_ASSERTED_AFTER_ARVALID> will be issued if this period elapses from the assertion of <ARVALID>.
--         
--    AXI4_CONFIG_MAX_LATENCY_RVALID_ASSERTION_TO_RREADY - 
--          A configuration parameter defining the timeout (in clock periods) from the assertion of <RVALID> to the assertion of <RREADY> (default 10000).
--         
--         The error message <AXI4_RREADY_NOT_ASSERTED_AFTER_RVALID> will be issued if this period elapses from the assertion of <RVALID>.
--         
--    AXI4_CONFIG_MAX_LATENCY_BVALID_ASSERTION_TO_BREADY - 
--          A configuration parameter defining the timeout (in clock periods) from the assertion of <BVALID> to the assertion of <BREADY> (default 10000).
--         
--         The error message <AXI4_BREADY_NOT_ASSERTED_AFTER_BVALID> will be issued if this period elapses from the assertion of <BVALID>.
--         
--    AXI4_CONFIG_MAX_LATENCY_WVALID_ASSERTION_TO_WREADY - 
--          A configuration parameter defining the timeout (in clock periods) from the assertion of <WVALID> to the assertion of <WREADY> (default 10000).
--         
--         The error message <AXI4_WREADY_NOT_ASSERTED_AFTER_WVALID> will be issued if this period elapses from the assertion of <WVALID>.
--         
--    AXI4_CONFIG_ENABLE_QOS - 
--          A configuration parameter defining whether the master participates in the Quality-of-Service scheme  (SPEC4(A8.1.2)). 
--         
--         This defaults to 'true' i.e. the master participates in the Quality-of-Service scheme. If a master does not participate, the <AWQOS>/<ARQOS> value used in write/read transactions must be b0000.
--         
--    AXI4_CONFIG_READ_DATA_REORDERING_DEPTH - 
--          A configuration parameter defining the read reordering depth of the slave end of the interface (SPEC3(A5.3.1)).
--         
--         Responses from the first <config_read_data_reordering_depth> outstanding read transactions, each with address <ARID> values different from any
--          earlier outstanding read transaction(as seen by the slave) are expected, interleaved at random. A violation causes a <AXI4_READ_REORDERING_VIOLATION> error.
--         
--         The default value of <config_read_data_reordering_depth> is (1 << AXI4_ID_WIDTH), so that the slave is expected to process all transactions in any order (up to uniqueness of <ARID>).
--         
--         For a given <AXI4_ID_WIDTH> parameter value, the maximum possible value of <config_read_data_reordering_depth> is 2**AXI4_ID_WIDTH. The <AXI4_PARAM_READ_REORDERING_DEPTH_EXCEEDS_MAX_ID>
--          error report will be issued if <config_read_data_reordering_depth> exceeds this value.
--         
--         If the user-supplied value is 0, the <AXI4_PARAM_READ_REORDERING_DEPTH_EQUALS_ZERO> error will be issued, and the value will be set to 1.
--         
--    AXI4_CONFIG_SLAVE_START_ADDR - 
--          A configuration parameter indicating start address for slave.
--         
--    AXI4_CONFIG_SLAVE_END_ADDR - 
--          A configuration parameter indicating end address for slave.
--         
--    AXI4_AXI4_MAX_SW_MULTIPLE - 
--         **************************************************************************************
--          *
--          * Copyright 2007-2013 Mentor Graphics Corporation
--          * All Rights Reserved.
--          *
--          * THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
--          * MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
--          *
--          **************************************************************************************
    constant AXI4_CONFIG_INTERFACE_TYPE               : std_logic_vector(7 downto 0) := X"00";
    constant AXI4_CONFIG_SETUP_TIME                   : std_logic_vector(7 downto 0) := X"01";
    constant AXI4_CONFIG_HOLD_TIME                    : std_logic_vector(7 downto 0) := X"02";
    constant AXI4_CONFIG_BURST_TIMEOUT_FACTOR         : std_logic_vector(7 downto 0) := X"03";
    constant AXI4_CONFIG_MAX_TRANSACTION_TIME_FACTOR  : std_logic_vector(7 downto 0) := X"04";
    constant AXI4_CONFIG_ENABLE_RLAST                 : std_logic_vector(7 downto 0) := X"05";
    constant AXI4_CONFIG_ENABLE_SLAVE_EXCLUSIVE       : std_logic_vector(7 downto 0) := X"06";
    constant AXI4_CONFIG_AXI4LITE_INTERFACE           : std_logic_vector(7 downto 0) := X"07";
    constant AXI4_CONFIG_AXI4LITE_TR_ID               : std_logic_vector(7 downto 0) := X"08";
    constant AXI4_CONFIG_ENABLE_ALL_ASSERTIONS        : std_logic_vector(7 downto 0) := X"09";
    constant AXI4_CONFIG_ENABLE_ASSERTION             : std_logic_vector(7 downto 0) := X"0A";
    constant AXI4_CONFIG_MAX_LATENCY_AWVALID_ASSERTION_TO_AWREADY : std_logic_vector(7 downto 0) := X"0B";
    constant AXI4_CONFIG_MAX_LATENCY_ARVALID_ASSERTION_TO_ARREADY : std_logic_vector(7 downto 0) := X"0C";
    constant AXI4_CONFIG_MAX_LATENCY_RVALID_ASSERTION_TO_RREADY : std_logic_vector(7 downto 0) := X"0D";
    constant AXI4_CONFIG_MAX_LATENCY_BVALID_ASSERTION_TO_BREADY : std_logic_vector(7 downto 0) := X"0E";
    constant AXI4_CONFIG_MAX_LATENCY_WVALID_ASSERTION_TO_WREADY : std_logic_vector(7 downto 0) := X"0F";
    constant AXI4_CONFIG_ENABLE_QOS                   : std_logic_vector(7 downto 0) := X"10";
    constant AXI4_CONFIG_READ_DATA_REORDERING_DEPTH   : std_logic_vector(7 downto 0) := X"11";
    constant AXI4_CONFIG_SLAVE_START_ADDR             : std_logic_vector(7 downto 0) := X"12";
    constant AXI4_CONFIG_SLAVE_END_ADDR               : std_logic_vector(7 downto 0) := X"13";
    constant AXI4_CONFIG_MAX_OUTSTANDING_WR           : std_logic_vector(7 downto 0) := X"14";
    constant AXI4_CONFIG_MAX_OUTSTANDING_RD           : std_logic_vector(7 downto 0) := X"15";
    constant AXI4_CONFIG_NUM_OUTSTANDING_WR_PHASE     : std_logic_vector(7 downto 0) := X"16";
    constant AXI4_CONFIG_NUM_OUTSTANDING_RD_PHASE     : std_logic_vector(7 downto 0) := X"17";
    constant AXI4_AXI4_MAX_SW_MULTIPLE                : std_logic_vector(7 downto 0) := X"18";

    -- axi4_vhd_if_e
    constant AXI4_VHD_SET_CONFIG                         : integer := 0;
    constant AXI4_VHD_GET_CONFIG                         : integer := 1;
    constant AXI4_VHD_CREATE_WRITE_TRANSACTION           : integer := 2;
    constant AXI4_VHD_CREATE_READ_TRANSACTION            : integer := 3;
    constant AXI4_VHD_SET_READ_OR_WRITE                  : integer := 4;
    constant AXI4_VHD_GET_READ_OR_WRITE                  : integer := 5;
    constant AXI4_VHD_SET_ADDR                           : integer := 6;
    constant AXI4_VHD_GET_ADDR                           : integer := 7;
    constant AXI4_VHD_SET_PROT                           : integer := 8;
    constant AXI4_VHD_GET_PROT                           : integer := 9;
    constant AXI4_VHD_SET_REGION                         : integer := 10;
    constant AXI4_VHD_GET_REGION                         : integer := 11;
    constant AXI4_VHD_SET_SIZE                           : integer := 12;
    constant AXI4_VHD_GET_SIZE                           : integer := 13;
    constant AXI4_VHD_SET_BURST                          : integer := 14;
    constant AXI4_VHD_GET_BURST                          : integer := 15;
    constant AXI4_VHD_SET_LOCK                           : integer := 16;
    constant AXI4_VHD_GET_LOCK                           : integer := 17;
    constant AXI4_VHD_SET_CACHE                          : integer := 18;
    constant AXI4_VHD_GET_CACHE                          : integer := 19;
    constant AXI4_VHD_SET_QOS                            : integer := 20;
    constant AXI4_VHD_GET_QOS                            : integer := 21;
    constant AXI4_VHD_SET_ID                             : integer := 22;
    constant AXI4_VHD_GET_ID                             : integer := 23;
    constant AXI4_VHD_SET_BURST_LENGTH                   : integer := 24;
    constant AXI4_VHD_GET_BURST_LENGTH                   : integer := 25;
    constant AXI4_VHD_SET_ADDR_USER                      : integer := 26;
    constant AXI4_VHD_GET_ADDR_USER                      : integer := 27;
    constant AXI4_VHD_SET_DATA_WORDS                     : integer := 28;
    constant AXI4_VHD_GET_DATA_WORDS                     : integer := 29;
    constant AXI4_VHD_SET_WRITE_STROBES                  : integer := 30;
    constant AXI4_VHD_GET_WRITE_STROBES                  : integer := 31;
    constant AXI4_VHD_SET_RESP                           : integer := 32;
    constant AXI4_VHD_GET_RESP                           : integer := 33;
    constant AXI4_VHD_SET_ADDRESS_VALID_DELAY            : integer := 34;
    constant AXI4_VHD_GET_ADDRESS_VALID_DELAY            : integer := 35;
    constant AXI4_VHD_SET_DATA_VALID_DELAY               : integer := 36;
    constant AXI4_VHD_GET_DATA_VALID_DELAY               : integer := 37;
    constant AXI4_VHD_SET_WRITE_RESPONSE_VALID_DELAY     : integer := 38;
    constant AXI4_VHD_GET_WRITE_RESPONSE_VALID_DELAY     : integer := 39;
    constant AXI4_VHD_SET_ADDRESS_READY_DELAY            : integer := 40;
    constant AXI4_VHD_GET_ADDRESS_READY_DELAY            : integer := 41;
    constant AXI4_VHD_SET_DATA_READY_DELAY               : integer := 42;
    constant AXI4_VHD_GET_DATA_READY_DELAY               : integer := 43;
    constant AXI4_VHD_SET_WRITE_RESPONSE_READY_DELAY     : integer := 44;
    constant AXI4_VHD_GET_WRITE_RESPONSE_READY_DELAY     : integer := 45;
    constant AXI4_VHD_SET_GEN_WRITE_STROBES              : integer := 46;
    constant AXI4_VHD_GET_GEN_WRITE_STROBES              : integer := 47;
    constant AXI4_VHD_SET_OPERATION_MODE                 : integer := 48;
    constant AXI4_VHD_GET_OPERATION_MODE                 : integer := 49;
    constant AXI4_VHD_SET_WRITE_DATA_MODE                : integer := 50;
    constant AXI4_VHD_GET_WRITE_DATA_MODE                : integer := 51;
    constant AXI4_VHD_SET_DATA_BEAT_DONE                 : integer := 52;
    constant AXI4_VHD_GET_DATA_BEAT_DONE                 : integer := 53;
    constant AXI4_VHD_SET_TRANSACTION_DONE               : integer := 54;
    constant AXI4_VHD_GET_TRANSACTION_DONE               : integer := 55;
    constant AXI4_VHD_EXECUTE_TRANSACTION                : integer := 56;
    constant AXI4_VHD_GET_RW_TRANSACTION                 : integer := 57;
    constant AXI4_VHD_EXECUTE_WRITE_DATA_BURST           : integer := 58;
    constant AXI4_VHD_GET_WRITE_DATA_BURST               : integer := 59;
    constant AXI4_VHD_EXECUTE_READ_ADDR_PHASE            : integer := 60;
    constant AXI4_VHD_GET_READ_ADDR_PHASE                : integer := 61;
    constant AXI4_VHD_EXECUTE_READ_DATA_BURST            : integer := 62;
    constant AXI4_VHD_GET_READ_DATA_BURST                : integer := 63;
    constant AXI4_VHD_EXECUTE_READ_DATA_PHASE            : integer := 64;
    constant AXI4_VHD_GET_READ_DATA_PHASE                : integer := 65;
    constant AXI4_VHD_EXECUTE_WRITE_ADDR_PHASE           : integer := 66;
    constant AXI4_VHD_GET_WRITE_ADDR_PHASE               : integer := 67;
    constant AXI4_VHD_EXECUTE_WRITE_DATA_PHASE           : integer := 68;
    constant AXI4_VHD_GET_WRITE_DATA_PHASE               : integer := 69;
    constant AXI4_VHD_EXECUTE_WRITE_RESPONSE_PHASE       : integer := 70;
    constant AXI4_VHD_GET_WRITE_RESPONSE_PHASE           : integer := 71;
    constant AXI4_VHD_GET_READ_ADDR_CYCLE                : integer := 72;
    constant AXI4_VHD_EXECUTE_READ_ADDR_READY            : integer := 73;
    constant AXI4_VHD_GET_READ_ADDR_READY                : integer := 74;
    constant AXI4_VHD_GET_READ_DATA_CYCLE                : integer := 75;
    constant AXI4_VHD_EXECUTE_READ_DATA_READY            : integer := 76;
    constant AXI4_VHD_GET_READ_DATA_READY                : integer := 77;
    constant AXI4_VHD_GET_WRITE_ADDR_CYCLE               : integer := 78;
    constant AXI4_VHD_EXECUTE_WRITE_ADDR_READY           : integer := 79;
    constant AXI4_VHD_GET_WRITE_ADDR_READY               : integer := 80;
    constant AXI4_VHD_GET_WRITE_DATA_CYCLE               : integer := 81;
    constant AXI4_VHD_EXECUTE_WRITE_DATA_READY           : integer := 82;
    constant AXI4_VHD_GET_WRITE_DATA_READY               : integer := 83;
    constant AXI4_VHD_GET_WRITE_RESPONSE_CYCLE           : integer := 84;
    constant AXI4_VHD_EXECUTE_WRITE_RESP_READY           : integer := 85;
    constant AXI4_VHD_GET_WRITE_RESP_READY               : integer := 86;
    constant AXI4_VHD_CREATE_MONITOR_TRANSACTION         : integer := 87;
    constant AXI4_VHD_CREATE_SLAVE_TRANSACTION           : integer := 88;
    constant AXI4_VHD_PUSH_TRANSACTION_ID                : integer := 89;
    constant AXI4_VHD_POP_TRANSACTION_ID                 : integer := 90;
    constant AXI4_VHD_GET_WRITE_ADDR_DATA                : integer := 91;
    constant AXI4_VHD_GET_READ_ADDR                      : integer := 92;
    constant AXI4_VHD_SET_READ_DATA                      : integer := 93;
    constant AXI4_VHD_PRINT                              : integer := 94;
    constant AXI4_VHD_DESTRUCT_TRANSACTION               : integer := 95;
    constant AXI4_VHD_WAIT_ON                            : integer := 96;

    -- axi_wait_e
    constant AXI4_CLOCK_POSEDGE        : integer := 0;
    constant AXI4_CLOCK_NEGEDGE        : integer := 1;
    constant AXI4_CLOCK_ANYEDGE        : integer := 2;
    constant AXI4_CLOCK_0_TO_1         : integer := 3;
    constant AXI4_CLOCK_1_TO_0         : integer := 4;
    constant AXI4_RESET_POSEDGE        : integer := 5;
    constant AXI4_RESET_NEGEDGE        : integer := 6;
    constant AXI4_RESET_ANYEDGE        : integer := 7;
    constant AXI4_RESET_0_TO_1         : integer := 8;
    constant AXI4_RESET_1_TO_0         : integer := 9;

    -- axi4_operation_mode_e
    constant AXI4_TRANSACTION_NON_BLOCKING : integer := 0;
    constant AXI4_TRANSACTION_BLOCKING     : integer := 1;

    -- axi4_write_data_mode_e
    constant AXI4_DATA_AFTER_ADDRESS       : integer := 0;
    constant AXI4_DATA_WITH_ADDRESS        : integer := 1;

    -- Queue ID
    constant AXI4_QUEUE_ID_0 : integer := 0;
    constant AXI4_QUEUE_ID_1 : integer := 1;
    constant AXI4_QUEUE_ID_2 : integer := 2;
    constant AXI4_QUEUE_ID_3 : integer := 3;
    constant AXI4_QUEUE_ID_4 : integer := 4;
    constant AXI4_QUEUE_ID_5 : integer := 5;
    constant AXI4_QUEUE_ID_6 : integer := 6;
    constant AXI4_QUEUE_ID_7 : integer := 7;

    -- Parallel path
    type axi4_path_t is (
      AXI4_PATH_0,
      AXI4_PATH_1,
      AXI4_PATH_2,
      AXI4_PATH_3,
      AXI4_PATH_4
    );

    -- Parallel ready-path
    type axi4_adv_path_t is (
      AXI4_PATH_5,
      AXI4_PATH_6,
      AXI4_PATH_7
    );

    -- Global signal record
    type axi4_vhd_if_struct_t is record
        req             : std_logic_vector(AXI4_VHD_WAIT_ON downto 0);
        ack             : std_logic_vector(AXI4_VHD_WAIT_ON downto 0);
        transaction_id  : integer; 
        value_0         : integer;
        value_1         : integer;
        value_2         : integer;
        value_3         : integer;
        value_max       : std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
    end record;

    -- 512 array of records 
    type axi4_tr_if_array_t is array(511 downto 0) of axi4_vhd_if_struct_t;
    type axi4_tr_if_path_array_t is array(axi4_path_t) of axi4_vhd_if_struct_t;
    type axi4_tr_if_path_2d_array_t is array(511 downto 0) of axi4_tr_if_path_array_t;
    type axi4_tr_adv_if_path_array_t is array(axi4_adv_path_t) of axi4_vhd_if_struct_t;
    type axi4_tr_adv_if_path_2d_array_t is array(511 downto 0) of axi4_tr_adv_if_path_array_t;

    -- Global signal passed to each API
    signal axi4_tr_if_0              : axi4_tr_if_array_t;
    signal axi4_tr_if_1              : axi4_tr_if_array_t;
    signal axi4_tr_if_2              : axi4_tr_if_array_t;
    signal axi4_tr_if_3              : axi4_tr_if_array_t;
    signal axi4_tr_if_4              : axi4_tr_if_array_t;
    signal axi4_tr_if_5              : axi4_tr_if_array_t;
    signal axi4_tr_if_6              : axi4_tr_if_array_t;
    signal axi4_tr_if_7              : axi4_tr_if_array_t;
    signal axi4_tr_if_local          : axi4_tr_if_path_2d_array_t;
    signal axi4_tr_adv_if_local      : axi4_tr_adv_if_path_2d_array_t;

    -- Helper method to convert to integer
    function to_integer (OP: STD_LOGIC_VECTOR) return INTEGER;

    -- API: Master, Slave, Monitor
    -- This procedure sets the configuration of the BFM.
    procedure set_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         bfm_id        : in    integer;
                         signal tr_if  : inout axi4_vhd_if_struct_t);

    procedure set_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         bfm_id        : in    integer;
                         path_id       : in    axi4_path_t;
                         signal tr_if  : inout axi4_vhd_if_struct_t);

    procedure set_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : in    integer;
                         bfm_id        : in    integer;
                         signal tr_if  : inout axi4_vhd_if_struct_t);

    procedure set_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : in    integer;
                         bfm_id        : in    integer;
                         path_id       : in    axi4_path_t;
                         signal tr_if  : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- This procedure gets the configuration of the BFM.
    procedure get_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : out   std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         bfm_id        : in    integer;
                         signal tr_if  : inout axi4_vhd_if_struct_t);

    procedure get_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : out   std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         bfm_id        : in    integer;
                         path_id       : in    axi4_path_t;
                         signal tr_if  : inout axi4_vhd_if_struct_t);

    procedure get_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : out   integer;
                         bfm_id        : in    integer;
                         signal tr_if  : inout axi4_vhd_if_struct_t);

    procedure get_config(config_name   : in    std_logic_vector(7 downto 0);
                         config_val    : out   integer;
                         bfm_id        : in    integer;
                         path_id       : in    axi4_path_t;
                         signal tr_if  : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- This procedure creates a write transaction with the given parameters.
    procedure create_write_transaction(addr            : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi4_path_t;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi4_path_t;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in integer;
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in integer;
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi4_path_t;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_write_transaction(addr            : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi4_path_t;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- This procedure creates a read transaction with the given parameters.
    procedure create_read_transaction(addr            : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi4_path_t;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi4_path_t;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in integer;
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in integer;
                                       burst_length    : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi4_path_t;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure create_read_transaction(addr            : in integer;
                                       transaction_id  : out integer;
                                       bfm_id          : in integer;
                                       path_id         : in axi4_path_t;
                                       signal tr_if    : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- This field is set by default when creating a transaction.
    procedure set_read_or_write(read_or_write       : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_read_or_write(read_or_write       : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the read_or_write field of the transaction.
    procedure get_read_or_write(read_or_write       : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_read_or_write(read_or_write       : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the addr field of the transaction.
    procedure set_addr(addr                : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_addr(addr                : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_addr(addr                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_addr(addr                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the addr field of the transaction.
    procedure get_addr(addr                : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_addr(addr                : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_addr(addr                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_addr(addr                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the prot field of the transaction.
    procedure set_prot(prot                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_prot(prot                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the prot field of the transaction.
    procedure get_prot(prot                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_prot(prot                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the region field of the transaction.
    procedure set_region(region              : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_region(region              : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_region(region              : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_region(region              : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the region field of the transaction.
    procedure get_region(region              : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_region(region              : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_region(region              : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_region(region              : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the size field of the transaction.
    procedure set_size(size                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_size(size                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the size field of the transaction.
    procedure get_size(size                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_size(size                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the burst field of the transaction.
    procedure set_burst(burst               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_burst(burst               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the burst field of the transaction.
    procedure get_burst(burst               : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_burst(burst               : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the lock field of the transaction.
    procedure set_lock(lock                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_lock(lock                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the lock field of the transaction.
    procedure get_lock(lock                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_lock(lock                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the cache field of the transaction.
    procedure set_cache(cache               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_cache(cache               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the cache field of the transaction.
    procedure get_cache(cache               : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_cache(cache               : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the qos field of the transaction.
    procedure set_qos(qos                 : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_qos(qos                 : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_qos(qos                 : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_qos(qos                 : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the qos field of the transaction.
    procedure get_qos(qos                 : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_qos(qos                 : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_qos(qos                 : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_qos(qos                 : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the id field of the transaction.
    procedure set_id(id                  : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_id(id                  : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_id(id                  : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_id(id                  : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the id field of the transaction.
    procedure get_id(id                  : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_id(id                  : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_id(id                  : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_id(id                  : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the burst_length field of the transaction.
    procedure set_burst_length(burst_length        : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_burst_length(burst_length        : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_burst_length(burst_length        : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_burst_length(burst_length        : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the burst_length field of the transaction.
    procedure get_burst_length(burst_length        : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_burst_length(burst_length        : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_burst_length(burst_length        : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_burst_length(burst_length        : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the addr_user field of the transaction.
    procedure set_addr_user(addr_user           : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_addr_user(addr_user           : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_addr_user(addr_user           : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_addr_user(addr_user           : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the addr_user field of the transaction.
    procedure get_addr_user(addr_user           : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_addr_user(addr_user           : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_addr_user(addr_user           : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_addr_user(addr_user           : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the data_words field of the transaction.
    procedure set_data_words(data_words          : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_words(data_words          : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the data_words field of the transaction.
    procedure get_data_words(data_words          : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_words(data_words          : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the write_strobes field of the transaction.
    procedure set_write_strobes(write_strobes       : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_write_strobes(write_strobes       : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the write_strobes field of the transaction.
    procedure get_write_strobes(write_strobes       : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0 );
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_write_strobes(write_strobes       : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the resp field of the transaction.
    procedure set_resp(resp                : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_resp(resp                : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_resp(resp                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_resp(resp                : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the resp field of the transaction.
    procedure get_resp(resp                : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_resp(resp                : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_resp(resp                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_resp(resp                : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the address_valid_delay field of the transaction.
    procedure set_address_valid_delay(address_valid_delay : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_address_valid_delay(address_valid_delay : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the address_valid_delay field of the transaction.
    procedure get_address_valid_delay(address_valid_delay : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_address_valid_delay(address_valid_delay : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the data_valid_delay field of the transaction.
    procedure set_data_valid_delay(data_valid_delay    : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_valid_delay(data_valid_delay    : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_valid_delay(data_valid_delay    : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_valid_delay(data_valid_delay    : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the data_valid_delay field of the transaction.
    procedure get_data_valid_delay(data_valid_delay    : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_valid_delay(data_valid_delay    : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_valid_delay(data_valid_delay    : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_valid_delay(data_valid_delay    : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the write_response_valid_delay field of the transaction.
    procedure set_write_response_valid_delay(write_response_valid_delay: in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_write_response_valid_delay(write_response_valid_delay: in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the write_response_valid_delay field of the transaction.
    procedure get_write_response_valid_delay(write_response_valid_delay: out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_write_response_valid_delay(write_response_valid_delay: out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the address_ready_delay field of the transaction.
    procedure set_address_ready_delay(address_ready_delay : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_address_ready_delay(address_ready_delay : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the address_ready_delay field of the transaction.
    procedure get_address_ready_delay(address_ready_delay : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_address_ready_delay(address_ready_delay : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the data_ready_delay field of the transaction.
    procedure set_data_ready_delay(data_ready_delay    : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_ready_delay(data_ready_delay    : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_ready_delay(data_ready_delay    : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_ready_delay(data_ready_delay    : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the data_ready_delay field of the transaction.
    procedure get_data_ready_delay(data_ready_delay    : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_ready_delay(data_ready_delay    : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_ready_delay(data_ready_delay    : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_ready_delay(data_ready_delay    : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the write_response_ready_delay field of the transaction.
    procedure set_write_response_ready_delay(write_response_ready_delay: in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_write_response_ready_delay(write_response_ready_delay: in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the write_response_ready_delay field of the transaction.
    procedure get_write_response_ready_delay(write_response_ready_delay: out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_write_response_ready_delay(write_response_ready_delay: out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the gen_write_strobes field of the transaction.
    procedure set_gen_write_strobes(gen_write_strobes   : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_gen_write_strobes(gen_write_strobes   : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the gen_write_strobes field of the transaction.
    procedure get_gen_write_strobes(gen_write_strobes   : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_gen_write_strobes(gen_write_strobes   : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the operation_mode field of the transaction.
    procedure set_operation_mode(operation_mode      : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_operation_mode(operation_mode      : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the operation_mode field of the transaction.
    procedure get_operation_mode(operation_mode      : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_operation_mode(operation_mode      : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Set the write_data_mode field of the transaction.
    procedure set_write_data_mode(write_data_mode     : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_write_data_mode(write_data_mode     : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the write_data_mode field of the transaction.
    procedure get_write_data_mode(write_data_mode     : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_write_data_mode(write_data_mode     : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave
    -- Set the data_beat_done field of the transaction.
    procedure set_data_beat_done(data_beat_done      : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_beat_done(data_beat_done      : in    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_beat_done(data_beat_done      : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_data_beat_done(data_beat_done      : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the data_beat_done field of the transaction.
    procedure get_data_beat_done(data_beat_done      : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_beat_done(data_beat_done      : out    integer;
                    index               : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_beat_done(data_beat_done      : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_data_beat_done(data_beat_done      : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave
    -- Set the transaction_done field of the transaction.
    procedure set_transaction_done(transaction_done    : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure set_transaction_done(transaction_done    : in    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Get the transaction_done field of the transaction.
    procedure get_transaction_done(transaction_done    : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    procedure get_transaction_done(transaction_done    : out    integer;
                    transaction_id      : in    integer;
                    bfm_id              : in    integer;
                    path_id             : in    axi4_path_t;
                    signal tr_if        : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Execute a transaction defined by the paramters.
    procedure execute_transaction(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_transaction(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Execute a write_data_burst defined by the paramters.
    procedure execute_write_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_write_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Execute a read_addr_phase defined by the paramters.
    procedure execute_read_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_read_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master, Monitor
    -- Get a read_data_burst defined by the paramters.
    procedure get_read_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure get_read_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master, Monitor
    -- Get a read_data_phase defined by the paramters.
    procedure get_read_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     last         : out   integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure get_read_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     last         : out    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure get_read_data_phase(transaction_id  : in    integer;
                                     last         : out   integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure get_read_data_phase(transaction_id  : in    integer;
                                     last         : out    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Execute a write_addr_phase defined by the paramters.
    procedure execute_write_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_write_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Execute a write_data_phase defined by the paramters.
    procedure execute_write_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_write_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_write_data_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_write_data_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master, Monitor
    -- Get a write_response_phase defined by the paramters.
    procedure get_write_response_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure get_write_response_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master, Monitor
    -- Get a read_addr_ready defined by the paramters.
    procedure get_read_addr_ready(ready : out integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master, Monitor
    -- Get a read_data_cycle defined by the paramters.
    procedure get_read_data_cycle(bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Execute a read_data_ready defined by the paramters.
    procedure execute_read_data_ready(ready : in integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_read_data_ready(ready : in integer;
                                     non_blocking_mode : in integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master, Monitor
    -- Get a write_addr_ready defined by the paramters.
    procedure get_write_addr_ready(ready : out integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master, Monitor
    -- Get a write_data_ready defined by the paramters.
    procedure get_write_data_ready(ready : out integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master, Monitor
    -- Get a write_response_cycle defined by the paramters.
    procedure get_write_response_cycle(bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master
    -- Execute a write_resp_ready defined by the paramters.
    procedure execute_write_resp_ready(ready : in integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_write_resp_ready(ready : in integer;
                                     non_blocking_mode : in integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave
    -- Create a slave_transaction defined by the paramters.
    procedure create_slave_transaction(transaction_id  : out    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure create_slave_transaction(transaction_id  : out    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave, Monitor
    -- Get a write_data_burst defined by the paramters.
    procedure get_write_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure get_write_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave, Monitor
    -- Get a read_addr_phase defined by the paramters.
    procedure get_read_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure get_read_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave
    -- Execute a read_data_burst defined by the paramters.
    procedure execute_read_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_read_data_burst(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave
    -- Execute a read_data_phase defined by the paramters.
    procedure execute_read_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_read_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_read_data_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_read_data_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave, Monitor
    -- Get a write_addr_phase defined by the paramters.
    procedure get_write_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure get_write_addr_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave, Monitor
    -- Get a write_data_phase defined by the paramters.
    procedure get_write_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     last         : out   integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure get_write_data_phase(transaction_id  : in    integer;
                                     index        : in    integer;
                                     last         : out    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure get_write_data_phase(transaction_id  : in    integer;
                                     last         : out   integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure get_write_data_phase(transaction_id  : in    integer;
                                     last         : out    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave
    -- Execute a write_response_phase defined by the paramters.
    procedure execute_write_response_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_write_response_phase(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave, Monitor
    -- Get a read_addr_cycle defined by the paramters.
    procedure get_read_addr_cycle(bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave
    -- Execute a read_addr_ready defined by the paramters.
    procedure execute_read_addr_ready(ready : in integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_read_addr_ready(ready : in integer;
                                     non_blocking_mode : in integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave, Monitor
    -- Get a read_data_ready defined by the paramters.
    procedure get_read_data_ready(ready : out integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave, Monitor
    -- Get a write_addr_cycle defined by the paramters.
    procedure get_write_addr_cycle(bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave
    -- Execute a write_addr_ready defined by the paramters.
    procedure execute_write_addr_ready(ready : in integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_write_addr_ready(ready : in integer;
                                     non_blocking_mode : in integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave, Monitor
    -- Get a write_data_cycle defined by the paramters.
    procedure get_write_data_cycle(bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave
    -- Execute a write_data_ready defined by the paramters.
    procedure execute_write_data_ready(ready : in integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure execute_write_data_ready(ready : in integer;
                                     non_blocking_mode : in integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Slave, Monitor
    -- Get a write_resp_ready defined by the paramters.
    procedure get_write_resp_ready(ready : out integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_adv_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Monitor
    -- Create a monitor_transaction defined by the paramters.
    procedure create_monitor_transaction(transaction_id  : out    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure create_monitor_transaction(transaction_id  : out    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Monitor
    -- Get a rw_transaction defined by the paramters.
    procedure get_rw_transaction(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    procedure get_rw_transaction(transaction_id  : in    integer;
                                     bfm_id       : in    integer;
                                     path_id      : in    axi4_path_t;
                                     signal tr_if : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Push the transaction_id into the back of the queue.
    procedure push_transaction_id(transaction_id  : in integer;
                           queue_id        : in integer;
                           bfm_id          : in integer;
                           signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure push_transaction_id(transaction_id  : in integer;
                           queue_id        : in integer;
                           bfm_id          : in integer;
                           path_id         : in axi4_path_t;
                           signal tr_if    : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Pop the transaction_id from the front of the queue.
    procedure pop_transaction_id(transaction_id  : out integer;
                           queue_id        : in integer;
                           bfm_id          : in integer;
                           signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure pop_transaction_id(transaction_id  : out integer;
                           queue_id        : in integer;
                           bfm_id          : in integer;
                           path_id         : in axi4_path_t;
                           signal tr_if    : inout axi4_vhd_if_struct_t);

    -- API: Slave
    -- Returns the address and data of the given byte within a write_data_phase.
    procedure get_write_addr_data(transaction_id  : in  integer;
                    index           : in  integer;
                    byte_index      : in  integer;
                    dynamic_size    : out integer;
                    addr            : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                    data            : out std_logic_vector(7 downto 0);
                    bfm_id          : in  integer;
                    signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure get_write_addr_data(transaction_id  : in  integer;
                    index           : in  integer;
                    byte_index      : in  integer;
                    dynamic_size    : out integer;
                    addr            : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                    data            : out std_logic_vector(7 downto 0);
                    bfm_id          : in  integer;
                    path_id         : in  axi4_path_t;
                    signal tr_if    : inout axi4_vhd_if_struct_t);

    -- API: Slave
    -- Returns the address of the given byte within a read_data transaction.
    procedure get_read_addr(transaction_id  : in  integer;
                    index           : in  integer;
                    byte_index      : in  integer;
                    dynamic_size    : out integer;
                    addr            : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                    bfm_id          : in  integer;
                    signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure get_read_addr(transaction_id  : in  integer;
                    index           : in  integer;
                    byte_index      : in  integer;
                    dynamic_size    : out integer;
                    addr            : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                    bfm_id          : in  integer;
                    path_id         : in  axi4_path_t;
                    signal tr_if    : inout axi4_vhd_if_struct_t);

    -- API: Slave
    -- Set the given data byte within a read transaction.
    procedure set_read_data(transaction_id  : in integer;
                    index           : in integer;
                    byte_index      : in integer;
                    dynamic_size    : in integer;
                    addr            : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                    data            : in std_logic_vector(7 downto 0);
                    bfm_id          : in integer;
                    signal tr_if    : inout axi4_vhd_if_struct_t);

    procedure set_read_data(transaction_id  : in integer;
                    index           : in integer;
                    byte_index      : in integer;
                    dynamic_size    : in integer;
                    addr            : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                    data            : in std_logic_vector(7 downto 0);
                    bfm_id          : in integer;
                    path_id         : in axi4_path_t;
                    signal tr_if    : inout axi4_vhd_if_struct_t);

    -- API: Master, Slave, Monitor
    -- Print the transaction identified by the transaction_id.
    procedure print( transaction_id  : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi4_vhd_if_struct_t );

    procedure print( transaction_id  : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi4_path_t;
                    signal tr_if    : inout axi4_vhd_if_struct_t );

    procedure print( transaction_id  : in integer;
                    print_delays    : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi4_vhd_if_struct_t );

    procedure print( transaction_id  : in integer;
                    print_delays    : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi4_path_t;
                    signal tr_if    : inout axi4_vhd_if_struct_t );

    -- API: Master, Slave, Monitor
    -- Remove and clean up the transaction identified by the transaction_id.
    procedure destruct_transaction( transaction_id  : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi4_vhd_if_struct_t );

    procedure destruct_transaction( transaction_id  : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi4_path_t;
                    signal tr_if    : inout axi4_vhd_if_struct_t );

    -- API: Master, Slave, Monitor
    -- Wait for the event specified by the parameters.
    procedure wait_on( phase           : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi4_vhd_if_struct_t );

    procedure wait_on( phase           : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi4_path_t;
                    signal tr_if    : inout axi4_vhd_if_struct_t );

    procedure wait_on( phase           : in integer;
                    count           : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi4_vhd_if_struct_t );

    procedure wait_on( phase           : in integer;
                    count           : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi4_path_t;
                    signal tr_if    : inout axi4_vhd_if_struct_t );

    procedure wait_on( phase           : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi4_adv_path_t;
                    signal tr_if    : inout axi4_vhd_if_struct_t );

    procedure wait_on( phase           : in integer;
                    count           : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi4_adv_path_t;
                    signal tr_if    : inout axi4_vhd_if_struct_t );

end mgc_axi4_bfm_pkg;

-- Procedure implementations:
package body mgc_axi4_bfm_pkg is

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
                         config_val  : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         bfm_id       : in integer;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0   <= to_integer(config_name);
      tr_if.value_max <= config_val;
      tr_if.req(AXI4_VHD_SET_CONFIG) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_CONFIG) = '1');
      tr_if.req(AXI4_VHD_SET_CONFIG) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_CONFIG) = '0');
    end set_config;

    procedure set_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         bfm_id       : in integer;
                         path_id      : in axi4_path_t;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0   <= to_integer(config_name);
      tr_if.value_max <= config_val;
      tr_if.req(AXI4_VHD_SET_CONFIG) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_CONFIG) = '1');
      tr_if.req(AXI4_VHD_SET_CONFIG) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_CONFIG) = '0');
    end set_config;

    procedure set_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : in integer;
                         bfm_id       : in integer;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0   <= to_integer(config_name);
      tr_if.value_max <= conv_std_logic_vector(config_val, AXI4_MAX_BIT_SIZE);
      tr_if.req(AXI4_VHD_SET_CONFIG) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_CONFIG) = '1');
      tr_if.req(AXI4_VHD_SET_CONFIG) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_CONFIG) = '0');
    end set_config;

    procedure set_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : in integer;
                         bfm_id       : in integer;
                         path_id      : in axi4_path_t;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0   <= to_integer(config_name);
      tr_if.value_max <= conv_std_logic_vector(config_val, AXI4_MAX_BIT_SIZE);
      tr_if.req(AXI4_VHD_SET_CONFIG) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_CONFIG) = '1');
      tr_if.req(AXI4_VHD_SET_CONFIG) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_CONFIG) = '0');
    end set_config;

    procedure get_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         bfm_id       : in integer;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= to_integer(config_name);
      tr_if.req(AXI4_VHD_GET_CONFIG) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_CONFIG) = '1');
      tr_if.req(AXI4_VHD_GET_CONFIG) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_CONFIG) = '0');
      config_val := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max;
    end get_config;

    procedure get_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         bfm_id       : in integer;
                         path_id      : in axi4_path_t;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= to_integer(config_name);
      tr_if.req(AXI4_VHD_GET_CONFIG) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_CONFIG) = '1');
      tr_if.req(AXI4_VHD_GET_CONFIG) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_CONFIG) = '0');
      config_val := axi4_tr_if_local(bfm_id)(path_id).value_max;
    end get_config;

    procedure get_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : out integer;
                         bfm_id       : in integer;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= to_integer(config_name);
      tr_if.req(AXI4_VHD_GET_CONFIG) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_CONFIG) = '1');
      tr_if.req(AXI4_VHD_GET_CONFIG) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_CONFIG) = '0');
      config_val := to_integer(axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max);
    end get_config;

    procedure get_config(config_name : in std_logic_vector(7 downto 0);
                         config_val  : out integer;
                         bfm_id       : in integer;
                         path_id      : in axi4_path_t;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= to_integer(config_name);
      tr_if.req(AXI4_VHD_GET_CONFIG) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_CONFIG) = '1');
      tr_if.req(AXI4_VHD_GET_CONFIG) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_CONFIG) = '0');
      config_val := to_integer(axi4_tr_if_local(bfm_id)(path_id).value_max);
    end get_config;

    procedure create_write_transaction(addr : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi4_path_t;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= 0;
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi4_path_t;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= 0;
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in integer;
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI4_MAX_BIT_SIZE);
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in integer;
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi4_path_t;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI4_MAX_BIT_SIZE);
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI4_MAX_BIT_SIZE);
      tr_if.value_0     <= 0;
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).transaction_id;
    end create_write_transaction;

    procedure create_write_transaction(addr : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi4_path_t;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI4_MAX_BIT_SIZE);
      tr_if.value_0     <= 0;
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_WRITE_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_WRITE_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_write_transaction;

    procedure create_read_transaction(addr : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi4_path_t;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= 0;
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi4_path_t;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= addr;
      tr_if.value_0     <= 0;
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in integer;
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI4_MAX_BIT_SIZE);
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in integer;
                         burst_length  : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi4_path_t;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI4_MAX_BIT_SIZE);
      tr_if.value_0     <= burst_length;
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI4_MAX_BIT_SIZE);
      tr_if.value_0     <= 0;
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).transaction_id;
    end create_read_transaction;

    procedure create_read_transaction(addr : in integer;
                         transaction_id : out integer;
                         bfm_id         : in  integer;
                         path_id      : in axi4_path_t;
                         signal tr_if : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max   <= conv_std_logic_vector(addr, AXI4_MAX_BIT_SIZE);
      tr_if.value_0     <= 0;
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_READ_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_READ_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_read_transaction;

    procedure set_read_or_write(read_or_write       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= read_or_write;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_READ_OR_WRITE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_READ_OR_WRITE) = '1');
      tr_if.req(AXI4_VHD_SET_READ_OR_WRITE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_READ_OR_WRITE) = '0');
    end set_read_or_write;

    procedure set_read_or_write(read_or_write       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= read_or_write;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_READ_OR_WRITE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_READ_OR_WRITE) = '1');
      tr_if.req(AXI4_VHD_SET_READ_OR_WRITE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_READ_OR_WRITE) = '0');
    end set_read_or_write;

    procedure get_read_or_write(read_or_write       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_READ_OR_WRITE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_READ_OR_WRITE) = '1');
      tr_if.req(AXI4_VHD_GET_READ_OR_WRITE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_READ_OR_WRITE) = '0');
      read_or_write := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_read_or_write;

    procedure get_read_or_write(read_or_write       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_READ_OR_WRITE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_OR_WRITE) = '1');
      tr_if.req(AXI4_VHD_GET_READ_OR_WRITE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_OR_WRITE) = '0');
      read_or_write := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_read_or_write;

    procedure set_addr(addr       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= addr;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ADDR) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ADDR) = '1');
      tr_if.req(AXI4_VHD_SET_ADDR) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ADDR) = '0');
    end set_addr;

    procedure set_addr(addr       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= addr;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ADDR) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ADDR) = '1');
      tr_if.req(AXI4_VHD_SET_ADDR) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ADDR) = '0');
    end set_addr;

    procedure set_addr(addr       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(addr, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ADDR) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ADDR) = '1');
      tr_if.req(AXI4_VHD_SET_ADDR) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ADDR) = '0');
    end set_addr;

    procedure set_addr(addr       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(addr, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ADDR) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ADDR) = '1');
      tr_if.req(AXI4_VHD_SET_ADDR) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ADDR) = '0');
    end set_addr;

    procedure get_addr(addr       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ADDR) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ADDR) = '1');
      tr_if.req(AXI4_VHD_GET_ADDR) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ADDR) = '0');
      addr := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max;
    end get_addr;

    procedure get_addr(addr       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ADDR) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ADDR) = '1');
      tr_if.req(AXI4_VHD_GET_ADDR) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ADDR) = '0');
      addr := axi4_tr_if_local(bfm_id)(path_id).value_max;
    end get_addr;

    procedure get_addr(addr       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ADDR) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ADDR) = '1');
      tr_if.req(AXI4_VHD_GET_ADDR) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ADDR) = '0');
      addr := to_integer(axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max);
    end get_addr;

    procedure get_addr(addr       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ADDR) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ADDR) = '1');
      tr_if.req(AXI4_VHD_GET_ADDR) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ADDR) = '0');
      addr := to_integer(axi4_tr_if_local(bfm_id)(path_id).value_max);
    end get_addr;

    procedure set_prot(prot       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= prot;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_PROT) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_PROT) = '1');
      tr_if.req(AXI4_VHD_SET_PROT) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_PROT) = '0');
    end set_prot;

    procedure set_prot(prot       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= prot;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_PROT) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_PROT) = '1');
      tr_if.req(AXI4_VHD_SET_PROT) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_PROT) = '0');
    end set_prot;

    procedure get_prot(prot       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_PROT) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_PROT) = '1');
      tr_if.req(AXI4_VHD_GET_PROT) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_PROT) = '0');
      prot := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_prot;

    procedure get_prot(prot       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_PROT) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_PROT) = '1');
      tr_if.req(AXI4_VHD_GET_PROT) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_PROT) = '0');
      prot := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_prot;

    procedure set_region(region       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= region;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_REGION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_REGION) = '1');
      tr_if.req(AXI4_VHD_SET_REGION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_REGION) = '0');
    end set_region;

    procedure set_region(region       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= region;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_REGION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_REGION) = '1');
      tr_if.req(AXI4_VHD_SET_REGION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_REGION) = '0');
    end set_region;

    procedure set_region(region       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(region, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_REGION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_REGION) = '1');
      tr_if.req(AXI4_VHD_SET_REGION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_REGION) = '0');
    end set_region;

    procedure set_region(region       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(region, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_REGION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_REGION) = '1');
      tr_if.req(AXI4_VHD_SET_REGION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_REGION) = '0');
    end set_region;

    procedure get_region(region       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_REGION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_REGION) = '1');
      tr_if.req(AXI4_VHD_GET_REGION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_REGION) = '0');
      region := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max;
    end get_region;

    procedure get_region(region       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_REGION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_REGION) = '1');
      tr_if.req(AXI4_VHD_GET_REGION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_REGION) = '0');
      region := axi4_tr_if_local(bfm_id)(path_id).value_max;
    end get_region;

    procedure get_region(region       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_REGION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_REGION) = '1');
      tr_if.req(AXI4_VHD_GET_REGION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_REGION) = '0');
      region := to_integer(axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max);
    end get_region;

    procedure get_region(region       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_REGION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_REGION) = '1');
      tr_if.req(AXI4_VHD_GET_REGION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_REGION) = '0');
      region := to_integer(axi4_tr_if_local(bfm_id)(path_id).value_max);
    end get_region;

    procedure set_size(size       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= size;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_SIZE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_SIZE) = '1');
      tr_if.req(AXI4_VHD_SET_SIZE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_SIZE) = '0');
    end set_size;

    procedure set_size(size       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= size;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_SIZE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_SIZE) = '1');
      tr_if.req(AXI4_VHD_SET_SIZE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_SIZE) = '0');
    end set_size;

    procedure get_size(size       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_SIZE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_SIZE) = '1');
      tr_if.req(AXI4_VHD_GET_SIZE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_SIZE) = '0');
      size := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_size;

    procedure get_size(size       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_SIZE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_SIZE) = '1');
      tr_if.req(AXI4_VHD_GET_SIZE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_SIZE) = '0');
      size := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_size;

    procedure set_burst(burst       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= burst;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_BURST) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_BURST) = '1');
      tr_if.req(AXI4_VHD_SET_BURST) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_BURST) = '0');
    end set_burst;

    procedure set_burst(burst       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= burst;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_BURST) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_BURST) = '1');
      tr_if.req(AXI4_VHD_SET_BURST) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_BURST) = '0');
    end set_burst;

    procedure get_burst(burst       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_BURST) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_BURST) = '1');
      tr_if.req(AXI4_VHD_GET_BURST) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_BURST) = '0');
      burst := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_burst;

    procedure get_burst(burst       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_BURST) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_BURST) = '1');
      tr_if.req(AXI4_VHD_GET_BURST) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_BURST) = '0');
      burst := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_burst;

    procedure set_lock(lock       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= lock;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_LOCK) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_LOCK) = '1');
      tr_if.req(AXI4_VHD_SET_LOCK) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_LOCK) = '0');
    end set_lock;

    procedure set_lock(lock       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= lock;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_LOCK) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_LOCK) = '1');
      tr_if.req(AXI4_VHD_SET_LOCK) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_LOCK) = '0');
    end set_lock;

    procedure get_lock(lock       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_LOCK) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_LOCK) = '1');
      tr_if.req(AXI4_VHD_GET_LOCK) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_LOCK) = '0');
      lock := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_lock;

    procedure get_lock(lock       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_LOCK) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_LOCK) = '1');
      tr_if.req(AXI4_VHD_GET_LOCK) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_LOCK) = '0');
      lock := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_lock;

    procedure set_cache(cache       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= cache;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_CACHE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_CACHE) = '1');
      tr_if.req(AXI4_VHD_SET_CACHE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_CACHE) = '0');
    end set_cache;

    procedure set_cache(cache       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= cache;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_CACHE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_CACHE) = '1');
      tr_if.req(AXI4_VHD_SET_CACHE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_CACHE) = '0');
    end set_cache;

    procedure get_cache(cache       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_CACHE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_CACHE) = '1');
      tr_if.req(AXI4_VHD_GET_CACHE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_CACHE) = '0');
      cache := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_cache;

    procedure get_cache(cache       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_CACHE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_CACHE) = '1');
      tr_if.req(AXI4_VHD_GET_CACHE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_CACHE) = '0');
      cache := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_cache;

    procedure set_qos(qos       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= qos;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_QOS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_QOS) = '1');
      tr_if.req(AXI4_VHD_SET_QOS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_QOS) = '0');
    end set_qos;

    procedure set_qos(qos       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= qos;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_QOS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_QOS) = '1');
      tr_if.req(AXI4_VHD_SET_QOS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_QOS) = '0');
    end set_qos;

    procedure set_qos(qos       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(qos, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_QOS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_QOS) = '1');
      tr_if.req(AXI4_VHD_SET_QOS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_QOS) = '0');
    end set_qos;

    procedure set_qos(qos       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(qos, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_QOS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_QOS) = '1');
      tr_if.req(AXI4_VHD_SET_QOS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_QOS) = '0');
    end set_qos;

    procedure get_qos(qos       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_QOS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_QOS) = '1');
      tr_if.req(AXI4_VHD_GET_QOS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_QOS) = '0');
      qos := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max;
    end get_qos;

    procedure get_qos(qos       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_QOS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_QOS) = '1');
      tr_if.req(AXI4_VHD_GET_QOS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_QOS) = '0');
      qos := axi4_tr_if_local(bfm_id)(path_id).value_max;
    end get_qos;

    procedure get_qos(qos       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_QOS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_QOS) = '1');
      tr_if.req(AXI4_VHD_GET_QOS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_QOS) = '0');
      qos := to_integer(axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max);
    end get_qos;

    procedure get_qos(qos       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_QOS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_QOS) = '1');
      tr_if.req(AXI4_VHD_GET_QOS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_QOS) = '0');
      qos := to_integer(axi4_tr_if_local(bfm_id)(path_id).value_max);
    end get_qos;

    procedure set_id(id       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= id;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ID) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ID) = '1');
      tr_if.req(AXI4_VHD_SET_ID) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ID) = '0');
    end set_id;

    procedure set_id(id       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= id;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ID) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ID) = '1');
      tr_if.req(AXI4_VHD_SET_ID) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ID) = '0');
    end set_id;

    procedure set_id(id       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(id, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ID) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ID) = '1');
      tr_if.req(AXI4_VHD_SET_ID) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ID) = '0');
    end set_id;

    procedure set_id(id       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(id, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ID) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ID) = '1');
      tr_if.req(AXI4_VHD_SET_ID) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ID) = '0');
    end set_id;

    procedure get_id(id       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ID) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ID) = '1');
      tr_if.req(AXI4_VHD_GET_ID) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ID) = '0');
      id := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max;
    end get_id;

    procedure get_id(id       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ID) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ID) = '1');
      tr_if.req(AXI4_VHD_GET_ID) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ID) = '0');
      id := axi4_tr_if_local(bfm_id)(path_id).value_max;
    end get_id;

    procedure get_id(id       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ID) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ID) = '1');
      tr_if.req(AXI4_VHD_GET_ID) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ID) = '0');
      id := to_integer(axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max);
    end get_id;

    procedure get_id(id       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ID) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ID) = '1');
      tr_if.req(AXI4_VHD_GET_ID) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ID) = '0');
      id := to_integer(axi4_tr_if_local(bfm_id)(path_id).value_max);
    end get_id;

    procedure set_burst_length(burst_length       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= burst_length;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_BURST_LENGTH) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_BURST_LENGTH) = '1');
      tr_if.req(AXI4_VHD_SET_BURST_LENGTH) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_BURST_LENGTH) = '0');
    end set_burst_length;

    procedure set_burst_length(burst_length       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= burst_length;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_BURST_LENGTH) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_BURST_LENGTH) = '1');
      tr_if.req(AXI4_VHD_SET_BURST_LENGTH) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_BURST_LENGTH) = '0');
    end set_burst_length;

    procedure set_burst_length(burst_length       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(burst_length, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_BURST_LENGTH) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_BURST_LENGTH) = '1');
      tr_if.req(AXI4_VHD_SET_BURST_LENGTH) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_BURST_LENGTH) = '0');
    end set_burst_length;

    procedure set_burst_length(burst_length       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(burst_length, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_BURST_LENGTH) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_BURST_LENGTH) = '1');
      tr_if.req(AXI4_VHD_SET_BURST_LENGTH) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_BURST_LENGTH) = '0');
    end set_burst_length;

    procedure get_burst_length(burst_length       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_BURST_LENGTH) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_BURST_LENGTH) = '1');
      tr_if.req(AXI4_VHD_GET_BURST_LENGTH) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_BURST_LENGTH) = '0');
      burst_length := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max;
    end get_burst_length;

    procedure get_burst_length(burst_length       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_BURST_LENGTH) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_BURST_LENGTH) = '1');
      tr_if.req(AXI4_VHD_GET_BURST_LENGTH) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_BURST_LENGTH) = '0');
      burst_length := axi4_tr_if_local(bfm_id)(path_id).value_max;
    end get_burst_length;

    procedure get_burst_length(burst_length       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_BURST_LENGTH) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_BURST_LENGTH) = '1');
      tr_if.req(AXI4_VHD_GET_BURST_LENGTH) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_BURST_LENGTH) = '0');
      burst_length := to_integer(axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max);
    end get_burst_length;

    procedure get_burst_length(burst_length       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_BURST_LENGTH) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_BURST_LENGTH) = '1');
      tr_if.req(AXI4_VHD_GET_BURST_LENGTH) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_BURST_LENGTH) = '0');
      burst_length := to_integer(axi4_tr_if_local(bfm_id)(path_id).value_max);
    end get_burst_length;

    procedure set_addr_user(addr_user       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= addr_user;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ADDR_USER) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ADDR_USER) = '1');
      tr_if.req(AXI4_VHD_SET_ADDR_USER) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ADDR_USER) = '0');
    end set_addr_user;

    procedure set_addr_user(addr_user       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= addr_user;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ADDR_USER) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ADDR_USER) = '1');
      tr_if.req(AXI4_VHD_SET_ADDR_USER) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ADDR_USER) = '0');
    end set_addr_user;

    procedure set_addr_user(addr_user       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(addr_user, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ADDR_USER) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ADDR_USER) = '1');
      tr_if.req(AXI4_VHD_SET_ADDR_USER) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ADDR_USER) = '0');
    end set_addr_user;

    procedure set_addr_user(addr_user       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(addr_user, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ADDR_USER) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ADDR_USER) = '1');
      tr_if.req(AXI4_VHD_SET_ADDR_USER) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ADDR_USER) = '0');
    end set_addr_user;

    procedure get_addr_user(addr_user       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ADDR_USER) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ADDR_USER) = '1');
      tr_if.req(AXI4_VHD_GET_ADDR_USER) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ADDR_USER) = '0');
      addr_user := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max;
    end get_addr_user;

    procedure get_addr_user(addr_user       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ADDR_USER) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ADDR_USER) = '1');
      tr_if.req(AXI4_VHD_GET_ADDR_USER) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ADDR_USER) = '0');
      addr_user := axi4_tr_if_local(bfm_id)(path_id).value_max;
    end get_addr_user;

    procedure get_addr_user(addr_user       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ADDR_USER) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ADDR_USER) = '1');
      tr_if.req(AXI4_VHD_GET_ADDR_USER) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ADDR_USER) = '0');
      addr_user := to_integer(axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max);
    end get_addr_user;

    procedure get_addr_user(addr_user       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ADDR_USER) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ADDR_USER) = '1');
      tr_if.req(AXI4_VHD_GET_ADDR_USER) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ADDR_USER) = '0');
      addr_user := to_integer(axi4_tr_if_local(bfm_id)(path_id).value_max);
    end get_addr_user;

    procedure set_data_words(data_words       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= data_words;
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= data_words;
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= data_words;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= data_words;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(data_words, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(data_words, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(data_words, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure set_data_words(data_words       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(data_words, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_WORDS) = '0');
    end set_data_words;

    procedure get_data_words(data_words       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_WORDS) = '0');
      data_words := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max;
    end get_data_words;

    procedure get_data_words(data_words       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_WORDS) = '0');
      data_words := axi4_tr_if_local(bfm_id)(path_id).value_max;
    end get_data_words;

    procedure get_data_words(data_words       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_WORDS) = '0');
      data_words := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max;
    end get_data_words;

    procedure get_data_words(data_words       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_WORDS) = '0');
      data_words := axi4_tr_if_local(bfm_id)(path_id).value_max;
    end get_data_words;

    procedure get_data_words(data_words       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_WORDS) = '0');
      data_words := to_integer(axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max);
    end get_data_words;

    procedure get_data_words(data_words       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_WORDS) = '0');
      data_words := to_integer(axi4_tr_if_local(bfm_id)(path_id).value_max);
    end get_data_words;

    procedure get_data_words(data_words       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_WORDS) = '0');
      data_words := to_integer(axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max);
    end get_data_words;

    procedure get_data_words(data_words       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_WORDS) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_WORDS) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_WORDS) = '0');
      data_words := to_integer(axi4_tr_if_local(bfm_id)(path_id).value_max);
    end get_data_words;

    procedure set_write_strobes(write_strobes       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= write_strobes;
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= write_strobes;
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= write_strobes;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= write_strobes;
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(write_strobes, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(write_strobes, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(write_strobes, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure set_write_strobes(write_strobes       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_max       <= conv_std_logic_vector(write_strobes, AXI4_MAX_BIT_SIZE);
      tr_if.value_0         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_STROBES) = '0');
    end set_write_strobes;

    procedure get_write_strobes(write_strobes       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max;
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := axi4_tr_if_local(bfm_id)(path_id).value_max;
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max;
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := axi4_tr_if_local(bfm_id)(path_id).value_max;
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := to_integer(axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max);
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := to_integer(axi4_tr_if_local(bfm_id)(path_id).value_max);
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := to_integer(axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max);
    end get_write_strobes;

    procedure get_write_strobes(write_strobes       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_STROBES) = '0');
      write_strobes := to_integer(axi4_tr_if_local(bfm_id)(path_id).value_max);
    end get_write_strobes;

    procedure set_resp(resp       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= resp;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_RESP) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_RESP) = '1');
      tr_if.req(AXI4_VHD_SET_RESP) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_RESP) = '0');
    end set_resp;

    procedure set_resp(resp       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= resp;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_RESP) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_RESP) = '1');
      tr_if.req(AXI4_VHD_SET_RESP) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_RESP) = '0');
    end set_resp;

    procedure set_resp(resp       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= resp;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_RESP) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_RESP) = '1');
      tr_if.req(AXI4_VHD_SET_RESP) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_RESP) = '0');
    end set_resp;

    procedure set_resp(resp       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= resp;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_RESP) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_RESP) = '1');
      tr_if.req(AXI4_VHD_SET_RESP) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_RESP) = '0');
    end set_resp;

    procedure get_resp(resp       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_RESP) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_RESP) = '1');
      tr_if.req(AXI4_VHD_GET_RESP) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_RESP) = '0');
      resp := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_resp;

    procedure get_resp(resp       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_RESP) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_RESP) = '1');
      tr_if.req(AXI4_VHD_GET_RESP) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_RESP) = '0');
      resp := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_resp;

    procedure get_resp(resp       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_RESP) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_RESP) = '1');
      tr_if.req(AXI4_VHD_GET_RESP) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_RESP) = '0');
      resp := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_resp;

    procedure get_resp(resp       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_RESP) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_RESP) = '1');
      tr_if.req(AXI4_VHD_GET_RESP) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_RESP) = '0');
      resp := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_resp;

    procedure set_address_valid_delay(address_valid_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= address_valid_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ADDRESS_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ADDRESS_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_ADDRESS_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ADDRESS_VALID_DELAY) = '0');
    end set_address_valid_delay;

    procedure set_address_valid_delay(address_valid_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= address_valid_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ADDRESS_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ADDRESS_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_ADDRESS_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ADDRESS_VALID_DELAY) = '0');
    end set_address_valid_delay;

    procedure get_address_valid_delay(address_valid_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ADDRESS_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ADDRESS_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_ADDRESS_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ADDRESS_VALID_DELAY) = '0');
      address_valid_delay := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_address_valid_delay;

    procedure get_address_valid_delay(address_valid_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ADDRESS_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ADDRESS_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_ADDRESS_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ADDRESS_VALID_DELAY) = '0');
      address_valid_delay := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_address_valid_delay;

    procedure set_data_valid_delay(data_valid_delay       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_valid_delay;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_VALID_DELAY) = '0');
    end set_data_valid_delay;

    procedure set_data_valid_delay(data_valid_delay       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_valid_delay;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_VALID_DELAY) = '0');
    end set_data_valid_delay;

    procedure set_data_valid_delay(data_valid_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_valid_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_VALID_DELAY) = '0');
    end set_data_valid_delay;

    procedure set_data_valid_delay(data_valid_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_valid_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_VALID_DELAY) = '0');
    end set_data_valid_delay;

    procedure get_data_valid_delay(data_valid_delay       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_VALID_DELAY) = '0');
      data_valid_delay := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_data_valid_delay;

    procedure get_data_valid_delay(data_valid_delay       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_VALID_DELAY) = '0');
      data_valid_delay := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_data_valid_delay;

    procedure get_data_valid_delay(data_valid_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_VALID_DELAY) = '0');
      data_valid_delay := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_data_valid_delay;

    procedure get_data_valid_delay(data_valid_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_VALID_DELAY) = '0');
      data_valid_delay := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_data_valid_delay;

    procedure set_write_response_valid_delay(write_response_valid_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= write_response_valid_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_RESPONSE_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_RESPONSE_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_RESPONSE_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_RESPONSE_VALID_DELAY) = '0');
    end set_write_response_valid_delay;

    procedure set_write_response_valid_delay(write_response_valid_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= write_response_valid_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_RESPONSE_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_RESPONSE_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_RESPONSE_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_RESPONSE_VALID_DELAY) = '0');
    end set_write_response_valid_delay;

    procedure get_write_response_valid_delay(write_response_valid_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_RESPONSE_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_RESPONSE_VALID_DELAY) = '0');
      write_response_valid_delay := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_write_response_valid_delay;

    procedure get_write_response_valid_delay(write_response_valid_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_VALID_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_RESPONSE_VALID_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_VALID_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_RESPONSE_VALID_DELAY) = '0');
      write_response_valid_delay := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_write_response_valid_delay;

    procedure set_address_ready_delay(address_ready_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= address_ready_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ADDRESS_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ADDRESS_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_ADDRESS_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_ADDRESS_READY_DELAY) = '0');
    end set_address_ready_delay;

    procedure set_address_ready_delay(address_ready_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= address_ready_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_ADDRESS_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ADDRESS_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_ADDRESS_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_ADDRESS_READY_DELAY) = '0');
    end set_address_ready_delay;

    procedure get_address_ready_delay(address_ready_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ADDRESS_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ADDRESS_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_ADDRESS_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_ADDRESS_READY_DELAY) = '0');
      address_ready_delay := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_address_ready_delay;

    procedure get_address_ready_delay(address_ready_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_ADDRESS_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ADDRESS_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_ADDRESS_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_ADDRESS_READY_DELAY) = '0');
      address_ready_delay := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_address_ready_delay;

    procedure set_data_ready_delay(data_ready_delay       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_ready_delay;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_READY_DELAY) = '0');
    end set_data_ready_delay;

    procedure set_data_ready_delay(data_ready_delay       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_ready_delay;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_READY_DELAY) = '0');
    end set_data_ready_delay;

    procedure set_data_ready_delay(data_ready_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_ready_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_READY_DELAY) = '0');
    end set_data_ready_delay;

    procedure set_data_ready_delay(data_ready_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_ready_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_READY_DELAY) = '0');
    end set_data_ready_delay;

    procedure get_data_ready_delay(data_ready_delay       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_READY_DELAY) = '0');
      data_ready_delay := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_data_ready_delay;

    procedure get_data_ready_delay(data_ready_delay       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_READY_DELAY) = '0');
      data_ready_delay := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_data_ready_delay;

    procedure get_data_ready_delay(data_ready_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_READY_DELAY) = '0');
      data_ready_delay := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_data_ready_delay;

    procedure get_data_ready_delay(data_ready_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_READY_DELAY) = '0');
      data_ready_delay := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_data_ready_delay;

    procedure set_write_response_ready_delay(write_response_ready_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= write_response_ready_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_RESPONSE_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_RESPONSE_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_RESPONSE_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_RESPONSE_READY_DELAY) = '0');
    end set_write_response_ready_delay;

    procedure set_write_response_ready_delay(write_response_ready_delay       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= write_response_ready_delay;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_RESPONSE_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_RESPONSE_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_RESPONSE_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_RESPONSE_READY_DELAY) = '0');
    end set_write_response_ready_delay;

    procedure get_write_response_ready_delay(write_response_ready_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_RESPONSE_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_RESPONSE_READY_DELAY) = '0');
      write_response_ready_delay := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_write_response_ready_delay;

    procedure get_write_response_ready_delay(write_response_ready_delay       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_READY_DELAY) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_RESPONSE_READY_DELAY) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_READY_DELAY) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_RESPONSE_READY_DELAY) = '0');
      write_response_ready_delay := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_write_response_ready_delay;

    procedure set_gen_write_strobes(gen_write_strobes       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= gen_write_strobes;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_GEN_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_GEN_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_SET_GEN_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_GEN_WRITE_STROBES) = '0');
    end set_gen_write_strobes;

    procedure set_gen_write_strobes(gen_write_strobes       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= gen_write_strobes;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_GEN_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_GEN_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_SET_GEN_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_GEN_WRITE_STROBES) = '0');
    end set_gen_write_strobes;

    procedure get_gen_write_strobes(gen_write_strobes       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_GEN_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_GEN_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_GET_GEN_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_GEN_WRITE_STROBES) = '0');
      gen_write_strobes := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_gen_write_strobes;

    procedure get_gen_write_strobes(gen_write_strobes       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_GEN_WRITE_STROBES) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_GEN_WRITE_STROBES) = '1');
      tr_if.req(AXI4_VHD_GET_GEN_WRITE_STROBES) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_GEN_WRITE_STROBES) = '0');
      gen_write_strobes := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_gen_write_strobes;

    procedure set_operation_mode(operation_mode       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= operation_mode;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_OPERATION_MODE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_OPERATION_MODE) = '1');
      tr_if.req(AXI4_VHD_SET_OPERATION_MODE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_OPERATION_MODE) = '0');
    end set_operation_mode;

    procedure set_operation_mode(operation_mode       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= operation_mode;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_OPERATION_MODE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_OPERATION_MODE) = '1');
      tr_if.req(AXI4_VHD_SET_OPERATION_MODE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_OPERATION_MODE) = '0');
    end set_operation_mode;

    procedure get_operation_mode(operation_mode       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_OPERATION_MODE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_OPERATION_MODE) = '1');
      tr_if.req(AXI4_VHD_GET_OPERATION_MODE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_OPERATION_MODE) = '0');
      operation_mode := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_operation_mode;

    procedure get_operation_mode(operation_mode       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_OPERATION_MODE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_OPERATION_MODE) = '1');
      tr_if.req(AXI4_VHD_GET_OPERATION_MODE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_OPERATION_MODE) = '0');
      operation_mode := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_operation_mode;

    procedure set_write_data_mode(write_data_mode       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= write_data_mode;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_DATA_MODE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_DATA_MODE) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_DATA_MODE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_WRITE_DATA_MODE) = '0');
    end set_write_data_mode;

    procedure set_write_data_mode(write_data_mode       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= write_data_mode;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_WRITE_DATA_MODE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_DATA_MODE) = '1');
      tr_if.req(AXI4_VHD_SET_WRITE_DATA_MODE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_WRITE_DATA_MODE) = '0');
    end set_write_data_mode;

    procedure get_write_data_mode(write_data_mode       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_MODE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_DATA_MODE) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_MODE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_DATA_MODE) = '0');
      write_data_mode := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_write_data_mode;

    procedure get_write_data_mode(write_data_mode       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_MODE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_DATA_MODE) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_MODE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_DATA_MODE) = '0');
      write_data_mode := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_write_data_mode;

    procedure set_data_beat_done(data_beat_done       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_beat_done;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_BEAT_DONE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_BEAT_DONE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_BEAT_DONE) = '0');
    end set_data_beat_done;

    procedure set_data_beat_done(data_beat_done       : in integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_beat_done;
      tr_if.value_1         <= index;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_BEAT_DONE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_BEAT_DONE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_BEAT_DONE) = '0');
    end set_data_beat_done;

    procedure set_data_beat_done(data_beat_done       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_beat_done;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_BEAT_DONE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_BEAT_DONE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_DATA_BEAT_DONE) = '0');
    end set_data_beat_done;

    procedure set_data_beat_done(data_beat_done       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= data_beat_done;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_DATA_BEAT_DONE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI4_VHD_SET_DATA_BEAT_DONE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_DATA_BEAT_DONE) = '0');
    end set_data_beat_done;

    procedure get_data_beat_done(data_beat_done       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_BEAT_DONE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_BEAT_DONE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_BEAT_DONE) = '0');
      data_beat_done := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_data_beat_done;

    procedure get_data_beat_done(data_beat_done       : out integer;
                          index          : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= index;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_BEAT_DONE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_BEAT_DONE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_BEAT_DONE) = '0');
      data_beat_done := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_data_beat_done;

    procedure get_data_beat_done(data_beat_done       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_BEAT_DONE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_BEAT_DONE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_DATA_BEAT_DONE) = '0');
      data_beat_done := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_data_beat_done;

    procedure get_data_beat_done(data_beat_done       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_DATA_BEAT_DONE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_BEAT_DONE) = '1');
      tr_if.req(AXI4_VHD_GET_DATA_BEAT_DONE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_DATA_BEAT_DONE) = '0');
      data_beat_done := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_data_beat_done;

    procedure set_transaction_done(transaction_done       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= transaction_done;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_TRANSACTION_DONE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_TRANSACTION_DONE) = '1');
      tr_if.req(AXI4_VHD_SET_TRANSACTION_DONE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_TRANSACTION_DONE) = '0');
    end set_transaction_done;

    procedure set_transaction_done(transaction_done       : in integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0         <= transaction_done;
      tr_if.value_1         <= 0;
      tr_if.transaction_id  <= transaction_id;
      tr_if.req(AXI4_VHD_SET_TRANSACTION_DONE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_TRANSACTION_DONE) = '1');
      tr_if.req(AXI4_VHD_SET_TRANSACTION_DONE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_TRANSACTION_DONE) = '0');
    end set_transaction_done;

    procedure get_transaction_done(transaction_done       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_TRANSACTION_DONE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_TRANSACTION_DONE) = '1');
      tr_if.req(AXI4_VHD_GET_TRANSACTION_DONE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_TRANSACTION_DONE) = '0');
      transaction_done := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_transaction_done;

    procedure get_transaction_done(transaction_done       : out integer;
                          transaction_id : in integer;
                          bfm_id         : in integer;
                          path_id        : in axi4_path_t;
                          signal tr_if       : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0              <= 0;
      tr_if.transaction_id       <= transaction_id;
      tr_if.req(AXI4_VHD_GET_TRANSACTION_DONE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_TRANSACTION_DONE) = '1');
      tr_if.req(AXI4_VHD_GET_TRANSACTION_DONE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_TRANSACTION_DONE) = '0');
      transaction_done := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_transaction_done;

    procedure execute_transaction(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_TRANSACTION) = '0');
    end execute_transaction;

    procedure execute_transaction(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_TRANSACTION) = '0');
    end execute_transaction;

    procedure execute_write_data_burst(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_BURST) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_WRITE_DATA_BURST) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_BURST) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_WRITE_DATA_BURST) = '0');
    end execute_write_data_burst;

    procedure execute_write_data_burst(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_BURST) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_DATA_BURST) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_BURST) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_DATA_BURST) = '0');
    end execute_write_data_burst;

    procedure execute_read_addr_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_READ_ADDR_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_READ_ADDR_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_READ_ADDR_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_READ_ADDR_PHASE) = '0');
    end execute_read_addr_phase;

    procedure execute_read_addr_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_READ_ADDR_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_ADDR_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_READ_ADDR_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_ADDR_PHASE) = '0');
    end execute_read_addr_phase;

    procedure get_read_data_burst(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_READ_DATA_BURST) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_READ_DATA_BURST) = '1');
      tr_if.req(AXI4_VHD_GET_READ_DATA_BURST) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_READ_DATA_BURST) = '0');
    end get_read_data_burst;

    procedure get_read_data_burst(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_READ_DATA_BURST) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_DATA_BURST) = '1');
      tr_if.req(AXI4_VHD_GET_READ_DATA_BURST) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_DATA_BURST) = '0');
    end get_read_data_burst;

    procedure get_read_data_phase(transaction_id  : in integer;
                              index           : in  integer; 
                              last            : out integer; 
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI4_VHD_GET_READ_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_READ_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_READ_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_READ_DATA_PHASE) = '0');
      last           := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_read_data_phase;

    procedure get_read_data_phase(transaction_id  : in integer;
                              index           : in  integer; 
                              last            : out integer; 
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI4_VHD_GET_READ_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_READ_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_DATA_PHASE) = '0');
      last           := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_read_data_phase;

    procedure get_read_data_phase(transaction_id  : in integer;
                              last            : out integer; 
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_READ_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_READ_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_READ_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_READ_DATA_PHASE) = '0');
      last           := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_read_data_phase;

    procedure get_read_data_phase(transaction_id  : in integer;
                              last            : out integer; 
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_READ_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_READ_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_DATA_PHASE) = '0');
      last           := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_read_data_phase;

    procedure execute_write_addr_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_ADDR_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_WRITE_ADDR_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_ADDR_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_WRITE_ADDR_PHASE) = '0');
    end execute_write_addr_phase;

    procedure execute_write_addr_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_ADDR_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_ADDR_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_ADDR_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_ADDR_PHASE) = '0');
    end execute_write_addr_phase;

    procedure execute_write_data_phase(transaction_id  : in integer;
                              index           : in  integer; 
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) = '0');
    end execute_write_data_phase;

    procedure execute_write_data_phase(transaction_id  : in integer;
                              index           : in  integer; 
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) = '0');
    end execute_write_data_phase;

    procedure execute_write_data_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) = '0');
    end execute_write_data_phase;

    procedure execute_write_data_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_DATA_PHASE) = '0');
    end execute_write_data_phase;

    procedure get_write_response_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_RESPONSE_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_RESPONSE_PHASE) = '0');
    end get_write_response_phase;

    procedure get_write_response_phase(transaction_id  : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_RESPONSE_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_RESPONSE_PHASE) = '0');
    end get_write_response_phase;

    procedure get_read_addr_ready(ready : out integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.req(AXI4_VHD_GET_READ_ADDR_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_ADDR_READY) = '1');
      tr_if.req(AXI4_VHD_GET_READ_ADDR_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_ADDR_READY) = '0');
      ready := axi4_tr_adv_if_local(bfm_id)(path_id).value_0;
    end get_read_addr_ready;

    procedure get_read_data_cycle(bfm_id          : in  integer; 
                              path_id         : in  axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.req(AXI4_VHD_GET_READ_DATA_CYCLE) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_DATA_CYCLE) = '1');
      tr_if.req(AXI4_VHD_GET_READ_DATA_CYCLE) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_DATA_CYCLE) = '0');
    end get_read_data_cycle;

    procedure execute_read_data_ready(ready : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= ready;
      tr_if.value_1        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_DATA_READY) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_DATA_READY) = '0');
    end execute_read_data_ready;

    procedure execute_read_data_ready(ready : in integer;
                              non_blocking_mode : in integer; 
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= ready;
      tr_if.value_1        <= non_blocking_mode;
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_DATA_READY) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_DATA_READY) = '0');
    end execute_read_data_ready;

    procedure get_write_addr_ready(ready : out integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.req(AXI4_VHD_GET_WRITE_ADDR_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_ADDR_READY) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_ADDR_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_ADDR_READY) = '0');
      ready := axi4_tr_adv_if_local(bfm_id)(path_id).value_0;
    end get_write_addr_ready;

    procedure get_write_data_ready(ready : out integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_DATA_READY) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_DATA_READY) = '0');
      ready := axi4_tr_adv_if_local(bfm_id)(path_id).value_0;
    end get_write_data_ready;

    procedure get_write_response_cycle(bfm_id          : in  integer; 
                              path_id         : in  axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_CYCLE) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_RESPONSE_CYCLE) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_RESPONSE_CYCLE) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_RESPONSE_CYCLE) = '0');
    end get_write_response_cycle;

    procedure execute_write_resp_ready(ready : in integer;
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= ready;
      tr_if.value_1        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_RESP_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_RESP_READY) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_RESP_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_RESP_READY) = '0');
    end execute_write_resp_ready;

    procedure execute_write_resp_ready(ready : in integer;
                              non_blocking_mode : in integer; 
                              bfm_id          : in  integer; 
                              path_id         : in  axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= ready;
      tr_if.value_1        <= non_blocking_mode;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_RESP_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_RESP_READY) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_RESP_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_RESP_READY) = '0');
    end execute_write_resp_ready;

    procedure create_slave_transaction(transaction_id  : out integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_CREATE_SLAVE_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_SLAVE_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_SLAVE_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_SLAVE_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).transaction_id;
    end create_slave_transaction;

    procedure create_slave_transaction(transaction_id  : out integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_CREATE_SLAVE_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_SLAVE_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_SLAVE_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_SLAVE_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_slave_transaction;

    procedure get_write_data_burst(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_BURST) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_DATA_BURST) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_BURST) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_DATA_BURST) = '0');
    end get_write_data_burst;

    procedure get_write_data_burst(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_BURST) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_DATA_BURST) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_BURST) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_DATA_BURST) = '0');
    end get_write_data_burst;

    procedure get_read_addr_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_READ_ADDR_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_READ_ADDR_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_READ_ADDR_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_READ_ADDR_PHASE) = '0');
    end get_read_addr_phase;

    procedure get_read_addr_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_READ_ADDR_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_ADDR_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_READ_ADDR_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_ADDR_PHASE) = '0');
    end get_read_addr_phase;

    procedure execute_read_data_burst(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_BURST) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_READ_DATA_BURST) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_BURST) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_READ_DATA_BURST) = '0');
    end execute_read_data_burst;

    procedure execute_read_data_burst(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_BURST) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_DATA_BURST) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_BURST) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_DATA_BURST) = '0');
    end execute_read_data_burst;

    procedure execute_read_data_phase(transaction_id  : in integer;
                              index           : in integer; 
                              bfm_id          : in integer;
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_READ_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_READ_DATA_PHASE) = '0');
    end execute_read_data_phase;

    procedure execute_read_data_phase(transaction_id  : in integer;
                              index           : in integer; 
                              bfm_id          : in integer;
                              path_id         : in axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_DATA_PHASE) = '0');
    end execute_read_data_phase;

    procedure execute_read_data_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_READ_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_READ_DATA_PHASE) = '0');
    end execute_read_data_phase;

    procedure execute_read_data_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_READ_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_DATA_PHASE) = '0');
    end execute_read_data_phase;

    procedure get_write_addr_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_WRITE_ADDR_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_ADDR_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_ADDR_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_ADDR_PHASE) = '0');
    end get_write_addr_phase;

    procedure get_write_addr_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_WRITE_ADDR_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_ADDR_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_ADDR_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_ADDR_PHASE) = '0');
    end get_write_addr_phase;

    procedure get_write_data_phase(transaction_id  : in integer;
                              index           : in integer; 
                              last            : out integer; 
                              bfm_id          : in integer;
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_DATA_PHASE) = '0');
      last           := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_write_data_phase;

    procedure get_write_data_phase(transaction_id  : in integer;
                              index           : in integer; 
                              last            : out integer; 
                              bfm_id          : in integer;
                              path_id         : in axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= index;
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_DATA_PHASE) = '0');
      last           := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_write_data_phase;

    procedure get_write_data_phase(transaction_id  : in integer;
                              last            : out integer; 
                              bfm_id          : in integer;
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_DATA_PHASE) = '0');
      last           := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
    end get_write_data_phase;

    procedure get_write_data_phase(transaction_id  : in integer;
                              last            : out integer; 
                              bfm_id          : in integer;
                              path_id         : in axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_DATA_PHASE) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_DATA_PHASE) = '0');
      last           := axi4_tr_if_local(bfm_id)(path_id).value_0;
    end get_write_data_phase;

    procedure execute_write_response_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_RESPONSE_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_WRITE_RESPONSE_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_RESPONSE_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_EXECUTE_WRITE_RESPONSE_PHASE) = '0');
    end execute_write_response_phase;

    procedure execute_write_response_phase(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_RESPONSE_PHASE) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_RESPONSE_PHASE) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_RESPONSE_PHASE) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_RESPONSE_PHASE) = '0');
    end execute_write_response_phase;

    procedure get_read_addr_cycle(bfm_id          : in integer;
                              path_id         : in axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.req(AXI4_VHD_GET_READ_ADDR_CYCLE) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_ADDR_CYCLE) = '1');
      tr_if.req(AXI4_VHD_GET_READ_ADDR_CYCLE) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_ADDR_CYCLE) = '0');
    end get_read_addr_cycle;

    procedure execute_read_addr_ready(ready : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= ready;
      tr_if.value_1        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_READ_ADDR_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_ADDR_READY) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_READ_ADDR_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_ADDR_READY) = '0');
    end execute_read_addr_ready;

    procedure execute_read_addr_ready(ready : in integer;
                              non_blocking_mode : in integer; 
                              bfm_id          : in integer;
                              path_id         : in axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= ready;
      tr_if.value_1        <= non_blocking_mode;
      tr_if.req(AXI4_VHD_EXECUTE_READ_ADDR_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_ADDR_READY) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_READ_ADDR_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_READ_ADDR_READY) = '0');
    end execute_read_addr_ready;

    procedure get_read_data_ready(ready : out integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.req(AXI4_VHD_GET_READ_DATA_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_DATA_READY) = '1');
      tr_if.req(AXI4_VHD_GET_READ_DATA_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_DATA_READY) = '0');
      ready := axi4_tr_adv_if_local(bfm_id)(path_id).value_0;
    end get_read_data_ready;

    procedure get_write_addr_cycle(bfm_id          : in integer;
                              path_id         : in axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.req(AXI4_VHD_GET_WRITE_ADDR_CYCLE) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_ADDR_CYCLE) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_ADDR_CYCLE) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_ADDR_CYCLE) = '0');
    end get_write_addr_cycle;

    procedure execute_write_addr_ready(ready : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= ready;
      tr_if.value_1        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_ADDR_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_ADDR_READY) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_ADDR_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_ADDR_READY) = '0');
    end execute_write_addr_ready;

    procedure execute_write_addr_ready(ready : in integer;
                              non_blocking_mode : in integer; 
                              bfm_id          : in integer;
                              path_id         : in axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= ready;
      tr_if.value_1        <= non_blocking_mode;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_ADDR_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_ADDR_READY) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_ADDR_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_ADDR_READY) = '0');
    end execute_write_addr_ready;

    procedure get_write_data_cycle(bfm_id          : in integer;
                              path_id         : in axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_CYCLE) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_DATA_CYCLE) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_DATA_CYCLE) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_DATA_CYCLE) = '0');
    end get_write_data_cycle;

    procedure execute_write_data_ready(ready : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= ready;
      tr_if.value_1        <= 0;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_DATA_READY) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_DATA_READY) = '0');
    end execute_write_data_ready;

    procedure execute_write_data_ready(ready : in integer;
                              non_blocking_mode : in integer; 
                              bfm_id          : in integer;
                              path_id         : in axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= ready;
      tr_if.value_1        <= non_blocking_mode;
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_DATA_READY) = '1');
      tr_if.req(AXI4_VHD_EXECUTE_WRITE_DATA_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_EXECUTE_WRITE_DATA_READY) = '0');
    end execute_write_data_ready;

    procedure get_write_resp_ready(ready : out integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_adv_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.req(AXI4_VHD_GET_WRITE_RESP_READY) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_RESP_READY) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_RESP_READY) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_RESP_READY) = '0');
      ready := axi4_tr_adv_if_local(bfm_id)(path_id).value_0;
    end get_write_resp_ready;

    procedure create_monitor_transaction(transaction_id  : out integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_CREATE_MONITOR_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_MONITOR_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_MONITOR_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_CREATE_MONITOR_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).transaction_id;
    end create_monitor_transaction;

    procedure create_monitor_transaction(transaction_id  : out integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_CREATE_MONITOR_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_MONITOR_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_CREATE_MONITOR_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_CREATE_MONITOR_TRANSACTION) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(path_id).transaction_id;
    end create_monitor_transaction;

    procedure get_rw_transaction(transaction_id  : in integer;
                              bfm_id          : in integer;
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_RW_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_RW_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_GET_RW_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_RW_TRANSACTION) = '0');
    end get_rw_transaction;

    procedure get_rw_transaction(transaction_id  : in integer;
                              bfm_id          : in integer;
                              path_id         : in axi4_path_t; 
                              signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0        <= 0;
      tr_if.req(AXI4_VHD_GET_RW_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_RW_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_GET_RW_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_RW_TRANSACTION) = '0');
    end get_rw_transaction;

    procedure push_transaction_id(transaction_id  : in integer;
                                  queue_id        : in integer;
                                  bfm_id          : in integer; 
                                  signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= queue_id;
      tr_if.req(AXI4_VHD_PUSH_TRANSACTION_ID) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_PUSH_TRANSACTION_ID) = '1');
      tr_if.req(AXI4_VHD_PUSH_TRANSACTION_ID) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_PUSH_TRANSACTION_ID) = '0');
    end push_transaction_id;

    procedure push_transaction_id(transaction_id  : in integer;
                                  queue_id        : in integer;
                                  bfm_id          : in integer; 
                                  path_id         : in axi4_path_t; 
                                  signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= queue_id;
      tr_if.req(AXI4_VHD_PUSH_TRANSACTION_ID) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_PUSH_TRANSACTION_ID) = '1');
      tr_if.req(AXI4_VHD_PUSH_TRANSACTION_ID) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_PUSH_TRANSACTION_ID) = '0');
    end push_transaction_id;

    procedure pop_transaction_id(transaction_id  : out integer;
                                 queue_id        : in integer;
                                 bfm_id          : in integer; 
                                 signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= queue_id;
      tr_if.req(AXI4_VHD_POP_TRANSACTION_ID) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_POP_TRANSACTION_ID) = '1');
      tr_if.req(AXI4_VHD_POP_TRANSACTION_ID) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_POP_TRANSACTION_ID) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).transaction_id;
    end pop_transaction_id;

    procedure pop_transaction_id(transaction_id  : out integer;
                                 queue_id        : in integer;
                                 bfm_id          : in integer; 
                                 path_id         : in axi4_path_t;
                                 signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= queue_id;
      tr_if.req(AXI4_VHD_POP_TRANSACTION_ID) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_POP_TRANSACTION_ID) = '1');
      tr_if.req(AXI4_VHD_POP_TRANSACTION_ID) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_POP_TRANSACTION_ID) = '0');
      transaction_id := axi4_tr_if_local(bfm_id)(path_id).transaction_id;
    end pop_transaction_id;

    procedure get_write_addr_data(transaction_id  : in integer;
                                  index           : in integer;
                                  byte_index      : in integer;
                                  dynamic_size    : out integer;
                                  addr            : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                                  data            : out std_logic_vector(7 downto 0);
                                  bfm_id          : in integer;
                                  signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= index;
      tr_if.value_1 <= byte_index;
      tr_if.req(AXI4_VHD_GET_WRITE_ADDR_DATA) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_ADDR_DATA) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_ADDR_DATA) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_WRITE_ADDR_DATA) = '0');
      dynamic_size := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
      addr := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max;
      data := conv_std_logic_vector(axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_1, 8);
    end get_write_addr_data;

    procedure get_write_addr_data(transaction_id  : in integer;
                                  index           : in integer;
                                  byte_index      : in integer;
                                  dynamic_size    : out integer;
                                  addr            : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                                  data            : out std_logic_vector(7 downto 0);
                                  bfm_id          : in integer;
                                  path_id         : in axi4_path_t; 
                                  signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= index;
      tr_if.value_1 <= byte_index;
      tr_if.req(AXI4_VHD_GET_WRITE_ADDR_DATA) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_ADDR_DATA) = '1');
      tr_if.req(AXI4_VHD_GET_WRITE_ADDR_DATA) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_WRITE_ADDR_DATA) = '0');
      dynamic_size := axi4_tr_if_local(bfm_id)(path_id).value_0;
      addr := axi4_tr_if_local(bfm_id)(path_id).value_max;
      data := conv_std_logic_vector(axi4_tr_if_local(bfm_id)(path_id).value_1, 8);
    end get_write_addr_data;

    procedure get_read_addr(transaction_id  : in integer;
                                  index           : in integer;
                            byte_index      : in integer;
                            dynamic_size    : out integer;
                            addr            : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                            bfm_id          : in integer;
                            signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= index;
      tr_if.value_1 <= byte_index;
      tr_if.req(AXI4_VHD_GET_READ_ADDR) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_READ_ADDR) = '1');
      tr_if.req(AXI4_VHD_GET_READ_ADDR) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_GET_READ_ADDR) = '0');
      dynamic_size := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_0;
      addr := axi4_tr_if_local(bfm_id)(AXI4_PATH_0).value_max;
    end get_read_addr;

    procedure get_read_addr(transaction_id  : in integer;
                                  index           : in integer;
                            byte_index      : in integer;
                            dynamic_size    : out integer;
                            addr            : out std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                            bfm_id          : in integer;
                            path_id         : in axi4_path_t; 
                            signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= index;
      tr_if.value_1 <= byte_index;
      tr_if.req(AXI4_VHD_GET_READ_ADDR) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_ADDR) = '1');
      tr_if.req(AXI4_VHD_GET_READ_ADDR) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_GET_READ_ADDR) = '0');
      dynamic_size := axi4_tr_if_local(bfm_id)(path_id).value_0;
      addr := axi4_tr_if_local(bfm_id)(path_id).value_max;
    end get_read_addr;

    procedure set_read_data(transaction_id  : in integer;
                                  index           : in integer;
                            byte_index      : in integer;
                            dynamic_size    : in integer;
                            addr            : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                            data            : in std_logic_vector(7 downto 0);
                            bfm_id          : in integer;
                            signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= index;
      tr_if.value_1 <= byte_index;
      tr_if.value_2 <= dynamic_size;
      tr_if.value_max <= addr;
      tr_if.value_3 <= to_integer(data);
      tr_if.req(AXI4_VHD_SET_READ_DATA) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_READ_DATA) = '1');
      tr_if.req(AXI4_VHD_SET_READ_DATA) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_SET_READ_DATA) = '0');
    end set_read_data;

    procedure set_read_data(transaction_id  : in integer;
                                  index           : in integer;
                            byte_index      : in integer;
                            dynamic_size    : in integer;
                            addr            : in std_logic_vector(AXI4_MAX_BIT_SIZE-1 downto 0);
                            data            : in std_logic_vector(7 downto 0);
                            bfm_id          : in integer;
                            path_id         : in axi4_path_t; 
                            signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= index;
      tr_if.value_1 <= byte_index;
      tr_if.value_2 <= dynamic_size;
      tr_if.value_max <= addr;
      tr_if.value_3 <= to_integer(data);
      tr_if.req(AXI4_VHD_SET_READ_DATA) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_READ_DATA) = '1');
      tr_if.req(AXI4_VHD_SET_READ_DATA) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_SET_READ_DATA) = '0');
    end set_read_data;

    procedure print(transaction_id  : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= 0;
      tr_if.req(AXI4_VHD_PRINT) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_PRINT) = '1');
      tr_if.req(AXI4_VHD_PRINT) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_PRINT) = '0');
    end print;

    procedure print(transaction_id  : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi4_path_t; 
                    signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= 0;
      tr_if.req(AXI4_VHD_PRINT) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_PRINT) = '1');
      tr_if.req(AXI4_VHD_PRINT) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_PRINT) = '0');
    end print;

    procedure print(transaction_id  : in integer;
                    print_delays    : in integer;
                    bfm_id          : in integer;
                    signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= print_delays;
      tr_if.req(AXI4_VHD_PRINT) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_PRINT) = '1');
      tr_if.req(AXI4_VHD_PRINT) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_PRINT) = '0');
    end print;

    procedure print(transaction_id  : in integer;
                    print_delays    : in integer;
                    bfm_id          : in integer;
                    path_id         : in axi4_path_t; 
                    signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.value_0 <= print_delays;
      tr_if.req(AXI4_VHD_PRINT) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_PRINT) = '1');
      tr_if.req(AXI4_VHD_PRINT) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_PRINT) = '0');
    end print;

    procedure destruct_transaction(transaction_id  : in integer;
                                   bfm_id          : in integer;
                                   signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.req(AXI4_VHD_DESTRUCT_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_DESTRUCT_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_DESTRUCT_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_DESTRUCT_TRANSACTION) = '0');
    end destruct_transaction;

    procedure destruct_transaction(transaction_id  : in integer;
                                   bfm_id          : in integer;
                                   path_id         : in axi4_path_t; 
                                   signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.transaction_id <= transaction_id;
      tr_if.req(AXI4_VHD_DESTRUCT_TRANSACTION) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_DESTRUCT_TRANSACTION) = '1');
      tr_if.req(AXI4_VHD_DESTRUCT_TRANSACTION) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_DESTRUCT_TRANSACTION) = '0');
    end destruct_transaction;

    procedure wait_on(phase           : in integer;
                      bfm_id          : in integer;
                      signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= phase;
      tr_if.value_1 <= 1;
      tr_if.req(AXI4_VHD_WAIT_ON) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_WAIT_ON) = '1');
      tr_if.req(AXI4_VHD_WAIT_ON) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_WAIT_ON) = '0');
    end wait_on;

    procedure wait_on(phase           : in integer;
                      bfm_id          : in integer;
                      path_id         : in axi4_path_t; 
                      signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= phase;
      tr_if.value_1 <= 1;
      tr_if.req(AXI4_VHD_WAIT_ON) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_WAIT_ON) = '1');
      tr_if.req(AXI4_VHD_WAIT_ON) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_WAIT_ON) = '0');
    end wait_on;

    procedure wait_on(phase           : in integer;
                      count           : in integer;
                      bfm_id          : in integer;
                      signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= phase;
      tr_if.value_1 <= count;
      tr_if.req(AXI4_VHD_WAIT_ON) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_WAIT_ON) = '1');
      tr_if.req(AXI4_VHD_WAIT_ON) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(AXI4_PATH_0).ack(AXI4_VHD_WAIT_ON) = '0');
    end wait_on;

    procedure wait_on(phase           : in integer;
                      count           : in integer;
                      bfm_id          : in integer;
                      path_id         : in axi4_path_t; 
                      signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= phase;
      tr_if.value_1 <= count;
      tr_if.req(AXI4_VHD_WAIT_ON) <= '1';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_WAIT_ON) = '1');
      tr_if.req(AXI4_VHD_WAIT_ON) <= '0';
      wait until (axi4_tr_if_local(bfm_id)(path_id).ack(AXI4_VHD_WAIT_ON) = '0');
    end wait_on;

    procedure wait_on(phase           : in integer;
                      bfm_id          : in integer;
                      path_id         : in axi4_adv_path_t; 
                      signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= phase;
      tr_if.value_1 <= 1;
      tr_if.req(AXI4_VHD_WAIT_ON) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_WAIT_ON) = '1');
      tr_if.req(AXI4_VHD_WAIT_ON) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_WAIT_ON) = '0');
    end wait_on;

    procedure wait_on(phase           : in integer;
                      count           : in integer;
                      bfm_id          : in integer;
                      path_id         : in axi4_adv_path_t; 
                      signal tr_if    : inout axi4_vhd_if_struct_t) is
    begin
      tr_if.value_0 <= phase;
      tr_if.value_1 <= count;
      tr_if.req(AXI4_VHD_WAIT_ON) <= '1';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_WAIT_ON) = '1');
      tr_if.req(AXI4_VHD_WAIT_ON) <= '0';
      wait until (axi4_tr_adv_if_local(bfm_id)(path_id).ack(AXI4_VHD_WAIT_ON) = '0');
    end wait_on;

end mgc_axi4_bfm_pkg;
