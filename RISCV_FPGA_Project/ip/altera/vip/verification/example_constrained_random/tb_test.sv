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


module tb_test;

// 24RGB has 3 channels per pixel, whereas YCbCr is 2 :
`define CHANNELS_PER_PIXEL      3

// 8 bits per channel :
`define BITS_PER_CHANNEL         8

// The Avalon-ST video protocol supports both symbols in sequence (serial)
// and symbols in parallel (parallel).  Both are supported via the define below :
`define TRANSPORT          parallel

// The constrained random test will just keep generating and testing packets for as long
// as specified, here in clock cycles :
`define TEST_DURATION     20000

import av_st_video_classes::*;
typedef c_av_st_video_data #(.BITS_PER_CHANNEL(`BITS_PER_CHANNEL), .CHANNELS_PER_PIXEL(`CHANNELS_PER_PIXEL)) video_t;
 
// Create clock and reset:
logic clk, resetn;

initial
    clk <= 1'b0;
   
always
    #2.5 clk <= ~clk; //200 MHz


initial
begin
    resetn <= 1'b0;
    #10 @(posedge clk) resetn <= 1'b1;
end

// Instantiate "netlist" :
`define NETLIST netlist
tb  `NETLIST (.reset_reset_n(resetn),.clk_clk(clk));

// Create some useful objects from our defined classes :
c_av_st_video_data        #(`BITS_PER_CHANNEL, `CHANNELS_PER_PIXEL) video_data_pkt1,  video_data_pkt2 ;
c_av_st_video_control     #(`BITS_PER_CHANNEL, `CHANNELS_PER_PIXEL) video_control_pkt1,  video_control_pkt2;
c_av_st_video_user_packet #(`BITS_PER_CHANNEL, `CHANNELS_PER_PIXEL) user_pkt1, user_pkt2 ;

c_av_st_video_item          item_data  ;
c_av_st_video_item          item_data_copy  ;

c_av_st_video_item          item_pkt  ;
c_av_st_video_item          reference_pkt  ;
c_av_st_video_item          dut_pkt  ;

c_av_st_video_data          dut_video_pkt  ;
c_av_st_video_control       dut_control_pkt  ;
c_av_st_video_user_packet   dut_user_pkt  ;

// This creates a class with a names specific to `SOURCE0, which is needed because the
// class calls functions for that specific `SOURCE0.  A class is used so that individual mailboxes
// can be easily associated with individual sources/sinks :


// This names MUST match the instance name of the source in tb.v :
`define SOURCE st_source_bfm_0 
`define SOURCE_STR "st_source_bfm_0"
`define SOURCE_HIERARCHY_NAME `NETLIST.`SOURCE
`include "../class_library/av_st_video_source_bfm_class.sv"

// Create an object of name `SOURCE of class av_st_video_source_bfm_`SOURCE :
`define CLASSNAME c_av_st_video_source_bfm_`SOURCE
`CLASSNAME `SOURCE;
`undef CLASSNAME


// This names MUST match the instance name of the sink in tb.v :
`define SINK st_sink_bfm_0 
`define SINK_STR "st_sink_bfm_0"
`define SINK_HIERARCHY_NAME `NETLIST.`SINK
`include "../class_library/av_st_video_sink_bfm_class.sv"

// Create an object of name `SINK of class av_st_video_sink_bfm_`SINK :
`define CLASSNAME c_av_st_video_sink_bfm_`SINK
`CLASSNAME `SINK;
`undef CLASSNAME


// Create mailboxes to transfer video packets and control packets :
mailbox #(c_av_st_video_item) m_video_items_for_src_bfm = new(0);
mailbox #(c_av_st_video_item) m_video_items_from_sink_bfm = new(0);
mailbox #(c_av_st_video_item) m_video_items_for_scoreboard = new(0);
mailbox #(c_av_st_video_item) m_dut_items_for_scoreboard = new(0);

int r;
int fields_read;

event event_constrained_random_generation;
event event_dut_output_analyzed;

initial
begin
    
    wait (resetn == 1'b1)
    repeat (4) @ (posedge (clk));
 
    video_data_pkt1    = new();    
    video_control_pkt1 = new();
    user_pkt1          = new();


    // Associate the mailboxes with the source and sink classes via their constructors :
    `SOURCE = new(m_video_items_for_src_bfm);
    `SINK   = new(m_video_items_from_sink_bfm);
    
    // Avaon-ST video packets should be sent with pixels in parallel :
    `SOURCE.set_pixel_transport(`TRANSPORT);
      `SINK.set_pixel_transport(`TRANSPORT);
    
    `SOURCE.set_name(`SOURCE_STR);
      `SINK.set_name(  `SINK_STR);
    
    `SOURCE.set_readiness_probability(90);
      `SINK.set_readiness_probability(90); 
      
    `SOURCE.set_long_delay_probability(0.01);
      `SINK.set_long_delay_probability(0.01);
    
        
    fork    
    
        `SOURCE.start();
        `SINK.start();

        forever
        begin

            // Randomly determine which packet type to send :
            r = $urandom_range(100, 0);
            if (r>67)
            begin
                video_data_pkt1.set_max_length(100);
                video_data_pkt1.randomize();
                $display("\n%t Constrained random sending a VIDEO data packet of length %0d ",$time, video_data_pkt1.get_length());

                // Send it to the source BFM :
                m_video_items_for_src_bfm.put(video_data_pkt1);
                
                // Copy and send to scoreboard :
                video_data_pkt2 = new();
                video_data_pkt2.copy(video_data_pkt1);
                m_video_items_for_scoreboard.put(video_data_pkt2); 
                
            end
            else if (r>34)
            begin
                video_control_pkt1.randomize();
                $display("\n%t Constrained random sent control packet (width = %0d, height = %0d, interlacing = 0x%0h)",$time,video_control_pkt1.get_width(),video_control_pkt1.get_height(),video_control_pkt1.get_interlacing());
                m_video_items_for_src_bfm.put(video_control_pkt1);

                // Copy and send to scoreboard :
                video_control_pkt2 = new();
                video_control_pkt2.copy(video_control_pkt1);
                m_video_items_for_scoreboard.put(video_control_pkt2); 

            end
            
            else
            begin
                user_pkt1.set_max_length(33);
                user_pkt1.randomize() ;
                $display("\n%t Constrained random sending a USER packet of length %0d",$time, user_pkt1.get_length());
                m_video_items_for_src_bfm.put(user_pkt1);
                
                // Copy and send to scoreboard :
                user_pkt2 = new();
                user_pkt2.copy(user_pkt1);
                m_video_items_for_scoreboard.put(user_pkt2); 

            end    
            
            // Video items have been sent to the DUT and the scoreboard, wait for the analysis :
            -> event_constrained_random_generation;  
            wait(event_dut_output_analyzed);      
                                                                   
        end

        
    join    
         
end    


// Scoreboard :


// The DUT's packet behaviour is to absorb user packets and to always output a 
// control packet followed by a video packet, regardless of how many control
// packets it sees at its input :
initial
begin

    forever
    begin

        @event_constrained_random_generation
        begin
            
            // Get the reference item from the scoreboard mailbox :
            m_video_items_for_scoreboard.get(reference_pkt);          
            
            // If the reference item is a video packet, then check for the control & video packet response :
            if (reference_pkt.get_packet_type() == video_packet)
            begin
            
                m_video_items_from_sink_bfm.get(dut_pkt); 
                if (dut_pkt.get_packet_type() != control_packet)
                    $fatal(1,"SCOREBOARD ERROR : DUT output a %s instead of a control packet ",display_video_item_type(dut_pkt.get_packet_type()));

                m_video_items_from_sink_bfm.get(dut_pkt);                 
                if (dut_pkt.get_packet_type() != video_packet)
                    $fatal(1, "SCOREBOARD ERROR : DUT output a %s instead of a video packet ",display_video_item_type(dut_pkt.get_packet_type()));
                
                // A video packet has been received, as expected.  Now compare the video data itself :
                dut_video_pkt = c_av_st_video_data'(dut_pkt);
                if (dut_video_pkt.compare (to_greyscale(c_av_st_video_data'(reference_pkt))))
                    $display("%t Scoreboard match : Video packet of length %0d received.\n",$time,dut_video_pkt.get_length());
                else
                    $fatal(1, "SCOREBOARD ERROR : Incorrect video packet.\n");
                    
            end             
            
            -> event_dut_output_analyzed;

        end               

    end
    
end        

initial
begin
    #`TEST_DURATION  $display("\nTest passed after %0d clocks\n\n", `TEST_DURATION );
    $finish;
end

// The scoreboard calls a function which models the behaviour of the video algorithm :
function c_av_st_video_data to_greyscale (c_av_st_video_data rgb) ;

    const bit [7:0]   red_factor =  76; // 255 * 0.299
    const bit [7:0] green_factor = 150; // 255 * 0.587;
    const bit [7:0]  blue_factor =  29; // 255 * 0.114;

    c_av_st_video_data            grey;
    c_pixel                  rgb_pixel;
    c_pixel                 grey_pixel;
    int                     grey_value;

    grey = new ();
    grey.packet_type = video_packet;

    do
    begin
        grey_pixel = new();            
        rgb_pixel = rgb.pop_pixel();

        // Turn RGB into greyscale :
        grey_value = (  red_factor * rgb_pixel.get_data(2) +
                      green_factor * rgb_pixel.get_data(1) +
                       blue_factor * rgb_pixel.get_data(0));

        grey_pixel.set_data(2, grey_value[15:8]);
        grey_pixel.set_data(1, grey_value[15:8]);
        grey_pixel.set_data(0, grey_value[15:8]);
        grey.push_pixel(grey_pixel);   
    end
    while (rgb.get_length()>0);

    return grey;

endfunction


endmodule
