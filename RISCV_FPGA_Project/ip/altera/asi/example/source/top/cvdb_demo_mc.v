//--------------------------------------------------------------------------------------------------
// (c)2004 Altera Corporation. All rights reserved.
//
// Altera products are protected under numerous U.S. and foreign patents,
// maskwork rights, copyrights and other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design License
// Agreement (either as signed by you or found at www.altera.com).  By using
// this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not
// agree with such terms and conditions, you may not use the reference design
// file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an �as-is� basis and as an
// accommodation and therefore all warranties, representations or guarantees of
// any kind (whether express, implied or statutory) including, without
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or
// require that this reference design file be used in combination with any
// other product not provided by Altera.
//--------------------------------------------------------------------------------------------------
// File          : $RCSfile: cvdb_demo_mc.v,v $
// Last modified : $Date: 2013/08/11 $
// Export tag    : $Name:  $
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------


module cvdb_demo_mc (
  clk0,
  clk1,
  clk2,
  clk3,

  asi_rx0,
  asi_rx1,
  asi_tx,
  sdi_rx,
  sdi_tx,

  switch,
  button,
  led,
  header_clk,
  header_gnd,
  header_rx_dat,
  header_rx_ena,
  header_rx_sop,
  header_rx_eop,
  header_rx_lock,
  header_tx_dat,
  header_tx_ena
);

input         clk0;
input         clk1;
input         clk2;
input         clk3;

input         asi_rx0;
input         asi_rx1;
output        asi_tx;
input         sdi_rx;
output        sdi_tx;

input   [7:0] switch;
input   [3:0] button;
output  [3:0] led;
//inout  [31:0] header;
output        header_clk;
output  [6:0] header_gnd;
output  [7:0] header_rx_dat;
output        header_rx_ena;
output        header_rx_sop;
output        header_rx_eop;
output  [1:0] header_rx_lock;
input   [7:0] header_tx_dat;
input         header_tx_ena;


wire rx_refclk = clk3;

wire tx_refclk = clk1;


wire rst = ~button[0];


   
//--------------------------------------------------------------------------------------------------
// Generate sampling clocks for deserializer. Sampling rate is 5/4x data rate, i.e. 337.5MHz.
// Two phases are produced by the PLL, one being a 90 degree phase shift from the other. Within the
// deserializer these two phases and their inverse are used to sample the data four times per sample
// clock which is equivalent to five samples per bit period.
//--------------------------------------------------------------------------------------------------

wire sclk_rx;
wire sclk90_rx;
wire rx_pll_locked;
pll_sclk u_rx_pll(
  .inclk0   (rx_refclk),
  .areset   (rst),
  .c0       (sclk_rx),
  .c1       (sclk90_rx),
  .locked   (rx_pll_locked)
  );

   
//--------------------------------------------------------------------------------------------------
// Local receive clock is 135MHz. Generate using logic as Cyclone PLL only has two outputs.
//--------------------------------------------------------------------------------------------------

   
wire rx_clk135;

clkdiv_2p5 u_clkdiv(
  .rst      (rst),
  .sclk     (sclk_rx),
  .sclk90   (sclk90_rx),
  .clkdiv   (rx_clk135)
  );


//--------------------------------------------------------------------------------------------------
// Generate 270MHz clock for serial transmit
//--------------------------------------------------------------------------------------------------
wire tx_clk270;
pll_x10_top u_tx_pll(
  .inclk0   (tx_refclk),
  .areset   (rst),
  .c0       (tx_clk270),
  .c1       (tx_clk27), 
  .locked   ()
  );

   
   
//--------------------------------------------------------------------------------------------------
// ASI receive logic for ASI_RX0
//--------------------------------------------------------------------------------------------------
wire [7:0] rx_dat_0;
wire [5:0] rx0_ts_status;
   
   asi_rx u_rx0
     ( 
       .rst             (rst),
       .asi_rx          (asi_rx0),
       .rx_serial_clk   (sclk_rx),
       .rx_serial_clk90 (sclk90_rx),
       .rx_clk135       (rx_clk135),
       .rx_data         (rx_dat_0),
       .rx_ts_status    (rx0_ts_status),
       .rx_data_clk     ()
       );
   
 // if lock acheived, illuminate LED.  
 assign led[0] = ~(rx0_ts_status[5:4]!=2'b00);

//--------------------------------------------------------------------------------------------------
// ASI receive logic for ASI_RX1
//--------------------------------------------------------------------------------------------------
wire [7:0] rx_dat_1;
wire [5:0] rx1_ts_status;
wire       rxclk;
   
   asi_rx u_rx1
     ( 
       .rst             (rst),
       .asi_rx          (asi_rx1),
       .rx_serial_clk   (sclk_rx),
       .rx_serial_clk90 (sclk90_rx),
       .rx_clk135       (rx_clk135),
       .rx_data         (rx_dat_1),
       .rx_ts_status    (rx1_ts_status),
       .rx_data_clk     (rxclk)
       
       );
 // if lock acheived, illuminate LED.    
 assign led[1] = ~(rx1_ts_status[5:4]!=2'b00);
   

//--------------------------------------------------------------------------------------------------
// Select input that is indicating lock (rx0 has priority)
//--------------------------------------------------------------------------------------------------
   
wire [7:0] rx_dat_sel  = (rx0_ts_status[5:4]!=2'b00) ? rx_dat_0  : rx_dat_1;
wire [5:0] rx_ts_status  = (rx0_ts_status[5:4]!=2'b00) ? rx0_ts_status  : rx1_ts_status;
  
 
//--------------------------------------------------------------------------------------------------
// Retime to local 27MHz clock
//--------------------------------------------------------------------------------------------------

wire [1:0] rx_lock;
wire [7:0] rx_dat;
wire rx_ena;
wire rx_sop;
wire rx_eop;


asi_buffer u_buffer (
 .rx_clk       (rxclk),
  .rx_rst       (rst),
  .rx_lock      (rx_ts_status[5:4]),
  .rx_dat       (rx_dat_sel),
  .rx_ena       (rx_ts_status[0]),
  .rx_sop       (rx_ts_status[1]),
  .rx_eop       (rx_ts_status[2]),
  .rx_err       (rx_ts_status[3]),

  .pad_188      (~switch[5]),

  .tx_clk       (tx_clk27),
  .tx_lock      (rx_lock),
  .tx_dav       (1'b1),
  .tx_dat       (rx_dat),
  .tx_ena       (rx_ena),
  .tx_sop       (rx_sop),
  .tx_eop       (rx_eop)
  );


//--------------------------------------------------------------------------------------------------
// Send data out to header
//--------------------------------------------------------------------------------------------------
reg [1:0] rx_lock_d;
reg [7:0] rx_dat_d;
reg rx_ena_d;
reg rx_sop_d;
reg rx_eop_d;
always @ (posedge tx_clk27)
begin
  rx_lock_d <= rx_lock;
  rx_dat_d <= rx_dat;
  rx_ena_d <= rx_ena;
  rx_sop_d <= rx_sop;
  rx_eop_d <= rx_eop;
end

wire [13:0] ddio_in_h;
wire [13:0] ddio_in_l;
wire [13:0] ddio_out;

assign ddio_in_h[0] = 1'b1;
assign ddio_in_l[0] = 1'b0;

assign ddio_in_h[13:1] = {rx_lock_d, rx_eop_d, rx_sop_d, rx_ena_d, rx_dat_d};
assign ddio_in_l[13:1] = {rx_lock_d, rx_eop_d, rx_sop_d, rx_ena_d, rx_dat_d};

ddio_out u_ddio (
  .outclock (tx_clk27),
  .datain_h (ddio_in_h),
  .datain_l (ddio_in_l),
  .dataout  (ddio_out)
  );

/*
assign header[31] = ddio_out[0];         // CLK

assign header[16] = ddio_out[1];         // DAT
assign header[17] = ddio_out[2];
assign header[21] = ddio_out[3];
assign header[23] = ddio_out[4];
assign header[25] = ddio_out[5];
assign header[27] = ddio_out[6];
assign header[26] = ddio_out[7];
assign header[29] = ddio_out[8];

assign header[15] = ddio_out[9];         // ENA
assign header[14] = ddio_out[10];        // SOP
assign header[13] = ddio_out[11];        // EOP
assign header[12] = ddio_out[12];        // Lock
assign header[30] = ddio_out[13];

assign header[0]  = 1'b0;
assign header[19] = 1'b0;
assign header[20] = 1'b0;
assign header[22] = 1'b0;
assign header[24] = 1'b0;
assign header[28] = 1'b0;

assign header[10] = 1'b0;
*/
assign header_clk = ddio_out[0];         // CLK

assign header_rx_dat[0] = ddio_out[1];         // DAT
assign header_rx_dat[1] = ddio_out[2];
assign header_rx_dat[2] = ddio_out[3];
assign header_rx_dat[3] = ddio_out[4];
assign header_rx_dat[4] = ddio_out[5];
assign header_rx_dat[5] = ddio_out[6];
assign header_rx_dat[6] = ddio_out[7];
assign header_rx_dat[7] = ddio_out[8];

assign header_rx_ena = ddio_out[9];         // ENA
assign header_rx_sop = ddio_out[10];        // SOP
assign header_rx_eop = ddio_out[11];        // EOP
assign header_rx_lock[0] = ddio_out[12];        // Lock
assign header_rx_lock[1] = ddio_out[13];

assign header_gnd = 7'b0;


//--------------------------------------------------------------------------------------------------
// Switch 7 determines if output is generated from received data (OPEN) or parallel data from
// header (CLOSED).
//--------------------------------------------------------------------------------------------------
reg [7:0] tx_dat;
reg tx_ena;
always @ (posedge tx_clk27)
begin

  tx_ena    <= switch[7] ? rx_ena    : header_tx_ena;
  tx_dat[0] <= switch[7] ? rx_dat[0] : header_tx_dat[0];
  tx_dat[1] <= switch[7] ? rx_dat[1] : header_tx_dat[1];
  tx_dat[2] <= switch[7] ? rx_dat[2] : header_tx_dat[2];
  tx_dat[3] <= switch[7] ? rx_dat[3] : header_tx_dat[3];
  tx_dat[4] <= switch[7] ? rx_dat[4] : header_tx_dat[4];
  tx_dat[5] <= switch[7] ? rx_dat[5] : header_tx_dat[5];
  tx_dat[6] <= switch[7] ? rx_dat[6] : header_tx_dat[6];
  tx_dat[7] <= switch[7] ? rx_dat[7] : header_tx_dat[7];
end

//--------------------------------------------------------------------------------------------------
// ASI transmit logic
//--------------------------------------------------------------------------------------------------

   
   // ASI Transmit Megacore
   wire t_asi_tx;
   asi_tx	u_tx
     (
      .rst              (rst),
      .tx_refclk        (tx_clk27),
      .tx_clk270        (tx_clk270),
      .tx_data          (tx_dat),
      .tx_en            (tx_ena),
      .asi_tx           (t_asi_tx)
      );
   
 assign asi_tx = switch[0] ? t_asi_tx : ~t_asi_tx;   
   
   
//--------------------------------------------------------------------------------------------------
// Status LED's
//--------------------------------------------------------------------------------------------------

reg cable_error;
reg [23:0] error_delay;
reg [7:0] rx_dat_d1;
reg [7:0] rx_dat_d2;
reg [7:0] rx_dat_d3;
reg [7:0] rx_dat_d4;
always @ (posedge tx_clk27)
begin
  rx_dat_d1 <= rx_dat_d;
  rx_dat_d2 <= rx_dat_d1;
  rx_dat_d3 <= rx_dat_d2;
  rx_dat_d4 <= rx_dat_d3;
  if (~switch[7] & tx_ena & tx_dat!=rx_dat_d3) begin
    cable_error <= 1'b1;
    error_delay <= 24'hFFFFFF;
  end
  else if (error_delay>0) begin
    error_delay <= error_delay - 24'd1;
  end
  else begin
    cable_error <= 1'b0;
  end
end

assign led[3] = switch[7] ? ~(rx_ts_status[5:4]!=2'b00) : ~cable_error;

//--------------------------------------------------------------------------------------------------
// NULL packet generator for test purposes
//--------------------------------------------------------------------------------------------------
wire [7:0] gen_dat;
wire gen_ena;


   
    auk_ts_packet_gen u_gen (
      .clk                  (tx_clk27),
      .rst                  (rst),
      .enable               (1'b1),
      .id                   (8'h00),
      .len_188_204n         (switch[6]),
      .gap                  (~switch[4] ? 10 : 1023),
      .ts_data              (gen_dat),
      .ts_valid             (gen_ena),
      .ts_start             (),
      .ts_end               ()
      );

   // ASI transmit Megacore outputs null packet on port labelled SDI_TX
   wire t_sdi_tx;
   
   asi_tx	u_tx2
     (
      .rst              (rst),
      .tx_refclk        (tx_clk27),
      .tx_clk270        (tx_clk270),
      .tx_data          (gen_dat),
      .tx_en            (gen_ena),
      .asi_tx           (t_sdi_tx)
      );
 
   assign sdi_tx = switch[0] ? t_sdi_tx : ~t_sdi_tx;
   


   
//--------------------------------------------------------------------------------------------------
// NULL packet checker for test purposes
//--------------------------------------------------------------------------------------------------
 
   wire [5:0] rx2_ts_status;
   wire [7:0] rx2_dat;
      
   asi_rx u_rx2
     ( 
       .rst             (rst),
       .asi_rx          (sdi_rx),
       .rx_serial_clk   (sclk_rx),
       .rx_serial_clk90 (sclk90_rx),
       .rx_clk135       (rx_clk135),
       .rx_data         (rx2_dat),
       .rx_ts_status    (rx2_ts_status),
       .rx_data_clk     ()
       
       );
 



   wire       check_error;
   auk_ts_packet_check u_check 
     (
      .clk              (rxclk),
      .rst              (rst),
      .ts_valid         (rx2_ts_status[0]),
      .ts_data          (rx2_dat),
      .ts_start         (rx2_ts_status[1]),
      .ts_end           (rx2_ts_status[2]),
      .ts_lock          (rx2_ts_status[5:4]),
      .id               (8'h00),
      .check_id         (1'b0),
      .error            (check_error)
      );

      
reg check_error_flag;
reg [23:0] check_error_delay;
always @ (posedge rxclk)
begin
  if (check_error) begin
    check_error_flag <= 1'b1;
    check_error_delay <= 24'hFFFFFF;
  end
  else if (check_error_delay>0) begin
    check_error_delay <= check_error_delay - 24'd1;
  end
  else begin
    check_error_flag <= 1'b0;
  end
end
assign led[2] = ~(rx2_ts_status[5:4]!=2'b00 & ~check_error_flag);



   //assign led[2] = button[3];


endmodule
