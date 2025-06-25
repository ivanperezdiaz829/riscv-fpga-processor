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

module pof_avalon_mm_mmr_driver
(
	clk,
	reset_n,
	mmr_waitrequest,
	mmr_read_req,
	mmr_write_req,
	mmr_addr,
	mmr_be,
	mmr_wdata,
	mmr_rdata_valid,
	mmr_rdata,
	unique_ready,
	coordinator_ready,
	unique_done,
	unique_ready_1,
	coordinator_ready_1,
	unique_done_1,
    local_init_done,
    local_cal_success,
    local_cal_fail,
    pass,
    fail,
    test_complete
);

parameter MMRD_AVL_DATA_WIDTH = 32;
parameter MMRD_AVL_ADDR_WIDTH = 16;
parameter MMRD_AVL_BE_WIDTH = 4;
parameter MMRD_NUMBER_OF_STAGES = 2;

input wire                                  clk;
input wire                                  reset_n;

input wire                                  mmr_waitrequest;
output reg                                  mmr_write_req= 0;
output reg                                  mmr_read_req= 0;
output reg  [MMRD_AVL_ADDR_WIDTH - 1 : 0]   mmr_addr = 0;
output reg  [MMRD_AVL_BE_WIDTH - 1 : 0 ]    mmr_be = 0;
output reg  [MMRD_AVL_DATA_WIDTH - 1 : 0]   mmr_wdata = 0;
input wire  [MMRD_AVL_DATA_WIDTH - 1 : 0]   mmr_rdata;
input wire                                  mmr_rdata_valid;

output wire                                 unique_ready;
input wire                                  coordinator_ready;
output wire                                 unique_done;

output wire                                 unique_ready_1;
input wire                                  coordinator_ready_1;
output wire                                 unique_done_1;

input wire                                  local_init_done;
input wire                                  local_cal_success;
input wire                                  local_cal_fail;

output wire                                 pass;
output wire                                 fail;
output wire                                 test_complete;

reg                                         reset_n_reg;
reg         [MMRD_AVL_DATA_WIDTH - 1 : 0]   stored_rdata;
reg         [6          - 1 : 0]            stage_fail;
reg         [2          - 1 : 0]            burst_size;

logic                                       int_ready;

typedef enum int unsigned {
    VERIFY_ECC_DISABLE,
    VERIFY_ECC_ENABLE,
    VERIFY_RMW_DISABLE,
    VERIFY_RMW_ENABLE,
    VERIFY_SBE_COUNT,
    VERIFY_DBE_COUNT,
    ENABLE_ECC,
    ENABLE_RMW,
    DONE
} stage_type_t;

typedef enum int unsigned {
    IDLE,
	READ,
    READ_DATA,
    WRITE
} operation_type_t;

stage_type_t stage_type;
operation_type_t operation_type;

assign unique_ready = ~mmr_waitrequest;
assign unique_done = ((operation_type == IDLE) && (stage_type == VERIFY_SBE_COUNT)) ? 1'b1 : 1'b0;
assign unique_ready_1 = ~mmr_waitrequest;
assign unique_done_1 = ((operation_type == IDLE) && (stage_type == DONE)) ? 1'b1 : 1'b0;

always_comb
begin
    case(stage_type)
        VERIFY_ECC_DISABLE: int_ready <= coordinator_ready;
        VERIFY_ECC_ENABLE: int_ready <= coordinator_ready;
        VERIFY_RMW_DISABLE: int_ready <= coordinator_ready_1;
        VERIFY_RMW_ENABLE: int_ready <= coordinator_ready_1;
        VERIFY_SBE_COUNT: int_ready <= coordinator_ready_1;
        VERIFY_DBE_COUNT: int_ready <= coordinator_ready_1;
        ENABLE_ECC: int_ready <= coordinator_ready;
        ENABLE_RMW: int_ready <= coordinator_ready_1;
        default: int_ready <= coordinator_ready;
    endcase
end

always_ff @(posedge clk or negedge reset_n)			
begin
    if (!reset_n)
    begin
        reset_n_reg <= 0;
    end
    else
    begin
        reset_n_reg <= reset_n;
    end
end

always_ff @(posedge clk or negedge reset_n_reg)
begin
    if (!reset_n_reg)
    begin
        mmr_write_req <= 1'b0;
        mmr_read_req <= 1'b0;
        mmr_addr <= {MMRD_AVL_ADDR_WIDTH{1'b0}};
        mmr_be <= {MMRD_AVL_BE_WIDTH{1'b0}};
        mmr_wdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};

        burst_size <= 2'b00;
        operation_type <= IDLE;
        stage_type <= VERIFY_ECC_DISABLE;
        stored_rdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};
        stage_fail <= 6'b0000;

    end
    else
    begin

        case (operation_type)
            IDLE:
            begin
                mmr_write_req <= 1'b0;
                mmr_read_req <= 1'b0;
                mmr_addr <= {MMRD_AVL_ADDR_WIDTH{1'b0}};
                mmr_be <= {MMRD_AVL_BE_WIDTH{1'b0}};
                mmr_wdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};

                burst_size <= 2'b00;
                case (stage_type)
                    DONE:
                    begin
                        operation_type <= IDLE;
                        stage_type <= stage_type;
                        stored_rdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};
                    end

                    default:
                    begin
                        if (local_init_done == 1'b1)
                            operation_type <= READ;
                        else
                            operation_type <= IDLE;
                        stage_type <= stage_type;
                        stored_rdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};
                    end
                endcase
                stage_fail <= stage_fail;
            end

	        READ:
            begin
                if ((int_ready == 1'b1) || (burst_size > 0)) 
                begin
                    mmr_write_req <= 1'b0;
                    mmr_read_req <= 1'b1;

                    case (stage_type)
                        VERIFY_ECC_DISABLE:
                        begin
                            mmr_addr <= {{MMRD_AVL_ADDR_WIDTH-8-1{1'b0}},1'b1,8'b01000000};
                            mmr_be <= {{MMRD_AVL_BE_WIDTH-2{1'b0}},2'b10};
                        end

                        VERIFY_ECC_ENABLE:
                        begin
                            mmr_addr <= {{MMRD_AVL_ADDR_WIDTH-8-1{1'b0}},1'b1,8'b01000000};
                            mmr_be <= {{MMRD_AVL_BE_WIDTH-2{1'b0}},2'b10};
                        end

                        VERIFY_RMW_DISABLE:
                        begin
                            mmr_addr <= {{MMRD_AVL_ADDR_WIDTH-8-1{1'b0}},1'b1,8'b01000000};
                            mmr_be <= {{MMRD_AVL_BE_WIDTH-2{1'b0}},2'b10};
                        end

                        VERIFY_RMW_ENABLE:
                        begin
                            mmr_addr <= {{MMRD_AVL_ADDR_WIDTH-8-1{1'b0}},1'b1,8'b01000000};
                            mmr_be <= {{MMRD_AVL_BE_WIDTH-2{1'b0}},2'b10};
                        end

                        VERIFY_SBE_COUNT:
                        begin
                            mmr_addr <= {{MMRD_AVL_ADDR_WIDTH-8-1{1'b0}},1'b1,8'b01001001};
                            mmr_be <= {{MMRD_AVL_BE_WIDTH-2{1'b0}},2'b01};
                        end

                        VERIFY_DBE_COUNT:
                        begin
                            mmr_addr <= {{MMRD_AVL_ADDR_WIDTH-8-1{1'b0}},1'b1,8'b01001010};
                            mmr_be <= {{MMRD_AVL_BE_WIDTH-2{1'b0}},2'b01};
                        end
                    endcase

                    mmr_wdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};

                    burst_size <= burst_size + 1'b1;
                end
                else
                begin
                    mmr_write_req <= 1'b0;
                    mmr_read_req <= 1'b0;
                    mmr_addr <= {MMRD_AVL_ADDR_WIDTH{1'b0}};
                    mmr_be <= {MMRD_AVL_BE_WIDTH{1'b0}};
                    mmr_wdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};

                    burst_size <= 2'b00;
                end

                if (burst_size == 3)
                    operation_type <= READ_DATA;
                else
                    operation_type <= READ;
                stage_type <= stage_type;
                stored_rdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};
                stage_fail <= stage_fail;

            end

	        READ_DATA:
            begin
                mmr_write_req <= 1'b0;
                mmr_read_req <= 1'b0;
                mmr_addr <= {MMRD_AVL_ADDR_WIDTH{1'b0}};
                mmr_be <= {MMRD_AVL_BE_WIDTH{1'b0}};
                mmr_wdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};

                burst_size <= 2'b00;
                if (mmr_rdata_valid == 1'b1)
                begin
                    case (stage_type)
                        VERIFY_ECC_DISABLE:
                        begin
                            operation_type <= WRITE;
                            stage_type <= ENABLE_ECC;
                            stored_rdata <= mmr_rdata;
                            if (mmr_rdata[11:10] == 2'b00)
                                stage_fail <= stage_fail;
                            else
                                stage_fail <= {stage_fail[5:1],1'b1};
                        end

                        VERIFY_ECC_ENABLE:
                        begin

                            operation_type <= IDLE;
                            stage_type <= VERIFY_SBE_COUNT;
                            stored_rdata <= stored_rdata;
                            if (mmr_rdata[11:10] == 2'b01)
                                stage_fail <= stage_fail;
                            else
                                stage_fail <= {stage_fail[5:2],1'b1,stage_fail[0]};
                        end

                        VERIFY_RMW_DISABLE:
                        begin
                            operation_type <= WRITE;
                            stored_rdata <= mmr_rdata;
                            stage_type <= ENABLE_RMW;
                            if (mmr_rdata[11:10] == 2'b01)
                                stage_fail <= stage_fail;
                            else
                                stage_fail <= {stage_fail[5:3],1'b1,stage_fail[1:0]};
                        end
    
                        VERIFY_RMW_ENABLE:
                        begin
                            operation_type <= IDLE;
                            stage_type <= DONE;
                            stored_rdata <= stored_rdata;
                            if (mmr_rdata[11:10] == 2'b11)
                                stage_fail <= stage_fail;
                            else
                                stage_fail <= {stage_fail[5:4],1'b1,stage_fail[2:0]};
                        end

                        VERIFY_SBE_COUNT:
                        begin
                            operation_type <= READ;
                            stage_type <= VERIFY_DBE_COUNT;
                            stored_rdata <= stored_rdata;
                            if (mmr_rdata[7:0] == 8'd24)
                                stage_fail <= stage_fail;
                            else
                                stage_fail <= {stage_fail[5],1'b1,stage_fail[3:0]};
                        end

                        VERIFY_DBE_COUNT:
                        begin
                            operation_type <= READ;
                            stage_type <= VERIFY_RMW_DISABLE;
                            stored_rdata <= stored_rdata;
                            if (mmr_rdata[7:0] == 8'd1)
                                stage_fail <= stage_fail;
                            else
                                stage_fail <= {1'b1,stage_fail[4:0]};
                        end

                    endcase

                end
                else
                begin
                    operation_type <= READ_DATA;
                    stage_type <= stage_type;
                    stored_rdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};
                    stage_fail <= stage_fail;
                end
            end

            WRITE:
            begin
                if ((int_ready == 1'b1) || (burst_size > 0))
                begin
                    mmr_write_req <= 1'b1;
                    mmr_read_req <= 1'b0;
                    mmr_addr <= {{MMRD_AVL_ADDR_WIDTH-8-1{1'b0}},1'b1,8'b01000000};
                    mmr_be <= {{MMRD_AVL_BE_WIDTH-2{1'b0}},2'b10};

                    case (stage_type)
                        ENABLE_ECC: mmr_wdata <= {stored_rdata[MMRD_AVL_DATA_WIDTH-1:12],2'b01,stored_rdata[9:0]};
                        ENABLE_RMW: mmr_wdata <= {stored_rdata[MMRD_AVL_DATA_WIDTH-1:12],3'b11,stored_rdata[9:0]};
                        default:  mmr_wdata <= stored_rdata;
                    endcase

                    burst_size <= burst_size + 1'b1;
                end
                else
                begin
                    mmr_write_req <= 1'b0;
                    mmr_read_req <= 1'b0;
                    mmr_addr <= {MMRD_AVL_ADDR_WIDTH{1'b0}};
                    mmr_be <= {MMRD_AVL_BE_WIDTH{1'b0}};
                    mmr_wdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};

                    burst_size <= 2'b00;
                end

                if (burst_size == 3)
                begin
                    operation_type <= READ;

                    case (stage_type)
                        ENABLE_ECC: stage_type <= VERIFY_ECC_ENABLE;
                        ENABLE_RMW: stage_type <= VERIFY_RMW_ENABLE;
                        default: stage_type <= stage_type;
                    endcase

                    stored_rdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};
                end
                else
                begin
                    operation_type <= WRITE;
                    stage_type <= stage_type;
                    stored_rdata <= stored_rdata;
                end

                stage_fail <= stage_fail;

            end

            default:
            begin
                mmr_write_req <= 1'b0;
                mmr_read_req <= 1'b0;
                mmr_addr <= {MMRD_AVL_ADDR_WIDTH{1'b0}};
                mmr_be <= {MMRD_AVL_BE_WIDTH{1'b0}};
                mmr_wdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};

                burst_size <= 2'b00;
                operation_type <= IDLE;
                stage_type <= VERIFY_ECC_DISABLE;
                stored_rdata <= {MMRD_AVL_DATA_WIDTH{1'b0}};
                stage_fail <= stage_fail;
            end
        endcase
    end
end

endmodule
