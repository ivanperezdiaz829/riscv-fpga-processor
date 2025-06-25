NUMBER OF ADDRESS BITS: 6

`if HALF_RATE
CLASS cs 2
DEFINE cs cs_read 01
DEFINE cs cs_write 10
DEFINE cs cs_off 11
`else
CLASS cs 1
DEFINE cs cs_read 0
DEFINE cs cs_write 0
DEFINE cs cs_off 1
`endif

CLASS cmd 3 # wps#, rps#, doff#
DEFINE cmd cmd_doff 110
DEFINE cmd cmd_nop 111
DEFINE cmd cmd_read 101
DEFINE cmd cmd_write 011

CLASS add 1 MEM_ADDR_WIDTH 0
DEFINE add add_0 0
DEFINE add add_1 1

CLASS rdata_en 1
DEFINE rdata_en rdata_en_0 0
DEFINE rdata_en rdata_en_1 1

CLASS wdata_valid 1
DEFINE wdata_valid wdata_valid_0 0
DEFINE wdata_valid wdata_valid_1 1

TEMPLATE cs.cmd.add.wdata_valid.rdata_en

# Generic commands
LABEL ac_nop cs_off | cmd_nop | add_0 | wdata_valid_0 | rdata_en_0
LABEL ac_doff cs_off | cmd_doff | add_0 | wdata_valid_0 | rdata_en_0

# Write Commands
LABEL ac_write_addr_0 cs_write | cmd_write | add_0 | wdata_valid_1 | rdata_en_0
LABEL ac_write_addr_1 cs_write | cmd_write | add_1 | wdata_valid_1 | rdata_en_0
LABEL ac_write_0 cs_write | cmd_write | add_0 | wdata_valid_1 | rdata_en_0
LABEL ac_write_1 cs_write | cmd_write | add_1 | wdata_valid_1 | rdata_en_0
LABEL ac_write_data cs_off | cmd_nop | add_0 | wdata_valid_1 | rdata_en_0

# Read Commands
LABEL ac_read_0 cs_read | cmd_read | add_0 | wdata_valid_0 | rdata_en_1
LABEL ac_read_1 cs_read | cmd_read | add_0 | wdata_valid_0 | rdata_en_1
LABEL ac_read_addr_0 cs_read | cmd_read | add_0 | wdata_valid_0 | rdata_en_1
LABEL ac_read_addr_1 cs_read | cmd_read | add_1 | wdata_valid_0 | rdata_en_1
LABEL ac_read_data cs_off | cmd_nop | add_0 | wdata_valid_0 | rdata_en_1
