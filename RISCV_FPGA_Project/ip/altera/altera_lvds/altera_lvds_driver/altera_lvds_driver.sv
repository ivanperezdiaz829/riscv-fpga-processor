// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ps / 1 ps

module altera_lvds_driver (
	pll_areset,
	pll_locked,
	dzoutx,
	dpahold,
	dparst,
	dpaswitch,
	fiforst,
	core_in,
	par_in,                 
	bslipcntl,
	bsliprst,
	lock,
	pclk,
	bslipmax,
	par_out,                
	lvdsin,
	pclkdpa,
	lvdsout,                
	loopback2_data,
	data_lback_adj,
	loaden,
	data_lback2,
	data_lback13,
	tx_outclock,
	coreclock, 
	refclk
);

parameter MODE = "RX_Non-DPA";
parameter J_FACTOR = 10;
parameter DATA_RATE = "1600";
parameter TX_OUTCLOCK_DIVISION = 1;
parameter TX_OUTCLOCK_PHASE_SHIFT = 0; 
parameter pll_inclock_frequency = "100.0 MHz";
parameter NUM_CHANNELS = 1;
parameter pll_fclk_frequency = "1600.000000 MHz";
parameter pll_sclk_frequency = "160.000000 MHz";
parameter pll_loaden_frequency = "160.000000 MHz";
parameter pll_sclk_phase_shift = "312 ps";
parameter pll_fclk_phase_shift = "312 ps";
parameter pll_loaden_phase_shift = "5000 ps";
parameter pll_loaden_duty_cycle = 10;

localparam LOOPS = 20;
localparam SERDES_CHECKER_LOOPS = 2**(10-J_FACTOR);
localparam CYCLES_TO_PLL_LOCK = 500; 
localparam ALIGNER_WAIT_CYCLES = 4; 
localparam ALIGNMENT_WORD = 2**(J_FACTOR-1);
localparam BSLIPCNTL_PULSE_LENGTH = 10000;
localparam MAX_DPA_TRANSITIONS = 300; 
localparam REGTEST_TIMEOUT = 5000; 

output logic        pll_areset;
input  logic        pll_locked;
input  logic        dzoutx;
output logic        dpahold;
output logic [0:0]  dparst;
output logic        dpaswitch;
output logic        fiforst;
output logic        core_in;
output logic [J_FACTOR - 1:0]  par_in;
output logic [0:0]  bslipcntl;
output logic [0:0]  bsliprst;
input  logic        lock;
input  logic        pclk;
input  logic        bslipmax;
input  logic [J_FACTOR - 1:0]  par_out;
output logic [0:0]  lvdsin;
output logic        pclkdpa;
input  logic        lvdsout;
output logic        loopback2_data;
output logic        data_lback_adj;
input  logic        loaden;
input  logic        data_lback2;
input  logic        data_lback13;
input  logic        tx_outclock;
input  logic        coreclock;
output logic        refclk;

integer random;
reg [J_FACTOR-1:0] current_data;
reg [J_FACTOR-1:0] compare_data;

reg [2:0] delay;
reg has_error, data_ready;
reg fclk;
reg sclk; 
reg dpa_lock_watchdog_reset;
integer latency,j,loop_count,timeout_count;
bit one_time,check_off;
reg pll_locked_error;
reg dpa_locked_error; 
reg [NUM_CHANNELS-1:0] channel_done;
reg [NUM_CHANNELS-1:0] dpa_training_done; 
reg [NUM_CHANNELS-1:0] alignment_done; 

wire fclk_fb_wire;
wire sclk_fb_wire;
wire actual_sclk; 

initial 
begin
    refclk<= 0;
    forever #5000 refclk <= ~refclk;
end

assign actual_sclk = (MODE == "RX_Soft-CDR") ? pclk : coreclock; 

initial 
begin
	pll_areset <= 1'b0;
	dpahold <= 1'b0;
	dparst <= 1'b1;
	dpaswitch <= 1'b0;
	fiforst <= 1'b0;
	core_in <= 1'b0;
	par_in <= 'x;
	bslipcntl <= 1'b0;
	bsliprst <= 1'b0;
	lvdsin <= 'x;
	pclkdpa <= 1'b0;
	loopback2_data <= 'x;
    data_lback_adj <= 'x;
	random = 0;
    loop_count = 0;
	has_error <= 1'b0;
    latency <= 0;
    channel_done <= {NUM_CHANNELS{1'b0}};
    alignment_done<={NUM_CHANNELS{1'b0}};
    dpa_training_done <= {NUM_CHANNELS{1'b0}};
	dpa_lock_watchdog_reset <= 1'b1;
    #1000; pll_areset <= 1'b1;


    #40000 pll_areset <= 1'b0;

    @(posedge pll_locked);
    dparst <= 1'b0;

	if (MODE == "TX")
    begin
    $display ("TX basic mode, fork, and begin injection");
        alignment_done<={NUM_CHANNELS{1'b1}};  
        dpa_training_done <= {NUM_CHANNELS{1'b1}};
        par_in <= 10'b1;
        check_tx_outclock();
        par_in <='x;
        wait_n_sclk_cycles(4);
        fork
            write_tx_channel(0);
            check_tx_channel(0);
        join_none 
    end
	else if (MODE == "RX_Non-DPA" || MODE == "RX_DPA-FIFO" || MODE == "RX_Soft-CDR" )
	begin 
        $display ("RX basic mode, fork, and begin injection");
            if (MODE == "RX_DPA-FIFO" || MODE == "RX_Soft-CDR")
                train_dpa_channel(0,{2'b11,{J_FACTOR-2{1'b0}}}); 
            else
                dpa_training_done <= {NUM_CHANNELS{1'b1}};
            fork 
                rx_inject_alignment_word(ALIGNMENT_WORD,0);
                align_rx_channel(0);  
            join
            fork		
                write_rx_channel(0);
                check_rx_channel(0);
            join_none    
    end    
    else begin
        $display ("ERROR: Configuration not supported, or invalid, by TB.");
        has_error <=1;
    end     
end

initial
begin
    wait_n_sclk_cycles(REGTEST_TIMEOUT); 
	if (check_for_error() == 0)
		$display("Simulation SUCCESS");
	else
		$display("Simulation ERROR");

	$finish;
end

check_lock #(
    .LOCK_NAME("pll_locked"),
    .WAIT_CYCLES(CYCLES_TO_PLL_LOCK))
    pll_lock_check (
    .lock(pll_locked),
    .clk(refclk), 
    .reset(pll_areset), 
    .error(pll_locked_error));

check_lock #(
    .LOCK_NAME("rx_dpa_locked"),
    .WAIT_CYCLES(CYCLES_TO_PLL_LOCK))
    dpa_lock_check (
    .lock(lock),
    .clk(refclk), 
    .reset(pll_areset|dparst|dpa_lock_watchdog_reset), 
    .error(dpa_locked_error));


generic_pll #(
.reference_clock_frequency(pll_inclock_frequency),
.output_clock_frequency(pll_fclk_frequency),
.phase_shift(pll_fclk_phase_shift),
.duty_cycle(50)
) fclk_pll (
.refclk(refclk), 
.rst(pll_areset), 
.fbclk(fclk_fb_wire),
.fboutclk(fclk_fb_wire),
.outclk(fclk));
    
 generic_pll #(
.reference_clock_frequency(pll_inclock_frequency),
.output_clock_frequency(pll_sclk_frequency),
.phase_shift(pll_sclk_phase_shift),
.duty_cycle(50)
) sclk_pll (
.refclk(refclk), 
.rst(pll_areset), 
.fbclk(sclk_fb_wire),
.fboutclk(sclk_fb_wire),
.outclk(sclk));
    
   


/*
always @(fclk) begin
#1;
if (DRIVER_serdes__ser_des_configuration == "TX") begin

	if (DRIVER_serdes__tx_mux_src == "TX_MUX_SRC_TXDAT" && fclk == 1)
		check_ser();

	else if (DRIVER_serdes__tx_mux_src == "TX_MUX_SRC_TXDAT_NEG" && fclk == 0)
		check_ser();
end

end */


task automatic write_tx_channel (input integer channel);
begin
reg [J_FACTOR-1:0] data;
integer loop_count;

for (loop_count=0;loop_count<SERDES_CHECKER_LOOPS;loop_count=loop_count+1) begin
    data = {J_FACTOR{1'b0}}; 

    do begin  
        @(posedge sclk)  
            par_in <= data;

        data = data + 1; end
    while (data !== {J_FACTOR{1'b0}});
end
$display("Write_tx: Finished injecting words to channel %d", channel);
end
endtask


task automatic write_rx_channel(input integer channel);
begin
reg [J_FACTOR-1:0] data;
integer count_ser, loop_count;

$display("Write_rx_channel: Commence injecting bits to channel %d", channel);

for (loop_count=0;loop_count<SERDES_CHECKER_LOOPS;loop_count=loop_count+1) begin

    data = {J_FACTOR{1'b0}};  
    do begin  
        serialize_word(data,channel,0);
        data = data + 1; 
        end
    while (data !== {J_FACTOR{1'b0}});   

    end
$display("Write_rx_channel: Finished injecting bits to channel %d", channel);
end
endtask

task write_tx_bit_neg ();
begin
	foreach (current_data [m]) begin
		@(posedge fclk);
		lvdsin <= $random;
		delay[0] <= lvdsin;
		delay[1] <= delay[0];
		current_data [m] <= delay[1];
	end
#1;
	compare_data <= current_data;
	data_ready <= 1;
end
endtask


task automatic check_tx_channel(input integer channel);
begin
	
reg done, start;
reg [J_FACTOR-1: 0] expected_word, received_word; 

int loop_count, count_ser;

done = 1'b0;
expected_word = {J_FACTOR{1'b0}}; 
count_ser= 0;
start = 1'b0; 
loop_count = 0; 

    while (!done) begin
        while(count_ser < J_FACTOR) begin
            @ (negedge fclk) begin
                if (lvdsout === 1'bx && start === 1'b0 )
                    count_ser = 0;
                
               else if (start === 1'b1 && lvdsout == 1'bx) begin
                    $display("Check TX CHANNEL %d ERROR: Time: %d No data received when expected", channel, $time ); 
                    has_error <= 1'b1; end

               else begin 
                    if (lvdsout !==1'bx && start === 1'b0) 
                        start = 1'b1;
                        
                    received_word[count_ser] = lvdsout;
                    count_ser = count_ser + 1;
                    end
           end
        end
        
        if (expected_word !== received_word) begin
            has_error<=1'b1;
            $display("Check TX Channel %d ERROR: Time %d Did not receive expected bitstream.", channel, $time);
            $display("Received Word: 0x%b  Expected Word: 0x%b", received_word, expected_word); end

        else $display("Check TX Channel %d CHECKED: Time %d, received word: 0x%b, expected word: 0x%b",channel,$time,received_word, expected_word); 
        
        count_ser = 0;
        expected_word = expected_word + 1'b1; 
        received_word = 'x;

        if (expected_word === {J_FACTOR{1'b0}}) begin
            loop_count=loop_count+1;
            if (loop_count == SERDES_CHECKER_LOOPS)
                done = 1'b1;
            end    
    end        
    
    $display("Check TX Channel %d CHECK COMPLETE time:%d", channel, $time);
    channel_done[channel] <= 1'b1;
end        
endtask

task automatic check_rx_channel (input integer channel);
begin

reg done, start;
reg [J_FACTOR-1: 0] expected_word; 
int loop_count;
logic coreclock; 

done = 1'b0;
expected_word = {J_FACTOR{1'b0}}; 
start = 1'b0; 
loop_count = 0;

    while (!done) begin
        if (expected_word === {J_FACTOR{1'b1}}) begin
            loop_count=loop_count+1;
            if (loop_count == SERDES_CHECKER_LOOPS)
                done = 1;
        end        
        @(posedge actual_sclk) begin

            if (start === 1'b0 && par_out[J_FACTOR-1:0] === 0) begin
                $display ("INFO: time %d RX channel %d correctly received start word (0)",$time,channel);
                start = 1'b1;
                expected_word = expected_word + 1; 
            end
            else if (start===1'b1) begin  
                if (par_out !== expected_word) begin
                    $display ("ERROR: Check RX channel %d Time: %d  Did not receive expected word.",channel,$time);
                    $display ("     Received Word: 0x%b,  Expected Word: 0x%b", par_out, expected_word); 
                    has_error<=1;
                end
                else
                    $display("CHECKED: channel %d Time: %d Correctly received word: 0x%b", channel, $time, par_out); 
                expected_word = expected_word + 1; 
            end 
        end
     end   
     $display ("FINISH: Check RX channel %d has successfully iterated through expected words Time: %d", channel, $time); 
     channel_done[channel] <= 1'b1;
end
endtask
                        

task check_txclk_pos ();
	if (lvdsout === fclk) begin
		$display("Checked: time %d, LVDSOUT read 0x%h, expected 0x%h", $time, lvdsout, fclk); end
	else begin
		$display("ERROR: time %d, LVDSOUT read 0x%h, expected 0x%h", $time, lvdsout, fclk);
		has_error <= 1'b1; end
endtask

task automatic serialize_word (input logic [J_FACTOR-1:0] word, input integer channel, input integer delay);
    int index;
    for(index=0;index<J_FACTOR;index++)
        if (MODE == "RX_Non-DPA")
        begin
            @(negedge fclk) 
                lvdsin <= #(delay)word[index];
        end
        else 
        begin
            @(posedge fclk) 
                lvdsin <= #(delay)word[index];
        end
endtask

task automatic rx_inject_alignment_word(input logic [J_FACTOR-1:0] word, input integer channel);
    while (alignment_done[channel] !== 1'b1)
        serialize_word(word, channel,0);
endtask        

task automatic deserialize_word (input integer channel, int serial_delay, output logic [J_FACTOR-1:0] word);
    int index; 
    @(posedge sclk);
    #1; 
    for (index=0; index < serial_delay; index++)
        @(posedge fclk);
    for (index=J_FACTOR-1;index>=0;index--)
        @(posedge fclk)
            word[index] = lvdsout; 
endtask             
            

task check_tx_outclock ();
time fclk_period, first_edge, second_edge, falling_edge, word_start; 
int index, upper_bound, lower_bound, duty_cycle, dc_upper_bound, dc_lower_bound, local_error, phase_shift;
int ps_upper_bound, ps_lower_bound; 

    local_error = 0; 
    fclk_period = 0; 
    @(posedge fclk)
        first_edge = $time; 
    @(posedge fclk)
        second_edge = $time;
    
    fclk_period = second_edge - first_edge; 
    upper_bound = (1.02)*(TX_OUTCLOCK_DIVISION*fclk_period);
    lower_bound = (0.98)*(TX_OUTCLOCK_DIVISION*fclk_period);

    if (J_FACTOR%2 == 1 && TX_OUTCLOCK_DIVISION == J_FACTOR && TX_OUTCLOCK_PHASE_SHIFT%180 != 0)
    begin
        dc_upper_bound = 100*(real'((J_FACTOR)/2+1)/(J_FACTOR)) + 2;
        dc_lower_bound = 100*(real'((J_FACTOR)/2+1)/(J_FACTOR)) - 2;
    end
    else begin
        dc_upper_bound = 52;
        dc_lower_bound = 48; 
    end

    ps_upper_bound = (real'(TX_OUTCLOCK_PHASE_SHIFT+23)/360 *fclk_period);
    ps_lower_bound = (real'(TX_OUTCLOCK_PHASE_SHIFT-23)/360 *fclk_period);
    if (ps_lower_bound < 0) 
        ps_lower_bound += fclk_period * TX_OUTCLOCK_DIVISION;

    $display ("PS_UB: %d, PS_LB: %d", ps_upper_bound, ps_lower_bound);
    $display ("DC_UB: %d, DC_LB: %d", dc_upper_bound, dc_lower_bound);


    for (index = 0; index < J_FACTOR * 10; index++)
    begin
        @(posedge lvdsout)
            word_start = $time; 
        @(posedge tx_outclock)
            first_edge = $time;
        @(negedge tx_outclock)
            falling_edge = $time; 
        @(posedge tx_outclock)
            second_edge = $time;

        if ((second_edge-first_edge) > upper_bound ||
            (second_edge-first_edge) < lower_bound)
        begin
            $display("ERROR: time %d TX_OUTCLOCK period is not within 2%% of the expected value.",$time);
            $display("\t Upper Bound:%d Lower Bound %d Measured: %d" ,upper_bound,lower_bound, (second_edge - first_edge));
            local_error = 1;
        end
        
        duty_cycle = 100*(real'((falling_edge - first_edge))/(second_edge - first_edge));
        if (duty_cycle > dc_upper_bound || duty_cycle < dc_lower_bound)
        begin
            $display("ERROR: time %d TX_OUTCLOCK duty cycle is not within 2%% of the expect value", $time);
            $display("\t Upper Bound:%d Lower Bound %d Measured: %d" ,dc_upper_bound,dc_lower_bound, duty_cycle);
            local_error = 1;
        end
        
        phase_shift = first_edge - word_start;
        
        if ((ps_upper_bound >= ps_lower_bound && (phase_shift > ps_upper_bound || phase_shift < ps_lower_bound)) || 
           (ps_upper_bound < ps_lower_bound && (phase_shift > ps_upper_bound && phase_shift < ps_lower_bound))) 
        begin
            $display("ERROR: time %d TX_OUTCLOCK phase shift not within +/- 10 fclk degrees of the expected value", $time);
            $display("\t Upper Bound:%d Lower Bound %d Measured: %d" ,ps_upper_bound,ps_lower_bound, phase_shift);
            local_error = 1;
        end

     end 
     
    if (local_error == 1)
        has_error <= 1'b1;
    else
    begin
        $display("INFO: expectations, and measured TX_OUTCLOCK characteristics"); 
        $display("\tPeriod      -- Upper Bound:%d Lower Bound %d Measured: %d" ,upper_bound,lower_bound, (second_edge - first_edge));
        $display("\tDuty Cycle  -- Upper Bound:%d Lower Bound %d Measured: %d" ,dc_upper_bound,dc_lower_bound, duty_cycle);
        $display("\tPhase Shift -- Upper Bound:%d Lower Bound %d Measured: %d" ,ps_upper_bound,ps_lower_bound, phase_shift);
        $display("INFO: time %d TX_OUTCLOCK checking has passed.", $time);
    end    
endtask
    



task automatic align_rx_channel(input integer channel);
    
    logic [J_FACTOR-1:0] result, initial_alignment, found_alignment;
    int count, slips;  

    initial_alignment = 'x;
    result= 'x; 
    slips = 0; 
    found_alignment = 1'b0;
    
    wait_n_sclk_cycles(4); 

    while (found_alignment !== 1'b1)
    begin
        
        wait_n_sclk_cycles(ALIGNER_WAIT_CYCLES);

        if (initial_alignment === 'x)
        begin
            initial_alignment = par_out;
        end

        if (par_out === ALIGNMENT_WORD)
        begin
            found_alignment = 1'b1;
            $display("INFO: time %d RX channel %d, aligned after %d bitslips", $time, channel, slips);
            #10;
        end
        else 
        begin
            $display("Received word 0x%h , expect word 0x%h", par_out, ALIGNMENT_WORD);
            bslipcntl <= 1'b1; 
            slips = (slips+1)%J_FACTOR; 
            if (slips % J_FACTOR == 0)
            begin
                if (bslipmax !== 1'b1)
                begin
                    $display("ERROR: time %d RX channel %d has not asserted bslipmax before expected rollover.", $time, channel);
                    has_error <= 1'b1;
                end   
                else
                    $display ("WARNING: time %d RX channel %d has not aligned after %d slips. The bitslip will now rollover.", $time, channel, J_FACTOR-1);
            end        
            else    
                $display("INFO: time %d RX channel %d asserting bslipcntrl, bitslip now set to %d serial cycles", $time, channel, slips);

            bslipcntl <= 1'b1; 
            wait_n_sclk_cycles(1);
            bslipcntl <= 1'b0;
        end
    end  

    bsliprst<=1'b1;
    wait_n_sclk_cycles(1);
    bsliprst<=1'b0;
    wait_n_sclk_cycles(ALIGNER_WAIT_CYCLES);
    if (par_out !== initial_alignment)
    begin
        $display("ERROR: time %d rx_cda_reset (bsliprst) doesn't seem to revert the received back to the default alignment", $time);
        $display("Default Alignment: 0x%h Received Alignment: 0x%h (Training word: 0x%h)", initial_alignment, par_out, ALIGNMENT_WORD);
        has_error<= 1'b1;
    end

    for (count = 0;count < slips; count ++)
    begin
        bslipcntl <= 1'b1;
        wait_n_sclk_cycles(1);
        bslipcntl <= 1'b0;
        wait_n_sclk_cycles(ALIGNER_WAIT_CYCLES);
    end 

    if (par_out !== ALIGNMENT_WORD)
    begin
        $display("ERROR: time %d The word was not successfully realigned after asserting rx_cda_reset(bsliprst)", $time);
        $display("Default Alignment: 0x%h Received Alignment: 0x%h (Training word: 0x%h)", initial_alignment, par_out, ALIGNMENT_WORD);
        has_error<= 1'b1;
    end

    for (count = slips; count<J_FACTOR-1;count++)
    begin
        bslipcntl <= 1'b1;
        wait_n_sclk_cycles(1);
        bslipcntl <= 1'b0;
        wait_n_sclk_cycles(ALIGNER_WAIT_CYCLES);
    end
    
    if (bslipmax !== 1'b1)
    begin
        $display("ERROR: time %d rx_cda_max (bslipmax) was not asserted after J_FACTOR-1 (%d) assertions", $time, J_FACTOR-1);
        has_error<=1'b1;
    end
    
    bslipcntl <= 1'b1;
    wait_n_sclk_cycles(1);
    bslipcntl <= 1'b0;
    wait_n_sclk_cycles(ALIGNER_WAIT_CYCLES);

    if (par_out !== initial_alignment)
    begin
        $display("ERROR: time %d the bitslip doesn't appear to rollover after %d (JFACTOR) assertions of bslipcntl", $time, J_FACTOR);
        $display("Default Alignment: 0x%h Received Alignment: 0x%h (Training word: 0x%h)", initial_alignment, par_out, ALIGNMENT_WORD);
        has_error<= 1'b1;
    end

    for (count = 0;count < slips; count++)
    begin
        bslipcntl <= 1'b1;
        wait_n_sclk_cycles(1);
        bslipcntl <= 1'b0;
        wait_n_sclk_cycles(ALIGNER_WAIT_CYCLES);
    end 

    if (par_out !== ALIGNMENT_WORD)
    begin
        $display("ERROR: time %d The word was not successfully realigned after bitslip rollover", $time);
        $display("Expected Alignment: 0x%h Received Alignment: 0x%h", ALIGNMENT_WORD, par_out);
        has_error<= 1'b1;
    end
    alignment_done[channel] <= 1'b1;
    $display("INFO: time %d BITSLIP STRESSING COMPLETE",$time); 
endtask

task automatic train_dpa_channel(input integer channel, input logic [J_FACTOR-1:0] training_word); 
    logic done, lock_prev;
    integer delay, dpa_ui, count, pos_trans, loop_cnt, first_edge, second_edge;

    done = 1'b0; 
    lock_prev = 1'b1;
    delay = 0;
    loop_cnt  = 0;
    /*
    pos_trans = count_positive_transitions(training_word);
    $display("INFO: DPA training word has %d transitions", pos_trans*2);
    @(posedge fclk)
        first_edge = $time; 
    @(posedge fclk)
        second_edge = $time;

    dpa_ui = (second_edge - first_edge)/8 + 1;
    $display("INFO: Measured ideal fclk period: %d, ideal UI: %d", (second_edge - first_edge), dpa_ui);
    
    while (loop_cnt < 4)
    begin

        if (lock !== 1'b0)
        begin   
            has_error <= 1'b1; 
            $display("ERROR: Time: %t DPA has asserted lock (or is X, HiZ) before providing a bitstream,or after a reset", $time);    
        end
        else
        begin
            $display("INFO: Time %t Commencing DPA stress iteration %d", $time, loop_cnt);
        end
        count = 0;
        while (lock !== 1'b1 && count*pos_trans*2 < MAX_DPA_TRANSITIONS)
        begin
            serialize_word(training_word,channel,0);
            count++; 
        end    
       
        if (count*pos_trans*2 >= MAX_DPA_TRANSITIONS)
        begin
            $display("ERROR: Time: %t Stage1a: DPA has not asserted lock after providing approximately %d transitions on lvdsin", $time, count*pos_trans*2);  
            has_error <=1'b1;
        end
        else
        begin
            $display ("INFO: time: %t Stage1a:  DPA has locked after recieving approximately %d training words", $time, count);
            count = 0; 
            while (count<MAX_DPA_TRANSITIONS && lock === 1'b1)
            begin
                serialize_word(training_word,channel,0);
                count++; 
            end
            if(lock !== 1'b1)
            begin
                $display("ERROR: Time: %t stage1b: DPA lost lock unexpectedly. (No phase delay was introduced between assertion and deassertion", $time);  
                has_error <=1'b1;
            end
        end
        
        count=0;
        lock_prev = 1'b1; 
        while ( (lock_prev !== 1'b0 || lock !== 1'b1) && count*pos_trans*2 < MAX_DPA_TRANSITIONS) 
        begin
           lock_prev = lock; 
           serialize_word(training_word,channel,3.5*dpa_ui);
           count++; 
        end
        
        if (count*pos_trans*2 >= MAX_DPA_TRANSITIONS)
        begin
            if (lock == 1'b1)
            begin
                $display("ERROR: Time: %t Stage2a: DPA did not lose lock after insterting 2UI delay in bitstream", $time);  
                has_error <=1'b1;
            end
            else
            begin
                $display("ERROR: Time: %t Stage2a: DPA did not regain lock after inserting 2UI delay in bitstream", $time);  
                has_error <=1'b1;
            end
        end
        else
        begin
            $display ("INFO: time: %t Stage 2a: DPA has regained lock after adding 2UI delay, receiving approximately %d training words", $time, count);
            count = 0; 
            while (count<MAX_DPA_TRANSITIONS && lock === 1'b1)
            begin
                serialize_word(training_word,channel,3.5*dpa_ui);
                count++; 
            end
            if(lock !== 1'b1)
            begin
                $display("ERROR: Time: %t Stage2b: DPA lost lock unexpectedly. (No phase delay was introduced between assertion and deassertion", $time);  
                has_error <=1'b1;
            end
        end    
            
        
        count =0; 
        lock_prev = 1'b1; 
        while ( (lock_prev !== 1'b0 || lock !== 1'b1) && count*pos_trans*2 < MAX_DPA_TRANSITIONS) 
        begin
           lock_prev = lock; 
           serialize_word(training_word,channel,0);
           count++; 
        end
        
        if (count * pos_trans* 2 == MAX_DPA_TRANSITIONS)
        begin
            if (lock == 1'b1)
            begin
                $display("ERROR: Time: %t Stage 3a: DPA did not lose lock after removing 2UI delay in bitstream", $time);  
                has_error <=1'b1;
            end
            else
            begin
                $display("ERROR: Time: %t Stage 3a: DPA did not regain lock after removing 2UI delay in bitstream", $time);  
                has_error <=1'b1;
            end
        end
        else
        begin
            $display ("INFO: time: %t Stage 3a:DPA has regained lock removing 2UI delay, receiving approximately %d training words", $time, count);

            count = 0; 
            while (count<MAX_DPA_TRANSITIONS && lock === 1'b1)
            begin
                serialize_word(training_word,channel,0);
                count++; 
            end
            if(lock !== 1'b1)
            begin
                $display("ERROR: Time: %t Stage 3b: DPA lost lock unexpectedly. (No phase delay was introduced between assertion and deassertion", $time);  
                has_error <=1'b1;
            end
        end    


        dparst <= 1'b1;
        fiforst <= 1'b1; 
        serialize_word(training_word,channel,0);
        serialize_word(training_word,channel,0);
        dparst <= 1'b0;
        fiforst <= 1'b0;
        loop_cnt++; 
    end
    */ 
    
    while (lock !== 1'b1)
        begin
            serialize_word(training_word,channel,0);
        end  
    
    dpa_training_done[channel] <= 1'b1;
    $display("INFO: time %d DPA LOGIC STRESSING COMPLETE",$time);
    
    for (count = 0; count<MAX_DPA_TRANSITIONS; count++)
        serialize_word(training_word,channel,0);

endtask

task check_txclk_neg ();
	if (lvdsout === ~fclk) begin
		$display("Checked: time %d, LVDSOUT read 0x%h, expected 0x%h", $time, lvdsout, ~fclk); end
	else begin
		$display("ERROR: time %d, LVDSOUT read 0x%h, expected 0x%h", $time, lvdsout, ~fclk);
		has_error <= 1'b1; end
endtask

function bit check_for_error();
int index; 
    
    if (pll_locked_error == 1'b1) 
    begin
       return(1); 
    end

    if (dpa_locked_error == 1'b1 && (MODE == "RX_DPA-FIFO" || MODE == "RX_Soft-CDR"))
    begin
        return(1);
    end    
    
    
   for (index = 0; index < NUM_CHANNELS; index++)
   begin
        
        if(dpa_training_done[index] !== 1'b1)
        begin
            $display("ERROR: Channel %d DPA block did not pass stressing (stressing task did not assert flag)", index); 
        end   
        else if(alignment_done[index] !== 1'b1)
        begin
            $display("ERROR: Channel %d was not properly aligned (alignment task did not assert flag)", index); 
        end   
        else if(channel_done[index] !== 1'b1)
        begin
            $display("ERROR: Channel %d did not run to completion (checker did not assert done flag)", index); 
        end            
   end 
   
   if (&channel_done !== 1'b1 || &alignment_done !==1'b1 || &dpa_training_done !==1'b1 )
       return(1); 
    
   return(has_error);
endfunction  


function count_positive_transitions(input logic [J_FACTOR-1:0] word);
integer index, transitions;
transitions = 0;

    for (index=0;index<J_FACTOR;index++)
    begin
        if ({word[(index+1)%J_FACTOR],word[index]} === 2'b10)
            transitions++;
    end 
    return transitions;
endfunction

task automatic wait_n_sclk_cycles (integer num_cycles);
int index;
int j;
    for (index=0;index<num_cycles;index++)
        for (j = 0;j<J_FACTOR;j++)
            @(posedge fclk);
endtask


endmodule

/********************************************************************************/
/***                                MODULES                                   ***/
/********************************************************************************/ 



module check_lock (input logic lock, input logic reset, input logic clk, output logic error);
    parameter WAIT_CYCLES = 10000; 
    parameter LOCK_NAME = "lock"; 
    localparam WAIT_FOR_LOCK = 2'b00;
    localparam HOLD_LOCK = 2'b01;
    localparam ERROR = 2'b10; 
    reg [1:0] state;
    reg lock_prev; 
    reg [31:0] waited; 

    always @(posedge clk or posedge reset)
    begin
        if (reset == 1'b1) 
            state <= WAIT_FOR_LOCK; 
        else if (waited > WAIT_CYCLES && state == WAIT_FOR_LOCK)
        begin
            $display("ERROR: %s has not locked after waiting %d cycles", LOCK_NAME, WAIT_CYCLES); 
            state <= ERROR; 
        end
        else if (lock_prev === 1'b1 && lock === 1'b0 && state == HOLD_LOCK) 
        begin
            $display("ERROR: %s deasserted at time %t",LOCK_NAME, $time); 
            state <= ERROR; 
        end    
        else if (lock_prev === 1'b0 && lock === 1'b1)
        begin    
            $display("INFO: %s asserted at time %t (%d refclk cycles)", LOCK_NAME, $time, waited); 
            state <= HOLD_LOCK; 
        end
        else
            state <= state; 
    end

    assign error = (state == ERROR) ? 1'b1 : 1'b0; 

    always @(posedge clk or posedge reset)
    begin
        if (reset == 1'b1) 
            waited <= 32'b0; 
        else if (state == WAIT_FOR_LOCK && lock !== 1'b1 && waited <= WAIT_CYCLES ) 
            waited <= waited +1; 
        else
            waited <= waited;
    end
    
    always @(posedge clk or posedge reset) 
    begin
        if (reset == 1'b1) 
            lock_prev <= 1'b0; 
        else
            lock_prev <= lock; 
    end    
endmodule


