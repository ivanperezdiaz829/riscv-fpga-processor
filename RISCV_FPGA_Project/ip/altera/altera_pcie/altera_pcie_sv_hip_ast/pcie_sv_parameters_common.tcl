# (C) 2001-2013 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


proc set_pcie_hip_flow_control_settings_common {} {

   set credit_type "absolute"
   set icredit_type 2
   set atom_ops 0

   set max_payload  [ get_parameter_value max_payload_size_hwtcl ]
   set use_crc_forwarding_hwtcl [ get_parameter_value use_crc_forwarding_hwtcl ]
   set rxbuffer_rxreq_hwtcl [ get_parameter_value rxbuffer_rxreq_hwtcl ]
   set override_rxbuffer_cred_preset [ get_parameter_value override_rxbuffer_cred_preset ]

   if { $override_rxbuffer_cred_preset == 1 } {
      # when set override presets
      set icredit_type 5
   } else {
      if  { [ regexp Minimum $rxbuffer_rxreq_hwtcl ] } {
         set icredit_type 0
      } elseif { [ regexp Low $rxbuffer_rxreq_hwtcl ] } {
         set icredit_type 1
      } elseif { [ regexp High $rxbuffer_rxreq_hwtcl ] } {
         set icredit_type 3
      } elseif { [ regexp Maximum $rxbuffer_rxreq_hwtcl ] } {
         set icredit_type 4
      } else {
         set icredit_type 2
      }
      set_parameter_value credit_buffer_allocation_aux_hwtcl "absolute"
   }

   # Info display
   #
   send_message info "Credit allocation in the 16 KBytes receive buffer:"
   set cred_val ""

   #For readability
   set kvc_minimum   0
   set kvc_low       1
   set kvc_balanced  2
   set kvc_high      3
   set kvc_maximum   4

   if { $atom_ops == 1 } {
      if { $use_crc_forwarding_hwtcl == 0 } {
         #                                                       k_vc0 = Cpld, CplH, NPD, NPH, PD, PH ko_cpl_spc_vc0
         # MINIMUM REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)      k_vc0 = { 0,    0,    2,     2,     8,        1 } ko_cpl_spc_vc0 :  CPLD=809,  CPLH=202
         # MINIMUM REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)     k_vc0 = { 0,    0,    2,     2,     16,       1 } ko_cpl_spc_vc0 :  CPLD=803,  CPLH=200
         # MINIMUM REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)     k_vc0 = { 0,    0,    2,     2,     32,       1 } ko_cpl_spc_vc0 :  CPLD=790,  CPLH=197
         # MINIMUM REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)    k_vc0 = { 0,    0,    2,     2,     64,       1 } ko_cpl_spc_vc0 :  CPLD=764,  CPLH=191
         # MINIMUM REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)   k_vc0 = { 0,    0,    2,     2,     128,      1 } ko_cpl_spc_vc0 :  CPLD=713,  CPLH=178
         #
         # LOW REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)          k_vc0 = { 0,    0,    8,     16,     16,     16 } ko_cpl_spc_vc0 :  CPLD=773,  CPLH=195
         # LOW REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)         k_vc0 = { 0,    0,    8,     16,     16,     16 } ko_cpl_spc_vc0 :  CPLD=773,  CPLH=195
         # LOW REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)         k_vc0 = { 0,    0,    8,     16,     32,     16 } ko_cpl_spc_vc0 :  CPLD=760,  CPLH=192
         # LOW REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)        k_vc0 = { 0,    0,    8,     16,     64,     16 } ko_cpl_spc_vc0 :  CPLD=735,  CPLH=185
         # LOW REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)       k_vc0 = { 0,    0,    8,     16,     128,    16 } ko_cpl_spc_vc0 :  CPLD=684,  CPLH=172
         #
         # HIGH REQUESTOR - OPTION A (BALANCE PD = 8*PH)
         #
         # HIGH REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)         k_vc0 = { 0,    0,    16,     92,     784,     100 } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=16
         # HIGH REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)        k_vc0 = { 0,    0,    16,     52,     866,     58  } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=16
         # HIGH REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)        k_vc0 = { 0,    0,    16,     28,     902,     30  } ko_cpl_spc_vc0 :  CPLD=32,  CPLH=16
         # HIGH REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)       k_vc0 = { 0,    0,    16,     16,     896,     16  } ko_cpl_spc_vc0 :  CPLD=64,  CPLH=16
         # HIGH REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)      k_vc0 = { 0,    0,    16,     16,     816,     16  } ko_cpl_spc_vc0 :  CPLD=128,  CPLH=32
         #
         # MAX REQUESTOR (MAXPAYLD=128B, 8 CREDS)                k_vc0 = { 0,    0,    32,     88,     783,     112 } ko_cpl_spc_vc0 :  CPLD=8,  CPLH=1
         # MAX REQUESTOR (MAXPAYLD=256B, 16 CREDS)               k_vc0 = { 0,    0,    32,     52,     865,     58  } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=1
         # MAX REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)         k_vc0 = { 0,    0,    32,     28,     901,     30  } ko_cpl_spc_vc0 :  CPLD=32,  CPLH=1
         # MAX REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)        k_vc0 = { 0,    0,    32,     16,     895,     16  } ko_cpl_spc_vc0 :  CPLD=64,  CPLH=1
         # MAX REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)       k_vc0 = { 0,    0,    32,     16,     831,     16  } ko_cpl_spc_vc0 :  CPLD=128,  CPLH=1
         #
         set k_vc($kvc_minimum,128)   " 0 0 2 2 8 1 809 202"
         set k_vc($kvc_minimum,256)   " 0 0 2 2 16 1 803 200"
         set k_vc($kvc_minimum,512)   " 0 0 2 2 32 1 790 197"
         set k_vc($kvc_minimum,1024)  " 0 0 2 2 64 1 764 191"
         set k_vc($kvc_minimum,2048)  " 0 0 2 2 128 1 713 178"

         set k_vc($kvc_low,128)       " 0 0 8 16 16 16 773 195"
         set k_vc($kvc_low,256)       " 0 0 8 16 16 16 773 195"
         set k_vc($kvc_low,512)       " 0 0 8 16 32 16 760 192"
         set k_vc($kvc_low,1024)      " 0 0 8 16 64 16 735 185"
         set k_vc($kvc_low,2048)      " 0 0 8 16 128 16 684 172"

         # Needs to be updated when Atomic Ops are supported
         set k_vc($kvc_balanced,128)  "0 0 0 56 358 50 448 112"
         set k_vc($kvc_balanced,256)  "0 0 0 56 358 50 448 112"
         set k_vc($kvc_balanced,512)  "0 0 0 56 358 50 448 112"
         set k_vc($kvc_balanced,1024) "0 0 0 56 358 50 448 112"
         set k_vc($kvc_balanced,2048) "0 0 0 56 358 50 448 112"

         set k_vc($kvc_high,128)      " 0 0 16 92 784 100 16 16"
         set k_vc($kvc_high,256)      " 0 0 16 52 866 58 16 16"
         set k_vc($kvc_high,512)      " 0 0 16 28 902 30 32 16"
         set k_vc($kvc_high,1024)     " 0 0 16 16 896 16 64 16"
         set k_vc($kvc_high,2048)     " 0 0 16 16 816 16 128 32"

         set k_vc($kvc_maximum,128)   " 0 0 32 88 783 112 8 1"
         set k_vc($kvc_maximum,256)   " 0 0 32 52 865 58 16 1"
         set k_vc($kvc_maximum,512)   " 0 0 32 28 901 30 32 1"
         set k_vc($kvc_maximum,1024)  " 0 0 32 16 895 16 64 1"
         set k_vc($kvc_maximum,2048)  " 0 0 32 16 831 16 128 1"

      } else {
         #
         #  MINIMUM REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)         k_vc0 = { 0,    0,    2,     4,     8,      2  } ko_cpl_spc_vc0 :  CPLD=803,  CPLH=202
         #  MINIMUM REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)        k_vc0 = { 0,    0,    2,     4,     16,     2  } ko_cpl_spc_vc0 :  CPLD=797,  CPLH=200
         #  MINIMUM REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)        k_vc0 = { 0,    0,    2,     4,     32,     2  } ko_cpl_spc_vc0 :  CPLD=784,  CPLH=197
         #  MINIMUM REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)       k_vc0 = { 0,    0,    2,     4,     64,     2  } ko_cpl_spc_vc0 :  CPLD=758,  CPLH=191
         #  MINIMUM REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)      k_vc0 = { 0,    0,    2,     4,     128,    2  } ko_cpl_spc_vc0 :  CPLD=707,  CPLH=178
         #
         #  LOW REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)             k_vc0 = { 0,    0,    8,     16,     16,    16 } ko_cpl_spc_vc0 :  CPLD=757,  CPLH=195
         #  LOW REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)            k_vc0 = { 0,    0,    8,     16,     16,    16 } ko_cpl_spc_vc0 :  CPLD=757,  CPLH=195
         #  LOW REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)            k_vc0 = { 0,    0,    8,     16,     32,    16 } ko_cpl_spc_vc0 :  CPLD=744,  CPLH=192
         #  LOW REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)           k_vc0 = { 0,    0,    8,     16,     64,    16 } ko_cpl_spc_vc0 :  CPLD=719,  CPLH=185
         #  LOW REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)          k_vc0 = { 0,    0,    8,     16,     128,   16 } ko_cpl_spc_vc0 :  CPLD=668,  CPLH=172
         #
         #  HIGH REQUESTOR - OPTION A (BALANCE PD = 8*PH)
         #
         #  HIGH REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)         k_vc0 = { 0,    0,    16,     88,     694,     100 } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=16
         #  HIGH REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)        k_vc0 = { 0,    0,    16,     48,     817,     58  } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=16
         #  HIGH REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)        k_vc0 = { 0,    0,    16,     24,     879,     30  } ko_cpl_spc_vc0 :  CPLD=32,  CPLH=16
         #  HIGH REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)       k_vc0 = { 0,    0,    16,     16,     880,     16  } ko_cpl_spc_vc0 :  CPLD=64,  CPLH=16
         #  HIGH REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)      k_vc0 = { 0,    0,    16,     16,     800,     16  } ko_cpl_spc_vc0 :  CPLD=128,  CPLH=32
         #
         #  MAX REQUESTOR (MAXPAYLD=128B, 8 CREDS)                k_vc0 = { 0,    0,    32,     88,     683,     112 } ko_cpl_spc_vc0 :  CPLD=8,  CPLH=1
         #  MAX REQUESTOR (MAXPAYLD=256B, 16 CREDS)               k_vc0 = { 0,    0,    32,     48,     816,     58  } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=1
         #  MAX REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)         k_vc0 = { 0,    0,    32,     24,     878,     30  } ko_cpl_spc_vc0 :  CPLD=32,  CPLH=1
         #  MAX REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)        k_vc0 = { 0,    0,    32,     16,     879,     16  } ko_cpl_spc_vc0 :  CPLD=64,  CPLH=1
         #  MAX REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)       k_vc0 = { 0,    0,    32,     16,     815,     16  } ko_cpl_spc_vc0 :  CPLD=128,  CPLH=1
         #

         set k_vc($kvc_minimum,128)   "0 0 2 4 8 2 803 202"
         set k_vc($kvc_minimum,256)   "0 0 2 4 16 2 797 200"
         set k_vc($kvc_minimum,512)   "0 0 2 4 32 2 784 197"
         set k_vc($kvc_minimum,1024)  "0 0 2 4 64 2 758 191"
         set k_vc($kvc_minimum,2048)  "0 0 2 4 128 2 707 178"

         set k_vc($kvc_low,128)       "0 0 8 16 16 16 757 195"
         set k_vc($kvc_low,256)       "0 0 8 16 16 16 757 195"
         set k_vc($kvc_low,512)       "0 0 8 16 32 16 744 192"
         set k_vc($kvc_low,1024)      "0 0 8 16 64 16 719 185"
         set k_vc($kvc_low,2048)      "0 0 8 16 128 16 668 172"

         #Needs to be updated when Atomic Ops are supported
         set k_vc($kvc_balanced,128)  "0 0 0 56 333 50 420 112"
         set k_vc($kvc_balanced,256)  "0 0 0 56 333 50 420 112"
         set k_vc($kvc_balanced,512)  "0 0 0 56 333 50 420 112"
         set k_vc($kvc_balanced,1024) "0 0 0 56 333 50 420 112"
         set k_vc($kvc_balanced,2048) "0 0 0 56 333 50 420 112"

         set k_vc($kvc_high,128)      "0 0 16 88 694 100 16 16"
         set k_vc($kvc_high,256)      "0 0 16 48 817 58 16 16"
         set k_vc($kvc_high,512)      "0 0 16 24 879 30 32 16"
         set k_vc($kvc_high,1024)     "0 0 16 16 880 16 64 16"
         set k_vc($kvc_high,2048)     "0 0 16 16 800 16 128 32"

         set k_vc($kvc_maximum,128)   "0 0 32 88 683 112 8 1"
         set k_vc($kvc_maximum,256)   "0 0 32 48 816 58 16 1"
         set k_vc($kvc_maximum,512)   "0 0 32 24 878 30 32 1"
         set k_vc($kvc_maximum,1024)  "0 0 32 16 879 16 64 1"
         set k_vc($kvc_maximum,2048)  "0 0 32 16 815 16 128 1"

      }
   } else {
      if { $use_crc_forwarding_hwtcl == 0 } {
         #
         #                                                            k_vc0 = Cpld, CplH, NPD, NPH, PD, PH             ko_cpl_spc_vc0
         #   MINIMUM REQUESTOR CREDS (MAXPAYLD=128B , 8 CREDS  )      k_vc0 = { 0,    0,    0,     4,     8,      1 }  ko_cpl_spc_vc0 :  CPLD=809,  CPLH=202
         #   MINIMUM REQUESTOR CREDS (MAXPAYLD=256B , 16 CREDS )      k_vc0 = { 0,    0,    0,     4,     16,     1 }  ko_cpl_spc_vc0 :  CPLD=803,  CPLH=200
         #   MINIMUM REQUESTOR CREDS (MAXPAYLD=512B , 32 CREDS )      k_vc0 = { 0,    0,    0,     4,     32,     1 }  ko_cpl_spc_vc0 :  CPLD=790,  CPLH=197
         #   MINIMUM REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS )      k_vc0 = { 0,    0,    0,     4,     64,     1 }  ko_cpl_spc_vc0 :  CPLD=764,  CPLH=191
         #   MINIMUM REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)      k_vc0 = { 0,    0,    0,     4,     128,    1 }  ko_cpl_spc_vc0 :  CPLD=713,  CPLH=178
         #
         #
         #   LOW REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)             k_vc0 = { 0,    0,    0,     16,    16,     16 } ko_cpl_spc_vc0 :  CPLD=781,  CPLH=195
         #   LOW REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)            k_vc0 = { 0,    0,    0,     16,    16,     16 } ko_cpl_spc_vc0 :  CPLD=781,  CPLH=195
         #   LOW REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)            k_vc0 = { 0,    0,    0,     16,    32,     16 } ko_cpl_spc_vc0 :  CPLD=768,  CPLH=192
         #   LOW REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)           k_vc0 = { 0,    0,    0,     16,    64,     16 } ko_cpl_spc_vc0 :  CPLD=743,  CPLH=185
         #   LOW REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)          k_vc0 = { 0,    0,    0,     16,    128,    16 } ko_cpl_spc_vc0 :  CPLD=692,  CPLH=172
         #
         #   HIGH REQUESTOR - OPTION A (BALANCE PD = 8*PH)
         #
         #   HIGH REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)            k_vc0 = { 0,    0,    0,     92,    800,    100} ko_cpl_spc_vc0 :  CPLD=16,  CPLH=16
         #   HIGH REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)           k_vc0 = { 0,    0,    0,     52,    882,    58 } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=16
         #   HIGH REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)           k_vc0 = { 0,    0,    0,     28,    918,    30 } ko_cpl_spc_vc0 :  CPLD=32,  CPLH=16
         #   HIGH REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)          k_vc0 = { 0,    0,    0,     16,    912,    16 } ko_cpl_spc_vc0 :  CPLD=64,  CPLH=16
         #   HIGH REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)         k_vc0 = { 0,    0,    0,     16,    832,    16 } ko_cpl_spc_vc0 :  CPLD=128,  CPLH=32
         #
         #   MAX REQUESTOR (MAXPAYLD=128B, 8 CREDS)                   k_vc0 = { 0,    0,    0,     88,     815,   112 }ko_cpl_spc_vc0 :  CPLD=8,  CPLH=1
         #   MAX REQUESTOR (MAXPAYLD=256B, 16 CREDS)                  k_vc0 = { 0,    0,    0,     52,     897,    58 }ko_cpl_spc_vc0 :  CPLD=16,  CPLH=1
         #   MAX REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)            k_vc0 = { 0,    0,    0,     28,     933,    30 }ko_cpl_spc_vc0 :  CPLD=32,  CPLH=1
         #   MAX REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)           k_vc0 = { 0,    0,    0,     16,     927,    16 }ko_cpl_spc_vc0 :  CPLD=64,  CPLH=1
         #   MAX REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)          k_vc0 = { 0,    0,    0,     16,     863,    16 }ko_cpl_spc_vc0 :  CPLD=128,  CPLH=1

         #              Cpld, CplH, NPD, NPH, PD, PH, Size CPLD, Size CPLH
         set k_vc($kvc_minimum,128)   "0 0 0 4 8 1 809 202"
         set k_vc($kvc_minimum,256)   "0 0 0 4 16 1 803 200"
         set k_vc($kvc_minimum,512)   "0 0 0 4 32 1 790 197"
         set k_vc($kvc_minimum,1024)  "0 0 0 4 64 1 764 191"
         set k_vc($kvc_minimum,2048)  "0 0 0 4 128 1 713 178"

         set k_vc($kvc_low,128)       "0 0 0 16 16 16 781 195"
         set k_vc($kvc_low,256)       "0 0 0 16 16 16 781 195"
         set k_vc($kvc_low,512)       "0 0 0 16 32 16 768 192"
         set k_vc($kvc_low,1024)      "0 0 0 16 64 16 743 185"
         set k_vc($kvc_low,2048)      "0 0 0 16 128 16 692 172"

         set k_vc($kvc_balanced,128)  "0 0 0 56 358 50 448 112"
         set k_vc($kvc_balanced,256)  "0 0 0 56 358 50 448 112"
         set k_vc($kvc_balanced,512)  "0 0 0 56 358 50 448 112"
         set k_vc($kvc_balanced,1024) "0 0 0 56 358 50 448 112"
         set k_vc($kvc_balanced,2048) "0 0 0 56 358 50 448 112"

         set k_vc($kvc_high,128)      "0 0 0 92 800 100 16 16"
         set k_vc($kvc_high,256)      "0 0 0 52 882 58 16 16"
         set k_vc($kvc_high,512)      "0 0 0 28 918 30 32 16"
         set k_vc($kvc_high,1024)     "0 0 0 16 912 16 64 16"
         set k_vc($kvc_high,2048)     "0 0 0 16 832 16 128 32"

         set k_vc($kvc_maximum,128)   "0 0 0 88 815 112 8 1"
         set k_vc($kvc_maximum,256)   "0 0 0 52 897 58 16 1"
         set k_vc($kvc_maximum,512)   "0 0 0 28 933 30 32 1"
         set k_vc($kvc_maximum,1024)  "0 0 0 16 927 16 64 1"
         set k_vc($kvc_maximum,2048)  "0 0 0 16 863 16 128 1"
      } else  {
         # ECRC Forwarding
         #    MINIMUM REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)         k_vc0 = { 0,    0,    0,     8,     8,      2 } ko_cpl_spc_vc0 :  CPLD=799,  CPLH=202
         #    MINIMUM REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)        k_vc0 = { 0,    0,    0,     8,     16,     2 } ko_cpl_spc_vc0 :  CPLD=793,  CPLH=200
         #    MINIMUM REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)        k_vc0 = { 0,    0,    0,     8,     32,     2 } ko_cpl_spc_vc0 :  CPLD=780,  CPLH=197
         #    MINIMUM REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)       k_vc0 = { 0,    0,    0,     8,     64,     2 } ko_cpl_spc_vc0 :  CPLD=754,  CPLH=191
         #    MINIMUM REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)      k_vc0 = { 0,    0,    0,     8,     128,    2 } ko_cpl_spc_vc0 :  CPLD=703,  CPLH=178
         #
         #    LOW REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)             k_vc0 = { 0,    0,    0,     16,     16,     16 } ko_cpl_spc_vc0 :  CPLD=765,  CPLH=195
         #    LOW REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)            k_vc0 = { 0,    0,    0,     16,     16,     16 } ko_cpl_spc_vc0 :  CPLD=765,  CPLH=195
         #    LOW REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)            k_vc0 = { 0,    0,    0,     16,     32,     16 } ko_cpl_spc_vc0 :  CPLD=752,  CPLH=192
         #    LOW REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)           k_vc0 = { 0,    0,    0,     16,     64,     16 } ko_cpl_spc_vc0 :  CPLD=727,  CPLH=185
         #    LOW REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)          k_vc0 = { 0,    0,    0,     16,     128,    16 } ko_cpl_spc_vc0 :  CPLD=676,  CPLH=172
         #
         #    HIGH REQUESTOR - OPTION A (BALANCE PD = 8*PH)
         #
         #    HIGH REQUESTOR CREDS (MAXPAYLD=128B, 8 CREDS)            k_vc0 = { 0,    0,    0,     88,     710,    100 } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=16
         #    HIGH REQUESTOR CREDS (MAXPAYLD=256B, 16 CREDS)           k_vc0 = { 0,    0,    0,     48,     833,     58 } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=16
         #    HIGH REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)           k_vc0 = { 0,    0,    0,     24,     895,     30 } ko_cpl_spc_vc0 :  CPLD=32,  CPLH=16
         #    HIGH REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)          k_vc0 = { 0,    0,    0,     16,     896,     16 } ko_cpl_spc_vc0 :  CPLD=64,  CPLH=16
         #    HIGH REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)         k_vc0 = { 0,    0,    0,     16,     816,     16 } ko_cpl_spc_vc0 :  CPLD=128, CPLH=32
         #
         #    MAX REQUESTOR (MAXPAYLD=128B, 8 CREDS)                   k_vc0 = { 0,    0,    0,     88,     715,    112 } ko_cpl_spc_vc0 :  CPLD=8,   CPLH=1
         #    MAX REQUESTOR (MAXPAYLD=256B, 16 CREDS)                  k_vc0 = { 0,    0,    0,     48,     848,     58 } ko_cpl_spc_vc0 :  CPLD=16,  CPLH=1
         #    MAX REQUESTOR CREDS (MAXPAYLD=512B, 32 CREDS)            k_vc0 = { 0,    0,    0,     24,     910,     30 } ko_cpl_spc_vc0 :  CPLD=32,  CPLH=1
         #    MAX REQUESTOR CREDS (MAXPAYLD=1024B, 64 CREDS)           k_vc0 = { 0,    0,    0,     16,     911,     16 } ko_cpl_spc_vc0 :  CPLD=64,  CPLH=1
         #    MAX REQUESTOR CREDS (MAXPAYLD=2048B, 128 CREDS)          k_vc0 = { 0,    0,    0,     16,     847,     16 } ko_cpl_spc_vc0 :  CPLD=128, CPLH=1

         #   Cpld, CplH, NPD, NPH, PD, PH, Size CPLD, Size CPLH
         set k_vc($kvc_minimum,128)   "0 0 0 8 8 2 799 202"
         set k_vc($kvc_minimum,256)   "0 0 0 8 16 2 793 200"
         set k_vc($kvc_minimum,512)   "0 0 0 8 32 2 780 197"
         set k_vc($kvc_minimum,1024)  "0 0 0 8 64 2 754 191"
         set k_vc($kvc_minimum,2048)  "0 0 0 8 128 2 703 178"

         set k_vc($kvc_low,128)       "0 0 0 16 16 16 765 195"
         set k_vc($kvc_low,256)       "0 0 0 16 16 16 765 195"
         set k_vc($kvc_low,512)       "0 0 0 16 32 16 752 192"
         set k_vc($kvc_low,1024)      "0 0 0 16 64 16 727 185"
         set k_vc($kvc_low,2048)      "0 0 0 16 128 16 676 172"

         set k_vc($kvc_balanced,128)  "0 0 0 56 333 50 420 112"
         set k_vc($kvc_balanced,256)  "0 0 0 56 333 50 420 112"
         set k_vc($kvc_balanced,512)  "0 0 0 56 333 50 420 112"
         set k_vc($kvc_balanced,1024) "0 0 0 56 333 50 420 112"
         set k_vc($kvc_balanced,2048) "0 0 0 56 333 50 420 112"

         set k_vc($kvc_high,128)      "0 0 0 88 710 100 16 16"
         set k_vc($kvc_high,256)      "0 0 0 48 833 58 16 16"
         set k_vc($kvc_high,512)      "0 0 0 24 895 30 32 16"
         set k_vc($kvc_high,1024)     "0 0 0 16 896 16 64 16"
         set k_vc($kvc_high,2048)     "0 0 0 16 816 16 128 32"

         set k_vc($kvc_maximum,128)   "0 0 0 88 715 112 8 1"
         set k_vc($kvc_maximum,256)   "0 0 0 48 848 58 16 1"
         set k_vc($kvc_maximum,512)   "0 0 0 24 910 30 32 1"
         set k_vc($kvc_maximum,1024)  "0 0 0 16 911 16 64 1"
         set k_vc($kvc_maximum,2048)  "0 0 0 16 847 16 128 1"

      }
   }

   if { $override_rxbuffer_cred_preset == 0 } {
      set cred_val $k_vc($icredit_type,$max_payload)
      set cred_array [ split $cred_val " "]
      # Cpld(0), CplH(1), NPD(2), NPH(3), PD(4), PH(5), Size CPLD(6), Size CPLH(7)

      set CPLH_ADVERTISE [ lindex $cred_array 1 ]
      set CPLD_ADVERTISE [ lindex $cred_array 0 ]
      set NPH  [ lindex $cred_array 3]
      set NPD  [ lindex $cred_array 2]
      set PH   [ lindex $cred_array 5]
      set PD   [ lindex $cred_array 4]
      set CPLH [ lindex $cred_array 7]
      set CPLD [ lindex $cred_array 6]

      set_parameter_value vc0_rx_flow_ctrl_posted_header_hwtcl $PH
      set_parameter_value vc0_rx_flow_ctrl_posted_data_hwtcl $PD
      set_parameter_value vc0_rx_flow_ctrl_nonposted_header_hwtcl $NPH
      set_parameter_value vc0_rx_flow_ctrl_nonposted_data_hwtcl $NPD
      set_parameter_value vc0_rx_flow_ctrl_compl_header_hwtcl $CPLH_ADVERTISE
      set_parameter_value vc0_rx_flow_ctrl_compl_data_hwtcl $CPLD_ADVERTISE
      set_parameter_value cpl_spc_data_hwtcl $CPLD
      set_parameter_value cpl_spc_header_hwtcl $CPLH

      send_message info "Posted    : header=$PH  data=$PD"
      send_message info "Non posted: header=$NPH  data=$NPD"
      send_message info "Completion: header=$CPLH data=$CPLD"

   } else {
      set PH   [ get_parameter_value vc0_rx_flow_ctrl_posted_header_hwtcl   ]
      set PD   [ get_parameter_value vc0_rx_flow_ctrl_posted_data_hwtcl     ]
      set NPH  [ get_parameter_value vc0_rx_flow_ctrl_nonposted_header_hwtcl]
      set NPD  [ get_parameter_value vc0_rx_flow_ctrl_nonposted_data_hwtcl  ]
      set CPLH [ get_parameter_value vc0_rx_flow_ctrl_compl_header_hwtcl    ]
      set CPLD [ get_parameter_value vc0_rx_flow_ctrl_compl_data_hwtcl      ]

      send_message info "Posted    : header=$PH  data=$PD"
      send_message info "Non posted: header=$NPH  data=$NPD"
      send_message info "Completion: header=$CPLH data=$CPLD"
   }

}
proc add_pcie_hip_common_hidden_rtl_parameters {} {

   send_message debug "proc:add_pcie_hip_common_hidden_rtl_parameters"
   #-----------------------------------------------------------------------------------------------------------------

   # Internal parameter to force using direct value for credit in the command line and bypass UI
   #  default zero
   add_parameter          advanced_default_parameter_override integer 0
   set_parameter_property advanced_default_parameter_override VISIBLE false
   set_parameter_property advanced_default_parameter_override HDL_PARAMETER false

   # Internal parameter to override default design exanmple tb partner
   #  default zero
   #       - When  1  driver simulate config only
   #       - When  2  driver simulate chaining dma
   #       - When  3  driver simulate config target
   #       - When  10 driver simulate config bypass
   add_parameter          override_tbpartner_driver_setting_hwtcl integer 0
   set_parameter_property override_tbpartner_driver_setting_hwtcl VISIBLE false
   set_parameter_property override_tbpartner_driver_setting_hwtcl HDL_PARAMETER false

   # Internal parameter to force using direct value for credit in the command line and bypass UI
   #  default zero
   add_parameter override_rxbuffer_cred_preset integer 0
   set_parameter_property override_rxbuffer_cred_preset VISIBLE false
   set_parameter_property override_rxbuffer_cred_preset HDL_PARAMETER false

   # DERIVE Default to enable auto update
   add_parameter bypass_cdc_hwtcl string "false"
   set_parameter_property bypass_cdc_hwtcl VISIBLE false
   set_parameter_property bypass_cdc_hwtcl HDL_PARAMETER true
   set_parameter_property bypass_cdc_hwtcl DERIVED true

   add_parameter enable_rx_buffer_checking_hwtcl string "false"
   set_parameter_property enable_rx_buffer_checking_hwtcl VISIBLE false
   set_parameter_property enable_rx_buffer_checking_hwtcl HDL_PARAMETER true
   set_parameter_property enable_rx_buffer_checking_hwtcl DERIVED true

   add_parameter disable_link_x2_support_hwtcl string "false"
   set_parameter_property disable_link_x2_support_hwtcl VISIBLE false
   set_parameter_property disable_link_x2_support_hwtcl HDL_PARAMETER true
   set_parameter_property disable_link_x2_support_hwtcl DERIVED true

   add_parameter wrong_device_id_hwtcl string "disable"
   set_parameter_property wrong_device_id_hwtcl VISIBLE false
   set_parameter_property wrong_device_id_hwtcl HDL_PARAMETER true
   set_parameter_property wrong_device_id_hwtcl DERIVED true

   add_parameter data_pack_rx_hwtcl string "disable"
   set_parameter_property data_pack_rx_hwtcl VISIBLE false
   set_parameter_property data_pack_rx_hwtcl HDL_PARAMETER true
   set_parameter_property data_pack_rx_hwtcl DERIVED true

   add_parameter ltssm_1ms_timeout_hwtcl string "disable"
   set_parameter_property ltssm_1ms_timeout_hwtcl VISIBLE false
   set_parameter_property ltssm_1ms_timeout_hwtcl HDL_PARAMETER true
   set_parameter_property ltssm_1ms_timeout_hwtcl DERIVED true

   add_parameter ltssm_freqlocked_check_hwtcl string "disable"
   set_parameter_property ltssm_freqlocked_check_hwtcl VISIBLE false
   set_parameter_property ltssm_freqlocked_check_hwtcl HDL_PARAMETER true
   set_parameter_property ltssm_freqlocked_check_hwtcl DERIVED true

   add_parameter deskew_comma_hwtcl string "skp_eieos_deskw"
   set_parameter_property deskew_comma_hwtcl VISIBLE false
   set_parameter_property deskew_comma_hwtcl HDL_PARAMETER true
   set_parameter_property deskew_comma_hwtcl DERIVED true

   add_parameter device_number_hwtcl integer 0
   set_parameter_property device_number_hwtcl VISIBLE false
   set_parameter_property device_number_hwtcl HDL_PARAMETER true
   set_parameter_property device_number_hwtcl DERIVED true

   add_parameter pipex1_debug_sel_hwtcl string "disable"
   set_parameter_property pipex1_debug_sel_hwtcl VISIBLE false
   set_parameter_property pipex1_debug_sel_hwtcl HDL_PARAMETER true
   set_parameter_property pipex1_debug_sel_hwtcl DERIVED true

   add_parameter pclk_out_sel_hwtcl string "pclk"
   set_parameter_property pclk_out_sel_hwtcl VISIBLE false
   set_parameter_property pclk_out_sel_hwtcl HDL_PARAMETER true
   set_parameter_property pclk_out_sel_hwtcl DERIVED true

   add_parameter no_soft_reset_hwtcl string "false"
   set_parameter_property no_soft_reset_hwtcl VISIBLE false
   set_parameter_property no_soft_reset_hwtcl HDL_PARAMETER true
   set_parameter_property no_soft_reset_hwtcl DERIVED true

   add_parameter maximum_current_hwtcl integer 0
   set_parameter_property maximum_current_hwtcl VISIBLE false
   set_parameter_property maximum_current_hwtcl HDL_PARAMETER true
   set_parameter_property maximum_current_hwtcl DERIVED true

   add_parameter d1_support_hwtcl string "false"
   set_parameter_property d1_support_hwtcl VISIBLE false
   set_parameter_property d1_support_hwtcl HDL_PARAMETER true
   set_parameter_property d1_support_hwtcl DERIVED true

   add_parameter d2_support_hwtcl string "false"
   set_parameter_property d2_support_hwtcl VISIBLE false
   set_parameter_property d2_support_hwtcl HDL_PARAMETER true
   set_parameter_property d2_support_hwtcl DERIVED true

   add_parameter d0_pme_hwtcl string "false"
   set_parameter_property d0_pme_hwtcl VISIBLE false
   set_parameter_property d0_pme_hwtcl HDL_PARAMETER true
   set_parameter_property d0_pme_hwtcl DERIVED true

   add_parameter d1_pme_hwtcl string "false"
   set_parameter_property d1_pme_hwtcl VISIBLE false
   set_parameter_property d1_pme_hwtcl HDL_PARAMETER true
   set_parameter_property d1_pme_hwtcl DERIVED true

   add_parameter d2_pme_hwtcl string "false"
   set_parameter_property d2_pme_hwtcl VISIBLE false
   set_parameter_property d2_pme_hwtcl HDL_PARAMETER true
   set_parameter_property d2_pme_hwtcl DERIVED true

   add_parameter d3_hot_pme_hwtcl string "false"
   set_parameter_property d3_hot_pme_hwtcl VISIBLE false
   set_parameter_property d3_hot_pme_hwtcl HDL_PARAMETER true
   set_parameter_property d3_hot_pme_hwtcl DERIVED true

   add_parameter d3_cold_pme_hwtcl string "false"
   set_parameter_property d3_cold_pme_hwtcl VISIBLE false
   set_parameter_property d3_cold_pme_hwtcl HDL_PARAMETER true
   set_parameter_property d3_cold_pme_hwtcl DERIVED true

   add_parameter low_priority_vc_hwtcl string "single_vc"
   set_parameter_property low_priority_vc_hwtcl VISIBLE false
   set_parameter_property low_priority_vc_hwtcl HDL_PARAMETER true
   set_parameter_property low_priority_vc_hwtcl DERIVED true

   add_parameter disable_snoop_packet_hwtcl string "false"
   set_parameter_property disable_snoop_packet_hwtcl VISIBLE false
   set_parameter_property disable_snoop_packet_hwtcl HDL_PARAMETER true
   set_parameter_property disable_snoop_packet_hwtcl DERIVED true

   add_parameter enable_l1_aspm_hwtcl string "false"
   set_parameter_property enable_l1_aspm_hwtcl VISIBLE false
   set_parameter_property enable_l1_aspm_hwtcl HDL_PARAMETER true
   set_parameter_property enable_l1_aspm_hwtcl DERIVED true

   add_parameter          set_l0s_hwtcl integer 0
   set_parameter_property set_l0s_hwtcl VISIBLE false
   set_parameter_property set_l0s_hwtcl HDL_PARAMETER false
   set_parameter_property set_l0s_hwtcl DERIVED true

   add_parameter          rx_ei_l0s_hwtcl integer 0
   set_parameter_property rx_ei_l0s_hwtcl DISPLAY_NAME "L0s supported"
   set_parameter_property rx_ei_l0s_hwtcl DISPLAY_HINT boolean
   #set_parameter_property rx_ei_l0s_hwtcl GROUP $group_name
   set_parameter_property rx_ei_l0s_hwtcl VISIBLE false
   set_parameter_property rx_ei_l0s_hwtcl HDL_PARAMETER true
   set_parameter_property rx_ei_l0s_hwtcl DERIVED true
   set_parameter_property rx_ei_l0s_hwtcl DESCRIPTION "Enables or disables entry to the L0s state."

   add_parameter          enable_l0s_aspm_hwtcl string "false"
   set_parameter_property enable_l0s_aspm_hwtcl VISIBLE false
   set_parameter_property enable_l0s_aspm_hwtcl HDL_PARAMETER true
   set_parameter_property enable_l0s_aspm_hwtcl DERIVED true

   add_parameter          aspm_config_management_hwtcl string "false"
   set_parameter_property aspm_config_management_hwtcl VISIBLE false
   set_parameter_property aspm_config_management_hwtcl DERIVED true
   set_parameter_property aspm_config_management_hwtcl HDL_PARAMETER true

   add_parameter l1_exit_latency_sameclock_hwtcl integer 0
   set_parameter_property l1_exit_latency_sameclock_hwtcl VISIBLE false
   set_parameter_property l1_exit_latency_sameclock_hwtcl HDL_PARAMETER true
   set_parameter_property l1_exit_latency_sameclock_hwtcl DERIVED true

   add_parameter l1_exit_latency_diffclock_hwtcl integer 0
   set_parameter_property l1_exit_latency_diffclock_hwtcl VISIBLE false
   set_parameter_property l1_exit_latency_diffclock_hwtcl HDL_PARAMETER true
   set_parameter_property l1_exit_latency_diffclock_hwtcl DERIVED true

   add_parameter hot_plug_support_hwtcl integer 0
   set_parameter_property hot_plug_support_hwtcl VISIBLE false
   set_parameter_property hot_plug_support_hwtcl HDL_PARAMETER true
   set_parameter_property hot_plug_support_hwtcl DERIVED true

   add_parameter extended_tag_reset_hwtcl string "false"
   set_parameter_property extended_tag_reset_hwtcl VISIBLE false
   set_parameter_property extended_tag_reset_hwtcl HDL_PARAMETER true
   set_parameter_property extended_tag_reset_hwtcl DERIVED true

   add_parameter no_command_completed_hwtcl string "false"
   set_parameter_property no_command_completed_hwtcl VISIBLE false
   set_parameter_property no_command_completed_hwtcl HDL_PARAMETER true
   set_parameter_property no_command_completed_hwtcl DERIVED true

   add_parameter interrupt_pin_hwtcl string "inta"
   set_parameter_property interrupt_pin_hwtcl VISIBLE false
   set_parameter_property interrupt_pin_hwtcl HDL_PARAMETER true
   set_parameter_property interrupt_pin_hwtcl DERIVED true

   add_parameter bridge_port_vga_enable_hwtcl string "false"
   set_parameter_property bridge_port_vga_enable_hwtcl VISIBLE false
   set_parameter_property bridge_port_vga_enable_hwtcl HDL_PARAMETER true
   set_parameter_property bridge_port_vga_enable_hwtcl DERIVED true

   add_parameter bridge_port_ssid_support_hwtcl string "false"
   set_parameter_property bridge_port_ssid_support_hwtcl VISIBLE false
   set_parameter_property bridge_port_ssid_support_hwtcl HDL_PARAMETER true
   set_parameter_property bridge_port_ssid_support_hwtcl DERIVED true

   add_parameter ssvid_hwtcl integer 0
   set_parameter_property ssvid_hwtcl VISIBLE false
   set_parameter_property ssvid_hwtcl HDL_PARAMETER true
   set_parameter_property ssvid_hwtcl DERIVED true

   add_parameter ssid_hwtcl integer 0
   set_parameter_property ssid_hwtcl VISIBLE false
   set_parameter_property ssid_hwtcl HDL_PARAMETER true
   set_parameter_property ssid_hwtcl DERIVED true

   add_parameter eie_before_nfts_count_hwtcl integer 4
   set_parameter_property eie_before_nfts_count_hwtcl VISIBLE false
   set_parameter_property eie_before_nfts_count_hwtcl HDL_PARAMETER true
   set_parameter_property eie_before_nfts_count_hwtcl DERIVED true

   add_parameter gen2_diffclock_nfts_count_hwtcl integer 255
   set_parameter_property gen2_diffclock_nfts_count_hwtcl VISIBLE false
   set_parameter_property gen2_diffclock_nfts_count_hwtcl HDL_PARAMETER true
   set_parameter_property gen2_diffclock_nfts_count_hwtcl DERIVED true

   add_parameter gen2_sameclock_nfts_count_hwtcl integer 255
   set_parameter_property gen2_sameclock_nfts_count_hwtcl VISIBLE false
   set_parameter_property gen2_sameclock_nfts_count_hwtcl HDL_PARAMETER true
   set_parameter_property gen2_sameclock_nfts_count_hwtcl DERIVED true

   add_parameter l0_exit_latency_sameclock_hwtcl integer 6
   set_parameter_property l0_exit_latency_sameclock_hwtcl VISIBLE false
   set_parameter_property l0_exit_latency_sameclock_hwtcl HDL_PARAMETER true
   set_parameter_property l0_exit_latency_sameclock_hwtcl DERIVED true

   add_parameter l0_exit_latency_diffclock_hwtcl integer 6
   set_parameter_property l0_exit_latency_diffclock_hwtcl VISIBLE false
   set_parameter_property l0_exit_latency_diffclock_hwtcl HDL_PARAMETER true
   set_parameter_property l0_exit_latency_diffclock_hwtcl DERIVED true

   add_parameter atomic_op_routing_hwtcl string "false"
   set_parameter_property atomic_op_routing_hwtcl VISIBLE false
   set_parameter_property atomic_op_routing_hwtcl HDL_PARAMETER true
   set_parameter_property atomic_op_routing_hwtcl DERIVED true

   add_parameter atomic_op_completer_32bit_hwtcl string "false"
   set_parameter_property atomic_op_completer_32bit_hwtcl VISIBLE false
   set_parameter_property atomic_op_completer_32bit_hwtcl HDL_PARAMETER true
   set_parameter_property atomic_op_completer_32bit_hwtcl DERIVED true

   add_parameter atomic_op_completer_64bit_hwtcl string "false"
   set_parameter_property atomic_op_completer_64bit_hwtcl VISIBLE false
   set_parameter_property atomic_op_completer_64bit_hwtcl HDL_PARAMETER true
   set_parameter_property atomic_op_completer_64bit_hwtcl DERIVED true

   add_parameter cas_completer_128bit_hwtcl string "false"
   set_parameter_property cas_completer_128bit_hwtcl VISIBLE false
   set_parameter_property cas_completer_128bit_hwtcl HDL_PARAMETER true
   set_parameter_property cas_completer_128bit_hwtcl DERIVED true

   add_parameter ltr_mechanism_hwtcl string "false"
   set_parameter_property ltr_mechanism_hwtcl VISIBLE false
   set_parameter_property ltr_mechanism_hwtcl HDL_PARAMETER true
   set_parameter_property ltr_mechanism_hwtcl DERIVED true

   add_parameter tph_completer_hwtcl string "false"
   set_parameter_property tph_completer_hwtcl VISIBLE false
   set_parameter_property tph_completer_hwtcl HDL_PARAMETER true
   set_parameter_property tph_completer_hwtcl DERIVED true

   add_parameter extended_format_field_hwtcl string "false"
   set_parameter_property extended_format_field_hwtcl VISIBLE false
   set_parameter_property extended_format_field_hwtcl HDL_PARAMETER true
   set_parameter_property extended_format_field_hwtcl DERIVED true

   add_parameter atomic_malformed_hwtcl string "true"
   set_parameter_property atomic_malformed_hwtcl VISIBLE false
   set_parameter_property atomic_malformed_hwtcl HDL_PARAMETER true
   set_parameter_property atomic_malformed_hwtcl DERIVED true

   add_parameter flr_capability_hwtcl string "false"
   set_parameter_property flr_capability_hwtcl VISIBLE false
   set_parameter_property flr_capability_hwtcl HDL_PARAMETER true
   set_parameter_property flr_capability_hwtcl DERIVED true

   add_parameter enable_adapter_half_rate_mode_hwtcl string "false"
   set_parameter_property enable_adapter_half_rate_mode_hwtcl VISIBLE false
   set_parameter_property enable_adapter_half_rate_mode_hwtcl HDL_PARAMETER true
   set_parameter_property enable_adapter_half_rate_mode_hwtcl DERIVED true

   add_parameter vc0_clk_enable_hwtcl string "true"
   set_parameter_property vc0_clk_enable_hwtcl VISIBLE false
   set_parameter_property vc0_clk_enable_hwtcl HDL_PARAMETER true
   set_parameter_property vc0_clk_enable_hwtcl DERIVED true

   add_parameter register_pipe_signals_hwtcl string "false"
   set_parameter_property register_pipe_signals_hwtcl VISIBLE false
   set_parameter_property register_pipe_signals_hwtcl HDL_PARAMETER true
   set_parameter_property register_pipe_signals_hwtcl DERIVED true

   add_parameter skp_os_gen3_count_hwtcl integer 0
   set_parameter_property skp_os_gen3_count_hwtcl VISIBLE false
   set_parameter_property skp_os_gen3_count_hwtcl HDL_PARAMETER true
   set_parameter_property skp_os_gen3_count_hwtcl DERIVED true

   add_parameter tx_cdc_almost_empty_hwtcl integer 5
   set_parameter_property tx_cdc_almost_empty_hwtcl VISIBLE false
   set_parameter_property tx_cdc_almost_empty_hwtcl HDL_PARAMETER true
   set_parameter_property tx_cdc_almost_empty_hwtcl DERIVED true

   add_parameter rx_l0s_count_idl_hwtcl integer 0
   set_parameter_property rx_l0s_count_idl_hwtcl VISIBLE false
   set_parameter_property rx_l0s_count_idl_hwtcl HDL_PARAMETER true
   set_parameter_property rx_l0s_count_idl_hwtcl DERIVED true

   add_parameter cdc_dummy_insert_limit_hwtcl integer 11
   set_parameter_property cdc_dummy_insert_limit_hwtcl VISIBLE false
   set_parameter_property cdc_dummy_insert_limit_hwtcl HDL_PARAMETER true
   set_parameter_property cdc_dummy_insert_limit_hwtcl DERIVED true

   add_parameter ei_delay_powerdown_count_hwtcl integer 10
   set_parameter_property ei_delay_powerdown_count_hwtcl VISIBLE false
   set_parameter_property ei_delay_powerdown_count_hwtcl HDL_PARAMETER true
   set_parameter_property ei_delay_powerdown_count_hwtcl DERIVED true

   add_parameter skp_os_schedule_count_hwtcl integer 0
   set_parameter_property skp_os_schedule_count_hwtcl VISIBLE false
   set_parameter_property skp_os_schedule_count_hwtcl HDL_PARAMETER true
   set_parameter_property skp_os_schedule_count_hwtcl DERIVED true

   add_parameter fc_init_timer_hwtcl integer 1024
   set_parameter_property fc_init_timer_hwtcl VISIBLE false
   set_parameter_property fc_init_timer_hwtcl HDL_PARAMETER true
   set_parameter_property fc_init_timer_hwtcl DERIVED true

   add_parameter l01_entry_latency_hwtcl integer 31
   set_parameter_property l01_entry_latency_hwtcl VISIBLE false
   set_parameter_property l01_entry_latency_hwtcl HDL_PARAMETER true
   set_parameter_property l01_entry_latency_hwtcl DERIVED true

   add_parameter flow_control_update_count_hwtcl integer 30
   set_parameter_property flow_control_update_count_hwtcl VISIBLE false
   set_parameter_property flow_control_update_count_hwtcl HDL_PARAMETER true
   set_parameter_property flow_control_update_count_hwtcl DERIVED true

   add_parameter flow_control_timeout_count_hwtcl integer 200
   set_parameter_property flow_control_timeout_count_hwtcl VISIBLE false
   set_parameter_property flow_control_timeout_count_hwtcl HDL_PARAMETER true
   set_parameter_property flow_control_timeout_count_hwtcl DERIVED true

   add_parameter retry_buffer_last_active_address_hwtcl integer 2047
   set_parameter_property retry_buffer_last_active_address_hwtcl VISIBLE false
   set_parameter_property retry_buffer_last_active_address_hwtcl HDL_PARAMETER true
   set_parameter_property retry_buffer_last_active_address_hwtcl DERIVED true

   # Reserved debug pins
   add_parameter          reserved_debug_hwtcl integer 0
   set_parameter_property reserved_debug_hwtcl VISIBLE false
   set_parameter_property reserved_debug_hwtcl HDL_PARAMETER true
   set_parameter_property reserved_debug_hwtcl DERIVED true

   # DERIVED parameters with rules
   add_parameter bypass_clk_switch_hwtcl string "true"
   set_parameter_property bypass_clk_switch_hwtcl VISIBLE false
   set_parameter_property bypass_clk_switch_hwtcl DERIVED true
   set_parameter_property bypass_clk_switch_hwtcl HDL_PARAMETER true

   add_parameter l2_async_logic_hwtcl string "disable"
   set_parameter_property l2_async_logic_hwtcl VISIBLE false
   set_parameter_property l2_async_logic_hwtcl HDL_PARAMETER true
   set_parameter_property l2_async_logic_hwtcl DERIVED true

   add_parameter indicator_hwtcl integer 0
   set_parameter_property indicator_hwtcl VISIBLE false
   set_parameter_property indicator_hwtcl HDL_PARAMETER true
   set_parameter_property indicator_hwtcl DERIVED true

   add_parameter diffclock_nfts_count_hwtcl integer 128
   set_parameter_property diffclock_nfts_count_hwtcl VISIBLE false
   set_parameter_property diffclock_nfts_count_hwtcl HDL_PARAMETER true
   set_parameter_property diffclock_nfts_count_hwtcl DERIVED true

   add_parameter sameclock_nfts_count_hwtcl integer 128
   set_parameter_property sameclock_nfts_count_hwtcl VISIBLE false
   set_parameter_property sameclock_nfts_count_hwtcl HDL_PARAMETER true
   set_parameter_property sameclock_nfts_count_hwtcl DERIVED true

   add_parameter rx_cdc_almost_full_hwtcl integer 12
   set_parameter_property rx_cdc_almost_full_hwtcl VISIBLE false
   set_parameter_property rx_cdc_almost_full_hwtcl HDL_PARAMETER true
   set_parameter_property rx_cdc_almost_full_hwtcl DERIVED true

   add_parameter tx_cdc_almost_full_hwtcl integer 11
   set_parameter_property tx_cdc_almost_full_hwtcl VISIBLE false
   set_parameter_property tx_cdc_almost_full_hwtcl HDL_PARAMETER true
   set_parameter_property tx_cdc_almost_full_hwtcl DERIVED true
   add_parameter credit_buffer_allocation_aux_hwtcl string "balanced"
   set_parameter_property credit_buffer_allocation_aux_hwtcl VISIBLE false
   set_parameter_property credit_buffer_allocation_aux_hwtcl HDL_PARAMETER true
   set_parameter_property credit_buffer_allocation_aux_hwtcl DERIVED true

   add_parameter vc0_rx_flow_ctrl_posted_header_hwtcl integer 50
   set_parameter_property vc0_rx_flow_ctrl_posted_header_hwtcl VISIBLE false
   set_parameter_property vc0_rx_flow_ctrl_posted_header_hwtcl HDL_PARAMETER true
   set_parameter_property vc0_rx_flow_ctrl_posted_header_hwtcl DERIVED true

    add_parameter vc0_rx_flow_ctrl_posted_data_hwtcl integer 358
   set_parameter_property vc0_rx_flow_ctrl_posted_data_hwtcl VISIBLE false
   set_parameter_property vc0_rx_flow_ctrl_posted_data_hwtcl HDL_PARAMETER true
   set_parameter_property vc0_rx_flow_ctrl_posted_data_hwtcl DERIVED true

   add_parameter vc0_rx_flow_ctrl_nonposted_header_hwtcl integer 56
   set_parameter_property vc0_rx_flow_ctrl_nonposted_header_hwtcl VISIBLE false
   set_parameter_property vc0_rx_flow_ctrl_nonposted_header_hwtcl HDL_PARAMETER true
   set_parameter_property vc0_rx_flow_ctrl_nonposted_header_hwtcl DERIVED true

   add_parameter vc0_rx_flow_ctrl_nonposted_data_hwtcl integer 0
   set_parameter_property vc0_rx_flow_ctrl_nonposted_data_hwtcl VISIBLE false
   set_parameter_property vc0_rx_flow_ctrl_nonposted_data_hwtcl HDL_PARAMETER true
   set_parameter_property vc0_rx_flow_ctrl_nonposted_data_hwtcl DERIVED true

   add_parameter vc0_rx_flow_ctrl_compl_header_hwtcl integer 0
   set_parameter_property vc0_rx_flow_ctrl_compl_header_hwtcl VISIBLE false
   set_parameter_property vc0_rx_flow_ctrl_compl_header_hwtcl HDL_PARAMETER true
   set_parameter_property vc0_rx_flow_ctrl_compl_header_hwtcl DERIVED true

   add_parameter vc0_rx_flow_ctrl_compl_data_hwtcl integer 0
   set_parameter_property vc0_rx_flow_ctrl_compl_data_hwtcl VISIBLE false
   set_parameter_property vc0_rx_flow_ctrl_compl_data_hwtcl HDL_PARAMETER true
   set_parameter_property vc0_rx_flow_ctrl_compl_data_hwtcl DERIVED true

   add_parameter cpl_spc_header_hwtcl integer 112
   set_parameter_property cpl_spc_header_hwtcl VISIBLE false
   set_parameter_property cpl_spc_header_hwtcl HDL_PARAMETER true
   set_parameter_property cpl_spc_header_hwtcl DERIVED true

   add_parameter cpl_spc_data_hwtcl integer 448
   set_parameter_property cpl_spc_data_hwtcl VISIBLE false
   set_parameter_property cpl_spc_data_hwtcl HDL_PARAMETER true
   set_parameter_property cpl_spc_data_hwtcl DERIVED true

   add_parameter          gen3_rxfreqlock_counter_hwtcl integer 0
   set_parameter_property gen3_rxfreqlock_counter_hwtcl VISIBLE false
   set_parameter_property gen3_rxfreqlock_counter_hwtcl HDL_PARAMETER true

   add_parameter          gen3_skip_ph2_ph3_hwtcl integer 0
   set_parameter_property gen3_skip_ph2_ph3_hwtcl VISIBLE false
   set_parameter_property gen3_skip_ph2_ph3_hwtcl DERIVED true
   set_parameter_property gen3_skip_ph2_ph3_hwtcl HDL_PARAMETER true

   add_parameter          g3_bypass_equlz_hwtcl integer 0
   set_parameter_property g3_bypass_equlz_hwtcl VISIBLE false
   set_parameter_property g3_bypass_equlz_hwtcl DERIVED true
   set_parameter_property g3_bypass_equlz_hwtcl HDL_PARAMETER true

   add_parameter          cvp_data_compressed_hwtcl string "false"
   set_parameter_property cvp_data_compressed_hwtcl VISIBLE false
   set_parameter_property cvp_data_compressed_hwtcl DERIVED true
   set_parameter_property cvp_data_compressed_hwtcl HDL_PARAMETER true

   add_parameter          cvp_data_encrypted_hwtcl string "false"
   set_parameter_property cvp_data_encrypted_hwtcl VISIBLE false
   set_parameter_property cvp_data_encrypted_hwtcl DERIVED true
   set_parameter_property cvp_data_encrypted_hwtcl HDL_PARAMETER true

   add_parameter          cvp_mode_reset_hwtcl string "false"
   set_parameter_property cvp_mode_reset_hwtcl VISIBLE false
   set_parameter_property cvp_mode_reset_hwtcl DERIVED true
   set_parameter_property cvp_mode_reset_hwtcl HDL_PARAMETER true

   add_parameter          cvp_clk_reset_hwtcl string "false"
   set_parameter_property cvp_clk_reset_hwtcl VISIBLE false
   set_parameter_property cvp_clk_reset_hwtcl DERIVED true
   set_parameter_property cvp_clk_reset_hwtcl HDL_PARAMETER true

   add_parameter          cseb_cpl_status_during_cvp_hwtcl string "config_retry_status"
   set_parameter_property cseb_cpl_status_during_cvp_hwtcl VISIBLE false
   set_parameter_property cseb_cpl_status_during_cvp_hwtcl DERIVED true
   set_parameter_property cseb_cpl_status_during_cvp_hwtcl HDL_PARAMETER true

   add_parameter          core_clk_sel_hwtcl string "pld_clk"
   set_parameter_property core_clk_sel_hwtcl VISIBLE false
   set_parameter_property core_clk_sel_hwtcl DERIVED true
   set_parameter_property core_clk_sel_hwtcl HDL_PARAMETER true

   add_parameter          cvp_rate_sel_hwtcl string "full_rate"
   set_parameter_property cvp_rate_sel_hwtcl VISIBLE false
   set_parameter_property cvp_rate_sel_hwtcl DERIVED true
   set_parameter_property cvp_rate_sel_hwtcl HDL_PARAMETER true

   add_parameter          g3_dis_rx_use_prst_hwtcl string "true"
   set_parameter_property g3_dis_rx_use_prst_hwtcl VISIBLE false
   set_parameter_property g3_dis_rx_use_prst_hwtcl DERIVED true
   set_parameter_property g3_dis_rx_use_prst_hwtcl HDL_PARAMETER true

   add_parameter          g3_dis_rx_use_prst_ep_hwtcl string "true"
   set_parameter_property g3_dis_rx_use_prst_ep_hwtcl VISIBLE false
   set_parameter_property g3_dis_rx_use_prst_ep_hwtcl DERIVED true
   set_parameter_property g3_dis_rx_use_prst_ep_hwtcl HDL_PARAMETER true

   add_parameter          deemphasis_enable_hwtcl string "false"
   set_parameter_property deemphasis_enable_hwtcl VISIBLE false
   set_parameter_property deemphasis_enable_hwtcl HDL_PARAMETER true
   set_parameter_property deemphasis_enable_hwtcl DERIVED true

   add_parameter          reconfig_to_xcvr_width integer 10
   set_parameter_property reconfig_to_xcvr_width VISIBLE false
   set_parameter_property reconfig_to_xcvr_width HDL_PARAMETER true
   set_parameter_property reconfig_to_xcvr_width DERIVED true

   add_parameter          reconfig_from_xcvr_width integer 10
   set_parameter_property reconfig_from_xcvr_width VISIBLE false
   set_parameter_property reconfig_from_xcvr_width HDL_PARAMETER true
   set_parameter_property reconfig_from_xcvr_width DERIVED true

   add_parameter          single_rx_detect_hwtcl integer 0
   set_parameter_property single_rx_detect_hwtcl VISIBLE false
   set_parameter_property single_rx_detect_hwtcl DERIVED true
   set_parameter_property single_rx_detect_hwtcl HDL_PARAMETER true

   add_parameter          hip_hard_reset_hwtcl integer 0
   set_parameter_property hip_hard_reset_hwtcl VISIBLE false
   set_parameter_property hip_hard_reset_hwtcl DERIVED true
   set_parameter_property hip_hard_reset_hwtcl HDL_PARAMETER true

   add_parameter          force_hrc  integer 0
   set_parameter_property force_hrc  VISIBLE false
   set_parameter_property force_hrc  HDL_PARAMETER false

   add_parameter          force_src integer 0
   set_parameter_property force_src VISIBLE false
   set_parameter_property force_src HDL_PARAMETER false

   # Testbench related parameters
   add_parameter          serial_sim_hwtcl integer 1
   set_parameter_property serial_sim_hwtcl VISIBLE false
   set_parameter_property serial_sim_hwtcl HDL_PARAMETER false

   # derive default to enable auto update

   add_parameter          advanced_default_hwtcl_bypass_cdc string "false"
   set_parameter_property advanced_default_hwtcl_bypass_cdc VISIBLE false
   set_parameter_property advanced_default_hwtcl_bypass_cdc HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_bypass_cdc DERIVED false

   add_parameter          advanced_default_hwtcl_enable_rx_buffer_checking string "false"
   set_parameter_property advanced_default_hwtcl_enable_rx_buffer_checking VISIBLE false
   set_parameter_property advanced_default_hwtcl_enable_rx_buffer_checking HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_enable_rx_buffer_checking DERIVED false

   add_parameter          advanced_default_hwtcl_disable_link_x2_support string "false"
   set_parameter_property advanced_default_hwtcl_disable_link_x2_support VISIBLE false
   set_parameter_property advanced_default_hwtcl_disable_link_x2_support HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_disable_link_x2_support DERIVED false

   add_parameter          advanced_default_hwtcl_wrong_device_id string "disable"
   set_parameter_property advanced_default_hwtcl_wrong_device_id VISIBLE false
   set_parameter_property advanced_default_hwtcl_wrong_device_id HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_wrong_device_id DERIVED false

   add_parameter          advanced_default_hwtcl_data_pack_rx string "disable"
   set_parameter_property advanced_default_hwtcl_data_pack_rx VISIBLE false
   set_parameter_property advanced_default_hwtcl_data_pack_rx HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_data_pack_rx DERIVED false

   add_parameter          advanced_default_hwtcl_ltssm_1ms_timeout string "disable"
   set_parameter_property advanced_default_hwtcl_ltssm_1ms_timeout VISIBLE false
   set_parameter_property advanced_default_hwtcl_ltssm_1ms_timeout HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_ltssm_1ms_timeout DERIVED false

   add_parameter          advanced_default_hwtcl_ltssm_freqlocked_check string "disable"
   set_parameter_property advanced_default_hwtcl_ltssm_freqlocked_check VISIBLE false
   set_parameter_property advanced_default_hwtcl_ltssm_freqlocked_check HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_ltssm_freqlocked_check DERIVED false

   add_parameter          advanced_default_hwtcl_deskew_comma string "com_deskw"
   set_parameter_property advanced_default_hwtcl_deskew_comma VISIBLE false
   set_parameter_property advanced_default_hwtcl_deskew_comma HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_deskew_comma DERIVED false

   add_parameter          advanced_default_hwtcl_device_number integer 0
   set_parameter_property advanced_default_hwtcl_device_number VISIBLE false
   set_parameter_property advanced_default_hwtcl_device_number HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_device_number DERIVED false

   add_parameter          advanced_default_hwtcl_pipex1_debug_sel string "disable"
   set_parameter_property advanced_default_hwtcl_pipex1_debug_sel VISIBLE false
   set_parameter_property advanced_default_hwtcl_pipex1_debug_sel HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_pipex1_debug_sel DERIVED false

   add_parameter          advanced_default_hwtcl_pclk_out_sel string "pclk"
   set_parameter_property advanced_default_hwtcl_pclk_out_sel VISIBLE false
   set_parameter_property advanced_default_hwtcl_pclk_out_sel HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_pclk_out_sel DERIVED false

   add_parameter          advanced_default_hwtcl_no_soft_reset string "false"
   set_parameter_property advanced_default_hwtcl_no_soft_reset VISIBLE false
   set_parameter_property advanced_default_hwtcl_no_soft_reset HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_no_soft_reset DERIVED false

   add_parameter          advanced_default_hwtcl_maximum_current integer 0
   set_parameter_property advanced_default_hwtcl_maximum_current VISIBLE false
   set_parameter_property advanced_default_hwtcl_maximum_current HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_maximum_current DERIVED false

   add_parameter          advanced_default_hwtcl_d1_support string "false"
   set_parameter_property advanced_default_hwtcl_d1_support VISIBLE false
   set_parameter_property advanced_default_hwtcl_d1_support HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_d1_support DERIVED false

   add_parameter          advanced_default_hwtcl_d2_support string "false"
   set_parameter_property advanced_default_hwtcl_d2_support VISIBLE false
   set_parameter_property advanced_default_hwtcl_d2_support HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_d2_support DERIVED false

   add_parameter          advanced_default_hwtcl_d0_pme string "false"
   set_parameter_property advanced_default_hwtcl_d0_pme VISIBLE false
   set_parameter_property advanced_default_hwtcl_d0_pme HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_d0_pme DERIVED false

   add_parameter          advanced_default_hwtcl_d1_pme string "false"
   set_parameter_property advanced_default_hwtcl_d1_pme VISIBLE false
   set_parameter_property advanced_default_hwtcl_d1_pme HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_d1_pme DERIVED false

   add_parameter          advanced_default_hwtcl_d2_pme string "false"
   set_parameter_property advanced_default_hwtcl_d2_pme VISIBLE false
   set_parameter_property advanced_default_hwtcl_d2_pme HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_d2_pme DERIVED false

   add_parameter          advanced_default_hwtcl_d3_hot_pme string "false"
   set_parameter_property advanced_default_hwtcl_d3_hot_pme VISIBLE false
   set_parameter_property advanced_default_hwtcl_d3_hot_pme HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_d3_hot_pme DERIVED false

   add_parameter          advanced_default_hwtcl_d3_cold_pme string "false"
   set_parameter_property advanced_default_hwtcl_d3_cold_pme VISIBLE false
   set_parameter_property advanced_default_hwtcl_d3_cold_pme HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_d3_cold_pme DERIVED false

   add_parameter          advanced_default_hwtcl_low_priority_vc string "single_vc"
   set_parameter_property advanced_default_hwtcl_low_priority_vc VISIBLE false
   set_parameter_property advanced_default_hwtcl_low_priority_vc HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_low_priority_vc DERIVED false

   add_parameter          advanced_default_hwtcl_disable_snoop_packet string "false"
   set_parameter_property advanced_default_hwtcl_disable_snoop_packet VISIBLE false
   set_parameter_property advanced_default_hwtcl_disable_snoop_packet HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_disable_snoop_packet DERIVED false

   add_parameter          advanced_default_hwtcl_enable_l1_aspm string "false"
   set_parameter_property advanced_default_hwtcl_enable_l1_aspm VISIBLE false
   set_parameter_property advanced_default_hwtcl_enable_l1_aspm HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_enable_l1_aspm DERIVED false

   add_parameter          advanced_default_hwtcl_set_l0s integer 0
   set_parameter_property advanced_default_hwtcl_set_l0s VISIBLE false
   set_parameter_property advanced_default_hwtcl_set_l0s HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_set_l0s DERIVED false

   add_parameter          advanced_default_hwtcl_l1_exit_latency_sameclock integer 0
   set_parameter_property advanced_default_hwtcl_l1_exit_latency_sameclock VISIBLE false
   set_parameter_property advanced_default_hwtcl_l1_exit_latency_sameclock HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_l1_exit_latency_sameclock DERIVED false

   add_parameter          advanced_default_hwtcl_l1_exit_latency_diffclock integer 0
   set_parameter_property advanced_default_hwtcl_l1_exit_latency_diffclock VISIBLE false
   set_parameter_property advanced_default_hwtcl_l1_exit_latency_diffclock HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_l1_exit_latency_diffclock DERIVED false

   add_parameter          advanced_default_hwtcl_hot_plug_support integer 0
   set_parameter_property advanced_default_hwtcl_hot_plug_support VISIBLE false
   set_parameter_property advanced_default_hwtcl_hot_plug_support HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_hot_plug_support DERIVED false

   add_parameter          advanced_default_hwtcl_extended_tag_reset string "false"
   set_parameter_property advanced_default_hwtcl_extended_tag_reset VISIBLE false
   set_parameter_property advanced_default_hwtcl_extended_tag_reset HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_extended_tag_reset DERIVED false

   add_parameter          advanced_default_hwtcl_no_command_completed string "true"
   set_parameter_property advanced_default_hwtcl_no_command_completed VISIBLE false
   set_parameter_property advanced_default_hwtcl_no_command_completed HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_no_command_completed DERIVED false

   add_parameter          advanced_default_hwtcl_interrupt_pin string "inta"
   set_parameter_property advanced_default_hwtcl_interrupt_pin VISIBLE false
   set_parameter_property advanced_default_hwtcl_interrupt_pin HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_interrupt_pin DERIVED false

   add_parameter          advanced_default_hwtcl_bridge_port_vga_enable string "false"
   set_parameter_property advanced_default_hwtcl_bridge_port_vga_enable VISIBLE false
   set_parameter_property advanced_default_hwtcl_bridge_port_vga_enable HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_bridge_port_vga_enable DERIVED false

   add_parameter          advanced_default_hwtcl_bridge_port_ssid_support string "false"
   set_parameter_property advanced_default_hwtcl_bridge_port_ssid_support VISIBLE false
   set_parameter_property advanced_default_hwtcl_bridge_port_ssid_support HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_bridge_port_ssid_support DERIVED false

   add_parameter          advanced_default_hwtcl_ssvid integer 0
   set_parameter_property advanced_default_hwtcl_ssvid VISIBLE false
   set_parameter_property advanced_default_hwtcl_ssvid HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_ssvid DERIVED false

   add_parameter          advanced_default_hwtcl_ssid integer 0
   set_parameter_property advanced_default_hwtcl_ssid VISIBLE false
   set_parameter_property advanced_default_hwtcl_ssid HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_ssid DERIVED false

   add_parameter          advanced_default_hwtcl_eie_before_nfts_count integer 4
   set_parameter_property advanced_default_hwtcl_eie_before_nfts_count VISIBLE false
   set_parameter_property advanced_default_hwtcl_eie_before_nfts_count HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_eie_before_nfts_count DERIVED false

   add_parameter          advanced_default_hwtcl_gen2_diffclock_nfts_count integer 255
   set_parameter_property advanced_default_hwtcl_gen2_diffclock_nfts_count VISIBLE false
   set_parameter_property advanced_default_hwtcl_gen2_diffclock_nfts_count HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_gen2_diffclock_nfts_count DERIVED false

   add_parameter          advanced_default_hwtcl_gen2_sameclock_nfts_count integer 255
   set_parameter_property advanced_default_hwtcl_gen2_sameclock_nfts_count VISIBLE false
   set_parameter_property advanced_default_hwtcl_gen2_sameclock_nfts_count HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_gen2_sameclock_nfts_count DERIVED false

   add_parameter          advanced_default_hwtcl_l0_exit_latency_sameclock integer 6
   set_parameter_property advanced_default_hwtcl_l0_exit_latency_sameclock VISIBLE false
   set_parameter_property advanced_default_hwtcl_l0_exit_latency_sameclock HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_l0_exit_latency_sameclock DERIVED false

   add_parameter          advanced_default_hwtcl_l0_exit_latency_diffclock integer 6
   set_parameter_property advanced_default_hwtcl_l0_exit_latency_diffclock VISIBLE false
   set_parameter_property advanced_default_hwtcl_l0_exit_latency_diffclock HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_l0_exit_latency_diffclock DERIVED false

   add_parameter          advanced_default_hwtcl_atomic_op_routing string "false"
   set_parameter_property advanced_default_hwtcl_atomic_op_routing VISIBLE false
   set_parameter_property advanced_default_hwtcl_atomic_op_routing HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_atomic_op_routing DERIVED false

   add_parameter          advanced_default_hwtcl_atomic_op_completer_32bit string "false"
   set_parameter_property advanced_default_hwtcl_atomic_op_completer_32bit VISIBLE false
   set_parameter_property advanced_default_hwtcl_atomic_op_completer_32bit HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_atomic_op_completer_32bit DERIVED false

   add_parameter          advanced_default_hwtcl_atomic_op_completer_64bit string "false"
   set_parameter_property advanced_default_hwtcl_atomic_op_completer_64bit VISIBLE false
   set_parameter_property advanced_default_hwtcl_atomic_op_completer_64bit HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_atomic_op_completer_64bit DERIVED false

   add_parameter          advanced_default_hwtcl_cas_completer_128bit string "false"
   set_parameter_property advanced_default_hwtcl_cas_completer_128bit VISIBLE false
   set_parameter_property advanced_default_hwtcl_cas_completer_128bit HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_cas_completer_128bit DERIVED false

   add_parameter          advanced_default_hwtcl_ltr_mechanism string "false"
   set_parameter_property advanced_default_hwtcl_ltr_mechanism VISIBLE false
   set_parameter_property advanced_default_hwtcl_ltr_mechanism HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_ltr_mechanism DERIVED false

   add_parameter          advanced_default_hwtcl_tph_completer string "false"
   set_parameter_property advanced_default_hwtcl_tph_completer VISIBLE false
   set_parameter_property advanced_default_hwtcl_tph_completer HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_tph_completer DERIVED false

   add_parameter          advanced_default_hwtcl_extended_format_field string "false"
   set_parameter_property advanced_default_hwtcl_extended_format_field VISIBLE false
   set_parameter_property advanced_default_hwtcl_extended_format_field HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_extended_format_field DERIVED false

   add_parameter          advanced_default_hwtcl_atomic_malformed string "true"
   set_parameter_property advanced_default_hwtcl_atomic_malformed VISIBLE false
   set_parameter_property advanced_default_hwtcl_atomic_malformed HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_atomic_malformed DERIVED false

   add_parameter          advanced_default_hwtcl_flr_capability string "false"
   set_parameter_property advanced_default_hwtcl_flr_capability VISIBLE false
   set_parameter_property advanced_default_hwtcl_flr_capability HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_flr_capability DERIVED false

   add_parameter          advanced_default_hwtcl_enable_adapter_half_rate_mode string "false"
   set_parameter_property advanced_default_hwtcl_enable_adapter_half_rate_mode VISIBLE false
   set_parameter_property advanced_default_hwtcl_enable_adapter_half_rate_mode HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_enable_adapter_half_rate_mode DERIVED false

   add_parameter          advanced_default_hwtcl_vc0_clk_enable string "true"
   set_parameter_property advanced_default_hwtcl_vc0_clk_enable VISIBLE false
   set_parameter_property advanced_default_hwtcl_vc0_clk_enable HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_vc0_clk_enable DERIVED false

   add_parameter          advanced_default_hwtcl_register_pipe_signals string "false"
   set_parameter_property advanced_default_hwtcl_register_pipe_signals VISIBLE false
   set_parameter_property advanced_default_hwtcl_register_pipe_signals HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_register_pipe_signals DERIVED false

   add_parameter          advanced_default_hwtcl_skp_os_gen3_count integer 0
   set_parameter_property advanced_default_hwtcl_skp_os_gen3_count VISIBLE false
   set_parameter_property advanced_default_hwtcl_skp_os_gen3_count HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_skp_os_gen3_count DERIVED false

   add_parameter          advanced_default_hwtcl_tx_cdc_almost_empty integer 5
   set_parameter_property advanced_default_hwtcl_tx_cdc_almost_empty VISIBLE false
   set_parameter_property advanced_default_hwtcl_tx_cdc_almost_empty HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_tx_cdc_almost_empty DERIVED false

   add_parameter          advanced_default_hwtcl_rx_l0s_count_idl integer 0
   set_parameter_property advanced_default_hwtcl_rx_l0s_count_idl VISIBLE false
   set_parameter_property advanced_default_hwtcl_rx_l0s_count_idl HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_rx_l0s_count_idl DERIVED false

   add_parameter          advanced_default_hwtcl_cdc_dummy_insert_limit integer 11
   set_parameter_property advanced_default_hwtcl_cdc_dummy_insert_limit VISIBLE false
   set_parameter_property advanced_default_hwtcl_cdc_dummy_insert_limit HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_cdc_dummy_insert_limit DERIVED false

   add_parameter          advanced_default_hwtcl_ei_delay_powerdown_count integer 10
   set_parameter_property advanced_default_hwtcl_ei_delay_powerdown_count VISIBLE false
   set_parameter_property advanced_default_hwtcl_ei_delay_powerdown_count HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_ei_delay_powerdown_count DERIVED false

   add_parameter          advanced_default_hwtcl_skp_os_schedule_count integer 0
   set_parameter_property advanced_default_hwtcl_skp_os_schedule_count VISIBLE false
   set_parameter_property advanced_default_hwtcl_skp_os_schedule_count HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_skp_os_schedule_count DERIVED false

   add_parameter          advanced_default_hwtcl_fc_init_timer integer 1024
   set_parameter_property advanced_default_hwtcl_fc_init_timer VISIBLE false
   set_parameter_property advanced_default_hwtcl_fc_init_timer HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_fc_init_timer DERIVED false

   add_parameter          advanced_default_hwtcl_l01_entry_latency integer 31
   set_parameter_property advanced_default_hwtcl_l01_entry_latency VISIBLE false
   set_parameter_property advanced_default_hwtcl_l01_entry_latency HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_l01_entry_latency DERIVED false

   add_parameter          advanced_default_hwtcl_flow_control_update_count integer 30
   set_parameter_property advanced_default_hwtcl_flow_control_update_count VISIBLE false
   set_parameter_property advanced_default_hwtcl_flow_control_update_count HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_flow_control_update_count DERIVED false

   add_parameter          advanced_default_hwtcl_flow_control_timeout_count integer 200
   set_parameter_property advanced_default_hwtcl_flow_control_timeout_count VISIBLE false
   set_parameter_property advanced_default_hwtcl_flow_control_timeout_count HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_flow_control_timeout_count DERIVED false

   add_parameter          advanced_default_hwtcl_retry_buffer_last_active_address integer 2047
   set_parameter_property advanced_default_hwtcl_retry_buffer_last_active_address VISIBLE false
   set_parameter_property advanced_default_hwtcl_retry_buffer_last_active_address HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_retry_buffer_last_active_address DERIVED false

   add_parameter          advanced_default_hwtcl_reserved_debug integer 0
   set_parameter_property advanced_default_hwtcl_reserved_debug VISIBLE false
   set_parameter_property advanced_default_hwtcl_reserved_debug HDL_PARAMETER false
   set_parameter_property advanced_default_hwtcl_reserved_debug DERIVED false

}

proc set_pcie_cvp_parameters_common {} {
   set in_cvp_mode_hwtcl [ get_parameter_value in_cvp_mode_hwtcl ]
   if { $in_cvp_mode_hwtcl == 1 } {
      set_parameter_value  cvp_rate_sel_hwtcl "full_rate"
      set_parameter_value  cvp_data_compressed_hwtcl "false"
      set_parameter_value  cvp_data_encrypted_hwtcl "false"
      set_parameter_value  cvp_mode_reset_hwtcl "false"
      set_parameter_value  cvp_clk_reset_hwtcl "false"
      set_parameter_value  cseb_cpl_status_during_cvp_hwtcl "completer_abort"
      set_parameter_value  core_clk_sel_hwtcl "core_clk_250"
      set_parameter_value  bypass_clk_switch_hwtcl "false"
   } else {
      set_parameter_value  cvp_rate_sel_hwtcl "full_rate"
      set_parameter_value  cvp_data_compressed_hwtcl "false"
      set_parameter_value  cvp_data_encrypted_hwtcl "false"
      set_parameter_value  cvp_mode_reset_hwtcl "false"
      set_parameter_value  cvp_clk_reset_hwtcl "false"
      set_parameter_value  cseb_cpl_status_during_cvp_hwtcl "config_retry_status"
      set_parameter_value  core_clk_sel_hwtcl "pld_clk"
      set_parameter_value  bypass_clk_switch_hwtcl "true"
   }
}

proc update_default_value_hidden_parameter_common {} {
   set_parameter_value diffclock_nfts_count_hwtcl  128
   set_parameter_value sameclock_nfts_count_hwtcl  128
   set_parameter_value l2_async_logic_hwtcl        "disable"
   set_parameter_value rx_cdc_almost_full_hwtcl    12
   set_parameter_value tx_cdc_almost_full_hwtcl    11
   set_parameter_value indicator_hwtcl             0

   set port_type_hwtcl                   [get_parameter_value port_type_hwtcl ]
   set lane_mask_hwtcl                   [get_parameter_value lane_mask_hwtcl ]
   set gen123_lane_rate_mode_hwtcl       [get_parameter_value gen123_lane_rate_mode_hwtcl ]
   set use_atx_pll                       [ get_parameter_value use_atx_pll_hwtcl     ]


   if { [ regexp endpoint $port_type_hwtcl ] } {
      set_parameter_value g3_dis_rx_use_prst_ep_hwtcl "true"
   } else {
      set_parameter_value g3_dis_rx_use_prst_ep_hwtcl "false"
   }

   # Disable L0s
   set L0s [ get_parameter_value set_l0s_hwtcl ]
   if { $L0s == 1 } {
      set_parameter_value rx_ei_l0s_hwtcl 1
      set_parameter_value enable_l0s_aspm_hwtcl "true"
      if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
         set_parameter_value aspm_config_management_hwtcl "true"
         # For 2.1 : ECN ASPM optionality
      } else {
         set_parameter_value aspm_config_management_hwtcl "false"
      }
   } else {
      set_parameter_value rx_ei_l0s_hwtcl 0
      set_parameter_value enable_l0s_aspm_hwtcl "false"
      set_parameter_value aspm_config_management_hwtcl "true"
   }

   # Setting Reconfig Port width parameters
   set reconfig_interfaces 11
   if  { [ regexp x1 $lane_mask_hwtcl ] } {
      if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
         set reconfig_interfaces 3
      } else {
         set reconfig_interfaces 2
      }
      set_parameter_value single_rx_detect_hwtcl 1
   } elseif  { [ regexp x2 $lane_mask_hwtcl ] } {
      if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
         set reconfig_interfaces 4
      } else {
         set reconfig_interfaces 3
      }
      set_parameter_value single_rx_detect_hwtcl 2
   } elseif { [ regexp x4 $lane_mask_hwtcl ] } {
      if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
         set reconfig_interfaces 6
      } else {
         set reconfig_interfaces 5
      }
      set_parameter_value single_rx_detect_hwtcl 4
   } else {
      if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] }  {
         set reconfig_interfaces 11
      } else {
         set reconfig_interfaces 10
      }
      set_parameter_value single_rx_detect_hwtcl 0
   }
   set_parameter_value reconfig_to_xcvr_width   [ common_get_reconfig_to_xcvr_total_width "Stratix V" $reconfig_interfaces ]
   set_parameter_value reconfig_from_xcvr_width [ common_get_reconfig_from_xcvr_total_width "Stratix V" $reconfig_interfaces ]
   send_message info "$reconfig_interfaces reconfiguration interfaces are required for connection to the external reconfiguration controller and the reconfig driver"


   set fhrc             [ get_parameter_value force_hrc             ]
   set fsrc             [ get_parameter_value force_src             ]

   if {$use_atx_pll==1} {
       set_parameter_value hip_hard_reset_hwtcl 0
       send_message info "ATX PLL only supported with Soft Reset Controller. Hard Reset Controller is disabled"
       if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
         send_message warning "CMU PLL  is also used for all Gen3 variants"
       }
   } else {
      if { $fhrc == 1  } {
        # Force using HARD Reset controller
        set_parameter_value hip_hard_reset_hwtcl 1
        send_message info "Hard Reset Controller enabled"
      } elseif {  $fsrc == 1  } {
        # Force using SOFT Reset controller
        set_parameter_value hip_hard_reset_hwtcl 0
      } elseif { [ regexp Gen1 $gen123_lane_rate_mode_hwtcl ] } {
        # Default to HARD Reset controller for Gen1
        set_parameter_value hip_hard_reset_hwtcl 1
        send_message info "Hard Reset Controller enabled"
      } else {
        # Default to SOFT Reset controller for Gen1/Gen2
        set_parameter_value hip_hard_reset_hwtcl 0
      }
   }

   if { [ regexp endpoint $port_type_hwtcl ] } {
      set_parameter_value g3_dis_rx_use_prst_ep_hwtcl "true"
   } else {
      set_parameter_value g3_dis_rx_use_prst_ep_hwtcl "false"
   }

   add_pcie_hip_common_hidden_parameters_update
}


proc add_pcie_hip_common_hidden_parameters_update {} {
   # This proc is used to update hidden parameter values of QSYS system created
   # with a previous HWTCL version and different hidden parameter value
   send_message debug "proc:add_pcie_hip_common_hidden_parameters_update"
   set advanced_default_parameter_override  [ get_parameter_value advanced_default_parameter_override ]
   if { $advanced_default_parameter_override == 0 } {
      set_parameter_value bypass_cdc_hwtcl                           "false"
      set_parameter_value enable_rx_buffer_checking_hwtcl            "false"
      set_parameter_value disable_link_x2_support_hwtcl              "false"
      set_parameter_value wrong_device_id_hwtcl                      "disable"
      set_parameter_value data_pack_rx_hwtcl                         "disable"
      set_parameter_value ltssm_1ms_timeout_hwtcl                    "disable"
      set_parameter_value ltssm_freqlocked_check_hwtcl               "disable"
      set_parameter_value deskew_comma_hwtcl                         "skp_eieos_deskw"
      set_parameter_value device_number_hwtcl                        0
      set_parameter_value pipex1_debug_sel_hwtcl                     "disable"
      set_parameter_value pclk_out_sel_hwtcl                         "pclk"
      set_parameter_value no_soft_reset_hwtcl                        "false"
      set_parameter_value maximum_current_hwtcl                      0
      set_parameter_value d1_support_hwtcl                           "false"
      set_parameter_value d2_support_hwtcl                           "false"
      set_parameter_value d0_pme_hwtcl                               "false"
      set_parameter_value d1_pme_hwtcl                               "false"
      set_parameter_value d2_pme_hwtcl                               "false"
      set_parameter_value d3_hot_pme_hwtcl                           "false"
      set_parameter_value d3_cold_pme_hwtcl                          "false"
      set_parameter_value low_priority_vc_hwtcl                      "single_vc"
      set_parameter_value disable_snoop_packet_hwtcl                 "false"
      set_parameter_value enable_l1_aspm_hwtcl                       "false"
      set_parameter_value set_l0s_hwtcl                              0
      set_parameter_value l1_exit_latency_sameclock_hwtcl            0
      set_parameter_value l1_exit_latency_diffclock_hwtcl            0
      set_parameter_value hot_plug_support_hwtcl                     0
      set_parameter_value extended_tag_reset_hwtcl                   "false"
      set_parameter_value no_command_completed_hwtcl                 "true"
      set_parameter_value interrupt_pin_hwtcl                        "inta"
      set_parameter_value bridge_port_vga_enable_hwtcl               "false"
      set_parameter_value bridge_port_ssid_support_hwtcl             "false"
      set_parameter_value ssvid_hwtcl                                0
      set_parameter_value ssid_hwtcl                                 0
      set_parameter_value eie_before_nfts_count_hwtcl                4
      set_parameter_value gen2_diffclock_nfts_count_hwtcl            255
      set_parameter_value gen2_sameclock_nfts_count_hwtcl            255
      set_parameter_value l0_exit_latency_sameclock_hwtcl            6
      set_parameter_value l0_exit_latency_diffclock_hwtcl            6
      set_parameter_value atomic_op_routing_hwtcl                    "false"
      set_parameter_value atomic_op_completer_32bit_hwtcl            "false"
      set_parameter_value atomic_op_completer_64bit_hwtcl            "false"
      set_parameter_value cas_completer_128bit_hwtcl                 "false"
      set_parameter_value ltr_mechanism_hwtcl                        "false"
      set_parameter_value tph_completer_hwtcl                        "false"
      set_parameter_value extended_format_field_hwtcl                "false"
      set_parameter_value atomic_malformed_hwtcl                     "true"
      set_parameter_value flr_capability_hwtcl                       "false"
      set_parameter_value enable_adapter_half_rate_mode_hwtcl        "false"
      set_parameter_value vc0_clk_enable_hwtcl                       "true"
      set_parameter_value register_pipe_signals_hwtcl                "false"
      set_parameter_value skp_os_gen3_count_hwtcl                    0
      set_parameter_value tx_cdc_almost_empty_hwtcl                  5
      set_parameter_value rx_l0s_count_idl_hwtcl                     0
      set_parameter_value cdc_dummy_insert_limit_hwtcl               11
      set_parameter_value ei_delay_powerdown_count_hwtcl             10
      set_parameter_value skp_os_schedule_count_hwtcl                0
      set_parameter_value fc_init_timer_hwtcl                        1024
      set_parameter_value l01_entry_latency_hwtcl                    31
      set_parameter_value flow_control_update_count_hwtcl            30
      set_parameter_value flow_control_timeout_count_hwtcl           200
      set_parameter_value retry_buffer_last_active_address_hwtcl     2047
      set_parameter_value reserved_debug_hwtcl                       0
   } else {
      set_parameter_value bypass_cdc_hwtcl                          [ get_parameter_value  advanced_default_hwtcl_bypass_cdc                                    ]
      set_parameter_value enable_rx_buffer_checking_hwtcl           [ get_parameter_value  advanced_default_hwtcl_enable_rx_buffer_checking                     ]
      set_parameter_value disable_link_x2_support_hwtcl             [ get_parameter_value  advanced_default_hwtcl_disable_link_x2_support                       ]
      set_parameter_value wrong_device_id_hwtcl                     [ get_parameter_value  advanced_default_hwtcl_wrong_device_id                               ]
      set_parameter_value data_pack_rx_hwtcl                        [ get_parameter_value  advanced_default_hwtcl_data_pack_rx                                  ]
      set_parameter_value ltssm_1ms_timeout_hwtcl                   [ get_parameter_value  advanced_default_hwtcl_ltssm_1ms_timeout                             ]
      set_parameter_value ltssm_freqlocked_check_hwtcl              [ get_parameter_value  advanced_default_hwtcl_ltssm_freqlocked_check                        ]
      set_parameter_value deskew_comma_hwtcl                        [ get_parameter_value  advanced_default_hwtcl_deskew_comma                                  ]
      set_parameter_value device_number_hwtcl                       [ get_parameter_value  advanced_default_hwtcl_device_number                                 ]
      set_parameter_value pipex1_debug_sel_hwtcl                    [ get_parameter_value  advanced_default_hwtcl_pipex1_debug_sel                              ]
      set_parameter_value pclk_out_sel_hwtcl                        [ get_parameter_value  advanced_default_hwtcl_pclk_out_sel                                  ]
      set_parameter_value no_soft_reset_hwtcl                       [ get_parameter_value  advanced_default_hwtcl_no_soft_reset                                 ]
      set_parameter_value maximum_current_hwtcl                     [ get_parameter_value  advanced_default_hwtcl_maximum_current                               ]
      set_parameter_value d1_support_hwtcl                          [ get_parameter_value  advanced_default_hwtcl_d1_support                                    ]
      set_parameter_value d2_support_hwtcl                          [ get_parameter_value  advanced_default_hwtcl_d2_support                                    ]
      set_parameter_value d0_pme_hwtcl                              [ get_parameter_value  advanced_default_hwtcl_d0_pme                                        ]
      set_parameter_value d1_pme_hwtcl                              [ get_parameter_value  advanced_default_hwtcl_d1_pme                                        ]
      set_parameter_value d2_pme_hwtcl                              [ get_parameter_value  advanced_default_hwtcl_d2_pme                                        ]
      set_parameter_value d3_hot_pme_hwtcl                          [ get_parameter_value  advanced_default_hwtcl_d3_hot_pme                                    ]
      set_parameter_value d3_cold_pme_hwtcl                         [ get_parameter_value  advanced_default_hwtcl_d3_cold_pme                                   ]
      set_parameter_value low_priority_vc_hwtcl                     [ get_parameter_value  advanced_default_hwtcl_low_priority_vc                               ]
      set_parameter_value disable_snoop_packet_hwtcl                [ get_parameter_value  advanced_default_hwtcl_disable_snoop_packet                          ]
      set_parameter_value enable_l1_aspm_hwtcl                      [ get_parameter_value  advanced_default_hwtcl_enable_l1_aspm                                ]
      set_parameter_value set_l0s_hwtcl                             [ get_parameter_value  advanced_default_hwtcl_set_l0s                                       ]
      set_parameter_value l1_exit_latency_sameclock_hwtcl           [ get_parameter_value  advanced_default_hwtcl_l1_exit_latency_sameclock                     ]
      set_parameter_value l1_exit_latency_diffclock_hwtcl           [ get_parameter_value  advanced_default_hwtcl_l1_exit_latency_diffclock                     ]
      set_parameter_value hot_plug_support_hwtcl                    [ get_parameter_value  advanced_default_hwtcl_hot_plug_support                              ]
      set_parameter_value extended_tag_reset_hwtcl                  [ get_parameter_value  advanced_default_hwtcl_extended_tag_reset                            ]
      set_parameter_value no_command_completed_hwtcl                [ get_parameter_value  advanced_default_hwtcl_no_command_completed                          ]
      set_parameter_value interrupt_pin_hwtcl                       [ get_parameter_value  advanced_default_hwtcl_interrupt_pin                                 ]
      set_parameter_value bridge_port_vga_enable_hwtcl              [ get_parameter_value  advanced_default_hwtcl_bridge_port_vga_enable                        ]
      set_parameter_value bridge_port_ssid_support_hwtcl            [ get_parameter_value  advanced_default_hwtcl_bridge_port_ssid_support                      ]
      set_parameter_value ssvid_hwtcl                               [ get_parameter_value  advanced_default_hwtcl_ssvid                                         ]
      set_parameter_value ssid_hwtcl                                [ get_parameter_value  advanced_default_hwtcl_ssid                                          ]
      set_parameter_value eie_before_nfts_count_hwtcl               [ get_parameter_value  advanced_default_hwtcl_eie_before_nfts_count                         ]
      set_parameter_value gen2_diffclock_nfts_count_hwtcl           [ get_parameter_value  advanced_default_hwtcl_gen2_diffclock_nfts_count                     ]
      set_parameter_value gen2_sameclock_nfts_count_hwtcl           [ get_parameter_value  advanced_default_hwtcl_gen2_sameclock_nfts_count                     ]
      set_parameter_value l0_exit_latency_sameclock_hwtcl           [ get_parameter_value  advanced_default_hwtcl_l0_exit_latency_sameclock                     ]
      set_parameter_value l0_exit_latency_diffclock_hwtcl           [ get_parameter_value  advanced_default_hwtcl_l0_exit_latency_diffclock                     ]
      set_parameter_value atomic_op_routing_hwtcl                   [ get_parameter_value  advanced_default_hwtcl_atomic_op_routing                             ]
      set_parameter_value atomic_op_completer_32bit_hwtcl           [ get_parameter_value  advanced_default_hwtcl_atomic_op_completer_32bit                     ]
      set_parameter_value atomic_op_completer_64bit_hwtcl           [ get_parameter_value  advanced_default_hwtcl_atomic_op_completer_64bit                     ]
      set_parameter_value cas_completer_128bit_hwtcl                [ get_parameter_value  advanced_default_hwtcl_cas_completer_128bit                          ]
      set_parameter_value ltr_mechanism_hwtcl                       [ get_parameter_value  advanced_default_hwtcl_ltr_mechanism                                 ]
      set_parameter_value tph_completer_hwtcl                       [ get_parameter_value  advanced_default_hwtcl_tph_completer                                 ]
      set_parameter_value extended_format_field_hwtcl               [ get_parameter_value  advanced_default_hwtcl_extended_format_field                         ]
      set_parameter_value atomic_malformed_hwtcl                    [ get_parameter_value  advanced_default_hwtcl_atomic_malformed                              ]
      set_parameter_value flr_capability_hwtcl                      [ get_parameter_value  advanced_default_hwtcl_flr_capability                                ]
      set_parameter_value enable_adapter_half_rate_mode_hwtcl       [ get_parameter_value  advanced_default_hwtcl_enable_adapter_half_rate_mode                 ]
      set_parameter_value vc0_clk_enable_hwtcl                      [ get_parameter_value  advanced_default_hwtcl_vc0_clk_enable                                ]
      set_parameter_value register_pipe_signals_hwtcl               [ get_parameter_value  advanced_default_hwtcl_register_pipe_signals                         ]
      set_parameter_value skp_os_gen3_count_hwtcl                   [ get_parameter_value  advanced_default_hwtcl_skp_os_gen3_count                             ]
      set_parameter_value tx_cdc_almost_empty_hwtcl                 [ get_parameter_value  advanced_default_hwtcl_tx_cdc_almost_empty                           ]
      set_parameter_value rx_l0s_count_idl_hwtcl                    [ get_parameter_value  advanced_default_hwtcl_rx_l0s_count_idl                              ]
      set_parameter_value cdc_dummy_insert_limit_hwtcl              [ get_parameter_value  advanced_default_hwtcl_cdc_dummy_insert_limit                        ]
      set_parameter_value ei_delay_powerdown_count_hwtcl            [ get_parameter_value  advanced_default_hwtcl_ei_delay_powerdown_count                      ]
      set_parameter_value skp_os_schedule_count_hwtcl               [ get_parameter_value  advanced_default_hwtcl_skp_os_schedule_count                         ]
      set_parameter_value fc_init_timer_hwtcl                       [ get_parameter_value  advanced_default_hwtcl_fc_init_timer                                 ]
      set_parameter_value l01_entry_latency_hwtcl                   [ get_parameter_value  advanced_default_hwtcl_l01_entry_latency                             ]
      set_parameter_value flow_control_update_count_hwtcl           [ get_parameter_value  advanced_default_hwtcl_flow_control_update_count                     ]
      set_parameter_value flow_control_timeout_count_hwtcl          [ get_parameter_value  advanced_default_hwtcl_flow_control_timeout_count                    ]
      set_parameter_value retry_buffer_last_active_address_hwtcl    [ get_parameter_value  advanced_default_hwtcl_retry_buffer_last_active_address              ]
      set_parameter_value reserved_debug_hwtcl                      [ get_parameter_value  advanced_default_hwtcl_reserved_debug                                ]
   }
}

proc add_pcie_hip_gen2_vod {} {

   send_message debug "proc:add_pcie_hip_gen2_vod"

   # hwtcl_override_g2_txvod : When 1 override RTL default setting of GEN2 TX VOD
   add_parameter          hwtcl_override_g2_txvod integer 1
   set_parameter_property hwtcl_override_g2_txvod VISIBLE false
   set_parameter_property hwtcl_override_g2_txvod HDL_PARAMETER true

   add_parameter          rpre_emph_a_val_hwtcl integer 9
   set_parameter_property rpre_emph_a_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_a_val_hwtcl HDL_PARAMETER true

   add_parameter          rpre_emph_b_val_hwtcl integer 0
   set_parameter_property rpre_emph_b_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_b_val_hwtcl HDL_PARAMETER true

   add_parameter          rpre_emph_c_val_hwtcl integer 16
   set_parameter_property rpre_emph_c_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_c_val_hwtcl HDL_PARAMETER true

   add_parameter          rpre_emph_d_val_hwtcl integer 13
   set_parameter_property rpre_emph_d_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_d_val_hwtcl HDL_PARAMETER true

   add_parameter          rpre_emph_e_val_hwtcl integer 5
   set_parameter_property rpre_emph_e_val_hwtcl VISIBLE false
   set_parameter_property rpre_emph_e_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_a_val_hwtcl integer 42
   set_parameter_property rvod_sel_a_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_a_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_b_val_hwtcl integer 38
   set_parameter_property rvod_sel_b_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_b_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_c_val_hwtcl integer 38
   set_parameter_property rvod_sel_c_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_c_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_d_val_hwtcl integer 43
   set_parameter_property rvod_sel_d_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_d_val_hwtcl HDL_PARAMETER true

   add_parameter          rvod_sel_e_val_hwtcl integer 15
   set_parameter_property rvod_sel_e_val_hwtcl VISIBLE false
   set_parameter_property rvod_sel_e_val_hwtcl HDL_PARAMETER true
}
