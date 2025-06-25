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






















package nios2_control_regs;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $status_reg
    $estatus_reg
    $bstatus_reg
    $ienable_reg
    $ipending_reg
    $cpuid_reg
    $sim_reg
    $exception_reg
    $pteaddr_reg
    $tlbacc_reg
    $tlbmisc_reg
    $eccinj_reg
    $badaddr_reg
    $config_reg
    $mpubase_reg
    $mpuacc_reg

    $status_reg_regnum $status_reg_sz $status_reg_lsb $status_reg_msb
    $estatus_reg_regnum $estatus_reg_sz $estatus_reg_lsb $estatus_reg_msb
    $bstatus_reg_regnum $bstatus_reg_sz $bstatus_reg_lsb $bstatus_reg_msb
    $ienable_reg_regnum $ienable_reg_sz $ienable_reg_lsb $ienable_reg_msb
    $ipending_reg_regnum $ipending_reg_sz $ipending_reg_lsb $ipending_reg_msb
    $cpuid_reg_regnum $cpuid_reg_sz $cpuid_reg_lsb $cpuid_reg_msb
    $sim_reg_regnum $sim_reg_sz $sim_reg_lsb $sim_reg_msb
    $exception_reg_regnum $exception_reg_sz $exception_reg_lsb 
      $exception_reg_msb
    $pteaddr_reg_regnum $pteaddr_reg_sz $pteaddr_reg_lsb $pteaddr_reg_msb
    $tlbacc_reg_regnum $tlbacc_reg_sz $tlbacc_reg_lsb $tlbacc_reg_msb
    $tlbmisc_reg_regnum $tlbmisc_reg_sz $tlbmisc_reg_lsb $tlbmisc_reg_msb
    $eccinj_reg_regnum $eccinj_reg_sz $eccinj_reg_lsb $eccinj_reg_msb
    $badaddr_reg_regnum $badaddr_reg_sz $badaddr_reg_lsb $badaddr_reg_msb
    $config_reg_regnum $config_reg_sz $config_reg_lsb $config_reg_msb
    $mpubase_reg_regnum $mpubase_reg_sz $mpubase_reg_lsb $mpubase_reg_msb
    $mpuacc_reg_regnum $mpuacc_reg_sz $mpuacc_reg_lsb $mpuacc_reg_msb

    $status_reg_pie $status_reg_pie_sz $status_reg_pie_lsb $status_reg_pie_msb
    $status_reg_u $status_reg_u_sz $status_reg_u_lsb $status_reg_u_msb
    $status_reg_eh $status_reg_eh_sz $status_reg_eh_lsb $status_reg_eh_msb
    $status_reg_ih $status_reg_ih_sz $status_reg_ih_lsb $status_reg_ih_msb
    $status_reg_il $status_reg_il_sz $status_reg_il_lsb $status_reg_il_msb
    $status_reg_crs $status_reg_crs_sz $status_reg_crs_lsb $status_reg_crs_msb
    $status_reg_prs $status_reg_prs_sz $status_reg_prs_lsb $status_reg_prs_msb
    $status_reg_nmi $status_reg_nmi_sz $status_reg_nmi_lsb $status_reg_nmi_msb
    $status_reg_rsie $status_reg_rsie_sz $status_reg_rsie_lsb 
      $status_reg_rsie_msb
    $estatus_reg_pie $estatus_reg_pie_sz $estatus_reg_pie_lsb 
      $estatus_reg_pie_msb
    $estatus_reg_u $estatus_reg_u_sz $estatus_reg_u_lsb $estatus_reg_u_msb
    $estatus_reg_eh $estatus_reg_eh_sz $estatus_reg_eh_lsb $estatus_reg_eh_msb
    $estatus_reg_ih $estatus_reg_ih_sz $estatus_reg_ih_lsb $estatus_reg_ih_msb
    $estatus_reg_il $estatus_reg_il_sz $estatus_reg_il_lsb 
      $estatus_reg_il_msb
    $estatus_reg_crs $estatus_reg_crs_sz $estatus_reg_crs_lsb 
      $estatus_reg_crs_msb
    $estatus_reg_prs $estatus_reg_prs_sz $estatus_reg_prs_lsb 
      $estatus_reg_prs_msb
    $estatus_reg_nmi $estatus_reg_nmi_sz $estatus_reg_nmi_lsb 
      $estatus_reg_nmi_msb
    $estatus_reg_rsie $estatus_reg_rsie_sz $estatus_reg_rsie_lsb 
      $estatus_reg_rsie_msb
    $bstatus_reg_pie $bstatus_reg_pie_sz $bstatus_reg_pie_lsb 
      $bstatus_reg_pie_msb
    $bstatus_reg_u $bstatus_reg_u_sz $bstatus_reg_u_lsb $bstatus_reg_u_msb
    $bstatus_reg_eh $bstatus_reg_eh_sz $bstatus_reg_eh_lsb $bstatus_reg_eh_msb
    $bstatus_reg_ih $bstatus_reg_ih_sz $bstatus_reg_ih_lsb $bstatus_reg_ih_msb
    $bstatus_reg_il $bstatus_reg_il_sz $bstatus_reg_il_lsb 
      $bstatus_reg_il_msb
    $bstatus_reg_crs $bstatus_reg_crs_sz $bstatus_reg_crs_lsb 
      $bstatus_reg_crs_msb
    $bstatus_reg_prs $bstatus_reg_prs_sz $bstatus_reg_prs_lsb 
      $bstatus_reg_prs_msb
    $bstatus_reg_nmi $bstatus_reg_nmi_sz $bstatus_reg_nmi_lsb 
      $bstatus_reg_nmi_msb
    $bstatus_reg_rsie $bstatus_reg_rsie_sz $bstatus_reg_rsie_lsb 
      $bstatus_reg_rsie_msb
    $cpuid_reg_cpuid $cpuid_reg_cpuid_sz $cpuid_reg_cpuid_lsb 
      $cpuid_reg_cpuid_msb
    $sim_reg_stop $sim_reg_stop_sz $sim_reg_stop_lsb $sim_reg_stop_msb
    $sim_reg_perf_cnt_en $sim_reg_perf_cnt_en_sz $sim_reg_perf_cnt_en_lsb 
      $sim_reg_perf_cnt_en_msb
    $sim_reg_perf_cnt_clr $sim_reg_perf_cnt_clr_sz $sim_reg_perf_cnt_clr_lsb 
      $sim_reg_perf_cnt_clr_msb
    $sim_reg_inst_trace $sim_reg_inst_trace_sz $sim_reg_inst_trace_lsb 
      $sim_reg_inst_trace_msb
    $sim_reg_mem_traffic $sim_reg_mem_traffic_sz $sim_reg_mem_traffic_lsb 
      $sim_reg_mem_traffic_msb
    $sim_reg_show_icache $sim_reg_show_icache_sz $sim_reg_show_icache_lsb 
      $sim_reg_show_icache_msb
    $sim_reg_show_dcache $sim_reg_show_dcache_sz $sim_reg_show_dcache_lsb 
      $sim_reg_show_dcache_msb
    $sim_reg_show_tlb $sim_reg_show_tlb_sz $sim_reg_show_tlb_lsb 
      $sim_reg_show_tlb_msb
    $sim_reg_show_mmu_regs $sim_reg_show_mmu_regs_sz $sim_reg_show_mmu_regs_lsb
      $sim_reg_show_mmu_regs_msb
    $exception_reg_mea $exception_reg_mea_sz $exception_reg_mea_lsb 
      $exception_reg_mea_msb
    $exception_reg_mee $exception_reg_mee_sz $exception_reg_mee_lsb 
      $exception_reg_mee_msb
    $exception_reg_cause $exception_reg_cause_sz $exception_reg_cause_lsb 
      $exception_reg_cause_msb
    $exception_reg_eccftl $exception_reg_eccftl_sz $exception_reg_eccftl_lsb 
      $exception_reg_eccftl_msb
    $pteaddr_reg_vpn $pteaddr_reg_vpn_sz $pteaddr_reg_vpn_lsb 
      $pteaddr_reg_vpn_msb
    $pteaddr_reg_ptbase $pteaddr_reg_ptbase_sz $pteaddr_reg_ptbase_lsb 
      $pteaddr_reg_ptbase_msb
    $tlbacc_reg_pfn $tlbacc_reg_pfn_sz $tlbacc_reg_pfn_lsb $tlbacc_reg_pfn_msb
    $tlbacc_reg_g $tlbacc_reg_g_sz $tlbacc_reg_g_lsb $tlbacc_reg_g_msb
    $tlbacc_reg_x $tlbacc_reg_x_sz $tlbacc_reg_x_lsb $tlbacc_reg_x_msb
    $tlbacc_reg_w $tlbacc_reg_w_sz $tlbacc_reg_w_lsb $tlbacc_reg_w_msb
    $tlbacc_reg_r $tlbacc_reg_r_sz $tlbacc_reg_r_lsb $tlbacc_reg_r_msb
    $tlbacc_reg_c $tlbacc_reg_c_sz $tlbacc_reg_c_lsb $tlbacc_reg_c_msb
    $tlbacc_reg_ig $tlbacc_reg_ig_sz $tlbacc_reg_ig_lsb $tlbacc_reg_ig_msb
    $tlbmisc_reg_d $tlbmisc_reg_d_sz $tlbmisc_reg_d_lsb $tlbmisc_reg_d_msb
    $tlbmisc_reg_perm $tlbmisc_reg_perm_sz $tlbmisc_reg_perm_lsb 
      $tlbmisc_reg_perm_msb
    $tlbmisc_reg_bad $tlbmisc_reg_bad_sz $tlbmisc_reg_bad_lsb 
      $tlbmisc_reg_bad_msb
    $tlbmisc_reg_dbl $tlbmisc_reg_dbl_sz $tlbmisc_reg_dbl_lsb 
      $tlbmisc_reg_dbl_msb
    $tlbmisc_reg_pid $tlbmisc_reg_pid_sz $tlbmisc_reg_pid_lsb 
      $tlbmisc_reg_pid_msb
    $tlbmisc_reg_we $tlbmisc_reg_we_sz $tlbmisc_reg_we_lsb $tlbmisc_reg_we_msb
    $tlbmisc_reg_rd $tlbmisc_reg_rd_sz $tlbmisc_reg_rd_lsb $tlbmisc_reg_rd_msb
    $tlbmisc_reg_way $tlbmisc_reg_way_sz $tlbmisc_reg_way_lsb 
      $tlbmisc_reg_way_msb
    $tlbmisc_reg_ee $tlbmisc_reg_ee_sz $tlbmisc_reg_ee_lsb $tlbmisc_reg_ee_msb

    $eccinj_reg_rf $eccinj_reg_rf_sz $eccinj_reg_rf_lsb $eccinj_reg_rf_msb
    $eccinj_reg_ictag $eccinj_reg_ictag_sz $eccinj_reg_ictag_lsb $eccinj_reg_ictag_msb
    $eccinj_reg_icdat $eccinj_reg_icdat_sz $eccinj_reg_icdat_lsb $eccinj_reg_icdat_msb
    $eccinj_reg_dctag $eccinj_reg_dctag_sz $eccinj_reg_dctag_lsb $eccinj_reg_dctag_msb
    $eccinj_reg_dcdat $eccinj_reg_dcdat_sz $eccinj_reg_dcdat_lsb $eccinj_reg_dcdat_msb
    $eccinj_reg_dtcm0 $eccinj_reg_dtcm0_sz $eccinj_reg_dtcm0_lsb $eccinj_reg_dtcm0_msb
    $eccinj_reg_dtcm1 $eccinj_reg_dtcm1_sz $eccinj_reg_dtcm1_lsb $eccinj_reg_dtcm1_msb
    $eccinj_reg_dtcm2 $eccinj_reg_dtcm2_sz $eccinj_reg_dtcm2_lsb $eccinj_reg_dtcm2_msb
    $eccinj_reg_dtcm3 $eccinj_reg_dtcm3_sz $eccinj_reg_dtcm3_lsb $eccinj_reg_dtcm3_msb
    $eccinj_reg_tlb $eccinj_reg_tlb_sz $eccinj_reg_tlb_lsb $eccinj_reg_tlb_msb

    $badaddr_reg_baddr $badaddr_reg_baddr_sz $badaddr_reg_baddr_lsb 
      $badaddr_reg_baddr_msb
    $config_reg_pe $config_reg_pe_sz $config_reg_pe_lsb $config_reg_pe_msb
    $config_reg_ani $config_reg_ani_sz $config_reg_ani_lsb $config_reg_ani_msb
    $config_reg_eccen $config_reg_eccen_sz $config_reg_eccen_lsb $config_reg_eccen_msb
    $config_reg_eccexc $config_reg_eccexc_sz $config_reg_eccexc_lsb $config_reg_eccexc_msb

    $mpubase_reg_d $mpubase_reg_d_sz $mpubase_reg_d_lsb $mpubase_reg_d_msb
    $mpubase_reg_index $mpubase_reg_index $mpubase_reg_index_sz 
      $mpubase_reg_index_lsb $mpubase_reg_index_msb
    $mpubase_reg_base $mpubase_reg_base $mpubase_reg_base_sz 
      $mpubase_reg_base_lsb $mpubase_reg_base_msb
    $mpuacc_reg_wr $mpuacc_reg_wr_sz $mpuacc_reg_wr_lsb $mpuacc_reg_wr_msb
    $mpuacc_reg_rd $mpuacc_reg_rd_sz $mpuacc_reg_rd_lsb $mpuacc_reg_rd_msb
    $mpuacc_reg_perm $mpuacc_reg_perm_sz $mpuacc_reg_perm_lsb 
      $mpuacc_reg_perm_msb
    $mpuacc_reg_c $mpuacc_reg_c_sz $mpuacc_reg_c_lsb $mpuacc_reg_c_msb
    $mpuacc_reg_mask $mpuacc_reg_mask_sz $mpuacc_reg_mask_lsb 
      $mpuacc_reg_mask_msb
    $mpuacc_reg_limit $mpuacc_reg_limit_sz $mpuacc_reg_limit_lsb 
      $mpuacc_reg_limit_msb
);

use cpu_utils;
use cpu_control_reg;
use strict;














our $status_reg;
our $estatus_reg;
our $bstatus_reg;
our $ienable_reg;
our $ipending_reg;
our $cpuid_reg;
our $sim_reg;
our $exception_reg;
our $pteaddr_reg;
our $tlbacc_reg;
our $tlbmisc_reg;
our $eccinj_reg;
our $badaddr_reg;
our $config_reg;
our $mpubase_reg;
our $mpuacc_reg;



our $status_reg_regnum;
our $estatus_reg_regnum;
our $bstatus_reg_regnum;
our $ienable_reg_regnum;
our $ipending_reg_regnum;
our $cpuid_reg_regnum;
our $sim_reg_regnum;
our $exception_reg_regnum;
our $pteaddr_reg_regnum;
our $tlbacc_reg_regnum;
our $tlbmisc_reg_regnum;
our $eccinj_reg_regnum;
our $badaddr_reg_regnum;
our $config_reg_regnum;
our $mpubase_reg_regnum;
our $mpuacc_reg_regnum;



our $status_reg_sz;
our $status_reg_lsb; 
our $status_reg_msb;
our $estatus_reg_sz;
our $estatus_reg_lsb;
our $estatus_reg_msb;
our $bstatus_reg_sz;
our $bstatus_reg_lsb;
our $bstatus_reg_msb;
our $ienable_reg_sz;
our $ienable_reg_lsb;
our $ienable_reg_msb;
our $ipending_reg_sz;
our $ipending_reg_lsb;
our $ipending_reg_msb;
our $cpuid_reg_sz;
our $cpuid_reg_lsb;
our $cpuid_reg_msb;
our $sim_reg_sz;
our $sim_reg_lsb;
our $sim_reg_msb;
our $exception_reg_sz;
our $exception_reg_lsb;
our $exception_reg_msb;
our $pteaddr_reg_sz;
our $pteaddr_reg_lsb;
our $pteaddr_reg_msb;
our $tlbacc_reg_sz;
our $tlbacc_reg_lsb;
our $tlbacc_reg_msb;
our $tlbmisc_reg_sz;
our $tlbmisc_reg_lsb;
our $tlbmisc_reg_msb;
our $eccinj_reg_sz;
our $eccinj_reg_lsb;
our $eccinj_reg_msb;
our $badaddr_reg_sz;
our $badaddr_reg_lsb;
our $badaddr_reg_msb;
our $config_reg_sz;
our $config_reg_lsb;
our $config_reg_msb;
our $mpubase_reg_sz;
our $mpubase_reg_lsb;
our $mpubase_reg_msb;
our $mpuacc_reg_sz;
our $mpuacc_reg_lsb;
our $mpuacc_reg_msb;



our $status_reg_pie;
our $status_reg_u;
our $status_reg_eh;
our $status_reg_ih;
our $status_reg_il;
our $status_reg_crs;
our $status_reg_prs;
our $status_reg_nmi;
our $status_reg_rsie;
our $estatus_reg_pie;
our $estatus_reg_u;
our $estatus_reg_eh;
our $estatus_reg_ih;
our $estatus_reg_il;
our $estatus_reg_crs;
our $estatus_reg_prs;
our $estatus_reg_nmi;
our $estatus_reg_rsie;
our $bstatus_reg_pie;
our $bstatus_reg_u;
our $bstatus_reg_eh;
our $bstatus_reg_ih;
our $bstatus_reg_il;
our $bstatus_reg_crs;
our $bstatus_reg_prs;
our $bstatus_reg_nmi;
our $bstatus_reg_rsie;
our $cpuid_reg_cpuid;
our $sim_reg_stop;
our $sim_reg_perf_cnt_en;
our $sim_reg_perf_cnt_clr;
our $sim_reg_inst_trace;
our $sim_reg_mem_traffic;
our $sim_reg_show_icache;
our $sim_reg_show_dcache;
our $sim_reg_show_tlb;
our $sim_reg_show_mmu_regs;
our $exception_reg_mea;
our $exception_reg_mee;
our $exception_reg_cause;
our $exception_reg_eccftl;
our $pteaddr_reg_vpn;
our $pteaddr_reg_ptbase;
our $tlbacc_reg_pfn;
our $tlbacc_reg_g;
our $tlbacc_reg_x;
our $tlbacc_reg_w;
our $tlbacc_reg_r;
our $tlbacc_reg_c;
our $tlbacc_reg_ig;
our $tlbmisc_reg_d;
our $tlbmisc_reg_perm;
our $tlbmisc_reg_bad;
our $tlbmisc_reg_dbl;
our $tlbmisc_reg_pid;
our $tlbmisc_reg_we;
our $tlbmisc_reg_rd;
our $tlbmisc_reg_ee;
our $tlbmisc_reg_way;
our $eccinj_reg_rf;
our $eccinj_reg_ictag;
our $eccinj_reg_icdat;
our $eccinj_reg_dctag;
our $eccinj_reg_dcdat;
our $eccinj_reg_dtcm0;
our $eccinj_reg_dtcm1;
our $eccinj_reg_dtcm2;
our $eccinj_reg_dtcm3;
our $eccinj_reg_tlb;
our $badaddr_reg_baddr;
our $config_reg_pe;
our $config_reg_ani;
our $config_reg_eccen;
our $config_reg_eccexc;
our $mpubase_reg_d;
our $mpubase_reg_index;
our $mpubase_reg_base;
our $mpuacc_reg_wr;
our $mpuacc_reg_rd;
our $mpuacc_reg_perm;
our $mpuacc_reg_c;
our $mpuacc_reg_mask;
our $mpuacc_reg_limit;



our $status_reg_pie_sz;
our $status_reg_pie_lsb;
our $status_reg_pie_msb;
our $status_reg_u_sz;
our $status_reg_u_lsb;
our $status_reg_u_msb;
our $status_reg_eh_sz;
our $status_reg_eh_lsb;
our $status_reg_eh_msb;
our $status_reg_ih_sz;
our $status_reg_ih_lsb;
our $status_reg_ih_msb;
our $status_reg_il_sz;
our $status_reg_il_lsb;
our $status_reg_il_msb;
our $status_reg_crs_sz;
our $status_reg_crs_lsb;
our $status_reg_crs_msb;
our $status_reg_prs_sz;
our $status_reg_prs_lsb;
our $status_reg_prs_msb;
our $status_reg_nmi_sz;
our $status_reg_nmi_lsb;
our $status_reg_nmi_msb;
our $status_reg_rsie_sz;
our $status_reg_rsie_lsb;
our $status_reg_rsie_msb;
our $estatus_reg_pie_sz;
our $estatus_reg_pie_lsb;
our $estatus_reg_pie_msb;
our $estatus_reg_u_sz;
our $estatus_reg_u_lsb;
our $estatus_reg_u_msb;
our $estatus_reg_eh_sz;
our $estatus_reg_eh_lsb;
our $estatus_reg_eh_msb;
our $estatus_reg_ih_sz;
our $estatus_reg_ih_lsb;
our $estatus_reg_ih_msb;
our $estatus_reg_il_sz;
our $estatus_reg_il_lsb;
our $estatus_reg_il_msb;
our $estatus_reg_nmi_sz;
our $estatus_reg_nmi_lsb;
our $estatus_reg_nmi_msb;
our $estatus_reg_rsie_sz;
our $estatus_reg_rsie_lsb;
our $estatus_reg_rsie_msb;
our $estatus_reg_crs_sz;
our $estatus_reg_crs_lsb;
our $estatus_reg_crs_msb;
our $estatus_reg_prs_sz;
our $estatus_reg_prs_lsb;
our $estatus_reg_prs_msb;
our $bstatus_reg_pie_sz;
our $bstatus_reg_pie_lsb;
our $bstatus_reg_pie_msb;
our $bstatus_reg_u_sz;
our $bstatus_reg_u_lsb;
our $bstatus_reg_u_msb;
our $bstatus_reg_eh_sz;
our $bstatus_reg_eh_lsb;
our $bstatus_reg_eh_msb;
our $bstatus_reg_ih_sz;
our $bstatus_reg_ih_lsb;
our $bstatus_reg_ih_msb;
our $bstatus_reg_il_sz;
our $bstatus_reg_il_lsb;
our $bstatus_reg_il_msb;
our $bstatus_reg_crs_sz;
our $bstatus_reg_crs_lsb;
our $bstatus_reg_crs_msb;
our $bstatus_reg_prs_sz;
our $bstatus_reg_prs_lsb;
our $bstatus_reg_prs_msb;
our $bstatus_reg_nmi_sz;
our $bstatus_reg_nmi_lsb;
our $bstatus_reg_nmi_msb;
our $bstatus_reg_rsie_sz;
our $bstatus_reg_rsie_lsb;
our $bstatus_reg_rsie_msb;
our $cpuid_reg_cpuid_sz;
our $cpuid_reg_cpuid_lsb;
our $cpuid_reg_cpuid_msb;
our $sim_reg_stop_sz;
our $sim_reg_stop_lsb;
our $sim_reg_stop_msb;
our $sim_reg_show_tlb_sz;
our $sim_reg_show_tlb_lsb;
our $sim_reg_show_tlb_msb;
our $sim_reg_show_mmu_regs_sz;
our $sim_reg_show_mmu_regs_lsb;
our $sim_reg_show_mmu_regs_msb;
our $sim_reg_perf_cnt_en_sz;
our $sim_reg_perf_cnt_en_lsb;
our $sim_reg_perf_cnt_en_msb;
our $sim_reg_perf_cnt_clr_sz;
our $sim_reg_perf_cnt_clr_lsb;
our $sim_reg_perf_cnt_clr_msb;
our $sim_reg_inst_trace_sz;
our $sim_reg_inst_trace_lsb;
our $sim_reg_inst_trace_msb;
our $sim_reg_mem_traffic_sz;
our $sim_reg_mem_traffic_lsb;
our $sim_reg_mem_traffic_msb;
our $sim_reg_show_icache_sz;
our $sim_reg_show_icache_lsb;
our $sim_reg_show_icache_msb;
our $sim_reg_show_dcache_sz;
our $sim_reg_show_dcache_lsb;
our $sim_reg_show_dcache_msb;
our $sim_reg_show_tlb_sz;
our $sim_reg_show_tlb_lsb;
our $sim_reg_show_tlb_msb;
our $sim_reg_show_mmu_regs_sz;
our $sim_reg_show_mmu_regs_lsb;
our $sim_reg_show_mmu_regs_msb;
our $exception_reg_mea_sz;
our $exception_reg_mea_lsb;
our $exception_reg_mea_msb;
our $exception_reg_mee_sz;
our $exception_reg_mee_lsb;
our $exception_reg_mee_msb;
our $exception_reg_cause_sz;
our $exception_reg_cause_lsb;
our $exception_reg_cause_msb;
our $exception_reg_eccftl_sz;
our $exception_reg_eccftl_lsb;
our $exception_reg_eccftl_msb;
our $pteaddr_reg_vpn_sz;
our $pteaddr_reg_vpn_lsb;
our $pteaddr_reg_vpn_msb;
our $pteaddr_reg_ptbase_sz;
our $pteaddr_reg_ptbase_lsb;
our $pteaddr_reg_ptbase_msb;
our $tlbacc_reg_pfn_sz;
our $tlbacc_reg_pfn_lsb;
our $tlbacc_reg_pfn_msb;
our $tlbacc_reg_g_sz;
our $tlbacc_reg_g_lsb;
our $tlbacc_reg_g_msb;
our $tlbacc_reg_x_sz;
our $tlbacc_reg_x_lsb;
our $tlbacc_reg_x_msb;
our $tlbacc_reg_w_sz;
our $tlbacc_reg_w_lsb;
our $tlbacc_reg_w_msb;
our $tlbacc_reg_r_sz;
our $tlbacc_reg_r_lsb;
our $tlbacc_reg_r_msb;
our $tlbacc_reg_c_sz;
our $tlbacc_reg_c_lsb;
our $tlbacc_reg_c_msb;
our $tlbacc_reg_ig_sz;
our $tlbacc_reg_ig_lsb;
our $tlbacc_reg_ig_msb;
our $tlbmisc_reg_d_sz;
our $tlbmisc_reg_d_lsb;
our $tlbmisc_reg_d_msb;
our $tlbmisc_reg_perm_sz;
our $tlbmisc_reg_perm_lsb;
our $tlbmisc_reg_perm_msb;
our $tlbmisc_reg_bad_sz;
our $tlbmisc_reg_bad_lsb;
our $tlbmisc_reg_bad_msb;
our $tlbmisc_reg_dbl_sz;
our $tlbmisc_reg_dbl_lsb;
our $tlbmisc_reg_dbl_msb;
our $tlbmisc_reg_pid_sz;
our $tlbmisc_reg_pid_lsb;
our $tlbmisc_reg_pid_msb;
our $tlbmisc_reg_we_sz;
our $tlbmisc_reg_we_lsb;
our $tlbmisc_reg_we_msb;
our $tlbmisc_reg_rd_sz;
our $tlbmisc_reg_rd_lsb;
our $tlbmisc_reg_rd_msb;
our $tlbmisc_reg_ee_sz;
our $tlbmisc_reg_ee_lsb;
our $tlbmisc_reg_ee_msb;
our $tlbmisc_reg_way_sz;
our $tlbmisc_reg_way_lsb;
our $tlbmisc_reg_way_msb;
our $eccinj_reg_rf_sz;
our $eccinj_reg_rf_lsb;
our $eccinj_reg_rf_msb;
our $eccinj_reg_ictag_sz;
our $eccinj_reg_ictag_lsb;
our $eccinj_reg_ictag_msb;
our $eccinj_reg_icdat_sz;
our $eccinj_reg_icdat_lsb;
our $eccinj_reg_icdat_msb;
our $eccinj_reg_dctag_sz;
our $eccinj_reg_dctag_lsb;
our $eccinj_reg_dctag_msb;
our $eccinj_reg_dcdat_sz;
our $eccinj_reg_dcdat_lsb;
our $eccinj_reg_dcdat_msb;
our $eccinj_reg_tlb_sz;
our $eccinj_reg_tlb_lsb;
our $eccinj_reg_tlb_msb;
our $eccinj_reg_dtcm0_sz;
our $eccinj_reg_dtcm0_lsb;
our $eccinj_reg_dtcm0_msb;
our $eccinj_reg_dtcm1_sz;
our $eccinj_reg_dtcm1_lsb;
our $eccinj_reg_dtcm1_msb;
our $eccinj_reg_dtcm2_sz;
our $eccinj_reg_dtcm2_lsb;
our $eccinj_reg_dtcm2_msb;
our $eccinj_reg_dtcm3_sz;
our $eccinj_reg_dtcm3_lsb;
our $eccinj_reg_dtcm3_msb;
our $badaddr_reg_baddr_sz;
our $badaddr_reg_baddr_lsb;
our $badaddr_reg_baddr_msb;
our $config_reg_pe_sz;
our $config_reg_pe_lsb;
our $config_reg_pe_msb;
our $config_reg_ani_sz;
our $config_reg_ani_lsb;
our $config_reg_ani_msb;
our $config_reg_eccen_sz;
our $config_reg_eccen_lsb;
our $config_reg_eccen_msb;
our $config_reg_eccexc_sz;
our $config_reg_eccexc_lsb;
our $config_reg_eccexc_msb;
our $mpubase_reg_d_sz;
our $mpubase_reg_d_lsb;
our $mpubase_reg_d_msb;
our $mpubase_reg_index_sz;
our $mpubase_reg_index_lsb;
our $mpubase_reg_index_msb;
our $mpubase_reg_base_sz;
our $mpubase_reg_base_lsb;
our $mpubase_reg_base_msb;
our $mpuacc_reg_wr_sz;
our $mpuacc_reg_wr_lsb;
our $mpuacc_reg_wr_msb;
our $mpuacc_reg_rd_sz;
our $mpuacc_reg_rd_lsb;
our $mpuacc_reg_rd_msb;
our $mpuacc_reg_perm_sz;
our $mpuacc_reg_perm_lsb;
our $mpuacc_reg_perm_msb;
our $mpuacc_reg_c_sz;
our $mpuacc_reg_c_lsb;
our $mpuacc_reg_c_msb;
our $mpuacc_reg_mask_sz;
our $mpuacc_reg_mask_lsb;
our $mpuacc_reg_mask_msb;
our $mpuacc_reg_limit_sz;
our $mpuacc_reg_limit_lsb;
our $mpuacc_reg_limit_msb;
                     






sub
create_control_reg_args_from_infos
{
    my $nios2_isa_info = shift;
    my $interrupt_info = shift;
    my $exception_info = shift;
    my $misc_info = shift;
    my $ecc_info = shift;
    my $mmu_info = shift;
    my $mpu_info = shift;
    my $elaborated_mpu_info = shift;
    my $test_info = shift;
    my $elaborated_test_info = shift;
    my $elaborated_avalon_master_info = shift;
    my $icache_info = shift;
    my $dcache_info = shift;

    my $control_reg_args = {
      interrupt_sz => 
        manditory_int(
          manditory_hash($nios2_isa_info, "isa_constants"), "interrupt_sz"),

      internal_irq_mask => manditory_int($interrupt_info, "internal_irq_mask"),
      eic_present => manditory_bool($interrupt_info, "eic_present"),

      extra_exc_info => manditory_bool($exception_info, "extra_exc_info"),
      slave_access_error_exc => 
        manditory_bool($exception_info, "slave_access_error_exc"),
      imprecise_illegal_mem_exc => 
        manditory_bool($exception_info, "imprecise_illegal_mem_exc"),

      cpuid_value => manditory_int($misc_info, "cpuid_value"),
      num_shadow_reg_sets => manditory_int($misc_info, "num_shadow_reg_sets"),

      mmu_present => manditory_bool($mmu_info, "mmu_present"),
        tlb_num_ways => $mmu_info->{tlb_num_ways},
        process_id_num_bits => $mmu_info->{process_id_num_bits},

      mpu_present => manditory_bool($mpu_info, "mpu_present"),
        mpu_min_inst_region_size_log2 => 
          $mpu_info->{mpu_min_inst_region_size_log2},
        mpu_min_data_region_size_log2 => 
          $mpu_info->{mpu_min_data_region_size_log2},
        impu_region_index_sz => $elaborated_mpu_info->{impu_region_index_sz},
        dmpu_region_index_sz => $elaborated_mpu_info->{dmpu_region_index_sz},
        mpu_use_limit => $mpu_info->{mpu_use_limit},

      sim_reg_present => 
       manditory_bool($elaborated_test_info, "sim_reg_present"),
        activate_test_end_checker => $test_info->{activate_test_end_checker},
        perf_cnt_present => $elaborated_test_info->{perf_cnt_present},
        sim_reg_c_model_fields_present => 
          $elaborated_test_info->{sim_reg_c_model_fields_present},

      max_address_width => 
        manditory_int($elaborated_avalon_master_info, "Max_Address_Width"),
      pcb_sz => 
        manditory_int($elaborated_avalon_master_info, "pcb_sz"),
      mem_baddr_sz => 
        manditory_int($elaborated_avalon_master_info, "mem_baddr_sz"),
      num_tightly_coupled_data_masters =>
        manditory_int($elaborated_avalon_master_info, "num_tightly_coupled_data_masters"),
      cache_has_icache => manditory_bool($icache_info, "cache_has_icache"),
      dcache_supports_initda => manditory_bool($dcache_info, "dcache_supports_initda"),

      ecc_present => manditory_bool($ecc_info, "ecc_present"),
        ic_ecc_present   => manditory_bool($ecc_info, "ic_ecc_present"),
        dc_ecc_present   => manditory_bool($ecc_info, "dc_ecc_present"),
        rf_ecc_present   => manditory_bool($ecc_info, "rf_ecc_present"),
        itcm_ecc_present => manditory_bool($ecc_info, "itcm_ecc_present"),
        dtcm_ecc_present => manditory_bool($ecc_info, "dtcm_ecc_present"),
        mmu_ecc_present  => manditory_bool($ecc_info, "mmu_ecc_present"),
    };

    return $control_reg_args;
}






sub
create_control_reg_args_max_configuration
{
    my $control_reg_args = {
      interrupt_sz => 32,

      internal_irq_mask => 0xffffffff,
      eic_present => 1,

      extra_exc_info => 1,
      slave_access_error_exc => 1,
      imprecise_illegal_mem_exc => 0,

      cpuid_value => 0,
      num_shadow_reg_sets => 63,

      mmu_present => 1,
        tlb_num_ways => 16,
        process_id_num_bits => 14,

      mpu_present => 1,
        mpu_min_inst_region_size_log2 => 6,
        mpu_min_data_region_size_log2 => 6,
        impu_region_index_sz => 5,
        dmpu_region_index_sz => 5,
        mpu_use_limit => 1,

      sim_reg_present => 1,
        activate_test_end_checker => 1,
        perf_cnt_present => 1,
        sim_reg_c_model_fields_present => 1,
      
      max_address_width => 32,
      pcb_sz => 32,
      mem_baddr_sz => 32,
      num_tightly_coupled_data_masters => 4,
      cache_has_icache => 1,
      dcache_supports_initda => 1,

      ecc_present => 1,
        ic_ecc_present   => 1,
        dc_ecc_present   => 1,
        rf_ecc_present   => 1,
        itcm_ecc_present => 1,
        dtcm_ecc_present => 1,
        mmu_ecc_present  => 1,
    };

    return $control_reg_args;
}




sub
validate_and_elaborate
{
    my $control_reg_args = shift; # Hash reference containing all args

    my ($control_regs, $skip_control_reg_when_creating_global_field_scalars) =
      create_control_regs($control_reg_args);


    my $control_reg_info = {
      control_regs          => $control_regs,
    };


    foreach my $control_reg (@$control_regs) {






        foreach my $cmd (@{get_control_reg_into_scalars($control_regs,
          $control_reg)}) {
            eval_cmd($cmd);
        }


        my $skip = 0;
        foreach my $skip_control_reg 
          (@$skip_control_reg_when_creating_global_field_scalars) {
            if ($control_reg == $skip_control_reg) {
                $skip = 1;
            }
        }

        if ($skip) {
            next;
        }






        foreach my $field (@{get_control_reg_fields($control_reg)}) {
            foreach my $cmd (@{get_control_reg_field_into_scalars($field)}) {
                eval_cmd($cmd);
            }
        }
    }

    return $control_reg_info;
}


sub
convert_to_c
{
    my $control_reg_info = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    my $control_regs = manditory_array($control_reg_info, "control_regs");
    if (!defined($control_regs)) {
        return undef;
    }

    push(@$h_lines, "");
    push(@$h_lines, "/*");
    push(@$h_lines, " * Control register macros");
    push(@$h_lines, " */");

    foreach my $control_reg (@$control_regs) {
        if (!defined(
          convert_control_reg_to_c($control_reg, $c_lines, $h_lines))) {
            return undef;
        }
    }

    return 1;   # Some defined value
}





sub
create_control_regs
{
    my $args = shift;       # Hash ref containing all required arguments

    my $max_address_width = manditory_int($args, "max_address_width");
    my $pcb_sz = manditory_int($args, "pcb_sz");
    my $mem_baddr_sz = manditory_int($args, "mem_baddr_sz");
    my $cpuid_value = manditory_int($args, "cpuid_value");
    my $internal_irq_mask = manditory_int($args, "internal_irq_mask");
    my $eic_present = manditory_bool($args, "eic_present");
    my $mmu_present = manditory_bool($args, "mmu_present");
    my $mpu_present = manditory_bool($args, "mpu_present");
    my $ecc_present = manditory_bool($args, "ecc_present");
    my $cache_has_icache = manditory_bool($args, "cache_has_icache");
    my $dcache_supports_initda = manditory_bool($args, "dcache_supports_initda");
    my $num_tightly_coupled_data_masters = manditory_int($args, "num_tightly_coupled_data_masters");
    my $extra_exc_info = manditory_bool($args, "extra_exc_info");
    my $slave_access_error_exc = 
      manditory_bool($args, "slave_access_error_exc");
    my $imprecise_illegal_mem_exc = 
      manditory_bool($args, "imprecise_illegal_mem_exc");
    my $sim_reg_present = manditory_bool($args, "sim_reg_present");
    my $num_shadow_reg_sets = manditory_int($args, "num_shadow_reg_sets");

    my $eic_and_shadow = ($eic_present && ($num_shadow_reg_sets > 0));

    my $control_regs = [];
    my @skip_control_reg_when_creating_global_field_scalars;








    $status_reg = add_control_reg($control_regs, 
      { name => "status", num => 0 });
    $estatus_reg = add_control_reg($control_regs, 
      { name => "estatus", num => 1 });
    $bstatus_reg = add_control_reg($control_regs, 
      { name => "bstatus", num => 2 });

    my $pie_props = { name => "pie", lsb => 0, sz => 1 };
    $status_reg_pie = add_control_reg_field($status_reg,  $pie_props);
    $estatus_reg_pie = add_control_reg_field($estatus_reg, $pie_props);
    $bstatus_reg_pie = add_control_reg_field($bstatus_reg, $pie_props);

    if ($mmu_present || $mpu_present) {
        my $u_props = { name => "u", lsb => 1, sz => 1 };
        $status_reg_u = add_control_reg_field($status_reg,  $u_props);
        $estatus_reg_u = add_control_reg_field($estatus_reg, $u_props);
        $bstatus_reg_u = add_control_reg_field($bstatus_reg, $u_props);
    }
    if ($mmu_present || $ecc_present) {
        my $eh_props = { name => "eh", lsb => 2, sz => 1 };
        $status_reg_eh = add_control_reg_field($status_reg,  $eh_props); 
        $estatus_reg_eh = add_control_reg_field($estatus_reg, $eh_props); 
        $bstatus_reg_eh = add_control_reg_field($bstatus_reg, $eh_props); 
    }
    if ($eic_present) {
        my $ih_props = { name => "ih", lsb => 3, sz => 1 };
        $status_reg_ih = add_control_reg_field($status_reg,  $ih_props); 
        $estatus_reg_ih = add_control_reg_field($estatus_reg, $ih_props); 
        $bstatus_reg_ih = add_control_reg_field($bstatus_reg, $ih_props); 

        my $il_props = { name => "il", lsb => 4, sz => 6 };
        $status_reg_il = add_control_reg_field($status_reg,  $il_props); 
        $estatus_reg_il = add_control_reg_field($estatus_reg, $il_props); 
        $bstatus_reg_il = add_control_reg_field($bstatus_reg, $il_props); 

        my $nmi_name = "nmi";
        my $nmi_lsb = 22;
        my $nmi_sz = 1;
        my $status_nmi_props = 
          { name => $nmi_name, lsb => $nmi_lsb, sz => $nmi_sz, 
            mode => $MODE_READ_ONLY }; 
        my $estatus_bstatus_nmi_props = 
          { name => $nmi_name, lsb => $nmi_lsb, sz => $nmi_sz };
        $status_reg_nmi = add_control_reg_field($status_reg,  
          $status_nmi_props); 
        $estatus_reg_nmi = add_control_reg_field($estatus_reg, 
          $estatus_bstatus_nmi_props); 
        $bstatus_reg_nmi = add_control_reg_field($bstatus_reg, 
          $estatus_bstatus_nmi_props); 

        if ($num_shadow_reg_sets > 0) {
            my $rsie_name = "rsie";
            my $rsie_lsb = 23;
            my $rsie_sz = 1;
            my $status_rsie_props = { name => $rsie_name, lsb => $rsie_lsb,
              sz => $rsie_sz, reset_value => "1" };
            my $estatus_bstatus_rsie_props = 
              { name => $rsie_name, lsb => $rsie_lsb, sz => $rsie_sz };
            $status_reg_rsie = add_control_reg_field($status_reg,  
              $status_rsie_props); 
            $estatus_reg_rsie = add_control_reg_field($estatus_reg, 
              $estatus_bstatus_rsie_props); 
            $bstatus_reg_rsie = add_control_reg_field($bstatus_reg, 
              $estatus_bstatus_rsie_props); 
        }
    }

    if ($num_shadow_reg_sets > 0) {
        my $num_reg_sets = $num_shadow_reg_sets + 1;

        my $crs_name = "crs";
        my $crs_lsb = 10;
        my $crs_sz = count2sz($num_reg_sets);
        my $status_crs_props = 
          { name => $crs_name, lsb => $crs_lsb, sz => $crs_sz, 
            mode => $MODE_READ_ONLY }; 
        my $estatus_bstatus_crs_props = 
          { name => $crs_name, lsb => $crs_lsb, sz => $crs_sz };
        $status_reg_crs = add_control_reg_field($status_reg,  
          $status_crs_props); 
        $estatus_reg_crs = add_control_reg_field($estatus_reg, 
          $estatus_bstatus_crs_props); 
        $bstatus_reg_crs = add_control_reg_field($bstatus_reg, 
          $estatus_bstatus_crs_props); 

        my $prs_name = "prs";
        my $prs_lsb = 16;
        my $prs_sz = count2sz($num_reg_sets);
        my $prs_props = 
          { name => $prs_name, lsb => $prs_lsb, sz => $prs_sz };
        $status_reg_prs = add_control_reg_field($status_reg,  $prs_props); 
        $estatus_reg_prs = add_control_reg_field($estatus_reg, $prs_props); 
        $bstatus_reg_prs = add_control_reg_field($bstatus_reg, $prs_props); 
    }







    $ienable_reg = add_control_reg($control_regs, 
      { name => "ienable", num => 3 });
    $ipending_reg = add_control_reg($control_regs, 
      { name => "ipending", num => 4 });

    push(@skip_control_reg_when_creating_global_field_scalars, $ienable_reg);
    push(@skip_control_reg_when_creating_global_field_scalars, $ipending_reg);

    for (my $irq = 0; $irq < $args->{interrupt_sz}; $irq++) {
        if (($internal_irq_mask & (0x1 << $irq)) != 0) {
            my $field_name = "irq" . $irq;

            add_control_reg_field($ienable_reg,
              { name => $field_name, lsb => $irq, sz => 1 }); 
            add_control_reg_field($ipending_reg,
              { name => $field_name, lsb => $irq, sz => 1, 
                mode => $MODE_READ_ONLY}); 
        }
    }
    




    my $cpuid_sz = num2sz($cpuid_value);
    if ($cpuid_sz == 0) {
        $cpuid_sz = 1;
    }

    $cpuid_reg = add_control_reg($control_regs, 
      { name => "cpuid", num => 5 });
    $cpuid_reg_cpuid = add_control_reg_field($cpuid_reg, 
      { name => "cpuid", lsb => 0, sz => $cpuid_sz,
        mode => $MODE_CONSTANT, constant_value => $cpuid_value }); 




    if ($sim_reg_present) {
        my $activate_test_end_checker = manditory_bool($args, 
          "activate_test_end_checker");
        my $perf_cnt_present = manditory_bool($args, "perf_cnt_present");
        my $sim_reg_c_model_fields_present = 
          manditory_bool($args, "sim_reg_c_model_fields_present");

        $sim_reg = add_control_reg($control_regs, 
          { name => "sim", num => 6, hide => 1 });

        if ($activate_test_end_checker) {
            $sim_reg_stop = add_control_reg_field($sim_reg, 
              { name => "stop", lsb => 0, sz => 1, mode => $MODE_WRITE_ONLY });
        }

        if ($perf_cnt_present) {
            $sim_reg_perf_cnt_en = add_control_reg_field($sim_reg, 
              { name => "perf_cnt_en", lsb => 1, sz => 1, reset_value => "1" });
            $sim_reg_perf_cnt_clr = add_control_reg_field($sim_reg, 
              { name => "perf_cnt_clr", lsb => 2, sz => 1, 
                mode => $MODE_WRITE_ONLY });
        }

        if ($sim_reg_c_model_fields_present) {
            $sim_reg_inst_trace = add_control_reg_field($sim_reg, 
              { name => "inst_trace", lsb => 3, sz => 1, reset_value => "1" });
            $sim_reg_mem_traffic = add_control_reg_field($sim_reg, 
              { name => "mem_traffic", lsb => 4, sz => 1, reset_value => "1" });
            $sim_reg_show_icache = add_control_reg_field($sim_reg, 
              { name => "show_icache", lsb => 5, sz => 1, 
                mode => $MODE_WRITE_ONLY });
            $sim_reg_show_dcache = add_control_reg_field($sim_reg, 
              { name => "show_dcache", lsb => 6, sz => 1, 
                mode => $MODE_WRITE_ONLY });
            if ($mmu_present) {
                $sim_reg_show_tlb = add_control_reg_field($sim_reg, 
                  { name => "show_tlb", lsb => 7, sz => 1, 
                    mode => $MODE_WRITE_ONLY });
                $sim_reg_show_mmu_regs = add_control_reg_field($sim_reg, 
                  { name => "show_mmu_regs", lsb => 8, sz => 1, 
                    mode => $MODE_WRITE_ONLY });
            }    
        }
    }















    if ($extra_exc_info || $slave_access_error_exc || 
      $imprecise_illegal_mem_exc || $ecc_present) {
        $exception_reg = add_control_reg($control_regs, 
          { name => "exception", num => 7 });

        if ($slave_access_error_exc || $imprecise_illegal_mem_exc) {
            $exception_reg_mea = add_control_reg_field($exception_reg, 
              { name => "mea", lsb => 0, sz => 1 });
            $exception_reg_mee = add_control_reg_field($exception_reg, 
              { name => "mee", lsb => 1, sz => 1 });
        }

        if ($extra_exc_info) {
            $exception_reg_cause = add_control_reg_field($exception_reg, 
              { name => "cause", lsb => 2, sz => 5, mode => $MODE_READ_ONLY });
        }
        
        if ($ecc_present) {
            $exception_reg_eccftl = add_control_reg_field($exception_reg, 
              { name => "eccftl", lsb => 31, sz => 1, mode => $MODE_READ_ONLY });
        }
    }




    if ($mmu_present) {
        my $tlb_num_ways = manditory_int($args, "tlb_num_ways");
        my $process_id_num_bits = manditory_int($args, "process_id_num_bits");





        $pteaddr_reg = add_control_reg($control_regs, 
          { name => "pteaddr", num => 8 });
        $pteaddr_reg_vpn = add_control_reg_field($pteaddr_reg, 
          { name => "vpn", lsb => 2, sz => 20 });
        $pteaddr_reg_ptbase = add_control_reg_field($pteaddr_reg, 
          { name => "ptbase", lsb => 22, sz => 10 });





        $tlbacc_reg = add_control_reg($control_regs, 
          { name => "tlbacc", num => 9 });
        $tlbacc_reg_pfn = add_control_reg_field($tlbacc_reg, 
          { name => "pfn", lsb => 0, sz => ($max_address_width - 12) });
        $tlbacc_reg_g = add_control_reg_field($tlbacc_reg, 
          { name => "g", lsb => 20, sz => 1 });
        $tlbacc_reg_x = add_control_reg_field($tlbacc_reg, 
          { name => "x", lsb => 21, sz => 1 });
        $tlbacc_reg_w = add_control_reg_field($tlbacc_reg, 
          { name => "w", lsb => 22, sz => 1 });
        $tlbacc_reg_r = add_control_reg_field($tlbacc_reg, 
          { name => "r", lsb => 23, sz => 1 });
        $tlbacc_reg_c = add_control_reg_field($tlbacc_reg, 
          { name => "c", lsb => 24, sz => 1 });
        $tlbacc_reg_ig = add_control_reg_field($tlbacc_reg, 
          { name => "ig", lsb => 25, sz => 7, mode => $MODE_IGNORED });
    




        $tlbmisc_reg = add_control_reg($control_regs, 
          { name => "tlbmisc", num => 10 });
        $tlbmisc_reg_d = add_control_reg_field($tlbmisc_reg, 
          { name => "d", lsb => 0, sz => 1, mode => $MODE_READ_ONLY });
        $tlbmisc_reg_perm = add_control_reg_field($tlbmisc_reg, 
          { name => "perm", lsb => 1, sz => 1, mode => $MODE_READ_ONLY });
        $tlbmisc_reg_bad = add_control_reg_field($tlbmisc_reg, 
          { name => "bad", lsb => 2, sz => 1, mode => $MODE_READ_ONLY });
        $tlbmisc_reg_dbl = add_control_reg_field($tlbmisc_reg, 
          { name => "dbl", lsb => 3, sz => 1, mode => $MODE_READ_ONLY });
        $tlbmisc_reg_pid = add_control_reg_field($tlbmisc_reg, 
          { name => "pid", lsb => 4, sz => $process_id_num_bits });
        $tlbmisc_reg_we = add_control_reg_field($tlbmisc_reg, 
          { name => "we", lsb => 18, sz => 1 });
        $tlbmisc_reg_rd = add_control_reg_field($tlbmisc_reg, 
          { name => "rd", lsb => 19, sz => 1, mode => $MODE_WRITE_ONLY });
        $tlbmisc_reg_way = add_control_reg_field($tlbmisc_reg, 
          { name => "way", lsb => 20, sz => count2sz($tlb_num_ways) });
        

        if ($ecc_present) {
            $tlbmisc_reg_ee = add_control_reg_field($tlbmisc_reg, 
              { name => "ee", lsb => 24, sz => 1 });
        }
    }




    if ($ecc_present) {
        $eccinj_reg = add_control_reg($control_regs, 
          { name => "eccinj", num => 11 });
        if (manditory_bool($args, "rf_ecc_present")) {
            $eccinj_reg_rf = add_control_reg_field($eccinj_reg, 
              { name => "rf", lsb => 0, sz => 2 });
        }
        if (manditory_bool($args, "ic_ecc_present")) {
            $eccinj_reg_ictag = add_control_reg_field($eccinj_reg, 
              { name => "ictag", lsb => 2, sz => 2 });
            $eccinj_reg_icdat = add_control_reg_field($eccinj_reg, 
              { name => "icdat", lsb => 4, sz => 2 });
        }
        if (manditory_bool($args, "dc_ecc_present")) {
            $eccinj_reg_dctag = add_control_reg_field($eccinj_reg, 
              { name => "dctag", lsb => 6, sz => 2 });
            $eccinj_reg_dcdat = add_control_reg_field($eccinj_reg, 
              { name => "dcdat", lsb => 8, sz => 2 });
        }
        if (manditory_bool($args, "mmu_ecc_present")) {
            $eccinj_reg_tlb = add_control_reg_field($eccinj_reg, 
              { name => "tlb", lsb => 10, sz => 2 });
        }
        if (manditory_bool($args, "dtcm_ecc_present") && 
          ($num_tightly_coupled_data_masters > 0)) {
            $eccinj_reg_dtcm0 = add_control_reg_field($eccinj_reg, 
              { name => "dtcm0", lsb => 12, sz => 2 });
        }
        
        if (manditory_bool($args, "dtcm_ecc_present") &&
          ($num_tightly_coupled_data_masters > 1)) {
            $eccinj_reg_dtcm1 = add_control_reg_field($eccinj_reg, 
              { name => "dtcm1", lsb => 14, sz => 2 });
        }
        
        if (manditory_bool($args, "dtcm_ecc_present") &&
          ($num_tightly_coupled_data_masters > 2)) {
            $eccinj_reg_dtcm2 = add_control_reg_field($eccinj_reg, 
              { name => "dtcm2", lsb => 16, sz => 2 });
        }
        
        if (manditory_bool($args, "dtcm_ecc_present") &&
          ($num_tightly_coupled_data_masters > 3)) {
            $eccinj_reg_dtcm3 = add_control_reg_field($eccinj_reg, 
              { name => "dtcm3", lsb => 18, sz => 2 });
        }
    }





    if ($extra_exc_info) {
        $badaddr_reg = add_control_reg($control_regs, 
          { name => "badaddr", num => 12 });




        my $baddr_sz = ($pcb_sz > $mem_baddr_sz) ? $pcb_sz : $mem_baddr_sz;

        $badaddr_reg_baddr = add_control_reg_field($badaddr_reg, 
          { name => "baddr", lsb => 0, sz => $baddr_sz, 
            mode => $MODE_READ_ONLY });
    }

    if ($mpu_present || $eic_and_shadow || $ecc_present) {



        $config_reg = add_control_reg($control_regs, 
          { name => "config", num => 13 });

        if ($mpu_present) {
            $config_reg_pe = add_control_reg_field($config_reg, 
              { name => "pe", lsb => 0, sz => 1 });
        }
        if ($eic_and_shadow) {
            $config_reg_ani = add_control_reg_field($config_reg, 
              { name => "ani", lsb => 1, sz => 1 });
        }
        if ($ecc_present) {
            $config_reg_eccen = add_control_reg_field($config_reg, 
              { name => "eccen", lsb => 2, sz => 1 });
            $config_reg_eccexc = add_control_reg_field($config_reg, 
              { name => "eccexc", lsb => 3, sz => 1 });
        }
    }




    if ($mpu_present) {

        my $mpu_min_inst_region_size_log2 = 
          manditory_int($args, "mpu_min_inst_region_size_log2");
        my $mpu_min_data_region_size_log2 = 
          manditory_int($args, "mpu_min_data_region_size_log2");
        my $impu_region_index_sz = manditory_int($args, "impu_region_index_sz");
        my $dmpu_region_index_sz = manditory_int($args, "dmpu_region_index_sz");
        my $mpu_use_limit = manditory_bool($args, "mpu_use_limit");





        my $mpu_max_address_width = $max_address_width;
        
        my $base_index_sz = 
          ($impu_region_index_sz > $dmpu_region_index_sz) ?
            $impu_region_index_sz :
            $dmpu_region_index_sz;

        my $base_base_lsb =
          ($mpu_min_inst_region_size_log2 < $mpu_min_data_region_size_log2) ?
            $mpu_min_inst_region_size_log2 : 
            $mpu_min_data_region_size_log2;
        my $base_base_msb = $mpu_max_address_width - 1;
        my $base_base_sz = $base_base_msb - $base_base_lsb + 1;

        $mpubase_reg = add_control_reg($control_regs, 
          { name => "mpubase", num => 14 });
        $mpubase_reg_d = add_control_reg_field($mpubase_reg, 
            { name => "d", lsb => 0, sz => 1 });
        $mpubase_reg_index = add_control_reg_field($mpubase_reg, 
          { name => "index", lsb => 1, sz => $base_index_sz });
        $mpubase_reg_base = add_control_reg_field($mpubase_reg, 
          { name => "base", lsb => $base_base_lsb, sz => $base_base_sz });




        $mpuacc_reg = add_control_reg($control_regs, 
          { name => "mpuacc", num => 15 });
        $mpuacc_reg_wr = add_control_reg_field($mpuacc_reg, 
          { name => "wr", lsb => 0, sz => 1, mode => $MODE_WRITE_ONLY });
        $mpuacc_reg_rd = add_control_reg_field($mpuacc_reg, 
          { name => "rd", lsb => 1, sz => 1, mode => $MODE_WRITE_ONLY });
        $mpuacc_reg_perm = add_control_reg_field($mpuacc_reg, 
          { name => "perm", lsb => 2, sz => 3 });
        $mpuacc_reg_c = add_control_reg_field($mpuacc_reg, 
          { name => "c", lsb => 5, sz => 1 });




        if ($mpu_use_limit) {


          if ($mpu_max_address_width == 32) {
              $base_base_sz = $base_base_sz -1;
          }
            $mpuacc_reg_limit = add_control_reg_field($mpuacc_reg, 
              { name => "limit", lsb => $base_base_lsb, 
                sz => $base_base_sz + 1});
        } else {
            $mpuacc_reg_mask = add_control_reg_field($mpuacc_reg, 
              { name => "mask", lsb => $base_base_lsb, 
                sz => $base_base_sz });
        }
    };
    
    return ($control_regs, 
      \@skip_control_reg_when_creating_global_field_scalars);
}



sub
add_control_reg
{
    my $control_regs = shift;
    my $props = shift;

    my $name = $props->{name};
    my $num = $props->{num};

    if (defined(get_control_reg_by_name_or_undef($control_regs, $name))) {
        return &$error("Control register name '$name' already exists");
    }

    if (defined(get_control_reg_by_num_or_undef($control_regs, $num))) {
        return &$error("Control register number $num already exists");
    }

    my $control_reg = create_control_reg($props);


    push(@$control_regs, $control_reg);

    return $control_reg;
}

sub
eval_cmd
{
    my $cmd = shift;

    eval($cmd);
    if ($@) {
        &$error("nios2_control_regs.pm: eval($cmd) returns '$@'\n");
    }
}

1;
