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




























use europa_all;
use strict;


my $Read_Wait_States = 1;
my $Write_Wait_States = 1;
my $Address_Width = 9;     # 2KBytes = 11 bits, 32 bits --> -2.
my $Data_Width = 32;


my $default_databits      = "8";
my $default_targetclock   = "20";
my $default_clockunits    = "MHz";
my $default_numslaves     = "1";
my $default_ismaster      = "1";
my $default_clockpolarity = "0";
my $default_clockphase    = "0";
my $default_lsbfirst      = "0";
my $default_extradelay    = "0";
my $default_targetssdelay = "100";
my $default_delayunits    = "us";


my $default_clockmult;
($default_clockmult = $default_clockunits) =~ s/Hz//;
$default_clockmult = unit_prefix_to_num($default_clockmult);

my $default_delaymult;
($default_delaymult = $default_delayunits) =~ s/s//;
$default_delaymult = unit_prefix_to_num($default_delaymult);

my $g_slave_name = 'epcs_control_port';

sub get_slave_name
{


  return $g_slave_name;
}

sub get_code_size
{
  my $project = shift;
  my $device_family =
    uc($project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}->{device_family});

  if( ($device_family eq "STRATIXII")   ||
      ($device_family eq "STRATIXIIGX") ||
      ($device_family eq "STRATIXIIGXLITE") ||
      ($device_family eq "STRATIXIII") ||
      ($device_family eq "STRATIXIV") ||
      ($device_family eq "STRATIXV") ||
      ($device_family eq "ARRIAII") ||
      ($device_family eq "ARRIAIIGZ") ||
      ($device_family eq "ARRIAV") ||
      ($device_family eq "ARRIAVGZ") ||
      ($device_family eq "STRATIXIIGXLITE") ||
      ($device_family eq "CYCLONEIII")||
      ($device_family eq "TARPON") ||
      ($device_family eq "CYCLONEIVE") ||
      ($device_family eq "STINGRAY") ||
      ($device_family eq "CYCLONEV"))
  {


    return 0x400;
  }
  else
  {

    return 0x200;
  }
}

sub add_make_target_ptf_assignments
{
  my $project = shift;

  my $name = $project->_target_module_name();


  my $wsa = $project->system_ptf()->{"MODULE $name"}->{WIZARD_SCRIPT_ARGUMENTS};
  my $sbi = $project->system_ptf()->{"MODULE $name"}->{SYSTEM_BUILDER_INFO};
  my $slave_sbi = $project->SBI("$name/$g_slave_name");
  my $slave_wsa =
    $project->system_ptf()->{"MODULE $name"}->{"SLAVE $g_slave_name"}->
      {WIZARD_SCRIPT_ARGUMENTS};
  my $refdes = $slave_wsa->{epcs_flash_refdes};







  my @targets = qw(flashfiles dat programflash);
  



}

sub validate_epcs_parameters
{
  my ($Options, $system_WSA) = @_;

  validate_parameter ({
    hash => $system_WSA,
    name => "clock_freq",
    type => "integer",
  });

  validate_parameter ({
    hash => $Options,
    name => "ismaster",
    type => "boolean",
    default => $default_ismaster,
  });
  
  validate_parameter ({
    hash => $Options,
    name => "databits",
    type => "integer",
    range   => [1,16],
    default => $default_databits,
  });
  
  validate_parameter ({
    hash => $Options,
    name => "targetclock",
    type => "string",
    default => $default_targetclock,
  });
  
  validate_parameter ({
    hash => $Options,
    name => "numslaves",
    type => "integer",
    range => [1, 16],
    default => $default_numslaves,
  });
  
  validate_parameter ({
    hash => $Options,
    name => "clockpolarity",
    type => "boolean",
    default => $default_clockpolarity,
  });
  
  validate_parameter ({
    hash => $Options,
    name => "clockphase",
    type => "boolean",
    default => $default_clockphase,
  });

  validate_parameter ({
    hash => $Options,
    name => "lsbfirst",
    type => "boolean",
    default => $default_lsbfirst,
  });

  validate_parameter ({
    hash => $Options,
    name => "extradelay",
    type => "boolean",
    default => $default_extradelay,
  });
  
  validate_parameter ({
    hash => $Options,
    name => "targetssdelay",
    type => "string",
    default => $default_targetssdelay,
  });

  validate_parameter ({
    hash => $Options,
    name => "delayunit",
    type => "string",
    default => $default_delayunits,
    allowed => ["s", "ms", "us", "ns"],
  });


  validate_parameter ({
    hash => $Options,
    name => "clockunit",
    type => "string",
    allowed => ["Hz", "kHz", "MHz", ],
    default => $default_clockunits,
  });
  
}

sub make_epcs
{

  if (!@_)
  {
    return make_class_ptf();
  }
  
  die "Don't make an EPCS this way!\n";

}

  
my $global_magic_comment_string = <<EOP ;












EOP


sub do_create_class_ptf
{
  return 1;
}

sub make_class_ptf
{




  



  if (!do_create_class_ptf())
  {
    print STDERR "Not generating class.ptf: user has overridden.\n\n";
    return;
  }
  


  
  open FILE, ">class.ptf" or ribbit("Can't open 'class.ptf'\n");

  print FILE
qq[$global_magic_comment_string
CLASS altera_avalon_epcs_flash_controller
{
  SDK_GENERATION
  {
    SDK_FILES 0
    {
      cpu_architecture = "always";
      short_type = "epcs";
      c_structure_type = "np_epcs *";
      c_header_file = "sdk/epcs_struct.h";
      sdk_files_dir = "sdk";
    }
    SDK_FILES 1
    {
      cpu_architecture = "always";
      toolchain = "gnu";
      asm_header_file = "sdk/epcs_struct.s";
    }
  }
  ASSOCIATED_FILES
  {
    Add_Program  = "default";
    Edit_Program = "default";
    Generator_Program = "em_epcs.pl";
    Bind_Program = "bind";
  }
  MODULE_DEFAULTS
  {
    class      = "altera_avalon_epcs_flash_controller";
    class_version = "2.1";
    SLAVE epcs_control_port
    {
      SYSTEM_BUILDER_INFO
      {
        Bus_Type                     = "avalon";
        Is_Nonvolatile_Storage       = "1";
        Is_Printable_Device          = "0";
        Address_Alignment            = "dynamic";
        Is_Memory_Device             = "1";
        Address_Width                = "9";
        Data_Width                   = "32";
        Has_IRQ                      = "1";
        Read_Wait_States             = "1";
        Write_Wait_States            = "1";
      }
      WIZARD_SCRIPT_ARGUMENTS
      {
        class = "altera_avalon_epcs_flash_controller";
      }
    }
    SYSTEM_BUILDER_INFO
    {
      Is_Enabled= "1";
      Instantiate_In_System_Module = "1";

      Required_Device_Family = "STRATIX,CYCLONE,CYCLONEII,CYCLONEIII,STRATIXIII,STRATIXII,STRATIXIIGX,ARRIAGX,STRATIXIIGXLITE,STRATIXIV,STRATIXV,ARRIAII,ARRIAIIGZ,ARRIAV,ARRIAVGZ,TARPON,STINGRAY,CYCLONEIVE,CYCLONEV";
      Fixed_Module_Name = "epcs_controller";
      Top_Level_Ports_Are_Enumerated = "1";
    }
    WIZARD_SCRIPT_ARGUMENTS
    {
      databits      = "8";
      targetclock   = "20";
      clockunits    = "MHz";
      clockmult     = "1000000";
      numslaves     = "1";
      ismaster      = "1";
      clockpolarity = "0";
      clockphase    = "0";
      lsbfirst      = "0";
      extradelay    = "0";
      targetssdelay = "100";
      delayunits    = "us";
      delaymult     = "1.e-06";
      prefix        = "epcs_";



      register_offset = "";
    }
  }
  USER_INTERFACE
  {
        USER_LABELS
        {
            name="EPCS Serial Flash Controller";
            technology="Memory,EP1C20 Nios Development Board Cyclone Edition";
            alias="epcs";
        }
        WIZARD_UI default
        {
          title = "EPCS Serial Flash Controller - {{ \$MOD }}";
          CONTEXT 
          {
            SWSA = "SLAVE epcs_control_port/WIZARD_SCRIPT_ARGUMENTS";
            WSA = "WIZARD_SCRIPT_ARGUMENTS";
            SBI = "SLAVE epcs_control_port/SYSTEM_BUILDER_INFO";
            MODULE_SBI = "SYSTEM_BUILDER_INFO";
            SPWA = "SLAVE epcs_control_port/PORT_WIRING/PORT address";
            SPWD = "SLAVE epcs_control_port/PORT_WIRING/PORT data";
          }	  
	  error = "{{ if (device_info('has_EPCS') == 0) {'EPCS-capable device required'}; }}";
	  


	  \$\$non_asmi_support="{{((\$SYS/device_family_id == 'CYCLONEIII') || 
                               (\$SYS/device_family_id == 'TARPON') || 
                               (\$SYS/device_family_id == 'STINGRAY') || 
                               (\$SYS/device_family_id == 'CYCLONEIVE') ||
                               (\$SYS/device_family_id == 'CYCLONEV') ||
                               (\$SYS/hardcopy_compatible == '1'))}}";
	  \$\$no_legacy_validation="{{\$WSA/ignore_legacy_check}}";
	  
	  \$\$sopc_asmi_setting="{{\$WSA/use_asmi_atom}}";	  
	  \$\$legacy_asmi_setting = "{{
            if (\$\$non_asmi_support)
              '0';
            else
              '1';
          }}";
	  
          \$WSA/use_asmi_atom = "{{
            if (\$\$no_legacy_validation)
              \$\$sopc_asmi_setting;
            else
              \$\$legacy_asmi_setting;
          }}";

          \$\$epcs_new_refdes = "{{ if (\$SWSA/flash_reference_designator == '') '--none--'; else \$SWSA/flash_reference_designator; }}";
          \$\$add_code = "{{ if (\$\$add) 1; else 0; }}";
          \$\$edit_code = "{{ if (\$\$edit) 1; else 0; }}";

          \$\$cfi_utilcomponentclass = "altera_avalon_cfi_flash";

          \$\$no_board_is_selected = 0;
          \$\$epcs_instances = "{{ sopc_slave_list('WIZARD_SCRIPT_ARGUMENTS/class=altera_avalon_epcs_flash_controller'); }}";
          \$\$cfi_component_dir = "{{ sopc_get_component_dir(\$\$cfi_utilcomponentclass); }}";

          code = "{{
            \$\$board_info = exec_and_wait(
              \$\$cfi_component_dir+'/cfi_flash.pl',
              'get_board_info',
              \$\$system_directory+'/'+\$SYSTEM+'.ptf',              
              \$\$/target_module_name,
              \$\$epcs_instances,
              'epcs_control_port',
              \$\$epcs_new_refdes,
              \$\$add_code,
              \$\$edit_code,
              \$SYSTEM/WIZARD_SCRIPT_ARGUMENTS/board_class,
              \$BUS/BOARD_INFO/altera_avalon_epcs_flash_controller/reference_designators
            );

            \$\$extra_info = exec_and_wait(
              \$\$cfi_component_dir+'/cfi_flash.pl',
              'get_extra_info',
              \$\$system_directory+'/'+\$SYSTEM+'.ptf',              
              \$\$/target_module_name,
              \$\$epcs_instances,
              'epcs_control_port',
              \$\$epcs_new_refdes,
              \$\$add_code,
              \$\$edit_code,
              \$SYSTEM/WIZARD_SCRIPT_ARGUMENTS/board_class,
              \$BUS/BOARD_INFO/altera_avalon_epcs_flash_controller/reference_designators
            );

            if (\$\$board_info == 'no_board')
            {
              \$\$no_board_is_selected = 1;
              \$\$error_message = '';
              \$\$message_message = 'No Matching Ref Des in System Board Target';
              \$\$warning_message = '';
              \$\$enabled_combo = 1;
              \$\$editable_combo = 1;
            }
            if (\$\$board_info == 'error')
            {
              \$\$error_message = \$\$extra_info;
              \$\$warning_message = '';
              \$\$message_message = '';
              \$\$enabled_combo = 1;
              \$\$editable_combo = 1;
            }
            if (\$\$board_info == 'warning')
            {
              \$\$warning_message = \$\$extra_info;
              \$\$error_message = '';
              \$\$message_message = '';
              \$\$enabled_combo = 1;
              \$\$editable_combo = 1;
            }
            if (\$\$board_info == '1_ref_des')
            {
              \$\$message_message = '';
              \$\$error_message = '';
              \$\$warning_message = '';
              \$\$enabled_combo = 0;
              \$\$editable_combo = 0;
            }
            if (\$\$board_info == 'some_ref_des')
            {
              \$\$error_message = '';
              \$\$warning_message = '';
              \$\$message_message = '';
              \$\$enabled_combo = 1;
              \$\$editable_combo = 0;
            }

          }}";

          ACTION initialize
          {
            code = "{{
              if (\$\$add)
              {
                if (\$\$board_info == 'some_ref_des')
                {
                  \$SWSA/flash_reference_designator = \$\$extra_info;
                  \$\$epcs_new_refdes = \$\$extra_info;
                }
                if (\$\$board_info == '1_ref_des')
                {
                  \$SWSA/flash_reference_designator = \$\$extra_info;
                  \$\$epcs_new_refdes = \$\$extra_info;
                }
              }
            }}";
          }

          PAGES main
          {
            PAGE 1
            {
              title = "Attributes";
              GROUP
              {
                title = "Board Info";
                COMBO refdes
                {
                  title = "Reference Designator (chip label): ";
                  key = "R";

                  values = "{{ \$BUS/BOARD_INFO/altera_avalon_epcs_flash_controller/reference_designators }}";

                  editable = "0";
                  enable = "{{ \$\$enabled_combo; }}";
                  message = "{{ \$\$message_message; }}";
                  DATA
                  {
                    \$SWSA/flash_reference_designator = "\$";
                    \$\$epcs_new_refdes = "\$";
                  }
                }
              }
            }
          }
        }

        WIZARD_UI bind
        {
          visible = "0";
          CONTEXT
          {
            WSA = "WIZARD_SCRIPT_ARGUMENTS";
          }
	  



	  \$\$non_asmi_support="{{((\$SYS/device_family_id == 'CYCLONEIII') || 
                               (\$SYS/device_family_id == 'STINGRAY') || 
                               (\$SYS/device_family_id == 'CYCLONEIVE') ||
                               (\$SYS/device_family_id == 'CYCLONEV') ||
                               (\$SYS/hardcopy_compatible == '1'))}}";
	  \$\$no_legacy_validation="{{\$WSA/ignore_legacy_check}}";
	  
	  \$\$sopc_asmi_setting="{{\$WSA/use_asmi_atom}}";	  
	  \$\$legacy_asmi_setting = "{{
            if (\$\$non_asmi_support)
              '0';
            else
              '1';
          }}";
	  
          \$WSA/use_asmi_atom = "{{
            if (\$\$no_legacy_validation)
              \$\$sopc_asmi_setting;
            else
              \$\$legacy_asmi_setting;
          }}";
		}

        LINKS
        {
            LINK help
            {
               title="Data Sheet";
               url="http://www.altera.com/literature/hb/nios2/n2cpu_nii51012.pdf";
            }
            LINK Cyclone_Data_Sheet
            {
               title="Manual for Nios 1c20 Cyclone Board";
               url="http://www.altera.com/literature/manual/mnl_nios2_board_cyclone_1c20.pdf";
            }
            LINK Cyclone_Schematics
            {
               title="Schematics for Nios 1c20 Cyclone Board";
               url="nios_cyclone_1c20/nios_1c20_board_schematic.pdf";
            }
        }
  }
}
];

  close FILE;
}



return 1;


