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


`define SMALL 2'b00
`define LARGE 2'b01

`timescale 1ns/1ns
module avalon_st_snk_bfm_wrp (
                   clk,                  
                   rst_n,                
                   sink_data,         
                   sink_valid,        
                   sink_startofpacket,
                   sink_endofpacket,  
                   sink_error,        
                   sink_empty,        
                   sink_ready 
                             );
                                          
  parameter ST_SYMBOL_W      = 115;   
  parameter ST_NUMSYMBOLS    = 1;
  parameter ST_EMPTY_W       = 3;
  parameter ST_MAX_CHANNELS  = 0; 
  parameter ST_USE_PACKET    = 1;
  parameter ST_USE_EMPTY     = 1;
  
  //input output ports declaration
  
  input  logic clk;                                           
  input  logic rst_n;                                      
  input  logic [(ST_SYMBOL_W * ST_NUMSYMBOLS) -1 : 0 ] sink_data;                           
  input  logic sink_valid;
  input  logic sink_startofpacket;
  input  logic sink_endofpacket;  
  input  logic sink_error;           
  input  logic [ST_EMPTY_W -1 : 0]sink_empty;           
  output logic sink_ready;           
  
  import hutil_pkg::*;
    
  //Header interface
  altera_avalon_st_sink_bfm#(
        .ST_SYMBOL_W       (ST_SYMBOL_W),   
        .ST_NUMSYMBOLS     (ST_NUMSYMBOLS),
        .ST_EMPTY_W        (ST_EMPTY_W),
        .ST_MAX_CHANNELS   (ST_MAX_CHANNELS), 
        .USE_PACKET        (ST_USE_PACKET),
        .USE_EMPTY         (ST_USE_EMPTY))
                             
  U_avalon_st_sink_bfm (
            .clk                   (clk),   
            .reset                 (!rst_n),
            .sink_data             (sink_data),
            .sink_channel          (),
            .sink_valid            (sink_valid),
            .sink_startofpacket    (sink_startofpacket),
            .sink_endofpacket      (sink_endofpacket),
            .sink_error            (sink_error),
            .sink_empty            (sink_empty),
            .sink_ready            (sink_ready));
  
  
  
    
 task receive_header_avalon_st;
  input reg  [1 : 0] tt;
  input reg  [3 : 0] ftype;
  input reg  [3 : 0] ttype;
  input int          payload_size; // Number of payload bytes
  input reg  [15: 0] dest_id;
  input reg [28 : 0] rio_dut_addr;

  reg  [15:0]  source_id;
  reg [114:0] exp_header;
  
  reg [3:0]   wrsize;
  reg         wdptr;
  bit [28:0]  address;
  bit [114:0] header_data;
  bit [7 : 0] tid_rcvd;

  if (tt == `SMALL) 
    source_id = 'h00AB;
  else if (tt == `LARGE)
    source_id = 'hABAB;

  //Assume payload size is minimum of 8
    case (payload_size) 
      1 : begin
            wrsize = 'b0011;
            wdptr = 1'b0;
          end
      2:  begin
            wrsize = 'b0110;
            wdptr = 1'b1;
          end
      4:  begin
            wrsize = 'b1000;
            wdptr = 1'b0;
          end
      8 : begin 
            wrsize = 'b1011;
            wdptr = 0;
          end
     16 : begin 
            wrsize = 'b1011;
            wdptr = 1;
          end
     32 : begin 
            wrsize = 'b1100;
            wdptr = 0;
          end
     64 : begin 
            wrsize = 'b1100;
            wdptr = 1;
          end
    128 : begin 
            wrsize = 'b1101;
            wdptr = 1;
          end
    256 : begin 
            wrsize = 'b1111;
            wdptr = 1;
          end
     default :  begin 
                 wrsize = 'b1011;
                 wdptr = 0;
               end
   endcase
  if ((dest_id == 'h5555) | (dest_id == 'h0055)) 
    address = rio_dut_addr; 
  else
    address = 29'b1_1110_1010_1101_1011_1110_1110_1111;
  //Form the expected header
  //Currently only supports IO packet headers
  if (payload_size < 8) 
     payload_size = 8; 
  U_avalon_st_sink_bfm.set_ready(1'b1);
  @U_avalon_st_sink_bfm.signal_transaction_received;
  $display("%m %t Transaction received on Sink Header side",$stime);
  U_avalon_st_sink_bfm.pop_transaction();
  header_data = U_avalon_st_sink_bfm.get_transaction_data();
  $display("%m Header Recieved on passthrough port is %h",header_data);
  tid_rcvd = header_data [55 : 48];
  $display("%m tid Recieved on passthrough port is %h",tid_rcvd);
  
     exp_header = {payload_size,2'b00,2'b10,tt,ftype,dest_id,source_id,ttype,wrsize,tid_rcvd,address,wdptr,2'b01 ,16'b0}; 
  $display("expected address = %h",address);
     //exp_header = {payload_size,2'b00,2'b10,tt,ftype,dest_id,source_id,ttype,wrsize,8'b00,address,wdptr,2'b01 ,16'b0};
  //expect_n("PT Header",exp_header,header_data,115);
  check("PT Header",exp_header[31:0],header_data[31:0]);
  check("PT Header",exp_header[63:32],header_data[63:32]);
  check("PT Header",exp_header[95:64],header_data[95:64]);
  check("PT Header",{13'b0,exp_header[114:96]},{13'b0,header_data[114:96]});

endtask

task receive_payload_avalon_st;
  input reg  [1 : 0] tt;
  input reg  [3 : 0] ftype;
  input reg  [3 : 0] ttype;
  input int          payload_size; // Number of payload bytes
  input reg  [15 : 0] dest_id;
 

  int rem_payload;
  bit [7:0] payload[];
  int pld_part_first;
  bit [3:0] exp_empty;
  int i,j;
  static int cycle_count = 0;
  bit sop;
  bit eop;
  bit [3:0] empty;
  bit [127:0] data;
  bit [127:0] exp_data;
  bit error;
  bit timed_out;
  static time time_out = 150us;
  int k;
  bit [127 : 0  ] packet [];

  begin
    if (payload_size < 8) 
      payload_size = 8;
    if (payload_size%16) begin
      payload = new[payload_size + (payload_size%16)];
      cycle_count = (payload_size/16) + 1;
    end
    else begin
      cycle_count = (payload_size/16);
      payload = new[payload_size];
    end  
    exp_empty = 16 - (payload_size%16);

    if (tt == `SMALL) 
      pld_part_first = 6;
    else
      pld_part_first = 4;
 
    for (i=1;i<=pld_part_first;i++) begin
      payload[i-1] = i;
      $display("%m %t Payload data is is %x",$stime,payload[i-1]);
    end

    rem_payload = payload_size - pld_part_first;

    j = pld_part_first;
    for (i=0;i < rem_payload; i = i + 16) begin
       for (k=0;k<16;k++) begin
         if (((i/16) + k) > rem_payload)
           payload[j + k + i] = 'h00;
         else
           payload[j + k + i] = i + k;
       end
    end
    
    U_avalon_st_sink_bfm.set_ready(1'b1);
    for (i=0;i<cycle_count;i++) begin
      fork
        begin
          @U_avalon_st_sink_bfm.signal_transaction_received;
          $display("%m %t Transaction received on Sink Payload side",$stime);
        end
        begin
          #time_out;   
          timed_out = 1;
        end
      join_any
      if (timed_out) begin
        $display("%m %0t ERROR: Timed out waiting for Payload",$stime);
        err_cnt++;
        exit();
      end
      else if ((dest_id !== 'h00cd) | (dest_id !== 'hcdcd))
      begin
            j = (i/16);
            payload[0]   = i;
            payload[1]   = (i+1) >= payload_size ? 'h00 : (i+1);
            payload[2]   = (i+2) >= payload_size ? 'h00 : (i+2);
            payload[3]   = (i+3) >= payload_size ? 'h00 : (i+3);
            payload[4]   = (i+4) >= payload_size ? 'h00 : (i+4);
            payload[5]   = (i+5) >= payload_size ? 'h00 : (i+5);
            payload[6]   = (i+6) >= payload_size ? 'h00 : (i+6);
            payload[7]   = (i+7) >= payload_size ? 'h00 : (i+7);
            payload[8]   = (i+8) >= payload_size ? 'h00 : (i+8);
            payload[9]   = (i+9) >= payload_size ? 'h00 : (i+9);
            payload[10] = (i+10) >= payload_size ? 'h00 : (i+10);
            payload[11] = (i+11) >= payload_size ? 'h00 : (i+11);
            payload[12] = (i+12) >= payload_size ? 'h00 : (i+12);
            payload[13] = (i+13) >= payload_size ? 'h00 : (i+13);
            payload[14] = (i+14) >= payload_size ? 'h00 : (i+14);
            payload[15] = (i+15) >= payload_size ? 'h00 : (i+15);
            packet[j] = {payload[0],payload[1],payload[2],
                             payload[3],payload[4],payload[5],
                             payload[6],payload[7],payload[8],
                             payload[9],payload[10],payload[11],
                             payload[12],payload[13],payload[14],
                             payload[15]};
            $display("expected packet data is", packet[j]);
            expect_1("pld_error",1'b0,error);
            check("pld_data",packet[j][31:0],data[31:0]); 
            check("pld_data",packet[j][63:32],data[63:32]); 
            check("pld_data",packet[j][95:64],data[95:64]); 
            check("pld_data",packet[j][127:96],data[127:96]);
     end
      else 
      begin
        exp_data = {payload[16*i],payload[16*i+1],payload[16*i+2],payload[16*i+3],payload[16*i+4],payload[16*i+5],payload[16*i+6],payload[16*i+7],payload[16*i+8],payload[16*i+9],payload[16*i+10],payload[16*i+11],payload[16*i+12],payload[16*i+13],payload[16*i+14],payload[16*i+15]};
        $display("%m %t Generated Exp Data is %x",$stime,exp_data);
        U_avalon_st_sink_bfm.pop_transaction();
        sop = U_avalon_st_sink_bfm.get_transaction_sop();
        eop = U_avalon_st_sink_bfm.get_transaction_eop();
        data = U_avalon_st_sink_bfm.get_transaction_data();
        empty = U_avalon_st_sink_bfm.get_transaction_empty();
        error = U_avalon_st_sink_bfm.get_transaction_error();
        $display("%m %t Doing comparison for cycle %d",$stime,i);
        if (i == 0) 
          expect_1("pld_startofpacket",1'b1,sop);
        else
          expect_1("pld_startofpacket",1'b0,sop);
        if (i == (cycle_count -1)) begin
          expect_1("pld_endofpacket",1'b1,eop);
          if ((dest_id != 'h5555) | (dest_id != 'h0055))
             expect_n("pld_empty",exp_empty,empty,4);
          if (exp_empty == 8) begin
            exp_data = exp_data && 'hFFFFFFFF_00000000;
            data = data && 'hFFFFFFFF_00000000;
          end
        end
        else begin
          expect_1("pld_endofpacket",1'b0,eop);
          //expect_n("pld_empty",4'b0000,empty,4);
        end
        expect_1("pld_error",1'b0,error);
        check("pld_data",exp_data[31:0],data[31:0]); 
        check("pld_data",exp_data[63:32],data[63:32]); 
        check("pld_data",exp_data[95:64],data[95:64]); 
        check("pld_data",exp_data[127:96],data[127:96]); 
      end
    end
  end
endtask    
  
  task avst_snk_bfm_trans;
  
    output logic [(ST_SYMBOL_W * ST_NUMSYMBOLS) -1 : 0 ]data;
    output logic [ST_EMPTY_W -1 : 0]empty;
    output logic sop;
    output logic eop;
  
    begin
       @U_avalon_st_sink_bfm.signal_transaction_received;
       $display("%m %t Transaction received on Sink side",$stime);
       U_avalon_st_sink_bfm.pop_transaction();
       data  = U_avalon_st_sink_bfm.get_transaction_data();
       empty = U_avalon_st_sink_bfm.get_transaction_empty();
       sop   = U_avalon_st_sink_bfm.get_transaction_sop();
       eop   = U_avalon_st_sink_bfm.get_transaction_eop();
    end
  endtask

endmodule

