use europa_all;
use europa_utils;


sub get_value{
    my $input = shift;
    my $var = 1;
    for ($i=0;$i<$input; $i++)
    {
        $var *= 2;
    }
    return $var;
}
sub write_example_driver
{
    #print "\n\n\n ---------------> $gMEM_CHIP_BITS\n\n";
my $top = e_module->new({name => $gWRAPPER_NAME."_example_driver"});#,output_file => "/temp_gen/${gWRAPPER_NAME}_example_driver"});
my $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory});#'temp_gen'});
my $module = $project->top();

$module->add_attribute(ALTERA_ATTRIBUTE => "MESSAGE_DISABLE=12300;MESSAGE_DISABLE=14130;MESSAGE_DISABLE=14110");

#####   Parameters declaration  ######
$header_title = "Memory Controller Example Driver";
$header_filename = $gWRAPPER_NAME . "_example_driver";
$header_revision = "V" . $gWIZARD_VERSION;
#my $verilog_dq_io_instname;# = "\\g_datapath:\$i:g_ddr_io ";
my $Stratix_Fam = "";
my %stratix_param  = "";

my $LOCAL_DATA_BITS = $gLOCAL_DATA_BITS;
my $LOCAL_BE_BITS = $LOCAL_DATA_BITS / 8;
#my $LOCAL_ADDR_BITS = 24;
my $LOCAL_BURST_LEN = $gLOCAL_BURST_LEN;
my $LOCAL_BURST_LEN_BITS = $gLOCAL_BURST_LEN_BITS;
my $MEM_CHIPSELS = $gMEM_CHIPSELS;
my $MEM_CHIP_BITS = $gMEM_CHIP_BITS;
my $MEM_ROW_BITS = $gMEM_ROW_BITS;
my $MEM_BANK_BITS = $gMEM_BANK_BITS;
my $MEM_COL_BITS = $gMEM_COL_BITS;
my $MEM_DQ_PER_DQS = $gMEM_DQ_PER_DQS;

my $WRITE_ALL_MODE = 1;
my $S_WRITE_ALL = 1;
my $S_WRITE = 5;
my $S_WRITE_ALL_WAIT = 2;
my $S_WRITE_WAIT = 6;
my $S_READ_ALL = 3;
my $S_READ = 7;
my $S_READ_ALL_WAIT = 4;
my $S_READ_WAIT = 8;
my $S_IDLE = 0;
my $S_INIT = 9;
my $S_BURST_WRITE_ALL = 10;
my $S_BURST_READ_ALL = 11;
my $S_BURST_WRITE_WAIT = 12;
my $S_BURST_READ_WAIT = 13;

#my $cs_addr_max = get_value($gLEGAL_MEM_CHIP_BITS)-1;
#my $bank_addr_max = get_value($MEM_BANK_BITS)-1;
#my $row_addr_max = get_value($MEM_ROW_BITS)-1;
#my $col_addr_max = get_value($MEM_COL_BITS)-1;
####  end parameter list  ######

#######################################################################################################################################

######################################################################################################################################################################
#     $module->add_contents
#     (
#     #####	Paramenter declaration#	######
#        e_parameter->add({name => "MEM_CHIPSELS", default => $gMEM_CHIPSELS, vhdl_type => "integer"}),
#        e_parameter->add({name => "MEM_CHIP_BITS", default => $gMEM_CHIP_BITS, vhdl_type => "integer"}),
#        e_parameter->add({name => "MEM_ROW_BITS", default => $gMEM_ROW_BITS, vhdl_type => "integer"}),
#        e_parameter->add({name => "MEM_BANK_BITS", default => $gMEM_BANK_BITS, vhdl_type => "integer"}),
#        e_parameter->add({name => "MEM_COL_BITS", default => $gMEM_COL_BITS, vhdl_type => "integer"}),
#        e_parameter->add({name => "MEM_DQ_PER_DQS", default => $gMEM_DQ_PER_DQS, vhdl_type => "integer"}),
#        e_parameter->add({name => "LOCAL_DATA_BITS", default => $gLOCAL_DATA_BITS, vhdl_type => "integer"}),
#        e_parameter->add({name => "LOCAL_ADDR_BITS", default => 24, vhdl_type => "integer"}),
#        e_parameter->add({name => "LOCAL_BURST_LEN", default => $gLOCAL_BURST_LEN, vhdl_type => "integer"}),
#        e_parameter->add({name => "LOCAL_BURST_LEN_BITS", default => $gLOCAL_BURST_LEN_BITS, vhdl_type => "integer"}),
#        e_parameter->add({name => "WRITE_ALL_MODE", default => 1, vhdl_type => "integer"}),
#        e_parameter->add({name => "AVALON_IF", default => $gLOCAL_AVALON_IF, vhdl_type => "string"}),
#    );

######################################################################################################################################################################
     $module->add_contents
     (
     #####	Ports declaration#	######
         e_port->new({name => "clk",direction => "input"}),
         e_port->new({name => "reset_n",direction => "input"}),
         e_port->new({name => "local_read_req",direction => "output"}),
         e_port->new({name => "local_write_req",direction => "output"}),
         e_port->new({name => "local_size",direction => "output",width => "$gLOCAL_BURST_LEN_BITS"}),
         e_port->new({name => "local_ready",direction => "input"}),
         e_port->new({name => "local_cs_addr",direction => "output",width => $gLEGAL_MEM_CHIP_BITS}),
         e_port->new({name => "local_row_addr",direction => "output",width => $MEM_ROW_BITS}),
         e_port->new({name => "local_bank_addr",direction => "output",width => $MEM_BANK_BITS}),
         e_port->new({name => "local_col_addr",direction => "output",width => $MEM_COL_BITS}),
         e_port->new({name => "local_rdata_valid",direction => "input"}),
         #e_port->new({name => "local_rdvalid_in_n",direction => "input"}),
         e_port->new({name => "local_rdata",direction => "input",width => "$LOCAL_DATA_BITS"}),
         #e_port->new({name => "local_wdata_req",direction => "input"}),
         e_port->new({name => "local_wdata",direction => "output",width => $LOCAL_DATA_BITS}),
         # e_port->new({name => "local_be",direction => "output",width => $LOCAL_DATA_BITS / $MEM_DQ_PER_DQS}),
         e_port->new({name => "local_be",direction => "output",width => $LOCAL_DATA_BITS / 8}), # one BE per byte not per DQS
         #e_port->new({name => "local_init_done",direction => "input"}),
         e_port->new({name => "test_complete",direction => "output"}),
         e_port->new({name => "pnf_per_byte",width=>$LOCAL_DATA_BITS / 8,direction => "output"}),
         e_port->new({name => "pnf_persist",width=> 1,direction => "output"}),
    );

#########################################################################################################################################################

    if ($gLOCAL_AVALON_IF eq "false") {
        $module->add_contents (
            e_port->new({name => "local_wdata_req",direction => "input"}),
            );
    }

#########################################################################################################################################################

    if (($gLOCAL_AVALON_IF eq "true") and ($LOCAL_BURST_LEN > 1)){
        $module->add_contents (
            e_port->new({name => "local_burstbegin",direction => "output"}),
            e_signal->new(["burst_begin",1,0,1]),
            e_signal->new(["burst_beat_count",3,0,1]),
            e_assign->new(["local_burstbegin" => "burst_begin"]),
            e_assign->new(["avalon_burst_mode" => "1"]),

            );
    } else {
        $module->add_contents (
            e_assign->new(["avalon_burst_mode" => "0"]),
        );
    }

#########################################################################################################################################################

    if($gMEM_CHIP_BITS > 0)
    {
        $module->add_contents
        (
            e_signal->new(["MAX_CHIPSEL",$gMEM_CHIP_BITS,	0,	1]),
            e_signal->new(["MIN_CHIPSEL",$gMEM_CHIP_BITS,	0,	1]),
        );
    }else
    {
        $module->add_contents
        (
            e_signal->new(["MIN_CHIPSEL",1,	0,	1]),
            e_signal->new(["MAX_CHIPSEL",1,	0,	1]),
        );
    }
     $module->add_contents
     (
     #####   signal generation #####
         e_signal->news #: ["signal", width, export, never_export]
         (
            ["avalon_burst_mode",1,	0,	1],
            ["cs_addr",$gLEGAL_MEM_CHIP_BITS,	0,	1],
            ["row_addr",$MEM_ROW_BITS,	0,	1],
            ["bank_addr",$MEM_BANK_BITS,	0,	1],
            ["col_addr",$MEM_COL_BITS,	0,	1],
            ["read_req",1,	0,	1],
            ["write_req",1,	0,	1],
            ["size",$LOCAL_BURST_LEN_BITS,	0,	1],
            ["LOCAL_BURST_LEN_s",$LOCAL_BURST_LEN_BITS,	0,	1],
            ["wdata_req",1,	0,	1],
            ["last_wdata_req",1,	0,	1],
            ["last_rdata_valid",1,	0,	1],
            ["wdata",$LOCAL_DATA_BITS,	0,	1],
            ["be",$LOCAL_DATA_BITS / 8,		0,	1],
            ["compare",$LOCAL_DATA_BITS / 8,		0,	1],
            ["compare_reg",$LOCAL_DATA_BITS / 8,		0,	1],
            ["compare_valid",$LOCAL_DATA_BITS / 8,		0,	1],
            ["compare_valid_reg",$LOCAL_DATA_BITS / 8,	0,	1],
         ),

         #e_signal->new(["MIN_CHIPSEL",$gMEM_CHIP_BITS,	0,	1]),
         #e_signal->new(["MAX_CHIPSEL",$gMEM_CHIP_BITS,	0,	1]),
         e_signal->new(["MAX_ROW", $gMEM_ROW_BITS,	0,	1]),
         e_signal->new(["MAX_BANK",$gMEM_BANK_BITS,	0,	1]),
         e_signal->new(["MAX_COL",$gMEM_COL_BITS,	0,	1]),
         e_assign->new(["MIN_CHIPSEL" => "0"]),
         e_assign->new(["MAX_CHIPSEL" => $gMEM_CHIPSELS-1]),#$gMEM_CHIPSELS
         e_assign->new(["MAX_ROW"     => "3"]),
#         e_assign->new(["MAX_BANK"    => "3"]),
         e_assign->new(["MAX_BANK"    => 2**$gMEM_BANK_BITS - 1]),
         e_assign->new(["MAX_COL"     => "16"]),
#         e_parameter->add({name => "cs_addr_max",default => $cs_addr_max, vhdl_type => "integer"}),#"{".$gLEGAL_MEM_CHIP_BITS."{1'b1}}", vhdl_type => "integer"}),
#         e_parameter->add({name => "row_addr_max", default => $row_addr_max, vhdl_type => "integer"}),#"{".$MEM_ROW_BITS."{1'b1}}", vhdl_type => "integer"}),
#         e_parameter->add({name => "bank_addr_max", default => $bank_addr_max, vhdl_type => "integer"}),#"{".$MEM_BANK_BITS."{1'b1}}", vhdl_type => "integer"}),
#         e_parameter->add({name => "col_addr_max", default => $col_addr_max, vhdl_type => "integer"}),#"{".$MEM_COL_BITS."{1'b1}}", vhdl_type => "integer"}),
         e_signal->news #: ["signal", width, export, never_export]
         (	["state",4,	0,	1],
            ["dgen_enable",1,	0,	1],
            ["dgen_pause",1,	0,	1],
            ["dgen_data",$LOCAL_DATA_BITS,	0,	1],
            ["dgen_ldata",$LOCAL_DATA_BITS,	0,	1],
            ["writes_remaining",8,	0,	1],
            ["wait_first_write_data",1,	0,	1],
            ["reads_remaining",8,	0,	1],
            ["reset_address",1,	0,	1],
            ["pnf_persist1",1,	0,	1],
            ["reached_max_address",1,	0,	1],
            ["reached_max_count",1,	0,	1],
            ["burst_beat_count",3,	0,	1],
            ["avalon_read_burst_max_address",1,	0,	1],
         ),
     ),

###############################################################################################################################################################

     $module->add_contents
     (
         e_assign->new({lhs => "local_cs_addr", rhs => "cs_addr", comment => "\n\n"}),
         e_assign->new(["local_row_addr" => "row_addr"]),
         e_assign->new(["local_bank_addr" => "bank_addr"]),
         e_assign->new(["local_col_addr" => "col_addr"]),
         e_assign->new(["local_write_req" => "write_req"]),
         e_assign->new({lhs => "local_read_req", rhs=> "read_req"}),
         e_assign->new({lhs => "local_wdata", rhs=> "wdata"}),
         e_assign->new(["wdata" => "dgen_data"]),
         e_comment->new({comment => "The LOCAL_BURST_LEN_s is a signal used insted of the parameter LOCAL_BURST_LEN"}),
         e_assign->new(["LOCAL_BURST_LEN_s" => "$gLOCAL_BURST_LEN"]),
      );

##################################################################################################################################################################

    if ($gLOCAL_AVALON_IF eq "false") {
        $module->add_contents
        (
           e_assign->new({lhs => "wdata_req", rhs => "local_wdata_req",comment =>"LOCAL INTERFACE (NON-AVALON)"}),
           e_assign->new({lhs => "dgen_pause",rhs => "~ (last_wdata_req | local_rdata_valid)",
           comment => "// Generate new data (enable lfsr) when writing or reading valid data"}),
        );
    } else {
        $module->add_contents
        (
            e_assign->new({lhs => "wdata_req", rhs => "write_req && local_ready",comment => "LOCAL INTERFACE (AVALON)"}),
            e_assign->new({lhs => "dgen_pause", rhs =>"~ (wdata_req | local_rdata_valid)",
            comment => " Generate new data (enable lfsr) when writing or reading valid data"}),
        );
    }

#################################################################################################################################################################

    $module->add_contents
    (
         e_assign->new({lhs => "local_be", rhs => "be", comment => "\n\n"}),
         e_assign->new(["be" => "{"."$LOCAL_BE_BITS"."{1'b1}}"]),
         e_assign->new(["pnf_per_byte" => "compare_valid_reg"]),
         e_assign->new(["local_size" => "size"]),
    );

if (($gMEM_TYPE eq "ddr2_sdram" ) and ($gLOCAL_AVALON_IF eq "true")) {
    $module->add_contents
    (
        e_assign->new({ lhs => "size", rhs => "2"}),
    );
}else{
    $module->add_contents
    (
        e_assign->new({ lhs => "size", rhs => "LOCAL_BURST_LEN_s["."$LOCAL_BURST_LEN_BITS-1".":"."0"."]",comment => "FIX"}),
    );
}
    $module->add_contents
    (
         #e_assign->new({ lhs => "size", rhs => "LOCAL_BURST_LEN_s["."$LOCAL_BURST_LEN_BITS-1".":"."0"."]",comment => "FIX"}),
         e_assign->new({lhs => "reached_max_address", rhs=>
         "(col_addr >= (MAX_COL - ("."$LOCAL_BURST_LEN * 2"."))) && (row_addr == MAX_ROW) && (bank_addr == MAX_BANK) && (cs_addr == MAX_CHIPSEL)"}),
         e_assign->new({lhs => "avalon_read_burst_max_address", rhs=>
         "(col_addr >= (MAX_COL - ("."$LOCAL_BURST_LEN * 4"."))) && (row_addr == MAX_ROW) && (bank_addr == MAX_BANK) && (cs_addr == MAX_CHIPSEL)"}),
    );

#################################################################################################################################################################
my $dqs = 8; #used to be $MEM_DQ_PER_DQS
for ($i=0;$i<($gLOCAL_DATA_BITS/$dqs); $i++) {
    #my $value =
    $module->add_contents
    (
        e_blind_instance->new
        ({
            name 		=> "LFSRGEN_".$i."_lfsr_inst",
            module 		=> "example_lfsr8",
            comment 	=> "---------------------------------------------------------------------\n
            Generate the per byte lane logic (LFSR & Comparator)\n
            ---------------------------------------------------------------------\n
            lfsr/pattern generator per local byte lane",
            in_port_map 	=>
            {
                clk   => "clk",
                reset_n   => "reset_n",
                enable   => "dgen_enable",
                pause   => "dgen_pause",
                load   => "dgen_load",
                ldata   => "dgen_ldata["."$dqs * ($i + 1) - 1".":"."$dqs * $i"."]",
            },
            out_port_map	=>
            {
                data   => "dgen_data["."$dqs * ($i + 1) - 1".":"."$dqs * $i"."]",
            },
            parameter_map 	=>
            {
                "seed" => (10 * $i) + 1,
            },
        }),
        e_assign->new({lhs => "compare[$i]", rhs => "dgen_data["."$dqs * ($i + 1) - 1".":"."$dqs * $i"."] == local_rdata["."$dqs * ($i + 1) - 1".":"."$dqs * $i"."]" , comment =>" 8 bit comparator per local byte lane"}),
    );
}

#########################################################################################################################################################
     # $module->add_contents
     # (
     # #####   signal generation #####
         # e_signal->news #: ["signal", width, export, never_export]
         # (
            # ["incr_address",1,	0,	1],
            # # ["writes_remaining_v",5,	0,	1],
            # # ["reads_remaining_v",5,	0,	1],
          # ),
    # );

#################################################################################################################################################################

     $module->add_contents
     (
         e_process->new
         ({
              clock			=>	"clk",
              reset			=>	"reset_n",
              comment			=>
              "\n\n\n-----------------------------------------------------------------\n
              Main clocked process\n
              -----------------------------------------------------------------\n
              Read / Write control state machine & address counter\n
              -----------------------------------------------------------------",
              _asynchronous_contents	=>
              [
                e_assign->new({lhs => "state", rhs => "1'b0",comment => "Reset - asynchronously force all register outputs LOW"}),
                e_assign->new(["write_req" => "1'b0"]),
                e_assign->new(["read_req" => "1'b0"]),
                e_assign->new(["burst_begin" => "0"]),
                e_assign->new(["burst_beat_count" => "0"]),
                e_assign->new({ lhs => "cs_addr", rhs => "0"}),
                e_assign->new({ lhs => "row_addr", rhs => "0"}),
                e_assign->new({ lhs => "bank_addr", rhs => "0"}),
                e_assign->new({ lhs => "col_addr", rhs => "0"}),
                e_assign->new({ lhs => "dgen_enable", rhs => "1'b0"}),
                e_assign->new({ lhs => "dgen_load", rhs => "1'b0"}),
                e_assign->new({ lhs => "wait_first_write_data", rhs => "1'b0"}),
                e_assign->new({ lhs => "reached_max_count", rhs => "1'b0"}),
                e_assign->new({ lhs => "test_complete", rhs => "1'b0"}),
                e_assign->new({ lhs => "writes_remaining", rhs => "0"}),
                e_assign->new({ lhs => "reads_remaining", rhs => "0"}),
                e_assign->new({ lhs => "reset_address", rhs => "1'b0"}),
              ],
              contents	=>
              [
#				e_assign->new(["incr_address" => "1'b0"]),
                e_assign->new(["reset_address" => "1'b0"]),
                e_assign->new(["reached_max_count" => "reached_max_address"]),
                e_assign->new(["read_req" => "1'b0"]),
                e_assign->new(["write_req" => "1'b0"]),
                e_assign->new(["dgen_load" => "1'b0"]),
                e_assign->new(["test_complete" => "1'b0"]),
                e_if->new
                ({
                    condition	=> "last_wdata_req",
                    then		=>
                    [	e_assign->new(["wait_first_write_data" => "0"]) ],
                }),
                #e_assign->new(["writes_remaining_v" => "writes_remaining"]),
                e_if->new
                ({
                    condition	=> "(write_req && local_ready)",
                    then		=>
                    [
                        e_if->new
                        ({
                            condition	=> "wdata_req",
                            then		=>
                            [
                                e_assign->new(["writes_remaining" => "writes_remaining + (size - 1)"]),
                            ],
                            else		=>
                            [
                                e_assign->new(["writes_remaining" => "writes_remaining + size"]),
                            ],
                        }),
                    ],
                    else		=>
                    [
                        e_if->new
                        ({
                            condition	=> "((wdata_req) && (writes_remaining > 0))",
                            then		=>
                            [	e_assign->new({lhs => "writes_remaining", rhs => "writes_remaining - 1'b1", comment => "size"}) ],
                            else		=>
                            [	e_assign->new(["writes_remaining" => "writes_remaining"]),]
                        }),
                    ]
                }),
                #e_assign->new(["writes_remaining" => "writes_remaining_v"]),
                #e_assign->new(["reads_remaining_v" => "reads_remaining"]),
                e_if->new
                ({
                    condition	=> "(read_req && local_ready)",
                    then		=>
                    [
                        e_if->new
                        ({
                            condition	=> "local_rdata_valid",
                            then		=>
                            [
                                e_assign->new(["reads_remaining" => "reads_remaining + (size - 1)"])
                            ],
                            else		=>
                            [
                                e_assign->new(["reads_remaining" => "reads_remaining + size"])
                            ],
                        }),
                    ],
                    else		=>
                    [
                        e_if->new
                        ({
                            condition	=> "((local_rdata_valid) && (reads_remaining > 0))",
                            then		=>
                            [	e_assign->new({lhs => "reads_remaining", rhs => "reads_remaining - 1'b1"}) ],
                            else		=>
                            [	e_assign->new(["reads_remaining" => "reads_remaining"]),]
                        }),
                    ]
                }),


                #e_assign->new(["reads_remaining" => "reads_remaining_v"]),
                e_case->new
                ({
                    switch	  => "state",
                    parallel  => 0,
                    full      => 0,
                    contents  =>
                    {
                        $S_IDLE =>
                        [
                            e_assign->new({lhs => "reached_max_count", rhs => "0"}),
                            e_if->new
                            ({
                                condition	=> "avalon_burst_mode == 0",
                                then		=>
                                [
                                    e_if->new
                                    ({
                                        condition	=> "($WRITE_ALL_MODE == 0)",
                                        then		=>
                                        [e_assign->new({lhs => "state", rhs => $S_WRITE}) ],
                                        else		=>
                                        [e_assign->new({lhs => "state", rhs => $S_WRITE_ALL}) ],
                                    }),
                                ],
                                else =>
                                [
                                    e_assign->new(["burst_begin" => "1"]),
                                    e_assign->new({lhs => "write_req", rhs => "1'b1"}),
                                    e_assign->new({lhs => "state", rhs => $S_BURST_WRITE_ALL}),
                                ],
                            }),
                            e_assign->new({lhs => "dgen_enable", rhs => "1'b1"}),
                            e_assign->new({lhs => "writes_remaining", rhs => "0", comment => "Reset just in case!"}),
                            e_assign->new({lhs => "reads_remaining", rhs => "0"}),
                        ],

                        $S_BURST_WRITE_ALL =>
                        [
                            e_assign->new({ lhs => "reset_address", rhs => "1'b0"}),
                            e_assign->new({lhs => "write_req", rhs => "1'b1"}),
                            e_assign->new(["burst_begin" => "0"]),

                            e_if->new
                            ({
                                condition	=> "(local_ready)",
                                then		=>
                                [
                                    e_assign->new(["burst_beat_count" => "burst_beat_count + 1"]),
                                    e_assign->new({lhs => "state", rhs => $S_BURST_WRITE_WAIT}),
                                ],
                            }),

                        ],

                        $S_BURST_WRITE_WAIT =>
                        [
                            e_assign->new({lhs => "write_req", rhs => "1'b1"}),

                            e_if->new
                            ({
                                condition	=> "(local_ready)",
                                then		=>
                                [
                                    e_if->new
                                    ({
                                        condition	=> "(burst_beat_count == size - 1)",
                                        then		=>
                                        [
                                            e_if->new
                                            ({
                                                condition	=> "reached_max_count",
                                                then		=>
                                                [
                                                    e_assign->new({lhs => "write_req", rhs => "1'b0"}),
                                                    e_assign->new(["burst_beat_count" => "0"]),
                                                    e_assign->new({ lhs => "reset_address", rhs => "1'b1"}),
                                                    e_assign->new({lhs => "dgen_enable", rhs => "1'b0"}),
                                                    e_assign->new({lhs => "state", rhs => $S_WRITE_ALL_WAIT}),
                                                ],
                                                else =>
                                                [
                                                    e_assign->new(["burst_begin" => "1"]),
                                                    e_assign->new({lhs => "write_req", rhs => "1'b1"}),
                                                    e_assign->new(["burst_beat_count" => "0"]),
                                                    e_assign->new({lhs => "state", rhs => $S_BURST_WRITE_ALL}),
                                                ],
                                            }),
                                        ],
                                        else =>
                                        [
                                            e_assign->new(["burst_beat_count" => "burst_beat_count + 1"]),
                                        ],
                                    }),
                                ],
                            }),

                        ],

                        $S_BURST_READ_ALL =>
                        [
                            e_assign->new({ lhs => "reset_address", rhs => "1'b0"}),
                            e_assign->new({lhs => "read_req", rhs => "1'b1"}),

                            e_if->new
                            ({
                                condition	=> "(! local_ready)",
                                then		=>
                                [
                                    e_assign->new(["burst_begin" => "0"]),
                                    e_assign->new({lhs => "state", rhs => $S_BURST_READ_WAIT}),
                                ],
                            }),

                            e_if->new
                            ({
                                condition	=> "avalon_read_burst_max_address",
                                then		=>
                                [
                                    e_assign->new({lhs => "read_req", rhs => "1'b0"}),
                                    e_assign->new({ lhs => "reset_address", rhs => "1'b1"}),
                                    e_assign->new({ lhs => "test_complete", rhs => "1'b1"}),
                                    #e_assign->new({lhs => "dgen_enable", rhs => "1'b0"}),
                                    e_assign->new(["burst_beat_count" => "0"]),
                                    e_assign->new({lhs => "state", rhs => $S_READ_ALL_WAIT}),
                                ],
                            }),
                        ],

                        $S_BURST_READ_WAIT =>
                        [
                            e_assign->new({lhs => "read_req", rhs => "1'b1"}),

                            e_if->new
                            ({
                                condition	=> "(local_ready)",
                                then		=>
                                [
                                    e_assign->new(["burst_begin" => "1"]),
                                    e_assign->new({lhs => "read_req", rhs => "1'b1"}),
                                    e_assign->new({lhs => "state", rhs => $S_BURST_READ_ALL}),
                                ],
                                else =>
                                [
                                    e_if->new
                                    ({
                                        condition	=> "avalon_read_burst_max_address",
                                        then		=>
                                        [
                                            e_assign->new({lhs => "read_req", rhs => "1'b0"}),
                                            e_assign->new({ lhs => "reset_address", rhs => "1'b1"}),
                                            e_assign->new({ lhs => "test_complete", rhs => "1'b1"}),
                                            e_assign->new({lhs => "dgen_enable", rhs => "1'b0"}),
                                            #e_assign->new(["burst_beat_count" => "0"]),
                                            e_assign->new({lhs => "state", rhs => $S_READ_ALL_WAIT}),
                                        ],
                                    }),
                                ],
                            }),
                        ],

                        $S_WRITE_ALL =>
                        [
#							comment => "WRITE ALL / READ ALL state machine loop",
                            e_assign->new({lhs => "write_req", rhs => "1'b1"}),
                            e_assign->new({lhs => "dgen_enable", rhs => "1'b1"}),
                            e_if->new
                            ({
                                condition	=> "(local_ready && write_req)",
                                then		=>
                                [
#									e_assign->new({lhs => "incr_address", rhs => "1'b1"}),
                                    e_if->new
                                    ({
                                        condition	=> "reached_max_count",
                                        then		=>
                                        [
                                            e_assign->new({lhs => "state", rhs => $S_WRITE_ALL_WAIT}),
                                            e_assign->new({lhs => "write_req", rhs => "1'b0"}),
                                            e_assign->new({lhs => "reset_address", rhs => "1'b1"}),
                                        ],
                                    }),
                                ],
                            }),
                        ],

                        $S_WRITE_ALL_WAIT =>
                        [
                            e_if->new
                            ({
                                condition	=> "avalon_burst_mode == 0",
                                then		=>
                                [
                                    e_if->new
                                    ({
                                        condition	=> "(writes_remaining == 0)",
                                        then		=>
                                        [
                                            e_assign->new({lhs => "state", rhs => $S_READ_ALL}),
                                            e_assign->new({lhs => "dgen_enable", rhs => "1'b0"}),
                                        ],
                                    }),
                                ],
                                else =>
                                [
                                    e_assign->new({lhs => "dgen_enable", rhs => "1'b1"}),
                                    e_assign->new(["burst_begin" => "1"]),
                                    e_assign->new({lhs => "read_req", rhs => "1'b1"}),
                                    e_assign->new({ lhs => "reset_address", rhs => "1'b0"}),
                                    e_assign->new({lhs => "state", rhs => $S_BURST_READ_ALL}),
                                ]
                            }),
                        ],

                        $S_READ_ALL =>
                        [
                            e_assign->new({lhs => "read_req", rhs => "1'b1"}),
                            e_assign->new({lhs => "dgen_enable", rhs => "1'b1"}),
                            e_if->new
                            ({
                                condition	=> "(local_ready && read_req)",
                                then		=>
                                [
#									e_assign->new({lhs => "incr_address", rhs => "1'b1"}),
                                    e_if->new
                                    ({
                                        condition	=> "reached_max_count",
                                        then		=>
                                        [
                                            e_assign->new({lhs => "state", rhs => $S_READ_ALL_WAIT}),
                                            e_assign->new({lhs => "read_req", rhs => "1'b0"}),
                                            e_assign->new({lhs => "reset_address", rhs => "1'b1"}),
                                        ],
                                    }),
                                ],
                            }),
                        ],

                        $S_READ_ALL_WAIT =>
                        [
                            e_if->new
                            ({
                                condition	=> "avalon_burst_mode == 0",
                                then		=>
                                [
                                    e_if->new
                                    ({
                                        condition	=> "(reads_remaining == 0)",
                                        then		=>
                                        [
                                            e_assign->new({lhs => "state", rhs => $S_IDLE}),
                                            e_assign->new({lhs => "dgen_enable", rhs => "1'b0"}),
                                            e_assign->new({lhs => "test_complete", rhs => "1'b1"}),
                                        ],
                                    }),
                                ],
                                else =>
                                [
                                    e_if->new
                                    ({
                                        condition	=> "(reads_remaining == 1)",
                                        then		=>
                                        [
                                            e_assign->new({lhs => "dgen_enable", rhs => "1'b0"}),
                                        ],
                                    }),

                                    e_if->new
                                    ({
                                        condition	=> "(reads_remaining == 0)",
                                        then		=>
                                        [
                                            e_assign->new({lhs => "dgen_enable", rhs => "1'b1"}),
                                            e_assign->new(["burst_begin" => "1"]),
                                            e_assign->new({lhs => "write_req", rhs => "1'b1"}),
                                            e_assign->new({lhs => "read_req", rhs => "1'b0"}),
                                            e_assign->new({ lhs => "reset_address", rhs => "1'b0"}),
                                            e_assign->new(["burst_beat_count" => "0"]),
                                            e_assign->new({lhs => "state", rhs => $S_BURST_WRITE_ALL}),
                                        ],
                                    }),
                                ]
                            }),
                        ],

                        $S_WRITE =>
                        [
                            e_assign->new({lhs => "write_req", rhs => "1'b1"}),
                            e_assign->new({lhs => "dgen_enable", rhs => "1'b1"}),
                            e_assign->new({lhs => "wait_first_write_data", rhs => "1'b1"}),
                            e_if->new
                            ({
                                condition	=> "(local_ready)",
                                then		=>
                                [
                                    e_assign->new({lhs => "state", rhs => "$S_WRITE_WAIT"}),
                                    e_assign->new({lhs => "write_req", rhs => "1'b0"}),
                                ]
                            }),
                        ],

                        $S_WRITE_WAIT =>
                        [
                            e_if->new
                            ({
                                condition	=> "(writes_remaining == 0)",
                                then		=>
                                [
                                    e_assign->new({lhs => "state", rhs => $S_READ}),
                                    e_assign->new({lhs => "dgen_load", rhs => "1'b1"}),
                                ],
                            }),
                        ],

                        $S_READ =>
                        [
                            e_assign->new({lhs => "read_req", rhs => "1'b1"}),
                            e_assign->new({lhs => "dgen_enable", rhs => "1'b1"}),
                            e_if->new
                            ({
                                condition	=> "(local_ready)",
                                then		=>
                                [
#									e_assign->new({lhs => "incr_address", rhs => "1'b1"}),
                                    e_assign->new({lhs => "state", rhs => "$S_READ_WAIT"}),
                                    e_assign->new({lhs => "read_req", rhs => "1'b0"}),
                                ]
                            }),
                        ],

                        $S_READ_WAIT =>
                        [
                            e_if->new
                            ({
                                condition	=> "(reads_remaining == 0)",
                                then		=>
                                [
                                    e_if->new
                                    ({
                                        condition	=> "",
                                        then		=>
                                        [
                                            e_assign->new({lhs => "reset_address", rhs => "1'b1"}),
                                            e_assign->new({lhs => "dgen_enable", rhs => "1'b0"}),
                                            e_assign->new({lhs => "state", rhs => "$S_IDLE"}),
                                            e_assign->new({lhs => "test_complete", rhs => "1'b1"}),
                                        ],
                                        else		=>
                                        [
                                            e_assign->new({lhs => "state", rhs => "$S_WRITE"}),
                                        ],
                                    })
                                ]
                            }),
                        ],
                    },
                }),

                e_if->new
                ({
                    condition	=> "reset_address",
                    then		=>
                    [
                        e_assign->new({lhs => "cs_addr", rhs => "MIN_CHIPSEL[".$gLEGAL_MEM_CHIP_BITS." -1]", comment => "(others => '0')"}),
                        e_assign->new({lhs => "row_addr", rhs => "0"}),
                        e_assign->new({lhs => "bank_addr", rhs => "0"}),
                        e_assign->new({lhs => "col_addr", rhs => "0"}),
                    ],
                    else		=>
                    [
                        e_if->new
                        ({
                            #condition	=> "(((local_ready && write_req) && ((state == $S_WRITE_ALL) || (state == $S_BURST_WRITE_ALL))) || ((local_ready && read_req) && (state == $S_READ_ALL)) || ((local_ready) && (state == $S_READ)))",#"incr_address",
                            condition	=> "(((local_ready && write_req) && (state == $S_WRITE_ALL))) || ((local_ready && read_req) && (state == $S_READ_ALL)) || ((local_ready) && ((state == $S_READ) || (state == $S_BURST_WRITE_ALL) || (state == $S_BURST_READ_ALL) || (state == $S_BURST_READ_WAIT)))",#"incr_address",
                            #condition	=> "(((local_ready && write_req) && (state == $S_WRITE_ALL))) || ((local_ready && read_req) && (state == $S_READ_ALL)) || ((local_ready) && ((state == $S_READ) || (state == $S_BURST_WRITE_ALL))) || (state == $S_BURST_READ_ALL)",#"incr_address",
                            then		=>
                            [
                                e_if->new
                                ({
                                    condition	=> "(col_addr >= MAX_COL)",
                                    then		=>
                                    [
                                        e_assign->new(["col_addr" => "0"]),
                                        e_if->new
                                        ({
                                            condition	=> "(row_addr == MAX_ROW)",
                                            then		=>
                                            [
                                                e_assign->new(["row_addr" => "0"]),
                                                e_if->new
                                                ({
                                                    condition	=> "(bank_addr == MAX_BANK)",
                                                    then		=>
                                                    [
                                                        e_assign->new(["bank_addr" => "0"]),
                                                        e_if->new
                                                        ({
                                                            condition	=> "(cs_addr == MAX_CHIPSEL)",
                                                            then		=>
                                                            [
                                                                e_assign->new({ lhs => "cs_addr", rhs => "MIN_CHIPSEL[".$gLEGAL_MEM_CHIP_BITS." - 1]", comment => "reached_max_count <= TRUE\n(others => '0')"}),
                                                            ],
                                                            else		=>
                                                            [
                                                                e_assign->new({ lhs => "cs_addr", rhs => "cs_addr + 1'b1"}),
                                                            ],
                                                        }),
                                                    ],
                                                    else		=>
                                                    [
                                                        e_assign->new({ lhs => "bank_addr", rhs => "bank_addr + 1'b1"}),
                                                    ]
                                                }),
                                            ],
                                            else		=>
                                            [
                                                e_assign->new({ lhs => "row_addr", rhs => "row_addr + 1'b1"}),
                                            ],
                                        }),
                                    ],
                                    else		=>
                                    [
                                        e_assign->new({ lhs => "col_addr", rhs => "col_addr + ("."$LOCAL_BURST_LEN * 2)"}),
                                    ],
                                }),
                            ],
                        }),
                    ],
                }),
            ],
          }),
     );

#################################################################################################################################################################

     $module->add_contents
     (
          e_process->new
          ({
              clock			=>	"clk",
              reset			=>	"reset_n",
              _asynchronous_contents	=>
              [
                e_assign->new({lhs => "dgen_ldata", rhs => "0"}),
                e_assign->new(["last_wdata_req" => "1'b0"]),
                e_assign->new({ lhs => "compare_valid", rhs => "{"."$LOCAL_BE_BITS"."{1'b1}}", comment => "all ones"}),
                e_assign->new({ lhs => "compare_valid_reg", rhs => "{"."$LOCAL_BE_BITS"."{1'b1}}", comment => "all ones"}),
                e_assign->new({ lhs => "pnf_persist", rhs => "1'b1"}),
                e_assign->new({ lhs => "pnf_persist1", rhs => "1'b1"}),
                e_assign->new({ lhs => "compare_reg", rhs => "{"."$LOCAL_BE_BITS"."{1'b1}}", comment => "all ones"}),
                e_assign->new({ lhs => "last_rdata_valid", rhs => "1'b0"}),
              ],
              contents	=>
              [
                    e_assign->new(["last_wdata_req" => "wdata_req"]),
                e_assign->new(["last_rdata_valid" => "local_rdata_valid"]),
                e_assign->new(["compare_reg" => "compare"]),
                e_if->new
                ({
                    condition	=> 	"wdata_req",
                    then		=>
                    [
                        e_if->new
                        ({
                            condition	=> 	"wait_first_write_data",
                            then		=>
                            [
                                e_assign->new(["dgen_ldata" => "dgen_data"]),
                            ],
                            comment		=> "Store the data from the first write in a burst \nUsed to reload the lfsr for the first read in a burst in WRITE 1, READ 1 mode\n",
                        }),
                    ],
                }),
                e_if->new
                ({
                    condition	=>	"last_rdata_valid",
                    then		=>
                    [
                        e_assign->new(["compare_valid" => "compare_reg"]),
                    ],
                    comment		=> "Enable the comparator result when read data is valid",
                }),
                e_if->new
                ({
                    condition	=>	"~&compare_valid",
                    then		=>
                    [
                        e_assign->new(["pnf_persist1" => "1'b0"]),
                    ],
                    comment		=> "Create the overall persistent passnotfail output",
                }),
                e_assign->new({lhs => "compare_valid_reg", rhs => "compare_valid", comment => "Extra register stage to help Tco / Fmax on comparator output pins"}),
                e_assign->new(["pnf_persist" => "pnf_persist1"]),
              ],
              comment	=> "------------------------------------------------------------\n
                        LFSR re-load data storage\n
                    Comparator masking and test pass signal generation\n
                    ------------------------------------------------------------",
          }),
      );
##################################################################################################################################################################
$project->output();
}
1;


