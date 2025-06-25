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
my $Address_Width = 3;
my $Data_Width = 16;


my $default_databits      = "8";
my $default_targetclock   = "20";
my $default_clockunits   = "MHz";
my $default_numslaves     = "1";
my $default_ismaster      = "1";
my $default_clockpolarity = "0";
my $default_clockphase    = "0";
my $default_lsbfirst      = "0";
my $default_extradelay    = "0";
my $default_targetssdelay = "100";
my $default_delayunits   = "us";          


my $default_clockmult;
($default_clockmult = $default_clockunits) =~ s/Hz//;
$default_clockmult = unit_prefix_to_num($default_clockmult);

my $default_delaymult;
($default_delaymult = $default_delayunits) =~ s/s//;
$default_delaymult = unit_prefix_to_num($default_delaymult);

sub validate_ASMI_parameters
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

sub make_asmi
{

  if (!@_)
  {
    return make_class_ptf();
  }
  
  die "Don't make an ASMI this way!\n";

}

  
my $global_magic_comment_string =
  "# This file created by em_asmi.pm.";
sub do_create_class_ptf
{
  my $sig = shift;




  


  my $do_create_class_ptf = 0;
  if (!-e "class.ptf")
  {
    $do_create_class_ptf = 1;
  }
  else
  {
    open FILE, "class.ptf" or ribbit("Can't open 'class.ptf'\n");
    while (<FILE>)
    {
      if (/$global_magic_comment_string/)
      {
        $do_create_class_ptf = 1;
        last;
      }
    }
    
    close FILE;
  }
  
  return $do_create_class_ptf;
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
CLASS altera_avalon_asmi
{
  SDK_GENERATION 
  {
    SDK_FILES 0
    {
      cpu_architecture = "always";
      short_type = "asmi";
      c_structure_type = "np_asmi *";
      c_header_file = "sdk/asmi_struct.h";
    }
    SDK_FILES 1
    {
      cpu_architecture = "always";
      toolchain = "gnu";
      asm_header_file = "sdk/asmi_struct.s";
    }
    SDK_FILES 2
    {
      cpu_architecture = "nios";
      toolchain = "gnu";
      sdk_files_dir = "sdk";
    }
    SDK_FILES 3
    {
      cpu_architecture = "else";
      sdk_files_dir = "sdk";
    }
  }
  ASSOCIATED_FILES
  {
    Add_Program  = "default";
    Edit_Program = "default";
    Generator_Program = "em_asmi.pl";
  }
  MODULE_DEFAULTS
  {
    class      = "altera_avalon_asmi";
    class_version = "2.1";
    SLAVE asmi_control_port
    {
      SYSTEM_BUILDER_INFO
      {
        Bus_Type                     = "avalon";
        Is_Nonvolatile_Storage       = "1";
        Is_Printable_Device          = "0";
        Address_Alignment            = "native";
        Address_Width                = "3";
        Data_Width                   = "16";
        Has_IRQ                      = "1";
        Read_Wait_States             = "$Read_Wait_States";
        Write_Wait_States            = "$Write_Wait_States";
      }
    }
    SYSTEM_BUILDER_INFO
    {
      Is_Enabled= "1";
      Instantiate_In_System_Module = "1";
      Required_Device_Family = "CYCLONE,CYCLONEII,STRATIXII,STRATIXIIGX";
      Fixed_Module_Name = "asmi";
    }
    WIZARD_SCRIPT_ARGUMENTS
    {
      databits      = "$default_databits";
      targetclock   = "$default_targetclock";
      clockunits    = "$default_clockunits";
      clockmult     = "$default_clockmult";
      numslaves     = "$default_numslaves";
      ismaster      = "$default_ismaster";
      clockpolarity = "$default_clockpolarity";
      clockphase    = "$default_clockphase";
      lsbfirst      = "$default_lsbfirst";
      extradelay    = "$default_extradelay";
      targetssdelay = "$default_targetssdelay";
      delayunits    = "$default_delayunits";
      delaymult     = "$default_delaymult";
      prefix        = "asmi_";
      CONSTANTS
      {
        CONSTANT na_asmi_64K
        {   
            value = "0";
            comment = "ASMI part is 64k bits";
        }
        CONSTANT na_asmi_1M
        {
            value = "0";
            comment = "ASMI part is 1M bits";
        }
        CONSTANT na_asmi_4M
        {
            value = "1";
            comment = "ASMI part is 4M bits";
        }
      }
    }
  }
  USER_INTERFACE
  {
        USER_LABELS
        {
            name="Active Serial Memory Interface";
            technology="Legacy Components";
        }
        LINKS
        {
            LINK help
            {
               title="Data Sheet";
               url="http://www.altera.com/literature/ds/ds_nios_asmi.pdf";
            }
            LINK Cyclone_Data_Sheet
            {
               title="Manual for Nios 1c20 Cyclone Board";
               url="http://www.altera.com/literature/manual/mnl_nios_board_cyclone_1c20.pdf";
            }
            LINK Cyclone_Schematics
            {
               title="Schematics for Nios 1c20 Cyclone Board";
               url="ftp://ftp.altera.com/outgoing/download/support/ip/processors/nios2/nios_cyclone_1c20/nios_1c20_board_schematic.pdf";
            }
        }

        WIZARD_UI default
        {
            title = "Active Serial Memory Interface";
            CONTEXT
            {
                WSA="WIZARD_SCRIPT_ARGUMENTS";
                SBI="SLAVE/SYSTEM_BUILDER_INFO";
                MSBI="SYSTEM_BUILDER_INFO";
                CONSTANTS = "WIZARD_SCRIPT_ARGUMENTS/CONSTANTS";
            }
            GROUP
            {
                indent = "17";
                align = "left";
                RADIO 
                { 
                    title = "EPCS1 Serial Configuration Device (1 Mbit)"; 
                    DATA
                    {
                        \$CONSTANTS/CONSTANT na_asmi_64K/value = "0";
                        \$CONSTANTS/CONSTANT na_asmi_1M/value = "1";
                        \$CONSTANTS/CONSTANT na_asmi_4M/value = "0";
                    }
                }
                RADIO 
                { 
                    title = "EPCS4 Serial Configuration Device (4 Mbit)"; 
                    DATA
                    {
                        \$CONSTANTS/CONSTANT na_asmi_64K/value = "0";
                        \$CONSTANTS/CONSTANT na_asmi_1M/value = "0";
                        \$CONSTANTS/CONSTANT na_asmi_4M/value = "1";
                    }
                }
            }
            IMAGE
            {
                file = "asmi.gif";
            }
        }
  }
}
];

  close FILE;
}

1;

