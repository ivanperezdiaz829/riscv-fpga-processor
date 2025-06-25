use write_ddr_sdram;
use write_datapath;
use write_ddr_clk_gen;
use write_byte_groups;
use write_example_instance;
use write_example_driver;
use write_ddr_dll_gen;
use strict;



sub init_controller
{
	print "1) doing ddr_sdram top level\t\n";
	&write_auk_ddr_sdram();
	print "\tddr_sdram top level done\t\n";

	print "2) doing ddr_dll wrapper\t\n";
	&write_ddr_dll_gen();
	print "\tddr_dll wrapper done\t\n";
}

sub init_controller2
{
	print "5) doing the clock to memory\t\n";
	&write_ddr_clk_gen();
	print "\tclock to memory done\t\n";
	print "6) doing datapaths\t\n";
	&write_auk_ddr_datapath();
	print "\tdatapath done\t\n";
}

sub init_controller3
{
	print "7) doing dqs groups\t\n";
	&write_auk_ddr_dqs_group();
	print "\tdqs groups done\t\n";
}

sub init_controller4
{
	my $ext = "";
	my $fileName = $::gWRAPPER_NAME."_example_driver";
	if ($::language eq "vhdl"){$ext = $fileName.".vhd";}else{$ext = $fileName.".v";}
	if (($::gPARSE_EXAMPLE_DESIGN eq "true") or (!-e $::output_directory.$ext))
	{
		print "4) doing example driver\t\n";
		&write_example_driver();
	}
	print "\tdoing example driver done\t\n";
}

sub init_controller5
{
	print "3) doing example top level\t\n";
	&write_example_instance();
	print "\texample top level done\t\n";
}

1;







