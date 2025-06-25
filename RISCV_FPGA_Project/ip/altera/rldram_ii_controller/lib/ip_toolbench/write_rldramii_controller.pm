# use lib 'C:\altera\quartus50_b69\sopc_builder\bin';
# use lib 'C:\MegaCore\ddr_ddr2_sdram-v3.2.0\lib\europa';
# use lib 'C:\altera\quartus50_b69\sopc_builder\bin\perl_lib';

# Andy's latest Quartus5.0 setup 
#use lib 'D:\Program_Files\quartus5.0_build94\sopc_builder\bin';
#use lib 'D:\Program_Files\quartus5.0_build94\sopc_builder\bin\europa';
#use lib 'D:\Program_Files\quartus5.0_build94\sopc_builder\bin\perl_lib';

#Commented out for distributed reg tests bring up
#use lib 'C:\altera\quartus50_build147\sopc_builder\bin';
#use lib 'C:\altera\quartus50_build147\sopc_builder\bin\europa';
#use lib 'C:\altera\quartus50_build147\sopc_builder\bin\perl_lib';

#use Cwd;
use europa_all; 
use europa_utils;
use write_rldramii_datapath;
use write_rldramii_example_driver;
use write_rldramii_example_instance;
use write_rldramii_test_bench;
use write_rldramii_mw_wrapper;
use write_rldramii_clk_gen;
use write_rldramii_pipeline;
use write_rldramii_addr_cmd_out_reg;
use write_rldramii_dqs_group;
use write_rldramii_qvld_group;
use write_rldramii_dm_group;
use auk_rldramii_controller_ipfs_wrapper;
use strict;


sub init_controller2

{
	print "doing datapaths\t\n";
	&write_auk_rldramii_clk_gen();
	&gen_pipelines();
	&write_rldramii_addr_cmd_out_reg();
	&write_auk_rldramii_datapath();
	&write_rldramii_dqs_group();
	&write_rldramii_dm_group();
	&write_rldramii_qvld_group();
	print "2\t\n";

}

sub init_controller3
{
	print "doing rldramii wrapper\t\n";
	&auk_rldramii_controller_ipfs_wrapper();
	&write_rldramii_mw_wrapper();
	print "3\t\n";
}

sub init_controller4
{
	print "doing rldramii example driver\t\n";
	&write_rldramii_example_driver();
	print "4\t\n";
}

 sub init_controller5
 {
	 my $ext = "";
	 if ($::language eq "vhdl"){$ext = "$::gTOPLEVEL_NAME.vhd";}else{$ext = "$::gTOPLEVEL_NAME.v";}
	 #print "the toplevel name is : $::update_toplevel -->\n\n<-- $::output_directory$ext **\n";
	 if ($::update_toplevel eq "true"){
	 	 print "doing rldramii example instance\t\n";
		 &write_rldramii_example_instance();
		 print "5\t\n";
	 }
 }

sub init_controller6
{
	print "doing rldramii test bench\t\n";
	&write_rldramii_test_bench();
	print "6\t\n";
}

1;



