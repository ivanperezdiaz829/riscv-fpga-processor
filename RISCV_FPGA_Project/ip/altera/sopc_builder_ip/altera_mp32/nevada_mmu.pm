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


























package nevada_mmu;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $mmu_addr_vpn_sz $mmu_addr_vpn_lsb $mmu_addr_vpn_msb
    $mmu_addr_vpn2_sz $mmu_addr_vpn2_lsb $mmu_addr_vpn2_msb
    $mmu_addr_pfn_sz $mmu_addr_pfn_lsb $mmu_addr_pfn_msb
    $mmu_addr_page_offset_sz $mmu_addr_page_offset_lsb $mmu_addr_page_offset_msb
    $mmu_addr_user_region_sz
    $mmu_addr_user_region_lsb
    $mmu_addr_user_region_msb
    $mmu_addr_user_region
    $mmu_addr_kernel_region_sz
    $mmu_addr_kernel_region_lsb
    $mmu_addr_kernel_region_msb
    $mmu_addr_kernel_region
    $mmu_addr_kernel_region_int
    $mmu_addr_io_region_sz
    $mmu_addr_io_region_lsb
    $mmu_addr_io_region_msb
    $mmu_addr_io_region
    $mmu_addr_io_region_int
    $mmu_addr_io_region_vpn
    $mmu_addr_kernel_mmu_region_sz
    $mmu_addr_kernel_mmu_region_lsb
    $mmu_addr_kernel_mmu_region_msb
    $mmu_addr_kernel_mmu_region
    $mmu_addr_dseg_region_sz
    $mmu_addr_dseg_region_lsb
    $mmu_addr_dseg_region_msb
    $mmu_addr_dseg_region
    $mmu_addr_bypass_tlb_sz
    $mmu_addr_bypass_tlb_lsb
    $mmu_addr_bypass_tlb_msb
    $mmu_addr_bypass_tlb
    $mmu_addr_bypass_tlb_cacheable_sz
    $mmu_addr_bypass_tlb_cacheable_lsb
    $mmu_addr_bypass_tlb_cacheable_msb
    $mmu_addr_bypass_tlb_cacheable
    $mmu_addr_bypass_tlb_uncacheable
    $mmu_addr_bypass_tlb_paddr_sz
    $mmu_addr_bypass_tlb_paddr_lsb
    $mmu_addr_bypass_tlb_paddr_msb
    $tlb_min_ptr_sz $tlb_max_ptr_sz $tlb_max_entries
    $uitlb_index_sz $udtlb_index_sz
);

use cpu_utils;
use cpu_file_utils;
use cpu_bit_field;
use cpu_control_reg;
use nios_utils;
use nios_sdp_ram;
use nios_isa;
use nevada_common;
use nevada_control_regs;
use strict;






our $mmu_addr_vpn_sz;
our $mmu_addr_vpn_lsb;
our $mmu_addr_vpn_msb;
our $mmu_addr_vpn2_sz;
our $mmu_addr_vpn2_lsb;
our $mmu_addr_vpn2_msb;
our $mmu_addr_pfn_sz;
our $mmu_addr_pfn_lsb;
our $mmu_addr_pfn_msb;
our $mmu_addr_page_offset_sz;
our $mmu_addr_page_offset_lsb;
our $mmu_addr_page_offset_msb;
our $mmu_addr_user_region_sz;
our $mmu_addr_user_region_lsb;
our $mmu_addr_user_region_msb;
our $mmu_addr_user_region;
our $mmu_addr_kernel_region_sz;
our $mmu_addr_kernel_region_lsb;
our $mmu_addr_kernel_region_msb;
our $mmu_addr_kernel_region;
our $mmu_addr_kernel_region_int;
our $mmu_addr_io_region_sz;
our $mmu_addr_io_region_lsb;
our $mmu_addr_io_region_msb;
our $mmu_addr_io_region;
our $mmu_addr_io_region_int;
our $mmu_addr_io_region_vpn;
our $mmu_addr_kernel_mmu_region_sz;
our $mmu_addr_kernel_mmu_region_lsb;
our $mmu_addr_kernel_mmu_region_msb;
our $mmu_addr_kernel_mmu_region;
our $mmu_addr_dseg_region_sz;
our $mmu_addr_dseg_region_lsb;
our $mmu_addr_dseg_region_msb;
our $mmu_addr_dseg_region;
our $mmu_addr_bypass_tlb_sz;
our $mmu_addr_bypass_tlb_lsb;
our $mmu_addr_bypass_tlb_msb;
our $mmu_addr_bypass_tlb;
our $mmu_addr_bypass_tlb_cacheable_sz;
our $mmu_addr_bypass_tlb_cacheable_lsb;
our $mmu_addr_bypass_tlb_cacheable_msb;
our $mmu_addr_bypass_tlb_cacheable;
our $mmu_addr_bypass_tlb_uncacheable;
our $mmu_addr_bypass_tlb_paddr_sz;
our $mmu_addr_bypass_tlb_paddr_lsb;
our $mmu_addr_bypass_tlb_paddr_msb;

our $tlb_min_ptr_sz;
our $tlb_max_ptr_sz;
our $tlb_max_entries;
our $uitlb_index_sz;
our $udtlb_index_sz;


our $tlb_num_entries;
our $tlb_num_banks;
our $tlb_entries_per_bank;
our $tlb_bank_entry_index_sz;
our $tlb_bank_num_addrs;
our $tlb_bank_addr_sz;

our $tlb_tag_entry_min_addr;
our $tlb_tag_entry_max_addr;
our $tlb_even_data_entry_min_addr;
our $tlb_even_data_entry_max_addr;
our $tlb_odd_data_entry_min_addr;
our $tlb_odd_data_entry_max_addr;

our $tlb_index_sz;

our $tlb_vpn2_sz;
our $tlb_asid_sz;
our $tlb_mask_sz;
our $tlb_g_sz;
our $tlb_tag_sz;

our $tlb_pfn_sz;
our $tlb_c_sz;
our $tlb_d_sz;
our $tlb_v_sz;
our $tlb_data_sz;

our $tlb_ram_data_width;
our $tlb_ram_data_entry_padding;







sub
create_mmu_args_from_infos
{
    my $mmu_info = shift;

    if (!manditory_bool($mmu_info, "mmu_present")) {
        &$error("Shouldn't be called if MMU isn't present");
    }

    my $mmu_args = {
      tlb_present => manditory_int($mmu_info, "tlb_present"),
      tlb_num_entries => manditory_int($mmu_info, "tlb_num_entries"),
      tlb_num_banks => manditory_int($mmu_info, "tlb_num_banks"),
      udtlb_num_entries => manditory_int($mmu_info, "udtlb_num_entries"),
      uitlb_num_entries => manditory_int($mmu_info, "uitlb_num_entries"),
    };

    return $mmu_args;
}





sub
create_mmu_args_default_configuration
{
    my $mmu_args = {
      tlb_present => 1,
      tlb_num_entries => 30,
      tlb_num_banks => 3,
      udtlb_num_entries => 8,
      uitlb_num_entries => 8,
    };

    return $mmu_args;
}




sub
validate_and_elaborate
{
    my $mmu_args = shift;

    assert_hash_ref($mmu_args, "mmu_args") || return undef;

    my $mmu_constants = create_mmu_constants($mmu_args);
    my $mmu_addr_bit_fields = create_mmu_addr_bit_fields();


    my $elaborated_mmu_info = {
        mmu_constants       => $mmu_constants,
        mmu_addr_bit_fields => $mmu_addr_bit_fields,
    };



    foreach my $var (keys(%$mmu_constants)) {
        eval_cmd('$' . $var . ' = "' . $mmu_constants->{$var} . '"');
    }


    foreach my $mmu_addr_bit_field (@$mmu_addr_bit_fields) {




        foreach my $cmd 
          (@{get_bit_field_into_scalars($mmu_addr_bit_field, "mmu_addr_")}) {
            eval_cmd($cmd);
        }
    }

    return $elaborated_mmu_info;
}


sub
fits_in_kernel_region
{
    my $paddr = shift;

    if (!defined($mmu_addr_kernel_region_sz)) {
        return &$error("MMU constants haven't been initialized yet.");
    }

    my $mmu_addr_kernel_region_mask = 
      (0x1 << $mmu_addr_kernel_region_sz) - 1;

    return 
      ((($paddr >> $mmu_addr_kernel_region_lsb) & 
        $mmu_addr_kernel_region_mask) == 0);
}


sub
paddr_to_kernel_vaddr
{
    my $paddr = shift;

    if (!defined($mmu_addr_kernel_region_int)) {
        return &$error("MMU constants haven't been initialized yet.");
    }

    return ($paddr | 
      ($mmu_addr_kernel_region_int << $mmu_addr_kernel_region_lsb));
}


sub
fits_in_io_region
{
    my $paddr = shift;

    if (!defined($mmu_addr_kernel_region_sz)) {
        return &$error("MMU constants haven't been initialized yet.");
    }

    my $mmu_addr_kernel_region_mask = 
      (0x1 << $mmu_addr_kernel_region_sz) - 1;

    return 
      ((($paddr >> $mmu_addr_kernel_region_lsb) & 
        $mmu_addr_kernel_region_mask) == 0);
}


sub
paddr_to_io_vaddr
{
    my $paddr = shift;

    if (!defined($mmu_addr_io_region_int)) {
        return &$error("MMU constants haven't been initialized yet.");
    }

    return ($paddr | 
      ($mmu_addr_io_region_int << $mmu_addr_io_region_lsb));
}





sub
master_paddr_mapper
{
    my $master = shift;
    my $paddr_name = shift;

    if (!defined($mmu_present)) {
        return &$error("master_paddr_mapper() called but don't know if MMU" .
          " is present");
    }

    my $master_name = not_empty_scalar($master, "name") || return undef;
    my $paddr = manditory_int($master, $paddr_name);
    if (!defined($paddr)) {
        return undef;
    }

    if (!$mmu_present) {
        return $paddr;
    }

    if (!fits_in_kernel_region($paddr)) {
        my $paddr_hex = sprintf("0x%x", $paddr);
        return &$error(
          "Master '$master_name' $paddr_name address $paddr_hex" .
          " is not reachable from the kernel region");
    }

    return paddr_to_kernel_vaddr($paddr);
}


sub
convert_to_c
{
    my $elaborated_mmu_info = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    push(@$h_lines, "");
    push(@$h_lines, "/* MMU Constants */");
    format_hash_as_c_macros($elaborated_mmu_info->{mmu_constants}, $h_lines,
      "MIPS32_");

    convert_mmu_addr_bit_fields_to_c(
      $elaborated_mmu_info->{mmu_addr_bit_fields}, $c_lines, $h_lines);

    add_handy_macros($h_lines);

    return 1;   # Some defined value
}

sub
initialize_config_constants
{
    my $mmu_info = shift;

    if (!$mmu_present) {
        return;
    }

    if ($tlb_present) {
        $tlb_num_entries = manditory_int($mmu_info, "tlb_num_entries"); 
        $tlb_num_banks = manditory_int($mmu_info, "tlb_num_banks");

        if (($tlb_num_entries % $tlb_num_banks) != 0) {
            return &$error("Number of TLB entries ($tlb_num_entries) not divisible by number of TLB banks ($tlb_num_banks)");
        }

        $tlb_entries_per_bank = $tlb_num_entries / $tlb_num_banks;
        $tlb_bank_entry_index_sz = count2sz($tlb_entries_per_bank);

        $tlb_bank_num_addrs = $tlb_entries_per_bank * 3;
        $tlb_bank_addr_sz = count2sz($tlb_bank_num_addrs);




        $tlb_tag_entry_min_addr = 0;
        $tlb_tag_entry_max_addr = 
          $tlb_tag_entry_min_addr + $tlb_entries_per_bank - 1;
        $tlb_even_data_entry_min_addr = $tlb_tag_entry_max_addr + 1;
        $tlb_even_data_entry_max_addr =
          $tlb_even_data_entry_min_addr + $tlb_entries_per_bank - 1;
        $tlb_odd_data_entry_min_addr = $tlb_even_data_entry_max_addr + 1;
        $tlb_odd_data_entry_max_addr =
          $tlb_odd_data_entry_min_addr + $tlb_entries_per_bank - 1;

        $tlb_index_sz = get_control_reg_field_sz($cop0_index_reg_index);

        $tlb_vpn2_sz = get_control_reg_field_sz($cop0_entry_hi_reg_vpn2);
        $tlb_asid_sz = get_control_reg_field_sz($cop0_entry_hi_reg_asid);
        $tlb_mask_sz = get_control_reg_field_sz($cop0_page_mask_reg_mask) / 2;
        $tlb_g_sz = 1;
        $tlb_tag_sz = 
          $tlb_vpn2_sz +
          $tlb_asid_sz +
          $tlb_mask_sz +
          $tlb_g_sz;

        $tlb_pfn_sz = get_control_reg_field_sz($cop0_entry_lo_0_reg_pfn);
        $tlb_c_sz = 1;      # Only need 1 bit to encode required values
        $tlb_d_sz = 1;
        $tlb_v_sz = 1;
        $tlb_data_sz =
          $tlb_pfn_sz +
          $tlb_c_sz +
          $tlb_d_sz +
          $tlb_v_sz;

        if ($tlb_data_sz > $tlb_tag_sz) {
            &$error("TLB data entry is larger than the TLB tag entry.");
        }




        $tlb_ram_data_width = $tlb_tag_sz;
        $tlb_ram_data_entry_padding = ($tlb_tag_sz - $tlb_data_sz) . "'b0";
    }
}



sub 
make_utlb
{
    my $Opt = shift;
    my $d = shift;

    if (!defined($tlb_num_entries)) {
        return &$error("MMU config constants haven't been initialized yet.");
    }


    my $u = $d ? "udtlb" : "uitlb";
    my $U = $d ? "UDTLB" : "UITLB";

    my $utlb_wave_signals = [];

    my $utlb_storage_wave_signals = make_utlb_storage($Opt, $d, $u, $U);
    push(@$utlb_wave_signals, $utlb_storage_wave_signals);

    my $utlb_lru_wave_signals = make_utlb_lru($Opt, $d, $u, $U);
    push(@$utlb_wave_signals, $utlb_lru_wave_signals);

    my $utlb_fill_wave_signals = make_utlb_fill($Opt, $d, $u, $U);
    push(@$utlb_wave_signals, $utlb_fill_wave_signals);

    my $utlb_lookup_wave_signals = make_utlb_lookup($Opt, $d, $u, $U);
    push(@$utlb_wave_signals, $utlb_lookup_wave_signals);

    return $utlb_wave_signals;
}

sub
make_utlb_storage
{
    my $Opt = shift;
    my $d = shift;
    my $u = shift;
    my $U = shift;


    my $num_entries = not_empty_scalar($Opt, $u . "_num_entries");

    my $ui;     # UTLB index





    my @utlb_contents_wave_signals = (
      { divider => "$U Contents" },
      { radix => "x", signal => "utlb_flush_all" },
    );


    for ($ui = 0; $ui < $num_entries; $ui++) {
        my $ue = get_utlb_entry_signal_name_prefix($u, $ui);

        e_assign->adds(








          [["${ue}_flush", 1], 
            "(A_tlbw_active & 
              (${ue}_m | (A_tlb_rw_inst_index == ${ue}_tlb_index))) |
             utlb_flush_all"],



          [["${ue}_wr_en", 1],
            "${ue}_flush | (${u}_fill_select${ui} & ${u}_fill_wr_en)"],






          [["${ue}_vpn_nxt", $mmu_addr_vpn_sz],
            "${ue}_flush ? 
              ($mmu_addr_io_region_vpn + $ui) : 
              tlb_match_vpn_persistent"],
        );

        e_register->adds(

          {out => ["${ue}_tlb_index", $tlb_index_sz],                  
           in => "tlb_match_tlb_index_d1",
           enable => "${ue}_wr_en"},

          {out => ["${ue}_vpn", $mmu_addr_vpn_sz], 
           in => "${ue}_vpn_nxt",
           enable => "${ue}_wr_en",
           async_value => "$mmu_addr_io_region_vpn + $ui"},

          {out => ["${ue}_raw_mask", $tlb_mask_sz], 
           in => "${ue}_flush ? 0 : tlb_match_raw_mask_d1",
           enable => "${ue}_wr_en"},


          {out => ["${ue}_m", 1],                  
           in => "utlb_fill_tlb_miss",
           enable => "${ue}_wr_en"},

          {out => ["${ue}_pfn", $tlb_pfn_sz],     
           in => "tlb_rd_pfn",
           enable => "${ue}_wr_en"},

          {out => ["${ue}_c", 1],                  
           in => "tlb_rd_c",
           enable => "${ue}_wr_en"},

          $d ? {out => ["${ue}_d", 1],                  
                in => "tlb_rd_d",
                enable => "${ue}_wr_en"} : (),

          {out => ["${ue}_v", 1],                  
           in => "tlb_rd_v",
           enable => "${ue}_wr_en"},
        );

        push(@utlb_contents_wave_signals,
          { radix => "x", signal => "${ue}_flush" },
          { radix => "x", signal => "${ue}_wr_en" },
          { radix => "x", signal => "${ue}_tlb_index" },
          { radix => "x", signal => "${ue}_vpn" },
          { radix => "x", signal => "${ue}_raw_mask" },
          { radix => "x", signal => "${ue}_m" },
          { radix => "x", signal => "${ue}_pfn" },
          { radix => "x", signal => "${ue}_c" },
          $d ? { radix => "x", signal => "${ue}_d" } : "",
          { radix => "x", signal => "${ue}_v" },
        );
    }

    return \@utlb_contents_wave_signals;
}















sub
make_utlb_lru
{
    my $Opt = shift;
    my $d = shift;
    my $u = shift;
    my $U = shift;


    my $lru_stage = $d ? "A" : "E";

    my $num_entries = not_empty_scalar($Opt, $u . "_num_entries");

    my $ui;     # UTLB index


    my $lru_fifo_bits = count2sz($num_entries);
    my $lru_fifo_tail = 0;
    my $lru_fifo_head = $num_entries - 1;

    my $utlb_lru_access = "${lru_stage}_valid_${u}_lru_access";
    my $utlb_lru_index = "${lru_stage}_${u}_index";

    my @utlb_lru_wave_signals = (
      { divider => "$U LRU" },
      { radix => "x", signal => $utlb_lru_access },
      { radix => "x", signal => $utlb_lru_index },
    );


    for ($ui = 0; $ui < $num_entries; $ui++) {
        my $ui_less_one = $ui - 1;




        my $fifo_input = ($ui == $lru_fifo_tail) ? 
          $utlb_lru_index : "${u}_lru_fifo${ui_less_one}";



        my @accept_higher_entry;
        for (my $mi = $ui; $mi < $num_entries; $mi++) {
            if ($ui != $lru_fifo_tail) {
                push(@accept_higher_entry, "${u}_lru_fifo${mi}_match");
            }
        }

        my $accept_higher_entry_expr = scalar(@accept_higher_entry > 0) ? 
          " & (" . join('|', @accept_higher_entry) . ")" :
          "";

        if ($ui != $lru_fifo_tail) {
            e_assign->adds(



              [["${u}_lru_fifo${ui}_match", 1], 
                "${u}_lru_fifo${ui} == $utlb_lru_index"],
            );
        }

        e_assign->adds(


          [["${u}_fill_select${ui}", 1], 
            "${u}_lru_fifo${lru_fifo_head} == $ui"],





          [["${u}_lru_fifo${ui}_wr_en", 1], 
            $utlb_lru_access . $accept_higher_entry_expr],
        );

        e_register->adds(

          {out          => ["${u}_lru_fifo${ui}", $lru_fifo_bits],
           in           => $fifo_input,
           enable       => "${u}_lru_fifo${ui}_wr_en",
           async_value  => $ui },
        );
    }

    for ($ui = 0; $ui < $num_entries; $ui++) {
        push(@utlb_lru_wave_signals,
          { radix => "x", signal => "${u}_lru_fifo${ui}" },
        );
    }

    for ($ui = 0; $ui < $num_entries; $ui++) {
        push(@utlb_lru_wave_signals,
          ($ui != $lru_fifo_tail) ? 
            { radix => "x", signal => "${u}_lru_fifo${ui}_match" } : "",
        );
    }

    for ($ui = 0; $ui < $num_entries; $ui++) {
        push(@utlb_lru_wave_signals,
          { radix => "x", signal => "${u}_lru_fifo${ui}_wr_en" },
        );
    }

    return \@utlb_lru_wave_signals;
}

sub
make_utlb_fill
{
    my $Opt = shift;
    my $d = shift;
    my $u = shift;
    my $U = shift;


    my $want_fill = not_empty_scalar($Opt, $u . "_want_fill");
    my $want_fill_expr = not_empty_scalar($Opt, $u . "_want_fill_expr");
    my $num_entries = not_empty_scalar($Opt, $u . "_num_entries");

    my $ui;     # UTLB index

    if ($d) {


        e_assign->adds(
          [[$want_fill, 1], $want_fill_expr],
        );
    } else {


        e_assign->adds(
          [["${want_fill}_unfiltered", 1], $want_fill_expr],
        );







        if (manditory_bool($Opt, "asic_enabled")) {
            e_assign->adds(
              [[$want_fill, 1], "${want_fill}_unfiltered"],
            );
        } else {
            create_x_filter({
              lhs       => $want_fill,
              rhs       => "${want_fill}_unfiltered",
              sz        => 1,
            });
        }
    }

    my @utlb_fill_wave_signals = (
      { divider => "$U Fill" },
      { radix => "x", signal => $want_fill },
      { radix => "x", signal => "utlb_fill_tlb_miss" },
      { radix => "x", signal => "${u}_fill_wr_en" },
    );

    for ($ui = 0; $ui < $num_entries; $ui++) {
        push(@utlb_fill_wave_signals,
          { radix => "x", signal => "${u}_fill_select${ui}" },
        );
    }
    
    return \@utlb_fill_wave_signals;
}

sub
make_utlb_lookup
{
    my $Opt = shift;
    my $d = shift;
    my $u = shift;
    my $U = shift;


    my $match_cmp_vpn = $d ? "E_mem_baddr_vpn" : "F_pcb_vpn_nxt";


    my $match_mux_stage = $d ? "M" : "F";

    my $match_mux_vaddr = not_empty_scalar($Opt, $u . "_match_mux_vaddr");
    my $match_mux_paddr = not_empty_scalar($Opt, $u . "_match_mux_paddr");

    my $num_entries = not_empty_scalar($Opt, $u . "_num_entries");

    my $ui;     # UTLB index

    my @utlb_match_mux_signals;
    my @utlb_match_wave_signals;
    my @utlb_index_mux_table;
    my @utlb_pfn_mux_table;
    my @utlb_m_mux_table;
    my @utlb_c_mux_table;
    my @utlb_d_mux_table;
    my @utlb_v_mux_table;

    for ($ui = 0; $ui < $num_entries; $ui++) {
        my $ue = get_utlb_entry_signal_name_prefix($u, $ui);
        
        my $match_cmp_signal = 
          $d ? "E_${ue}_match" : "F_${ue}_match_nxt";
        my $match_cmp_pfn_signal = 
          $d ? "E_${ue}_match_pfn" : "F_${ue}_match_pfn_nxt";
        my $match_mux_signal = "${match_mux_stage}_${ue}_match";
        my $match_mux_pfn_signal = "${match_mux_stage}_${ue}_match_pfn";

        e_assign->adds(


          [["${ue}_vpn_mask", $mmu_addr_vpn_sz],
            "{4'b0,
              ${ue}_raw_mask[7],
              ${ue}_raw_mask[7],
              ${ue}_raw_mask[6],
              ${ue}_raw_mask[6],
              ${ue}_raw_mask[5],
              ${ue}_raw_mask[5],
              ${ue}_raw_mask[4],
              ${ue}_raw_mask[4],
              ${ue}_raw_mask[3],
              ${ue}_raw_mask[3],
              ${ue}_raw_mask[2],
              ${ue}_raw_mask[2],
              ${ue}_raw_mask[1],
              ${ue}_raw_mask[1],
              ${ue}_raw_mask[0],
              ${ue}_raw_mask[0]}"],


          [[$match_cmp_signal, 1], 
            "(${ue}_vpn & ~${ue}_vpn_mask) ==
               ($match_cmp_vpn & ~${ue}_vpn_mask)"],



          [["$match_cmp_pfn_signal", $tlb_pfn_sz], 
            "(${ue}_pfn & ~${ue}_vpn_mask) |
               ($match_cmp_vpn\[$tlb_pfn_sz-1:0] & 
                ${ue}_vpn_mask[$tlb_pfn_sz-1:0])"],
        );

        push(@utlb_match_mux_signals, $match_mux_signal);
        push(@utlb_match_wave_signals,
          { radix => "x", signal => "${ue}_vpn_mask" },
          { radix => "x", signal => $match_cmp_signal },
          { radix => "x", signal => $match_cmp_pfn_signal },
        );


        e_register->adds(
          {out => [$match_mux_signal, 1],     
           in => $match_cmp_signal, 
           enable => "${match_mux_stage}_en"},
          {out => [$match_mux_pfn_signal, $tlb_pfn_sz], 
           in => $match_cmp_pfn_signal, 
           enable => "${match_mux_stage}_en"},
        );

        my $sel = "${match_mux_stage}_${ue}_match";

        push(@utlb_index_mux_table, $sel => "${ui}");
        push(@utlb_pfn_mux_table, $sel => $match_mux_pfn_signal);
        push(@utlb_m_mux_table,   $sel => "${ue}_m");
        push(@utlb_c_mux_table,   $sel => "${ue}_c");
        push(@utlb_d_mux_table,   $sel => "${ue}_d");
        push(@utlb_v_mux_table,   $sel => "${ue}_v");
    }

    my $utlb_index_sz = $d ? $udtlb_index_sz : $uitlb_index_sz;


    e_mux->adds(
      { lhs => ["${match_mux_stage}_${u}_index", $utlb_index_sz],   
        type => "and_or", table => \@utlb_index_mux_table },
      { lhs => ["${match_mux_stage}_${u}_pfn", $tlb_pfn_sz],   
        type => "and_or", table => \@utlb_pfn_mux_table },
      { lhs => ["${match_mux_stage}_${u}_m", 1],               
        type => "and_or", table => \@utlb_m_mux_table },
      { lhs => ["${match_mux_stage}_${u}_c", 1, 0, $force_never_export],
        type => "and_or", table => \@utlb_c_mux_table },
      $d ? { lhs => ["${match_mux_stage}_${u}_d", 1],
        type => "and_or", table => \@utlb_d_mux_table } : (),
      { lhs => ["${match_mux_stage}_${u}_v", 1],
        type => "and_or", table => \@utlb_v_mux_table },
      );

    if (!$d) {
        e_assign->adds(


          [["${match_mux_paddr}_pfn_valid", 1],  
            "(${match_mux_stage}_${u}_hit & ~${match_mux_stage}_${u}_m) |
              ${match_mux_vaddr}_bypass_tlb"],
        );
    }

    my $paddr_sz = $d ? 
      manditory_int($Opt, "d_Address_Width") :
      manditory_int($Opt, "i_Address_Width");

    my $bypass_pfn_mux_table = [];

    if ($debug_port_present) {

        my $vaddr_sz = 32;


        my $debug_offset_paddr_sz = $vaddr_sz - $mmu_addr_dseg_region_sz;


        my $debug_vpn_sz = $debug_offset_paddr_sz - $mmu_addr_page_offset_sz;

        my $debug_paddr = manditory_int($Opt, "debug_paddr");
        my $debug_base_paddr_mask = sz2mask($mmu_addr_dseg_region_sz);
        my $debug_base_paddr = 
          ($debug_paddr >> $debug_offset_paddr_sz) & $debug_base_paddr_mask;

        my $region_sel = "${match_mux_vaddr}_dseg_region";
        if ($d) {

            $region_sel .= "_with_lsnm";
        }



        push(@$bypass_pfn_mux_table,
            $region_sel => "{" .
              " ${mmu_addr_dseg_region_sz}'d${debug_base_paddr}," . 
              " ${match_mux_vaddr}_vpn\[$debug_vpn_sz-1:0]" .
              " }"
        );
    }



    push(@$bypass_pfn_mux_table,
        "1'b1" => "{ 3'b000, ${match_mux_vaddr}_vpn[16:0]}",
    );



    e_mux->add ({
      lhs => ["${match_mux_paddr}_bypass_pfn_max_sized", $mmu_addr_pfn_sz],
      type => "priority",
      table => $bypass_pfn_mux_table,
    });

    e_assign->adds(

      [["${match_mux_stage}_${u}_hit", 1], join('|', @utlb_match_mux_signals)],



      [["${match_mux_paddr}_got_pfn", 1],  
        "${match_mux_stage}_${u}_hit | ${match_mux_vaddr}_bypass_tlb"],


      [["${match_mux_paddr}_bypass_pfn", $tlb_pfn_sz],
        "${match_mux_paddr}_bypass_pfn_max_sized[$tlb_pfn_sz-1:0]"],




      [["$match_mux_paddr", $paddr_sz], 
        "{ (${match_mux_vaddr}_bypass_tlb ? 
                ${match_mux_paddr}_bypass_pfn :
                ${match_mux_stage}_${u}_pfn), 
           ${match_mux_vaddr}_page_offset }"],
    );

    if (!$d) {
        e_assign->adds(

          [["F_pc_phy", $paddr_sz-2], "$match_mux_paddr\[$paddr_sz-1:2]"],
        );
    }

    e_process->adds({
        tag => 'simulation',
        contents => [
            e_if->new({
                condition => 
                  "reset_n & " .
                  "((" . join('+', @utlb_match_mux_signals) . ") > 1)",
                then => [
                    e_sim_write->new({
                        show_time => 1,
                        spec_string => "ERROR: Multiple matches in the $U"}),
                    e_stop->new(),
                ],
            }),
        ],
    });
    

    my @utlb_lookup_wave_signals = (
      { divider => "$U Lookup" },
      { radix => "x", signal => $match_cmp_vpn },
      @utlb_match_wave_signals,
      { radix => "x", signal => "${match_mux_vaddr}_bypass_tlb" },
      { radix => "x", signal => "${match_mux_stage}_${u}_index" },
      { radix => "x", signal => "${match_mux_stage}_${u}_pfn" },
      { radix => "x", signal => "${match_mux_stage}_${u}_m" },
      { radix => "x", signal => "${match_mux_stage}_${u}_c" },
      $d ? { radix => "x", signal => "${match_mux_stage}_${u}_d" } : "",
      { radix => "x", signal => "${match_mux_stage}_${u}_v" },
      { radix => "x", signal => "${match_mux_stage}_${u}_hit" },
      { radix => "x", signal => "${match_mux_paddr}_got_pfn" },
      $d ? "" : { radix => "x", signal => "${match_mux_paddr}_pfn_valid" },
      { radix => "x", signal => "${match_mux_paddr}_bypass_pfn" },
      { radix => "x", signal => $match_mux_paddr },
    );

    return \@utlb_lookup_wave_signals;
}

























































































sub 
make_tlb
{
    my $Opt = shift;

    &$progress("    TLB");

    if (!defined($tlb_num_entries)) {
        return &$error("MMU config constants haven't been initialized yet.");
    }

    my $tlb_wave_signals = [];

    my $tlb_fill_wave_signals = make_tlb_fill($Opt);
    push(@$tlb_wave_signals, $tlb_fill_wave_signals);

    my $tlb_ram_banks_wave_signals_array = make_all_tlb_ram_banks($Opt);
    push(@$tlb_wave_signals, @$tlb_ram_banks_wave_signals_array);

    return $tlb_wave_signals;
}









sub 
make_tlb_fill
{
    my $Opt = shift;

    my $udtlb_want_fill = not_empty_scalar($Opt, "udtlb_want_fill");
    my $uitlb_want_fill = not_empty_scalar($Opt, "uitlb_want_fill");

    e_assign->adds(


      [["utlb_flush_all", 1],
        "W_cop0_entry_hi_reg_asid_wr_en & 
          (W_cop0_entry_hi_reg_asid != W_cop0_entry_hi_reg_asid_nxt)"],




      [["utlb_flush_possible", 1], "utlb_flush_all | A_tlbw_active"], 
    );

    e_assign->adds(









      [["uitlb_ignore_want_fill_nxt", 1],
        "uitlb_fill_starting | " .
        "(uitlb_ignore_want_fill & ~(D_uitlb_fill_done & D_en))"],






      [["udtlb_ignore_want_fill_nxt", 1],
        "udtlb_fill_starting | " .
        "(udtlb_ignore_want_fill & ~udtlb_fill_done_d2)"],


      [["uitlb_want_fill_qualified", 1], 
        "$uitlb_want_fill & ~uitlb_ignore_want_fill"],
      [["udtlb_want_fill_qualified", 1], 
        "$udtlb_want_fill & ~udtlb_ignore_want_fill"],
      [["utlb_want_fill_qualified", 1], 
        "uitlb_want_fill_qualified | udtlb_want_fill_qualified"],







      [["utlb_fill_starting", 1], 
        "utlb_want_fill_qualified & 
          ~(utlb_fill_active | utlb_flush_possible | 
           (A_ctrl_tlb_inst & A_valid))"],



      [["utlb_fill_starting_d", 1], "udtlb_want_fill_qualified"],


      [["uitlb_fill_starting", 1], 
        "utlb_fill_starting & ~utlb_fill_starting_d"],
      [["udtlb_fill_starting", 1], 
        "utlb_fill_starting & utlb_fill_starting_d"],







      [["utlb_fill_active_nxt", 1], 
        "utlb_fill_active ? ~utlb_fill_done : utlb_fill_starting"],



      [["utlb_fill_active_d_nxt", 1], 
        "utlb_fill_starting ? utlb_fill_starting_d : utlb_fill_active_d"],















      [["utlb_fill_match_active_nxt", 1], 
        "utlb_fill_match_active ? 
            ~(utlb_fill_tlb_hit | utlb_fill_tlb_miss | A_tlb_inst_start_nxt) :
            utlb_fill_starting"],



      [["utlb_fill_match_active_d_nxt", 1],
        "utlb_fill_starting ? utlb_fill_starting_d : utlb_fill_match_active_d"],









      [["utlb_fill_done", 1], 
        "utlb_fill_tlb_hit_d1 | utlb_fill_tlb_miss | utlb_flush_possible |
         A_tlb_inst_start_nxt"],







      [["F_uitlb_fill_done_nxt", 1], 
        "(utlb_fill_done & ~utlb_fill_active_d) | 
         (F_uitlb_fill_done & F_stall)"],










      [["utlb_fill_last_bank_tag_entry", 1], 
        "utlb_fill_bank_tag_entry_cnt == $tlb_entries_per_bank"],



      [["utlb_fill_tlb_hit", 1], "tlb_match & utlb_fill_match_active"],



      [["utlb_fill_tlb_miss", 1], 
        "~tlb_match & utlb_fill_match_active & utlb_fill_last_bank_tag_entry"],








      [["uitlb_fill_wr_en", 1], 
        "~utlb_fill_match_active_d & " .
        "(utlb_fill_tlb_hit_d1 | utlb_fill_tlb_miss)"],

      [["udtlb_fill_wr_en", 1], 
        "utlb_fill_match_active_d & " .
        "(utlb_fill_tlb_hit_d1 | utlb_fill_tlb_miss)"],
    );

    e_register->adds(
      {out => ["uitlb_ignore_want_fill", 1], 
       in => "uitlb_ignore_want_fill_nxt", enable => "1'b1"},
      {out => ["udtlb_ignore_want_fill", 1], 
       in => "udtlb_ignore_want_fill_nxt", enable => "1'b1"},
      {out => ["utlb_fill_tlb_hit_d1", 1], 
       in => "utlb_fill_tlb_hit", enable => "1'b1"},
      {out => ["utlb_fill_active", 1], 
       in => "utlb_fill_active_nxt", enable => "1'b1"},
      {out => ["utlb_fill_active_d", 1], 
       in => "utlb_fill_active_d_nxt", enable => "1'b1"},
      {out => ["utlb_fill_match_active", 1], 
       in => "utlb_fill_match_active_nxt", enable => "1'b1"},
      {out => ["utlb_fill_match_active_d", 1], 
       in => "utlb_fill_match_active_d_nxt", enable => "1'b1"},






      {out => ["utlb_fill_bank_tag_entry_cnt", $tlb_bank_entry_index_sz+1],
       in => "utlb_fill_starting ? 0 : utlb_fill_bank_tag_entry_cnt+1",
       enable => "1'b1"},

      {out => ["udtlb_fill_done_d1", 1], 
       in => "utlb_fill_done & utlb_fill_active_d", enable => "1'b1"},
      {out => ["udtlb_fill_done_d2", 1], 
       in => "udtlb_fill_done_d1",                  enable => "1'b1"},

      {out => ["F_uitlb_fill_done", 1], 
       in => "F_uitlb_fill_done_nxt", enable => "1'b1"},
      {out => ["D_uitlb_fill_done", 1], 
       in => "F_uitlb_fill_done", enable => "D_en"},
    );

    my @utlb_fill_wave_signals = (
      { divider => "UTLB Fill" },
      { radix => "x", signal => "utlb_flush_all" },
      { radix => "x", signal => "utlb_flush_possible" },
      { radix => "x", signal => "uitlb_ignore_want_fill" },
      { radix => "x", signal => "udtlb_ignore_want_fill" },
      { radix => "x", signal => "uitlb_want_fill_qualified" },
      { radix => "x", signal => "udtlb_want_fill_qualified" },
      { radix => "x", signal => "utlb_want_fill_qualified" },
      { radix => "x", signal => "utlb_fill_starting" },
      { radix => "x", signal => "utlb_fill_starting_d" },
      { radix => "x", signal => "uitlb_fill_starting" },
      { radix => "x", signal => "udtlb_fill_starting" },
      { radix => "x", signal => "utlb_fill_active" },
      { radix => "x", signal => "utlb_fill_active_d" },
      { radix => "x", signal => "utlb_fill_match_active" },
      { radix => "x", signal => "utlb_fill_match_active_d" },
      { radix => "x", signal => "utlb_fill_last_bank_tag_entry" },
      { radix => "x", signal => "utlb_fill_tlb_hit_d1" },
      { radix => "x", signal => "utlb_fill_tlb_miss" },
      { radix => "x", signal => "utlb_fill_done" },
      { radix => "x", signal => "F_uitlb_fill_done" },
      { radix => "x", signal => "D_uitlb_fill_done" },
      { radix => "x", signal => "udtlb_fill_done_d1" },
      { radix => "x", signal => "udtlb_fill_done_d2" },
      { radix => "x", signal => "uitlb_fill_wr_en" },
      { radix => "x", signal => "udtlb_fill_wr_en" },
    );

    return \@utlb_fill_wave_signals;
}

sub 
make_all_tlb_ram_banks
{
    my $Opt = shift;


    my $udtlb_fill_vpn = "A_mem_baddr_vpn";
    my $uitlb_fill_vpn = "D_pcb_vpn";

    my @tlb_rd_q_mux_table;
    my @tlb_match_signals;
    my @tlb_match_tlb_index_mux_table;
    my @tlb_match_raw_mask_mux_table;

    for (my $bank = 0; $bank < $tlb_num_banks; $bank++) {
        my $tb = get_tlb_bank_signal_name_prefix($bank);

        push(@tlb_rd_q_mux_table, 
          "${tb}_rd_q_select" => "${tb}_rd_q",
        );
        push(@tlb_match_signals, "${tb}_match");
        push(@tlb_match_tlb_index_mux_table, 
           "${tb}_match" => "${tb}_match_tlb_index",
        );
        push(@tlb_match_raw_mask_mux_table, 
           "${tb}_match" => "${tb}_rd_raw_mask_d1",
        );
    }



    e_mux->adds(
      { lhs => ["tlb_rd_q", $tlb_ram_data_width],   
        type => "and_or", 
        table => \@tlb_rd_q_mux_table, 
      },
    );






    e_mux->adds(
      { lhs => ["tlb_match_raw_mask", $tlb_mask_sz],   
        type => "and_or", 
        table => \@tlb_match_raw_mask_mux_table, 
      },
      { lhs => ["tlb_match_tlb_index", $tlb_index_sz],   
        type => "and_or", 
        table => \@tlb_match_tlb_index_mux_table, 
      },
    );

    e_signal->adds(

      ["tlb_rd_vpn2", $tlb_vpn2_sz],
      ["tlb_rd_asid", $tlb_asid_sz],
      ["tlb_rd_raw_mask", $tlb_mask_sz],
      ["tlb_rd_g", 1],


      ["tlb_rd_pfn", $tlb_pfn_sz],
      ["tlb_rd_c", 1],
      ["tlb_rd_d", 1],
      ["tlb_rd_v", 1],
    );




    e_assign->adds(





      [["A_tlb_inst_stall", 1], "A_tlb_inst_active"],



      [["A_tlb_inst_start_nxt", 1], "M_ctrl_tlb_inst & M_valid & A_en"],

      [["A_tlb_inst_stop_nxt", 1], 
        "A_tlbw_odd | 
         A_tlbr_odd_addr_d1 | 
         A_tlbp_done"],

      [["A_tlb_inst_active_nxt", 1], 
        "A_tlb_inst_active ? ~A_tlb_inst_stop_nxt : A_tlb_inst_start_nxt"],




      [["M_tlb_rw_inst_index", $tlb_index_sz], 
        "M_op_tlbwr ? W_cop0_random_reg_random : W_cop0_index_reg_index"],





      [["A_tlbr_active", 1], "A_op_tlbr & A_tlb_inst_active"],




      [["A_tlbr_tag_addr", 1], "A_op_tlbr & A_tlb_inst_start"],





      [["A_tlbr_even_addr", 1], "A_tlbr_tag_addr_d1"],





      [["A_tlbr_odd_addr", 1], "A_tlbr_even_addr_d1"],
      






      [["A_tlbp_start", 1], "A_op_tlbp & A_tlb_inst_start"],



      [["A_tlbp_done", 1], 
        "A_tlbp_match_active & (tlb_match | A_tlbp_last_bank_tag_entry)"],



      [["A_tlbp_match_active_nxt", 1], 
        "A_tlbp_start_d1 | (A_tlbp_match_active & ~A_tlbp_done)"],






      [["A_tlbp_last_bank_tag_entry", 1], 
        "A_tlbp_bank_tag_entry_cnt == $tlb_entries_per_bank"],






      [["A_tlbw_start", 1], "A_ctrl_tlb_wr_inst & A_tlb_inst_start"],



      [["A_tlbw_tag", 1], "A_tlbw_start"],



      [["A_tlbw_even", 1], "A_tlbw_tag_d1"],



      [["A_tlbw_odd", 1], "A_tlbw_even_d1"],


      [["A_tlbw_en", 1], "A_tlbw_tag | A_tlbw_even | A_tlbw_odd"],
      



      [["A_tlbw_active", 1], "A_ctrl_tlb_wr_inst & A_tlb_inst_active"],


      [["A_tlb_wr_vpn2", $tlb_vpn2_sz], "W_cop0_entry_hi_reg_vpn2"],
      [["A_tlb_wr_asid", $tlb_asid_sz], "W_cop0_entry_hi_reg_asid"],
      [["A_tlb_wr_mask", $tlb_mask_sz], 
        "{ W_cop0_page_mask_reg_mask[14],
           W_cop0_page_mask_reg_mask[12],
           W_cop0_page_mask_reg_mask[10],
           W_cop0_page_mask_reg_mask[8],
           W_cop0_page_mask_reg_mask[6],
           W_cop0_page_mask_reg_mask[4],
           W_cop0_page_mask_reg_mask[2],
           W_cop0_page_mask_reg_mask[0] }"],
      [["A_tlb_wr_g", 1], "W_cop0_entry_lo_0_reg_g & W_cop0_entry_lo_1_reg_g"],


      [["A_tlb_wr_even_pfn", $tlb_pfn_sz], "W_cop0_entry_lo_0_reg_pfn"],
      [["A_tlb_wr_even_c", 1], 
        "W_cop0_entry_lo_0_reg_c != $coherency_uncached"],
      [["A_tlb_wr_even_d", 1], "W_cop0_entry_lo_0_reg_d"],
      [["A_tlb_wr_even_v", 1], "W_cop0_entry_lo_0_reg_v"],


      [["A_tlb_wr_odd_pfn", $tlb_pfn_sz], "W_cop0_entry_lo_1_reg_pfn"],
      [["A_tlb_wr_odd_c", 1], 
        "W_cop0_entry_lo_1_reg_c != $coherency_uncached"],
      [["A_tlb_wr_odd_d", 1], "W_cop0_entry_lo_1_reg_d"],
      [["A_tlb_wr_odd_v", 1], "W_cop0_entry_lo_1_reg_v"],


      [["A_tlb_wr_data", $tlb_ram_data_width],
        "A_tlbw_tag ?
          { A_tlb_wr_vpn2, A_tlb_wr_asid, A_tlb_wr_mask, A_tlb_wr_g } :
         A_tlbw_even ?
          { $tlb_ram_data_entry_padding, A_tlb_wr_even_pfn, A_tlb_wr_even_c,
            A_tlb_wr_even_d, A_tlb_wr_even_v } :
          { $tlb_ram_data_entry_padding, A_tlb_wr_odd_pfn, A_tlb_wr_odd_c, 
            A_tlb_wr_odd_d, A_tlb_wr_odd_v }"],








      [["tlb_match", 1], join('|', @tlb_match_signals)],




      [["tlb_match_vpn", $mmu_addr_vpn_sz], 
        "udtlb_fill_starting ? $udtlb_fill_vpn : 
         uitlb_fill_starting ? $uitlb_fill_vpn : 
                               tlb_match_vpn_persistent"],


      [["tlb_match_vpn2", $mmu_addr_vpn2_sz], 
        "tlb_match_vpn[$mmu_addr_vpn_sz-1:1]"],





      ["{ tlb_rd_vpn2, tlb_rd_asid, tlb_rd_raw_mask, tlb_rd_g }", 
        "tlb_rd_q"],


      ["{ tlb_rd_pfn, tlb_rd_c, tlb_rd_d, tlb_rd_v }", 
        "tlb_rd_q[$tlb_data_sz-1:0]"],


      [["tlb_rd_page_mask", $tlb_mask_sz * 2],
        "{
          tlb_rd_raw_mask[7],
          tlb_rd_raw_mask[7],
          tlb_rd_raw_mask[6],
          tlb_rd_raw_mask[6],
          tlb_rd_raw_mask[5],
          tlb_rd_raw_mask[5],
          tlb_rd_raw_mask[4],
          tlb_rd_raw_mask[4],
          tlb_rd_raw_mask[3],
          tlb_rd_raw_mask[3],
          tlb_rd_raw_mask[2],
          tlb_rd_raw_mask[2],
          tlb_rd_raw_mask[1],
          tlb_rd_raw_mask[1],
          tlb_rd_raw_mask[0],
          tlb_rd_raw_mask[0]}"],
    );

    e_register->adds(
      {out => ["A_tlb_inst_active", 1], in => "A_tlb_inst_active_nxt",
       enable => "1"},


      {out => ["A_tlb_inst_start", 1], in => "A_tlb_inst_start_nxt",
       enable => "1"},

      {out => ["A_tlb_rw_inst_index", $tlb_index_sz], 
       in => "M_tlb_rw_inst_index",
       enable => "A_en"},

      {out => ["A_tlbr_tag_addr_d1", 1], in => "A_tlbr_tag_addr",
       enable => "1"},
      {out => ["A_tlbr_even_addr_d1", 1], in => "A_tlbr_even_addr",
       enable => "1"},
      {out => ["A_tlbr_odd_addr_d1", 1], in => "A_tlbr_odd_addr",
       enable => "1"},

      {out => ["A_tlbp_start_d1", 1], in => "A_tlbp_start",
       enable => "1"},
      {out => ["A_tlbp_match_active", 1], in => "A_tlbp_match_active_nxt",
       enable => "1"},






      {out => ["A_tlbp_bank_tag_entry_cnt", $tlb_bank_entry_index_sz+1],
       in => "A_tlbp_start ? 0 : (A_tlbp_bank_tag_entry_cnt+1)",
       enable => "1'b1"},

      {out => ["A_tlbw_tag_d1", 1], in => "A_tlbw_tag",
       enable => "1"},
      {out => ["A_tlbw_even_d1", 1], in => "A_tlbw_even",
       enable => "1"},









      {out => ["tlb_match_tag_addr", $tlb_bank_addr_sz],
       in => "(tlb_match_tag_addr == $tlb_tag_entry_max_addr) ?
                  $tlb_tag_entry_min_addr : 
                  (tlb_match_tag_addr + 1)", 
       enable => "1'b1", async_value => $tlb_tag_entry_min_addr },

      {out => ["tlb_match_even_data_addr", $tlb_bank_addr_sz],
       in => "(tlb_match_even_data_addr == $tlb_even_data_entry_max_addr) ?
                  $tlb_even_data_entry_min_addr : 
                  (tlb_match_even_data_addr + 1)", 
       enable => "1'b1", async_value => ($tlb_even_data_entry_min_addr - 2) },

      {out => ["tlb_match_odd_data_addr", $tlb_bank_addr_sz],
       in => "(tlb_match_odd_data_addr == $tlb_odd_data_entry_max_addr) ?
                  $tlb_odd_data_entry_min_addr : 
                  (tlb_match_odd_data_addr + 1)", 
       enable => "1'b1", async_value => ($tlb_odd_data_entry_min_addr - 2) },

      {out => ["tlb_match_tlb_index_d1", $tlb_index_sz], 
       in => "tlb_match_tlb_index", enable => "1'b1"},

      {out => ["tlb_match_raw_mask_d1", $tlb_mask_sz], 
       in => "tlb_match_raw_mask", enable => "1'b1"},






      {out => ["tlb_match_vpn_persistent", $mmu_addr_vpn_sz], 
       in => "A_tlbp_start         ? { W_cop0_entry_hi_reg_vpn2, 1'b0} :
              utlb_fill_starting_d ? $udtlb_fill_vpn : 
                                     $uitlb_fill_vpn",
       enable => "A_tlbp_start | utlb_fill_starting"},
    );

    my @tlb_all_ram_banks_wave_signals = ([
      { divider => "TLB ALL RAM BANKS" },
      { radix => "x", signal => "tlb_rd_q" },
      { radix => "x", signal => "tlb_match_raw_mask" },
      { radix => "x", signal => "tlb_match_tlb_index" },
      { radix => "x", signal => "tlb_rd_vpn2" },
      { radix => "x", signal => "tlb_rd_asid" },
      { radix => "x", signal => "tlb_rd_raw_mask" },
      { radix => "x", signal => "tlb_rd_page_mask" },
      { radix => "x", signal => "tlb_rd_g" },
      { radix => "x", signal => "tlb_rd_pfn" },
      { radix => "x", signal => "tlb_rd_c" },
      { radix => "x", signal => "tlb_rd_d" },
      { radix => "x", signal => "tlb_rd_v" },
      { radix => "x", signal => "A_tlb_inst_stall" },
      { radix => "x", signal => "A_tlb_inst_start_nxt" },
      { radix => "x", signal => "A_tlb_inst_stop_nxt" },
      { radix => "x", signal => "A_tlb_inst_active" },
      { radix => "x", signal => "M_tlb_rw_inst_index" },
      { radix => "x", signal => "A_tlbr_active" },
      { radix => "x", signal => "A_tlbr_tag_addr" },
      { radix => "x", signal => "A_tlbr_even_addr" },
      { radix => "x", signal => "A_tlbr_odd_addr" },
      { radix => "x", signal => "A_tlbp_start" },
      { radix => "x", signal => "A_tlbp_done" },
      { radix => "x", signal => "A_tlbp_match_active" },
      { radix => "x", signal => "A_tlbp_last_bank_tag_entry" },
      { radix => "x", signal => "A_tlbp_bank_tag_entry_cnt" },
      { radix => "x", signal => "tlb_match_tag_addr" },
      { radix => "x", signal => "tlb_match_even_data_addr" },
      { radix => "x", signal => "tlb_match_odd_data_addr" },
      { radix => "x", signal => "A_tlbw_tag" },
      { radix => "x", signal => "A_tlbw_start" },
      { radix => "x", signal => "A_tlbw_even" },
      { radix => "x", signal => "A_tlbw_odd" },
      { radix => "x", signal => "A_tlbw_en" },
      { radix => "x", signal => "A_tlbw_active" },
      { radix => "x", signal => "A_tlb_wr_vpn2" },
      { radix => "x", signal => "A_tlb_wr_asid" },
      { radix => "x", signal => "A_tlb_wr_mask" },
      { radix => "x", signal => "A_tlb_wr_g" },
      { radix => "x", signal => "A_tlb_wr_even_pfn" },
      { radix => "x", signal => "A_tlb_wr_even_c" },
      { radix => "x", signal => "A_tlb_wr_even_d" },
      { radix => "x", signal => "A_tlb_wr_even_v" },
      { radix => "x", signal => "A_tlb_wr_odd_pfn" },
      { radix => "x", signal => "A_tlb_wr_odd_c" },
      { radix => "x", signal => "A_tlb_wr_odd_d" },
      { radix => "x", signal => "A_tlb_wr_odd_v" },
      { radix => "x", signal => "A_tlb_wr_data" },
      { radix => "x", signal => "A_tlb_inst_active" },
      { radix => "x", signal => "A_tlb_inst_start" },
      { radix => "x", signal => "tlb_match" },
      { radix => "x", signal => "tlb_match_vpn" },
      { radix => "x", signal => "tlb_match_vpn2" },
      { radix => "x", signal => "tlb_match_vpn_persistent" },
    ]);


    for (my $bank = 0; $bank < $tlb_num_banks; $bank++) {
        my $tlb_one_ram_bank_wave_signals = make_one_tlb_ram_bank($Opt, $bank);

        push(@tlb_all_ram_banks_wave_signals, $tlb_one_ram_bank_wave_signals);
    }

    return \@tlb_all_ram_banks_wave_signals;
}


sub 
make_one_tlb_ram_bank
{
    my $Opt = shift;
    my $bank = shift;       # Bank index from 0 to tlb_num_banks-1

    my $tb = get_tlb_bank_signal_name_prefix($bank);


    my $min_tlb_index = $bank * $tlb_entries_per_bank;
    my $max_tlb_index = $min_tlb_index + ($tlb_entries_per_bank - 1);

    e_signal->adds(

      ["${tb}_rd_q", $tlb_ram_data_width],   


      ["${tb}_rd_vpn2", $tlb_vpn2_sz],
      ["${tb}_rd_asid", $tlb_asid_sz],
      ["${tb}_rd_raw_mask", $tlb_mask_sz],
      ["${tb}_rd_g", 1],
    );

    e_assign->adds(



       

      [["M_${tb}_rw_inst_select", 1], 
        ($tlb_num_banks == 1) ?
          "1" :
          "(M_tlb_rw_inst_index >= $min_tlb_index) &
           (M_tlb_rw_inst_index < ($max_tlb_index+1))"],


      [["M_${tb}_rw_inst_index_offset", $tlb_index_sz], 
        "M_tlb_rw_inst_index - $min_tlb_index"],
      [["M_${tb}_rw_inst_bank_entry_index", $tlb_bank_entry_index_sz], 
        "M_${tb}_rw_inst_index_offset[$tlb_bank_entry_index_sz-1:0]"],
        





      [["${tb}_fill_match_data_addr", $tlb_bank_addr_sz],
        "${tb}_match_even_odd_bit ? tlb_match_odd_data_addr :
                                    tlb_match_even_data_addr"],



      [["${tb}_rd_addr_sel_data_addr", 1],
        "${tb}_match & utlb_fill_match_active"],




      [["${tb}_rd_addr", $tlb_bank_addr_sz],
        "A_tlbr_active               ? A_${tb}_rw_inst_bank_addr : 
         ${tb}_rd_addr_sel_data_addr ? ${tb}_fill_match_data_addr :
                                       tlb_match_tag_addr"],


      ["{ ${tb}_rd_vpn2, ${tb}_rd_asid, ${tb}_rd_raw_mask, ${tb}_rd_g }",
        "${tb}_rd_q"],



      [["${tb}_rd_vpn2_mask", $tlb_vpn2_sz],
        "{3'b0,
          ${tb}_rd_raw_mask[7],
          ${tb}_rd_raw_mask[7],
          ${tb}_rd_raw_mask[6],
          ${tb}_rd_raw_mask[6],
          ${tb}_rd_raw_mask[5],
          ${tb}_rd_raw_mask[5],
          ${tb}_rd_raw_mask[4],
          ${tb}_rd_raw_mask[4],
          ${tb}_rd_raw_mask[3],
          ${tb}_rd_raw_mask[3],
          ${tb}_rd_raw_mask[2],
          ${tb}_rd_raw_mask[2],
          ${tb}_rd_raw_mask[1],
          ${tb}_rd_raw_mask[1],
          ${tb}_rd_raw_mask[0],
          ${tb}_rd_raw_mask[0]}"],






      [["${tb}_match_vpn2_lo_nxt", 1], 
        "(tlb_match_vpn2[8:0] & ~${tb}_rd_vpn2_mask[8:0]) == 
           (${tb}_rd_vpn2[8:0] & ~${tb}_rd_vpn2_mask[8:0])"],

      [["${tb}_match_vpn2_hi_nxt", 1], 
        "(tlb_match_vpn2[18:9] & ~${tb}_rd_vpn2_mask[18:9]) == 
           (${tb}_rd_vpn2[18:9] & ~${tb}_rd_vpn2_mask[18:9])"],




      [["${tb}_match_asid_nxt", 1], 
        "(W_cop0_entry_hi_reg_asid == ${tb}_rd_asid) | ${tb}_rd_g"],





      [["${tb}_match", 1], 
        "${tb}_match_vpn2_lo & ${tb}_match_vpn2_hi & ${tb}_match_asid"],







      [["A_${tb}_wr_en", 1], "A_tlbw_en & A_${tb}_rw_inst_select"], 
    );



    e_mux->adds({ 
      lhs => ["${tb}_match_even_odd_bit_nxt", 1],   
      type => "priority",
      table => [
        "${tb}_rd_raw_mask[7]" => "tlb_match_vpn[16]",
        "${tb}_rd_raw_mask[6]" => "tlb_match_vpn[14]",
        "${tb}_rd_raw_mask[5]" => "tlb_match_vpn[12]",
        "${tb}_rd_raw_mask[4]" => "tlb_match_vpn[10]",
        "${tb}_rd_raw_mask[3]" => "tlb_match_vpn[8]",
        "${tb}_rd_raw_mask[2]" => "tlb_match_vpn[6]",
        "${tb}_rd_raw_mask[1]" => "tlb_match_vpn[4]",
        "${tb}_rd_raw_mask[0]" => "tlb_match_vpn[2]",
      ],
      default                  => "tlb_match_vpn[0]",
    });

    my $tlb_bank_ram_fname = $Opt->{name} . "_${tb}_ram";



    nios_sdp_ram->add({
      name => $Opt->{name} . "_${tb}",
      Opt                     => $Opt,
      data_width              => $tlb_ram_data_width,
      address_width           => $tlb_bank_addr_sz,
      num_words               => $tlb_bank_num_addrs,
      contents_file           => $tlb_bank_ram_fname,
      read_during_write_mode_mixed_ports => qq("DONT_CARE"),
      port_map => {
        clock     => "clk",
   

        data      => "A_tlb_wr_data",
        wren      => "A_${tb}_wr_en",
        wraddress => "A_${tb}_rw_inst_bank_addr",
  

        rdaddress => "${tb}_rd_addr",
        q         => "${tb}_rd_q",
      },
    });

    my $do_build_sim = manditory_bool($Opt, "do_build_sim");
    my $simulation_directory = $do_build_sim ? 
        not_empty_scalar($Opt, "simulation_directory") : undef;

    make_contents_file_for_ram({
      filename_no_suffix        => $tlb_bank_ram_fname,
      data_sz                   => $tlb_ram_data_width,
      num_entries               => $tlb_bank_num_addrs, 
      value_str                 => "deadbeeef",
      clear_hdl_sim_contents    => 0,
      do_build_sim              => $do_build_sim,
      simulation_directory      => $simulation_directory,
      system_directory          => not_empty_scalar($Opt, "system_directory"),
    });

    e_register->adds(
      {out => ["A_${tb}_rw_inst_select", 1],   
       in => "M_${tb}_rw_inst_select", 
       enable => "A_en"},





      {out => ["${tb}_rd_q_select", 1],   
       in => ($tlb_num_banks == 1) ?
         "1" :
         "A_tlbr_active ? A_${tb}_rw_inst_select : ${tb}_match", 
       enable => "1"},








      {out => ["A_${tb}_rw_inst_bank_addr", $tlb_bank_addr_sz],   
       in => 
         "A_tlb_inst_start_nxt ? 
             M_${tb}_rw_inst_bank_entry_index :
          (A_${tb}_rw_inst_bank_addr < 
           ($tlb_bank_num_addrs - $tlb_entries_per_bank)) ? 
             (A_${tb}_rw_inst_bank_addr + $tlb_entries_per_bank) :
              A_${tb}_rw_inst_bank_addr", 
       enable => "1"},








      {out => ["${tb}_match_tlb_index", $tlb_index_sz],
       in => "(${tb}_match_tlb_index == $max_tlb_index) ?
                  $min_tlb_index : 
                  (${tb}_match_tlb_index + 1)", 
       enable => "1'b1", 
       async_value => ($max_tlb_index - 1)},


      {out => ["${tb}_rd_raw_mask_d1", $tlb_mask_sz], 
       in => "${tb}_rd_raw_mask", enable => "1'b1"},

      {out => ["${tb}_match_vpn2_lo", 1], in => "${tb}_match_vpn2_lo_nxt",
       enable => "1'b1"},
      {out => ["${tb}_match_vpn2_hi", 1], in => "${tb}_match_vpn2_hi_nxt",
       enable => "1'b1"},
      {out => ["${tb}_match_asid", 1], in => "${tb}_match_asid_nxt",
       enable => "1'b1"},
      {out => ["${tb}_match_even_odd_bit", 1],
       in => "${tb}_match_even_odd_bit_nxt", enable => "1'b1"},
    );

    my @tlb_ram_banks_wave_signals = (
      { divider => "TLB RAM BANK $bank" },
      { radix => "x", signal => "M_${tb}_rw_inst_select" },
      { radix => "x", signal => "M_${tb}_rw_inst_index_offset" },
      { radix => "x", signal => "M_${tb}_rw_inst_bank_entry_index" },
      { radix => "x", signal => "${tb}_fill_match_data_addr" },
      { radix => "x", signal => "${tb}_match_even_odd_bit_nxt" },
      { radix => "x", signal => "${tb}_rd_q_select" },
      { radix => "x", signal => "A_${tb}_rw_inst_bank_addr" },
      { radix => "x", signal => "${tb}_match_tlb_index" },
      { radix => "x", signal => "${tb}_rd_addr_sel_data_addr" },
      { radix => "x", signal => "${tb}_rd_addr" },
      { radix => "x", signal => "${tb}_rd_q" },
      { radix => "x", signal => "${tb}_rd_vpn2" },
      { radix => "x", signal => "${tb}_rd_asid" },
      { radix => "x", signal => "${tb}_rd_raw_mask" },
      { radix => "x", signal => "${tb}_rd_vpn2_mask" },
      { radix => "x", signal => "${tb}_rd_g" },
      { radix => "x", signal => "${tb}_match_vpn2_lo_nxt" },
      { radix => "x", signal => "${tb}_match_vpn2_hi_nxt" },
      { radix => "x", signal => "${tb}_match_asid_nxt" },
      { radix => "x", signal => "${tb}_match" },
      { radix => "x", signal => "A_${tb}_wr_en" },
      { radix => "x", signal => "A_${tb}_rw_inst_select" },
      { radix => "x", signal => "A_${tb}_rw_inst_bank_addr" },
    );

    return \@tlb_ram_banks_wave_signals;
}



sub 
make_fmt
{
    my $Opt = shift;
    my $d = shift;


    my $f = $d ? "dfmt" : "ifmt";
    my $F = $d ? "DFMT" : "IFMT";


    my $stage = not_empty_scalar($Opt, $f . "_stage");
    my $vaddr = not_empty_scalar($Opt, $f . "_vaddr");
    my $paddr = not_empty_scalar($Opt, $f . "_paddr");


    my $vaddr_sz = 32;
    my $vaddr_msb = $vaddr_sz - 1;
    my $paddr_sz = $d ? 
      manditory_int($Opt, "d_Address_Width") :
      manditory_int($Opt, "i_Address_Width");

    my $paddr_mux_table = [
        "${vaddr}_user_region"    =>
           "{ 1'b0, ${vaddr}\[$vaddr_msb-1:0] } + ${stage}_user_region_offset",
        "${vaddr}_kernel_region"  => "{ 3'b0, ${vaddr}\[$vaddr_msb-3:0] }",
        "${vaddr}_io_region"      => "{ 3'b0, ${vaddr}\[$vaddr_msb-3:0] }",
    ];

    if ($debug_port_present) {

        my $debug_offset_paddr_sz = $vaddr_sz - $mmu_addr_dseg_region_sz;
        my $debug_offset_paddr_msb = $debug_offset_paddr_sz - 1;

        my $debug_paddr = manditory_int($Opt, "debug_paddr");
        my $debug_base_paddr_mask = sz2mask($mmu_addr_dseg_region_sz);
        my $debug_base_paddr = 
          ($debug_paddr >> $debug_offset_paddr_sz) & $debug_base_paddr_mask;

        my $region_sel = "${vaddr}_dseg_region";
        if ($d) {

            $region_sel .= "_with_lsnm";
        }

        push(@$paddr_mux_table,
            $region_sel => "{" .
              " ${mmu_addr_dseg_region_sz}'d${debug_base_paddr}," . 
              " ${vaddr}\[$debug_offset_paddr_msb:0]" .
              " }"
        );
    }


    push(@$paddr_mux_table,
        "1'b1"                    => $vaddr
    );


    e_mux->add ({
      lhs => [$paddr, $paddr_sz],
      type => "priority",
      table => $paddr_mux_table,
    });

    my $vaddr_sz_less_2 = $vaddr_sz - 2;

    e_assign->adds(

      [["${stage}_user_region_offset", $vaddr_sz], 
        "{ 1'b0, ~W_cop0_status_reg_erl, ${vaddr_sz_less_2}'b0 }"],
    );

    if (!$d) {
        e_assign->adds(

          [["F_pc_phy", $paddr_sz-2], "$paddr\[$paddr_sz-1:2]"],
        );
    }

    my @wave_signals = (
      { divider => "$F FMT" },
      { radix => "x", signal => "${vaddr}_user_region" },
      { radix => "x", signal => "${vaddr}_kernel_region" },
      { radix => "x", signal => "${vaddr}_io_region" },
      { radix => "x", signal => "${stage}_user_region_offset" },
      { radix => "x", signal => "$paddr" },
    );

    return \@wave_signals;
}





sub
create_mmu_constants
{
    my $mmu_args = shift;

    my %constants;




    $constants{mmu_addr_user_region} = "1'b0";          # MIPS useg region
    $constants{mmu_addr_kernel_region} = "3'b100";      # MIPS kseg0 region
    $constants{mmu_addr_io_region} = "3'b101";          # MIPS kseg1 region
    $constants{mmu_addr_kernel_mmu_region} = "2'b11";   # MIPS kseg2 region
    $constants{mmu_addr_dseg_region} = "11'b11111111001"; # MIPS dseg region

    $constants{mmu_addr_kernel_region_int} = "8";       # decimal version
    $constants{mmu_addr_io_region_int} = "5";           # decimal version


    $constants{mmu_addr_bypass_tlb} = "2'b10";



    $constants{mmu_addr_bypass_tlb_cacheable} = "1'b0";




    $constants{mmu_addr_io_region_vpn} = "20'ha0000";




    if (manditory_bool($mmu_args, "tlb_present")) {
        $constants{tlb_min_ptr_sz} = 4;
        $constants{tlb_max_ptr_sz} = 6;
        $constants{tlb_max_entries} = 1 << $constants{tlb_max_ptr_sz};


        $constants{uitlb_index_sz} = 
          count2sz(manditory_int($mmu_args, "uitlb_num_entries"));
        $constants{udtlb_index_sz} = 
          count2sz(manditory_int($mmu_args, "udtlb_num_entries"));
    }

    return \%constants;
}

sub
create_mmu_addr_bit_fields
{
    my $bit_fields = [];

    add_bit_field($bit_fields, { name => "vpn", sz => 20, lsb => 12 });
    add_bit_field($bit_fields, { name => "vpn2", sz => 19, lsb => 13 });
    add_bit_field($bit_fields, { name => "pfn", sz => 20, lsb => 12 });
    add_bit_field($bit_fields, { name => "page_offset", sz => 12, lsb => 0 });


    add_bit_field($bit_fields, { name => "user_region", sz => 1, lsb => 31 });
    add_bit_field($bit_fields, 
      { name => "kernel_mmu_region", sz => 2, lsb => 30 });
    add_bit_field($bit_fields, { name => "kernel_region", sz => 3, lsb => 29 });
    add_bit_field($bit_fields, { name => "io_region", sz => 3, lsb => 29 });
    add_bit_field($bit_fields, { name => "dseg_region", sz => 11, lsb => 21 });
    add_bit_field($bit_fields, { name => "bypass_tlb", sz => 2, lsb => 30 });
    add_bit_field($bit_fields, 
      { name => "bypass_tlb_cacheable", sz => 1, lsb => 29 });


    add_bit_field($bit_fields, 
      { name => "bypass_tlb_paddr", sz => 29, lsb => 0 });

    return $bit_fields;
}



sub
add_bit_field
{
    my $bit_fields = shift;
    my $props = shift;

    my $field_name = $props->{name};

    if (defined(get_bit_field_by_name_or_undef($bit_fields, $field_name))) {
        return 
          &$error("Bit field name '$field_name' already exists");
    }

    my $bit_field = create_bit_field($props);


    push(@$bit_fields, $bit_field);

    return $bit_field;
}

sub
convert_mmu_addr_bit_fields_to_c
{
    my $bit_fields = shift;
    my $c_lines = shift;
    my $h_lines = shift;

    push(@$h_lines, 
      "",
      "/*",
      " * MMU address bit field macros",
      " */");

    foreach my $bit_field (@$bit_fields) {
        if (!defined(convert_bit_field_to_c($bit_field, $c_lines, $h_lines,
          "MIPS32_MMU_ADDR_", "Addr"))) {
            return undef;
        }
    }

    return 1;   # Some defined value
}

sub
add_handy_macros
{
    my $h_lines = shift;

    my $define = "#define";     # The build removes #define comments

    my $macros_str = <<EOM;

/*
 * MMU Memory Region Macros
 */
$define MIP32_USER_REGION_MIN_VADDR       0x00000000
$define MIP32_USER_REGION_MAX_VADDR       0x7fffffff
$define MIP32_KERNEL_REGION_MIN_VADDR     0x80000000
$define MIP32_KERNEL_REGION_MAX_VADDR     0x9fffffff
$define MIP32_IO_REGION_MIN_VADDR         0xa0000000
$define MIP32_IO_REGION_MAX_VADDR         0xbfffffff
$define MIP32_KERNEL_MMU_REGION_MIN_VADDR 0xc0000000
$define MIP32_KERNEL_MMU_REGION_MAX_VADDR 0xffffffff
$define MIP32_DSEG_REGION_MIN_VADDR       0xff200000
$define MIP32_DSEG_REGION_MAX_VADDR       0xff3fffff

$define MIP32_MMU_MIN_PAGE_SIZE (0x1 << (MIP32_MMU_ADDR_PAGE_OFFSET_SZ))

$define isMips32MmuUserRegion(Vaddr)          \\
    (GET_MIPS32_MMU_ADDR_USER_REGION(Vaddr) == MIPS32_MMU_ADDR_USER_REGION)
$define isMips32MmuKernelRegion(Vaddr)        \\
    (GET_MIPS32_MMU_ADDR_KERNEL_REGION(Vaddr) == MIPS32_MMU_ADDR_KERNEL_REGION)
$define isMips32MmuIORegion(Vaddr)            \\
    (GET_MIPS32_MMU_ADDR_IO_REGION(Vaddr) == MIPS32_MMU_ADDR_IO_REGION)
$define isMips32MmuKernelMmuRegion(Vaddr)     \\
    (GET_MIPS32_MMU_ADDR_KERNEL_MMU_REGION(Vaddr) == MIPS32_MMU_ADDR_KERNEL_MMU_REGION)
$define isMips32MmuDsegRegion(Vaddr)     \\
    (GET_MIPS32_MMU_ADDR_DSEG_REGION(Vaddr) == MIPS32_MMU_ADDR_DSEG_REGION)

/* Does this virtual address bypass the TLB? */
$define mips32VaddrBypassTlb(Vaddr)                \\
    (GET_MIPS32_MMU_ADDR_BYPASS_TLB(Vaddr) == MIPS32_MMU_ADDR_BYPASS_TLB)

/* If TLB is bypassed, is the address cacheable or uncachable. */
$define mips32VaddrBypassTlbCacheable(Vaddr)       \\
    (GET_MIPS32_MMU_ADDR_BYPASS_TLB_CACHEABLE(Vaddr) == MIPS32_MMU_ADDR_BYPASS_TLB_CACHEABLE)

/*
 * Compute physical address for regions that bypass the TLB.
 * Just need to clear some top bits.
 */
$define mips32BypassTlbVaddrToPaddr(Vaddr)    \\
    ((Vaddr) & (MIPS32_MMU_ADDR_BYPASS_TLB_PADDR_MASK << MIPS32_MMU_ADDR_BYPASS_TLB_PADDR_LSB))

/* 
 * Will the physical address fit in the Kernel/IO region virtual address space?
 */
$define mips32FitsInKernelRegion(Paddr)       \\
    (GET_MIPS32_MMU_ADDR_KERNEL_REGION(Paddr) == 0)
$define mips32FitsInIORegion(Paddr)           \\
    (GET_MIPS32_MMU_ADDR_IO_REGION(Paddr) == 0)

/* Convert a physical address to a Kernel/IO region virtual address. */
$define mips32PaddrToKernelRegionVaddr(Paddr) \\
    ((Paddr) | (MIPS32_MMU_ADDR_KERNEL_REGION << MIPS32_MMU_ADDR_KERNEL_REGION_LSB))
$define mips32PaddrToIORegionVaddr(Paddr)     \\
    ((Paddr) | (MIPS32_MMU_ADDR_IO_REGION << MIPS32_MMU_ADDR_IO_REGION_LSB))

/*
 * Convert a virtual address to a Kernel/IO region virtual address.
 * Uses bypassTlbVaddrToPaddr to clear top bits.
 */
$define mips32VaddrToKernelRegionVaddr(Vaddr) \\
    mips32PaddrToKernelRegionVaddr(mips32BypassTlbVaddrToPaddr(Vaddr))
$define mips32VaddrToIORegionVaddr(Vaddr) \\
    mips32PaddrToIORegionVaddr(mips32BypassTlbVaddrToPaddr(Vaddr))

/* Convert between VPN/PFN and virtual/physical addresses. */
$define mips32VpnToVaddr(Vpn) ((Vpn) << MIPS32_MMU_ADDR_VPN_LSB)
$define mips32Vpn2ToVaddr(Vpn2) ((Vpn2) << MIPS32_MMU_ADDR_VPN2_LSB)
$define mips32PfnToPaddr(Pfn) ((Pfn) << MIPS32_MMU_ADDR_PFN_LSB)
$define mips32VaddrToVpn(Vaddr) GET_MIPS32_MMU_ADDR_VPN(Vaddr)
$define mips32VaddrToVpn2(Vaddr) GET_MIPS32_MMU_ADDR_VPN2(Vaddr)
$define mips32PaddrToPfn(Paddr) GET_MIPS32_MMU_ADDR_PFN(Paddr)

/* Bitwise OR with a KERNEL region address to make it an IO region address */
$define MIPS32_KERNEL_TO_IO_REGION 0x20000000
EOM

    push(@$h_lines, split(/\n/, $macros_str));
}


sub
get_utlb_entry_signal_name_prefix
{
    my $u = shift;
    my $ui = shift;

    return $u . $ui;
}


sub
get_tlb_bank_signal_name_prefix
{
    my $bank = shift;

    return "tlb_bank" . $bank;
}

sub
eval_cmd
{
    my $cmd = shift;

    eval($cmd);
    if ($@) {
        &$error("nevada_mmu.pm: eval($cmd) returns '$@'\n");
    }
}

1;

