# (C) 2001-2013 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.



# $Id: //acds/rel/13.1/ip/merlin/altera_tristate_controller_aggregator/altera_tristate_controller_aggregator_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | 
# | altera_tristate_controller_aggregator "Tristate Controller Aggregator" v1.0
# | 2008.10.15.13:20:06
# | 
# | 
# +-----------------------------------

package require -exact sopc 9.1

# +-----------------------------------
# | module altera_tristate_controller_aggregator
# | 
set_module_property NAME altera_tristate_controller_aggregator
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Tristate Components"
set_module_property DISPLAY_NAME "Tristate Controller Aggregator"
set_module_property TOP_LEVEL_HDL_FILE altera_tristate_controller_aggregator.sv
set_module_property TOP_LEVEL_HDL_MODULE altera_tristate_controller_aggregator
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property INTERNAL true
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

add_file altera_tristate_controller_aggregator.sv {SYNTHESIS SIMULATION}

# +-----------------------------------
# | parameters
# |
add_parameter AV_ADDRESS_W INTEGER 32 
set_parameter_property AV_ADDRESS_W AFFECTS_ELABORATION true
set_parameter_property AV_ADDRESS_W HDL_PARAMETER true
set_parameter_property AV_ADDRESS_W DESCRIPTION {Width of the address signal - component side}
set_parameter_property AV_ADDRESS_W DISPLAY_NAME {Component address width}

add_parameter AV_DATA_W INTEGER 32
set_parameter_property AV_DATA_W AFFECTS_ELABORATION true
set_parameter_property AV_DATA_W HDL_PARAMETER true
set_parameter_property AV_DATA_W DESCRIPTION {Width of the readdata, writedata signals - component side}
set_parameter_property AV_DATA_W DISPLAY_NAME {Component Data width}

add_parameter AV_BYTEENABLE_W INTEGER 4
set_parameter_property AV_BYTEENABLE_W AFFECTS_ELABORATION true
set_parameter_property AV_BYTEENABLE_W HDL_PARAMETER true
set_parameter_property AV_BYTEENABLE_W DESCRIPTION {Width of the byteenable signal - component side}
set_parameter_property AV_BYTEENABLE_W DISPLAY_NAME {Component byteenable width}

add_parameter USE_READDATA INTEGER 1
set_parameter_property USE_READDATA AFFECTS_ELABORATION true
set_parameter_property USE_READDATA HDL_PARAMETER false
set_parameter_property USE_READDATA DESCRIPTION {Enable the readdata signal}
set_parameter_property USE_READDATA DISPLAY_NAME {Use readdata}

add_parameter USE_WRITEDATA INTEGER 1
set_parameter_property USE_WRITEDATA AFFECTS_ELABORATION true
set_parameter_property USE_WRITEDATA HDL_PARAMETER false
set_parameter_property USE_WRITEDATA DESCRIPTION {Enable the writedata signal}
set_parameter_property USE_WRITEDATA DISPLAY_NAME {Use writedata}

add_parameter USE_READ INTEGER 1
set_parameter_property USE_READ AFFECTS_ELABORATION true
set_parameter_property USE_READ HDL_PARAMETER false
set_parameter_property USE_READ DESCRIPTION {Enable the read signal}
set_parameter_property USE_READ DISPLAY_NAME {Use read}

add_parameter USE_WRITE INTEGER 1
set_parameter_property USE_WRITE AFFECTS_ELABORATION true
set_parameter_property USE_WRITE HDL_PARAMETER false

add_parameter USE_BEGINTRANSFER INTEGER 1
set_parameter_property USE_BEGINTRANSFER AFFECTS_ELABORATION true
set_parameter_property USE_BEGINTRANSFER HDL_PARAMETER false
set_parameter_property USE_BEGINTRANSFER DESCRIPTION {Enable the begintransfer signal}
set_parameter_property USE_BEGINTRANSFER DISPLAY_NAME {Use begintransfer}

add_parameter USE_BYTEENABLE INTEGER 1
set_parameter_property USE_BYTEENABLE AFFECTS_ELABORATION true
set_parameter_property USE_BYTEENABLE HDL_PARAMETER false
set_parameter_property USE_BYTEENABLE DESCRIPTION {Enable the byteenable signal}
set_parameter_property USE_BYTEENABLE DISPLAY_NAME {Use byteenable}

add_parameter USE_CHIPSELECT INTEGER 0
set_parameter_property USE_CHIPSELECT AFFECTS_ELABORATION true
set_parameter_property USE_CHIPSELECT HDL_PARAMETER false
set_parameter_property USE_CHIPSELECT DESCRIPTION {Enable the chipselect signal}
set_parameter_property USE_CHIPSELECT DISPLAY_NAME {Use chipselect}

add_parameter USE_LOCK INTEGER 0
set_parameter_property USE_LOCK AFFECTS_ELABORATION true
set_parameter_property USE_LOCK HDL_PARAMETER false
set_parameter_property USE_LOCK DESCRIPTION {Enable the lock signal}
set_parameter_property USE_LOCK DISPLAY_NAME {Use lock}

add_parameter USE_ADDRESS INTEGER 1
set_parameter_property USE_ADDRESS AFFECTS_ELABORATION true
set_parameter_property USE_ADDRESS HDL_PARAMETER false
set_parameter_property USE_ADDRESS DESCRIPTION {Enable the address signal}
set_parameter_property USE_ADDRESS DISPLAY_NAME {Use address}

add_parameter USE_WAITREQUEST INTEGER 0
set_parameter_property USE_WAITREQUEST AFFECTS_ELABORATION true
set_parameter_property USE_WAITREQUEST HDL_PARAMETER false
set_parameter_property USE_WAITREQUEST DESCRIPTION {Enable the waitrequest signal}
set_parameter_property USE_WAITREQUEST DISPLAY_NAME {Use waitrequest}

add_parameter USE_WRITEBYTEENABLE INTEGER 0
set_parameter_property USE_WRITE DESCRIPTION {Enable the write signal}
set_parameter_property USE_WRITE DISPLAY_NAME {Use write}
set_parameter_property USE_WRITEBYTEENABLE AFFECTS_ELABORATION true
set_parameter_property USE_WRITEBYTEENABLE HDL_PARAMETER false
set_parameter_property USE_WRITEBYTEENABLE DESCRIPTION {Enable the writebyteenable signal}
set_parameter_property USE_WRITEBYTEENABLE DISPLAY_NAME {Use writebyteenable}

add_parameter USE_OUTPUTENABLE INTEGER 0
set_parameter_property USE_OUTPUTENABLE AFFECTS_ELABORATION true
set_parameter_property USE_OUTPUTENABLE HDL_PARAMETER false
set_parameter_property USE_OUTPUTENABLE DESCRIPTION {Enable the outputenable signal}
set_parameter_property USE_OUTPUTENABLE DISPLAY_NAME {Use outputenable}

add_parameter USE_RESETREQUEST INTEGER 0
set_parameter_property USE_RESETREQUEST AFFECTS_ELABORATION true
set_parameter_property USE_RESETREQUEST HDL_PARAMETER false
set_parameter_property USE_RESETREQUEST DESCRIPTION {Enable the resetrequest signal}
set_parameter_property USE_RESETREQUEST DISPLAY_NAME {Use resetrequest}

add_parameter USE_IRQ INTEGER 0
set_parameter_property USE_IRQ AFFECTS_ELABORATION true
set_parameter_property USE_IRQ HDL_PARAMETER false
set_parameter_property USE_IRQ DESCRIPTION {Enable the irq signal}
set_parameter_property USE_IRQ DISPLAY_NAME {Use irq}

add_parameter USE_RESET_OUTPUT INTEGER 0
set_parameter_property USE_RESET_OUTPUT AFFECTS_ELABORATION true
set_parameter_property USE_RESET_OUTPUT HDL_PARAMETER false
set_parameter_property USE_RESET_OUTPUT DESCRIPTION {Enable the resetoutput signal}
set_parameter_property USE_RESET_OUTPUT DISPLAY_NAME {Use resetoutput}

add_parameter ACTIVE_LOW_READ INTEGER 0
set_parameter_property ACTIVE_LOW_READ AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_READ HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_READ DESCRIPTION {Active low read}
set_parameter_property ACTIVE_LOW_READ DISPLAY_NAME {Active low read}

add_parameter ACTIVE_LOW_LOCK INTEGER 0
set_parameter_property ACTIVE_LOW_LOCK AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_LOCK HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_LOCK DESCRIPTION {Active low lock}
set_parameter_property ACTIVE_LOW_LOCK DISPLAY_NAME {Active low lock}

add_parameter ACTIVE_LOW_WRITE INTEGER 0
set_parameter_property ACTIVE_LOW_WRITE AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_WRITE HDL_PARAMETER false

add_parameter ACTIVE_LOW_CHIPSELECT INTEGER 0
set_parameter_property ACTIVE_LOW_CHIPSELECT AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_CHIPSELECT HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_CHIPSELECT DESCRIPTION {Active low chipselect}
set_parameter_property ACTIVE_LOW_CHIPSELECT DISPLAY_NAME {Active low chipselect}

add_parameter ACTIVE_LOW_BYTEENABLE INTEGER 0
set_parameter_property ACTIVE_LOW_BYTEENABLE AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_BYTEENABLE HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_BYTEENABLE DESCRIPTION {Active low byteenable}
set_parameter_property ACTIVE_LOW_BYTEENABLE DISPLAY_NAME {Active low byteenable}

add_parameter ACTIVE_LOW_OUTPUTENABLE INTEGER 0
set_parameter_property ACTIVE_LOW_OUTPUTENABLE AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_OUTPUTENABLE HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_OUTPUTENABLE DESCRIPTION {Active low outputenable}
set_parameter_property ACTIVE_LOW_OUTPUTENABLE DISPLAY_NAME {Active low outputenable}

add_parameter ACTIVE_LOW_WRITEBYTEENABLE INTEGER 0
set_parameter_property ACTIVE_LOW_WRITE DESCRIPTION {Active low write}
set_parameter_property ACTIVE_LOW_WRITE DISPLAY_NAME {Active low write}
set_parameter_property ACTIVE_LOW_WRITEBYTEENABLE AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_WRITEBYTEENABLE HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_WRITEBYTEENABLE DESCRIPTION {Active low writebyteenable}
set_parameter_property ACTIVE_LOW_WRITEBYTEENABLE DISPLAY_NAME {Active low writebyteenable}

add_parameter ACTIVE_LOW_WAITREQUEST INTEGER 0
set_parameter_property ACTIVE_LOW_WAITREQUEST AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_WAITREQUEST HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_WAITREQUEST DESCRIPTION {Active low waitrequest}
set_parameter_property ACTIVE_LOW_WAITREQUEST DISPLAY_NAME {Active low waitrequest}

add_parameter ACTIVE_LOW_BEGINTRANSFER INTEGER 0
set_parameter_property ACTIVE_LOW_BEGINTRANSFER AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_BEGINTRANSFER HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_BEGINTRANSFER DESCRIPTION {Active low begintransfer}
set_parameter_property ACTIVE_LOW_BEGINTRANSFER DISPLAY_NAME {Active low begintransfer}

add_parameter ACTIVE_LOW_IRQ INTEGER 0
set_parameter_property ACTIVE_LOW_IRQ AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_IRQ HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_IRQ DESCRIPTION {Active low irq}
set_parameter_property ACTIVE_LOW_IRQ DISPLAY_NAME {Active low irq}

add_parameter ACTIVE_LOW_RESETREQUEST INTEGER 0
set_parameter_property ACTIVE_LOW_RESETREQUEST AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_RESETREQUEST HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_RESETREQUEST DESCRIPTION {Active low resetrequest}
set_parameter_property ACTIVE_LOW_RESETREQUEST DISPLAY_NAME {Active low resetrequest}

add_parameter ACTIVE_LOW_RESET_OUTPUT INTEGER 0
set_parameter_property ACTIVE_LOW_RESET_OUTPUT AFFECTS_ELABORATION true
set_parameter_property ACTIVE_LOW_RESET_OUTPUT HDL_PARAMETER false
set_parameter_property ACTIVE_LOW_RESET_OUTPUT DESCRIPTION {Active low resetoutput}
set_parameter_property ACTIVE_LOW_RESET_OUTPUT DISPLAY_NAME {Active low resetoutput}

add_parameter AV_READ_LATENCY INTEGER 0
set_parameter_property AV_READ_LATENCY AFFECTS_ELABORATION true
set_parameter_property AV_READ_LATENCY HDL_PARAMETER false
set_parameter_property AV_READ_LATENCY DESCRIPTION {Interface readLatency}
set_parameter_property AV_READ_LATENCY DISPLAY_NAME {readLatency}

add_parameter AV_WRITE_WAIT INTEGER 0
set_parameter_property AV_WRITE_WAIT AFFECTS_ELABORATION true
set_parameter_property AV_WRITE_WAIT HDL_PARAMETER false
set_parameter_property AV_WRITE_WAIT DESCRIPTION {Avalon-MM writeWaitTime interface property}
set_parameter_property AV_WRITE_WAIT DISPLAY_NAME {writeWaitTime}

add_parameter AV_READ_WAIT INTEGER 1
set_parameter_property AV_READ_WAIT AFFECTS_ELABORATION true
set_parameter_property AV_READ_WAIT HDL_PARAMETER false
set_parameter_property AV_READ_WAIT DESCRIPTION {Avalon-MM readWaitTime interface property}
set_parameter_property AV_READ_WAIT DISPLAY_NAME {readWaitTime}

add_parameter AV_HOLD_TIME INTEGER 0
set_parameter_property AV_HOLD_TIME AFFECTS_ELABORATION true
set_parameter_property AV_HOLD_TIME HDL_PARAMETER false
set_parameter_property AV_HOLD_TIME DESCRIPTION {Interface holdTime}
set_parameter_property AV_HOLD_TIME DISPLAY_NAME {holdTime}

add_parameter AV_SETUP_WAIT INTEGER 0
set_parameter_property AV_SETUP_WAIT AFFECTS_ELABORATION true
set_parameter_property AV_SETUP_WAIT HDL_PARAMETER false

add_parameter AV_TIMING_UNITS INTEGER 1
set_parameter_property AV_TIMING_UNITS AFFECTS_ELABORATION true
set_parameter_property AV_SETUP_WAIT HDL_PARAMETER false
set_parameter_property AV_SETUP_WAIT DESCRIPTION {Avalon-MM setupTime interface property}
set_parameter_property AV_SETUP_WAIT DISPLAY_NAME {setupTime}
set_parameter_property AV_TIMING_UNITS ALLOWED_RANGES { 1:Cycles 0:Nanoseconds }
set_parameter_property AV_TIMING_UNITS DESCRIPTION {Timing in cycles or nanoseconds}
set_parameter_property AV_TIMING_UNITS DISPLAY_NAME {Timing units}

# | 
# +-----------------------------------



# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end
set_interface_property clk ptfSchematicName ""

add_interface_port clk clk clk Input 1

add_interface reset reset end
add_interface_port reset reset reset Input 1
set_interface_property reset ASSOCIATED_CLOCK clk
# | 
# +-----------------------------------

add_interface tristate_conduit_master_0 tristate_conduit master clk
set_interface_property tristate_conduit_master_0 ASSOCIATED_CLOCK clk

add_interface avalon_slave_0 avalon slave clk
set_interface_property avalon_slave_0 ASSOCIATED_CLOCK clk
set_interface_property avalon_slave_0 associatedReset reset
set_interface_property avalon_slave_0 addressAlignment DYNAMIC
set_interface_property avalon_slave_0 addressUnits SYMBOLS
set_interface_property avalon_slave_0 burstcountUnits SYMBOLS
set_interface_property avalon_slave_0 timingUnits cycles
set_interface_property avalon_slave_0 maximumPendingReadTransactions 0
set_interface_property avalon_slave_0 bitsPerSymbol 8
set_interface_property avalon_slave_0 interleaveBursts 0
set_interface_property avalon_slave_0 isBigEndian 0
set_interface_property avalon_slave_0 addressGroup 0
set_interface_property avalon_slave_0 registerOutgoingSignals 0
set_interface_property avalon_slave_0 registerIncomingSignals 0
set_interface_property avalon_slave_0 alwaysBurstMaxBurst 0
set_interface_property avalon_slave_0 linewrapBursts 0
set_interface_property avalon_slave_0 constantBurstBehavior 0
set_interface_property avalon_slave_0 readLatency 0

add_interface conduit_end conduit end

add_interface reset_out reset start
set_interface_property reset_out synchronousEdges none
set_interface_property reset_out associatedResetSinks none

add_interface irq_out interrupt sender clk
set_interface_property irq_out associatedAddressablePoint avalon_slave_0

#Static Assignments

#Write
add_interface_port avalon_slave_0 av_write write input 1
add_interface_port tristate_conduit_master_0 tcm0_write write_out output 1
add_interface_port tristate_conduit_master_0 tcm0_write_n write_n_out output 1

#lock    
add_interface_port avalon_slave_0 av_lock lock input 1
add_interface_port tristate_conduit_master_0 tcm0_lock lock_out output 1
add_interface_port tristate_conduit_master_0 tcm0_lock_n lock_n_out output 1

#Read
add_interface_port avalon_slave_0 av_read read input 1
add_interface_port tristate_conduit_master_0 tcm0_read read_out output 1
add_interface_port tristate_conduit_master_0 tcm0_read_n read_n_out output 1

#BeginTransfer
add_interface_port avalon_slave_0 av_begintransfer begintransfer input 1
add_interface_port tristate_conduit_master_0 tcm0_begintransfer begintransfer_out output 1
add_interface_port tristate_conduit_master_0 tcm0_begintransfer_n begintransfer_n_out output 1

#Chipselect
add_interface_port avalon_slave_0 av_chipselect chipselect input 1
add_interface_port tristate_conduit_master_0 tcm0_chipselect chipselect_out output 1
add_interface_port tristate_conduit_master_0 tcm0_chipselect_n chipselect_n_out output 1

#OutputEnable
add_interface_port avalon_slave_0 av_outputenable outputenable input 1
add_interface_port tristate_conduit_master_0 tcm0_outputenable outputenable_out output 1
add_interface_port tristate_conduit_master_0 tcm0_outputenable_n outputenable_n_out output 1

# waitrequest    
add_interface_port avalon_slave_0 av_waitrequest waitrequest output 1
add_interface_port tristate_conduit_master_0 tcm0_waitrequest waitrequest_in input 1
add_interface_port tristate_conduit_master_0 tcm0_waitrequest_n waitrequest_n_in input 1

#resetrequest
add_interface_port reset_out reset_out reset output 1
add_interface_port tristate_conduit_master_0 tcm0_resetrequest resetrequest_in input 1
add_interface_port tristate_conduit_master_0 tcm0_resetrequest_n resetrequest_n_in input 1

#IRQ
add_interface_port tristate_conduit_master_0 tcm0_irq_in irq_in_in input 1
add_interface_port tristate_conduit_master_0 tcm0_irq_in_n irq_in_n_in input 1
add_interface_port irq_out irq_out irq output 1

#Reset Outputs
add_interface_port tristate_conduit_master_0 tcm0_reset_output reset_out output 1
add_interface_port tristate_conduit_master_0 tcm0_reset_output_n reset_n_out output 1

# ----------------
# Request and Grant
# ----------------
add_interface_port tristate_conduit_master_0 tcm0_request request output 1
add_interface_port tristate_conduit_master_0 tcm0_grant   grant   input 1

#Declare conduit interface
add_interface_port conduit_end c0_request request input  1
add_interface_port conduit_end c0_grant   grant   output 1
add_interface_port conduit_end c0_uav_write uav_write input 1

proc terminate {name value } {
    set_port_property $name termination true
    set_port_property $name termination_value $value
}

proc elaborate {} {


    set units [get_parameter_value AV_TIMING_UNITS]
    if { $units == 1 } {
	set units cycles
    } else {
	set units nanoseconds
    }

    set_interface_property avalon_slave_0 readLatency [get_parameter_value AV_READ_LATENCY]
    set_interface_property avalon_slave_0 readWaitTime [get_parameter_value AV_READ_WAIT]
    set_interface_property avalon_slave_0 setupTime [get_parameter_value AV_SETUP_WAIT]
    set_interface_property avalon_slave_0 holdTime [get_parameter_value AV_HOLD_TIME]
    set_interface_property avalon_slave_0 writeWaitTime [get_parameter_value AV_WRITE_WAIT]
    set_interface_property avalon_slave_0 timingUnits $units
    
    #Declare Tristate Conduit Master Interface and

    #Declare the slave-side customizable avalon interface
    
    # ----------------
    # Address
    # ----------------
    
    add_interface_port avalon_slave_0 av_address address input [ get_parameter_value AV_ADDRESS_W ]
    add_interface_port tristate_conduit_master_0 tcm0_address address_out output [ get_parameter_value AV_ADDRESS_W ]


    if { [get_parameter_value USE_ADDRESS] == 0 } {
	terminate av_address 0
	terminate tcm0_address 0
    }
   
    # ----------------
    # Byteenable
    # ----------------
    
    add_interface_port avalon_slave_0 av_byteenable byteenable input [ get_parameter_value AV_BYTEENABLE_W ]
    add_interface_port tristate_conduit_master_0 tcm0_byteenable byteenable_out output [ get_parameter_value AV_BYTEENABLE_W ]
    add_interface_port tristate_conduit_master_0 tcm0_byteenable_n byteenable_n_out output [ get_parameter_value AV_BYTEENABLE_W ]

    
    if { [ get_parameter_value USE_BYTEENABLE ] ==  0 } {
	terminate av_byteenable 0
	terminate tcm0_byteenable 0
	terminate tcm0_byteenable_n 0
    } else {
	
	if {[get_parameter_value ACTIVE_LOW_BYTEENABLE] == 1 } {
	    terminate tcm0_byteenable 0
	} else {
	    terminate tcm0_byteenable_n 0xFFFFFFFF
	}

    }

    # ----------------
    # Writebyteenable
    # ----------------
    
    add_interface_port avalon_slave_0 av_writebyteenable writebyteenable input [ get_parameter_value AV_BYTEENABLE_W ]
    add_interface_port tristate_conduit_master_0 tcm0_writebyteenable writebyteenable_out output [ get_parameter_value AV_BYTEENABLE_W ]
    add_interface_port tristate_conduit_master_0 tcm0_writebyteenable_n writebyteenable_n_out output [ get_parameter_value AV_BYTEENABLE_W ]


    if { [get_parameter_value USE_WRITEBYTEENABLE] == 0 } {
	terminate av_writebyteenable 0
	terminate tcm0_writebyteenable 0
	terminate tcm0_writebyteenable_n 0
    } else {
	
	if { [get_parameter_value ACTIVE_LOW_WRITEBYTEENABLE] == 1} {
	    terminate tcm0_writebyteenable 0
	} else {
	    terminate tcm0_writebyteenable_n 0xFFFFFFFF
	}

    }    

    # ----------------
    # Writedata and Output Enable
    # ----------------
    
    add_interface_port avalon_slave_0 av_writedata writedata input [ get_parameter_value AV_DATA_W ]
    add_interface_port tristate_conduit_master_0 tcm0_writedata data_out output [ get_parameter_value AV_DATA_W ]
    add_interface_port tristate_conduit_master_0 tcm0_data_outen data_outen output 1
    

    if { [ get_parameter_value USE_WRITEDATA ] ==  0 } {
        terminate av_writedata 0
	terminate tcm0_writedata 0
	terminate tcm0_data_outen 0
    }
    # ----------------
    # Readdata
    # ----------------
    
    add_interface_port avalon_slave_0 av_readdata readdata output [ get_parameter_value AV_DATA_W ]
    add_interface_port tristate_conduit_master_0 tcm0_readdata data_in input [ get_parameter_value AV_DATA_W ]

    if { [ get_parameter_value USE_READDATA ] ==  0 } {
        terminate av_readdata 0
	terminate tcm0_readdata 0
    }

    # ----------------
    # Write
    # ----------------
    


    if { [get_parameter_value USE_WRITE] == 0 } {
	terminate av_write 0
	terminate tcm0_write 0
	terminate tcm0_write_n 0
    } else {
	
	if {[get_parameter_value ACTIVE_LOW_WRITE] == 1} {
	    terminate tcm0_write 0
	} else {
	    terminate tcm0_write_n 1
	}
    }
    
    # ----------------
    # lock
    # ----------------

    if { [get_parameter_value USE_LOCK] == 0 } {
	terminate av_lock 0
	terminate tcm0_lock 0
	terminate tcm0_lock_n 0
    } else {
	
	if {[get_parameter_value ACTIVE_LOW_LOCK] == 1 } {
	    terminate tcm0_lock 0
	} else {
	    terminate tcm0_lock_n 1
	}
    }
    

    # ----------------
    # Read
    # ----------------
    


    if { [get_parameter_value USE_READ] == 0 } {
	terminate av_read 0
	terminate tcm0_read 0
	terminate tcm0_read_n 0
    } else {
	
	if {[get_parameter_value ACTIVE_LOW_READ] == 1 } {
	    terminate tcm0_read 0
	} else {
	    terminate tcm0_read_n 1
	}
    }

    # ----------------
    # waitrequest
    # ----------------

    if { [ get_parameter_value USE_WAITREQUEST ] ==  0 } {
	terminate av_waitrequest 0
	terminate tcm0_waitrequest 0
	terminate tcm0_waitrequest_n 0
    } else { 
	
	if {[get_parameter_value ACTIVE_LOW_WAITREQUEST] == 1 } {
	    terminate tcm0_waitrequest 0
	} else {
	    terminate tcm0_waitrequest_n 1
	}
    }
    
    # ----------------
    # Begintransfer
    # ----------------

    if { [ get_parameter_value USE_BEGINTRANSFER ] ==  0} {
	terminate av_begintransfer 0
	terminate tcm0_begintransfer 0
	terminate tcm0_begintransfer_n 0
    } else { 
	
	if {[get_parameter_value ACTIVE_LOW_BEGINTRANSFER] == 1 } {
	    terminate tcm0_begintransfer 0
	} else {
	    terminate tcm0_begintransfer_n 1
	}
    }
    
    # ----------------
    # Chipselect
    # ----------------

    if { [ get_parameter_value USE_CHIPSELECT ] ==  0 } {
	terminate av_chipselect 0
	terminate tcm0_chipselect 0
	terminate tcm0_chipselect_n 0
    } else {
	
	if { [get_parameter_value ACTIVE_LOW_CHIPSELECT] == 1} {
	    terminate tcm0_chipselect 0
	} else {
	    terminate tcm0_chipselect_n 1
	}

    }

    # ----------------
    # Outputenable
    # ----------------
    

    if { [ get_parameter_value USE_OUTPUTENABLE ] ==  0 } {
	terminate av_outputenable 0
	terminate tcm0_outputenable 0
	terminate tcm0_outputenable_n 0
    } else {
	
	if { [get_parameter_value ACTIVE_LOW_OUTPUTENABLE] == 1} {
	    terminate tcm0_outputenable 0
	} else {
	    terminate tcm0_outputenable_n 1
	}

    }

    # ----------------
    # Resetrequest
    # ----------------

    if { [ get_parameter_value USE_RESETREQUEST ] ==  0 } {
	terminate tcm0_resetrequest 0
	terminate tcm0_resetrequest_n 1
	terminate reset_out 0
    } else {

	if { [get_parameter_value ACTIVE_LOW_RESETREQUEST] == 1 } {
	    terminate tcm0_resetrequest 0
	} else {
	    terminate tcm0_resetrequest_n 1
	}

    }
    
    # ----------------
    # IRQ
    # ----------------
    
    if { [get_parameter_value USE_IRQ ] == 0 } {
	terminate irq_out 0
	terminate tcm0_irq_in 0
	terminate tcm0_irq_in_n 1
    } else {    

	if { [get_parameter_value ACTIVE_LOW_IRQ] == 1} {
	    terminate tcm0_irq_in 0
	} else {
	    terminate tcm0_irq_in_n 1
	}

    }


    # ----------------
    # Reset Output
    # ----------------
    
    if { [get_parameter_value USE_RESET_OUTPUT ] == 0 } {
	terminate tcm0_reset_output 0
	terminate tcm0_reset_output_n 1
    } else {    

	if { [get_parameter_value ACTIVE_LOW_RESET_OUTPUT] == 1} {
	    terminate tcm0_reset_output 0
	} else {
	    terminate tcm0_reset_output_n 1
	}

    }
    
}
