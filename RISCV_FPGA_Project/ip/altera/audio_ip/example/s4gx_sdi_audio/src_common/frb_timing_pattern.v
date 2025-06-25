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

module frb_timing_pattern (
  vid_clk,
  vid_clk_en,
  vid_reset,

  // control interface
  timing_std,

  // test video in
  vid_tim_en,
  vid_tim_ync,
  vid_tim_trs,
  vid_tim_fvh,
  vid_tim_pic,
  vid_tim_data,

  // test video out
  vid_pat_en,
  vid_pat_ync,
  vid_pat_trs,
  vid_pat_fvh,
  vid_pat_pic,
  vid_pat_data);

  `include "src_common/frb_include_smpte352m.v"

  input vid_clk;
  input vid_clk_en;
  input vid_reset;

  // control interface
  input [31:0] timing_std;

  // test video in
  input vid_tim_en;
  input [1:0] vid_tim_ync;
  input vid_tim_trs;
  input [2:0] vid_tim_fvh;
  input vid_tim_pic;
  input [19:0] vid_tim_data;

  // test video out
  output vid_pat_en;
  reg vid_pat_en;
  output [1:0] vid_pat_ync;
  reg [1:0] vid_pat_ync;
  output vid_pat_trs;
  reg vid_pat_trs;
  output [2:0] vid_pat_fvh;
  reg [2:0] vid_pat_fvh;
  output vid_pat_pic;
  reg vid_pat_pic;
  output [19:0] vid_pat_data;
  reg [19:0] vid_pat_data;

  wire logic0;
  //wire logic1;
  wire [3:0] vector4_0;
  wire [8:0] vector9_0;
  wire [31:0] vector32_0;

  reg vid_sd;
  reg vid_3gb;
  reg [1:0] vid_ync;
  reg [5:0] len_count;
  wire read_en;
  reg [6:0] read_addr;
  wire [8:0] read_addr_ram;
  reg [1:0] read_bank;
  wire [31:0] read_data_ram;
  wire [3:0] read_flag_ram;
  reg [35:0] read_data_p0;
  reg [35:0] read_data_p1;
  reg [1:0] vid_tim_ync_d1;
  reg vid_tim_trs_d1;
  reg [2:0] vid_tim_fvh_d1;
  reg vid_tim_pic_d1;
  reg [19:0] vid_tim_data_d1;
  reg [1:0] vid_ync_d1;
  reg [1:0] vid_tim_ync_d2;
  reg vid_tim_trs_d2;
  reg [2:0] vid_tim_fvh_d2;
  reg vid_tim_pic_d2;
  reg [19:0] vid_tim_data_d2;
  reg [1:0] vid_ync_d2;
  reg [5:0] rom_len;
  reg [9:0] rom_cb;
  reg [9:0] rom_cr;
  reg [9:0] rom_y;
  wire ram_rd;
  reg [2:0] pipe;
  reg pipe_rd;

//------------------------------------------------------------------------------
//MODULE BODY
//------------------------------------------------------------------------------

  assign logic0 = 1'b0;
  //assign logic1 = 1'b1;
  assign vector4_0 = {4{1'b0}};
  assign vector9_0 = {9{1'b0}};
  assign vector32_0 = {32{1'b0}};

  //---------------------------------------------------------------------------
  // Keep track of input phase
  //---------------------------------------------------------------------------
  always @(posedge vid_clk)
  begin
    begin
      if (timing_std[27:24] == `C_INTERFACE_SD_270) begin
        vid_sd <= 1'b1;
      end else begin
        vid_sd <= 1'b0;
      end
      if (timing_std[27:24] == `C_INTERFACE_DL_3G) begin
        vid_3gb <= 1'b1;
      end else begin
        vid_3gb <= 1'b0;
      end
    end
  end

  always @(posedge vid_clk)
  begin
    begin
      if (vid_clk_en == 1'b1) begin
        if (vid_reset == 1'b1) begin
          vid_ync <= {2{1'b0}};
        end else begin
          if (vid_tim_en == 1'b1) begin
            if (vid_tim_fvh[1] == 1'b1 || vid_tim_fvh[0] == 1'b1) begin
              vid_ync <= {2{1'b0}};
            end else begin
              vid_ync <= vid_ync + 2'd1;
            end
          end
        end
      end
    end
  end

  //---------------------------------------------------------------------------
  // ROM Read Control
  //---------------------------------------------------------------------------
  always @(posedge vid_clk)
  begin
    begin
      if (vid_clk_en == 1'b1) begin
        if (vid_reset == 1'b1) begin
          len_count <= {6{1'b0}};
        end else begin
          if (vid_tim_en == 1'b1) begin
            if (vid_tim_fvh[0] == 1'b1) begin
              len_count <= {6{1'b0}};
            end else if (read_en == 1'b1) begin
              len_count <= {6{1'b0}};
            end else if ((vid_ync[0] == 1'b1 || (vid_sd == 1'b0 && vid_3gb == 1'b0))) begin
              len_count <= len_count + 6'd1;
            end
          end
        end
      end

    end
  end

  assign read_en = (len_count == rom_len && (vid_ync[0] == 1'b1 || (vid_sd == 1'b0 && vid_3gb == 1'b0))) ? 1'b1 : 1'b0;

  //---------------------------------------------------------------------------
  // Pattern ROM
  //---------------------------------------------------------------------------
  always @(posedge vid_clk)
  begin
    begin
      if (vid_reset == 1'b1) begin
        vid_tim_ync_d1 <= {2{1'b0}};
        vid_tim_trs_d1 <= 1'b0;
        vid_tim_fvh_d1 <= {3{1'b0}};
        vid_tim_pic_d1 <= 1'b0;
        vid_tim_data_d1 <= {20{1'b0}};
        vid_ync_d1 <= {2{1'b0}};
        vid_tim_ync_d2 <= {2{1'b0}};
        vid_tim_trs_d2 <= 1'b0;
        vid_tim_fvh_d2 <= {3{1'b0}};
        vid_tim_pic_d2 <= 1'b0;
        vid_tim_data_d2 <= {20{1'b0}};
        vid_ync_d2 <= {2{1'b0}};
      end else if (vid_clk_en == 1'b1) begin
        if (vid_tim_en == 1'b1) begin
          vid_tim_ync_d1 <= vid_tim_ync;
          vid_tim_trs_d1 <= vid_tim_trs;
          vid_tim_fvh_d1 <= vid_tim_fvh;
          vid_tim_pic_d1 <= vid_tim_pic;
          vid_tim_data_d1 <= vid_tim_data;
          vid_ync_d1 <= vid_ync;

          vid_tim_ync_d2 <= vid_tim_ync_d1;
          vid_tim_trs_d2 <= vid_tim_trs_d1;
          vid_tim_fvh_d2 <= vid_tim_fvh_d1;
          vid_tim_pic_d2 <= vid_tim_pic_d1;
          vid_tim_data_d2 <= vid_tim_data_d1;
          vid_ync_d2 <= vid_ync_d1;
        end
      end
    end
  end

  frb_timing_pattern_ram #(
    .INITP_00                (256'h00000AFFF000000AFFF000000AFFF000000AFFF000000AFFF000000AFFF00000),
    .INITP_01                (256'h0000000000000000000000000000000000000000000000000AFFF000000AFFF0),

    .INITP_02                (256'h0000055550000005555000000555500000055550000005555000000455500000),
    .INITP_03                (256'h0000000000000000000000000000000000000000000000000F55500000055550),

    .INITP_04                (256'h000002BBB0000002BBB0000002BBB0000002BBB0000002BBB0000002BBB00000),
    .INITP_05                (256'h00000000000000000000000000000000000000000000000002BBB0000002BBB0),

    .INITP_06                (256'h00000EFFF000000EFFF000000EFFF000000EFFF000000EFFF000000EFFF00000),
    .INITP_07                (256'h0000000000000000000000000000000000000000000000000EFFF000000EFFF0),

    .INIT_00                 (256'hE00803ACE00803ACE00803AC2008036A20080294200801572008008120080040),
    .INIT_01                 (256'hC408A76D00089F6D0520036D000867710E50038100081B971B9003A7200803AC),
    .INIT_02                 (256'h24F002F20003D6FB19A0031900076F45097003634408A76DC408A76DC408A76D),
    .INIT_03                 (256'h14C002C700011ADD220002ED667102F2E67102F2E67102F2E67102F2000152F2),
    .INIT_04                 (256'h114002964A71A6B3CA71A6B3CA71A6B3CA71A6B300019EB30B9002B3000166B7),
    .INIT_05                 (256'hF59E5D39F59E5D39F59E5D39000DD13933B001390009A555259001B10003A63A),
    .INIT_06                 (256'hD99F00FA000EF8FA1AB000FA000EC0FE23E0010E000E752431200134759E5D39),
    .INIT_07                 (256'h3A80007F000A30882F3000A6000DC8D21F0000F0599F00FAD99F00FAD99F00FA),
    .INIT_08                 (256'h2A5000540007746A3790007A7C075C7FFC075C7FFC075C7FFC075C7F0007AC7F),
    .INIT_09                 (256'h00000000E0080040E0080040E0080040E00800400007F840212000400007C044),
    .INIT_0A                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0B                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0C                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0D                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0E                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_0F                 (256'h0000000000000000000000000000000000000000000000000000000000000000),

    .INIT_10                 (256'h200803AC200803AC200803AC2008036A20080294200801572008008120080040),
    .INIT_11                 (256'h04092B4800091B48052003480008BB4F0E50036700082F8C1B9003A4E00803AC),
    .INIT_12                 (256'h27E002A6000406B21B9002D70007DF1409E0033B04092B4804092B4804092B48),
    .INIT_13                 (256'h17D0026100012E862500029E298102A6298102A6298102A6298102A600015AA6),
    .INIT_14                 (256'h134002360D7226420D7226420D7226420D722642000216420E9002420001B649),
    .INIT_15                 (256'h329DE1AA329DE1AA329DE1AA000D61AA30F001AA000985B524D001DA0003FE11),
    .INIT_16                 (256'h169F0146000EF14617B00146000E954D20E00165000E0D8A2E2001A2329DE1AA),
    .INIT_17                 (256'h3A6000A40009DCB02E2000D7000DB5121C700139169F0146169F0146169F0146),
    .INIT_18                 (256'h2A50005F000704843790009C3C06D8A43C06D8A43C06D8A43C06D8A4000730A4),
    .INIT_19                 (256'h00000000200800402008004020080040A00800400007F0402120004000079047),
    .INIT_1A                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1B                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1C                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1D                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1E                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_1F                 (256'h0000000000000000000000000000000000000000000000000000000000000000),

    .INIT_20                 (256'hE00803ACE00803ACE00803AC2008036A20080294200801572008008120080040),
    .INIT_21                 (256'hC408A76D00089F6D0520036D000867710E50038100081B971B9003A7200803AC),
    .INIT_22                 (256'h24F002F20003D6FB19A0031900076F45097003634408A76DC408A76DC408A76D),
    .INIT_23                 (256'h14C002C700011ADD220002ED667102F2E67102F2E67102F2E67102F2000152F2),
    .INIT_24                 (256'h114002964A71A6B3CA71A6B3CA71A6B3CA71A6B300019EB30B9002B3000166B7),
    .INIT_25                 (256'hF59E5D39F59E5D39F59E5D39000DD13933B001390009A555259001B10003A63A),
    .INIT_26                 (256'hD99F00FA000EF8FA1AB000FA000EC0FE23E0010E000E752431200134759E5D39),
    .INIT_27                 (256'h3A80007F000A30882F3000A6000DC8D21F0000F0599F00FAD99F00FAD99F00FA),
    .INIT_28                 (256'h2A5000540007746A3790007A7C075C7FFC075C7FFC075C7FFC075C7F0007AC7F),
    .INIT_29                 (256'h00000000E0080040E0080040E0080040E00800400007F840212000400007C044),
    .INIT_2A                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2B                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2C                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2D                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2E                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_2F                 (256'h0000000000000000000000000000000000000000000000000000000000000000),

    .INIT_30                 (256'hE00803ACE00803ACE00803AC2008036A20080294200801572008008120080040),
    .INIT_31                 (256'hC408A76D00089F6D0520036D000867710E50038100081B971B9003A7200803AC),
    .INIT_32                 (256'h24F002F20003D6FB19A0031900076F45097003634408A76DC408A76DC408A76D),
    .INIT_33                 (256'h14C002C700011ADD220002ED667102F2E67102F2E67102F2E67102F2000152F2),
    .INIT_34                 (256'h114002964A71A6B3CA71A6B3CA71A6B3CA71A6B300019EB30B9002B3000166B7),
    .INIT_35                 (256'hF59E5D39F59E5D39F59E5D39000DD13933B001390009A555259001B10003A63A),
    .INIT_36                 (256'hD99F00FA000EF8FA1AB000FA000EC0FE23E0010E000E752431200134759E5D39),
    .INIT_37                 (256'h3A80007F000A30882F3000A6000DC8D21F0000F0599F00FAD99F00FAD99F00FA),
    .INIT_38                 (256'h2A5000540007746A3790007A7C075C7FFC075C7FFC075C7FFC075C7F0007AC7F),
    .INIT_39                 (256'h00000000E0080040E0080040E0080040E00800400007F840212000400007C044),
    .INIT_3A                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3B                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3C                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3D                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3E                 (256'h0000000000000000000000000000000000000000000000000000000000000000),
    .INIT_3F                 (256'h0000000000000000000000000000000000000000000000000000000000000000))
  u_ram(
    .CLK                     (vid_clk),
    .SSR                     (vid_reset),
    .ADDRA                   (read_addr_ram),
    .EN                      (ram_rd),
    .WEA                     (logic0),
    .DIA                     (vector32_0),
    .DIPA                    (vector4_0),
    .DOA                     (read_data_ram),
    .DOPA                    (read_flag_ram),

    .ADDRB                   (vector9_0),
    .DOB                     (),
    .DOPB                    ());

  assign read_addr_ram = {read_bank , read_addr};

  always @(posedge vid_clk)
  begin
    begin
      if (timing_std[27:24] == `C_INTERFACE_SD_270) begin
        // 720 Width
        read_bank <= 2'b01;
      end else if (timing_std[27:24] == `C_INTERFACE_720_1G5 || timing_std[27:24] == `C_INTERFACE_720_3G) begin
        // 1280 Width
        read_bank <= 2'b10;
      end else if ((timing_std[27:24] == `C_INTERFACE_IPT && timing_std[19] == 1'b0)) begin
        // 2048 Width
        read_bank <= 2'b11;
      end else begin
        // 1920 Width
        read_bank <= 2'b00;
      end
    end
  end

  // Due to RAM Rd-Latency, we have an output pipeline stage so ensure RAM-Data is always available.
  always @(posedge vid_clk)
  begin
    begin
      // Prefetch pipeline...
      if (vid_tim_fvh[0] == 1'b1 && vid_tim_en == 1'b1 && vid_tim_fvh_d1[0] == 1'b0) begin
        pipe <= 3'b000;
        pipe_rd <= 1'b0;
      end else if (pipe != 3'b111) begin
        pipe_rd <= 1'b1;
        pipe <= {pipe[1:0] , 1'b1};
      end else begin
        pipe_rd <= 1'b0;
      end
      if (vid_tim_fvh[0] == 1'b1 && vid_tim_en == 1'b1 && vid_tim_fvh_d1[0] == 1'b0) begin
        read_addr <= {7{1'b0}};
      end else if (ram_rd == 1'b1) begin
        read_addr <= read_addr + 7'd1;
      end
    end
  end
  assign ram_rd = pipe_rd | (read_en & vid_tim_en & ~ vid_tim_fvh_d1[0]);

  always @(posedge vid_clk)
  begin
    begin
      if (vid_reset == 1'b1) begin
        read_data_p0 <= {36{1'b0}};
        read_data_p1 <= {36{1'b0}};
        rom_len <= {6{1'b0}};
        rom_cb <= {10{1'b0}};
        rom_cr <= {10{1'b0}};
        rom_y <= {10{1'b0}};
      end else if (ram_rd == 1'b1) begin
        read_data_p0 <= {read_flag_ram , read_data_ram};
        read_data_p1 <= read_data_p0;
        rom_len <= read_data_p1[35:30];
        rom_cb <= read_data_p1[29:20];
        rom_cr <= read_data_p1[19:10];
        rom_y <= read_data_p1[9:0];
      end
    end
  end

  //---------------------------------------------------------------------------
  // Register Output
  //---------------------------------------------------------------------------
  always @(posedge vid_clk)
  begin
    begin
      if (vid_reset == 1'b1) begin
        vid_pat_en <= 1'b0;
        vid_pat_ync <= {2{1'b0}};
        vid_pat_trs <= 1'b0;
        vid_pat_fvh <= {3{1'b0}};
        vid_pat_pic <= 1'b0;
        vid_pat_data <= {20{1'b0}};
      end else if (vid_clk_en == 1'b1) begin
        vid_pat_en <= vid_tim_en;
        if (vid_tim_en == 1'b1) begin
          vid_pat_ync <= vid_tim_ync_d2;
          vid_pat_trs <= vid_tim_trs_d2;
          vid_pat_fvh <= vid_tim_fvh_d2;
          vid_pat_pic <= vid_tim_pic_d2;
          if (vid_tim_fvh_d2[1] == 1'b0 && vid_tim_fvh_d2[0] == 1'b0) begin
            if (vid_sd == 1'b1) begin
              if (vid_ync_d2 == 2'b00) begin
                vid_pat_data <= {10'b0000000000 , rom_cb};
              end else if (vid_ync_d2 == 2'b10) begin
                vid_pat_data <= {10'b0000000000 , rom_cr};
              end else begin
                vid_pat_data <= {10'b0000000000 , rom_y};
              end
            end else if (vid_3gb == 1'b1) begin
              if (vid_ync_d2 == 2'b00) begin
                vid_pat_data <= {rom_cb , rom_cb};
              end else if (vid_ync_d2 == 2'b10) begin
                vid_pat_data <= {rom_cr , rom_cr};
              end else begin
                vid_pat_data <= {rom_y , rom_y};
              end
            end else begin
              if (vid_ync_d2[0] == 1'b0) begin
                vid_pat_data <= {rom_y , rom_cb};
              end else if (vid_ync_d2[0] == 1'b1) begin
                vid_pat_data <= {rom_y , rom_cr};
              end
            end
          end else begin
            vid_pat_data <= vid_tim_data_d2;
          end
        end
      end
    end
  end

endmodule
