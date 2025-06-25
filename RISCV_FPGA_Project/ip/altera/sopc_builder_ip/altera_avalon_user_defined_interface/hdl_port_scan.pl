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





























use strict;
use HDL_parse;
use ptf_parse;
use hdl_common;

sub test_parse
{
    my $hash = &HDL_Get_Module_Info_From_File (
	file => "D:\\projects\\ndb\\nios_build\\internal_ram.v",
	language => "verilog" );
print "about to parse data struct\n";
    my $name;
    foreach $name (keys(%$hash))
    {
	print "$name/n";

	print "	port order\n";
	foreach my $port (@{$hash->{$name}{port_order}})
	{
		print "		$port\n";
	}

	print "signals\n";
	foreach my $signal (keys(%{$hash->{$name}{signal}}))
	{
		print "	$signal\n";
		print "		width = $hash->{$name}{signal}{$signal}{width}\n";
		print "		direction = $hash->{$name}{signal}{$signal}{direction}\n";
	}
    }
print "finished parsing data struct\n";
}








sub get_port_info_from_files
{
    my $moduleRef = shift;
    my $HDL_files = shift;
    my $system_dir = shift;
    my $moduleName;
    my $PortType;
    my $Master;
    my $Bus;


    my @children = get_first_children_of_type ($moduleRef, "WIZARD_SCRIPT_ARGUMENTS");
    foreach my $ref (@children)
    {
        if (get_name ($ref) eq "WIZARD_SCRIPT_ARGUMENTS")
        {
            $moduleName = get_data_by_path ($ref, "Module_Name");
            $PortType = get_data_by_path ($ref, "Port_Type");
        }
    }

    die ("Error: No top level module specified!") if ($moduleName eq "");


    if ($PortType =~ /Custom Instruction/)
    {
        $Bus = "";
        $PortType = "SLAVE";
    }
   else
   {
        if ($PortType =~ /AHB/)
        {
            $Bus = "ahb";
        }
        else
        {
            $Bus = "avalon";
        }
        if ($PortType =~ /Master/)
        {
            $PortType = "MASTER";
            $Bus = $Bus."M";
        }
        else
        {
            $PortType = "SLAVE";
            $Bus = $Bus."S";
        }
    }



    my $notFound = 1;
    chdir "$system_dir" or die "Error:Uable to change to system directory: $system_dir!";
    foreach my $fileName (@$HDL_files)
    {
    	my $moduleStruct = &HDL_Get_Module_Info_From_File ( file=>$fileName );
	    next unless ($moduleStruct);

        my $current_module_name = $moduleName;

        $current_module_name =~ tr/A-Z/a-z/
            if (file=>$fileName =~ /\.vhdl?/i);

        my $modKey;
        if ($moduleStruct->{$current_module_name})
        {
            $modKey = $current_module_name;
        }
        else
        {
            $modKey = "bdf";
        }


        $fileName =~ /.*\/(.*?)\.bdf/;
        next unless (($1 eq "") || ($1 eq $current_module_name));

	    if ($moduleStruct->{$modKey})
        {

           $notFound = 0;
	       my $port_wiring = get_child_by_path ($moduleRef, $PortType." ".$Bus."/PORT_WIRING", 1);
	       foreach my $port (@{$moduleStruct->{$modKey}{port_order}})
	       {

	            my $port_sect = get_child_by_path ($port_wiring, "PORT $port", 1);

	            add_child_data ($port_sect, "width",
	       		$moduleStruct->{$modKey}{signal}{$port}{width});
                add_child_data ($port_sect, "direction",
	       		$moduleStruct->{$modKey}{signal}{$port}{direction});


                add_child_data ($port_sect, "type","") if (&get_data_by_path ($port_sect, "type") eq "");
	        }
	        last;
        }
    }
    die ("Error: Module ($moduleName) not found in files!") if ($notFound);
}







sub get_module_list_from_files ()
{
    my $moduleRef = shift;
    my $HDL_files = shift;
    my $system_dir = shift;

    my $module_names="";
    my $notFound = 1;
    chdir "$system_dir" or die "Error:Uable to change to system directory: $system_dir!";

    my $module_list = get_child_by_path ($moduleRef,
        "WIZARD_SCRIPT_ARGUMENTS/Module_List",1);


    foreach my $fileName (@$HDL_files)
    {
    	my $moduleStruct = &HDL_Get_Module_Info_From_File ( file=>$fileName );
	    next unless ($moduleStruct);


        if ($fileName =~ /.*\/(.*?)\.bdf/)
        {
            if ($module_names eq "")
            {
                $module_names = $1;
            }
            else
            {
                $module_names = $module_names.", ".$1;
            }
            next;
        }

        foreach my $name (keys(%$moduleStruct))
        {
            if ($module_names eq "")
            {
                $module_names = $name;
            }
            else
            {
                $module_names = $module_names.", ".$name;
            }
        }
        print "names are $module_names ";
    }

    set_data ($module_list, $module_names);
}










    my $switches = &parse_args (@ARGV);
    my $PTFfileName = $switches->{system_directory}."/".$switches->{system_name}.".ptf";
    my $moduleName = $switches->{target_module_name};

    my $get_modules = $switches->{get_modules};


    my $ptf = &new_ptf_from_file ($PTFfileName);
    die ("Error: Unable to read PTF file ($PTFfileName)!") if ($ptf eq "");


    my $module = &get_child_by_path ($ptf,"SYSTEM\/MODULE $moduleName",0);
    die ("Error: No such module ($moduleName) in file $PTFfileName!") if ($module eq "");


    my @HDL_list = &get_HDLfiles_from_module ($module);
    die ("Error: No HDL files listed!") if (scalar(@HDL_list) == 0);

    if ($get_modules eq "1")
    {

        &get_module_list_from_files ($module, \@HDL_list,
            $switches->{system_directory});
    }
    else
    {

        &get_port_info_from_files ($module, \@HDL_list,
            $switches->{system_directory});
    }


    write_ptf_file ($ptf);
