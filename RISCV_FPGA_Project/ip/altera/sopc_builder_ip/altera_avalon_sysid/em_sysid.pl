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
use europa_utils;
use strict;




my $project = e_project->new(@ARGV);

&make_sysid ($project->top(), $project);

$project->output();





sub hash
{
   my ($inputstring) = (@_);
   my @charlist = split (//, $inputstring);
   my @sumbytes = (0,0,0,0);
   my $i = 0;
   foreach my $char (@charlist) {
      $sumbytes[$i] += $char;
      $sumbytes[$i] &= 0xFF;
      $i = ($i + 1) % 4;
   }
   return ($sumbytes[3] << 24) | 
          ($sumbytes[2] << 16) | 
          ($sumbytes[1] <<  8) | 
          ($sumbytes[0] <<  0)  ;  
}





sub make_sysid
{
   my $legacy;
   my ($module, $project) = (@_);

   my $name = $module->name();
   my $wsa = $project->system_ptf()->{"MODULE $name"}->{WIZARD_SCRIPT_ARGUMENTS};
   my $slave_SBI = $project->system_ptf()->{"MODULE $name"}->{'SLAVE control_slave'}->{SYSTEM_BUILDER_INFO};
   my $SBI = $project->system_ptf()->{"MODULE $name"}->{SYSTEM_BUILDER_INFO};


   if(exists($wsa->{regenerate_values}) && $wsa->{regenerate_values} eq "0")
   {
      $legacy = "0";
   }
   else
   {
      $legacy = "1";
   }

   my $value0;
   my $value1;

   if($legacy)
   {
      $value0 = hash ($project->ptf_to_string());
      $value1 = time();
   }
   else
   {


      $value0 = $wsa->{id};
      $value1 = $wsa->{timestamp};
   }



   $value0 =~ s/u//g;
   $value1 =~ s/u//g;



   $wsa->{id} = $value0 . 'u';
   $wsa->{timestamp} = $value1 . 'u';





   my $marker = e_default_module_marker->new($module);

   e_port->adds(["address",       $slave_SBI->{Address_Width}, "in" ],
                ["readdata",      32,                          "out"],
                ["clock",         1,                           "in" ],
                ["reset_n",       1,                           "in" ],  );
   
   e_avalon_slave->add ({
           name => "control_slave",
           type_map => {
               address     =>  "address" ,
               readdata    =>  "readdata",
               clock       =>  "clock"   ,
               reset_n     =>  "reset_n" ,
           },
   });  
   e_assign->add ({lhs => "readdata", 
                   rhs => "address[0] ? $value1 : $value0",
                });   


   my $base_address = $slave_SBI->{Base_Address};
   $wsa->{MAKE} = {};    # Paranoia--purge whatever was there before.


























   my $wsa_make = $wsa->{MAKE};
   $wsa_make->{"TARGET verifysysid"} = {};
   my $target_section = $wsa_make->{'TARGET verifysysid'};
   $target_section->{"verifysysid"} = {};
   my $verifysysid_section = $target_section->{'verifysysid'};
   
   $verifysysid_section->{Target_File} = 'dummy_verifysysid_file';
   $verifysysid_section->{Is_Phony} = 1;
   $verifysysid_section->{Command} = 
       "nios2-download \$(JTAG_CABLE)                                --sidp=$base_address --id=$value0 --timestamp=$value1";


   $verifysysid_section->{All_Depends_On} = '0';  

   



   my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = 
       localtime ($value1);

   my $weekday = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat') [$wday];
   my $month =
   ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')[$mon];
   my $realyear = $year + 1900;
   my $ampm = "AM";
   if ($hour > 12) {
      $ampm = "PM";
      $hour -= 12;
   }
   my $hexid    = sprintf ("%08X", $value0);
   my $hexstamp = sprintf ("%08X", $value1);
   my $minstring = sprintf ("%02d", $min);

   $SBI->{View}->{Settings_Summary} = 
       "System ID (at last Generate):<br>" .
       " <b>$hexid</b>    (unique ID tag) <br>" .
       " <b>$hexstamp</b> (timestamp: $weekday $month $mday, $realyear \@$hour:$minstring $ampm)";

}





