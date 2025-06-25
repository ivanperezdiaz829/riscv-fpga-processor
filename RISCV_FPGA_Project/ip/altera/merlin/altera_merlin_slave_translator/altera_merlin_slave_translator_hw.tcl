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


# (C) 2001-2012 Altera Corporation. All rights reserved.
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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_slave_translator/altera_merlin_slave_translator_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | 
# | altera_merlin_slave_translator "Merlin Slave Translator" v1.0
# | 2008.10.15.13:20:06
# | 
# | 
# +-----------------------------------

package require -exact qsys 12.1

# +-----------------------------------
# | module altera_merlin_slave_translator
# | 
set_module_property NAME altera_merlin_slave_translator
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Avalon MM Slave Translator"
set_module_property DESCRIPTION "Converts the Avalon-MM slave interface to a simplified representation that the Qsys network uses. Refer to the Avalon Interface Specifications (http://www.altera.com/literature/manual/mnl_avalon_spec.pdf) for definitions of the Avalon-MM signals and explanations of the bursting properties and address alignment."
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

#+ ----------------------------------------
#| Handy-Dandy Functions
#+ ----------------------------------------

 proc log2ceiling { num } {
    set val 0
    set i   1
    while { $i < $num } {
        set val [ expr $val + 1 ]
        set i   [ expr 1 << $val ]
    }

    return $val;
 }

 proc max { a b } { 
    if { $a > $b } {
        return $a
    } else {
        return $b
    }
 }

 proc min { a b } {
   return [ expr -1 * [ max [expr -$a] [expr -$b] ] ]
 }

 proc addr_span { a } {
  if { ($a < 0)} {
   # Handle exceptional cases:
   #  negative numbers: error; set a large number which might attract attention
   set val 18446744073709551616 
  } else {
    # Calculate the answer.
    set val 1
    for { set i 0 } { $i < $a } { incr i } {
     set val [ expr $val * 2 ]
    }
  }
  return $val
 }
 
 proc get_explicit_span { use_addr addr_w num_symbols address_symbols } {
     if { $use_addr == 0 } {
         set addr_w 0
     }
 
     if { $address_symbols == 0 } {
         incr addr_w [ log2ceiling $num_symbols ]
     }

     set explicitSpan [ addr_span $addr_w ]
    
     return $explicitSpan
 }

# +-----------------------------------
# | parameters
# |
add_parameter AV_ADDRESS_W INTEGER 30 
set_parameter_property AV_ADDRESS_W AFFECTS_ELABORATION true
set_parameter_property AV_ADDRESS_W HDL_PARAMETER true
set_parameter_property AV_ADDRESS_W ALLOWED_RANGES "1:64"
set_parameter_property AV_ADDRESS_W DESCRIPTION {Width of the address signal - component side}
set_parameter_property AV_ADDRESS_W DISPLAY_NAME {Component address width}

add_parameter AV_DATA_W INTEGER 32
set_parameter_property AV_DATA_W AFFECTS_ELABORATION true
set_parameter_property AV_DATA_W HDL_PARAMETER true
set_parameter_property AV_DATA_W ALLOWED_RANGES "1:32000"
set_parameter_property AV_DATA_W DESCRIPTION {Width of the readdata, writedata signals - component side}
set_parameter_property AV_DATA_W DISPLAY_NAME {Component Data width}

add_parameter UAV_DATA_W INTEGER 32
set_parameter_property UAV_DATA_W AFFECTS_ELABORATION true
set_parameter_property UAV_DATA_W HDL_PARAMETER true
set_parameter_property UAV_DATA_W ALLOWED_RANGES "1:32000"
set_parameter_property UAV_DATA_W DESCRIPTION {Width of the readdata, writedata signals - network side}
set_parameter_property UAV_DATA_W DISPLAY_NAME {Network Data width}

add_parameter AV_BURSTCOUNT_W INTEGER 4
set_parameter_property AV_BURSTCOUNT_W AFFECTS_ELABORATION true
set_parameter_property AV_BURSTCOUNT_W HDL_PARAMETER true
set_parameter_property AV_BURSTCOUNT_W ALLOWED_RANGES "1:32000"
set_parameter_property AV_BURSTCOUNT_W DESCRIPTION {Width of the burstcount signal - component side}
set_parameter_property AV_BURSTCOUNT_W DISPLAY_NAME {Component burstcount width}

add_parameter AV_BYTEENABLE_W INTEGER 4
set_parameter_property AV_BYTEENABLE_W AFFECTS_ELABORATION true
set_parameter_property AV_BYTEENABLE_W HDL_PARAMETER true
set_parameter_property AV_BYTEENABLE_W ALLOWED_RANGES "1:32000"
set_parameter_property AV_BYTEENABLE_W DESCRIPTION {Width of the byteenable signal - component side}
set_parameter_property AV_BYTEENABLE_W DISPLAY_NAME {Component byteenable width}

add_parameter UAV_BYTEENABLE_W INTEGER 4
set_parameter_property UAV_BYTEENABLE_W AFFECTS_ELABORATION true
set_parameter_property UAV_BYTEENABLE_W HDL_PARAMETER true
set_parameter_property UAV_BYTEENABLE_W ALLOWED_RANGES "1:32000"
set_parameter_property UAV_BYTEENABLE_W DESCRIPTION {Width of the byteenable signal - networkside}
set_parameter_property UAV_BYTEENABLE_W DISPLAY_NAME {Network byteenable width}

add_parameter UAV_ADDRESS_W INTEGER 32
set_parameter_property UAV_ADDRESS_W AFFECTS_ELABORATION true
set_parameter_property UAV_ADDRESS_W HDL_PARAMETER true
set_parameter_property UAV_ADDRESS_W ALLOWED_RANGES "1:32000"
set_parameter_property UAV_ADDRESS_W DESCRIPTION {Width of the address signal - network side}
set_parameter_property UAV_ADDRESS_W DISPLAY_NAME {Network address width}

add_parameter UAV_BURSTCOUNT_W INTEGER 4
set_parameter_property UAV_BURSTCOUNT_W AFFECTS_ELABORATION true
set_parameter_property UAV_BURSTCOUNT_W HDL_PARAMETER true
set_parameter_property UAV_BURSTCOUNT_W ALLOWED_RANGES "1:32000"
set_parameter_property UAV_BURSTCOUNT_W DESCRIPTION {Width of the burstcount signal - network side}
set_parameter_property UAV_BURSTCOUNT_W DISPLAY_NAME {Network burstcount width}

add_parameter AV_READLATENCY INTEGER 0
set_parameter_property AV_READLATENCY AFFECTS_ELABORATION true
set_parameter_property AV_READLATENCY HDL_PARAMETER true
set_parameter_property AV_READLATENCY ALLOWED_RANGES "0:32000"
set_parameter_property AV_READLATENCY DESCRIPTION {Avalon-MM readLatency interface property}
set_parameter_property AV_READLATENCY DISPLAY_NAME {readLatency}
add_display_item "" unitsBlurb text "<html><b>Read Latency parameterizable in units of cycles only.</b>"

add_parameter AV_SETUP_WAIT INTEGER 0
set_parameter_property AV_SETUP_WAIT AFFECTS_ELABORATION true
set_parameter_property AV_SETUP_WAIT HDL_PARAMETER false
set_parameter_property AV_SETUP_WAIT ALLOWED_RANGES "0:32000"

add_parameter AV_WRITE_WAIT INTEGER 0
set_parameter_property AV_WRITE_WAIT AFFECTS_ELABORATION true
set_parameter_property AV_WRITE_WAIT HDL_PARAMETER false
set_parameter_property AV_WRITE_WAIT ALLOWED_RANGES "0:32000"

add_parameter AV_READ_WAIT INTEGER 1
set_parameter_property AV_READ_WAIT AFFECTS_ELABORATION true
set_parameter_property AV_READ_WAIT HDL_PARAMETER false
set_parameter_property AV_READ_WAIT ALLOWED_RANGES "0:32000"

add_parameter AV_DATA_HOLD INTEGER 0
set_parameter_property AV_DATA_HOLD AFFECTS_ELABORATION true
set_parameter_property AV_DATA_HOLD HDL_PARAMETER false
set_parameter_property AV_DATA_HOLD ALLOWED_RANGES "0:32000"

add_parameter AV_TIMING_UNITS INTEGER 1
set_parameter_property AV_TIMING_UNITS AFFECTS_ELABORATION true
set_parameter_property AV_TIMING_UNITS HDL_PARAMETER false
set_parameter_property AV_TIMING_UNITS ALLOWED_RANGES {1:Cycles 0:Nanoseconds}
set_parameter_property AV_TIMING_UNITS DESCRIPTION {Timing in cycles or nanoseconds}
set_parameter_property AV_TIMING_UNITS DISPLAY_NAME {Timing units}

add_parameter USE_READDATA INTEGER 1
set_parameter_property USE_READDATA AFFECTS_ELABORATION true
set_parameter_property USE_READDATA HDL_PARAMETER false
set_parameter_property USE_READDATA DISPLAY_HINT boolean

add_parameter USE_WRITEDATA INTEGER 1
set_parameter_property USE_WRITEDATA AFFECTS_ELABORATION true
set_parameter_property USE_WRITEDATA HDL_PARAMETER false
set_parameter_property USE_WRITEDATA DISPLAY_HINT boolean
set_parameter_property USE_WRITEDATA DESCRIPTION {Enable the writedata signal}
set_parameter_property USE_WRITEDATA DISPLAY_NAME {Use writedata}

add_parameter USE_READ INTEGER 1
set_parameter_property USE_READ AFFECTS_ELABORATION true
set_parameter_property USE_READ HDL_PARAMETER false
set_parameter_property USE_READ DISPLAY_HINT boolean

add_parameter USE_WRITE INTEGER 1
set_parameter_property USE_WRITE AFFECTS_ELABORATION true
set_parameter_property USE_WRITE HDL_PARAMETER false
set_parameter_property USE_WRITE DISPLAY_HINT boolean

add_parameter USE_BEGINBURSTTRANSFER INTEGER 1
set_parameter_property USE_BEGINBURSTTRANSFER AFFECTS_ELABORATION true
set_parameter_property USE_BEGINBURSTTRANSFER HDL_PARAMETER false
set_parameter_property USE_BEGINBURSTTRANSFER DISPLAY_HINT boolean
set_parameter_property USE_BEGINBURSTTRANSFER DESCRIPTION {Enable the beginbursttransfer signal}
set_parameter_property USE_BEGINBURSTTRANSFER DISPLAY_NAME {Use beginbursttransfer}

add_parameter USE_BEGINTRANSFER INTEGER 1
set_parameter_property USE_BEGINTRANSFER AFFECTS_ELABORATION true
set_parameter_property USE_BEGINTRANSFER HDL_PARAMETER false
set_parameter_property USE_BEGINTRANSFER DISPLAY_HINT boolean
set_parameter_property USE_BEGINTRANSFER DESCRIPTION {Enable the begintransfer signal}
set_parameter_property USE_BEGINTRANSFER DISPLAY_NAME {Use begintransfer}

add_parameter USE_BYTEENABLE INTEGER 1
set_parameter_property USE_BYTEENABLE AFFECTS_ELABORATION true
set_parameter_property USE_BYTEENABLE HDL_PARAMETER false
set_parameter_property USE_BYTEENABLE DISPLAY_HINT boolean
set_parameter_property USE_BYTEENABLE DESCRIPTION {Enable the byteenable signal}
set_parameter_property USE_BYTEENABLE DISPLAY_NAME {Use byteenable}

add_parameter USE_CHIPSELECT INTEGER 0
set_parameter_property USE_CHIPSELECT AFFECTS_ELABORATION true
set_parameter_property USE_CHIPSELECT HDL_PARAMETER false
set_parameter_property USE_CHIPSELECT DISPLAY_HINT boolean
set_parameter_property USE_CHIPSELECT DESCRIPTION {Enable the chipselect signal}
set_parameter_property USE_CHIPSELECT DISPLAY_NAME {Use chipselect}

add_parameter USE_ADDRESS INTEGER 1
set_parameter_property USE_ADDRESS AFFECTS_ELABORATION true
set_parameter_property USE_ADDRESS HDL_PARAMETER false
set_parameter_property USE_ADDRESS DISPLAY_HINT boolean
set_parameter_property USE_ADDRESS DESCRIPTION {Enable the address signal}
set_parameter_property USE_ADDRESS DISPLAY_NAME {Use address}

add_parameter USE_BURSTCOUNT INTEGER 1
set_parameter_property USE_BURSTCOUNT AFFECTS_ELABORATION true
set_parameter_property USE_BURSTCOUNT HDL_PARAMETER false
set_parameter_property USE_BURSTCOUNT DISPLAY_HINT boolean
set_parameter_property USE_BURSTCOUNT DESCRIPTION {Enable the burstcount signal}
set_parameter_property USE_BURSTCOUNT DISPLAY_NAME {Use burstcount}

add_parameter USE_READDATAVALID INTEGER 1
set_parameter_property USE_READDATA DESCRIPTION {Enable the readdata signal}
set_parameter_property USE_READDATA DISPLAY_NAME {Use readdata}
set_parameter_property USE_READ DESCRIPTION {Enable the read signal}
set_parameter_property USE_READ DISPLAY_NAME {Use read}
set_parameter_property USE_READDATAVALID AFFECTS_ELABORATION true
set_parameter_property USE_READDATAVALID HDL_PARAMETER true
set_parameter_property USE_READDATAVALID DISPLAY_HINT boolean
set_parameter_property USE_READDATAVALID DESCRIPTION {Enable the readdatavalid signal}
set_parameter_property USE_READDATAVALID DISPLAY_NAME {Use readdatavalid}

add_parameter USE_WAITREQUEST INTEGER 1
set_parameter_property USE_WAITREQUEST AFFECTS_ELABORATION true
set_parameter_property USE_WAITREQUEST HDL_PARAMETER true
set_parameter_property USE_WAITREQUEST DISPLAY_HINT boolean
set_parameter_property USE_WAITREQUEST DESCRIPTION {Enable the waitrequest signal}
set_parameter_property USE_WAITREQUEST DISPLAY_NAME {Use waitrequest}

add_parameter USE_WRITEBYTEENABLE INTEGER 0
set_parameter_property USE_WRITE DESCRIPTION {Enable the write signal}
set_parameter_property USE_WRITE DISPLAY_NAME {Use write}
set_parameter_property USE_WRITEBYTEENABLE AFFECTS_ELABORATION true
set_parameter_property USE_WRITEBYTEENABLE HDL_PARAMETER false
set_parameter_property USE_WRITEBYTEENABLE DISPLAY_HINT boolean
set_parameter_property USE_WRITEBYTEENABLE DESCRIPTION {Enable the writebyteenable signal}
set_parameter_property USE_WRITEBYTEENABLE DISPLAY_NAME {Use writebyteenable}

add_parameter USE_LOCK INTEGER 0
set_parameter_property USE_LOCK AFFECTS_ELABORATION true
set_parameter_property USE_LOCK HDL_PARAMETER false
set_parameter_property USE_LOCK DISPLAY_HINT boolean
set_parameter_property USE_LOCK DESCRIPTION {Enable the lock signal}
set_parameter_property USE_LOCK DISPLAY_NAME {Use lock}

add_parameter USE_AV_CLKEN INTEGER 0
set_parameter_property USE_AV_CLKEN AFFECTS_ELABORATION true
set_parameter_property USE_AV_CLKEN HDL_PARAMETER false
set_parameter_property USE_AV_CLKEN DISPLAY_HINT boolean
set_parameter_property USE_AV_CLKEN DESCRIPTION {Enable the clken signal - component side}
set_parameter_property USE_AV_CLKEN DISPLAY_NAME {Use component clken}

add_parameter USE_UAV_CLKEN INTEGER 0
set_parameter_property USE_UAV_CLKEN AFFECTS_ELABORATION true
set_parameter_property USE_UAV_CLKEN HDL_PARAMETER true
set_parameter_property USE_UAV_CLKEN DISPLAY_HINT boolean
set_parameter_property USE_UAV_CLKEN DESCRIPTION {Enable the clken signal - network side}
set_parameter_property USE_UAV_CLKEN DISPLAY_NAME {Use network clken}

add_parameter USE_OUTPUTENABLE INTEGER 0
set_parameter_property USE_OUTPUTENABLE AFFECTS_ELABORATION true
set_parameter_property USE_OUTPUTENABLE HDL_PARAMETER false
set_parameter_property USE_OUTPUTENABLE DISPLAY_HINT boolean
set_parameter_property USE_OUTPUTENABLE DESCRIPTION {Enable the outputenable signal}
set_parameter_property USE_OUTPUTENABLE DISPLAY_NAME {Use outputenable}

add_parameter USE_DEBUGACCESS INTEGER 0
set_parameter_property USE_DEBUGACCESS AFFECTS_ELABORATION true
set_parameter_property USE_DEBUGACCESS HDL_PARAMETER false
set_parameter_property USE_DEBUGACCESS DISPLAY_HINT boolean
set_parameter_property USE_DEBUGACCESS DESCRIPTION {Enable the debugaccess signal}
set_parameter_property USE_DEBUGACCESS DISPLAY_NAME {Use debugaccess}

add_parameter USE_READRESPONSE INTEGER 0
set_parameter_property USE_READRESPONSE AFFECTS_ELABORATION true
set_parameter_property USE_READRESPONSE HDL_PARAMETER true
set_parameter_property USE_READRESPONSE DISPLAY_HINT BOOLEAN
set_parameter_property USE_READRESPONSE DESCRIPTION {Enable the read response signal}
set_parameter_property USE_READRESPONSE DISPLAY_NAME {Use readresponse}

add_parameter USE_WRITERESPONSE INTEGER 0
set_parameter_property USE_WRITERESPONSE AFFECTS_ELABORATION true
set_parameter_property USE_WRITERESPONSE HDL_PARAMETER true
set_parameter_property USE_WRITERESPONSE DISPLAY_HINT BOOLEAN
set_parameter_property USE_WRITERESPONSE DESCRIPTION {Enable the write response signals}
set_parameter_property USE_WRITERESPONSE DISPLAY_NAME {Use writeresponse}

add_parameter AV_SYMBOLS_PER_WORD INTEGER 4
set_parameter_property AV_SYMBOLS_PER_WORD AFFECTS_ELABORATION true
set_parameter_property AV_SYMBOLS_PER_WORD HDL_PARAMETER true
set_parameter_property AV_SYMBOLS_PER_WORD ALLOWED_RANGES "1:32000"
set_parameter_property AV_SYMBOLS_PER_WORD DESCRIPTION {Number of symbols (bytes) per word}
set_parameter_property AV_SYMBOLS_PER_WORD DISPLAY_NAME {Symbols per word}

add_parameter AV_ADDRESS_SYMBOLS INTEGER 0
set_parameter_property AV_ADDRESS_SYMBOLS AFFECTS_ELABORATION true
set_parameter_property AV_ADDRESS_SYMBOLS HDL_PARAMETER true
set_parameter_property AV_ADDRESS_SYMBOLS ALLOWED_RANGES {"0:Words" "1:Symbols"}
set_parameter_property AV_ADDRESS_SYMBOLS DESCRIPTION {Addressing in units of symbols (bytes) or words}
set_parameter_property AV_ADDRESS_SYMBOLS DISPLAY_NAME {Address symbols}

add_parameter AV_BURSTCOUNT_SYMBOLS INTEGER 0
set_parameter_property AV_BURSTCOUNT_SYMBOLS AFFECTS_ELABORATION true
set_parameter_property AV_BURSTCOUNT_SYMBOLS HDL_PARAMETER true
set_parameter_property AV_BURSTCOUNT_SYMBOLS ALLOWED_RANGES {"0:Words" "1:Symbols"}
set_parameter_property AV_BURSTCOUNT_SYMBOLS DESCRIPTION {Burstcount in units of symbols (bytes) or words}
set_parameter_property AV_BURSTCOUNT_SYMBOLS DISPLAY_NAME {Burstcount symbols}

add_parameter AV_CONSTANT_BURST_BEHAVIOR INTEGER 0
set_parameter_property AV_CONSTANT_BURST_BEHAVIOR AFFECTS_ELABORATION true
set_parameter_property AV_CONSTANT_BURST_BEHAVIOR HDL_PARAMETER true
set_parameter_property AV_CONSTANT_BURST_BEHAVIOR DISPLAY_HINT boolean
set_parameter_property AV_CONSTANT_BURST_BEHAVIOR DESCRIPTION {Avalon-MM constantBurstBehavior interface property - component side}
set_parameter_property AV_CONSTANT_BURST_BEHAVIOR DISPLAY_NAME {Component constantBurstBehavior}

add_parameter UAV_CONSTANT_BURST_BEHAVIOR INTEGER 0
set_parameter_property UAV_CONSTANT_BURST_BEHAVIOR AFFECTS_ELABORATION true
set_parameter_property UAV_CONSTANT_BURST_BEHAVIOR HDL_PARAMETER true
set_parameter_property UAV_CONSTANT_BURST_BEHAVIOR DISPLAY_HINT boolean
set_parameter_property UAV_CONSTANT_BURST_BEHAVIOR DESCRIPTION {Avalon-MM constantBurstBehavior interface property - network side}
set_parameter_property UAV_CONSTANT_BURST_BEHAVIOR DISPLAY_NAME {Network constantBurstBehavior}

add_parameter AV_REQUIRE_UNALIGNED_ADDRESSES INTEGER 0
set_parameter_property AV_REQUIRE_UNALIGNED_ADDRESSES AFFECTS_ELABORATION false
set_parameter_property AV_REQUIRE_UNALIGNED_ADDRESSES HDL_PARAMETER true
set_parameter_property AV_REQUIRE_UNALIGNED_ADDRESSES DISPLAY_HINT boolean
set_parameter_property AV_REQUIRE_UNALIGNED_ADDRESSES DESCRIPTION {Convert to unaligned address according to byteenable}
set_parameter_property AV_REQUIRE_UNALIGNED_ADDRESSES DISPLAY_NAME {Unaligned addresses}

add_parameter AV_LINEWRAPBURSTS INTEGER 0
set_parameter_property AV_LINEWRAPBURSTS AFFECTS_ELABORATION true
set_parameter_property AV_LINEWRAPBURSTS HDL_PARAMETER false
set_parameter_property AV_LINEWRAPBURSTS DISPLAY_HINT boolean
set_parameter_property AV_LINEWRAPBURSTS DESCRIPTION {Avalon-MM linewrapBursts interface property}
set_parameter_property AV_LINEWRAPBURSTS DISPLAY_NAME {linewrapBursts}

add_parameter AV_MAX_PENDING_READ_TRANSACTIONS INTEGER 64
set_parameter_property AV_MAX_PENDING_READ_TRANSACTIONS AFFECTS_ELABORATION true
set_parameter_property AV_MAX_PENDING_READ_TRANSACTIONS HDL_PARAMETER false
set_parameter_property AV_MAX_PENDING_READ_TRANSACTIONS ALLOWED_RANGES "0:32000"
set_parameter_property AV_MAX_PENDING_READ_TRANSACTIONS DESCRIPTION {Avalon-MM maxPendingReadTransactions interface property}
set_parameter_property AV_MAX_PENDING_READ_TRANSACTIONS DISPLAY_NAME {maxPendingReadTransactions}

add_parameter AV_MAX_PENDING_WRITE_TRANSACTIONS INTEGER 0
set_parameter_property AV_MAX_PENDING_WRITE_TRANSACTIONS AFFECTS_ELABORATION true
set_parameter_property AV_MAX_PENDING_WRITE_TRANSACTIONS HDL_PARAMETER false
set_parameter_property AV_MAX_PENDING_WRITE_TRANSACTIONS ALLOWED_RANGES "0:32000"
set_parameter_property AV_MAX_PENDING_WRITE_TRANSACTIONS DESCRIPTION {Avalon-MM maxPendingWriteTransactions interface property}
set_parameter_property AV_MAX_PENDING_WRITE_TRANSACTIONS DISPLAY_NAME {maxPendingWriteTransactions}

add_parameter AV_BURSTBOUNDARIES INTEGER 0
set_parameter_property AV_BURSTBOUNDARIES AFFECTS_ELABORATION true
set_parameter_property AV_BURSTBOUNDARIES HDL_PARAMETER false
set_parameter_property AV_BURSTBOUNDARIES DISPLAY_HINT boolean
set_parameter_property AV_BURSTBOUNDARIES DESCRIPTION {Avalon-MM burstOnBurstBoundariesOnly interface property}
set_parameter_property AV_BURSTBOUNDARIES DISPLAY_NAME {burstOnBurstBoundariesOnly}

add_parameter AV_INTERLEAVEBURSTS INTEGER 0
set_parameter_property AV_INTERLEAVEBURSTS AFFECTS_ELABORATION true
set_parameter_property AV_INTERLEAVEBURSTS HDL_PARAMETER false
set_parameter_property AV_INTERLEAVEBURSTS DISPLAY_HINT boolean
set_parameter_property AV_INTERLEAVEBURSTS DESCRIPTION {Avalon-MM interleaveBursts interface property}
set_parameter_property AV_INTERLEAVEBURSTS DISPLAY_NAME {interleaveBursts}

add_parameter AV_BITS_PER_SYMBOL INTEGER 8
set_parameter_property AV_BITS_PER_SYMBOL AFFECTS_ELABORATION true
set_parameter_property AV_BITS_PER_SYMBOL HDL_PARAMETER false
set_parameter_property AV_BITS_PER_SYMBOL ALLOWED_RANGES "1:32000"
set_parameter_property AV_BITS_PER_SYMBOL DESCRIPTION {Bits per symbol (byte)}
set_parameter_property AV_BITS_PER_SYMBOL DISPLAY_NAME {Bits/symbol}

add_parameter AV_ISBIGENDIAN INTEGER 0
set_parameter_property AV_ISBIGENDIAN AFFECTS_ELABORATION true
set_parameter_property AV_ISBIGENDIAN HDL_PARAMETER false
set_parameter_property AV_ISBIGENDIAN DISPLAY_HINT boolean
set_parameter_property AV_ISBIGENDIAN DESCRIPTION {Avalon-MM isBigEndian interface property}
set_parameter_property AV_ISBIGENDIAN DISPLAY_NAME {isBigEndian}

add_parameter AV_ADDRESSGROUP INTEGER 0
set_parameter_property AV_ADDRESSGROUP AFFECTS_ELABORATION true
set_parameter_property AV_ADDRESSGROUP HDL_PARAMETER false
set_parameter_property AV_ADDRESSGROUP DESCRIPTION {Avalon-MM address group interface property - component side}
set_parameter_property AV_ADDRESSGROUP DISPLAY_NAME {Component address group}

add_parameter UAV_ADDRESSGROUP INTEGER 0
set_parameter_property UAV_ADDRESSGROUP AFFECTS_ELABORATION true
set_parameter_property UAV_ADDRESSGROUP HDL_PARAMETER false
set_parameter_property UAV_ADDRESSGROUP DESCRIPTION {Avalon-MM address group interface property - network side}
set_parameter_property UAV_ADDRESSGROUP DISPLAY_NAME {Network address group}

add_parameter AV_REGISTEROUTGOINGSIGNALS INTEGER 0
set_parameter_property AV_REGISTEROUTGOINGSIGNALS AFFECTS_ELABORATION true
set_parameter_property AV_REGISTEROUTGOINGSIGNALS HDL_PARAMETER false
set_parameter_property AV_REGISTEROUTGOINGSIGNALS DISPLAY_HINT boolean
set_parameter_property AV_REGISTEROUTGOINGSIGNALS DESCRIPTION {Avalon-MM registerOutgoingSignals interface property}
set_parameter_property AV_REGISTEROUTGOINGSIGNALS DISPLAY_NAME {registerOutgoingSignals}

add_parameter AV_REGISTERINCOMINGSIGNALS INTEGER 0
set_parameter_property AV_REGISTERINCOMINGSIGNALS AFFECTS_ELABORATION true
set_parameter_property AV_REGISTERINCOMINGSIGNALS HDL_PARAMETER false
set_parameter_property AV_REGISTERINCOMINGSIGNALS DISPLAY_HINT boolean
set_parameter_property AV_REGISTERINCOMINGSIGNALS DESCRIPTION {Avalon-MM registerIncomingSignals interface property}
set_parameter_property AV_REGISTERINCOMINGSIGNALS DISPLAY_NAME {registerIncomingSignals}

add_parameter AV_ALWAYSBURSTMAXBURST INTEGER 0
set_parameter_property AV_ALWAYSBURSTMAXBURST AFFECTS_ELABORATION true
set_parameter_property AV_ALWAYSBURSTMAXBURST HDL_PARAMETER false
set_parameter_property AV_ALWAYSBURSTMAXBURST DISPLAY_HINT boolean
set_parameter_property AV_ALWAYSBURSTMAXBURST DESCRIPTION {Avalon-MM alwaysBurstMaxBurst interface property}
set_parameter_property AV_ALWAYSBURSTMAXBURST DISPLAY_NAME {Always burst max-burst}

add_parameter CHIPSELECT_THROUGH_READLATENCY INTEGER 0
set_parameter_property CHIPSELECT_THROUGH_READLATENCY AFFECTS_ELABORATION true
set_parameter_property CHIPSELECT_THROUGH_READLATENCY HDL_PARAMETER true
set_parameter_property CHIPSELECT_THROUGH_READLATENCY DISPLAY_HINT boolean
set_parameter_property CHIPSELECT_THROUGH_READLATENCY DESCRIPTION {Assert chipselect while readdata is pending}
set_parameter_property CHIPSELECT_THROUGH_READLATENCY DISPLAY_NAME {Chipselect through read latency}

add_parameter CLOCK_RATE LONG 1
set_parameter_property CLOCK_RATE AFFECTS_ELABORATION true
set_parameter_property CLOCK_RATE HDL_PARAMETER false
set_parameter_property CLOCK_RATE SYSTEM_INFO "CLOCK_RATE clk"
set_parameter_property CLOCK_RATE VISIBLE false

add_parameter AV_READ_WAIT_CYCLES INTEGER 0
set_parameter_property AV_READ_WAIT DESCRIPTION {Avalon-MM readWaitTime interface property}
set_parameter_property AV_READ_WAIT DISPLAY_NAME {readWaitTime}
set_parameter_property AV_READ_WAIT_CYCLES DERIVED true
set_parameter_property AV_READ_WAIT_CYCLES HDL_PARAMETER true
set_parameter_property AV_READ_WAIT_CYCLES VISIBLE false

add_parameter AV_WRITE_WAIT_CYCLES INTEGER 0
set_parameter_property AV_WRITE_WAIT DESCRIPTION {Avalon-MM writeWaitTime interface property}
set_parameter_property AV_WRITE_WAIT DISPLAY_NAME {writeWaitTime}
set_parameter_property AV_WRITE_WAIT_CYCLES DERIVED true
set_parameter_property AV_WRITE_WAIT_CYCLES HDL_PARAMETER true
set_parameter_property AV_WRITE_WAIT_CYCLES VISIBLE false

add_parameter AV_SETUP_WAIT_CYCLES INTEGER 0
set_parameter_property AV_SETUP_WAIT DESCRIPTION {Avalon-MM setupTime interface property}
set_parameter_property AV_SETUP_WAIT DISPLAY_NAME {setupTime}
set_parameter_property AV_SETUP_WAIT_CYCLES DERIVED true
set_parameter_property AV_SETUP_WAIT_CYCLES HDL_PARAMETER true
set_parameter_property AV_SETUP_WAIT_CYCLES VISIBLE false

add_parameter AV_DATA_HOLD_CYCLES INTEGER 0
set_parameter_property AV_DATA_HOLD DESCRIPTION {Hold time}
set_parameter_property AV_DATA_HOLD DISPLAY_NAME {Hold time}
set_parameter_property AV_DATA_HOLD_CYCLES DERIVED true
set_parameter_property AV_DATA_HOLD_CYCLES HDL_PARAMETER true
set_parameter_property AV_DATA_HOLD_CYCLES VISIBLE false

# | 
# +-----------------------------------
# +-----------------------------------
# | Set all parameters to AFFECTS_GENERATION false
# | 
foreach parameter [get_parameters] { 
	set_parameter_property $parameter AFFECTS_GENERATION false 
 }
# | 
# +-----------------------------------

# +-----------------------------------
# | connection points clk and reset
# | 
add_interface clk clock end
add_interface_port clk clk clk Input 1

add_interface reset reset end
add_interface_port reset reset reset Input 1
set_interface_property reset ASSOCIATED_CLOCK clk
# | 
# +-----------------------------------


# +-----------------------------------
# | connection points uav_ and av_
# |
add_interface avalon_universal_slave_0 avalon slave clk
set_interface_property avalon_universal_slave_0 ASSOCIATED_CLOCK clk
set_interface_property avalon_universal_slave_0 associatedReset reset

add_interface avalon_anti_slave_0 avalon master clk
set_interface_property avalon_anti_slave_0 ASSOCIATED_CLOCK clk
set_interface_property avalon_anti_slave_0 associatedReset reset
# |
# +-----------------------------------   


add_fileset synthesis_fileset QUARTUS_SYNTH synth_callback_procedure
set_fileset_property synthesis_fileset TOP_LEVEL altera_merlin_slave_translator 
add_fileset simulation_fileset SIM_VERILOG synth_callback_procedure
set_fileset_property simulation_fileset TOP_LEVEL altera_merlin_slave_translator
add_fileset vhdl_fileset SIM_VHDL synth_callback_procedure_vhdl
set_fileset_property vhdl_fileset TOP_LEVEL altera_merlin_slave_translator

proc synth_callback_procedure { entity_name } {
    add_fileset_file altera_merlin_slave_translator.sv SYSTEM_VERILOG PATH "altera_merlin_slave_translator.sv"
}

proc synth_callback_procedure_vhdl { entity_name } {
   if {1} {
      add_fileset_file mentor/altera_merlin_slave_translator.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_merlin_slave_translator.sv" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_merlin_slave_translator.sv SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_merlin_slave_translator.sv" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_merlin_slave_translator.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_merlin_slave_translator.sv" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_merlin_slave_translator.sv SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_merlin_slave_translator.sv" {SYNOPSYS_SPECIFIC}
   }    
}

proc convertToCycles { num } {
    set clock_rate [get_parameter_value CLOCK_RATE]

    if { $clock_rate != 0 } { 
	set clock_period [expr 1.0 / $clock_rate]
    
	#Convert to ns
	set clock_period [expr $clock_period * 1000000000]
	
	set numCycles [expr $num / $clock_period]
	return [expr ceil($numCycles) ]
    }

    return $num
}

proc elaborate {} {

    set setup_wait [get_parameter_value AV_SETUP_WAIT]
    set read_wait  [get_parameter_value AV_READ_WAIT]
    set write_wait [get_parameter_value AV_WRITE_WAIT]
    set data_hold  [get_parameter_value AV_DATA_HOLD]

    set units [get_parameter_value AV_TIMING_UNITS]
    if { $units == 1 } {
	set units cycles
    } else {
	set units nanoseconds
	
	set setup_wait [convertToCycles $setup_wait]
	set read_wait  [convertToCycles $read_wait]
	set write_wait [convertToCycles $write_wait]
	set data_hold  [convertToCycles $data_hold]
    }

    set_parameter_value AV_SETUP_WAIT_CYCLES $setup_wait
    set_parameter_value AV_READ_WAIT_CYCLES $read_wait
    set_parameter_value AV_WRITE_WAIT_CYCLES $write_wait
    set_parameter_value AV_DATA_HOLD_CYCLES $data_hold


#Declare the agent-side universal avalon interface
    add_interface_port  avalon_universal_slave_0  uav_address             address            input  [ get_parameter_value UAV_ADDRESS_W ]
    set_port_property uav_address vhdl_type std_logic_vector

    add_interface_port  avalon_universal_slave_0  uav_burstcount          burstcount         input  [ get_parameter_value UAV_BURSTCOUNT_W ]
    set_port_property uav_burstcount vhdl_type std_logic_vector

    add_interface_port  avalon_universal_slave_0  uav_read                read               input  1
    add_interface_port  avalon_universal_slave_0  uav_write               write              input  1
    add_interface_port  avalon_universal_slave_0  uav_waitrequest         waitrequest        output 1
    add_interface_port  avalon_universal_slave_0  uav_readdatavalid       readdatavalid      output 1

    add_interface_port  avalon_universal_slave_0  uav_byteenable          byteenable         input  [ get_parameter_value UAV_BYTEENABLE_W ]
    set_port_property uav_byteenable vhdl_type std_logic_vector

    add_interface_port  avalon_universal_slave_0  uav_readdata            readdata           output [ get_parameter_value UAV_DATA_W ]
    set_port_property uav_readdata vhdl_type std_logic_vector
    
    add_interface_port  avalon_universal_slave_0  uav_writedata           writedata          input  [ get_parameter_value UAV_DATA_W ]
    set_port_property uav_writedata vhdl_type std_logic_vector

    add_interface_port  avalon_universal_slave_0  uav_lock                lock               input  1
    add_interface_port  avalon_universal_slave_0  uav_debugaccess         debugaccess        input  1
    
    set_interface_property avalon_universal_slave_0 addressGroup [ get_parameter_value UAV_ADDRESSGROUP ]
    set_interface_property avalon_universal_slave_0 readLatency 0
    set_interface_property avalon_universal_slave_0 readWaitTime 0
    set_interface_property avalon_universal_slave_0 setupTime 0
    set_interface_property avalon_universal_slave_0 holdTime 0
    set_interface_property avalon_universal_slave_0 writeWaitTime 0
    set_interface_property avalon_universal_slave_0 timingUnits cycles
    set_interface_property avalon_universal_slave_0 maximumPendingReadTransactions [get_parameter_value AV_MAX_PENDING_READ_TRANSACTIONS]
	set_interface_property avalon_universal_slave_0 maximumPendingWriteTransactions [get_parameter_value AV_MAX_PENDING_WRITE_TRANSACTIONS]
    set_interface_property avalon_universal_slave_0 constantBurstBehavior 0
    set_interface_property avalon_universal_slave_0 linewrapBursts [ get_parameter_value AV_LINEWRAPBURSTS ]
    set_interface_property avalon_universal_slave_0 bitsPerSymbol [get_parameter_value AV_BITS_PER_SYMBOL]
    set_interface_property avalon_universal_slave_0 burstcountUnits SYMBOLS
    set_interface_property avalon_universal_slave_0 addressUnits SYMBOLS
    set_interface_property avalon_universal_slave_0 addressAlignment DYNAMIC
  
    set use_addr           [ get_parameter_value USE_ADDRESS ]
    set addr_w             [ get_parameter_value AV_ADDRESS_W ]
    set num_symbols        [get_parameter_value AV_SYMBOLS_PER_WORD]
    set address_symbols    [get_parameter_value AV_ADDRESS_SYMBOLS]
    set explicitSpan [get_explicit_span $use_addr $addr_w $num_symbols $address_symbols]
    set_interface_property avalon_universal_slave_0 explicitAddressSpan $explicitSpan

    #Declare the slave-side customizable avalon interface
    
    set_interface_property avalon_anti_slave_0 interleaveBursts [ get_parameter_value AV_INTERLEAVEBURSTS ]
    set_interface_property avalon_anti_slave_0 burstOnBurstBoundariesOnly [ get_parameter_value AV_BURSTBOUNDARIES ]
    set_interface_property avalon_anti_slave_0 isBigEndian [ get_parameter_value AV_ISBIGENDIAN ]
    set_interface_property avalon_anti_slave_0 addressGroup [ get_parameter_value UAV_ADDRESSGROUP ]
    set_interface_property avalon_anti_slave_0 registerOutgoingSignals [ get_parameter_value AV_REGISTEROUTGOINGSIGNALS ]
    set_interface_property avalon_anti_slave_0 registerIncomingSignals [ get_parameter_value AV_REGISTERINCOMINGSIGNALS ]
    set_interface_property avalon_anti_slave_0 alwaysBurstMaxBurst [ get_parameter_value AV_ALWAYSBURSTMAXBURST ]
    set_interface_property avalon_anti_slave_0 linewrapBursts [ get_parameter_value AV_LINEWRAPBURSTS ]
    set_interface_property avalon_anti_slave_0 readLatency [ get_parameter_value AV_READLATENCY ]
    set_interface_property avalon_anti_slave_0 readWaitTime [ get_parameter_value AV_READ_WAIT ]
    set_interface_property avalon_anti_slave_0 setupTime [ get_parameter_value AV_SETUP_WAIT ]
    set_interface_property avalon_anti_slave_0 holdTime [ get_parameter_value AV_DATA_HOLD ]
    set_interface_property avalon_anti_slave_0 writeWaitTime [ get_parameter_value AV_WRITE_WAIT ]
    set_interface_property avalon_anti_slave_0 timingUnits $units
    set_interface_property avalon_anti_slave_0 maximumPendingReadTransactions [ expr [get_parameter_value AV_MAX_PENDING_READ_TRANSACTIONS] * [get_parameter_value USE_READDATAVALID ] ]
	set_interface_property avalon_anti_slave_0 maximumPendingWriteTransactions [ expr [get_parameter_value AV_MAX_PENDING_WRITE_TRANSACTIONS] * [get_parameter_value USE_WRITERESPONSE ] ]
    set_interface_property avalon_anti_slave_0 constantBurstBehavior [get_parameter_value AV_CONSTANT_BURST_BEHAVIOR]
    set_interface_property avalon_anti_slave_0 bitsPerSymbol [get_parameter_value AV_BITS_PER_SYMBOL]

    set addressUnits "SYMBOLS"
    set burstcountUnits "SYMBOLS"
    if { [ get_parameter_value AV_ADDRESS_SYMBOLS ] == 0 } {
        set addressUnits "WORDS"
    }
    if { [ get_parameter_value AV_BURSTCOUNT_SYMBOLS ] == 0 } {
        set burstcountUnits "WORDS"
    }
    set_interface_property avalon_anti_slave_0 addressUnits $addressUnits
    set_interface_property avalon_anti_slave_0 burstcountUnits $burstcountUnits
    
    # ----------------
    # Address
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_address address output [ get_parameter_value AV_ADDRESS_W ]
    set_port_property av_address vhdl_type std_logic_vector
    
    if { [get_parameter_value USE_ADDRESS] == 0 } {
	set_port_property av_address termination true
    }
    
    # ----------------
    # Write
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_write write output 1
    
    if { [get_parameter_value USE_WRITE] == 0 } {
	set_port_property av_write termination true
    }
    
    # ----------------
    # Read
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_read read output 1
    
    if { [get_parameter_value USE_READ] == 0 } {
	set_port_property av_read termination true
    }
    
    # ----------------
    # Readdata
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_readdata readdata input [ get_parameter_value AV_DATA_W ]
    set_port_property av_readdata vhdl_type std_logic_vector
    
    if { [ get_parameter_value USE_READDATA ] ==  0 } {
	set_port_property av_readdata termination true
	set_port_property av_readdata termination_value 0xDEADDEAD
    }
    
    # ----------------
    # Writedata
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_writedata writedata output [ get_parameter_value AV_DATA_W ]
    set_port_property av_writedata vhdl_type std_logic_vector
    if { [ get_parameter_value USE_WRITEDATA ] ==  0 } {
	set_port_property av_writedata termination true
    } else {
        # Require universal-avalon writedata width >= avalon writedata width
        set uav_data_w [ get_parameter_value UAV_DATA_W ]
        set av_data_w [ get_parameter_value AV_DATA_W ]
        if { $uav_data_w < $av_data_w } {
            send_message error "UAV_DATA_W ($uav_data) must be >= AV_DATA_W ($av_data_w)"
        }
    }
    
    # ----------------
    # Begintransfer
    # ----------------
    
    
    add_interface_port avalon_anti_slave_0 av_begintransfer begintransfer output 1
    if { [ get_parameter_value USE_BEGINTRANSFER ] ==  0} {
	set_port_property av_begintransfer termination true
    }
    
    # ----------------
    # Beginbursttransfer
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_beginbursttransfer beginbursttransfer output 1
    if { [ get_parameter_value USE_BEGINBURSTTRANSFER ] ==  0 } {
	set_port_property av_beginbursttransfer termination true
    }
    
    # ----------------
    # Burstcount
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_burstcount burstcount output [ get_parameter_value AV_BURSTCOUNT_W ]
    set_port_property av_burstcount vhdl_type std_logic_vector
    if { [ get_parameter_value USE_BURSTCOUNT ] ==  0 } {
	set_port_property av_burstcount termination true
    }
    
    # ----------------
    # Byteenable
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_byteenable byteenable output [ get_parameter_value AV_BYTEENABLE_W ]
    set_port_property av_byteenable vhdl_type std_logic_vector 
    if { [ get_parameter_value USE_BYTEENABLE ] ==  0 } {
	set_port_property av_byteenable termination true
    } else {
        # Require universal-avalon byteenable width >= avalon byteenable width
        set uav_byteenable_w [ get_parameter_value UAV_BYTEENABLE_W ] 
        set av_byteenable_w [ get_parameter_value AV_BYTEENABLE_W ]
        if { $uav_byteenable_w < $av_byteenable_w } {
            send_message error "UAV_BYTEENABLE_W ($uav_byteenable_w) must be >= AV_BYTEENABLE_W ($av_byteenable_w)"
        }
    }
 
    # ----------------
    # Readdatavalid
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_readdatavalid readdatavalid input 1
    if { [ get_parameter_value USE_READDATAVALID ] ==  0 } {
	set_port_property av_readdatavalid termination true
	set_port_property av_readdatavalid termination_value 0
    }
    
    # ----------------
    # Waitrequest
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_waitrequest waitrequest input 1
    if { [get_parameter_value USE_WAITREQUEST] == 0 } {
	set_port_property av_waitrequest termination true
    }    

    # ----------------
    # Writebyteenable
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_writebyteenable writebyteenable output [ get_parameter_value AV_BYTEENABLE_W ]
    set_port_property av_writebyteenable vhdl_type std_logic_vector
    if { [get_parameter_value USE_WRITEBYTEENABLE] == 0 } {
	set_port_property av_writebyteenable termination true
    }

    # ----------------
    # lock
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_lock lock output 1
    if { [get_parameter_value USE_LOCK] == 0 } {
	set_port_property av_lock termination true
    }
    
    # ----------------
    # Chipselect
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_chipselect chipselect output 1
    if { [ get_parameter_value USE_CHIPSELECT ] ==  0 } {
	set_port_property av_chipselect termination true
    }       
    # ----------------
    # Clken
    # ----------------
    add_interface_port avalon_anti_slave_0 av_clken clken output 1
    add_interface_port avalon_universal_slave_0 uav_clken clken input 1

    set use_av_clken  [ get_parameter_value USE_AV_CLKEN ] 
    set use_uav_clken [ get_parameter_value USE_UAV_CLKEN ]
    if { $use_av_clken ==  0 } {
        set_port_property av_clken termination true
    } 
    if { $use_uav_clken == 0 } {
        set_port_property uav_clken termination true
    }

    # ----------------
    # Debugaccess
    # ----------------
    add_interface_port avalon_anti_slave_0 av_debugaccess debugaccess output 1
    if { [ get_parameter_value USE_DEBUGACCESS ] ==  0 } {
        set_port_property av_debugaccess termination true
    }    

    # ---------------
    # Outputenable
    # ----------------
    
    add_interface_port avalon_anti_slave_0 av_outputenable outputenable output 1
    
    if { [get_parameter_value USE_OUTPUTENABLE] == 0 } {
	set_port_property av_outputenable termination true
    } 
	
	# ----------------
    # Readresponse
    #
    # This signal is optional on anti master interface
    # ----------------
    add_interface_port avalon_universal_slave_0 uav_response response Output 2
    add_interface_port avalon_anti_slave_0 av_response  response Input 2
    if { ([ get_parameter_value USE_READRESPONSE ] == 0) && ([ get_parameter_value USE_WRITERESPONSE ] == 0) } {
        set_port_property av_response termination true
        set_port_property av_response termination_value 0
		set_port_property uav_response termination true
		set_port_property uav_response termination_value 0
    }

	# ----------------
    # Write response: 
    #
    # This signal is optional on anti master interface
    # ----------------
	add_interface_port avalon_universal_slave_0 uav_writeresponserequest writeresponserequest Input 1
	add_interface_port avalon_universal_slave_0 uav_writeresponsevalid writeresponsevalid Output 1
	add_interface_port avalon_anti_slave_0 av_writeresponserequest writeresponserequest Output 1
	add_interface_port avalon_anti_slave_0 av_writeresponsevalid writeresponsevalid Input 1
	if { [ get_parameter_value USE_WRITERESPONSE ] == 0 } {
		set_port_property av_writeresponserequest termination true
        set_port_property av_writeresponserequest termination_value 0
		set_port_property av_writeresponsevalid termination true
        set_port_property av_writeresponsevalid termination_value 0
		set_port_property uav_writeresponserequest termination true
        set_port_property uav_writeresponserequest termination_value 0
		set_port_property uav_writeresponsevalid termination true
        set_port_property uav_writeresponsevalid termination_value 0
    }
    set_interface_assignment avalon_universal_slave_0 merlin.flow.avalon_anti_slave_0 avalon_anti_slave_0
}
