###################################################################################################
# Utilities to get parameters
###################################################################################################
use ptf_parse;
use europa_all;

#Following parameters will be customized for each core
my $class_name = lc("ddr2_sdram_component"); #don't modify if it says iptb_sopc
my $class_version = "v13.1";
my $wizard_jar = "ddr2_sdram_controller.jar"; #name of IP Toolbench Wizard file
my $iptb_version = "1.3.0";

#Hashmap for command line arguments
my %args_map = ();

sub iptb_parse_command_line
{
  my @argv = @_;
  my $iptb_params = "";

  for my $arg (@argv)
  {
    if ($arg =~ /^--([\S]+)\s*=\s*([\S]+)$/)
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


# extract system name
my $system_name;
my $system_dir;
my $wrapper_name;
my $this_is_an_add;
my $this_is_an_edit;
foreach my $arg (@ARGV_list)
  {
      if ($arg =~ /^--system_name\s*=\s*([\S ]+)$/) 
      {
          $system_name = $1;
          #print "My system_name is $system_name\n";      
      }
      if ($arg =~ /^--system_directory\s*=\s*([\S ]+)$/) 
      {
          $system_dir = $1;
          #print "My system_dir is $system_dir\n";
      }
      if ($arg =~ /^--target_module_name\s*=\s*([\S ]+)$/) 
      {
          $wrapper_name = $1;
          #print "My wrapper_name is $wrapper_name\n";
      }
  }
 
 if ($system_dir =~ /([\S]+) ([\S]+)$/  ) 
{
	die "Impossible to generate, your Project path includes a space ($system_dir) \n";
}  
 
 
# Open the system PTF file
my $system_ptf_name = "$system_dir/$system_name.ptf";
my $sys_ptf = new_ptf_from_file ($system_ptf_name) || die "Unable to read system ptf from file $system_ptf_name\n"; 

# Get the clock frequency from the system PTF
my $clk_freq_for_iptb;
my $clock_source = get_data_by_path($sys_ptf,"SYSTEM $system_name/MODULE $wrapper_name/SYSTEM_BUILDER_INFO/Clock_Source") || die "ERROR: in $system_ptf_name, can't read Clock_Source setting for $wrapper_name instance of $class_name $class_version.\n";
my $clock_freq = get_data_by_path($sys_ptf,"SYSTEM $system_name/WIZARD_SCRIPT_ARGUMENTS/CLOCKS/CLOCK $clock_source/frequency") || die "ERROR: in $system_ptf_name, can't read system clock frequency setting for $wrapper_name instance of $class_name $class_version.\n";
$clk_freq_for_iptb = $clock_freq / 1000000;

#print "Assuming a clock frequency of $clk_freq_for_iptb MHz\n";


# Open the list of compnents to extract the name of the board (now in the project dir!).
my $install_ptf = ".sopc_builder/install.ptf";
my $db_ptf = new_ptf_from_file ($install_ptf) || die "Unable to read install ptf from file $install_ptf\n";


my $iptb_sopc_args = iptb_parse_command_line(@ARGV_list);

# Retrieve the module directory from arguments
my $core_component_directory = $args_map{'module_lib_dir'};


#Extract lib path from the $core_component_directory
$_ = $core_component_directory;
if(/(.*)\/sopc_builder/i)
{
  $megafunction_path = $1;
}

if ($megafunction_path =~ /([\S]+) ([\S]+)$/  ) 
{
	die "Impossible to generate, your IP directory include  a space $megafunction_path";
}  

$result = system("$megafunction_path/../../common/ip_toolbench/v$iptb_version/bin/ip_toolbench.exe -clock_frequency:$clk_freq_for_iptb -wizard_file:$megafunction_path/ip_toolbench/$wizard_jar -flow_dir:$megafunction_path/../../common/ip_toolbench/v$iptb_version/bin -silent -sopc $iptb_sopc_args");

if ($result != 1024)
{
	exit (2);
}
exit;
