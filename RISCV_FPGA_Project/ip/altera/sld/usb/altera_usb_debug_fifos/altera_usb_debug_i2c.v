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



//`define DEBUG_I2C   1

module altera_usb_debug_i2c #(
    parameter DEVICE_FAMILY  = "StratixIII",
    parameter I2CADDR        = 8'h6e
)(
    inout  tri         scl,
    inout  tri         sda,

    input  wire        clk,
    input  wire        arst,
    input  wire        waitrequest,
    output reg   [7:0] address,
    output reg         write,
    output reg   [7:0] writedata,
    output reg         read,
    input  wire  [7:0] readdata,
    input  wire        readvalid
);

//----------------------------------------------------------------------------
wire scl_in;
reg  scl_in_1/* synthesis ALTERA_ATTRIBUTE = "{-to \"*\"} CUT=ON; -name REMOVE_DUPLICATE_REGISTERS OFF" */;
reg  scl_in_2/* synthesis                                         -name REMOVE_DUPLICATE_REGISTERS OFF" */;
wire sda_in;
reg  sda_in_1/* synthesis ALTERA_ATTRIBUTE = "{-to \"*\"} CUT=ON; -name REMOVE_DUPLICATE_REGISTERS OFF" */;
reg  sda_in_2/* synthesis                                         -name REMOVE_DUPLICATE_REGISTERS OFF" */;
reg  sda_in_3;

wire scl_out = 1'b1;
reg  sda_out;

assign scl_in = scl;
assign scl    = (scl_out) ? 1'bz : 1'b0;
assign sda_in = sda;
assign sda    = (sda_out) ? 1'bz : 1'b0;

always @(posedge clk or posedge arst) begin
    if (arst) begin
        scl_in_1 <= 1'b1;
        scl_in_2 <= 1'b1;
        sda_in_1 <= 1'b1;
        sda_in_2 <= 1'b1;
        sda_in_3 <= 1'b1;
    end
    else begin
        scl_in_1 <= scl_in;         //cut this path
        scl_in_2 <= scl_in_1;
        sda_in_1 <= sda_in;
        sda_in_2 <= sda_in_1;
        sda_in_3 <= sda_in_2;
    end
end
//----------------------------------------------------------------------------

`ifdef DEBUG_I2C
//synthesis translate_off
reg   [7:0] address_1;
//synthesis translate_on
`endif

reg [3:0] count;
reg [4:0] state;
reg [7:0] i2caddr;
reg [7:0] rdata;
reg       write_pending;
reg       read_pending;

always @(posedge clk or posedge arst) begin
    if (arst) begin
        sda_out <= 1'b1;
        i2caddr <= 8'h0;
        address <= 8'h0;
`ifdef DEBUG_I2C
//synthesis translate_off
        address_1 <= 8'h0;
//synthesis translate_on
`endif
        write <= 1'b0;
        writedata <= 8'h0;
        read <= 1'b0;
        write_pending <= 1'b0;
        read_pending <= 1'b0;
        rdata <= 8'h0;
        count <= 4'h0;
        state <= 5'h0;
    end
    else begin
        write <= 1'b0;
        read <= 1'b0;

        if (write & waitrequest) begin
            write <= 1'b1;
        end
        else begin
            write_pending <= 1'b0;
        end
        if (read & waitrequest) begin
            read <= 1'b1;
        end

        //auto increment address
        if ((write | read) & ~waitrequest) begin
`ifdef DEBUG_I2C
//synthesis translate_off
            address_1 <= address;
//synthesis translate_on
`endif
            address <= address + 8'h1;
        end

        if (readvalid) begin
`ifdef DEBUG_I2C
//synthesis translate_off
$display("%t: reading regno=%x, readdata=%x", $time, address_1, readdata);
//synthesis translate_on
`endif
            rdata <= readdata;
        end
        if (read_pending & readvalid) begin
            read_pending <= 1'b0;
        end

        case (state)
        5'h0: begin
            //wait for scl, sda high
            if (scl_in_2 & sda_in_2) begin
                state <= 5'h1;
            end
        end
        5'h1: begin
            //start, stop detection is now in all states
        end

        //address phase
        5'h2: begin //scl low, sda can change now
            if (scl_in_2) begin
                //sample sda
                i2caddr <= {i2caddr[0+:7], sda_in_2};
                count <= count + 4'h1;
                state <= 5'h3;
            end
        end
        5'h3: begin //scl high
            if (~scl_in_2) begin
                state <= 5'h2;
                if (count == 4'h8) begin
`ifdef DEBUG_I2C
//synthesis translate_off
                    $display("%t: i2caddr = %x", $time, i2caddr);
//synthesis translate_on
`endif
                    if (i2caddr[1+:7] == I2CADDR[1+:7]) begin
                        sda_out <= 1'b0;
                        count <= 4'h0;
                        state <= 5'h4;
                    end
                    else begin
                        state <= 5'h0;
                    end
                end
            end
            //start, stop detection is now in all states
        end
        5'h4: begin //ack, scl low
            sda_out <= 1'b0;
            if (scl_in_2) begin
                //is this a read?
                if (i2caddr[0]) begin
                    read <= 1'b1;
                    read_pending <= 1'b1;
                end
                state <= 5'h5;
            end
        end
        5'h5: begin //ack, scl high
            if (read_pending) begin
            end
            else begin
                sda_out <= 1'b0;
                if (~scl_in_2) begin
                    sda_out <= 1'b1;
                    //is this a read?
                    if (i2caddr[0]) begin
                        sda_out <= rdata[7];
                        rdata <= {rdata[0+:7], 1'b1};
                        state <= 5'he;
                    end
                    else begin
                        state <= 5'h6;
                    end
                end
            end
        end


        //write regno phase
        5'h6: begin //scl low, sda can change now
            if (scl_in_2) begin
                //sample sda
                address <= {address[0+:7], sda_in_2};
                count <= count + 4'h1;
                state <= 5'h7;
            end
        end
        5'h7: begin //scl high
            if (~scl_in_2) begin
                state <= 5'h6;
                if (count == 4'h8) begin
`ifdef DEBUG_I2C
//synthesis translate_off
                    $display("%t: regno = %x", $time, address);
//synthesis translate_on
`endif
                    sda_out <= 1'b0;
                    count <= 4'h0;
                    state <= 5'h8;
                end
            end
            //start, stop detection is now in all states
        end
        5'h8: begin //ack, scl low
            sda_out <= 1'b0;
            if (scl_in_2) begin
                state <= 5'h9;
            end
        end
        5'h9: begin //ack, scl high
            sda_out <= 1'b0;
            if (~scl_in_2) begin
                sda_out <= 1'b1;
                state <= 5'ha;
            end
        end


        //write data phase
        5'ha: begin //scl low, sda can change now
            if (scl_in_2) begin
                //sample sda
                writedata <= {writedata[0+:7], sda_in_2};
                count <= count + 4'h1;
                state <= 5'hb;
            end
        end
        5'hb: begin //scl high
            if (~scl_in_2) begin
                state <= 5'ha;
                if (count == 4'h8) begin
`ifdef DEBUG_I2C
//synthesis translate_off
$display("%t: writing regno=%x, wdata=%x", $time, address, writedata);
//synthesis translate_on
`endif
                    write <= 1'b1;
                    write_pending <= 1'b1;
                    sda_out <= 1'b0;
                    count <= 4'h0;
                    state <= 5'hc;
                end
            end
            //start, stop detection is now in all states
        end
        5'hc: begin //ack, scl low
            if (write_pending) begin
            end
            else begin
                sda_out <= 1'b0;
                if (scl_in_2) begin
                    state <= 5'hd;
                end
            end
        end
        5'hd: begin //ack, scl high
            sda_out <= 1'b0;
            if (~scl_in_2) begin
                sda_out <= 1'b1;
                state <= 5'ha;
            end
        end


        //read data phase
        5'he: begin //scl low, sda can change now
            if (scl_in_2) begin
                count <= count + 4'h1;
                state <= 5'hf;
            end
        end
        5'hf: begin //scl high
            if (~scl_in_2) begin
                sda_out <= rdata[7];
                rdata <= {rdata[0+:7], 1'b1};
                state <= 5'he;
                if (count == 4'h8) begin
                    sda_out <= 1'b1;
                    count <= 4'h0;
                    state <= 5'h10;
                end
            end
            //start, stop detection is now in all states
        end
        5'h10: begin //ack, scl low
            if (scl_in_2) begin
`ifdef DEBUG_I2C
//synthesis translate_off
                $display("%t: master ack=%x", $time, sda_in_2);
//synthesis translate_on
`endif
                if (sda_in_2) begin
                    state <= 5'h12;
                end
                else begin
                    read <= 1'b1;
                    read_pending <= 1'b1;
                    state <= 5'h11;
                end
            end
        end
        5'h11: begin //ack, scl high
            if (read_pending) begin
            end
            else begin
                if (~scl_in_2) begin
                    sda_out <= rdata[7];
                    rdata <= {rdata[0+:7], 1'b1};
                    state <= 5'he;
                end
            end
        end
        5'h12: begin //ack, scl high
            if (~scl_in_2) begin
                sda_out <= 1'b1;
                state <= 5'h0;
            end
        end
        endcase


        //
        // do the start stop detection from all states
        //

        //start: scl high, sda falling
        if (scl_in_2 & ~sda_in_2 & sda_in_3) begin
`ifdef DEBUG_I2C
//synthesis translate_off
            $display("%t: start bit", $time);
//synthesis translate_on
`endif
            count <= 4'h0;
            read_pending <= 1'b0;
            write_pending <= 1'b0;
            sda_out <= 1'b1;
            state <= 5'h3;
        end

        //stop: scl high, sda rising
        if (scl_in_2 & sda_in_2 & ~sda_in_3 & ~sda_out) begin
`ifdef DEBUG_I2C
//synthesis translate_off
            $display("%t: stop bit", $time);
//synthesis translate_on
`endif
            read_pending <= 1'b0;
            write_pending <= 1'b0;
            sda_out <= 1'b1;
            state <= 5'h1;
        end

    end
end

endmodule
