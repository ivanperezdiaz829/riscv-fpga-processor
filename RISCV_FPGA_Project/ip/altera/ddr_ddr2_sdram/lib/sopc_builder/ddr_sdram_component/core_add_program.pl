###################################################################################################
# Utilities to get parameters
###################################################################################################
use ptf_parse;
use europa_all;

#Following parameters will be customized for each core
my $class_name = lc("ddr_sdram_component"); #don't modify if it says iptb_sopc
my $class_version = "v13.1";
my $wizard_jar = "ddr_sdram_controller.jar"; #name of IP Toolbench Wizard file
my $iptb_version = "1.3.0";

#Hashmap for command line arguments
my %args_map = ();

sub iptb_parse_command_line
{
    my @argv = @_;
    my $iptb_params = "";

    for my $arg (@argv)
    {
   
        if ($arg =~ /^--cmd\s*=\s*'([^']+)'$/)
        {
            $iptb_params .= "-silent ";
            @params = split(/;/, $1);
            #translate arguments as read only privates in IP Toolbench
            for my $param (@params)
            {
                if ($param =~ /^\s*("[^"]"|[\S]+)\s*=\s*(.+)$/)
                {
                    my $argname = "parameterization.$1";
                    my $argval = "$2";
                    $iptb_params .= "-$argname:$argval ";
                    $args_map{$argname}=$argval;
                }
            }
        }
        elsif ($arg =~ /^--projectname\s*=\s*([\S]+)$/)
        {
            my $argname = "parameterization.projectname";
            my $secondargname = "projectname";
            my $argval = $1;
            #translate arguments as read only privates in IP Toolbench
            $iptb_params .= "-$argname:$argval -$secondargname:$argval ";
            $args_map{$argname}=$argval;
        }
        elsif ($arg =~ /^--([\S]+)\s*=\s*([\S]+)$/)
        {
            my $argname = $1;
            my $argval = $2;
            #translate arguments as read only privates in IP Toolbench
            $iptb_params .= "-$argname:$argval ";
            $args_map{$argname}=$argval;
        }
    }
    return $iptb_params;
}



my @ARGV_list = @ARGV;        


# extract system name from SOPC Builder command line
my $system_name;
my $system_dir;
my $wrapper_name;
my $this_is_an_add;
my $this_is_an_edit;
foreach my $arg (@ARGV_list)
  {
      if ($arg =~ /^--system_name\s*=\s*([\S]+)$/) 
      {
          $system_name = $1;
          # print "My system_name is $system_name\n";      
      }
      if ($arg =~ /^--system_directory\s*=\s*([\S ]+)$/) 
      {
          $system_dir = $1;
          #print "My system_dir is $system_dir\n";
      }
      if ($arg =~ /^--target_module_name\s*=\s*([\S]+)$/) 
      {
          $wrapper_name = $1;
          #print "My wrapper_name is $wrapper_name\n";
      }
      if ($arg =~ /^--add\s*=\s*([\S]+)$/) 
      {
          $this_is_an_add = $1;
          # print "Am I adding? is $this_is_an_add\n";
      }
      if ($arg =~ /^--edit\s*=\s*([\S]+)$/) 
      {
          $this_is_an_edit = $1;
          # print "Am I editing? is $this_is_an_edit\n";
      }
  }

# Open the system PTF file and read the board class name from it
my $system_ptf_name = "$system_dir/$system_name.ptf";
my $sys_ptf = new_ptf_from_file ($system_ptf_name) || die "Unable to read system ptf from file\n"; 

my $board_type = get_data_by_path($sys_ptf,"SYSTEM $system_name/WIZARD_SCRIPT_ARGUMENTS/board_class");
if ($board_type eq "") { $board_type = "Unspecified";}
#print "Board = $board_type\n";


# Get the clock frequency from the system PTF
my $clk_freq_for_iptb;
if ($this_is_an_add == "1") {
    # For a new wrapper, get the name of the first clock in the list...  
    my $clocks = get_child_by_path($sys_ptf,"SYSTEM $system_name/WIZARD_SCRIPT_ARGUMENTS/CLOCKS", 0 ,0) || die "ERROR: in $system_ptf_name, can't read system clock setting (new instance of $class_name $class_version).\n";
    my $clock_name = $clock_freq->{section}[0]{data};

    # Now get the frequency of that clock
    my $clock_frequency = get_data_by_path($clocks, "CLOCK $clock_name/frequency") || die "ERROR: in $system_ptf_name, can't read $clock_name system clock frequency setting (new instance of $class_name $class_version).\n";
    $clk_freq_for_iptb = $clock_frequency / 1000000;
} else {
    # Get name of clock source from the module's entry in the PTF
    my $clock_source = get_data_by_path($sys_ptf,"SYSTEM $system_name/MODULE $wrapper_name/SYSTEM_BUILDER_INFO/Clock_Source") || die "ERROR: in $system_ptf_name, can't read Clock_Source setting for $wrapper_name instance of $class_name $class_version.\n";
    # Now get the frequency of that clock
    my $clock_freq = get_data_by_path($sys_ptf,"SYSTEM $system_name/WIZARD_SCRIPT_ARGUMENTS/CLOCKS/CLOCK $clock_source/frequency") || die "ERROR: in $system_ptf_name, can't read Clock frequency setting of system for $wrapper_name instance of $class_name $class_version.\n";
    $clk_freq_for_iptb = $clock_freq / 1000000;
}



# Open the list of compnents to extract the name of the board (now in the project dir!).
my $install_ptf = ".sopc_builder/install.ptf";
my $db_ptf = new_ptf_from_file ($install_ptf);

# Open the class.ptf for the board selected in SOPC Builder and extract it's pretty name
my $board_name = $board_type;
if ($board_name ne "Unspecified") { 
    my $board_component_directory = get_data_by_path($db_ptf,"PACKAGE install/COMPONENT $board_type/VERSION/local") || die "ERROR: in $install_ptf, can't read install path for $board_type 0.0.\n";
    my $board_ptf = new_ptf_from_file ($board_component_directory."/class.ptf");
    $board_name = get_data_by_path($board_ptf,"CLASS $board_type/USER_INTERFACE/USER_LABELS/name") || die "ERROR: in $board_ptf, can't read name for $board_type 0.0.\n";
    $board_name =  "\"".$board_name."\""; # quote it so it can be passed as a cmd line param
} else {
    $board_name = "Custom";
}
# print "Using a board $board_name\n";



my $iptb_sopc_args = iptb_parse_command_line(@ARGV_list);

# Retrieve the module directory from arguments
my $core_component_directory = $args_map{'module_lib_dir'};

#Extract lib path from the $core_component_directory
$_ = $core_component_directory;
if(/(.*)\/sopc_builder/i)
{
  $megafunction_path = $1;
}

$result = system("$megafunction_path/../../common/ip_toolbench/v$iptb_version/bin/ip_toolbench.exe -memory_or_board_type:$board_name -clock_frequency:$clk_freq_for_iptb -wizard_file:$megafunction_path/ip_toolbench/$wizard_jar -flow_dir:$megafunction_path/../../common/ip_toolbench/v$iptb_version/bin -sopc $iptb_sopc_args");

if ($result != 1024)
{
    exit (2);
}
exit (4);
