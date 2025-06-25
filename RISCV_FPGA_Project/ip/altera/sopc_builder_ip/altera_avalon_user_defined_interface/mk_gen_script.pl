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
use ptf_parse;
use hdl_common;

sub main 
{
    my $switches = parse_args (@ARGV);


    my $system_directory = $switches->{system_directory};
    my $class_name = $switches->{target_class_name};
    my $module_name = $switches->{target_module_name};
    my $top_module_name = $switches->{top_module_name};


    my $gen_script_file = $system_directory . "/" . $class_name . "/mk_" . $class_name . ".pl";
    my $PTF_file_name = $system_directory . "/" . $switches->{system_name} . ".ptf";


    my $ptf = &new_ptf_from_file ($PTF_file_name);
    die ("Error: Unable to read PTF file ($PTF_file_name)!") if ($ptf eq "");


    my $module = &get_child_by_path ($ptf,"SYSTEM\/MODULE $module_name",0);
    die ("Error: No such module ($module_name) in file $PTF_file_name!") if ($module eq "");


    my @HDL_list = get_HDLfiles_from_module ($module);
    for (my $i=0; $i < scalar @HDL_list; $i++)
    {
        $HDL_list[$i] =~ /^.*\/(.*)$/; # no directory name
        $HDL_list[$i] = $1;
    }
    my $class_file_list = join "\",\"" , @HDL_list; # comma separated list
    $class_file_list = "\"" . $class_file_list . "\""; # surrounded by quotes


    my $class_file_mode = "";
    my $instantiate = get_data_by_path ($module, 
        "SYSTEM_BUILDER_INFO/Instantiate_In_System_Module");
    my $simulate = get_data_by_path ($module,
        "WIZARD_SCRIPT_ARGUMENTS/Simulate_Imported_HDL");
    if ($instantiate && $simulate)
    {
        $class_file_mode = "simulation_and_quartus";
    }
    elsif ($instantiate)
    {
        $class_file_mode = "quartus_only";
    }


    my $gen_header = qq[






use strict;             # keeps us honest
use generator_library;  # includes all the code we'll need???








generator_enable_mode ("terse");





generator_begin (\@ARGV);

];

    my $gen_copy_files = qq[

generator_make_module_wrapper($simulate, "$top_module_name");



















generator_copy_files_and_set_system_ptf ("$class_file_mode", 
                ($class_file_list));

];

    my $gen_footer = qq[



generator_end ();





exit (0);

];


    open GF, ">$gen_script_file" or die "Unable to open output generator script";

    print GF $gen_header;

    if ($class_file_mode)
    {
        print GF $gen_copy_files;
    }

    print GF $gen_footer;

    close GF;
}

main;
1;

