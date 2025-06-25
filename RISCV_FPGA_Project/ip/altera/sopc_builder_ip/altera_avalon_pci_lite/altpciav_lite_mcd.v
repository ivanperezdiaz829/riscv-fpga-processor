module altpciav_lite_mcd
#(
    parameter CG_PCI_DATA_WIDTH = 32 
)

(
  input                                 PciClk_i,
  input                                 Rstn_i,
  input [17:0]                          rwinfo_header_i,
  input [CG_PCI_DATA_WIDTH-1:0]         avl_addr_header_i,
  input [(CG_PCI_DATA_WIDTH/8)-1 : 0]   ben_header_i,
  input [CG_PCI_DATA_WIDTH-1:0]         wr_data_i,
  input                                 cdreg_wr_i,
  input                                 cdreg_rd_i,
  input                                 rddata_ready_i,
  input [CG_PCI_DATA_WIDTH-1:0]         rd_data_i,
  
  output [17:0]                         rwinfo_reg_o,
  output [CG_PCI_DATA_WIDTH-1:0]        avl_addr_reg_o,
  output [(CG_PCI_DATA_WIDTH/8)-1 : 0]  ben_reg_o,
  output [CG_PCI_DATA_WIDTH-1:0]        wr_data_reg_o,
  output [CG_PCI_DATA_WIDTH-1:0]        rd_data_reg_o

);


//reg
  reg [17:0]                         rwinfo_reg;
  reg [CG_PCI_DATA_WIDTH-1:0]        avl_addr_reg;
  reg [(CG_PCI_DATA_WIDTH/8)-1 : 0]  ben_reg;
  reg [CG_PCI_DATA_WIDTH-1:0]        wr_data_reg;
  reg [CG_PCI_DATA_WIDTH-1:0]        rd_data_reg;

//control group register
always @ (posedge PciClk_i or negedge Rstn_i)
begin 
  if (~Rstn_i)
      rwinfo_reg <= 18'b0;
  else if (cdreg_wr_i)  
      rwinfo_reg <= rwinfo_header_i;
  else
      rwinfo_reg <= rwinfo_reg;
end

//avl addr reg
always @ (posedge PciClk_i or negedge Rstn_i)
begin 
  if (~Rstn_i)
      avl_addr_reg <= 0;
  else if (cdreg_wr_i)  
      avl_addr_reg <= avl_addr_header_i;
  else
      avl_addr_reg <= avl_addr_reg;
end

//ben header
always @ (posedge PciClk_i or negedge Rstn_i)
begin 
  if (~Rstn_i)
      ben_reg <= 0;
  else if (cdreg_wr_i)  
      ben_reg <= ben_header_i;
  else
      ben_reg <= ben_reg;
end

//write data register
//1, need to add control - latch data only during write transacation
always @ (posedge PciClk_i or negedge Rstn_i)
begin
  if(~Rstn_i)
    wr_data_reg<= 0;
  else if (cdreg_wr_i)  
    wr_data_reg <= wr_data_i;
  else
    wr_data_reg <= wr_data_reg;
end

//read data register
always @ (posedge PciClk_i or negedge Rstn_i)
begin
  if(~Rstn_i)
    rd_data_reg<= 0;
  else if (rddata_ready_i)  
    rd_data_reg <= rd_data_i;
  else
    rd_data_reg <= rd_data_reg;
end


//1. calculating size eg: addr, ben
assign rwinfo_reg_o = rwinfo_reg;
assign avl_addr_reg_o = avl_addr_reg;
assign ben_reg_o = ben_reg;
assign wr_data_reg_o = wr_data_reg;
assign rd_data_reg_o = rd_data_reg;


endmodule
