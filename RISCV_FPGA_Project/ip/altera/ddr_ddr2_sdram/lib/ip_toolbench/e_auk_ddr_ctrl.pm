# For all those of you out there who bag on europa and its "Winchester
# Mystery House Architecture" I present the Smith and Wesson solution.

# e_lpm_base: A new class which helps insert lpm_instances into your
# europa code.  Don't muck around in here.  The only reason why I bring
# it up is so that you can set @ISA = qw (e_lpm_base) in your coolio new
# europa class.

# e_lpm_dcfifo: An example class which uses e_lpm_base.  Check it out.

# e_lpm_base parses the vhdl component declaration (Which I copied
# directly from Quartus LPM Megafunction Documentation) and uses its
# info to figure out width_matches based upon parameter map
# declarations. E.g. In the dcfifo example, e_lpm_base notes that both d
# and q are of width (LPM_WIDTH).  When somebody later on defines a
# signal q of width 24, e_lpm_width automatically propogates the width
# to the "d" pin (unless d has also been defined.  See: standard europa
# signal matching.  e_lpm_base is also smart enough to set the component
# LPM_WIDTH value before outputing as HDL.

# Another cool advantage here is that different tools sometime have
# different ideas about which default settings are actually the default
# settings.  By copying the component directly, europa directly
# specifies ALL component settings.  The tools no longer have any say
# about defaults since europa specifies them directly.


=head1 NAME

e_lpm_dcfifo - description of the module goes here ...

=head1 SYNOPSIS

The e_lpm_dcfifo class implements ... detailed description of functionality

=head1 METHODS

=over 4

=cut

package e_auk_ddr_ctrl;
use e_lpm_base;
@ISA = ("e_lpm_base");

use strict;
use europa_utils;

#You must declare your vhdl component declaration for this class to
#work
################################################################################

=item I<vhdl_declare_component()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub vhdl_declare_component
{
    return q[
        component auk_ddr_controller
            generic
            (
            gREG_DIMM               : string;        
            gLOCAL_DATA_BITS        : integer := 16;            
            gLOCAL_BURST_LEN        : integer := 4;             
            gLOCAL_BURST_LEN_BITS   : integer := 3;             
            gLOCAL_AVALON_IF        : string  := "false";
            gMEM_TYPE               : string  := "ddr_sdram";   
            gMEM_CHIPSELS           : integer := 2;             
            gMEM_CHIP_BITS          : integer := 1;             
            gMEM_ROW_BITS           : integer := 12;            
            gMEM_BANK_BITS          : integer := 2;             
            gMEM_COL_BITS           : integer := 10;            
            gMEM_DQ_PER_DQS         : integer := 8;             
            gMEM_PCH_BIT            : integer := 10;            
            gMEM_ODT_RANKS          : integer := 0;
            gPIPELINE_COMMANDS      : string  := "true";         
            gEXTRA_PIPELINE_REGS    : string  := "false";        
            gADDR_CMD_NEGEDGE       : string  := "false";        
            gFAMILY                 : string  := "Stratix";      
            gRESYNCH_CYCLE          : integer := 0;              
            gINTER_RESYNCH          : string  := "false";        
            gUSER_REFRESH           : string  := "false";        
            gPIPELINE_READDATA      : string  := "true";         
            gSTRATIX_DLL_CONTROL    : string  := "true"          
            );
            port
            (
            stratix_dll_control  : out   std_logic;   
            local_ready          : out   std_logic;
            local_rdata_valid    : out   std_logic;
            local_rdvalid_in_n   : out   std_logic;
            local_rdata          : out   std_logic_vector(gLOCAL_DATA_BITS - 1 downto 0);
            local_wdata_req      : out   std_logic;
            local_init_done      : out   std_logic;
            local_refresh_ack    : out   std_logic;
            ddr_cs_n             : out   std_logic_vector(gMEM_CHIPSELS  - 1 downto 0);
            ddr_cke              : out   std_logic_vector(gMEM_CHIPSELS  - 1 downto 0);
            ddr_odt              : out   std_logic_vector(gMEM_CHIPSELS  - 1 downto 0);
            ddr_a                : out   std_logic_vector(gMEM_ROW_BITS  - 1 downto 0);
            ddr_ba               : out   std_logic_vector(gMEM_BANK_BITS - 1 downto 0);
            ddr_ras_n            : out   std_logic;
            ddr_cas_n            : out   std_logic;
            ddr_we_n             : out   std_logic;
            control_doing_wr     : out   std_logic;
            control_dqs_burst    : out   std_logic;
            control_wdata_valid  : out   std_logic;
            control_wdata        : out   std_logic_vector(gLOCAL_DATA_BITS - 1 downto 0);
            control_be           : out   std_logic_vector(gLOCAL_DATA_BITS/8 - 1 downto 0);
            control_doing_rd     : out   std_logic;

            clk                  : in    std_logic;
            reset_n              : in    std_logic;
            write_clk            : in    std_logic;
            local_read_req       : in    std_logic;
            local_write_req      : in    std_logic;
            local_size           : in    std_logic_vector(gLOCAL_BURST_LEN_BITS - 1 downto 0); 
            local_burstbegin     : in    std_logic; 
            local_cs_addr        : in    std_logic_vector(auk_to_legal_width(gMEM_CHIP_BITS) - 1 downto 0);
            local_row_addr       : in    std_logic_vector(gMEM_ROW_BITS  - 1 downto 0);
            local_bank_addr      : in    std_logic_vector(gMEM_BANK_BITS - 1 downto 0);
            local_col_addr       : in    std_logic_vector(gMEM_COL_BITS  - 2 downto 0); 
            local_wdata          : in    std_logic_vector(gLOCAL_DATA_BITS - 1 downto 0);
            local_be             : in    std_logic_vector(gLOCAL_DATA_BITS/8 - 1 downto 0);
            local_refresh_req    : in    std_logic;
            local_autopch_req    : in    std_logic;
            control_rdata        : in    std_logic_vector(gLOCAL_DATA_BITS - 1 downto 0);
            mem_tcl              : in    std_logic_vector(2 downto 0); 
            mem_bl               : in    std_logic_vector(2 downto 0); 
            mem_odt              : in    std_logic_vector(1 downto 0); 
            mem_btype            : in    std_logic;                    
            mem_dll_en           : in    std_logic;                    
            mem_drv_str          : in    std_logic;                    
            mem_trcd             : in    std_logic_vector(2 downto 0); 
            mem_tras             : in    std_logic_vector(3 downto 0); 
            mem_twtr             : in    std_logic_vector(1 downto 0); 
            mem_twr              : in    std_logic_vector(2 downto 0); 
            mem_trp              : in    std_logic_vector(2 downto 0); 
            mem_trfc             : in    std_logic_vector(6 downto 0); 
            mem_tmrd             : in    std_logic_vector(1 downto 0); 
            mem_trefi            : in    std_logic_vector(15 downto 0);
            mem_tinit_time       : in    std_logic_vector(15 downto 0) 
            );
        end component;
        ];
}

################################################################################

=item I<set_port_map_defaults()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub set_port_map_defaults
{
   # redefine the default port map here if you wish
   # set things you don't want popping out to "open"
   my $this = shift;
   #$this->port_map({});
}

################################################################################

=item I<set_parameter_map_defaults()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub set_parameter_map_defaults
{
   # redefine the default parameter map here if you wish
   my $this = shift;
   #$this->parameter_map({"gREG_DIMM" => "false"});
}

################################################################################

=item I<set_autoparameters()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub set_autoparameters
{
   my $this = shift;
   my $return = $this->SUPER::set_autoparameters(@_);
   return $return;
}

1;



=back
=cut
=head1 EXAMPLE
Here is a usage example ...
=head1 AUTHOR
Santa Cruz Technology Center
=head1 BUGS AND LIMITATIONS
list them here ...
=head1 SEE ALSO
The inherited class e_lpm_base
=begin html
<A HREF="e_lpm_base.html">e_lpm_base</A> webpage
=end html
=head1 COPYRIGHT
Copyright (C)2001-2005 Altera Corporation, All rights reserved.
=cut
1;
