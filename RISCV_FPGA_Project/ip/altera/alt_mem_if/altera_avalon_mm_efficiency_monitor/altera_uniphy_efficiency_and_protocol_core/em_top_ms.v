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


`timescale 1ps/1ps


module em_top_ms #(
  parameter EMPC_EFFICIENCY = "ON",
  parameter EMPC_ENABLE_PROTOCOL_CHECK = "ON",
  parameter EMPC_AV_BURSTCOUNT_WIDTH = 3,
  parameter EMPC_AV_DATA_WIDTH = 64,
  parameter EMPC_AV_POW2_DATA_WIDTH = 64,
  parameter EMPC_AVM_ADDRESS_WIDTH = 10,
  parameter EMPC_AVS_ADDRESS_WIDTH = 10,
  parameter EMPC_AV_BE_WIDTH = 8,
  parameter EMPC_AV_POW2_BE_WIDTH = 8,
  parameter EMPC_COUNT_WIDTH = 32,
  parameter EMPC_CSR_ADDR_WIDTH = 12,
  parameter EMPC_CSR_DATA_WIDTH = 32,
  parameter EMPC_VERSION = 16'd100
)(

  input  wire          ctl_reset_n,
  input  wire          avm_clk,

  input  wire       [EMPC_CSR_ADDR_WIDTH-1:0]  csr_addr,          
  input  wire   [(EMPC_CSR_DATA_WIDTH/8)-1:0]  csr_be,          
  input  wire                                  csr_write_req,
  input  wire                                  csr_read_req,
  input  wire       [EMPC_CSR_DATA_WIDTH-1:0]  csr_wdata,
  output wire       [EMPC_CSR_DATA_WIDTH-1:0]  csr_rdata,
  output wire                                  csr_rdata_valid,
  output wire                                  csr_waitrequest,

  input  wire    [EMPC_AVM_ADDRESS_WIDTH-1:0]  avm_address,
  input  wire          [EMPC_AV_POW2_BE_WIDTH-1:0]  avm_be,
  input  wire  [EMPC_AV_BURSTCOUNT_WIDTH-1:0]  avm_burstcount,
  input  wire                                  avm_beginbursttransfer,
  output wire                                  avm_waitrequest,
  input  wire                                  avm_write,
  input  wire                                  avm_read,
  output wire                                  avm_readvalid,
  input  wire        [EMPC_AV_POW2_DATA_WIDTH-1:0]  avm_wdata,
  output wire        [EMPC_AV_POW2_DATA_WIDTH-1:0]  avm_rdata,

  output wire    [EMPC_AVS_ADDRESS_WIDTH-1:0]  avs_address,
  output wire          [EMPC_AV_BE_WIDTH-1:0]  avs_be,
  output wire  [EMPC_AV_BURSTCOUNT_WIDTH-1:0]  avs_burstcount,

  output wire                                  avs_beginbursttransfer,
  input  wire                                  avs_waitrequest,
  output wire                                  avs_write,
  output wire                                  avs_read,
  input  wire                                  avs_readvalid,
  output wire        [EMPC_AV_DATA_WIDTH-1:0]  avs_wdata,
  input  wire        [EMPC_AV_DATA_WIDTH-1:0]  avs_rdata
);


reg   [EMPC_COUNT_WIDTH-1:0]  cycle_counter;  
reg   [EMPC_COUNT_WIDTH-1:0]  transfer_counter;  
reg   [EMPC_COUNT_WIDTH-1:0]  write_counter;  
reg   [EMPC_COUNT_WIDTH-1:0]  read_counter;  
reg   [EMPC_COUNT_WIDTH-1:0]  readtotal_counter;  
reg   [EMPC_COUNT_WIDTH-1:0]  NTC_waitrequest_counter;  
reg   [EMPC_COUNT_WIDTH-1:0]  NTC_noreaddatavalid_counter;  
reg   [EMPC_COUNT_WIDTH-1:0]  NTC_masterwridle_counter;  
reg   [EMPC_COUNT_WIDTH-1:0]  NTC_masteridle_counter;  

wire cycle_count;
wire transfer_count; 
wire write_count; 
wire read_count; 
wire NTC_wait_count; 
wire NTC_noreaddv_count; 
wire NTC_masterwridle_count; 
wire NTC_masteridle_count; 

wire   [7:0]  illegal_cmd;

wire       [EMPC_COUNT_WIDTH-1:0]  rdlat_min, rdlat_max;
wire   [(EMPC_COUNT_WIDTH*2)-1:0]  rdlat_total;

wire       [EMPC_COUNT_WIDTH/2-1:0]  rdlat_min_temp, rdlat_max_temp;
wire   [(EMPC_COUNT_WIDTH*2)/2-1:0]  rdlat_total_temp;


reg  [EMPC_AV_BURSTCOUNT_WIDTH-1:0]  avm_burstcount_1q;


reg counter_saturation;

reg pattern_start;

assign  avm_waitrequest = avs_waitrequest;
assign  avm_readvalid = avs_readvalid;
assign	avm_rdata = avs_rdata;
generate
  if (EMPC_AVS_ADDRESS_WIDTH == EMPC_AVM_ADDRESS_WIDTH) begin
    assign	avs_address = avm_address;
  end else begin
    assign	avs_address = {avm_address, {(EMPC_AVS_ADDRESS_WIDTH-EMPC_AVM_ADDRESS_WIDTH){1'b0}}};
  end
endgenerate

assign	avs_be = avm_be;
assign  avs_burstcount = avm_burstcount;
assign  avs_beginbursttransfer = avm_beginbursttransfer;
assign  avs_write = avm_write;
assign  avs_read = avm_read;
assign	avs_wdata = avm_wdata;


reg                                  int_write_req;
reg                                  int_read_req;
reg       [EMPC_CSR_ADDR_WIDTH-1:0]  int_addr;
reg   [(EMPC_CSR_DATA_WIDTH/8)-1:0]  int_be;
reg       [EMPC_CSR_DATA_WIDTH-1:0]  int_rdata;
reg                                  int_rdata_valid;
reg                                  int_waitrequest;
reg       [EMPC_CSR_DATA_WIDTH-1:0]  int_wdata;


reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0001;

reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0002;

reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0008;

reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0010;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0011;

reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0014;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0018;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_001C;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0020;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0024;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0028;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_002C;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0030;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0034;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0040;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0044;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0048;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0049;
reg   [EMPC_CSR_DATA_WIDTH-1:0]  csr_register_0050;

reg  eff_mon_reset_req_reg;
reg  protocol_checker_reset_req_reg;

reg  start_stop_eff_mon_reg;

reg    [7:0]  eff_mon_status;

reg csr_snapshot_reg;

wire          resync_ctl_reset_n;

em_reset_sync em_reset_sync_inst (
  .reset_n        (ctl_reset_n),
  .clk            (avm_clk),
  .reset_n_sync   (resync_ctl_reset_n)
);
defparam em_reset_sync_inst.NUM_RESET_OUTPUT = 1;


wire start_stop_eff_mon;
assign start_stop_eff_mon = start_stop_eff_mon_reg & (pattern_start || (~pattern_start && (avm_write || avm_read)));

always @(posedge avm_clk) begin
  csr_register_0001 <= 32'hdeadbeef;

  csr_register_0002 <= {EMPC_VERSION, 16'd5};

  csr_register_0010[15:0]  <= EMPC_AVM_ADDRESS_WIDTH[15:0];
  csr_register_0010[31:16] <= EMPC_AV_DATA_WIDTH[15:0];
  csr_register_0011[15:0]  <= EMPC_AV_BE_WIDTH[15:0];
  csr_register_0011[31:16] <= EMPC_AV_BURSTCOUNT_WIDTH[15:0];
end


always @(posedge avm_clk or negedge resync_ctl_reset_n) begin
  if (~resync_ctl_reset_n) begin
    csr_register_0008 <= 0;
    csr_register_0014 <= 0;
    csr_register_0018 <= 0;
    csr_register_001C <= 0;
    csr_register_0020 <= 0;
    csr_register_0024 <= 0;
    csr_register_0028 <= 0;
    csr_register_002C <= 0;
    csr_register_0030 <= 0;
    csr_register_0034 <= 0;
    csr_register_0040 <= 0;
    csr_register_0044 <= 0;
    csr_register_0048 <= 0;
    csr_register_0049 <= 0;
    csr_register_0050 <= 0;
  end else begin
    csr_register_0008 <= 0;
    csr_register_0008[16] <= start_stop_eff_mon;
    csr_register_0008[31:24] <= eff_mon_status;

	if (csr_snapshot_reg) begin
    csr_register_0014 <= cycle_counter;

    csr_register_0018 <= transfer_counter;

    csr_register_001C <= write_counter;

    csr_register_0020 <= read_counter;

    csr_register_0024 <= readtotal_counter;

    csr_register_0028 <= NTC_waitrequest_counter;

    csr_register_002C <= NTC_noreaddatavalid_counter;

    csr_register_0030 <= NTC_masterwridle_counter;

    csr_register_0034 <= NTC_masteridle_counter;

    csr_register_0040 <= rdlat_min;

    csr_register_0044 <= rdlat_max;

    csr_register_0048 <= rdlat_total[EMPC_COUNT_WIDTH-1:0]; 
    csr_register_0049 <= rdlat_total[(EMPC_COUNT_WIDTH*2)-1:EMPC_COUNT_WIDTH];
	end

    csr_register_0050 <= 0;
    csr_register_0050[7:0] <= illegal_cmd;
  end  
end  


always @(posedge avm_clk or negedge resync_ctl_reset_n) begin
  if (~resync_ctl_reset_n) begin
    int_write_req <= 0;
    int_read_req <= 0;
    int_addr <= 0;
    int_wdata <= 0;
    int_be <= 0;
  end else begin
    int_addr  <= csr_addr;
    int_wdata <= csr_wdata;
    int_be    <= csr_be;

    int_write_req <= csr_write_req;
    int_read_req <= csr_read_req;

  end  
end  


always @(posedge avm_clk or negedge resync_ctl_reset_n) begin
  if (~resync_ctl_reset_n) begin
    int_rdata       <= 0;
    int_rdata_valid <= 0;
	csr_snapshot_reg <= 0;

    int_waitrequest <= 1'b1;
  end else begin
    int_waitrequest <= 1'b0;

	if (int_read_req && int_addr[6:0] == 'h1) begin
		csr_snapshot_reg <= 1;
	end else begin
		csr_snapshot_reg <= 0;
	end

    if (int_read_req) begin
      case (int_addr[6:0])
        'h1 :
          int_rdata <= csr_register_0001;
        'h2 :
          int_rdata <= csr_register_0002;
        'h8 :
          int_rdata <= csr_register_0008;
        'h10 :
          int_rdata <= csr_register_0010;
        'h11 :
          int_rdata <= csr_register_0011;
        'h14 :
          int_rdata <= csr_register_0014;
        'h18 :
          int_rdata <= csr_register_0018;
        'h1c :
          int_rdata <= csr_register_001C;
        'h20 :
          int_rdata <= csr_register_0020;
        'h24 :
          int_rdata <= csr_register_0024;
        'h28 :
          int_rdata <= csr_register_0028;
        'h2c :
          int_rdata <= csr_register_002C;
        'h30 :
          int_rdata <= csr_register_0030;
        'h34 :
          int_rdata <= csr_register_0034;
        'h40 :
          int_rdata <= csr_register_0040;
        'h44 :
          int_rdata <= csr_register_0044;
        'h48 :
          int_rdata <= csr_register_0048;
        'h49 :
          int_rdata <= csr_register_0049;
        'h50 :
          int_rdata <= csr_register_0050;
        default :
          int_rdata <= 0;
      endcase
    end  

    if (int_read_req) begin
      int_rdata_valid <= 1'b1;
    end else begin
      int_rdata_valid <= 1'b0;
    end

  end  
end  


always @(posedge avm_clk or negedge resync_ctl_reset_n) begin
  if (~resync_ctl_reset_n) begin

    eff_mon_reset_req_reg <= #20 0;
    protocol_checker_reset_req_reg <= #20 0;

    start_stop_eff_mon_reg <= 1;
  end else begin

    eff_mon_reset_req_reg <= 1'b1;
    protocol_checker_reset_req_reg <= 1'b1;

    if (int_write_req) begin
      case (int_addr)
        'h8 : begin
          if (int_be[0]) begin
            eff_mon_reset_req_reg <= int_wdata[0];
          end

          if (int_be[1]) begin
            protocol_checker_reset_req_reg <= int_wdata[8];
          end

          if (int_be[2]) begin
            start_stop_eff_mon_reg <= int_wdata[16];
          end
        end
      endcase
    end
  end  
end  


assign csr_waitrequest = int_waitrequest;
assign csr_rdata = int_rdata;
assign csr_rdata_valid = int_rdata_valid;


always @(posedge avm_clk or negedge resync_ctl_reset_n) begin
  if (~resync_ctl_reset_n) begin
    pattern_start <= 0;
  end else begin
    if (~eff_mon_reset_req_reg) begin  
      pattern_start <= 0;
    end else if (~pattern_start && (avm_write || avm_read)) begin
      pattern_start <= 1;
    end
  end
end


always @(posedge avm_clk or negedge resync_ctl_reset_n) begin
  if (~resync_ctl_reset_n) begin
    counter_saturation <= 1'b0;
  end else begin
    if (~eff_mon_reset_req_reg) begin
      counter_saturation <= 1'b0;
    end else if ((cycle_counter == {{(EMPC_COUNT_WIDTH-1){1'b1}}, 1'b0}) & start_stop_eff_mon) begin
      counter_saturation <= 1'b1;
    end
  end
end


always @(posedge avm_clk or negedge resync_ctl_reset_n) begin
  if (~resync_ctl_reset_n) begin
    eff_mon_status <= 0;
  end else begin
    eff_mon_status <= 0;
    eff_mon_status[0] <= ~start_stop_eff_mon_reg;
    eff_mon_status[1] <= ~pattern_start;
    eff_mon_status[2] <= (~counter_saturation & start_stop_eff_mon & pattern_start);
    eff_mon_status[3] <= counter_saturation;
  end
end


always @(posedge avm_clk or negedge resync_ctl_reset_n) begin
  if (~resync_ctl_reset_n) begin
    avm_burstcount_1q <= 0;
  end else begin
    if (avm_read & ~avm_write & ~avm_waitrequest) begin
      avm_burstcount_1q <= avm_burstcount;
    end
  end
end



always @(posedge avm_clk or negedge resync_ctl_reset_n) begin
  if (~resync_ctl_reset_n) begin 
    cycle_counter <= 0;
    transfer_counter <= 0; 
    write_counter <= 0; 
    read_counter <= 0; 
    readtotal_counter <= 0; 
    NTC_waitrequest_counter <= 0; 
    NTC_noreaddatavalid_counter <= 0; 
    NTC_masterwridle_counter <= 0; 
    NTC_masteridle_counter <= 0;       
  end else begin  
    if (~eff_mon_reset_req_reg) begin
      cycle_counter <= 0; 
      transfer_counter <= 0; 
      write_counter <= 0; 
      read_counter <= 0; 
      readtotal_counter <= 0; 
      NTC_waitrequest_counter <= 0; 
      NTC_noreaddatavalid_counter <= 0; 
      NTC_masterwridle_counter <= 0; 
      NTC_masteridle_counter <= 0;       
    end else if (~counter_saturation & start_stop_eff_mon) begin
      cycle_counter <= cycle_counter + 1; 

      if (transfer_count == 1'b1) transfer_counter <= transfer_counter + 1; 
      if (write_count == 1'b1) write_counter <= write_counter + 1; 
      if (read_count == 1'b1) read_counter <= read_counter + 1; 
      if (read_count == 1'b1) readtotal_counter <= readtotal_counter + avm_burstcount_1q; 
      if (NTC_wait_count == 1'b1) NTC_waitrequest_counter <= NTC_waitrequest_counter + 1; 
      if (NTC_noreaddv_count == 1'b1) NTC_noreaddatavalid_counter <= NTC_noreaddatavalid_counter + 1;
      if (NTC_masterwridle_count == 1'b1) NTC_masterwridle_counter <= NTC_masterwridle_counter + 1;
      if (NTC_masteridle_count == 1'b1) NTC_masteridle_counter <= NTC_masteridle_counter + 1;
    end
  end
end


assign rdlat_max = {{(EMPC_COUNT_WIDTH/2){1'b0}}, rdlat_max_temp};
assign rdlat_min = {{(EMPC_COUNT_WIDTH/2){1'b0}}, rdlat_min_temp};
assign rdlat_total = {{(EMPC_COUNT_WIDTH/2){1'b0}}, rdlat_total_temp};


generate
if (EMPC_EFFICIENCY == "ON") begin
  em_count_fsm # (
    .EMPC_AV_BURSTCOUNT_WIDTH     (EMPC_AV_BURSTCOUNT_WIDTH)
  ) em_count_fsm (
    .ctl_reset_n             (resync_ctl_reset_n),
    .av_clk                  (avm_clk),
    .av_burstcount           (avm_burstcount),
    .av_beginbursttransfer   (avm_beginbursttransfer),
    .av_write                (avm_write),
    .av_read                 (avm_read),
    .av_readvalid            (avs_readvalid),
    .av_waitrequest          (avs_waitrequest),
    .transfer_count          (transfer_count),
    .write_count             (write_count),
    .read_count              (read_count),
    .NTC_wait_count          (NTC_wait_count),
    .NTC_noreaddv_count      (NTC_noreaddv_count),
    .NTC_masterwridle_count  (NTC_masterwridle_count),
    .NTC_masteridle_count    (NTC_masteridle_count)
  );

  em_rdlat_fsm # (
    .EMPC_AV_BURSTCOUNT_WIDTH    (EMPC_AV_BURSTCOUNT_WIDTH),
    .EMPC_COUNT_WIDTH            (EMPC_COUNT_WIDTH/2)
  ) em_rdlat_fsm (
    .ctl_reset_n     (resync_ctl_reset_n),
    .clr             (~eff_mon_reset_req_reg),
    .enable          (~counter_saturation & start_stop_eff_mon),
    .av_clk          (avm_clk),      
    .av_burstcount   (avm_burstcount),
    .av_read         (avm_read),
    .av_readvalid    (avs_readvalid),
    .av_waitrequest  (avs_waitrequest),
    .cycle_count     (cycle_counter[EMPC_COUNT_WIDTH/2-1:0]),
    .rdlat_total     (rdlat_total_temp),
    .rdlat_min       (rdlat_min_temp),
    .rdlat_max       (rdlat_max_temp)
  );
end
endgenerate 


generate
if (EMPC_ENABLE_PROTOCOL_CHECK == "ON") begin
  em_protocol_fsm # (
    .EMPC_AV_BURSTCOUNT_WIDTH    (EMPC_AV_BURSTCOUNT_WIDTH),
    .EMPC_AV_DATA_WIDTH          (EMPC_AV_DATA_WIDTH),
    .EMPC_AV_ADDRESS_WIDTH       (EMPC_AVM_ADDRESS_WIDTH),
    .EMPC_AV_BE_WIDTH            (EMPC_AV_BE_WIDTH)
  ) em_protocol_fsm (
    .ctl_reset_n            (resync_ctl_reset_n),
    .av_clk                 (avm_clk),
    .av_rst_n               (resync_ctl_reset_n), 
    .av_burstcount          (avm_burstcount),
    .av_beginbursttransfer  (avm_beginbursttransfer),
    .av_write               (avm_write),
    .av_read                (avm_read),
    .av_readvalid           (avs_readvalid),
    .av_waitrequest         (avs_waitrequest),
    .av_address             (avm_address),
    .av_byteenable          (avm_be),
    .av_writedata           (avm_wdata),
    .illegal_cmd_reg_rst    (~protocol_checker_reset_req_reg),  
    .illegal_cmd_reg        (illegal_cmd)
);
end
endgenerate 

endmodule

