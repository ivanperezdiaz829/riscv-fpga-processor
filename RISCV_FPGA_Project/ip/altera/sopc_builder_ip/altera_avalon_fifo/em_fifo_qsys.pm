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
use e_lpm_scfifo;
use europa_all;        
use e_atlantic_master;
use e_atlantic_slave;
use strict;







my $avalonmm_write_slave_cp_name = "in";
my $avalonmm_read_slave_cp_name = "out";
my $avalonst_sink_cp_name = "in";
my $avalonst_source_cp_name = "out";
my $wrclk_control_slave_cp_name = "in_csr";
my $rdclk_control_slave_cp_name = "out_csr";
my $wrclk_reset_n;
my $rdclk_reset_n;
                 
my $Device_Family;
my $Use_Register;
my $Single_Clock_Mode;
my $FIFO_Depth;
my $Use_Write_Control;   
my $Use_Read_Control;
my $Use_IRQ;
my $Use_AvalonMM_Write_Slave;
my $Use_AvalonMM_Read_Slave;
my $Use_AvalonST_Sink;
my $Use_AvalonST_Source;
my $Use_Backpressure;
my $AvalonMM_AvalonMM_Data_Width;
my $Bits_Per_Symbol;
my $Symbols_Per_Beat;
my $AvalonMM_AvalonST_Data_Width;
my $Error_Width;
my $Channel_Width;
my $Use_Packet;

my $avalonMMBitsPerSymbol;
my $minimumCyclesPerSymbol;
my $maximumSymbolsPerCycle;
my $cyclesPerBeat; 
my $FIFO_Width;
my $module_name;


sub calculate_derived_parameters
{
    my $options = shift;
     



  $Device_Family                	= $options->{Device_Family}; 
  $Use_Register                 	= $options->{Use_Register}; 
  $Single_Clock_Mode            	= $options->{Single_Clock_Mode}; 
  $FIFO_Depth                   	= $options->{FIFO_Depth}; 
  $Use_Write_Control            	= $options->{Use_Write_Control}; 
  $Use_Read_Control             	= $options->{Use_Read_Control};   
  $Use_IRQ                      	= $options->{Use_IRQ}; 
  $Use_AvalonMM_Write_Slave     	= $options->{Use_AvalonMM_Write_Slave}; 
  $Use_AvalonMM_Read_Slave      	= $options->{Use_AvalonMM_Read_Slave}; 
  $Use_AvalonST_Sink            	= $options->{Use_AvalonST_Sink}; 
  $Use_AvalonST_Source          	= $options->{Use_AvalonST_Source};                    
  $Use_Backpressure             	= $options->{Use_Backpressure}; 
  $AvalonMM_AvalonMM_Data_Width 	= $options->{AvalonMM_AvalonMM_Data_Width}; 
  $Bits_Per_Symbol              	= $options->{Bits_Per_Symbol}; 
  $Symbols_Per_Beat             	= $options->{Symbols_Per_Beat}; 
  $AvalonMM_AvalonST_Data_Width 	= $options->{AvalonMM_AvalonST_Data_Width}; 
  $Error_Width                  	= $options->{Error_Width}; 
  $Channel_Width                	= $options->{Channel_Width};                         
  $Use_Packet                   	= $options->{Use_Packet}; 
                                 	  

    if($Single_Clock_Mode){
      $wrclk_reset_n = "reset_n";
      $rdclk_reset_n = "reset_n";
    }
    else {
      $wrclk_reset_n = "wrreset_n";
      $rdclk_reset_n = "rdreset_n";
    }





    $avalonMMBitsPerSymbol = 1 << ceil (log2($Bits_Per_Symbol));
    $minimumCyclesPerSymbol = ceil( $avalonMMBitsPerSymbol / $AvalonMM_AvalonST_Data_Width );
    $maximumSymbolsPerCycle = $AvalonMM_AvalonST_Data_Width / $avalonMMBitsPerSymbol;
    $cyclesPerBeat = ($Symbols_Per_Beat / $maximumSymbolsPerCycle);




    if($Use_AvalonMM_Write_Slave && 
       $Use_AvalonMM_Read_Slave &&
       !$Use_AvalonST_Source &&
       !$Use_AvalonST_Sink)
    {

        $FIFO_Width = $AvalonMM_AvalonMM_Data_Width;
    }
    elsif($Use_AvalonMM_Write_Slave &&
          $Use_AvalonST_Source &&
          !$Use_AvalonMM_Read_Slave &&
          !$Use_AvalonST_Sink)
    {


	$FIFO_Width = $maximumSymbolsPerCycle * $Bits_Per_Symbol;
    }
    elsif($Use_AvalonST_Sink &&
          $Use_AvalonMM_Read_Slave &&
          !$Use_AvalonMM_Write_Slave &&
          !$Use_AvalonST_Source)
    {

        $FIFO_Width = $maximumSymbolsPerCycle * $Bits_Per_Symbol;
    }
    elsif($Use_AvalonST_Sink &&
          $Use_AvalonST_Source &&
          !$Use_AvalonMM_Write_Slave &&
          !$Use_AvalonMM_Read_Slave)
    {




        my @avalonst_signals = &get_avalonst_signals($options, "");
        $FIFO_Width = 0;
        foreach(@avalonst_signals)
        {
            $FIFO_Width = $FIFO_Width + $_->[1];
        };
    }
    else
    {
        &ribbit("Invalid Combination of Interfaces.\n");
    }   
                                       
}

sub make_proj
{
    my $proj = shift;
    my $options = shift;
    $module_name = shift;
    
    &calculate_derived_parameters($options);




    if($Single_Clock_Mode)
    {

        &define_scfifo_with_controls($proj, $options);
        &make_scfifo($proj, $options);
    }
    else
    {

        &define_dcfifo_with_controls($proj, $options);
        &make_dcfifo($proj, $options);
    }




    if($Use_Write_Control)
    {
        &make_write_control($proj, $options);
    }




    if($Use_Read_Control)
    {
        &make_read_control($proj, $options);
    }
}


















sub define_scfifo
{
    my $proj = shift;
    my $device_family = shift;
    my $fifo_name = shift;
    my $fifo_depth = shift;
    my $fifo_width = shift;
    my $use_register = shift;
    my $use_usedw = shift;
    my $use_full = shift;
    my $use_empty = shift;

    my $use_eab = $use_register ? qq("OFF") : qq("ON");
    my $fifo_widthu = log2($fifo_depth);
    my $fifo_widthu_ceil = ceil (log2($fifo_depth));

    if ($fifo_widthu != $fifo_widthu_ceil)
    {
        &ribbit("FIFO depth need to be power of 2.");
    }
    

    my $mod = e_module->new({name => $fifo_name});
    $proj->add_module($mod);

    my %out_port_map_hash = 
    (
        q => e_signal->new([q => $fifo_width]),
    );

    if($use_full)
    {
	$out_port_map_hash{"full"} = e_signal->new([full => 1]);
    }

    if($use_empty)
    {
	$out_port_map_hash{"empty"} = e_signal->new([empty => 1]);
    }

    if($use_usedw)
    {
         $out_port_map_hash{"usedw"} = e_signal->new([usedw => $fifo_widthu]);
    }

    $mod->add_contents(
        e_blind_instance->new({
            name => 'single_clock_fifo',
            module => 'scfifo',
            use_sim_models => 1,
            in_port_map =>
            {
                aclr => 'aclr',
                clock => 'clock',
                data => e_signal->new([data => $fifo_width]),
                rdreq => 'rdreq',
                wrreq => 'wrreq',
            },
            out_port_map =>
            {
                 %out_port_map_hash,
            },

            parameter_map =>
            {
                add_ram_output_register => qq("OFF"),
                intended_device_family => qq("$device_family"),
                lpm_numwords => $fifo_depth,
                lpm_showahead => qq("OFF"),
                lpm_type => qq("scfifo"),
                lpm_width => $fifo_width,
                lpm_widthu => $fifo_widthu,
                overflow_checking => qq("ON"),
                underflow_checking => qq("ON"),
                use_eab => $use_eab,
            },
        }),
    );
}






















sub define_dcfifo
{
    my $proj = shift;
    my $device_family = shift;
    my $fifo_name = shift;
    my $fifo_depth = shift;
    my $fifo_width = shift;
    my $use_register = shift;
    my $use_rdusedw = shift;
    my $use_wrusedw = shift;
    my $use_rdfull = shift;
    my $use_wrempty = shift;
    my $use_wrfull = shift;
    my $use_rdempty = shift;

    my $use_eab = $use_register ? qq("OFF") : qq("ON");
    my $fifo_widthu = log2($fifo_depth);
    my $fifo_widthu_ceil = ceil (log2($fifo_depth));

    if ($fifo_widthu != $fifo_widthu_ceil)
    {
        &ribbit("FIFO depth need to be power of 2.");
    }

    my $mod = e_module->new({name => $fifo_name});
    $proj->add_module($mod);

    my %out_port_map_hash = 
    (
        q => e_signal->new([q => $fifo_width]),
    );


    if($use_wrfull)
    {
 	$out_port_map_hash{"wrusedw"} = e_signal->new([wrusedw => $fifo_widthu]);
        $out_port_map_hash{"wrfull"} = e_signal->new([int_wrfull => 1]);
	$mod->add_contents(
	    e_assign->new(
		{lhs => e_signal->new([wrfull => 1]),
		 rhs => "(wrusedw >= $fifo_depth-3) | int_wrfull"},
	    ),
	);
    }

    if($use_rdfull)
    {
        $out_port_map_hash{"rdusedw"} = e_signal->new([rdusedw => $fifo_widthu]);
        $out_port_map_hash{"rdfull"} = e_signal->new([int_rdfull => 1]);
	$mod->add_contents(
	    e_assign->new(
		{lhs => e_signal->new([rdfull => 1]),
		 rhs => "(rdusedw >= $fifo_depth-3) | int_rdfull"}
	    ),
	);
    }

    if($use_rdempty)
    {
	$out_port_map_hash{"rdempty"} = e_signal->new(["rdempty", 1, 1]);
    }

    if($use_wrempty)
    {
    	 $out_port_map_hash{"wrempty"} = e_signal->new(["wrempty", 1, 1]);
    }
 
    if($use_rdusedw)
    {
        $out_port_map_hash{"rdusedw"} = e_signal->new(["rdusedw", $fifo_widthu, 1]);
    }

    if($use_wrusedw)
    {
         $out_port_map_hash{"wrusedw"} = e_signal->new(["wrusedw", $fifo_widthu, 1]);
    }

    my %parameter_map_hash = 
    (
         intended_device_family => qq("$device_family"),
         lpm_numwords => $fifo_depth,
         lpm_showahead => qq("OFF"),
         lpm_type => qq("dcfifo"),
         lpm_width => $fifo_width,
         lpm_widthu => $fifo_widthu,
         overflow_checking => qq("ON"),
         underflow_checking => qq("ON"),
         use_eab => $use_eab,
    );

    if( ($device_family =~ m/stratix\s*iii/i) || ($device_family =~ m/cyclone\s*iii/i) )
    {

	$parameter_map_hash{"rdsync_delaypipe"} = 4;
	$parameter_map_hash{"wrsync_delaypipe"} = 4;
    }
    elsif ( ($device_family =~ m/stratix\s*ii/i) || ($device_family =~ m/cyclone\s*ii/i) )
    {

	$parameter_map_hash{"lpm_hint"} = qq("MAXIMIZE_SPEED=5,");
	$parameter_map_hash{"rdsync_delaypipe"} = 4;
	$parameter_map_hash{"wrsync_delaypipe"} = 4;
    }
    else
    {

        $parameter_map_hash{"add_ram_output_register"} = qq("OFF");
	$parameter_map_hash{"clocks_are_synchronized"} = qq("FALSE");
    }



    $mod->add_contents(
        e_blind_instance->new({
            name => 'dual_clock_fifo',
            module => 'dcfifo',
            use_sim_models => 1,
            in_port_map =>
            {
                aclr => 'aclr',
                data => e_signal->new([data => $fifo_width]),
                wrreq => 'wrreq',
                wrclk => 'wrclk',

                rdreq => 'rdreq',
                rdclk => 'rdclk',
            },
            out_port_map =>
            {
                 %out_port_map_hash,
            },

            parameter_map =>
            {
		%parameter_map_hash,
            },
        }),
    );
}






sub define_dcfifo_with_controls
{
    my $proj = shift;
    my $options = shift;
 
    my $use_rdusedw = 0;
    my $use_wrusedw = 0;
    my $use_rdfull = 0;
    my $use_wrempty = 0;
    my $use_wrfull = 1;
    my $use_rdempty = 1;


    my $need_wrlevel = 0;
    if($Use_AvalonST_Sink & $Use_Backpressure)
    {
	$need_wrlevel = 1;
    }


    my %port_map_hash = 
    (
        aclr => "~$wrclk_reset_n",
        data => 'data',
        wrreq => 'wrreq',
        wrclk => 'wrclk',
        rdreq => 'rdreq',
        rdclk => 'rdclk',
        q => 'q',
        rdempty => 'rdempty',
        wrfull => 'wrfull',
    );
    



    $proj->top()->add_contents
    (
        e_signal->new({name=>"rdempty",never_export=>1}),
        e_signal->new({name=>"wrfull",never_export=>1}),



    e_signal->new({name=>"rdreset_to_be_optimized",never_export=>1}),
    e_assign->new(
            {lhs => "rdreset_to_be_optimized",
             rhs => "$rdclk_reset_n"}
		),
    );

	if($Use_Backpressure)   
	{
		$port_map_hash{"wrreq"} = "wrreq_valid";
	}
	
    if($Use_Write_Control | $need_wrlevel)
    {
        $use_wrusedw = 1;
        $port_map_hash{"wrusedw"} = "wrusedw";
    }

    if($Use_Write_Control)
    {   
        $use_wrempty = 1;
        $port_map_hash{"wrempty"} = "wrempty";
    }

    if($Use_Read_Control)
    {
        $use_rdfull = 1;
        $use_rdusedw = 1;

        $port_map_hash{"rdfull"} = "rdfull";
        $port_map_hash{"rdusedw"} = "rdusedw";	
    }

    &define_dcfifo($proj,
                   $Device_Family,
                   $module_name."_dual_clock_fifo",
                   $FIFO_Depth,
                   $FIFO_Width,
                   $Use_Register,
                   $use_rdusedw,
                   $use_wrusedw,
                   $use_rdfull,
                   $use_wrempty,
		   $use_wrfull,
		   $use_rdempty
		  );







    my $minimum_threshold = 1;



    my $maximum_threshold = $FIFO_Depth-4;



    my $fifo_widthu = log2($FIFO_Depth);
    my $fifo_widthu_ceil = ceil (log2($FIFO_Depth));
    if ($fifo_widthu != $fifo_widthu_ceil)
    {
        &ribbit("FIFO depth need to be power of 2.");
    }
    my $level_width = $fifo_widthu + 1;








    my @status_bits_signals = &get_status_bits_signals();


    my $status_width = @status_bits_signals;

    my $mod = e_module->new({name => $module_name."_dcfifo_with_controls"});
    $proj->add_module($mod);

    $mod->add_contents(

        e_instance->new
        ({
            name => "the_dcfifo",
            module => $module_name."_dual_clock_fifo",
            port_map =>
                {
                    %port_map_hash,
                },
        }),


        e_signal->news(
            ["rdempty", 1, 1],
            ["wrfull", 1, 1],
        ),
    );







    if($Use_Write_Control | $need_wrlevel)
    {

        $mod->add_contents(
            e_assign->new(
                {lhs => e_signal->new(["wrlevel", $level_width]),

                 rhs => &concatenate("1'b0", "wrusedw")},
            ),
        );


	if($need_wrlevel)
	{
	    $mod->add_contents(
		e_signal->new(
		    ["wrlevel", $level_width, 1],
		),
	    );
	}
    }

	if($Use_Backpressure)   
    {
        $mod->add_contents(
        e_assign->news(
            {lhs => e_signal->new(["wrreq_valid", 1]),
             rhs => "wrreq & ~wrfull"},
		)
		);
	}
	






    if($Use_Write_Control)
    {
        $mod->add_contents(


            e_assign->news(
                {lhs => "wroverflow",
                 rhs => "wrreq & wrfull"},
                {lhs => "wrunderflow",
                 rhs => "rdreq & wrempty"},
            ),
        );
    }

    if($Use_Write_Control)
    {
        $mod->add_contents(
           e_assign->news(







                {lhs => e_signal->new(["wrclk_control_slave_threshold_writedata", $level_width]),
                 rhs => "(wrclk_control_slave_writedata < $minimum_threshold) ? $minimum_threshold :
                         (wrclk_control_slave_writedata > $maximum_threshold) ? $maximum_threshold :
                          wrclk_control_slave_writedata[$level_width-1:0]"},





                {lhs => "wrclk_control_slave_event_almostfull_signal",
                 rhs => "wrclk_control_slave_almostfull_pulse"},
                {lhs => "wrclk_control_slave_event_almostempty_signal",
                 rhs => "wrclk_control_slave_almostempty_pulse"},

		{lhs => "wrclk_control_slave_status_almostfull_signal",
		 rhs => "wrclk_control_slave_almostfull_signal"},
		{lhs => "wrclk_control_slave_status_almostempty_signal",
		 rhs => "wrclk_control_slave_almostempty_signal"},


                {lhs => "wrclk_control_slave_event_full_signal",
                 rhs => "wrclk_control_slave_full_pulse"},
                {lhs => "wrclk_control_slave_event_empty_signal",
                 rhs => "wrclk_control_slave_empty_pulse"},

		{lhs => "wrclk_control_slave_status_full_signal",
		 rhs => "wrclk_control_slave_full_signal"},
		{lhs => "wrclk_control_slave_status_empty_signal",
		 rhs => "wrclk_control_slave_empty_signal"},


                {lhs => "wrclk_control_slave_event_overflow_signal",
                 rhs => "wroverflow"},
                {lhs => "wrclk_control_slave_event_underflow_signal",
                 rhs => "wrunderflow"},

		{lhs => "wrclk_control_slave_status_overflow_signal",
		 rhs => "wroverflow"},
		{lhs => "wrclk_control_slave_status_underflow_signal",
		 rhs => "wrunderflow"},
                ),







            e_assign->news(
                {lhs => "wrclk_control_slave_empty_signal",
                 rhs => "wrempty"},
                {lhs => "wrclk_control_slave_empty_pulse",
                 rhs => "wrclk_control_slave_empty_signal & wrclk_control_slave_empty_n_reg"},
            ),

            e_register->new({
                out => "wrclk_control_slave_empty_n_reg",
                in  => "!wrclk_control_slave_empty_signal",
                clock => "wrclk",
                enable => 1,
                reset => "$wrclk_reset_n"}),





            e_assign->news(
                {lhs => "wrclk_control_slave_full_signal",
                 rhs => "wrfull"},
                {lhs => "wrclk_control_slave_full_pulse",
                 rhs => "wrclk_control_slave_full_signal & wrclk_control_slave_full_n_reg"},
            ),

            e_register->new({
                out => "wrclk_control_slave_full_n_reg",
                in  => "!wrclk_control_slave_full_signal",
                clock => "wrclk",
                enable => 1,
                reset => "$wrclk_reset_n"}),






            e_assign->news(
                {lhs => "wrclk_control_slave_almostempty_signal",
                 rhs => "wrlevel <= wrclk_control_slave_almostempty_threshold_register"},
                {lhs => "wrclk_control_slave_almostempty_pulse",
                 rhs => "wrclk_control_slave_almostempty_signal & wrclk_control_slave_almostempty_n_reg"},
            ),

            e_register->new({
                out => "wrclk_control_slave_almostempty_n_reg",
                in  => "!wrclk_control_slave_almostempty_signal",
                clock => "wrclk",
                enable => 1,
                reset => "$wrclk_reset_n"}),




            e_assign->news(
                {lhs => "wrclk_control_slave_almostfull_signal",
                 rhs => "wrlevel >= wrclk_control_slave_almostfull_threshold_register"},
                {lhs => "wrclk_control_slave_almostfull_pulse",
                 rhs => "wrclk_control_slave_almostfull_signal & wrclk_control_slave_almostfull_n_reg"},
            ),

            e_register->new({
                out => "wrclk_control_slave_almostfull_n_reg",
                in  => "!wrclk_control_slave_almostfull_signal",
                clock => "wrclk",
                enable => 1,
                reset => "$wrclk_reset_n"}),



            e_register->new({
                out => "wrclk_control_slave_almostempty_threshold_register",
                in  => "wrclk_control_slave_threshold_writedata",
                clock => "wrclk",
                async_value => $minimum_threshold,
                enable => "(wrclk_control_slave_address == 5) & wrclk_control_slave_write",
                reset => "$wrclk_reset_n"}),



            e_register->new({
                out => "wrclk_control_slave_almostfull_threshold_register",
                in  => "wrclk_control_slave_threshold_writedata",
                clock => "wrclk",
                async_value => $maximum_threshold,
                enable => "(wrclk_control_slave_address == 4) & wrclk_control_slave_write",
                reset => "$wrclk_reset_n"}),




            e_register->new({
                out => e_signal->new(["wrclk_control_slave_ienable_register", $status_width]),
                in => "wrclk_control_slave_writedata[$status_width-1:0]",
                clock => "wrclk",
                enable => "(wrclk_control_slave_address == 3) & wrclk_control_slave_write",
                reset => "$wrclk_reset_n",}),



            e_assign->new(
                {lhs => e_signal->new(["wrclk_control_slave_level_register", $level_width]),
                 rhs => "wrlevel"},
            ),
        );






        my @event_reg_bits = ();
        foreach (@status_bits_signals)
        {
            my $event_regout = "wrclk_control_slave_event_".$_->[0]."_q";
            my $event_set  = "wrclk_control_slave_event_".$_->[0]."_signal";
            my $event_reset = "wrclk_control_slave_write & 
                               (wrclk_control_slave_address == 2) &
                               wrclk_control_slave_writedata[".$_->[1]."]";
            push(@event_reg_bits, $event_regout);
            
            $mod->add_contents(
                e_register->new({
                    out => $event_regout,
                    clock => "wrclk",
                    enable => 1,
                    reset => "$wrclk_reset_n",
                    sync_set => $event_set,
                    sync_reset => "$event_reset",
                }),
            );
        }

        $mod->add_contents(
            e_assign->new(
                {lhs => e_signal->new(["wrclk_control_slave_event_register", $status_width]),
                 rhs => &concatenate(@event_reg_bits)},
            ),
        );

        if($Use_IRQ)
        {
            $mod->add_contents(
                e_assign->new(
                    {lhs => "wrclk_control_slave_irq",
                     rhs => "| (wrclk_control_slave_event_register & wrclk_control_slave_ienable_register)"},
                ),  
            );
        }




        my @status_reg_bits = ();
        foreach(@status_bits_signals)
        {
            my $status_regin = "wrclk_control_slave_status_".$_->[0]."_signal";
            my $status_regout = "wrclk_control_slave_status_".$_->[0]."_q";

            $mod->add_contents(
                e_register->new({
                    out => $status_regout,
                    in  => $status_regin,
                    clock => "wrclk",
                    enable => 1,
                    reset => "$wrclk_reset_n",
                }),
            );
            push(@status_reg_bits, $status_regout);
        }

        $mod->add_contents(
            e_assign->new(
                {lhs => e_signal->new(["wrclk_control_slave_status_register", $status_width]),
                 rhs => &concatenate(@status_reg_bits)},
            ),
        );





        my @wrclk_control_slave_read_mux_table = (
        "wrclk_control_slave_address == 0" => "wrclk_control_slave_level_register",
        "wrclk_control_slave_address == 1" => "wrclk_control_slave_status_register",
        "wrclk_control_slave_address == 2" => "wrclk_control_slave_event_register",
        "wrclk_control_slave_address == 3" => "wrclk_control_slave_ienable_register",
        "wrclk_control_slave_address == 4" => "wrclk_control_slave_almostfull_threshold_register",
        "wrclk_control_slave_address == 5" => "wrclk_control_slave_almostempty_threshold_register",
        );

        $mod->add_contents(
            e_mux->new({
                lhs => "wrclk_control_slave_read_mux",
                table => \@wrclk_control_slave_read_mux_table,
                type => "and-or",
                default => "wrclk_control_slave_level_register",}),

            e_register->new({
                out => "wrclk_control_slave_readdata",
                in  => "wrclk_control_slave_read_mux",
                clock => "wrclk",
                enable => "wrclk_control_slave_read",
                reset => "$wrclk_reset_n",
            }),
        );
    }
    






    if($Use_Read_Control)
    {

        $mod->add_contents(
            e_assign->new(
                {lhs => e_signal->new(["rdlevel", $level_width]),

		 rhs => &concatenate("1'b0", "rdusedw")},
            ),
        );

        $mod->add_contents(


            e_assign->news(
                {lhs => "rdoverflow",
                 rhs => "wrreq & rdfull"},
                {lhs => "rdunderflow",
                 rhs => "rdreq & rdempty"},
            ),
        );
    }

    if($Use_Read_Control)
    {
        $mod->add_contents(
           e_assign->news(







                {lhs => e_signal->new(["rdclk_control_slave_threshold_writedata", $level_width]),
                 rhs => "(rdclk_control_slave_writedata < $minimum_threshold) ? $minimum_threshold :
                         (rdclk_control_slave_writedata > $maximum_threshold) ? $maximum_threshold :
                          rdclk_control_slave_writedata[$level_width-1:0]"},





                {lhs => "rdclk_control_slave_event_almostfull_signal",
                 rhs => "rdclk_control_slave_almostfull_pulse"},
                {lhs => "rdclk_control_slave_event_almostempty_signal",
                 rhs => "rdclk_control_slave_almostempty_pulse"},

		{lhs => "rdclk_control_slave_status_almostfull_signal",
		 rhs => "rdclk_control_slave_almostfull_signal"},
		{lhs => "rdclk_control_slave_status_almostempty_signal",
		 rhs => "rdclk_control_slave_almostempty_signal"},


                {lhs => "rdclk_control_slave_event_full_signal",
                 rhs => "rdclk_control_slave_full_pulse"},
                {lhs => "rdclk_control_slave_event_empty_signal",
                 rhs => "rdclk_control_slave_empty_pulse"},

		{lhs => "rdclk_control_slave_status_full_signal",
		 rhs => "rdclk_control_slave_full_signal"},
		{lhs => "rdclk_control_slave_status_empty_signal",
		 rhs => "rdclk_control_slave_empty_signal"},


                {lhs => "rdclk_control_slave_event_overflow_signal",
                 rhs => "rdoverflow"},
                {lhs => "rdclk_control_slave_event_underflow_signal",
                 rhs => "rdunderflow"},

		{lhs=> "rdclk_control_slave_status_overflow_signal",
		 rhs => "rdoverflow"},
		{lhs=> "rdclk_control_slave_status_underflow_signal",
		 rhs => "rdunderflow"},
                ),







            e_assign->news(
                {lhs => "rdclk_control_slave_empty_signal",
                 rhs => "rdempty"},
                {lhs => "rdclk_control_slave_empty_pulse",
                 rhs => "rdclk_control_slave_empty_signal & rdclk_control_slave_empty_n_reg"},
            ),

            e_register->new({
                out => "rdclk_control_slave_empty_n_reg",
                in  => "!rdclk_control_slave_empty_signal",
                clock => "rdclk",
                enable => 1,
                reset => "$rdclk_reset_n"}),





            e_assign->news(
                {lhs => "rdclk_control_slave_full_signal",
                 rhs => "rdfull"},
                {lhs => "rdclk_control_slave_full_pulse",
                 rhs => "rdclk_control_slave_full_signal & rdclk_control_slave_full_n_reg"},
            ),

            e_register->new({
                out => "rdclk_control_slave_full_n_reg",
                in  => "!rdclk_control_slave_full_signal",
                clock => "rdclk",
                enable => 1,
                reset => "$rdclk_reset_n"}),






            e_assign->news(
                {lhs => "rdclk_control_slave_almostempty_signal",
                 rhs => "rdlevel <= rdclk_control_slave_almostempty_threshold_register"},
                {lhs => "rdclk_control_slave_almostempty_pulse",
                 rhs => "rdclk_control_slave_almostempty_signal & rdclk_control_slave_almostempty_n_reg"},
            ),

            e_register->new({
                out => "rdclk_control_slave_almostempty_n_reg",
                in  => "!rdclk_control_slave_almostempty_signal",
                clock => "rdclk",
                enable => 1,
                reset => "$rdclk_reset_n"}),




            e_assign->news(
                {lhs => "rdclk_control_slave_almostfull_signal",
                 rhs => "rdlevel >= rdclk_control_slave_almostfull_threshold_register"},
                {lhs => "rdclk_control_slave_almostfull_pulse",
                 rhs => "rdclk_control_slave_almostfull_signal & rdclk_control_slave_almostfull_n_reg"},
            ),

            e_register->new({
                out => "rdclk_control_slave_almostfull_n_reg",
                in  => "!rdclk_control_slave_almostfull_signal",
                clock => "rdclk",
                enable => 1,
                reset => "$rdclk_reset_n"}),



            e_register->new({
                out => "rdclk_control_slave_almostempty_threshold_register",
                in  => "rdclk_control_slave_threshold_writedata",
                clock => "rdclk",
                async_value => $minimum_threshold,
                enable => "(rdclk_control_slave_address == 5) & rdclk_control_slave_write",
                reset => "$rdclk_reset_n"}),



            e_register->new({
                out => "rdclk_control_slave_almostfull_threshold_register",
                in  => "rdclk_control_slave_threshold_writedata",
                clock => "rdclk",
                async_value => $maximum_threshold,
                enable => "(rdclk_control_slave_address == 4) & rdclk_control_slave_write",
                reset => "$rdclk_reset_n"}),




            e_register->new({
                out => e_signal->new(["rdclk_control_slave_ienable_register", $status_width]),
                in => "rdclk_control_slave_writedata[$status_width-1:0]",
                clock => "rdclk",
                enable => "(rdclk_control_slave_address == 3) & rdclk_control_slave_write",
                reset => "$rdclk_reset_n",}),



            e_assign->new(
                {lhs => e_signal->new(["rdclk_control_slave_level_register", $level_width]),
                 rhs => "rdlevel"},
            ),
        );






        my @event_reg_bits = ();
        foreach (@status_bits_signals)
        {
            my $event_regout = "rdclk_control_slave_event_".$_->[0]."_q";
            my $event_set  = "rdclk_control_slave_event_".$_->[0]."_signal";
            my $event_reset = "rdclk_control_slave_write & 
                               (rdclk_control_slave_address == 2) &
                               rdclk_control_slave_writedata[".$_->[1]."]";
            push(@event_reg_bits, $event_regout);
            
            $mod->add_contents(
                e_register->new({
                    out => $event_regout,
                    clock => "rdclk",
                    enable => 1,
                    reset => "$rdclk_reset_n",
                    sync_set => $event_set,
                    sync_reset => "$event_reset",
                }),
            );
        }

        $mod->add_contents(
            e_assign->new(
                {lhs => e_signal->new(["rdclk_control_slave_event_register", $status_width]),
                 rhs => &concatenate(@event_reg_bits)},
            ),
        );

        if($Use_IRQ)
        {
            $mod->add_contents(
                e_assign->new(
                    {lhs => "rdclk_control_slave_irq",
                     rhs => "| (rdclk_control_slave_event_register & rdclk_control_slave_ienable_register)"},
                ),  
            );
        }




        my @status_reg_bits = ();
        foreach(@status_bits_signals)
        {
            my $status_regin = "rdclk_control_slave_status_".$_->[0]."_signal";
            my $status_regout = "rdclk_control_slave_status_".$_->[0]."_q";

            $mod->add_contents(
                e_register->new({
                    out => $status_regout,
                    in  => $status_regin,
                    clock => "rdclk",
                    enable => 1,
                    reset => "$rdclk_reset_n",
                }),
            );
            push(@status_reg_bits, $status_regout);
        }

        $mod->add_contents(
            e_assign->new(
                {lhs => e_signal->new(["rdclk_control_slave_status_register", $status_width]),
                 rhs => &concatenate(@status_reg_bits)},
            ),
        );





        my @rdclk_control_slave_read_mux_table = (
        "rdclk_control_slave_address == 0" => "rdclk_control_slave_level_register",
        "rdclk_control_slave_address == 1" => "rdclk_control_slave_status_register",
        "rdclk_control_slave_address == 2" => "rdclk_control_slave_event_register",
        "rdclk_control_slave_address == 3" => "rdclk_control_slave_ienable_register",
        "rdclk_control_slave_address == 4" => "rdclk_control_slave_almostfull_threshold_register",
        "rdclk_control_slave_address == 5" => "rdclk_control_slave_almostempty_threshold_register",
        );

        $mod->add_contents(
            e_mux->new({
                lhs => "rdclk_control_slave_read_mux",
                table => \@rdclk_control_slave_read_mux_table,
                type => "and-or",
                default => "rdclk_control_slave_level_register",}),

            e_register->new({
                out => "rdclk_control_slave_readdata",
                in  => "rdclk_control_slave_read_mux",
                clock => "rdclk",
                enable => "rdclk_control_slave_read",
                reset => "$rdclk_reset_n",
            }),
        );
    }
}





sub define_scfifo_with_controls
{
    my $proj = shift;
    my $options = shift;

    my $use_usedw = 0;
    my $use_full = 1;
    my $use_empty = 1;


    my $need_level = 0;
    if($Use_AvalonST_Sink & $Use_Backpressure)
    {
	$need_level = 1; # need to export level register
    }

    my %port_map_hash = 
    (
        data => 'data',
        wrreq => 'wrreq',
        rdreq => 'rdreq',
        clock => 'clock',
        aclr => "~$wrclk_reset_n",

        q => 'q',
        full => 'full',
        empty => 'empty',
    );
    



    $proj->top()->add_contents
    (
        e_signal->new({name=>"empty",never_export=>1}),
        e_signal->new({name=>"full",never_export=>1}),
    );

    if($Use_Write_Control | $need_level)
    {
        $use_usedw = 1;
        $port_map_hash{"usedw"} = "usedw";
    }

	if($Use_Backpressure)  
    {
        $port_map_hash{"wrreq"} = "wrreq_valid";
    }
	
    &define_scfifo($proj,
                   $Device_Family,
                   $module_name."_single_clock_fifo",
                   $FIFO_Depth,
                   $FIFO_Width,
                   $Use_Register,
                   $use_usedw,
		   $use_full,
		   $use_empty);







    my $minimum_threshold = 1;
    my $maximum_threshold = $FIFO_Depth-1;



    my $fifo_widthu = log2($FIFO_Depth);
    my $fifo_widthu_ceil = ceil (log2($FIFO_Depth));
    if ($fifo_widthu != $fifo_widthu_ceil)
    {
        &ribbit("FIFO depth need to be power of 2.");
    }
    my $level_width = $fifo_widthu + 1;








    my @status_bits_signals = &get_status_bits_signals();


    my $status_width = @status_bits_signals; 

    my $mod = e_module->new({name => $module_name."_scfifo_with_controls"});
    $proj->add_module($mod);

    $mod->add_contents(

        e_instance->new
        ({
            name => "the_scfifo",
            module => $module_name."_single_clock_fifo",
            port_map =>
                {
                    %port_map_hash,
                },
        }),


        e_signal->news(
            ["full", 1, 1],
            ["empty", 1, 1],
        ),
    );







    if($Use_Write_Control | $need_level)
    {

        $mod->add_contents(
            e_assign->new(
                {lhs => e_signal->new(["level", $level_width]),
                 rhs => &concatenate("full", "usedw")},
            ),
        );


	if($need_level)
	{
	    $mod->add_contents(
		e_signal->new(
		    ["level", $level_width, 1],
		),
	    );
	}
    }
	
	
	if($Use_Backpressure)   
    {
        $mod->add_contents(
        e_assign->news(
            {lhs => e_signal->new(["wrreq_valid", 1]),
             rhs => "wrreq & ~full"},
		)
		);
	}
						  






    if($Use_Write_Control)
    {
        $mod->add_contents(


            e_assign->news(
                {lhs => "overflow",
                 rhs => "wrreq & full"},
                {lhs => "underflow",
                 rhs => "rdreq & empty"},
            ),
        );
    }


    if($Use_Write_Control)
    {
        $mod->add_contents(
           e_assign->news(







                {lhs => e_signal->new(["wrclk_control_slave_threshold_writedata", $level_width]),
                 rhs => "(wrclk_control_slave_writedata < $minimum_threshold) ? $minimum_threshold :
                         (wrclk_control_slave_writedata > $maximum_threshold) ? $maximum_threshold :
                          wrclk_control_slave_writedata[$level_width-1:0]"},





                {lhs => "wrclk_control_slave_event_almostfull_signal",
                 rhs => "wrclk_control_slave_almostfull_pulse"},
                {lhs => "wrclk_control_slave_event_almostempty_signal",
                 rhs => "wrclk_control_slave_almostempty_pulse"},

		{lhs => "wrclk_control_slave_status_almostfull_signal",
		 rhs => "wrclk_control_slave_almostfull_signal"},
		{lhs => "wrclk_control_slave_status_almostempty_signal",
		 rhs => "wrclk_control_slave_almostempty_signal"},


                {lhs => "wrclk_control_slave_event_full_signal",
                 rhs => "wrclk_control_slave_full_pulse"},
                {lhs => "wrclk_control_slave_event_empty_signal",
                 rhs => "wrclk_control_slave_empty_pulse"},

		{lhs => "wrclk_control_slave_status_full_signal",
		 rhs => "wrclk_control_slave_full_signal"},
		{lhs => "wrclk_control_slave_status_empty_signal",
		 rhs => "wrclk_control_slave_empty_signal"},


                {lhs => "wrclk_control_slave_event_overflow_signal",
                 rhs => "overflow"},
                 {lhs => "wrclk_control_slave_event_underflow_signal",
                 rhs => "underflow"},

		{lhs => "wrclk_control_slave_status_overflow_signal",
		 rhs => "overflow"},
		{lhs => "wrclk_control_slave_status_underflow_signal",
		 rhs => "underflow"},
                ),







            e_assign->news(
                {lhs => "wrclk_control_slave_empty_signal",
                 rhs => "empty"},
                {lhs => "wrclk_control_slave_empty_pulse",
                 rhs => "wrclk_control_slave_empty_signal & wrclk_control_slave_empty_n_reg"},
            ),

            e_register->new({
                out => "wrclk_control_slave_empty_n_reg",
                in  => "!wrclk_control_slave_empty_signal",
                clock => "clock",
                enable => 1,
                reset => "$wrclk_reset_n"}),





            e_assign->news(
                {lhs => "wrclk_control_slave_full_signal",
                 rhs => "full"},
                {lhs => "wrclk_control_slave_full_pulse",
                 rhs => "wrclk_control_slave_full_signal & wrclk_control_slave_full_n_reg"},
            ),

            e_register->new({
                out => "wrclk_control_slave_full_n_reg",
                in  => "!wrclk_control_slave_full_signal",
                clock => "clock",
                enable => 1,
                reset => "$wrclk_reset_n"}),






            e_assign->news(
                {lhs => "wrclk_control_slave_almostempty_signal",
                 rhs => "level <= wrclk_control_slave_almostempty_threshold_register"},
                {lhs => "wrclk_control_slave_almostempty_pulse",
                 rhs => "wrclk_control_slave_almostempty_signal & wrclk_control_slave_almostempty_n_reg"},
            ),

            e_register->new({
                out => "wrclk_control_slave_almostempty_n_reg",
                in  => "!wrclk_control_slave_almostempty_signal",
                clock => "clock",
                enable => 1,
                reset => "$wrclk_reset_n"}),




            e_assign->news(
                {lhs => "wrclk_control_slave_almostfull_signal",
                 rhs => "level >= wrclk_control_slave_almostfull_threshold_register"},
                {lhs => "wrclk_control_slave_almostfull_pulse",
                 rhs => "wrclk_control_slave_almostfull_signal & wrclk_control_slave_almostfull_n_reg"},
            ),

            e_register->new({
                out => "wrclk_control_slave_almostfull_n_reg",
                in  => "!wrclk_control_slave_almostfull_signal",
                clock => "clock",
                enable => 1,
                reset => "$wrclk_reset_n"}),



            e_register->new({
                out => "wrclk_control_slave_almostempty_threshold_register",
                in  => "wrclk_control_slave_threshold_writedata",
                clock => "clock",
                async_value => $minimum_threshold,
                enable => "(wrclk_control_slave_address == 5) & wrclk_control_slave_write",
                reset => "$wrclk_reset_n"}),



            e_register->new({
                out => "wrclk_control_slave_almostfull_threshold_register",
                in  => "wrclk_control_slave_threshold_writedata",
                clock => "clock",
                async_value => $maximum_threshold,
                enable => "(wrclk_control_slave_address == 4) & wrclk_control_slave_write",
                reset => "$wrclk_reset_n"}),




            e_register->new({
                out => e_signal->new(["wrclk_control_slave_ienable_register", $status_width]),
                in => "wrclk_control_slave_writedata[$status_width-1:0]",
                clock => "clock",
                enable => "(wrclk_control_slave_address == 3) & wrclk_control_slave_write",
                reset => "$wrclk_reset_n",}),



            e_assign->new(
                {lhs => e_signal->new(["wrclk_control_slave_level_register", $level_width]),
                 rhs => "level"},
            ),
        );






        my @event_reg_bits = ();
        foreach (@status_bits_signals)
        {
            my $event_regout = "wrclk_control_slave_event_".$_->[0]."_q";
            my $event_set  = "wrclk_control_slave_event_".$_->[0]."_signal";
            my $event_reset = "wrclk_control_slave_write & 
                               (wrclk_control_slave_address == 2) &
                               wrclk_control_slave_writedata[".$_->[1]."]";
            push(@event_reg_bits, $event_regout);
            
            $mod->add_contents(
                e_register->new({
                    out => $event_regout,
                    clock => "clock",
                    enable => 1,
                    reset => "$wrclk_reset_n",
                    sync_set => $event_set,
                    sync_reset => "$event_reset",
                }),
            );
        }

        $mod->add_contents(
            e_assign->new(
                {lhs => e_signal->new(["wrclk_control_slave_event_register", $status_width]),
                 rhs => &concatenate(@event_reg_bits)},
            ),
        );

        if($Use_IRQ)
        {
            $mod->add_contents(
                e_assign->new(
                    {lhs => "wrclk_control_slave_irq",
                     rhs => "| (wrclk_control_slave_event_register & wrclk_control_slave_ienable_register)"},
                ),  
            );
        }




        my @status_reg_bits = ();
        foreach(@status_bits_signals)
        {
            my $status_regin = "wrclk_control_slave_status_".$_->[0]."_signal";
            my $status_regout = "wrclk_control_slave_status_".$_->[0]."_q";

            $mod->add_contents(
                e_register->new({
                    out => $status_regout,
                    in  => $status_regin,
                    clock => "clock",
                    enable => 1,
                    reset => "$wrclk_reset_n",
                }),
            );
            push(@status_reg_bits, $status_regout);
        }

        $mod->add_contents(
            e_assign->new(
                {lhs => e_signal->new(["wrclk_control_slave_status_register", $status_width]),
                 rhs => &concatenate(@status_reg_bits)},
            ),
        );





        my @wrclk_control_slave_read_mux_table = (
        "wrclk_control_slave_address == 0" => "wrclk_control_slave_level_register",
        "wrclk_control_slave_address == 1" => "wrclk_control_slave_status_register",
        "wrclk_control_slave_address == 2" => "wrclk_control_slave_event_register",
        "wrclk_control_slave_address == 3" => "wrclk_control_slave_ienable_register",
        "wrclk_control_slave_address == 4" => "wrclk_control_slave_almostfull_threshold_register",
        "wrclk_control_slave_address == 5" => "wrclk_control_slave_almostempty_threshold_register",
        );

        $mod->add_contents(
            e_mux->new({
                lhs => "wrclk_control_slave_read_mux",
                table => \@wrclk_control_slave_read_mux_table,
                type => "and-or",
                default => "wrclk_control_slave_level_register",}),

            e_register->new({
                out => "wrclk_control_slave_readdata",
                in  => "wrclk_control_slave_read_mux",
                clock => "clock",
                enable => "wrclk_control_slave_read",
                reset => "$wrclk_reset_n",
            }),
        );
    }
}














sub make_scfifo
{
    my $proj = shift;
    my $options = shift;

    e_instance->add({
        name => "the_scfifo_with_controls",
        module => $module_name."_scfifo_with_controls",
    });                             
    
    if($Use_AvalonMM_Write_Slave && 
       $Use_AvalonMM_Read_Slave &&
       !$Use_AvalonST_Source &&
       !$Use_AvalonST_Sink)
    {

        &make_avalonmm_avalonmm_interface($proj, $options);
    }
    elsif($Use_AvalonMM_Write_Slave &&
          $Use_AvalonST_Source &&
          !$Use_AvalonMM_Read_Slave &&
          !$Use_AvalonST_Sink)
    {

        &make_avalonmm_avalonst_interface($proj, $options);
    }
    elsif($Use_AvalonST_Sink &&
          $Use_AvalonMM_Read_Slave &&
          !$Use_AvalonMM_Write_Slave &&
          !$Use_AvalonST_Source)
    {

        &make_avalonst_avalonmm_interface($proj, $options);
    }
    elsif($Use_AvalonST_Sink &&
          $Use_AvalonST_Source &&
          !$Use_AvalonMM_Write_Slave &&
          !$Use_AvalonMM_Read_Slave)
    {

        &make_avalonst_avalonst_interface($proj, $options);
    }
    else
    {
        &ribbit("Invalid Combination of Interfaces.\n");
    }
}








sub make_avalonst_avalonst_interface
{
    my $proj = shift;
    my $options = shift;

    my @avalonst_sink_signals = &get_avalonst_signals($options, "");
    my @avalonst_source_signals = &get_avalonst_signals($options, "");

    my @avalonst_special_signals = ([valid => 1]);

    if($Use_Backpressure)
    {
        push(@avalonst_special_signals, [ready => 1]);
    }

    e_signal->adds(map {["avalonst_sink_".$_->[0] => $_->[1]]} @avalonst_sink_signals, @avalonst_special_signals);
    e_signal->adds(map {["avalonst_source_".$_->[0] => $_->[1]]} @avalonst_source_signals, @avalonst_special_signals);


    my $avalonst_sink_type_map = { map {"avalonst_sink_".$_->[0] => $_->[0]}
                                         (@avalonst_sink_signals, @avalonst_special_signals) };

    my $avalonst_source_type_map = { map {"avalonst_source_".$_->[0] => $_->[0]}
                                         (@avalonst_source_signals, @avalonst_special_signals) };
    
    $avalonst_sink_type_map->{"$wrclk_reset_n"} = "reset_n";
    $avalonst_source_type_map->{"$rdclk_reset_n"} = "reset_n";

    if($Single_Clock_Mode)
    {
        $avalonst_sink_type_map->{"wrclock"} = "clk";
        $avalonst_source_type_map->{"wrclock"} = "clk";
    }
    else
    {
        $avalonst_sink_type_map->{"wrclock"} = "clk";
        $avalonst_source_type_map->{"rdclock"} = "clk";
    }

    e_atlantic_slave->add({
        name => $avalonst_sink_cp_name,
        type_map => $avalonst_sink_type_map,
    });


    e_atlantic_master->add({
        name => $avalonst_source_cp_name,
        type_map => $avalonst_source_type_map,
    });

    my $total_width = 0;
    foreach(@avalonst_sink_signals)
    {
        $total_width = $total_width + $_->[1];
    };

    e_assign->adds(
        {lhs => e_signal->add([avalonst_sink_signals => $total_width]),
         rhs => &concatenate(map{"avalonst_sink_".$_->[0]}@avalonst_sink_signals)},
        {lhs => &concatenate(map{"avalonst_source_".$_->[0]}@avalonst_source_signals),
         rhs => e_signal->add([avalonst_source_signals => $total_width])},
    );

	if($Use_Backpressure)   
	{

	e_assign->adds(
		{lhs => e_signal->add(["no_stop_write" =>1]),
		 rhs => "(ready_selector & ready_1) | (!ready_selector & ready_0)"},
    );
			
	e_assign->add(
        {lhs => "wrreq",
         rhs => "avalonst_sink_valid & no_stop_write_d1"}, 
	);

			
	
	if($Single_Clock_Mode)
    {

















		e_assign->adds(
		{lhs => "ready_1",
		 rhs => "!full"},
		{lhs => "ready_0",
		 rhs => "!full & !avalonst_sink_valid"},
	    );
		

		my $last_word = $FIFO_Depth-1; 
	    e_assign->adds(
		{lhs => "ready_selector",
		 rhs => "(level < $last_word)"},
	    );
		
		
		e_register->add({
                out => "no_stop_write_d1",
                in  => "no_stop_write",
                clock => "clock",
                enable => 1,
                reset => "$wrclk_reset_n",}
		);
	}
	else
	{

















		e_assign->adds(
		{lhs => "ready_1",
		 rhs => "!wrfull"},
		{lhs => "ready_0",
		 rhs => "!wrfull & !avalonst_sink_valid"},
	    );


	    my $last_word = $FIFO_Depth-4;  ## DCFIFO maximum depth is DEPTH-3, hence last word is DEPTH-4
	    e_assign->adds(
		{lhs => "ready_selector",
		 rhs => "(wrlevel < $last_word)"},
	    );
		
	
		e_register->add({
                out => "no_stop_write_d1",
                in  => "no_stop_write",
                clock => "wrclk",
                enable => 1,
                reset => "$wrclk_reset_n",}
		);

	}
	}
	else
	{
		e_assign->add(
        {lhs => "wrreq",
         rhs => "avalonst_sink_valid"}, 
	);
	}
	
	
    if($Single_Clock_Mode)
    {

        e_assign->adds(
            {lhs => "data",
             rhs => "avalonst_sink_signals"},
            {lhs => "avalonst_source_signals",
             rhs => "q"},
            {lhs => "clock",
             rhs => "wrclock"},
        );

        if($Use_Backpressure)
        {

        e_assign->adds(
			{lhs => "avalonst_sink_ready",
			rhs => "no_stop_write"},   
        );
		}


        if($Use_Backpressure)
        {
            e_register->adds({
                out => "avalonst_source_valid",
                in  => "avalonst_source_ready & !empty",
                clock => "clock",
                enable => 1,
                reset => "$rdclk_reset_n",
            });

            e_assign->adds(
                {lhs => "rdreq",
                 rhs => "avalonst_source_ready & !empty"},
            );
        }
        else
        {
            e_register->adds({
                out => "avalonst_source_valid",
                in  => "!empty",
                clock => "clock",
                enable => 1,
                reset => "$rdclk_reset_n",
            });


            e_assign->adds(
                {lhs => "rdreq",
                 rhs => "!empty"},
            );
        }
    }
    else
    {   # Dual Clock Mode


        e_assign->adds(
            {lhs => "data",
             rhs => "avalonst_sink_signals"},
            {lhs => "avalonst_source_signals",
             rhs => "q"},
            {lhs => "wrclk",
             rhs => "wrclock"},
            {lhs => "rdclk",
             rhs => "rdclock"},
        );

        if($Use_Backpressure)
        {

        e_assign->adds(
			{lhs => "avalonst_sink_ready",
			rhs => "no_stop_write & no_stop_write_d1"},   
        );
        }



        if($Use_Backpressure)
        {
            e_register->adds({
                out => "avalonst_source_valid",
                in  => "avalonst_source_ready & !rdempty",
                clock => "rdclock",
                enable => 1,
                reset => "$rdclk_reset_n",
            });

            e_assign->adds(
                {lhs => "rdreq",
                 rhs => "avalonst_source_ready & !rdempty"},
            );
        }
        else
        {
            e_register->adds({
                out => "avalonst_source_valid",
                in  => "!rdempty",
                clock => "rdclock",
                enable => 1,
                reset => "$rdclk_reset_n",
            });


            e_assign->adds(
                {lhs => "rdreq",
                 rhs => "!rdempty"},
            );
        }
    }
}








sub get_avalonst_signals
{
    my $options = shift;
    my $prefix_name = shift;

    my @avalonst_signals = ();


    my $error_width = $Error_Width;
    my $channel_width = $Channel_Width;
    my $empty_width = ceil(log2($Symbols_Per_Beat));
    my $data_width = $Symbols_Per_Beat * $Bits_Per_Symbol;

    if($Use_Packet)
    {
        push(@avalonst_signals,
             [$prefix_name."startofpacket" => 1],
             [$prefix_name."endofpacket" => 1]);

        if($empty_width > 0)
        {
            push(@avalonst_signals, [$prefix_name."empty" => $empty_width]);
        }
    }

    if($channel_width > 0)
    {
        push(@avalonst_signals, [$prefix_name."channel" => $channel_width]);
    }

    if($error_width > 0)
    {
        push(@avalonst_signals, [$prefix_name."error" => $error_width]);
    }

    push(@avalonst_signals, [$prefix_name."data" => $data_width]);

    return @avalonst_signals;
}








sub make_avalonst_avalonmm_interface
{
    my $proj = shift;
    my $options = shift;

    if($cyclesPerBeat == 1)
    {



        &create_avalonst_to_avalonmm_with_one_read_per_beat($proj, $options);
    }
    else
    {
        &ribbit("Configuration not supported: Bits Per Symbol = $Bits_Per_Symbol; Symbols Per Beat = $Symbols_Per_Beat\n");
    }
}






sub create_avalonst_to_avalonmm_with_one_read_per_beat
{
    my $proj = shift;
    my $options = shift;

    if($cyclesPerBeat != 1)
    {
         &ribbit("Mapping one AvalonMM read from one AvalonST beat is
                 incorrect because the interface pair need $cyclesPerBeat 
                 AvalonMM read per AvalonST beat\n");
    }

    my @read_slave_signals = &get_avalonmm_slave_signals($proj, $options, "avalonmm_read_slave", $avalonmm_read_slave_cp_name);


    my $read_slave_type_map = {map {"avalonmm_read_slave_".$_->[0] => $_->[0]}
                                    @read_slave_signals};

    $read_slave_type_map->{"$rdclk_reset_n"} = "reset_n";
    if($Single_Clock_Mode)
    {
	$read_slave_type_map->{"wrclock"} = "clk";
    }
    else
    {
	$read_slave_type_map->{"rdclock"} = "clk";
    }

    e_avalon_slave->add({
        name => $avalonmm_read_slave_cp_name,
        type_map => $read_slave_type_map,
    });

    e_signal->adds(map{["avalonmm_read_slave_".$_->[0],
                        $_->[1]]} @read_slave_signals);


    if($Use_Backpressure)
    {



	e_assign->adds(
	    {lhs => e_signal->add(["deassert_waitrequest" => 1]),
	     rhs => "avalonmm_read_slave_address & avalonmm_read_slave_read"},
	);

        if($Single_Clock_Mode)
        {
            e_assign->adds(
                {lhs => "avalonmm_read_slave_waitrequest",
                 rhs => "!deassert_waitrequest & empty"},
            );
        }
        else
        {
            e_assign->adds(
                {lhs => "avalonmm_read_slave_waitrequest",
                 rhs => "!deassert_waitrequest & rdempty"},
            );
        }
    }




    &define_map_avalonst_to_avalonmm($proj, $options);
    e_instance->add
    ({
        name => "the_map_avalonst_to_avalonmm",
        module => $module_name."_map_avalonst_to_avalonmm",
        port_map =>
            {
                avalonmm_data => 'avalonmm_map_data_out',
                avalonst_data => 'avalonst_map_data_in',
            },
    });


    my $rdreq_driver = "(avalonmm_read_slave_address == 0) & avalonmm_read_slave_read";

    if($Single_Clock_Mode)
    {
        e_assign->adds(
            {lhs => "clock",
             rhs => "wrclock"}, 
        );
    }
    else
    {
        e_assign->adds(
            {lhs => "wrclk",
             rhs => "wrclock"},
            {lhs => "rdclk",
             rhs => "rdclock"},
        );
    }

    e_assign->adds(
        {lhs => "rdreq_driver",
         rhs => $rdreq_driver},
        {lhs => "avalonst_map_data_in",
         rhs => "q"},
        {lhs => "rdreq",
         rhs => "rdreq_driver"},
    );


    e_assign->adds(
        {lhs => "data",
         rhs => e_signal->add(["avalonst_sink_data" => $FIFO_Width])},
    );

	if($Use_Backpressure)
	{
	e_assign->adds(
		{lhs => "wrreq",
         rhs => "avalonst_sink_valid & no_stop_write_d1"}, # FIFO checks for overflow 
	);
	

	e_assign->adds(
		{lhs => e_signal->add(["no_stop_write" =>1]),
		 rhs => "(ready_selector & ready_1) | (!ready_selector & ready_0)"},
            );
			
	if($Single_Clock_Mode)
    {

















		e_assign->adds(
		{lhs => "ready_1",
		 rhs => "!full"},
		{lhs => "ready_0",
		 rhs => "!full & !avalonst_sink_valid"},
	    );
		

		my $last_word = $FIFO_Depth-1; 
	    e_assign->adds(
		{lhs => "ready_selector",
		 rhs => "(level < $last_word)"},
	    );
		

		e_register->add({
                out => "no_stop_write_d1",
                in  => "no_stop_write",
                clock => "clock",
                enable => 1,
                reset => "$wrclk_reset_n",}
		);
	}
	else
	{

















		e_assign->adds(
		{lhs => "ready_1",
		 rhs => "!wrfull"},
		{lhs => "ready_0",
		 rhs => "!wrfull & !avalonst_sink_valid"},
	    );


	    my $last_word = $FIFO_Depth-4;  ## DCFIFO maximum depth is DEPTH-3, hence last word is DEPTH-4
	    e_assign->adds(
		{lhs => "ready_selector",
		 rhs => "(wrlevel < $last_word)"},
	    );
		

		e_register->add({
                out => "no_stop_write_d1",
                in  => "no_stop_write",
                clock => "wrclk",
                enable => 1,
                reset => "$wrclk_reset_n",}
		);
	}
	}
	else
	{
	e_assign->add(
        {lhs => "wrreq",
         rhs => "avalonst_sink_valid"}, 
	);
	}
	
    if($Use_Backpressure)
    {

            e_assign->adds(
		{lhs => "avalonst_sink_ready",
		 rhs => "no_stop_write & no_stop_write_d1"}, 
            );
    }








    

    my $need_fifo_other_info = 0;
    
    if (($Error_Width > 0) || ($Channel_Width > 0) || ($Use_Packet))
    {
        $need_fifo_other_info = 1;
    }
    
    if ($need_fifo_other_info)
    {
        my $empty_width = ceil(log2($Symbols_Per_Beat));
        my $packet_info_width = 0;
        my @avalonst_other_info_signals = ();
    
        if($Error_Width > 0)
        {
            e_signal->add(
                [avalonst_sink_error => $Error_Width],
            );
            push(@avalonst_other_info_signals, "avalonst_sink_error");
        }
    
    
        if($Channel_Width > 0)
        {
            e_signal->add(
                [avalonst_sink_channel => $Channel_Width],
            );
            push(@avalonst_other_info_signals, "avalonst_sink_channel");
        }
    
        if($Use_Packet)
        {
            $packet_info_width = $empty_width + 2;
            if($empty_width!=0)
            {
                e_signal->add(
                    [avalonst_sink_empty => $empty_width],
                );
                push(@avalonst_other_info_signals, "avalonst_sink_empty");
            }
    
            e_signal->adds(
                [avalonst_sink_startofpacket => 1],
                [avalonst_sink_endofpacket => 1],
            );
            push(@avalonst_other_info_signals, "avalonst_sink_endofpacket", "avalonst_sink_startofpacket");
        }
    
        my $other_info_fifo_width = $packet_info_width + $Error_Width + $Channel_Width;
    

        if($Single_Clock_Mode)
        {
            &define_scfifo($proj,
                           $Device_Family,
                           $module_name."_single_clock_fifo_for_other_info",
                           $FIFO_Depth,
                           $other_info_fifo_width,
                           $Use_Register,
                           0,
    		       0,
    		       0);
    
			if($Use_Backpressure)
			{

            e_instance->add
            ({
                name => "the_scfifo_other_info",
                module => $module_name."_single_clock_fifo_for_other_info",
                port_map =>
                    {
                        data => &concatenate(@avalonst_other_info_signals),
                        wrreq => 'avalonst_sink_valid & no_stop_write_d1', # FIFO take care of overflow checking 
                        rdreq => $rdreq_driver,    
                        clock => 'clock',    # Use common clock
                        aclr => "~$wrclk_reset_n",
    
                        q => 'avalonst_other_info_map_in',
                    },
            });
			}
			else
			{
			e_instance->add
            ({
                name => "the_scfifo_other_info",
                module => $module_name."_single_clock_fifo_for_other_info",
                port_map =>
                    {
                        data => &concatenate(@avalonst_other_info_signals),
                        wrreq => 'avalonst_sink_valid', # FIFO take care of overflow checking 
                        rdreq => $rdreq_driver,    
                        clock => 'clock',    # Use common clock
                        aclr => "~$wrclk_reset_n",
                        q => 'avalonst_other_info_map_in',
                    },
            });
			}
        }
        else
        {
            &define_dcfifo($proj,
                           $Device_Family,
                           $module_name."_dual_clock_fifo_for_other_info",
                           $FIFO_Depth,
                           $other_info_fifo_width,
                           $Use_Register,
                           0, #no rdusedw
                           0, #no wrusedw
                           0, #no rdfull
                           0, #no wrempty
                           0, #no wrfull
                           0);#no rdempty
    
			if($Use_Backpressure)
			{

            e_instance->add
            ({
                name => "the_dcfifo_other_info",
                module => $module_name."_dual_clock_fifo_for_other_info",
                port_map =>
                    {
                        data => &concatenate(@avalonst_other_info_signals),
                        wrreq => 'avalonst_sink_valid & no_stop_write_d1', # FIFO take care of overflow checking  
                        rdreq => $rdreq_driver,    
                        wrclk => 'wrclk',
                        rdclk => 'rdclk',
                        aclr => "~$wrclk_reset_n",
    
                        q => 'avalonst_other_info_map_in',
                    },
            });
			}
			else  
			{
			e_instance->add
            ({
                name => "the_dcfifo_other_info",
                module => $module_name."_dual_clock_fifo_for_other_info",
                port_map =>
                    {
                        data => &concatenate(@avalonst_other_info_signals),
                        wrreq => 'avalonst_sink_valid', # FIFO take care of overflow checking  
                        rdreq => $rdreq_driver,    
                        wrclk => 'wrclk',
                        rdclk => 'rdclk',
                        aclr => "~$wrclk_reset_n",
                        q => 'avalonst_other_info_map_in',
                    },
            });
			}
        }
    
        &define_map_avalonst_to_avalonmm_other_info($proj, $options);
        e_instance->add
        ({
            name => "the_map_avalonst_to_avalonmm_other_info",
            module => $module_name."_map_avalonst_to_avalonmm_other_info",
            port_map =>
                {
                    avalonmm_other_info => "avalonmm_other_info_map_out",
                    avalonst_other_info => "avalonst_other_info_map_in",
                },
        });
    }

    if ($need_fifo_other_info)
    {




        if($Single_Clock_Mode)
        {
            e_register->add({
                out => "avalonmm_read_slave_address_delayed",
                in  => "avalonmm_read_slave_address",
                clock => "clock",
                enable => 1,
                reset => "$rdclk_reset_n",
            });

            e_register->add({
                out => "avalonmm_read_slave_read_delayed",
                in  => "avalonmm_read_slave_read",
                clock => "clock",
                enable => 1,
                reset => "$rdclk_reset_n",
            });
        }
        else
        {
            e_register->add({
                out => "avalonmm_read_slave_address_delayed",
                in  => "avalonmm_read_slave_address",
                clock => "rdclk",
                enable => 1,
                reset => "$rdclk_reset_n",
            });

            e_register->add({
                out => "avalonmm_read_slave_read_delayed",
                in  => "avalonmm_read_slave_read",
                clock => "rdclk",
                enable => 1,
                reset => "$rdclk_reset_n",
            });
        }
	    
        my @avalonmm_read_slave_read_mux_table = (
	        "(avalonmm_read_slave_address_delayed == 1) & avalonmm_read_slave_read_delayed" => "avalonmm_other_info_map_out",
	        "(avalonmm_read_slave_address_delayed == 0) & avalonmm_read_slave_read_delayed" => "avalonmm_map_data_out",
	    );
	
	    e_mux->add({
	        lhs => "avalonmm_read_slave_readdata",
	        table => \@avalonmm_read_slave_read_mux_table,
	        type => "and-or",
	        });
    }
    else
    {
        e_assign->adds(
	        {lhs => "avalonmm_read_slave_readdata",
	         rhs => "avalonmm_map_data_out"},
	    );
    }
    

    my @avalonst_sink_signals = &get_avalonst_signals($options, "");
    my @avalonst_special_signals = ([valid => 1]);

    if($Use_Backpressure)
    {
        push(@avalonst_special_signals, [ready => 1]);
    }
    my $avalonst_sink_type_map = {map {"avalonst_sink_".$_->[0] => $_->[0]}
					(@avalonst_sink_signals, @avalonst_special_signals)};

    $avalonst_sink_type_map->{"$wrclk_reset_n"} = "reset_n";


    $avalonst_sink_type_map->{"wrclock"} = "clk";

    e_atlantic_slave->add({
	name => $avalonst_sink_cp_name,
	type_map => $avalonst_sink_type_map,
    });
}






sub define_map_avalonst_to_avalonmm_other_info
{
    my $proj = shift;
    my $options = shift;

    my $mod = e_module->new({name => $module_name."_map_avalonst_to_avalonmm_other_info"});
    $proj->add_module($mod);


    my $error_width = $Error_Width;
    my $channel_width = $Channel_Width;
    my $empty_width = ceil(log2($Symbols_Per_Beat));
    my $packet_info_width = 0;

    if($Use_Packet)
    {
        $packet_info_width = $empty_width + 2;
    }

    my $avalonst_other_info_width = $error_width + $channel_width + $packet_info_width;
    my $avalonmm_other_info_width = $AvalonMM_AvalonST_Data_Width;


    $mod->add_contents(
        e_signal->news(
            [avalonmm_other_info => $avalonmm_other_info_width],
            [avalonst_other_info => $avalonst_other_info_width],
        ),
    );


    my $sop_index = -1;
    my $eop_index = -1;
    my $empty_low_index = -1;
    my $empty_high_index = -1;
    my $channel_low_index = -1;
    my $channel_high_index = -1;
    my $error_low_index = -1;
    my $error_high_index = -1;

    my $next_index = 0;

    if($Use_Packet)
    {
        $sop_index = $next_index;
        $eop_index = $sop_index + 1;
        $next_index = $eop_index + 1;

        if($empty_width > 0)
        {
            $empty_low_index = $next_index;
            $empty_high_index = $empty_low_index + $empty_width - 1;
            $next_index = $empty_high_index + 1;
        }
    }

    if($channel_width > 0)
    {
        $channel_low_index = $next_index;
        $channel_high_index = $channel_low_index + $channel_width - 1;
        $next_index = $channel_high_index + 1;
    }

    if($error_width > 0)
    {
        $error_low_index = $next_index;
        $error_high_index = $error_low_index + $error_width - 1;
        $next_index = $error_high_index + 1;
    }


    if($avalonst_other_info_width != $next_index)
    {
        &ribbit("Incorrect index for other info mapping from AvalonST to AvalonMM\n");
    }

    my @other_info = ();
    if($Use_Packet)
    {
        push(@other_info,
             ["sop" => 1],
             ["eop" => 1],
             ["empty" => $empty_width]);
    }
    else
    {
        push(@other_info,
             ["sop" => 0],
             ["eop" => 0],
             ["empty" => 0]);
    }

    push(@other_info,
         ["channel" => $channel_width],
         ["error" => $error_width]);

    foreach(@other_info)
    {
        if($_->[0] eq "sop")
        {
            my $sop_rhs;
            if($_->[1] == 0)
            {
                $sop_rhs = "1'b0";
            }
            else
            {
                $sop_rhs = "avalonst_other_info[$sop_index]";
            }
            $mod->add_contents(
                e_assign->new(
                    {lhs => e_signal->new([avalonmm_sop => 1]),
                     rhs => $sop_rhs},
                ),
            );
        }
        if($_->[0] eq "eop")
        {
            my $eop_rhs;
            if($_->[1] == 0)
            {
                $eop_rhs = "1'b0";
            }
            else
            {
                $eop_rhs = "avalonst_other_info[$eop_index]";
            }
            $mod->add_contents(
                e_assign->new(
                    {lhs => e_signal->new([avalonmm_eop => 1]),
                     rhs => $eop_rhs},
                ),
            );

        }




        if($_->[0] eq "empty")
        {
            my $empty_rhs;
            if($_->[1] == 0)
            {
                $empty_rhs = "6'b0";
            }
            elsif($_->[1] < 6)
            {
                $empty_rhs = &concatenate(6-$empty_width."'b0", "avalonst_other_info[$empty_high_index:$empty_low_index]");
            }
            else
            {
                $empty_rhs = "avalonst_other_info[$empty_high_index:$empty_low_index]";
            }
            $mod->add_contents(
                e_assign->new(
                    {lhs => e_signal->new([avalonmm_empty => 6]),
                     rhs => $empty_rhs},
                ),
            );
        }
        if($_->[0] eq "channel")
        {
            my $channel_rhs;
            if($_->[1] == 0)
            {
                $channel_rhs = "8'b0";
            }
            elsif($_->[1] < 8)
            {
                $channel_rhs = &concatenate(8-$channel_width."'b0", "avalonst_other_info[$channel_high_index:$channel_low_index]");
            }
            else
            {
                $channel_rhs = "avalonst_other_info[$channel_high_index:$channel_low_index]";
            }
            $mod->add_contents(
                e_assign->new(
                    {lhs => e_signal->new([avalonmm_channel => 8]),
                     rhs => $channel_rhs},
                ),
            );
        }
        if($_->[0] eq "error")
        {
            my $error_rhs;
            if($_->[1] == 0)
            {
                $error_rhs = "8'b0";
            }
            elsif($_->[1] < 8)
            {
                $error_rhs = &concatenate(8-$error_width."'b0", "avalonst_other_info[$error_high_index:$error_low_index]");
            }
            else
            {
                $error_rhs = "avalonst_other_info[$error_high_index:$error_low_index]";
            }
            $mod->add_contents(
                e_assign->new(
                    {lhs => e_signal->new([avalonmm_error => 8]),
                     rhs => $error_rhs},
                ),
            );
        }
    }

    my @avalonmm_signals = ();
    push(@avalonmm_signals,
         "8'b0",
         "avalonmm_error",
         "avalonmm_channel",
         "avalonmm_empty",
         "avalonmm_eop",
         "avalonmm_sop");

    $mod->add_contents(
        e_assign->new(
            {lhs => "avalonmm_other_info",
             rhs => &concatenate(@avalonmm_signals)},
        ),
    );
}









sub define_map_avalonst_to_avalonmm
{
    my $proj = shift;
    my $options = shift;

    my $mod = e_module->new({name => $module_name."_map_avalonst_to_avalonmm"});
    $proj->add_module($mod);


    $mod->add_contents(
        e_signal->news(
            [avalonmm_data => $maximumSymbolsPerCycle * $avalonMMBitsPerSymbol],
            [avalonst_data => $maximumSymbolsPerCycle * $Bits_Per_Symbol],
        ),
    );

    my $index;
    my $avalonmm_high_index;
    my $avalonmm_low_index;
    my $avalonst_high_index;
    my $avalonst_low_index;
    my $avalonmm_max_high_index;

    for($index = 0; $index < $maximumSymbolsPerCycle; $index++)
    {



        $avalonmm_low_index = $index * $avalonMMBitsPerSymbol;
        $avalonmm_high_index = $avalonmm_low_index + $Bits_Per_Symbol - 1;


        $avalonmm_max_high_index = $avalonmm_low_index + $avalonMMBitsPerSymbol - 1;


        $avalonst_low_index = ($maximumSymbolsPerCycle - $index - 1) * $Bits_Per_Symbol;
        $avalonst_high_index = $avalonst_low_index + $Bits_Per_Symbol - 1;
 
        $mod->add_contents(
            e_assign->new(
                {lhs => "avalonmm_data[$avalonmm_high_index : $avalonmm_low_index]",
                 rhs => "avalonst_data[$avalonst_high_index : $avalonst_low_index]"},
            ),
        );

        if($avalonmm_max_high_index > $avalonmm_high_index)
        {

            $mod->add_contents(
                e_assign->new(
                    {lhs => "avalonmm_data[$avalonmm_max_high_index:$avalonmm_high_index+1]",
                     rhs => $avalonmm_max_high_index-$avalonmm_high_index."'b0"},
                ),
            );
        }
    }
}








sub make_avalonmm_avalonst_interface
{
    my $proj = shift;
    my $options = shift;

    if($cyclesPerBeat == 1)
    {



        &create_avalonmm_to_avalonst_with_one_write_per_beat($proj, $options);
    }
    else
    {
        &ribbit("Configuration not supported: Bits Per Symbol = $Bits_Per_Symbol; Symbols Per Beat = $Symbols_Per_Beat\n");
    }
}






sub create_avalonmm_to_avalonst_with_one_write_per_beat
{
    my $proj = shift;
    my $options = shift;

    if($cyclesPerBeat != 1)
    {
        &ribbit("Mapping one AvalonMM write to one AvalonST beat is
                 incorrect because the interface pair need $cyclesPerBeat 
                 AvalonMM write per AvalonST beat\n");
    }

    my @write_slave_signals = &get_avalonmm_slave_signals($proj, $options, "avalonmm_write_slave", $avalonmm_write_slave_cp_name);


    my $write_slave_type_map = { map {"avalonmm_write_slave_".$_->[0] => $_->[0]}
                                         @write_slave_signals };


    $write_slave_type_map->{"wrclock"} = "clk";
    $write_slave_type_map->{"$wrclk_reset_n"} = "reset_n";
    e_avalon_slave->add({
        name => $avalonmm_write_slave_cp_name,
        type_map => $write_slave_type_map,
    });

    e_signal->adds( map {["avalonmm_write_slave_".$_->[0],
                          $_->[1]]} @write_slave_signals);


    if($Use_Backpressure)
    {
        if($Single_Clock_Mode)
        {
            e_assign->adds(
                {lhs => "avalonmm_write_slave_waitrequest",
                 rhs => "full"},
            );
        }
        else
        {
            e_assign->adds(
                {lhs => "avalonmm_write_slave_waitrequest",
                 rhs => "wrfull"},
            );
        }
    }






    &define_map_avalonmm_to_avalonst($proj, $options);
    e_instance->add
    ({
        name => "the_map_avalonmm_to_avalonst",
        module => $module_name."_map_avalonmm_to_avalonst",
        port_map =>
            {
                avalonmm_data => 'avalonmm_map_data_in',
                avalonst_data => 'avalonst_map_data_out',
            },
    });


    my $wrreq_driver = "(avalonmm_write_slave_address == 0) & avalonmm_write_slave_write";

    e_assign->adds(
        {lhs => "wrreq_driver",
         rhs => $wrreq_driver},
        {lhs => "avalonmm_map_data_in",
         rhs => "avalonmm_write_slave_writedata"},
        {lhs => "wrreq",
         rhs => "wrreq_driver"},
	{lhs => "data",
	 rhs => "avalonst_map_data_out"},
    );

    if($Single_Clock_Mode)
    {
        e_assign->adds(
            {lhs => "clock",
             rhs => "wrclock"},
        );
    }
    else
    {
        e_assign->adds(
            {lhs => "wrclk",
             rhs => "wrclock"},
            {lhs => "rdclk",
             rhs => "rdclock"},
        );
    }


	my $need_other_info_fifo = 0;
	if ($Use_Packet || ($Error_Width > 0) || ($Channel_Width > 0))
	{
        $need_other_info_fifo = 1;
	}
	
    if ($need_other_info_fifo)
    {

        my $enable_other_info_register = "(avalonmm_write_slave_address == 1) & avalonmm_write_slave_write";
    



        my $empty_width = ceil(log2($Symbols_Per_Beat));
        my $packet_info_width = 0;
        if($Use_Packet)
        {
            $packet_info_width = $empty_width + 2;
        }
        my $other_info_fifo_width = $packet_info_width + $Error_Width + $Channel_Width;
    

        if($Single_Clock_Mode)
        {
            &define_scfifo($proj,
                           $Device_Family,
                           $module_name."_single_clock_fifo_for_other_info",
                           $FIFO_Depth,
                           $other_info_fifo_width,
                           $Use_Register,
                           0,
                           0,
                  	       0);
            e_instance->add
            ({
                name => "the_scfifo_other_info",
                module => $module_name."_single_clock_fifo_for_other_info",
                port_map =>
                    {
                        data => 'avalonst_other_info',
                        wrreq => 'wrreq_driver & ~full',   
                        rdreq => 'rdreq_i',
                        clock => 'clock',
                        aclr => "~$wrclk_reset_n",
    
                        q => 'q_i',
                    },
            });
        }
        else
        {
            &define_dcfifo($proj,
                           $Device_Family,
                           $module_name."_dual_clock_fifo_for_other_info",
                           $FIFO_Depth,
                           $other_info_fifo_width,
                           $Use_Register,
                           0, #no rdusedw
                           0, #no wrusedw
                           0, #no rdfull
                           0, #no wrempty
                	       0, #no wrfull
                           0);#no rdempty
            e_instance->add
            ({
                name => "the_dcfifo_other_info",
                module => $module_name."_dual_clock_fifo_for_other_info",
                port_map =>
                    {
                        data => 'avalonst_other_info',
                        wrreq => 'wrreq_driver & ~wrfull',  
                        rdreq => 'rdreq_i',
                        wrclk => 'wrclk',
                        rdclk => 'rdclk',
                        aclr => "~$wrclk_reset_n",
    
                        q => 'q_i',
                    },
            });
        }
    
    

        &define_map_avalonmm_to_avalonst_other_info($proj, $options);
        if($Single_Clock_Mode)
        {
            e_instance->add
            ({
                name => "the_map_avalonmm_to_avalonst_other_info",
                module => $module_name."_map_avalonmm_to_avalonst_other_info",
                port_map =>
                    {
                        avalonmm_other_info => "avalonmm_write_slave_writedata",
                        auto_clr => "wrreq_driver & !full", # Only clear sop and eop when a valid write occurs
                        enable => $enable_other_info_register,
                        clock => "clock",
                        reset_n => "$wrclk_reset_n",
    
                        avalonst_other_info => "avalonst_other_info",
                    },
            });
        }
        else
        {
            e_instance->add
            ({
                name => "the_map_avalonmm_to_avalonst_other_info",
                module => $module_name."_map_avalonmm_to_avalonst_other_info",
                port_map =>
                    {
                        avalonmm_other_info => "avalonmm_write_slave_writedata",
                        auto_clr => "wrreq_driver & !wrfull", # Only clear sop and eop when a valid write occurs
                        enable => $enable_other_info_register,
                        clock => "wrclk",
                        reset_n => "$wrclk_reset_n",
    
                        avalonst_other_info => "avalonst_other_info",
                    },
            });
        }
    
    



        &define_map_fifo_other_info_to_avalonst($proj, $options);
        e_instance->add
        ({
            name => "the_map_fifo_other_info_to_avalonst",
            module => $module_name."_map_fifo_other_info_to_avalonst",
            port_map =>
                {
                    data_in => "q_i",
                },
        });
    }
    
    e_assign->adds(
            {lhs => e_signal->add([avalonst_source_data => $maximumSymbolsPerCycle * $Bits_Per_Symbol]),
             rhs => "q"},
    );

    if($Use_Backpressure)
    {
        if($Single_Clock_Mode)
        {
            e_assign->adds(
                {lhs => "rdreq",
                 rhs => "!empty & avalonst_source_ready"},
            );
            
            if ($need_other_info_fifo){
                e_assign->adds(
                    {lhs => "rdreq_i",
                     rhs => "rdreq"},
                );
            }
            
            e_register->add({
                out => "avalonst_source_valid",
                in  => "!empty & avalonst_source_ready",
                clock => "clock",
                enable => 1,
                reset => "$rdclk_reset_n",
            });
        }
        else
        {
            e_assign->adds(
                {lhs => "rdreq",
                 rhs => "!rdempty & avalonst_source_ready"},
            );
            
            if ($need_other_info_fifo){
                e_assign->adds(
                    {lhs => "rdreq_i",
                     rhs => "rdreq"},
                );
            }

            e_register->add({
                out => "avalonst_source_valid",
                in  => "!rdempty & avalonst_source_ready",
                clock => "rdclk",
                enable => 1,
                reset => "$rdclk_reset_n",
            });
        }
    }
    else
    {
        if($Single_Clock_Mode)
        {
            e_assign->adds(
                {lhs => "rdreq",
                 rhs => "!empty"},
            );

            if ($need_other_info_fifo){
                e_assign->adds(
                    {lhs => "rdreq_i",
                     rhs => "rdreq"},
                );
            }

            e_register->add({
                out => "avalonst_source_valid",
                in  => "!empty",
                clock => "clock",
                enable => 1,
                reset => "$rdclk_reset_n",
            });
        }
        else
        {
            e_assign->adds(
                {lhs => "rdreq",
                 rhs => "!rdempty"},
            );

            if ($need_other_info_fifo){
                e_assign->adds(
                    {lhs => "rdreq_i",
                     rhs => "rdreq"},
                );
            }

            e_register->add({
                out => "avalonst_source_valid",
                in  => "!rdempty",
                clock => "rdclk",
                enable => 1,
                reset => "$rdclk_reset_n",
            });
        }
    }


    my @avalonst_source_signals = &get_avalonst_signals($options, "");
    my @avalonst_special_signals = ([valid => 1]);
    if($Use_Backpressure)
    {
	push(@avalonst_special_signals, [ready => 1]);
    }

    my $avalonst_source_type_map = {map {"avalonst_source_".$_->[0] => $_->[0]}
					(@avalonst_source_signals, @avalonst_special_signals)};

    $avalonst_source_type_map->{"$rdclk_reset_n"} = "reset_n";
    if($Single_Clock_Mode)
    {
	$avalonst_source_type_map->{"wrclock"} = "clk";
    }
    else
    {
	$avalonst_source_type_map->{"rdclock"} = "clk";
    }

    e_atlantic_master->add({
	name => $avalonst_source_cp_name,
	type_map => $avalonst_source_type_map,
    });
}






sub define_map_fifo_other_info_to_avalonst
{
    my $proj = shift;
    my $options = shift;

    my $mod = e_module->new({name => $module_name."_map_fifo_other_info_to_avalonst"});
    $proj->add_module($mod);


    my $error_width = $Error_Width;
    my $channel_width = $Channel_Width;
    my $empty_width = ceil(log2($Symbols_Per_Beat));
    my $packet_info_width = 0;

    if($Use_Packet)
    {
        $packet_info_width = $empty_width + 2;
    }

    my $total_other_info_width = $error_width + $channel_width + $packet_info_width;
    my @avalonst_signals = ();

    $mod->add_contents(
        e_signal->new(
            ["data_in" => $total_other_info_width],
        ),
    );

    if($error_width > 0)
    {
        $mod->add_contents(
            e_signal->new(
                ["avalonst_source_error" => $error_width],
            ),
        );
        push(@avalonst_signals, "avalonst_source_error");
    }

    if($channel_width > 0)
    {
        $mod->add_contents(
            e_signal->new(
                ["avalonst_source_channel" => $channel_width],
            ),
        );
        push(@avalonst_signals, "avalonst_source_channel");
    }

    if($Use_Packet)
    {
       if($empty_width > 0)
        {
            $mod->add_contents(
                e_signal->new(
                    ["avalonst_source_empty" => $empty_width],
                ),
            );
            push(@avalonst_signals, "avalonst_source_empty");
        }

       $mod->add_contents(
           e_signal->news(
               ["avalonst_source_endofpacket" => 1],
               ["avalonst_source_startofpacket" => 1],
           ),
       );
       push(@avalonst_signals, "avalonst_source_endofpacket", "avalonst_source_startofpacket");
    }

    $mod->add_contents(
        e_assign->new(
            {lhs => &concatenate(@avalonst_signals),
             rhs => "data_in"},
        ),
    );
}





sub define_map_avalonmm_to_avalonst_other_info
{
    my $proj = shift;
    my $options = shift;

    my $mod = e_module->new({name => $module_name."_map_avalonmm_to_avalonst_other_info"});
    $proj->add_module($mod);


    my $error_width = $Error_Width;
    my $channel_width = $Channel_Width;
    my $empty_width = ceil(log2($Symbols_Per_Beat));
    my $packet_info_width = 0;

    if($Use_Packet)
    {
        $packet_info_width = $empty_width + 2;
    }

    my $avalonst_other_info_width = $error_width + $channel_width + $packet_info_width;
    my $avalonmm_other_info_width = $AvalonMM_AvalonST_Data_Width;


    $mod->add_contents(
        e_signal->news(
            [avalonmm_other_info => $avalonmm_other_info_width],
            [avalonst_other_info => $avalonst_other_info_width],
        ),
    );



    my $sop_index = 0;
    my $eop_index = 1;
    my $empty_low_index = 2;
    my $empty_high_index = $empty_low_index + $empty_width - 1;
    my $channel_low_index = 8;
    my $channel_high_index = $channel_low_index + $channel_width - 1;
    my $error_low_index = 16;
    my $error_high_index = $error_low_index + $error_width - 1;

    my @avalonst_signals_register = ();

    if($error_width > 0)
    {
        $mod->add_contents(
            e_assign->new(
                {lhs => e_signal->new(["error" => $error_width]),
                 rhs => "avalonmm_other_info[$error_high_index:$error_low_index]"},
            ),
        );
        push(@avalonst_signals_register, "error_q");
    }

    if($channel_width > 0)
    {
        $mod->add_contents(
            e_assign->new(
                {lhs => e_signal->new(["channel" => $channel_width]),
                 rhs => "avalonmm_other_info[$channel_high_index:$channel_low_index]"},
            ),
        );
        push(@avalonst_signals_register, "channel_q");
    }

    if($Use_Packet)
    {
        if($empty_width != 0)
        {
            $mod->add_contents(
                e_assign->new(
                    {lhs => e_signal->new(["empty" => $empty_width]),
                     rhs => "avalonmm_other_info[$empty_high_index:$empty_low_index]"},
                ),
            );
            push(@avalonst_signals_register, "empty_q");
        }

        $mod->add_contents(
            e_assign->news(
                {lhs => e_signal->new(["sop" => 1]),
                 rhs => "avalonmm_other_info[$sop_index]"},
                {lhs => e_signal->new(["eop" => 1]),
                 rhs => "avalonmm_other_info[$eop_index]"},
            ),
        );

        push(@avalonst_signals_register, "eop_q", "sop_q");
    }


    $mod->add_contents(
        e_assign->new(
            {lhs => "avalonst_other_info",
             rhs => &concatenate(@avalonst_signals_register)},
        ),
    );

    if($Use_Packet)
    {
        $mod->add_contents(
            e_register->new({
                out => "sop_q",
                in  => "sop",
                clock => "clock",
                enable => "enable | auto_clr",
                sync_reset => "auto_clr",
                reset => "reset_n",
            }),
            e_register->new({
                out => "eop_q",
                in  => "eop",
                clock => "clock",
                enable => "enable | auto_clr",
                sync_reset => "auto_clr",
                reset => "reset_n",
           }),
        );

        if($empty_width != 0)
        {
            $mod->add_contents(
                e_register->new({
                    out => "empty_q",
                    in  => "empty",
                    clock => "clock",
                    enable => "enable",
                    reset => "reset_n",
                }),
            );
        }
    }

    if($error_width > 0)
    {
        $mod->add_contents(
            e_register->new({
               out => "error_q",
               in  => "error",
               clock => "clock",
               enable => "enable",
               reset => "reset_n",
            }),
        );
    }

    if($channel_width > 0)
    {
        $mod->add_contents(
            e_register->new({
               out => "channel_q",
               in  => "channel",
               clock => "clock",
               enable => "enable",
               reset => "reset_n",
            }),
        );
    }
}







sub define_map_avalonmm_to_avalonst
{
    my $proj = shift;
    my $options = shift;

    my $mod = e_module->new({name => $module_name."_map_avalonmm_to_avalonst"});
    $proj->add_module($mod);


    $mod->add_contents(
        e_signal->news(
            [avalonmm_data => $maximumSymbolsPerCycle * $avalonMMBitsPerSymbol],
            [avalonst_data => $maximumSymbolsPerCycle * $Bits_Per_Symbol ],
        ),
    );

    my $index;
    my $avalonmm_high_index;
    my $avalonmm_low_index;
    my $avalonst_high_index;
    my $avalonst_low_index;

    for($index = 0; $index < $maximumSymbolsPerCycle; $index++)
    {



        $avalonmm_low_index = $index * $avalonMMBitsPerSymbol;
        $avalonmm_high_index = $avalonmm_low_index + $Bits_Per_Symbol - 1;


        $avalonst_low_index = ($maximumSymbolsPerCycle - $index - 1) * $Bits_Per_Symbol;
        $avalonst_high_index = $avalonst_low_index + $Bits_Per_Symbol - 1;
 
        $mod->add_contents(
            e_assign->new(
                {lhs => "avalonst_data[$avalonst_high_index : $avalonst_low_index]",
                 rhs => "avalonmm_data[$avalonmm_high_index : $avalonmm_low_index]"},
            ),
        );
    }
}








sub make_avalonmm_avalonmm_interface
{
    my $proj = shift;
    my $options = shift;

    my @read_slave_signals = &get_avalonmm_slave_signals($proj, $options, "avalonmm_read_slave", $avalonmm_read_slave_cp_name);
    my @write_slave_signals = &get_avalonmm_slave_signals($proj, $options, "avalonmm_write_slave", $avalonmm_write_slave_cp_name);


    my $write_slave_type_map = { map {"avalonmm_write_slave_".$_->[0] => $_->[0]}
                                         @write_slave_signals };

    $write_slave_type_map->{"wrclock"} = "clk";
    $write_slave_type_map->{"$wrclk_reset_n"} = "reset_n";

    e_avalon_slave->add({
        name => $avalonmm_write_slave_cp_name,
        type_map => $write_slave_type_map,
    });

    e_signal->adds( map {["avalonmm_write_slave_".$_->[0],
                          $_->[1]]} @write_slave_signals);


    my $read_slave_type_map = { map {"avalonmm_read_slave_".$_->[0] => $_->[0]}
                                         @read_slave_signals };

    $read_slave_type_map->{"$rdclk_reset_n"} = "reset_n";
    if($Single_Clock_Mode)
    {
        $read_slave_type_map->{"wrclock"} = "clk";
    }
    else
    {
        $read_slave_type_map->{"rdclock"} = "clk";
    }

    e_avalon_slave->add({
        name => $avalonmm_read_slave_cp_name,
        type_map => $read_slave_type_map,
    });

    e_signal->adds( map {["avalonmm_read_slave_".$_->[0],
                          $_->[1]]} @read_slave_signals);


    e_assign->adds(
        {lhs => "data",
         rhs => "avalonmm_write_slave_writedata"},
        {lhs => "wrreq",
         rhs => "avalonmm_write_slave_write"},

        {lhs => "avalonmm_read_slave_readdata",
         rhs => "q"},
        {lhs => "rdreq",
         rhs => "avalonmm_read_slave_read"},
    );

    if($Single_Clock_Mode)
    {
        e_assign->adds(
            {lhs => "clock",
             rhs => "wrclock"},
        );


        if($Use_Backpressure)
        {
            e_assign->adds(
                {lhs => "avalonmm_write_slave_waitrequest",
                 rhs => "full"},
                {lhs => "avalonmm_read_slave_waitrequest",
                 rhs => "empty"},
            );
        }
    }
    else
    {
        e_assign->adds(
            {lhs => "rdclk",
             rhs => "rdclock"},
            {lhs => "wrclk",
             rhs => "wrclock"},
	);


        if($Use_Backpressure)
        {
            e_assign->adds(
                {lhs => "avalonmm_write_slave_waitrequest",
                 rhs => "wrfull"},
                {lhs => "avalonmm_read_slave_waitrequest",
                 rhs => "rdempty"},
            );
        }	
    }
}







sub get_avalonmm_slave_signals
{
    my $proj = shift;
    my $options = shift;
    my $slave_name = shift;
    my $slave_connection_point_name = shift;







    my $data_width = $AvalonMM_AvalonMM_Data_Width;
    my $address_width = 1;

    my @slave_signals = ();



    if($Use_AvalonMM_Write_Slave &&
       $Use_AvalonMM_Read_Slave &&
       $slave_name eq "avalonmm_write_slave")
    {
        push(@slave_signals,
            [writedata => $data_width],
            [write => 1],
        );
    }
    elsif($Use_AvalonMM_Write_Slave &&
       $Use_AvalonMM_Read_Slave &&
       $slave_name eq "avalonmm_read_slave")
    {
        push(@slave_signals,
            [readdata => $data_width],
            [read => 1],
        );
    }
    elsif($Use_AvalonMM_Write_Slave &&
       $Use_AvalonST_Source &&
       $slave_name eq "avalonmm_write_slave")
    {
        push(@slave_signals,
            [writedata => $data_width],
            [write => 1],
            [address => $address_width],
        );
    }
    elsif($Use_AvalonMM_Read_Slave &&
       $Use_AvalonST_Sink &&
       $slave_name eq "avalonmm_read_slave")
    {
        push(@slave_signals,
            [readdata => $data_width],
            [read => 1],
            [address => $address_width],
        );
    }
    else
    {
        &ribbit("Unknown slave name $slave_name\n");
    }

    if($Use_Backpressure)
    {
        push(@slave_signals, [waitrequest => 1]);
    }

    return @slave_signals;
}







sub make_dcfifo
{
    my $proj = shift;
    my $options = shift;

    e_instance->add({
        name => "the_dcfifo_with_controls",
        module => $module_name."_dcfifo_with_controls",
    });
    
    if($Use_AvalonMM_Write_Slave && 
       $Use_AvalonMM_Read_Slave &&
       !$Use_AvalonST_Source &&
       !$Use_AvalonST_Sink)
    {

        &make_avalonmm_avalonmm_interface($proj, $options);
    }
    elsif($Use_AvalonMM_Write_Slave &&
          $Use_AvalonST_Source &&
          !$Use_AvalonMM_Read_Slave &&
          !$Use_AvalonST_Sink)
    {

        &make_avalonmm_avalonst_interface($proj, $options);
    }
    elsif($Use_AvalonST_Sink &&
          $Use_AvalonMM_Read_Slave &&
          !$Use_AvalonMM_Write_Slave &&
          !$Use_AvalonST_Source)
    {

        &make_avalonst_avalonmm_interface($proj, $options);
    }
    elsif($Use_AvalonST_Sink &&
          $Use_AvalonST_Source &&
          !$Use_AvalonMM_Write_Slave &&
          !$Use_AvalonMM_Read_Slave)
    {

        &make_avalonst_avalonst_interface($proj, $options);
    }
    else
    {
        &ribbit("Invalid Combination of Interfaces.\n");
    }
}















sub make_write_control
{
    my $proj = shift;
    my $options = shift;

    my @write_control_signals = &get_control_slave_signals($proj, $wrclk_control_slave_cp_name);
    my $write_control_slave_type_map = { map {"wrclk_control_slave_".$_->[0] => $_->[0]}
                                         @write_control_signals };

    e_avalon_slave->add({
        name => $wrclk_control_slave_cp_name,
        type_map => $write_control_slave_type_map,
    });

    e_signal->adds( map {["wrclk_control_slave_".$_->[0],
                          $_->[1],0,0,0]} @write_control_signals);
}















sub make_read_control
{
    my $proj = shift;
    my $options = shift;

    my @read_control_signals = &get_control_slave_signals($proj, $rdclk_control_slave_cp_name);
    my $read_control_slave_type_map = { map {"rdclk_control_slave_".$_->[0] => $_->[0]}
                                        @read_control_signals };
    e_avalon_slave->add({
        name => $rdclk_control_slave_cp_name,
        type_map => $read_control_slave_type_map,
    });

    e_signal->adds( map {["rdclk_control_slave_".$_->[0],
                          $_->[1],0,0,0]} @read_control_signals);
}






sub get_control_slave_signals
{
    my $proj = shift;
    my $control_slave_cp_name = shift;








    my $address_width = 3;
    my $data_width = 32;
    my $has_irq = 1;

    my @control_slave_signals = ();
    push(@control_slave_signals,
        [clk => 1],
        [reset_n => 1],
        [address => $address_width],
        [writedata => $data_width],
        [readdata => $data_width],
        [write => 1],
        [read => 1],
    );

    if($has_irq)
    {
        push(@control_slave_signals,
            [irq => 1]);
    }

    return @control_slave_signals;
}






sub get_status_bits_signals
{
    my @status_bits_names = ();



    push(@status_bits_names,
        [underflow => 5],
        [overflow => 4],
        [almostempty => 3],
        [almostfull => 2],
        [empty => 1],
        [full => 0],
   );
    return @status_bits_names;
}

1;
