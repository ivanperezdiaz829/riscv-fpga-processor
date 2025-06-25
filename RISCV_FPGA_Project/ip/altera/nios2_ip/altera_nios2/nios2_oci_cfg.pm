#Copyright (C)2001-2010 Altera Corporation
#Any megafunction design, and related net list (encrypted or decrypted),
#support information, device programming or simulation file, and any other
#associated documentation or information provided by Altera or a partner
#under Altera's Megafunction Partnership Program may be used only to
#program PLD devices (but not masked PLD devices) from Altera.  Any other
#use of such megafunction design, net list, support information, device
#programming or simulation file, or any other related documentation or
#information is prohibited for any other purpose, including, but not
#limited to modification, reverse engineering, de-compiling, or use with
#any other silicon devices, unless such use is explicitly licensed under
#a separate agreement with Altera or a megafunction partner.  Title to
#the intellectual property, including patents, copyrights, trademarks,
#trade secrets, or maskworks, embodied in any such megafunction design,
#net list, support information, device programming or simulation file, or
#any other related documentation or information provided by Altera or a
#megafunction partner, remains with Altera, the megafunction partner, or
#their respective licensors.  No other licenses, including any licenses
#needed under any third party's intellectual property, are provided herein.
#Copying or modifying any file, or portion thereof, to which this notice
#is attached violates this copyright.






















package nios2_oci_cfg;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $DBG_SLAVE_ADDR_SZ
    $DBG_SLAVE_ADDR_MSB
    $DBG_SLAVE_ADDR_LSB

    $IRC_OCIMEM
    $IRC_TRACEMEM
    $IRC_BREAK
    $IRC_TRACECTRL

    $TRACE_VERSION_1
    
    $SZ_1
    $SZ_2
    $SZ_8
    $SZ_16
    $SZ_32
    $SZ_36
    $SZ_38
    
    $SZ_IR
    $SZ_OCIMEM
    $SZ_TRACEMEM
    $SZ_BREAK
    $SZ_TRACECTRL
    
    $IR_WIDTH
    $OCIMEM_WIDTH
    $TRACEMEM_WIDTH
    $BREAK_WIDTH
    $TRACECTRL_WIDTH
    
    $SR_WIDTH
    $SR_MSB
    
    $OCIMEM_MR_POS
    $OCIMEM_RDDATA_LSB_POS
    $OCIMEM_RDDATA_MSB_POS
    $OCIMEM_RST_POS
    $OCIMEM_ER_POS
    $OCIMEM_DA_POS
    
    $OCIMEM_A_OR_B_POS
    $OCIMEM_A_ACT_POS
    $OCIMEM_A_ADDR_A9_POS
    $OCIMEM_A_ADDR_A2_POS
    $OCIMEM_A_MRC_POS
    $OCIMEM_A_RSTC_POS
    $OCIMEM_A_GOS_POS
    $OCIMEM_A_RSTR_POS
    $OCIMEM_A_DRS_POS
    $OCIMEM_A_DRC_POS
    $OCIMEM_A_BRSTS_POS
    $OCIMEM_A_BRSTC_POS
    $OCIMEM_A_ADDR_A10_POS
    $OCIMEM_B_WRDATA_MSB_POS
    $OCIMEM_B_WRDATA_LSB_POS
    
    $TRACEMEM_TW_POS
    $TRACEMEM_ON_POS
    $TRACEMEM_RDDATA_MSB_POS
    $TRACEMEM_RDDATA_LSB_POS
    $TRACEMEM_A_OR_B_POS
    $TRACEMEM_A_ACT_POS
    $TRACEMEM_A_TRCADDR_MSB_POS
    $TRACEMEM_A_TRCADDR_LSB_POS
    $TRACEMEM_B_TRCDATA_MSB_POS
    $TRACEMEM_B_TRCDATA_LSB_POS
    $TRACEMEM_B_TRCDATA_BITS
    
    $BREAK_TS_POS
    $BREAK_W3_POS
    $BREAK_W2_POS
    $BREAK_W1_POS
    $BREAK_W0_POS
    $BREAK_RDDATA_MSB_POS
    $BREAK_RDDATA_LSB_POS
    $BREAK_TB_POS
    
    $BREAK_W_POS
    $BREAK_A_OR_B_C_POS
    $BREAK_B_OR_C_POS
    $BREAK_A_WPR_MSB_POS
    $BREAK_A_WPR_LSB_POS
    $BREAK_A_WRDATA_MSB_POS
    $BREAK_A_WRDATA_LSB_POS
    $BREAK_B_RR_MSB_POS
    $BREAK_B_RR_LSB_POS
    $BREAK_B_TON_POS
    $BREAK_B_TOFF_POS
    $BREAK_B_TOUT_POS
    $BREAK_B_BRK_POS
    $BREAK_B_ARM0_POS
    $BREAK_B_ARM1_POS
    $BREAK_B_GOTO0_POS
    $BREAK_B_GOTO1_POS
    
    $BREAK_C_RR_MSB_POS
    $BREAK_C_RR_LSB_POS
    $BREAK_C_TME_POS
    $BREAK_C_TON_POS
    $BREAK_C_TOFF_POS
    $BREAK_C_TOUT_POS
    $BREAK_C_BRK_POS
    $BREAK_C_DU_POS
    $BREAK_C_AU_POS
    $BREAK_C_LD_POS
    $BREAK_C_ST_POS
    $BREAK_C_PAIR_POS
    $BREAK_C_ARM0_POS
    $BREAK_C_ARM1_POS
    $BREAK_C_GOTO0_POS
    $BREAK_C_GOTO1_POS
    
    $TRACECTRL_RESERVED_MSB_POS
    $TRACECTRL_RESERVED_LSB_POS
    $TRACECTRL_RESERVED_BITS
    $TRACECTRL_TRCACQADDR_MSB_POS
    $TRACECTRL_TRCACQADDR_LSB_POS
    $TRACECTRL_TRCACQADDR_BITS
    $TRACECTRL_TW_POS
    $TRACECTRL_ON_POS
    
    $TRACECTRL_ACT_POS
    $TRACECTRL_DB_POS
    $TRACECTRL_OFC_POS
    $TRACECTRL_TD_MSB_POS
    $TRACECTRL_TD_LSB_POS
    $TRACECTRL_TD_POS
    $TRACECTRL_TX_POS
    $TRACECTRL_SYN_MSB_POS
    $TRACECTRL_SYN_LSB_POS
    $TRACECTRL_SYN_POS
    $TRACECTRL_ON_OFF_POS
    $TRACECTRL_ENB_POS
    $TRACECTRL_TAAR_POS
    $TRACECTRL_TWR_POS
    $TRACECTRL_FULL_POS
    
    $OCIREG_MRS_POS
    $OCIREG_ERS_POS
    $OCIREG_GO_POS
    $OCIREG_SSTEP_POS
       
    $TM_NOP
    $TM_DCT
    $TM_EXC
    $TM_PID
    $TM_LDA
    $TM_STA
    $TM_LDD
    $TM_STD
    $TM_SYNC
    $TM_IDCT
    $TM_GAP
    $TM_LDAV
    $TM_STAV
    $TM_LDDV
    $TM_STDV
    
    $PAYLOAD_EXC_EXCEPTED_ADDR
    $PAYLOAD_EXC_HANDLER_ADDR
    
    $xbrk_ctrl_brk_bit
    $xbrk_ctrl_tout_bit
    $xbrk_ctrl_toff_bit
    $xbrk_ctrl_ton_bit
    $xbrk_ctrl_arm0_bit
    $xbrk_ctrl_arm1_bit
    $xbrk_ctrl_goto0_bit
    $xbrk_ctrl_goto1_bit
    
    $dbrk_paired_bit
    $dbrk_writeenb_bit
    $dbrk_readenb_bit
    $dbrk_addrused_bit
    $dbrk_dataused_bit
    $dbrk_break_bit
    $dbrk_trigout_bit
    $dbrk_traceoff_bit
    $dbrk_traceon_bit
    $dbrk_traceme_bit
    $dbrk_arm0_bit
    $dbrk_arm1_bit
    $dbrk_goto0_bit
    $dbrk_goto1_bit
    
    $TRC_ENB_BIT
    $TRC_ON_BIT
    $TRC_SYN_BITS
    $TRC_TX_BIT
    $TRC_TD_BITS
    $TRC_OFC_BIT
    $TRC_DEBUG_BIT
    $TRC_FULL_BIT
    
    $IDCODE_OCINIOS2
);

use strict;



















our $DBG_SLAVE_ADDR_SZ = 9;
our $DBG_SLAVE_ADDR_MSB = ($DBG_SLAVE_ADDR_SZ - 1);
our $DBG_SLAVE_ADDR_LSB = 0;

our $IRC_OCIMEM     = "2'b00";
our $IRC_TRACEMEM   = "2'b01";
our $IRC_BREAK      = "2'b10";
our $IRC_TRACECTRL  = "2'b11";

our $TRACE_VERSION_0 = 0x0; # LSB of EXC records general/fast TLB miss
our $TRACE_VERSION_1 = 0x1; # LSB of EXC records excepted PC+4 or handler PC 


our $SZ_1  = "3'b000";
our $SZ_2  = "3'b110";
our $SZ_8  = "3'b001";
our $SZ_16 = "3'b010";
our $SZ_32 = "3'b011";
our $SZ_36 = "3'b100";
our $SZ_38 = "3'b101";


our $SZ_IR         = $SZ_2;
our $SZ_OCIMEM     = $SZ_36;
our $SZ_TRACEMEM   = $SZ_38;
our $SZ_BREAK      = $SZ_38;
our $SZ_TRACECTRL  = $SZ_16;


our $IR_WIDTH         = 2;
our $OCIMEM_WIDTH     = 36;
our $TRACEMEM_WIDTH   = 38;
our $BREAK_WIDTH      = 38;
our $TRACECTRL_WIDTH  = 16;

our $SR_WIDTH = &private_max ([$OCIMEM_WIDTH, $TRACEMEM_WIDTH, 
                               $BREAK_WIDTH, $TRACECTRL_WIDTH]);
our $SR_MSB   = $SR_WIDTH - 1;








our $OCIMEM_MR_POS  = 0;
our $OCIMEM_RDDATA_LSB_POS = 1;
our $OCIMEM_RDDATA_MSB_POS = 32;
our $OCIMEM_RST_POS = 33;
our $OCIMEM_ER_POS  = 34;
our $OCIMEM_DA_POS  = 35;


our $OCIMEM_A_OR_B_POS      = 35;

our $OCIMEM_A_ACT_POS       = 34;
our $OCIMEM_A_ADDR_A9_POS   = 33;
our $OCIMEM_A_ADDR_A2_POS   = 26;
our $OCIMEM_A_MRC_POS       = 25;
our $OCIMEM_A_RSTC_POS      = 24;
our $OCIMEM_A_GOS_POS       = 23;
our $OCIMEM_A_RSTR_POS      = 22;
our $OCIMEM_A_DRS_POS       = 21;
our $OCIMEM_A_DRC_POS       = 20;
our $OCIMEM_A_BRSTS_POS     = 19;
our $OCIMEM_A_BRSTC_POS     = 18;
our $OCIMEM_A_ADDR_A10_POS  = 17;

our $OCIMEM_B_WRDATA_MSB_POS  = 34;
our $OCIMEM_B_WRDATA_LSB_POS  = 3;


our $TRACEMEM_TW_POS          = 37;
our $TRACEMEM_ON_POS          = 36;
our $TRACEMEM_RDDATA_MSB_POS  = 35;
our $TRACEMEM_RDDATA_LSB_POS  = 0;


our $TRACEMEM_A_OR_B_POS      = 37;

our $TRACEMEM_A_ACT_POS           = 36;
our $TRACEMEM_A_TRCADDR_MSB_POS   = 35;
our $TRACEMEM_A_TRCADDR_LSB_POS   = 19;

our $TRACEMEM_B_TRCDATA_MSB_POS   = 36;
our $TRACEMEM_B_TRCDATA_LSB_POS   = 1;
our $TRACEMEM_B_TRCDATA_BITS      = "$TRACEMEM_B_TRCDATA_MSB_POS : 
                                 $TRACEMEM_B_TRCDATA_LSB_POS";


our $BREAK_TS_POS           = 37;
our $BREAK_W3_POS           = 36;
our $BREAK_W2_POS           = 35;
our $BREAK_W1_POS           = 34;
our $BREAK_W0_POS           = 33;
our $BREAK_RDDATA_MSB_POS   = 32;
our $BREAK_RDDATA_LSB_POS   = 1;
our $BREAK_TB_POS           = 0;


our $BREAK_W_POS            = 37;
our $BREAK_A_OR_B_C_POS     = 36;
our $BREAK_B_OR_C_POS       = 35;

our $BREAK_A_WPR_MSB_POS      = 35;
our $BREAK_A_WPR_LSB_POS      = 32;
our $BREAK_A_WRDATA_MSB_POS   = 31;
our $BREAK_A_WRDATA_LSB_POS   = 0;

our $BREAK_B_RR_MSB_POS       = 33;
our $BREAK_B_RR_LSB_POS       = 32;
our $BREAK_B_TON_POS          = 30;
our $BREAK_B_TOFF_POS         = 29;
our $BREAK_B_TOUT_POS         = 28;
our $BREAK_B_BRK_POS          = 27;
our $BREAK_B_ARM0_POS         = 21;
our $BREAK_B_ARM1_POS         = 20;
our $BREAK_B_GOTO0_POS        = 19;
our $BREAK_B_GOTO1_POS        = 18;

our $BREAK_C_RR_MSB_POS       = 33;
our $BREAK_C_RR_LSB_POS       = 32;
our $BREAK_C_TME_POS          = 31;
our $BREAK_C_TON_POS          = 30;
our $BREAK_C_TOFF_POS         = 29;
our $BREAK_C_TOUT_POS         = 28;
our $BREAK_C_BRK_POS          = 27;
our $BREAK_C_DU_POS           = 26;
our $BREAK_C_AU_POS           = 25;
our $BREAK_C_LD_POS           = 24;
our $BREAK_C_ST_POS           = 23;
our $BREAK_C_PAIR_POS         = 22;
our $BREAK_C_ARM0_POS         = 21;
our $BREAK_C_ARM1_POS         = 20;
our $BREAK_C_GOTO0_POS        = 19;
our $BREAK_C_GOTO1_POS        = 18;


our $TRACECTRL_TRCACQADDR_MSB_POS = 15;
our $TRACECTRL_TRCACQADDR_LSB_POS = 2;
our $TRACECTRL_TRCACQADDR_BITS    = "$TRACECTRL_TRCACQADDR_MSB_POS : 
                                     $TRACECTRL_TRCACQADDR_LSB_POS";
our $TRACECTRL_TW_POS             = 1;
our $TRACECTRL_ON_POS             = 0;


our $TRACECTRL_ACT_POS      = 15;
our $TRACECTRL_DB_POS       = 14;
our $TRACECTRL_OFC_POS      = 13;
our $TRACECTRL_TD_MSB_POS   = 12;
our $TRACECTRL_TD_LSB_POS   = 10;
our $TRACECTRL_TD_POS       = "$TRACECTRL_TD_MSB_POS : $TRACECTRL_TD_LSB_POS";
our $TRACECTRL_TX_POS       = 9;
our $TRACECTRL_SYN_MSB_POS  = 8;
our $TRACECTRL_SYN_LSB_POS  = 7;
our $TRACECTRL_SYN_POS      = "$TRACECTRL_SYN_MSB_POS : $TRACECTRL_SYN_LSB_POS";
our $TRACECTRL_ON_OFF_POS   = 6;
our $TRACECTRL_ENB_POS      = 5;
our $TRACECTRL_TAAR_POS     = 4;
our $TRACECTRL_TWR_POS      = 3;
our $TRACECTRL_FULL_POS     = 2;





our $OCIREG_MRS_POS   = 0;
our $OCIREG_ERS_POS   = 1;
our $OCIREG_GO_POS    = 2;
our $OCIREG_SSTEP_POS = 3;
   





our $TM_NOP   = "4'b0000";     # no message
our $TM_DCT   = "4'b0001";     # direct control transfer instruction
our $TM_EXC  =  "4'b0010";     # exception
our $TM_PID  =  "4'b0011";     # MMU PID (Process Identifier)
our $TM_LDA   = "4'b0100";     # load address
our $TM_STA   = "4'b0101";     # store address
our $TM_LDD   = "4'b0110";     # load data
our $TM_STD   = "4'b0111";     # store data
our $TM_SYNC  = "4'b1000";     # periodic address sync
our $TM_IDCT  = "4'b1001";     # indirect control transfer instruction
our $TM_GAP   = "4'b1010";     # gap in record precedes this tm
our $TM_LDAV  = "4'b1100";     # load address after fifo overflow
our $TM_STAV  = "4'b1101";     # store address after fifo overflow
our $TM_LDDV  = "4'b1110";     # load data after fifo overflow
our $TM_STDV  = "4'b1111";     # store data after fifo overflow







our $PAYLOAD_EXC_EXCEPTED_ADDR = "1'b0";   # Addr of instruction took exception
our $PAYLOAD_EXC_HANDLER_ADDR  = "1'b1";   # Exception handler address












our $xbrk_ctrl_brk_bit    = 0;
our $xbrk_ctrl_tout_bit   = 1;
our $xbrk_ctrl_toff_bit   = 2;
our $xbrk_ctrl_ton_bit    = 3;
our $xbrk_ctrl_arm0_bit   = 4;
our $xbrk_ctrl_arm1_bit   = 5;
our $xbrk_ctrl_goto0_bit  = 6;
our $xbrk_ctrl_goto1_bit  = 7;































our $dbrk_paired_bit   = 64;
our $dbrk_writeenb_bit = 65;
our $dbrk_readenb_bit  = 66;
our $dbrk_addrused_bit = 67;
our $dbrk_dataused_bit = 68;
our $dbrk_break_bit    = 69;
our $dbrk_trigout_bit  = 70;
our $dbrk_traceoff_bit = 71;
our $dbrk_traceon_bit  = 72;
our $dbrk_traceme_bit  = 73;
our $dbrk_arm0_bit     = 74;
our $dbrk_arm1_bit     = 75;
our $dbrk_goto0_bit    = 76;
our $dbrk_goto1_bit    = 77;









our $TRC_ENB_BIT    = 0;              # enable trace system
our $TRC_ON_BIT     = 1;              # currently collecting?
our $TRC_SYN_BITS   = "3:2";          # sync interval code
our $TRC_TX_BIT     = 4;              # generate execution trace?
our $TRC_TD_BITS    = "7:5";          # generate data trace?
our $TRC_OFC_BIT    = 8;              # trace goes off-chip
our $TRC_DEBUG_BIT  = 9;              # trace in debug mode
our $TRC_FULL_BIT  = 10;              # stop trace when on-chip is full







our $IDCODE_OCINIOS2 = "8'h22";


sub 
private_max 
{
    my $list = shift;

    my $max_value = -1;

    while (my $compare = shift @$list) {
        if (($max_value eq undef) || ($compare > $max_value)) {
            $max_value = $compare;
        }
    }

    return $max_value;
}

1;
