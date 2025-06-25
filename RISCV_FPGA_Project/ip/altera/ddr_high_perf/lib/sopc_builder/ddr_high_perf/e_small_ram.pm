#Copyright (C)2001-2004 Altera Corporation
#Any megafunction design, and related net list (encrypted or decrypted),
#support information, device programming or simulation file, and any other
#associated documentation or information provided by Altera or a partner
#under Altera's Megafunction Partnership Program may be used only to
#program PLD devices (but not masked PLD devices) from Altera.  Any other
#use of such megafunction design, net list, support information, device
#programming or simulation file, or any other related documentation or
#information is prohibited for any other purpose, including, but not
#limited to modification, reverse engineering, de-compiling, or use with
#any other silicon devices, unless such use is explicitly licensed under
#a separate agreement with Altera or a megafunction partner.  Title to
#the intellectual property, including patents, copyrights, trademarks,
#trade secrets, or maskworks, embodied in any such megafunction design,
#net list, support information, device programming or simulation file, or
#any other related documentation or information provided by Altera or a
#megafunction partner, remains with Altera, the megafunction partner, or
#their respective licensors.  No other licenses, including any licenses
#needed under any third party's intellectual property, are provided herein.
#Copying or modifying any file, or portion thereof, to which this notice
#is attached violates this copyright.

=head1 NAME

e_ram - description of the module goes here ...

=head1 SYNOPSIS

The e_ram class implements ... detailed description of functionality

=head1 METHODS

=over 4

=cut

package e_small_ram;

use europa_utils;

use e_instance;
@ISA = qw (e_instance);

use strict;

my %fields =
(
    name        => "default_name",
    addr_width  => 24,
    data_width  => 16,
);

my %pointers =
(
);

&package_setup_fields_and_pointers
    (__PACKAGE__,
     \%fields, 
     \%pointers,
    );

=item I<new()>

Object constructor

=cut

sub new 
{
   my $this  = shift;
   my $self  = $this->SUPER::new();

   $self->set(@_);

   $self->setup_module();

   return $self;
}

=item I<setup_module()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub setup_module
{
    my $this = shift;
    my $name = $this->name();
    my $module = e_module->new
        ({ name  => "${name}_module",
            contents => [ 
                e_port->news
                ( 
                    ["data"      , $this->data_width()   , "input" ],
                    ["rdaddress" , $this->addr_width()   , "input" ],
                    ["wraddress" , $this->addr_width()   , "input" ],
                    ["wrclock"   , 1                     , "input" ],
                    ["wren"      , 1                     , "input" ],
                    ["q"         , $this->data_width()   , "output"],
                ),
                e_parameter->new({name => "ARRAY_DEPTH",default => 2048,vhdl_type => "integer",}),
            ]
        });
    $module->comment
    (
        "Default depth for this memory model is 2048, do these when\n
        changing the depth.\n
        \t1)Set ARRAY_DEPTH generic/parameter from 2048 to new depth.\n
        \t2)Change mem_array depth from 2047 to (new depth - 1).\n
        \t3)VHDL only, don't forget the generic in component declaration"
    );

    my $array_width = $this->addr_width() + $this->data_width() + 1;
    $module->add_contents
    (
        e_signal->new({name => "mem_array" ,width => $array_width,depth => 2048,never_export => 1,}),
        e_signal->new({name => "aq" ,width => $this->data_width(),never_export => 1,}),
        e_assign->new({lhs => "aq" ,rhs => "mem_array[0][".($this->data_width()-1).":0]"}),
    );
   
   $this->module($module);

}

=item I<to_verilog()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub to_verilog
{
   my $this = shift;

   $this->module()->simulation_strings(
					      $this->verilog_string()
					     );

   return $this->SUPER::to_verilog(@_);
}

=item I<to_vhdl()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub to_vhdl
{
   my $this = shift;

   $this->module()->simulation_strings(
					      $this->vhdl_string()
					     );

   return $this->SUPER::to_vhdl(@_);
}


=item I<verilog_string()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub verilog_string
{
    my $this = shift;

    my $ADDR_WIDTH = $this->addr_width();
    my $DATA_WIDTH = $this->data_width();
    my $ARRAY_WIDTH = $this->addr_width() + $this->data_width() + 1;

    my $memory_process;

    $memory_process = qq[
  reg     [  $DATA_WIDTH - 1: 0] out;

    integer i;
    reg found_valid_data;
    reg data_written;

    initial
    begin
        for (i = 0; i < ARRAY_DEPTH; i = i + 1)
            mem_array[i][0] <= 1'b0;
        data_written <= 1'b0;
    end

    always @(rdaddress)
    begin
        found_valid_data <= 1'b0;
        for (i = 0; i < ARRAY_DEPTH; i = i + 1)
        begin
            if (rdaddress == mem_array[i][$ARRAY_WIDTH - 1:$ARRAY_WIDTH - $ADDR_WIDTH] && mem_array[i][0])
            begin
                out = mem_array[i][$ARRAY_WIDTH - $ADDR_WIDTH - 1:$ARRAY_WIDTH - $ADDR_WIDTH - $DATA_WIDTH];
                found_valid_data = 1'b1;
            end
        end
        if (!found_valid_data)
            out = ${DATA_WIDTH}'dX;
    end

    always @(posedge wrclock)
    if (wren)
    begin
        data_written <= 1'b0;
        for (i = 0; i < ARRAY_DEPTH; i = i + 1)
        begin
            if (wraddress == mem_array[i][$ARRAY_WIDTH - 1:$ARRAY_WIDTH - $ADDR_WIDTH] && !data_written)
            begin
                mem_array[i][$ARRAY_WIDTH - $ADDR_WIDTH - 1:$ARRAY_WIDTH - $ADDR_WIDTH - $DATA_WIDTH] <= data;
                mem_array[i][0] <= 1'b1;
                data_written = 1'b1;
            end
            else if (!mem_array[i][0] && !data_written)
            begin
                mem_array[i] <= {wraddress,data,1'b1};
                data_written = 1'b1;
            end
        end
        if (!data_written)
        begin
            \$write(\$time);
            \$write(" --- Data could not be written, increase array depth or use full memory model --- ");
            \$stop;
        end
    end

    assign q = out;
];#'

return ($memory_process);
};

=item I<vhdl_string()>

method description goes here...
...remember: there must be a newline around each POD tag (e.g. =item, =cut etc)!

=cut

sub vhdl_string
{
    my $this = shift;

    my $ADDR_WIDTH = $this->addr_width();
    my $DATA_WIDTH = $this->data_width();
    my $ARRAY_WIDTH = $this->addr_width() + $this->data_width() + 1;

    my $memory_process;

    $memory_process = qq[
    process (wrclock, rdaddress)
        variable mem_init : boolean := false;
        variable found_valid_data : boolean := false;
        variable data_written : boolean := false;
    begin
    
        if(not mem_init) then
            for I in 0 to ARRAY_DEPTH - 1 loop
                mem_array(I) <= (others =>'0');
            end loop;
        mem_init := true;
        end if;
        
        if rdaddress'event then
            found_valid_data := false;
            for I in 0 to ARRAY_DEPTH - 1 loop
                if (rdaddress = mem_array(I)($ARRAY_WIDTH - 1 downto $ARRAY_WIDTH - $ADDR_WIDTH) and mem_array(I)(0) = '1') then
                    q <= mem_array(I)($ARRAY_WIDTH - $ADDR_WIDTH - 1 downto $ARRAY_WIDTH - $ADDR_WIDTH - $DATA_WIDTH);
                    found_valid_data := true;
                end if;
            end loop;
            if (not found_valid_data) then
                q <= (others => 'X');
            end if;
        end if;
        
        if wrclock'event and wrclock = '1' then
            if wren = '1' then 
                data_written := false;
                for I in 0 to ARRAY_DEPTH - 1 loop
                    if (wraddress = mem_array(I)($ARRAY_WIDTH - 1 downto $ARRAY_WIDTH - $ADDR_WIDTH) and not data_written) then
                        mem_array(I)($ARRAY_WIDTH - $ADDR_WIDTH - 1 downto $ARRAY_WIDTH - $ADDR_WIDTH - $DATA_WIDTH) <= data;
                        mem_array(I)(0) <= '1';
                        data_written := true;
                    elsif (mem_array(I)(0) = '0' and not data_written) then
                        mem_array(I) <= wraddress & data & '1';
                        data_written := true;
                    end if;
                end loop;
                if (not data_written) then
                    ASSERT false REPORT " --- Data could not be written, increase array depth or use full memory model --- " SEVERITY FAILURE ;
                end if;
            end if;
        end if;
    
    end process;

];#'

return ($memory_process);
};

__PACKAGE__->DONE();

=back

=cut

=head1 EXAMPLE

Here is a usage example ...

=head1 AUTHOR

Santa Cruz Technology Center

=head1 BUGS AND LIMITATIONS

list them here ...

=head1 SEE ALSO

The inherited class e_lpm_instance

=begin html

<A HREF="e_lpm_instance.html">e_lpm_instance</A> webpage

=end html

=head1 COPYRIGHT

Copyright (C)2001-2005 Altera Corporation, All rights reserved.

=cut

1;
