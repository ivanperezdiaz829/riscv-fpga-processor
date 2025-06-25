# ------------------------------------------------------------------------------
#  This confidential and proprietary software may be used only as authorized by
#  a licensing agreement from Altera Corporation.
#
#  (C) COPYRIGHT 2005 ALTERA CORPORATION
#  ALL RIGHTS RESERVED
#
#  The entire notice above must be reproduced on all authorized copies and any
#  such reproduction must be pursuant to a licensing agreement from Altera.
#
#  Title        : QDRII SRAM Controller Avalon read interface
#  Project      : QDRII SRAM Controller
#
#
#  File         : $RCSfile: write_qdrii_controller.pm,v $
#
#  Last modified: $Date: 2013/08/11 $
#  Revision     : $Revision: #1 $
#
#  Abstract:
#
#  Notes:
# ------------------------------------------------------------------------------

#use lib 'D:\Program_Files\quartus41 sp2\sopc_builder\bin';
#use lib 'D:\Program_Files\quartus41 sp2\sopc_builder\bin\europa';
#use lib 'D:\Program_Files\quartus41 sp2\sopc_builder\bin\perl_lib';

# Oladapo's Setup
#use lib 'C:\quartus_50_ib86\sopc_builder\bin';
#use lib 'D:\Data\mem\ddr_sdram\deliv\lib\europa';
#use lib 'C:\altera\quartus50_build34\sopc_builder\bin\perl_lib';

use europa_all;
use europa_utils;
use write_qdrii_datapath;
use write_qdrii_example_driver;
use write_qdrii_example_instance;
use write_qdrii_test_bench;
use write_qdrii_sdram;
use write_qdrii_clk_gen;
use write_qdrii_pipeline;
use write_qdrii_addr_cmd_wrapper;
use write_qdrii_addr_cmd_out_reg;
use write_qdrii_cq_cqn_group;
use write_qdrii_read_group;
use write_qdrii_capture_group;
use write_qdrii_capture_group_wrapper;
use write_qdrii_write_group;
use write_qdrii_resynch_reg;
use qdrii_av_master;
use write_qdrii_mw_wrapper;
use write_qdrii_lfsr;
use write_qdrii_test_group;
use write_qdrii_train_wrapper;
use write_qdrii_pipe_resynch_wrapper; 
use  write_qdrii_dll_gen;
use write_qdrii_new_example_driver;
# use e_auk_qdrii_avalon_write_if;
use write_qdrii_avalon_read_if_ipfs_wrap;
use write_qdrii_avalon_write_if_ipfs_wrap;
use write_qdrii_avalon_controller_ipfs_wrap;
use strict;


sub datapath
{
	my $i=1;
	print "doing datapath files\n\t";
	&gen_lfsr();
	print "$i) LFSR modules done\n\t";$i++;
	&write_auk_qdrii_clk_gen();
	print "$i) Memory clock module done\n\t";$i++;
	&gen_pipelines();
	print "$i) Pipeline modules done\n\t";$i++;
	&write_qdrii_addr_cmd_wrapper();
	print "$i) Address & Command Wrappper module done\n\t";$i++;
	&write_qdrii_addr_cmd_out_reg();
	print "$i) Address & Command module done\n\t";$i++;
	&write_qdrii_write_group();
	print "$i) Write datapath module done\n\t";$i++;
	&write_qdrii_cq_cqn_group();
	print "$i) DQS delay module done\n\t";$i++;
	&write_qdrii_resynch_reg();
	print "$i) Resynch registers module done\n\t";$i++;
	&write_qdrii_read_group();
	print "$i) Read datapath module done\n\t";$i++;
	&write_qdrii_capture_group_wrapper();
	print "$i) Capture Group Wrapper done\n\t";$i++;

	if($::gFAMILY eq "Cyclone II")
	{
		&write_qdrii_capture_group();
		print "$i) Capture module done\n\t";$i++;
	}
	&write_qdrii_datapath();
	print "$i) Datapath module done\n\n";
}

sub qdrii_sdram
{
	my $i=1;
	print "doing wrapper files\n\t";
	#print "$i) doing qdrii avalon_read_if_ipfs_wrap wrapper\n\t";$i++;
	#&write_qdrii_avalon_read_if_ipfs_wrap();
	#print "$i) doing qdrii avalon_write_if_ipfs_wrap wrapper\n\t";$i++;
	#&write_qdrii_avalon_write_if_ipfs_wrap();
	print "$i) doing qdrii resynch & pipeline wrapper\n\t";$i++;
	&write_qdrii_pipe_resynch_wrapper();
	print "$i) doing qdrii avalon controller ipfs wrapper\n\t";$i++;
	&write_qdrii_avalon_controller_ipfs_wrap();
	print "$i) doing qdrii sdram wrapper\n\t";$i++;
	&write_qdrii_sdram();
	#print "$i) doing qdrii mw_wrapper\n\t";$i++;
	#&write_qdrii_mw_wrapper();
    print "$i) doing qdrii sdram dll\n\t";$i++;
	&write_ddr_dll_gen();
	
	my $ext = "";
	
	if ($::language eq "vhdl"){$ext = "$::gTOPLEVEL_NAME.vhd";}else{$ext = "$::gTOPLEVEL_NAME.v";}
	#if (($::update_top_level eq "true") or (!-e $::output_directory.$ext))
	if ($::gUPDATE_TOP_LEVEL eq "true")
	{
		print "$i) update_top_level = true doing qdrii example instance\n\t";$i++;
		&write_qdrii_example_instance();
	}
	print "\t\n";
}

sub example_driver
{
	my $i=1;
	print "doing qdrii example driver\n\t";
	if ($::gREGRESSION_TEST eq "true")
	{
		&qdrii_av_master();
		print "$i) Avalon Master module done\n\t";$i++;
		&write_qdrii_example_driver();
	} else {
		&write_qdrii_new_example_driver();
	}
	print "$i) Example Driver module done\n\t";$i++;
	print "\t\n";
}

sub test_bench
{
	my $i=1;
	print "doing qdrii test bench\n\t";
	&write_qdrii_test_bench();
	print "$i) TestBench module done\n\t";$i++;
	&write_qdrii_test_group();
	print "$i) Test Module done\n\t";$i++;
	&write_qdrii_train_wrapper();
	print "$i) Test Module Wapper done\n\t";$i++;
}

1;



