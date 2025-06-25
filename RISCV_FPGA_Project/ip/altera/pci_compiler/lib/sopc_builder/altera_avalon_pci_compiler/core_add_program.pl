###################################################################################################
# Utilities to get parameters
###################################################################################################
use ptf_parse;

#Following parameters will be customized for each core
my $class_name = lc("altera_avalon_pci_compiler"); #don't modify if it says iptb_sopc
my $class_version = "2.0";
my $wizard_jar = "pci_compiler.jar"; #name of IP Toolbench Wizard file
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
      my $argname = "project.projectname";
      my $argval = $1;
      #translate arguments as read only privates in IP Toolbench
      $iptb_params .= "-$argname:$argval ";
      $args_map{$argname}=$argval;
    }
    elsif ($arg =~ /^--([\S]+)\s*=\s*([\S\s]+)$/)
    {
      my $argname = $1;
      my $argval = $2;
      #translate arguments as read only privates in IP Toolbench
      $iptb_params .= "-$argname:\"$argval\" ";
      $args_map{$argname}=$argval;
    }
  }
  return $iptb_params;
 }

my $iptb_sopc_args = iptb_parse_command_line(@ARGV);

#Retrive the module directory from arguments
my $core_component_directory = $args_map{'module_lib_dir'};

#Extract lib path from the $core_component_directory
$_ = $core_component_directory;
if(/(.*)\/sopc_builder/i)
{
  $megafunction_path = $1;
}

my $to_skip = check_skip($args_map);

if($to_skip == 0){
	$result = system("\"$megafunction_path/../../common/ip_toolbench/v$iptb_version/bin/ip_toolbench.exe\" -wizard_file:\"$megafunction_path/ip_toolbench/$wizard_jar\" -flow_dir:\"$megafunction_path/../../common/ip_toolbench/v$iptb_version/bin\" -sopc $iptb_sopc_args");

	if ($result != 1024)
	{
        	exit (2);
	}
}

exit (4);

sub check_skip
{
        my $args_map = shift;
        my $skip=0;
        my $system_directory = $args_map{'system_directory'};
        my $system_name = $args_map{'system_name'};
        my $target_module_name = $args_map{'target_module_name'};

        if ($system_directory ne "" && $system_name ne "" && $target_module_name ne "")
        {
                my $ptf_file = $system_directory . "/" . $system_name . ".ptf";
                #print "$ptf_file\n";
                my $ptf_ref = new_ptf_from_file($ptf_file);
                my $path = "SYSTEM ". $system_name."/MODULE ".$target_module_name."/SYSTEM_BUILDER_INFO/Do_Not_Generate";
                #print "path=$path\n";
                my $value = get_data_by_path($ptf_ref,$path,"0");
                #print "value=$value\n";
                $skip=$value;
        }
        return $skip;
}

