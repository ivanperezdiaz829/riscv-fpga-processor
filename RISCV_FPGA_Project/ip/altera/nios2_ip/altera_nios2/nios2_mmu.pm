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


























package nios2_mmu;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $mmu_addr_vpn_sz $mmu_addr_vpn_lsb $mmu_addr_vpn_msb
    $mmu_addr_pfn_sz $mmu_addr_pfn_lsb $mmu_addr_pfn_msb
    $mmu_addr_page_offset_sz $mmu_addr_page_offset_lsb $mmu_addr_page_offset_msb
    $mmu_addr_user_region_sz
    $mmu_addr_user_region_lsb
    $mmu_addr_user_region_msb
    $mmu_addr_user_region
    $mmu_addr_kernel_mmu_region_sz
    $mmu_addr_kernel_mmu_region_lsb
    $mmu_addr_kernel_mmu_region_msb
    $mmu_addr_kernel_mmu_region
    $mmu_addr_kernel_region_sz
    $mmu_addr_kernel_region_lsb
    $mmu_addr_kernel_region_msb
    $mmu_addr_kernel_region
    $mmu_addr_kernel_region_int
    $mmu_addr_io_region_sz
    $mmu_addr_io_region_lsb
    $mmu_addr_io_region_msb
    $mmu_addr_io_region
    $mmu_addr_io_region_vpn
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
    $tlb_min_pid_sz $tlb_max_pid_sz $tlb_min_ways $tlb_max_ways
    $tlb_min_ptr_sz $tlb_max_ptr_sz $tlb_max_entries $tlb_max_lines
    $uitlb_index_sz $udtlb_index_sz
);

use cpu_utils;
use cpu_bit_field;
use cpu_control_reg;
use nios_utils;
use nios_common;
use nios_sdp_ram;
use nios_isa;
use nios2_control_regs;
use strict;






our $mmu_addr_vpn_sz;
our $mmu_addr_vpn_lsb;
our $mmu_addr_vpn_msb;
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
our $mmu_addr_kernel_mmu_region_sz;
our $mmu_addr_kernel_mmu_region_lsb;
our $mmu_addr_kernel_mmu_region_msb;
our $mmu_addr_kernel_mmu_region;
our $mmu_addr_kernel_region_sz;
our $mmu_addr_kernel_region_lsb;
our $mmu_addr_kernel_region_msb;
our $mmu_addr_kernel_region;
our $mmu_addr_kernel_region_int;
our $mmu_addr_io_region_sz;
our $mmu_addr_io_region_lsb;
our $mmu_addr_io_region_msb;
our $mmu_addr_io_region;
our $mmu_addr_io_region_vpn;
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
our $tlb_min_pid_sz;
our $tlb_max_pid_sz;
our $tlb_min_ways;
our $tlb_max_ways;
our $tlb_min_ptr_sz;
our $tlb_max_ptr_sz;
our $tlb_max_entries;
our $tlb_max_lines;
our $uitlb_index_sz;
our $udtlb_index_sz;


our $tlb_pfn_sz;
our $tlb_way_sz;
our $tlb_pid_sz;
our $tlb_ptr_sz;
our $tlb_line_sz;
our $tlb_tag_sz;
our $tlb_vpn_line_lsb;
our $tlb_vpn_line_msb;
our $tlb_vpn_tag_lsb;
our $tlb_vpn_tag_msb;
our $tlb_data_sz;







sub
create_mmu_args_from_infos
{
    my $mmu_info = shift;

    if (!manditory_bool($mmu_info, "mmu_present")) {
        &$error("Shouldn't be called if MMU isn't present");
    }

    my $mmu_args = {
      process_id_num_bits => manditory_int($mmu_info, "process_id_num_bits"),
      tlb_ptr_sz => manditory_int($mmu_info, "tlb_ptr_sz"),
      tlb_num_ways => manditory_int($mmu_info, "tlb_num_ways"),
      udtlb_num_entries => manditory_int($mmu_info, "udtlb_num_entries"),
      uitlb_num_entries => manditory_int($mmu_info, "uitlb_num_entries"),
    };

    return $mmu_args;
}





sub
create_mmu_args_max_configuration
{
    my $mmu_args = {
      process_id_num_bits => 14,
      tlb_ptr_sz => 10,
      tlb_num_ways => 16,
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
convert_vectors_to_kernel_region
{
    my $vector_info = shift;


    if (fits_in_kernel_region($vector_info->{reset_addr})) {
        $vector_info->{reset_addr} = 
          paddr_to_kernel_region_vaddr($vector_info->{reset_addr});
    } else {
        &$error("Reset address " . sprintf("0x%x", $vector_info->{reset_addr}) .
          " is not reachable from the Kernel region");
    }

    if (fits_in_kernel_region($vector_info->{general_exception_addr})) {
        $vector_info->{general_exception_addr} = 
          paddr_to_kernel_region_vaddr($vector_info->{general_exception_addr});
    } else {
        &$error("General exception address " . 
          sprintf("0x%x", $vector_info->{general_exception_addr}) .
          " is not reachable from the Kernel region");
    }

    if (fits_in_kernel_region($vector_info->{break_addr})) {
        $vector_info->{break_addr} = 
          paddr_to_kernel_region_vaddr($vector_info->{break_addr});
    } else {
        &$error("Break address " . sprintf("0x%x", $vector_info->{break_addr}) .
          " is not reachable from the Kernel region");
    }

    if (fits_in_kernel_region($vector_info->{fast_tlb_miss_exception_addr})) {
        $vector_info->{fast_tlb_miss_exception_addr} = 
          paddr_to_kernel_region_vaddr(
            $vector_info->{fast_tlb_miss_exception_addr});
    } else {
        &$error("Fast TLB miss exception address " . 
          sprintf("0x%x", $vector_info->{fast_tlb_miss_exception_addr}) .
          " is not reachable from the Kernel region");
    }
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
paddr_to_kernel_region_vaddr
{
    my $paddr = shift;

    if (!defined($mmu_addr_kernel_region_int)) {
        return &$error("MMU constants haven't been initialized yet.");
    }

    return ($paddr | 
      ($mmu_addr_kernel_region_int << $mmu_addr_kernel_region_lsb));
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
          " is not reachable from the Kernel region");
    }

    return paddr_to_kernel_region_vaddr($paddr);
}


sub
convert_to_c
{
    my $elaborated_mmu_info = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    push(@$h_lines, "");
    push(@$h_lines, "/* MMU Constants */");
    format_hash_as_c_macros($elaborated_mmu_info->{mmu_constants}, $h_lines);

    convert_mmu_addr_bit_fields_to_c(
      $elaborated_mmu_info->{mmu_addr_bit_fields}, $c_lines, $h_lines);

    add_handy_macros($h_lines);

    return 1;   # Some defined value
}

sub
initialize_config_constants
{
    my $mmu_args = shift;

    if (!$mmu_present) {
        return;
    }

    $tlb_pfn_sz = get_control_reg_field_sz($tlbacc_reg_pfn);
    $tlb_way_sz = get_control_reg_field_sz($tlbmisc_reg_way);
    $tlb_pid_sz = get_control_reg_field_sz($tlbmisc_reg_pid);

    $tlb_ptr_sz = manditory_int($mmu_args, "tlb_ptr_sz");
    $tlb_line_sz = $tlb_ptr_sz - $tlb_way_sz;
    $tlb_tag_sz = 32 - $tlb_line_sz - $mmu_addr_page_offset_sz;


    $tlb_vpn_line_lsb = 0;
    $tlb_vpn_line_msb = $tlb_vpn_line_lsb + $tlb_line_sz - 1;
    $tlb_vpn_tag_lsb = $tlb_vpn_line_msb + 1;
    $tlb_vpn_tag_msb = $tlb_vpn_tag_lsb + $tlb_tag_sz - 1;

    $tlb_data_sz = (
      $tlb_tag_sz +
      $tlb_pid_sz +
      1 + # G-bit
      1 + # X-bit
      1 + # W-bit
      1 + # R-bit
      1 + # C-bit
      $tlb_pfn_sz
    );
}



sub 
make_utlb
{
    my ($Opt, $d) = @_;

    if (!defined($tlb_pfn_sz)) {
        return &$error("MMU config constants haven't been initialized yet.");
    }


    my $whoami = $d ? "uDTLB" : "uITLB";
    my $u = $d ? "udtlb" : "uitlb";
    my $U = $d ? "UDTLB" : "UITLB";


    my $wss = not_empty_scalar($Opt, "wrctl_setup_stage");
    my $cs = not_empty_scalar($Opt, "control_reg_stage");
    my $match_cmp_stage = not_empty_scalar($Opt, $u . "_match_cmp_stage");
    my $match_cmp_vpn = not_empty_scalar($Opt, $u . "_match_cmp_vpn");
    my $match_mux_stage = not_empty_scalar($Opt, $u . "_match_mux_stage");
    my $match_mux_vaddr = not_empty_scalar($Opt, $u . "_match_mux_vaddr");
    my $match_mux_paddr = not_empty_scalar($Opt, $u . "_match_mux_paddr");
    my $fill_stage = not_empty_scalar($Opt, $u . "_fill_stage");
    my $want_fill = not_empty_scalar($Opt, $u . "_want_fill");
    my $want_fill_expr = not_empty_scalar($Opt, $u . "_want_fill_expr");
    my $lru_stage = not_empty_scalar($Opt, $u . "_lru_stage");
    my $num_entries = not_empty_scalar($Opt, $u . "_num_entries");

    my $ui;     # UTLB index









    my @utlb_contents_wave_signals = (
      { divider => "$U Contents" },
      { radix => "x", signal => "utlb_flush_all" },
    );


    for ($ui = 0; $ui < $num_entries; $ui++) {
        e_assign->adds(

          [["${u}${ui}_line", $tlb_line_sz],
              "${u}${ui}_vpn[$tlb_vpn_line_msb:$tlb_vpn_line_lsb]"],





          [["${u}${ui}_ram_addr", $tlb_ptr_sz],
            "{ ${u}${ui}_line, ${u}${ui}_way }"],









          [["${u}${ui}_flush", 1],
            "(tlb_wr_en & (${u}${ui}_m | (tlb_wr_addr == ${u}${ui}_ram_addr))) |
             utlb_flush_all"],



          [["${u}${ui}_wr_en", 1],
            "${u}${ui}_flush | (${u}_fill_select${ui} & ${u}_fill_wr_en)"],






          [["${u}${ui}_vpn_nxt", $mmu_addr_vpn_sz],
            "${u}${ui}_flush ? 
              ($mmu_addr_io_region_vpn + $ui) : 
              utlb_fill_vpn_persistent"],
        );

        e_register->adds(
          {out => ["${u}${ui}_way", $tlb_way_sz],                  
           in => "tlb_rd_way_d1",
           enable => "${u}${ui}_wr_en"},

          {out => ["${u}${ui}_vpn", $mmu_addr_vpn_sz], 
           in => "${u}${ui}_vpn_nxt",
           enable => "${u}${ui}_wr_en",
           async_value => "$mmu_addr_io_region_vpn + $ui"},

          {out => ["${u}${ui}_pfn", $tlb_pfn_sz],     
           in => "tlb_rd_pfn_d1",
           enable => "${u}${ui}_wr_en"},

          {out => ["${u}${ui}_m", 1],                  
           in => "utlb_fill_tlb_miss",
           enable => "${u}${ui}_wr_en"},

          $d ? {out => ["${u}${ui}_w", 1],                  
               in => "tlb_rd_w_d1",
               enable => "${u}${ui}_wr_en"} : (),
          $d ? {out => ["${u}${ui}_r", 1],                  
               in => "tlb_rd_r_d1",
               enable => "${u}${ui}_wr_en"} : (),
          $d ? {out => ["${u}${ui}_c", 1],                  
               in => "tlb_rd_c_d1",
               enable => "${u}${ui}_wr_en"} : (),
          $d ? () : {out => ["${u}${ui}_x", 1],                  
               in => "tlb_rd_x_d1",
               enable => "${u}${ui}_wr_en"},

        );



        if ($mmu_ecc_present) {
            e_register->adds(
               {out => ["${u}${ui}_two_bit_err", 1],     
               in => "~A_tlb_rd_operation & tlb_two_bit_err",
               enable => "${u}${ui}_wr_en"},
            );
        }

        push(@utlb_contents_wave_signals,
          { radix => "x", signal => "${u}${ui}_ram_addr" },
          { radix => "x", signal => "${u}${ui}_line" },
          { radix => "x", signal => "${u}${ui}_way" },
          { radix => "x", signal => "${u}${ui}_vpn" },
          { radix => "x", signal => "${u}${ui}_pfn" },
          $d ? { radix => "x", signal => "${u}${ui}_w" } : "",
          $d ? { radix => "x", signal => "${u}${ui}_r" } : "",
          $d ? { radix => "x", signal => "${u}${ui}_c" } : "",
          $d ? "" : { radix => "x", signal => "${u}${ui}_x" },
          { radix => "x", signal => "${u}${ui}_m" },
          { radix => "x", signal => "${u}${ui}_wr_en" },
          { radix => "x", signal => "${u}${ui}_flush" },
        );
    }





















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





    my @utlb_match_mux_signals;
    my @utlb_match_wave_signals;
    my @utlb_index_mux_table;
    my @utlb_pfn_mux_table;
    my @utlb_m_mux_table;
    my @utlb_x_mux_table;
    my @utlb_w_mux_table;
    my @utlb_r_mux_table;
    my @utlb_c_mux_table;
    my @utlb_two_bit_err_mux_table;
    my @utlb_way_mux_table;

    my $match_mux_type = "and_or";  # "priority" not as good

    for ($ui = 0; $ui < $num_entries; $ui++) {
        my $match_cmp_signal = "${match_cmp_stage}_${u}${ui}_match";
        my $match_mux_signal = "${match_mux_stage}_${u}${ui}_match";

        e_assign->adds(

          [[$match_cmp_signal, 1], "${u}${ui}_vpn == $match_cmp_vpn"],






        );

        push(@utlb_match_mux_signals, $match_mux_signal);
        push(@utlb_match_wave_signals,
          { radix => "x", signal => $match_cmp_signal },
        );


        if ($match_cmp_stage ne $match_mux_stage) {
            e_register->adds(
              {out => [$match_mux_signal, 1],     in => $match_cmp_signal, 
               enable => "${match_mux_stage}_en"},
            );
        }



        my $sel = 
          (($ui == ($num_entries - 1)) && 
           ($match_mux_type eq "priority")) ? 
            "1'b1" : 
            "${match_mux_stage}_${u}${ui}_match";

        push(@utlb_index_mux_table, $sel => "${ui}");
        push(@utlb_pfn_mux_table, $sel => "${u}${ui}_pfn");
        push(@utlb_m_mux_table,   $sel => "${u}${ui}_m");
        push(@utlb_w_mux_table,   $sel => "${u}${ui}_w");
        push(@utlb_r_mux_table,   $sel => "${u}${ui}_r");
        push(@utlb_c_mux_table,   $sel => "${u}${ui}_c");
        push(@utlb_x_mux_table,   $sel => "${u}${ui}_x");
        if ($mmu_ecc_present) {
            push(@utlb_two_bit_err_mux_table,   $sel => "${u}${ui}_two_bit_err");
            push(@utlb_way_mux_table,   $sel => "${u}${ui}_way");
        }
    }

    my $utlb_index_sz = $d ? $udtlb_index_sz : $uitlb_index_sz;


    e_mux->adds(
      { lhs => ["${match_mux_stage}_${u}_index", $utlb_index_sz],   
        type => $match_mux_type, table => \@utlb_index_mux_table },
      { lhs => ["${match_mux_stage}_${u}_pfn", $tlb_pfn_sz],   
        type => $match_mux_type, table => \@utlb_pfn_mux_table },
      { lhs => ["${match_mux_stage}_${u}_m", 1],               
        type => $match_mux_type, table => \@utlb_m_mux_table },
      $d ? { lhs => ["${match_mux_stage}_${u}_w", 1],          
        type => $match_mux_type, table => \@utlb_w_mux_table } : (),
      $d ? { lhs => ["${match_mux_stage}_${u}_r",1],           
        type => $match_mux_type, table => \@utlb_r_mux_table } : (),
      $d ? { lhs => ["${match_mux_stage}_${u}_c", 1, 0, $force_never_export],
        type => $match_mux_type, table => \@utlb_c_mux_table } : (),
      $d ? () : { lhs => ["${match_mux_stage}_${u}_x", 1],
        type => $match_mux_type, table => \@utlb_x_mux_table },
      );



    if ($mmu_ecc_present) {
      e_mux->adds(
        { lhs => ["${match_mux_stage}_${u}_way", $tlb_way_sz],   
          type => $match_mux_type, table => \@utlb_way_mux_table },
        { lhs => ["${match_mux_stage}_${u}_two_bit_err", 1],               
          type => $match_mux_type, table => \@utlb_two_bit_err_mux_table },
      );        
    } 

    if (!$d) {
        e_assign->adds(


          [["${match_mux_paddr}_pfn_valid", 1],  
            "(${match_mux_stage}_${u}_hit & ~${match_mux_stage}_${u}_m) |
              ${match_mux_vaddr}_bypass_tlb"],
        );
    }

    my $paddr_sz = $d ? 
      manditory_int($Opt, "d_Address_Width") :
      (manditory_int($Opt, "i_Address_Width") - 2);

    e_assign->adds(

      [["${match_mux_stage}_${u}_hit", 1], join('|', @utlb_match_mux_signals)],



      [["${match_mux_paddr}_got_pfn", 1],  
        "${match_mux_stage}_${u}_hit | ${match_mux_vaddr}_bypass_tlb"],


      [["${match_mux_paddr}_pfn_max", $mmu_addr_pfn_sz],
        "{ 3'b000, ${match_mux_vaddr}_vpn[16:0]}"],



      [["$match_mux_paddr", $paddr_sz], 
        "{ (${match_mux_vaddr}_bypass_tlb ? 
                ${match_mux_paddr}_pfn_max[$tlb_pfn_sz-1:0] :
                ${match_mux_stage}_${u}_pfn), 
           ${match_mux_vaddr}_page_offset }"],


      $d ? () : [["F_pcb_phy", $paddr_sz+2, 0, $force_never_export],
        "{ $match_mux_paddr, 2'b00 }"],
    );

    e_process->adds({
        tag => 'simulation',
        contents => [
            e_if->new({
                condition => 
                  "reset_n & (" . join('+', @utlb_match_mux_signals) . ") > 1",
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
      $d ? { radix => "x", signal => "${match_mux_stage}_${u}_w" } : "",
      $d ? { radix => "x", signal => "${match_mux_stage}_${u}_r" } : "",
      $d ? { radix => "x", signal => "${match_mux_stage}_${u}_c" } : "",
      $d ? "" : { radix => "x", signal => "${match_mux_stage}_${u}_x" },
      { radix => "x", signal => "${match_mux_stage}_${u}_hit" },
      { radix => "x", signal => "${match_mux_paddr}_got_pfn" },
      $d ? "" : { radix => "x", signal => "${match_mux_paddr}_pfn_valid" },
      $d ? { radix => "x", signal => $match_mux_paddr } :
           { radix => "x", signal => "F_pcb_phy" },
    );

    my @wave_signals = 
      (@utlb_lookup_wave_signals,
       @utlb_lru_wave_signals,
       @utlb_fill_wave_signals,
       @utlb_contents_wave_signals);

    return \@wave_signals;
}



sub 
make_tlb
{
    my ($Opt) = @_;

    &$progress("    TLB");

    if (!defined($tlb_pfn_sz)) {
        return &$error("MMU config constants haven't been initialized yet.");
    }

    my $whoami = "TLB";
    my $wss = not_empty_scalar($Opt, "wrctl_setup_stage");
    my $cs = not_empty_scalar($Opt, "control_reg_stage");
    my $udtlb_want_fill = not_empty_scalar($Opt, "udtlb_want_fill");
    my $uitlb_want_fill = not_empty_scalar($Opt, "uitlb_want_fill");
    my $udtlb_fill_vpn = not_empty_scalar($Opt, "udtlb_fill_vpn");
    my $uitlb_fill_vpn = not_empty_scalar($Opt, "uitlb_fill_vpn");

    my $ecc_one_bit_err_flush = "";
    my $ecc_one_bit_err_wr_op = "";
    my $ecc_one_bit_err_get_rd_addr = "{ tlb_wr_line, tlb_wr_way }";
    my $ecc_err_match = "";
    my @ecc_ports;

    if ($mmu_ecc_present) {
       my $hw_read_one_bit_err      = "(~${cs}_tlb_rd_operation & tlb_one_bit_err)";
       

       $ecc_one_bit_err_flush       = "| (~${cs}_tlb_rd_operation & tlb_one_bit_err)";
       

       $ecc_err_match       = "| (~${cs}_tlb_rd_operation & (tlb_two_bit_err | tlb_one_bit_err))";


       $ecc_one_bit_err_wr_op       = "$hw_read_one_bit_err |";

       $ecc_one_bit_err_get_rd_addr = "(${wss}_wrctl_tlbacc & ${wss}_valid & ${cs}_tlbmisc_reg_we) ? { tlb_wr_line, tlb_wr_way } : 
                                                                                                   {tlb_rd_line_d1,tlb_rd_way_d1}";
       push(@ecc_ports,
            injs         => "W_tlb_injs",
            injd         => "W_tlb_injd",
            wrsel        => "tlb_wrsel",
            corrected_data_to_encoder    => "tlb_corrected_data_from_decoder",
            corrected_data_from_decoder    => "tlb_corrected_data_from_decoder_nxt",
            one_bit_err  => "tlb_one_bit_err_nxt",
            two_bit_err   => "tlb_two_bit_err_nxt",
            one_two_or_three_bit_err => "tlb_one_two_or_three_bit_err_nxt",
       );

       if ($ecc_test_ports_present) {

           my $tlb_ecc_bits = calc_num_ecc_bits($tlb_data_sz);
           my $tlb_ecc_data_sz =  $tlb_data_sz + $tlb_ecc_bits;
           push(@ecc_ports, test_invert => "ecc_test_tlb[$tlb_ecc_data_sz-1:0]",);
           
           e_register->adds(
              {out => ["ecc_test_tlb_valid_d1", 1],    in => "ecc_test_tlb_valid & tlb_wr_en",
               enable => "1'b1"},
           );       
           e_assign->adds(
              [["ecc_test_tlb_ready", 1], " ~ecc_test_tlb_valid | ecc_test_tlb_valid_d1"],
           );
       }


       e_assign->adds(
        [["tlb_wrsel", 1],
        "$hw_read_one_bit_err & ~(${wss}_wrctl_tlbacc & ${wss}_valid & ${cs}_tlbmisc_reg_we)"],
       );

       e_register->adds(

         {out => ["tlb_corrected_data_from_decoder", $tlb_data_sz],    in => "tlb_corrected_data_from_decoder_nxt",
          enable => "1'b1"},
         {out => ["tlb_one_bit_err", 1],    in => "${cs}_config_reg_eccen & utlb_fill_match_active_nxt & tlb_one_bit_err_nxt",
          enable => "1'b1"},         
         {out => ["tlb_two_bit_err", 1],    in => "${cs}_ecc_exc_enabled & utlb_fill_match_active_nxt & tlb_two_bit_err_nxt",
          enable => "1'b1"},
         {out => ["tlb_one_two_or_three_bit_err", 1],    in => "${cs}_config_reg_eccen & tlb_one_two_or_three_bit_err_nxt",
          enable => "1'b1"},
          

         {out => ["tlb_rd_line_d1", $tlb_line_sz],   in => "tlb_rd_line", 
          enable => "1'b1"},
          

         {out => ["tlb_re", 1],    in => "(utlb_fill_match_active_nxt & ~W_tlb_rd_operation) & tlb_one_bit_err_nxt",
          enable => "1'b1"},         
         {out => ["tlb_ue", 1],    in => "(utlb_fill_match_active_nxt & ~W_tlb_rd_operation) & tlb_two_bit_err_nxt",
          enable => "1'b1"},
         {out => ["tlb_sw", 1],    in => "W_tlb_rd_operation & tlb_one_two_or_three_bit_err_nxt",
          enable => "1'b1"},
       );
    }

    e_assign->adds(








      [["utlb_flush_all", 1], "(${wss}_wrctl_tlbmisc & ${wss}_valid) $ecc_one_bit_err_flush"], 




      [["utlb_flush_possible", 1], "utlb_flush_all | tlb_wr_en"], 
    );









    e_assign->adds(









      [["uitlb_ignore_want_fill_nxt", 1],
        "uitlb_fill_starting | " .
        "(uitlb_ignore_want_fill & ~(uitlb_fill_done_sync & D_en))"],







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
        "utlb_want_fill_qualified & ~utlb_fill_active & ~utlb_flush_possible"],



      [["utlb_fill_starting_d", 1], "udtlb_want_fill_qualified"],


      [["uitlb_fill_starting", 1], 
        "utlb_fill_starting & ~utlb_fill_starting_d"],
      [["udtlb_fill_starting", 1], 
        "utlb_fill_starting & utlb_fill_starting_d"],






      [["utlb_fill_active_nxt", 1], 
        "utlb_fill_starting | (utlb_fill_active & ~utlb_fill_done)"],
      [["utlb_fill_active_d_nxt", 1], 
        "utlb_fill_starting ? utlb_fill_starting_d : utlb_fill_active_d"],









      [["utlb_fill_match_active_nxt", 1], 
        "utlb_fill_starting_d1 | (utlb_fill_match_active & ~utlb_fill_done)"],
      [["utlb_fill_match_active_d_nxt", 1],
        "utlb_fill_starting_d1 ? utlb_fill_active_d :utlb_fill_match_active_d"],




      [["utlb_fill_vpn", $mmu_addr_vpn_sz], 
        "udtlb_fill_starting ? $udtlb_fill_vpn : 
         uitlb_fill_starting ? $uitlb_fill_vpn : 
                               utlb_fill_vpn_persistent"],


      [["utlb_fill_tag", $tlb_tag_sz],
        "utlb_fill_vpn[$tlb_vpn_tag_msb:$tlb_vpn_tag_lsb]"],
      [["utlb_fill_line", $tlb_line_sz],
        "utlb_fill_vpn[$tlb_vpn_line_msb:$tlb_vpn_line_lsb]"],



      [["utlb_fill_last_way", 1], "utlb_fill_way_cnt[$tlb_way_sz]"],







      [["utlb_fill_tag_match_nxt", 1], 
        "(utlb_fill_tag == tlb_rd_tag) & ~${cs}_tlb_rd_operation"], 




      [["utlb_fill_pid_match_nxt", 1], 
        "(${cs}_tlbmisc_reg_pid == tlb_rd_pid) | tlb_rd_g"],




      [["utlb_fill_match", 1], "utlb_fill_tag_match & utlb_fill_pid_match"],








      [["utlb_fill_done", 1], 
        "(utlb_fill_match_active & (utlb_fill_match | utlb_fill_last_way $ecc_err_match)) |
         utlb_flush_possible"],





      [["uitlb_fill_done_sync_nxt", 1], 
        "(utlb_fill_done & ~utlb_fill_active_d) | 
         (uitlb_fill_done_sync & D_stall)"],








      [["utlb_fill_tlb_miss", 1], "~utlb_fill_match & utlb_fill_last_way"],






      [["uitlb_fill_wr_en", 1], 
        "utlb_fill_match_active & ~utlb_fill_match_active_d & " .
        "(utlb_fill_match | utlb_fill_last_way $ecc_err_match)"],

      [["udtlb_fill_wr_en", 1], 
        "utlb_fill_match_active & utlb_fill_match_active_d & " .
        "(utlb_fill_match | utlb_fill_last_way $ecc_err_match)"],
    );

    e_register->adds(
      {out => ["uitlb_ignore_want_fill", 1], 
       in => "uitlb_ignore_want_fill_nxt", enable => "1'b1"},
      {out => ["udtlb_ignore_want_fill", 1], 
       in => "udtlb_ignore_want_fill_nxt", enable => "1'b1"},

      {out => ["utlb_fill_starting_d1", 1], 
       in => "utlb_fill_starting", enable => "1'b1"},

      {out => ["utlb_fill_active", 1], 
       in => "utlb_fill_active_nxt", enable => "1'b1"},
      {out => ["utlb_fill_active_d", 1], 
       in => "utlb_fill_active_d_nxt", enable => "1'b1"},

      {out => ["utlb_fill_match_active", 1], 
       in => "utlb_fill_match_active_nxt", enable => "1'b1"},
      {out => ["utlb_fill_match_active_d", 1], 
       in => "utlb_fill_match_active_d_nxt", enable => "1'b1"},


      {out => ["utlb_fill_vpn_persistent", $mmu_addr_vpn_sz], 
       in => "utlb_fill_starting_d ? $udtlb_fill_vpn : $uitlb_fill_vpn",
       enable => "utlb_fill_starting"},

      {out => ["utlb_fill_tag_match", 1], 
       in => "utlb_fill_tag_match_nxt", enable => "1'b1"},
      {out => ["utlb_fill_pid_match", 1], 
       in => "utlb_fill_pid_match_nxt", enable => "1'b1"},




      {out => ["utlb_fill_way", $tlb_way_sz], 
       in => "utlb_fill_way + 1", enable => "1'b1"},






      {out => ["utlb_fill_way_cnt", $tlb_way_sz+1],
       in => "utlb_fill_starting ? 0 : utlb_fill_way_cnt+1",
       enable => "1'b1"},

      {out => ["udtlb_fill_done_d1", 1], 
       in => "utlb_fill_done & utlb_fill_active_d", enable => "1'b1"},
      {out => ["udtlb_fill_done_d2", 1], 
       in => "udtlb_fill_done_d1", enable => "1'b1"},

      {out => ["uitlb_fill_done_sync", 1], 
       in => "uitlb_fill_done_sync_nxt", enable => "1'b1"},
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
      { radix => "x", signal => "utlb_fill_vpn" },
      { radix => "x", signal => "utlb_fill_tag" },
      { radix => "x", signal => "utlb_fill_line" },
      { radix => "x", signal => "utlb_fill_last_way" },
      { radix => "x", signal => "utlb_fill_tag_match" },
      { radix => "x", signal => "utlb_fill_pid_match" },
      { radix => "x", signal => "utlb_fill_match" },
      { radix => "x", signal => "utlb_fill_done" },
      { radix => "x", signal => "uitlb_fill_done_sync" },
      { radix => "x", signal => "utlb_fill_tlb_miss" },
      { radix => "x", signal => "uitlb_fill_wr_en" },
      { radix => "x", signal => "udtlb_fill_wr_en" },
    );





    e_signal->adds(

      ["tlb_rd_data", $tlb_data_sz],


      ["tlb_rd_tag", $tlb_tag_sz],
      ["tlb_rd_pid", $tlb_pid_sz],
      ["tlb_rd_g", 1],
      ["tlb_rd_x", 1],
      ["tlb_rd_w", 1],
      ["tlb_rd_r", 1],
      ["tlb_rd_c", 1],
      ["tlb_rd_pfn", $tlb_pfn_sz],
      );


    my $wdata = "${wss}_wrctl_data";

    e_assign->adds(





      [["tlb_rd_way_nxt", $tlb_way_sz],
          "${wss}_tlb_rd_operation ?
             ${wdata}_tlbmisc_reg_way[$tlb_way_sz-1:0] :
             utlb_fill_way"],
      [["tlb_rd_line_nxt", $tlb_line_sz],
          "${wss}_tlb_rd_operation ?
             ${cs}_pteaddr_reg_vpn[$tlb_vpn_line_msb:$tlb_vpn_line_lsb] :
             utlb_fill_line"],
      [["tlb_rd_addr_nxt", $tlb_ptr_sz], "{ tlb_rd_line_nxt, tlb_rd_way_nxt }"],







      [["tlb_wr_en", 1],
        "$ecc_one_bit_err_wr_op
        ${wss}_wrctl_tlbacc & ${wss}_valid & ${cs}_tlbmisc_reg_we"],

      [["tlb_wr_way", $tlb_way_sz], "${cs}_tlbmisc_reg_way"],
      [["tlb_wr_line", $tlb_line_sz],
          "${cs}_pteaddr_reg_vpn[$tlb_vpn_line_msb:$tlb_vpn_line_lsb]"],
      

      [["tlb_wr_addr", $tlb_ptr_sz],
          "$ecc_one_bit_err_get_rd_addr"],

      [["tlb_wr_tag", $tlb_tag_sz],
        "${cs}_pteaddr_reg_vpn[$tlb_vpn_tag_msb:$tlb_vpn_tag_lsb]"],
      [["tlb_wr_pid", $tlb_pid_sz], "${cs}_tlbmisc_reg_pid"],
      [["tlb_wr_g", 1], "${wdata}_tlbacc_reg_g"],
      [["tlb_wr_x", 1], "${wdata}_tlbacc_reg_x"],
      [["tlb_wr_w", 1], "${wdata}_tlbacc_reg_w"],
      [["tlb_wr_r", 1], "${wdata}_tlbacc_reg_r"],
      [["tlb_wr_c", 1], "${wdata}_tlbacc_reg_c"],
      [["tlb_wr_pfn", $tlb_pfn_sz], "${wdata}_tlbacc_reg_pfn"],

      [["tlb_wr_data", $tlb_data_sz],
        "{ tlb_wr_tag, tlb_wr_g, 
           tlb_wr_x, tlb_wr_w, tlb_wr_r, tlb_wr_c, tlb_wr_pfn, tlb_wr_pid }"],


      ["{ tlb_rd_tag, tlb_rd_g,
          tlb_rd_x, tlb_rd_w, tlb_rd_r, tlb_rd_c, tlb_rd_pfn, tlb_rd_pid }", "tlb_rd_data"],


      [["tlb_rd_vpn", $mmu_addr_vpn_sz], "{ tlb_rd_tag, tlb_rd_line }"],
    );




    if (manditory_bool($Opt, "export_large_RAMs")) {
        e_assign->adds(

          [["tlb_ram_write_data", $tlb_data_sz], "tlb_wr_data"],
          ["tlb_ram_write_enable", "tlb_wr_en"],
          [["tlb_ram_write_address", $tlb_ptr_sz], "tlb_wr_addr"],
          [["tlb_ram_read_address", $tlb_ptr_sz], "tlb_rd_addr_nxt"],


          ["tlb_rd_data", ["tlb_ram_read_data", $tlb_data_sz]],
        );
    } else {
        nios_sdp_ram->add({
          name => $Opt->{name} . "_tlb",
          Opt                     => $Opt,
          data_width              => $tlb_data_sz,
          address_width           => $tlb_ptr_sz,
          num_words               => (0x1 << $tlb_ptr_sz),
          read_during_write_mode_mixed_ports => qq("DONT_CARE"),
          ram_block_type          => qq("$Opt->{mmu_ram_type}"),
          ecc_present             => $mmu_ecc_present,
          verification            => $ecc_test_ports_present,
          port_map => {
            clock     => "clk",
    

            data      => "tlb_wr_data",
            wren      => "tlb_wr_en",
            wraddress => "tlb_wr_addr",
    


            rdaddress => "tlb_rd_addr_nxt",
            q         => "tlb_rd_data",
            

            @ecc_ports,
          },
        });
    }

    e_register->adds(

      {out => ["tlb_rd_way", $tlb_way_sz],     in => "tlb_rd_way_nxt", 
       enable => "1'b1"},


      {out => ["tlb_rd_line", $tlb_line_sz],   in => "tlb_rd_line_nxt", 
       enable => "1'b1"},



      {out => ["tlb_rd_way_d1", $tlb_way_sz],   in => "tlb_rd_way", 
       enable => "1'b1"},
      {out => ["tlb_rd_pfn_d1", $tlb_pfn_sz],   in => "tlb_rd_pfn", 
       enable => "1'b1"},
      {out => ["tlb_rd_x_d1", 1],               in => "tlb_rd_x",
       enable => "1'b1"},
      {out => ["tlb_rd_w_d1", 1],               in => "tlb_rd_w",
       enable => "1'b1"},
      {out => ["tlb_rd_r_d1", 1],               in => "tlb_rd_r",
       enable => "1'b1"},
      {out => ["tlb_rd_c_d1", 1],               in => "tlb_rd_c",
       enable => "1'b1"},
    );

    my @tlb_ram_wave_signals = (
      { divider => "TLB RAM" },
      { radix => "x", signal => "${wss}_tlb_rd_operation" },
      { radix => "x", signal => "${cs}_tlb_rd_operation" },
      { radix => "x", signal => "tlb_rd_way_nxt" },
      { radix => "x", signal => "tlb_rd_line_nxt" },
      { radix => "x", signal => "tlb_rd_addr_nxt" },
      { radix => "x", signal => "tlb_rd_vpn" },
      { radix => "x", signal => "tlb_rd_tag" },
      { radix => "x", signal => "tlb_rd_pid" },
      { radix => "x", signal => "tlb_rd_g" },
      { radix => "x", signal => "tlb_rd_x" },
      { radix => "x", signal => "tlb_rd_w" },
      { radix => "x", signal => "tlb_rd_r" },
      { radix => "x", signal => "tlb_rd_c" },
      { radix => "x", signal => "tlb_rd_pfn" },
      { radix => "x", signal => "tlb_wr_en" },
      { radix => "x", signal => "tlb_wr_way" },
      { radix => "x", signal => "tlb_wr_line" },
      { radix => "x", signal => "tlb_wr_addr" },
      { radix => "x", signal => "tlb_wr_tag" },
      { radix => "x", signal => "tlb_wr_pid" },
      { radix => "x", signal => "tlb_wr_g" },
      { radix => "x", signal => "tlb_wr_x" },
      { radix => "x", signal => "tlb_wr_w" },
      { radix => "x", signal => "tlb_wr_r" },
      { radix => "x", signal => "tlb_wr_c" },
      { radix => "x", signal => "tlb_wr_pfn" },
    );

    my @wave_signals = (
      @utlb_fill_wave_signals,
      @tlb_ram_wave_signals
    );

    return \@wave_signals;
}





sub
create_mmu_constants
{
    my $mmu_args = shift;

    my %constants;

    $constants{mmu_addr_user_region} = "1'b0";
    $constants{mmu_addr_kernel_mmu_region} = "2'b10";
    $constants{mmu_addr_kernel_region} = "3'b110";
    $constants{mmu_addr_io_region} = "3'b111";

    $constants{mmu_addr_kernel_region_int} = "6";     # decimal version

    $constants{mmu_addr_bypass_tlb} = "2'b11";
    $constants{mmu_addr_bypass_tlb_cacheable} = "1'b0";





    $constants{mmu_addr_io_region_vpn} = "20'he0000";




    $constants{tlb_min_pid_sz} = 8;
    $constants{tlb_max_pid_sz} = 14;
    $constants{tlb_min_ways} = 8;
    $constants{tlb_max_ways} = 16;
    $constants{tlb_min_ptr_sz} = 7;
    $constants{tlb_max_ptr_sz} = 10;
    $constants{tlb_max_entries} = 1 << $constants{tlb_max_ptr_sz};
    $constants{tlb_max_lines} = 
      $constants{tlb_max_entries} / $constants{tlb_min_ways};


    $constants{uitlb_index_sz} = 
      count2sz(manditory_int($mmu_args, "uitlb_num_entries"));
    $constants{udtlb_index_sz} = 
      count2sz(manditory_int($mmu_args, "udtlb_num_entries"));

    return \%constants;
}

sub
create_mmu_addr_bit_fields
{
    my $bit_fields = [];

    add_bit_field($bit_fields, { name => "vpn", sz => 20, lsb => 12 });
    add_bit_field($bit_fields, { name => "pfn", sz => 20, lsb => 12 });
    add_bit_field($bit_fields, { name => "page_offset", sz => 12, lsb => 0 });
    add_bit_field($bit_fields, { name => "user_region", sz => 1, lsb => 31 });
    add_bit_field($bit_fields, 
      { name => "kernel_mmu_region", sz => 2, lsb => 30 });
    add_bit_field($bit_fields, { name => "kernel_region", sz => 3, lsb => 29 });
    add_bit_field($bit_fields, { name => "io_region", sz => 3, lsb => 29 });
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
          "MMU_ADDR_", "Addr"))) {
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
$define USER_REGION_MIN_VADDR       0x00000000
$define USER_REGION_MAX_VADDR       0x7fffffff
$define KERNEL_MMU_REGION_MIN_VADDR 0x80000000
$define KERNEL_MMU_REGION_MAX_VADDR 0xbfffffff
$define KERNEL_REGION_MIN_VADDR     0xc0000000
$define KERNEL_REGION_MAX_VADDR     0xdfffffff
$define IO_REGION_MIN_VADDR         0xe0000000
$define IO_REGION_MAX_VADDR         0xffffffff

$define MMU_PAGE_SIZE (0x1 << (MMU_ADDR_PAGE_OFFSET_SZ))

$define isMmuUserRegion(Vaddr)          \\
    (GET_MMU_ADDR_USER_REGION(Vaddr) == MMU_ADDR_USER_REGION)
$define isMmuKernelMmuRegion(Vaddr)     \\
    (GET_MMU_ADDR_KERNEL_MMU_REGION(Vaddr) == MMU_ADDR_KERNEL_MMU_REGION)
$define isMmuKernelRegion(Vaddr)        \\
    (GET_MMU_ADDR_KERNEL_REGION(Vaddr) == MMU_ADDR_KERNEL_REGION)
$define isMmuIORegion(Vaddr)            \\
    (GET_MMU_ADDR_IO_REGION(Vaddr) == MMU_ADDR_IO_REGION)

/* Does this virtual address bypass the TLB? */
$define vaddrBypassTlb(Vaddr)                \\
    (GET_MMU_ADDR_BYPASS_TLB(Vaddr) == MMU_ADDR_BYPASS_TLB)

/* If TLB is bypassed, is the address cacheable or uncachable. */
$define vaddrBypassTlbCacheable(Vaddr)       \\
    (GET_MMU_ADDR_BYPASS_TLB_CACHEABLE(Vaddr) == MMU_ADDR_BYPASS_TLB_CACHEABLE)

/*
 * Compute physical address for regions that bypass the TLB.
 * Just need to clear some top bits.
 */
$define bypassTlbVaddrToPaddr(Vaddr)    \\
    ((Vaddr) & (MMU_ADDR_BYPASS_TLB_PADDR_MASK << MMU_ADDR_BYPASS_TLB_PADDR_LSB))

/* 
 * Will the physical address fit in the Kernel/IO region virtual address space?
 */
$define fitsInKernelRegion(Paddr)       \\
    (GET_MMU_ADDR_KERNEL_REGION(Paddr) == 0)
$define fitsInIORegion(Paddr)           \\
    (GET_MMU_ADDR_IO_REGION(Paddr) == 0)

/* Convert a physical address to a Kernel/IO region virtual address. */
$define paddrToKernelRegionVaddr(Paddr) \\
    ((Paddr) | (MMU_ADDR_KERNEL_REGION << MMU_ADDR_KERNEL_REGION_LSB))
$define paddrToIORegionVaddr(Paddr)     \\
    ((Paddr) | (MMU_ADDR_IO_REGION << MMU_ADDR_IO_REGION_LSB))

/*
 * Convert a virtual address to a Kernel/IO region virtual address.
 * Uses bypassTlbVaddrToPaddr to clear top bits.
 */
$define vaddrToKernelRegionVaddr(Vaddr) \\
    paddrToKernelRegionVaddr(bypassTlbVaddrToPaddr(Vaddr))
$define vaddrToIORegionVaddr(Vaddr) \\
    paddrToIORegionVaddr(bypassTlbVaddrToPaddr(Vaddr))

/* Convert between VPN/PFN and virtual/physical addresses. */
$define vpnToVaddr(Vpn) ((Vpn) << MMU_ADDR_VPN_LSB)
$define pfnToPaddr(Pfn) ((Pfn) << MMU_ADDR_PFN_LSB)
$define vaddrToVpn(Vaddr) GET_MMU_ADDR_VPN(Vaddr)
$define paddrToPfn(Paddr) GET_MMU_ADDR_PFN(Paddr)

/* Bitwise OR with a KERNEL region address to make it an IO region address */
$define KERNEL_TO_IO_REGION 0x20000000
EOM

    push(@$h_lines, split(/\n/, $macros_str));
}

sub
eval_cmd
{
    my $cmd = shift;

    eval($cmd);
    if ($@) {
        &$error("nios2_mmu.pm: eval($cmd) returns '$@'\n");
    }
}

1;

