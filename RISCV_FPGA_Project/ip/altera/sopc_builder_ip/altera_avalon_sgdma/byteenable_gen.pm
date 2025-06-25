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
use europa_all;

my $debug = 0;

sub byteenable_gen
{

    my $mod 	= shift;
    my $WSA 	= shift;
    my $proj 	= shift;


    my $WRITE_BLOCK_DATA_WIDTH = $WSA->{"write_block_data_width"};
    my $BYTEENABLE_WIDTH = $WRITE_BLOCK_DATA_WIDTH / 8;

    print "BYTEENABLE_WIDTH : $BYTEENABLE_WIDTH\n" if $debug;


    my $sixteen_bit_FSM 			= "sixteen_bit_byteenable_FSM";
    my $thirty_two_bit_FSM 			= "thirty_two_bit_byteenable_FSM";
    my $sixty_four_bit_FSM 			= "sixty_four_bit_byteenable_FSM";
    my $one_hundred_twenty_eight_bit_FSM	= "one_hundred_twenty_eight_bit_byteenable_FSM";
    my $two_hundred_fifty_six_bit_FSM		= "two_hundred_fifty_six_bit_byteenable_FSM";


    my $sixteen_bit_FSM_mod 			= $proj->make_new_private_module("$sixteen_bit_FSM");
    my $thirty_two_bit_FSM_mod 			= $proj->make_new_private_module("$thirty_two_bit_FSM");
    my $sixty_four_bit_FSM_mod 			= $proj->make_new_private_module("$sixty_four_bit_FSM");
    my $one_hundred_twenty_eight_bit_FSM_mod 	= $proj->make_new_private_module("$one_hundred_twenty_eight_bit_FSM");
    my $two_hundred_fifty_six_bit_FSM_mod 	= $proj->make_new_private_module("$two_hundred_fifty_six_bit_FSM");


    my @ports = (
    ["clk"=>1=>"input"],
    ["reset_n"=>1=>"input"],
    ["write_in"=>1=>"input"],
    ["byteenable_in"=>$BYTEENABLE_WIDTH=>"input"],
    ["waitrequest_out"=>1=>"output"],
    ["byteenable_out"=>$BYTEENABLE_WIDTH=>"output"],
    ["waitrequest_in"=>1=>"input"],
    );


    $mod->add_contents(
   	e_port->news(@ports),
    );

 if ($BYTEENABLE_WIDTH == 1) {



      $mod->add_contents(
        e_assign->new({lhs=>"byteenable_out", rhs=>"byteenable_in"}),
        e_assign->new({lhs=>"waitrequest_out", rhs=>"waitrequest_in"}),
      );
 } elsif ($BYTEENABLE_WIDTH == 2)   {



    &generate_sixteen_bit_FSM_mod($sixteen_bit_FSM_mod);

      $mod->add_contents(
    	e_instance->new({name=>"the_" . $sixteen_bit_FSM, module=>$sixteen_bit_FSM_mod}),
      );
 } elsif ($BYTEENABLE_WIDTH == 4)   {



    &generate_sixteen_bit_FSM_mod($sixteen_bit_FSM_mod);
    &generate_thirty_two_bit_FSM_mod($thirty_two_bit_FSM_mod,$sixteen_bit_FSM,$sixteen_bit_FSM_mod);

      $mod->add_contents(
    	e_instance->new({name=>"the_" . $thirty_two_bit_FSM, module=>$thirty_two_bit_FSM_mod}),
      );
 } elsif ($BYTEENABLE_WIDTH == 8)   {



    &generate_sixteen_bit_FSM_mod($sixteen_bit_FSM_mod);
    &generate_thirty_two_bit_FSM_mod($thirty_two_bit_FSM_mod,$sixteen_bit_FSM,$sixteen_bit_FSM_mod);
    &generate_sixty_four_bit_FSM_mod($sixty_four_bit_FSM_mod,$thirty_two_bit_FSM,$thirty_two_bit_FSM_mod);

      $mod->add_contents(
    	e_instance->new({name=>"the_" . $sixty_four_bit_FSM, module=>$sixty_four_bit_FSM_mod}),
      );
 } elsif ($BYTEENABLE_WIDTH == 16)   {




    &generate_sixteen_bit_FSM_mod($sixteen_bit_FSM_mod);
    &generate_thirty_two_bit_FSM_mod($thirty_two_bit_FSM_mod,$sixteen_bit_FSM,$sixteen_bit_FSM_mod);
    &generate_sixty_four_bit_FSM_mod($sixty_four_bit_FSM_mod,$thirty_two_bit_FSM,$thirty_two_bit_FSM_mod);
    &generate_one_hundred_twenty_eight_bit_FSM_mod($one_hundred_twenty_eight_bit_FSM_mod,$sixty_four_bit_FSM,$sixty_four_bit_FSM_mod);

      $mod->add_contents(
    	e_instance->new({name=>"the_" . $one_hundred_twenty_eight_bit_FSM, module=>$one_hundred_twenty_eight_bit_FSM_mod}),
      );
 } elsif ($BYTEENABLE_WIDTH == 32)   {




    &generate_sixteen_bit_FSM_mod($sixteen_bit_FSM_mod);
    &generate_thirty_two_bit_FSM_mod($thirty_two_bit_FSM_mod,$sixteen_bit_FSM,$sixteen_bit_FSM_mod);
    &generate_sixty_four_bit_FSM_mod($sixty_four_bit_FSM_mod,$thirty_two_bit_FSM,$thirty_two_bit_FSM_mod);
    &generate_one_hundred_twenty_eight_bit_FSM_mod($one_hundred_twenty_eight_bit_FSM_mod,$sixty_four_bit_FSM,$sixty_four_bit_FSM_mod);
    &generate_two_hundred_fifty_six_bit_FSM_mod($two_hundred_fifty_six_bit_FSM_mod,$two_hundred_fifty_six_bit_FSM,$two_hundred_fifty_six_bit_FSM_mod);

      $mod->add_contents(
    	e_instance->new({name=>"the_" . $two_hundred_fifty_six_bit_FSM, module=>$two_hundred_fifty_six_bit_FSM_mod}),
      );
}

}

sub port_declaration_for_FSM_mod {


    my $BYTEENABLE_WIDTH	= shift;
    my $mod			= shift;

    my @ports = (
    ["clk"=>1=>"input"],
    ["reset_n"=>1=>"input"],
    ["write_in"=>1=>"input"],
    ["byteenable_in"=>$BYTEENABLE_WIDTH=>"input"],
    ["waitrequest_out"=>1=>"output"],
    ["byteenable_out"=>$BYTEENABLE_WIDTH=>"output"],
    ["waitrequest_in"=>1=>"input"],
    );

    $mod->add_contents(
   	e_port->news(@ports),
    );
}


sub generate_sixteen_bit_FSM_mod {


    my $mod			= shift;

    my $byteenable_width	= 16/8;

    &port_declaration_for_FSM_mod($byteenable_width, $mod);

      $mod->add_contents(
        e_assign->new({lhs=>"byteenable_out", rhs=>"byteenable_in & {2{write_in}}"}),
        e_assign->new({lhs=>"waitrequest_out", rhs=>"waitrequest_in | ((write_in == 1) & (waitrequest_in == 1))"}),
      );
}

sub generate_thirty_two_bit_FSM_mod {


    my $mod			= shift;
    my $cascaded_submodule_name	= shift;
    my $cascaded_submodule	= shift;

    my $byteenable_width	= 32/8;

    &port_declaration_for_FSM_mod($byteenable_width, $mod);
    &FSM_condition($mod,$byteenable_width,$cascaded_submodule_name,$cascaded_submodule);

}


sub generate_sixty_four_bit_FSM_mod {


    my $mod			= shift;
    my $cascaded_submodule_name	= shift;
    my $cascaded_submodule	= shift;

    my $byteenable_width	= 64/8;

    &port_declaration_for_FSM_mod($byteenable_width, $mod);
    &FSM_condition($mod,$byteenable_width,$cascaded_submodule_name,$cascaded_submodule);

}

sub generate_one_hundred_twenty_eight_bit_FSM_mod {


    my $mod			= shift;
    my $cascaded_submodule_name	= shift;
    my $cascaded_submodule	= shift;

    my $byteenable_width	= 128/8;

    &port_declaration_for_FSM_mod($byteenable_width, $mod);
    &FSM_condition($mod,$byteenable_width,$cascaded_submodule_name,$cascaded_submodule);

}

sub generate_two_hundred_fifty_six_bit_FSM_mod {


    my $mod			= shift;
    my $cascaded_submodule_name	= shift;
    my $cascaded_submodule	= shift;

    my $byteenable_width	= 256/8;


    &port_declaration_for_FSM_mod($byteenable_width, $mod);
    &FSM_condition($mod,$byteenable_width,$cascaded_submodule_name,$cascaded_submodule);

}

sub FSM_condition {


    my $mod			= shift;
    my $byteenable_width	= shift;
    my $cascaded_submodule_name	= shift;
    my $cascaded_submodule	= shift;


    my $half_byteenable_width	= ($byteenable_width/2);

      $mod->add_contents(

        e_assign->new({lhs=>"partial_lower_half_transfer", rhs=>"byteenable_in[$half_byteenable_width-1:0] != 0"}),
        e_assign->new({lhs=>"full_lower_half_transfer", rhs=>"byteenable_in[$half_byteenable_width-1:0] == {$half_byteenable_width {1'b1}}"}),
        e_assign->new({lhs=>"partial_upper_half_transfer", rhs=>"byteenable_in[$byteenable_width-1:$half_byteenable_width] != 0"}),
        e_assign->new({lhs=>"full_upper_half_transfer", rhs=>"byteenable_in[$byteenable_width-1:$half_byteenable_width] == {$half_byteenable_width {1'b1}}"}),

      e_process->new({
      	reset => "reset_n",
      	reset_level => 0,
      	asynchronous_contents => [e_assign->new(["state_bit" => "0"])],
      	contents => [
        	e_if->new({
          	condition => "transfer_done == 1",
          	then =>["state_bit" => "0"],
          elsif => {
           	condition => "advance_to_next_state == 1",
            	then => ["state_bit" => "1"],
          	},
        	}),
      		],
      }), #end e_process

        e_assign->new({lhs=>"full_word_transfer", rhs=>"(full_lower_half_transfer == 1) & (full_upper_half_transfer == 1)"}),
        e_assign->new({lhs=>"two_stage_transfer", rhs=>"(full_word_transfer == 0) & (partial_lower_half_transfer == 1) & (partial_upper_half_transfer == 1)"}),
        e_assign->new({lhs=>"advance_to_next_state", rhs=>"(two_stage_transfer == 1) & (lower_stall == 0) & (write_in == 1) & (state_bit == 0) & (waitrequest_in == 0)"}),
        e_assign->new({lhs=>"transfer_done", rhs=>"	((full_word_transfer == 1) & (waitrequest_in == 0) & (write_in == 1)) | 
                         				((two_stage_transfer == 0) & (lower_stall == 0) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) |
                         				((two_stage_transfer == 1) & (state_bit == 1) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) "}),
        e_assign->new({lhs=>"lower_enable", rhs=>"	((write_in == 1) & (full_word_transfer == 1)) |
                        				((write_in == 1) & (two_stage_transfer == 0) & (partial_lower_half_transfer == 1)) |
                        				((write_in == 1) & (two_stage_transfer == 1) & (partial_lower_half_transfer == 1) & (state_bit == 0))"}),
        e_assign->new({lhs=>"upper_enable", rhs=>"	((write_in == 1) & (full_word_transfer == 1)) |
                        				((write_in == 1) & (two_stage_transfer == 0) & (partial_upper_half_transfer == 1)) |
                        				((write_in == 1) & (two_stage_transfer == 1) & (partial_upper_half_transfer == 1) & (state_bit == 1))"}),

    	e_instance->new({name=>"lower_" . $cascaded_submodule_name, module=>$cascaded_submodule,
                        port_map  => {
                        "clk"                   => "clk",
                        "reset_n"               => "reset_n",
                        "write_in"              => "lower_enable",
                        "byteenable_in"         => "byteenable_in[$half_byteenable_width-1:0]",
                        "waitrequest_out"       => "lower_stall",
                        "byteenable_out"        => "byteenable_out[$half_byteenable_width-1:0]",
                        "waitrequest_in"        => "waitrequest_in" },
			}),
    	e_instance->new({name=>"upper_" . $cascaded_submodule_name, module=>$cascaded_submodule,
                        port_map  => {
                        "clk"                   => "clk",
                        "reset_n"               => "reset_n",
                        "write_in"              => "upper_enable",
                        "byteenable_in"         => "byteenable_in[$byteenable_width-1:$half_byteenable_width]",
                        "waitrequest_out"       => "upper_stall",
                        "byteenable_out"        => "byteenable_out[$byteenable_width-1:$half_byteenable_width]",
                        "waitrequest_in"        => "waitrequest_in" },
      			}),

        e_assign->new({lhs=>"waitrequest_out", rhs=>"waitrequest_in | ((transfer_done == 0) & (write_in == 1))"}),
	);

 }

1;
