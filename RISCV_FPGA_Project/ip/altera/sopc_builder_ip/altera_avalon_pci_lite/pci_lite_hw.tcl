#:if expand("%") == ""|browse confirm w|else|confirm w|endif
######################
#PCI ComPiler Lite 1.0
#######################

set_module_property "author"  "Altera Corporation"
set_module_property "version" "13.1"
set_module_property "datasheetURL" "http://www.altera.com/literature/hb/nios2/qts_qii55010.pdf"
set_module_property "Name" "pci_lite"
set_module_property "displayName" "PCI Lite"
set_module_property "group" "Interface Protocols/PCI"
set_module_property "instantiateInSystemModule" "true"
set_module_property TOP_LEVEL_HDL_FILE pci_lite.v
set_module_property TOP_LEVEL_HDL_MODULE pci_lite
set_module_property EDITABLE false
set_module_property HIDE_FROM_QSYS true

set_module_property "synthesisFiles"   "altpciav_lite.v altpciav_lite_a2p_addrtrans.v altpciav_lite_a2p_fixtrans.v altpciav_lite_a2p_vartrans.v altpciav_lite_control_register.v altpciav_lite_cr_avalon.v altpciav_lite_fifo.v altpciav_lite_master.v altpciav_lite_mavl_cntrl.v altpciav_lite_mcd.v altpciav_lite_mpci_cntrl.v altpciav_lite_p2a_addrtrans.v altpciav_lite_pba.v altpciav_lite_pba_avl.v altpciav_lite_pba_loc.v altpciav_lite_pba_rdresp.v altpciav_lite_pba_wrfifo.v pci_lite.v pcimt32_dp.v pcit32_dp.v pcimt32.inc pcit32.inc pci_mt32.tdf pci_t32.tdf pcimt32_adce.tdf pcimt32_c.tdf pcimt32_cd.tdf pcimt32_m.tdf pcimt32_pg.tdf pcimt32_pk.tdf pcimt32_sr.tdf pcimt32_t.tdf pcit32_adce.tdf pcit32_c.tdf pcit32_cd.tdf pcit32_pg.tdf pcit32_pk.tdf pcit32_sr.tdf pcit32_t.tdf"

set_module_property "simulationModelInVerilog" "true"
set_module_property "simulationFiles" "pci_sim/verilog/pci_lite/arbiter.v
                     pci_sim/verilog/pci_lite/clk_gen.v 
                     pci_sim/verilog/pci_lite/monitor.v 
                     pci_sim/verilog/pci_lite/pci_tb.v 
                     pci_sim/verilog/pci_lite/pull_up.v 
                     pci_sim/verilog/pci_lite/trgt_tranx.v" 

# Module parameters
add_parameter "MASTER_ENABLE" "boolean" "0" "Enable PCI Master/Target - set (1). Enable Target-Only - set (0)."
add_parameter "MASTER_HOST_BRIDGE" "boolean" "0" "To enable Host-bridge functionality in PCI Master/Target Megacore function - set (1) . "
add_parameter "PCI_MASTER_ADDR_MAP_NUM_ENTRIES" "integer" "4" "Number Of Address tranlation Entries"
add_parameter "PCI_MASTER_ADDR_MAP_PASS_THRU_BITS" "integer" "14" "Memory size of the Translation table"
add_parameter "BAR_PREFETCHABLE" "boolean" "0" "Prefetchable BAR Enable"
add_parameter "BAR_PREFETCHABLE_SIZE" "integer" "20" "Prefetchable Memory BAR Size"
add_parameter "BAR_PREFETCHABLE_AV_ADDR_TRANS" "integer" "0000" "Avalon address translation offset."
add_parameter "BAR_NONPREFETCHABLE" "boolean" "0" "Non-Prefetchable BAR Enable"
add_parameter "BAR_NONPREFETCHABLE_SIZE" "integer" "20" "Non-Prefetchable Memory BAR Size"
add_parameter "BAR_NONPREFETCHABLE_AV_ADDR_TRANS" "integer" "0000" "Avalon address translation offset"
add_parameter "BAR_IO" "boolean" "0" "IO BAR Enable"
add_parameter "BAR_IO_SIZE" "integer" "7" "IO BAR Size"
add_parameter "BAR_IO_AV_ADDR_TRANS" "integer" "0000" "Avalon address translation offset"
add_parameter "MAX_READ_DWORDS_BURST" "integer" "8" "Maximum Read burst per transaction"
add_parameter "CONF_DEVICE_ID" "integer"  "16'h0004" ""
add_parameter "CONF_VEND_ID" "integer" "16'h1172" ""
add_parameter "CONF_CLASS_CODE" "integer"  "24'hff0000" ""
add_parameter "CONF_REVISION_ID" "integer"  "8'h01" ""
add_parameter "CONF_SUBSYSTEM_ID" "integer" "16'h0000" ""
add_parameter "CONF_SUBSYSTEM_VEND_ID" "integer" "16'h0000" ""
add_parameter "CONF_MAX_LATENCY" "integer"  "8'h00" ""
add_parameter "CONF_MIN_GRANT" "integer" "8'h00" ""

set_parameter_property "BAR_PREFETCHABLE_AV_ADDR_TRANS" "units" "Address"
set_parameter_property "BAR_NONPREFETCHABLE_AV_ADDR_TRANS" "units" "Address"
set_parameter_property "BAR_IO_AV_ADDR_TRANS" "units" "Address"
set_parameter_property "CONF_DEVICE_ID" "units" "Address"
set_parameter_property "CONF_CLASS_CODE" "units" "Address"
set_parameter_property "CONF_MAX_LATENCY" "units" "Address"
set_parameter_property "CONF_MIN_GRANT" "units" "Address"
set_parameter_property "CONF_REVISION_ID" "units" "Address"
set_parameter_property "CONF_SUBSYSTEM_ID" "units" "Address"
set_parameter_property "CONF_SUBSYSTEM_VEND_ID" "units" "Address"
set_parameter_property "CONF_VEND_ID" "units" "Address"
set_parameter_property BAR_PREFETCHABLE_SIZE ALLOWED_RANGES {10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31}
set_parameter_property BAR_NONPREFETCHABLE_SIZE ALLOWED_RANGES {10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31}
set_parameter_property BAR_IO_SIZE ALLOWED_RANGES {2 3 4 5 6 7 8}
set_parameter_property PCI_MASTER_ADDR_MAP_NUM_ENTRIES ALLOWED_RANGES {2 4 8 16}
set_parameter_property PCI_MASTER_ADDR_MAP_PASS_THRU_BITS ALLOWED_RANGES {12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27}
set_parameter_property MAX_READ_DWORDS_BURST ALLOWED_RANGES {1 2 4 8 16 32 64 128}

# Parameters Display Name
set_parameter_property "MASTER_ENABLE" "display_name" "Enable Master/Target Mode"
set_parameter_property "MASTER_HOST_BRIDGE" "display_name" "Enable Host Bridge Mode"
set_parameter_property "BAR_PREFETCHABLE" "display_name" "Prefetchable BAR"
set_parameter_property "BAR_PREFETCHABLE_SIZE" "display_name" "Prefetchable BAR Size"
set_parameter_property "BAR_PREFETCHABLE_AV_ADDR_TRANS" "display_name" "Prefetchable BAR Avalon Address Translation Offset"
set_parameter_property "BAR_NONPREFETCHABLE" "display_name" "Non-Prefetchable BAR" 
set_parameter_property "BAR_NONPREFETCHABLE_SIZE" "display_name" "Non-Prefetchable BAR Size"
set_parameter_property "BAR_NONPREFETCHABLE_AV_ADDR_TRANS" "display_name" "Non-Prefetchable BAR Avalon Address Translation Offset"
set_parameter_property "BAR_IO" "display_name" "IO BAR"
set_parameter_property "BAR_IO_SIZE" "display_name" "IO BAR Size"
set_parameter_property "BAR_IO_AV_ADDR_TRANS" "display_name" "IO BAR Avalon Address Translation Offset"
set_parameter_property "CONF_DEVICE_ID" "display_name"  "Device ID"
set_parameter_property "CONF_VEND_ID" "display_name" "Vendor ID"
set_parameter_property "CONF_CLASS_CODE" "display_name"  "Class Code"
set_parameter_property "CONF_REVISION_ID" "display_name"  "Revision ID"
set_parameter_property "CONF_SUBSYSTEM_ID" "display_name" "Subsystem ID"
set_parameter_property "CONF_SUBSYSTEM_VEND_ID" "display_name" "Subsystem Vendor ID"
set_parameter_property "CONF_MAX_LATENCY" "display_name"  "Maximum Latency"
set_parameter_property "CONF_MIN_GRANT" "display_name" "Minimum Grant"
set_parameter_property "PCI_MASTER_ADDR_MAP_NUM_ENTRIES" "display_name" "Number of Address Pages"
set_parameter_property "PCI_MASTER_ADDR_MAP_PASS_THRU_BITS" "display_name" "Size of Address Pages"
set_parameter_property "MAX_READ_DWORDS_BURST" "display_name" "Maximum Target Read Burst Size"

# Validation parameters
set BAR_PREFETCHABLE_SIZE_MIN_RANGE 10
set BAR_PREFETCHABLE_SIZE_MAX_RANGE 31
set BAR_NONPREFETCHABLE_SIZE_MIN_RANGE 10
set BAR_NONPREFETCHABLE_SIZE_MAX_RANGE 31
set BAR_IO_SIZE_MIN_RANGE 2
set BAR_IO_SIZE_MAX_RANGE 8
set BAR_PREFETCHABLE_AV_ADDR_TRANS_MIN_RANGE 0
set BAR_NONPREFETCHABLE_AV_ADDR_TRANS_MIN_RANGE 0
set BAR_IO_AV_ADDR_TRANS_MIN_RANGE 0 

set_module_property ValidationCallback "validate"
set_module_property ElaborationCallback "elaborate"

proc validate_bar_selected { } {
   
   set pm_bar_parameter [get_parameter_value "BAR_PREFETCHABLE"]
   set npm_bar_parameter [get_parameter_value "BAR_NONPREFETCHABLE"]
   set io_bar_parameter [get_parameter_value "BAR_IO"]

   if {$pm_bar_parameter=="0" && $npm_bar_parameter=="0" && $io_bar_parameter=="0"} {
	send_message "error" "PCI Lite: No BAR Selected."
   }
}

proc validate_parameter_range { parameter_name } {

   if { $parameter_name == "PCI_MASTER_ADDR_MAP_NUM_ENTRIES" } {

	set parameter_value [ get_parameter_value "$parameter_name" ]   
        if { $parameter_value == "2" || $parameter_value == "4" || 
	     $parameter_value == "8" || $parameter_value == "16"} {
   	} else {
	     send_message "error" "PCI_MASTER_ADDR_MAP_NUM_ENTRIES: Must be either 2,4,8 or 16."       
	}

   } elseif { $parameter_name == "PCI_MASTER_ADDR_MAP_PASS_THRU_BITS"} {
	set parameter_value [ get_parameter_value "$parameter_name" ]   
        if { $parameter_value < 12 || $parameter_value > 27 } { 
	     send_message "error" "PCI_MASTER_ADDR_MAP_PASS_THRU_BITS: expected value of range from 12 to 27."       
	}

   } elseif { $parameter_name == "MAX_READ_DWORDS_BURST"} {
	set parameter_value [ get_parameter_value "$parameter_name" ]   
        if { $parameter_value == "1" || $parameter_value == "2" || $parameter_value == "4" || 
	     $parameter_value == "8" || $parameter_value == "16" || $parameter_value == "32" ||
  	     $parameter_value == "64" || $parameter_value == "128"} {
   	} else {
	     send_message "error" "MAX_READ_DWORDS_BURST: Must be either 1,2,4,8,16,32,64 or 128."       
	}

   } elseif { $parameter_name == "BAR_PREFETCHABLE_SIZE" ||
              $parameter_name == "BAR_NONPREFETCHABLE_SIZE" ||
              $parameter_name == "BAR_IO_SIZE" } { 
      	   set min_range_variable_name ::${parameter_name}_MIN_RANGE
	   set min_range [subst $$min_range_variable_name]
	   set max_range_variable_name ::${parameter_name}_MAX_RANGE
	   set max_range [subst $$max_range_variable_name]
  
   	   set parameter_value [ get_parameter_value "$parameter_name" ] 
	   if { [ expr $parameter_value < $min_range ||  $parameter_value > $max_range ] } {
	             send_message "error" "Parameter value out of range. 
                                   Parameter $parameter_name is $parameter_value, expected value of range from $min_range to $max_range"
           }
   } 
  
}

proc validate {} {

   validate_bar_selected
   validate_parameter_range "MASTER_ENABLE"
   validate_parameter_range "MASTER_HOST_BRIDGE"
   validate_parameter_range "BAR_PREFETCHABLE"
   validate_parameter_range "BAR_NONPREFETCHABLE"
   validate_parameter_range "BAR_IO"
   validate_parameter_range "BAR_PREFETCHABLE_SIZE"
   validate_parameter_range "BAR_NONPREFETCHABLE_SIZE"
   validate_parameter_range "BAR_IO_SIZE"
   validate_parameter_range "PCI_MASTER_ADDR_MAP_NUM_ENTRIES"
   validate_parameter_range "PCI_MASTER_ADDR_MAP_PASS_THRU_BITS"
   validate_parameter_range "MAX_READ_DWORDS_BURST"
   
}

proc elaborate {} {

   set master_selection [get_parameter_value "MASTER_ENABLE"]
   set master_host_bridge [get_parameter_value "MASTER_HOST_BRIDGE"]
   set current_dir [pwd]
   set bar_prefetchable_size [get_parameter_value "BAR_PREFETCHABLE_SIZE"]
   set bar_nonprefetchable_size [get_parameter_value "BAR_NONPREFETCHABLE_SIZE"]
   set bar_io_size [get_parameter_value "BAR_IO_SIZE"]
   set prefetchable_bar_selected [get_parameter_value "BAR_PREFETCHABLE"]
   set nonprefetchable_bar_selected [get_parameter_value "BAR_NONPREFETCHABLE"]
   set io_bar_selected [get_parameter_value "BAR_IO"]
   set master_access_address_size [get_parameter_value "PCI_MASTER_ADDR_MAP_PASS_THRU_BITS"]

   # Clock Interface
   add_interface "pci_clk" "clock" "sink" "asynchronous"
   add_interface_port "pci_clk" "AvlClk_i" "clk" "input" 1
   add_interface_port "pci_clk" "rstn" "reset_n" "input" 1

   # Interface pci_lite
   add_interface "pci_lite" "conduit" "start" "pci_clk"
   
   if {$master_host_bridge} {
      send_message "info" "MASTER_ENABLE must be selected in order to use Host Bridge" 
   }

   if {$master_selection || $master_host_bridge} {
      add_interface_port "pci_lite" "gntn" "export" "input" 1
      add_interface_port "pci_lite" "reqn" "export" "output" 1
   }
   # Ports in interface pci_lite
   
   #if {$master_selection || $master_host_bridge} {
   add_interface_port "pci_lite" "idsel" "export" "input" 1
   add_interface_port "pci_lite" "intan" "export" "output" 1
   add_interface_port "pci_lite" "ad" "export" "bidir" 32
   add_interface_port "pci_lite" "cben" "export" "bidir" 4
   add_interface_port "pci_lite" "framen" "export" "bidir" 1
   add_interface_port "pci_lite" "irdyn" "export" "bidir" 1
   add_interface_port "pci_lite" "devseln" "export" "bidir" 1
   add_interface_port "pci_lite" "trdyn" "export" "bidir" 1
   add_interface_port "pci_lite" "stopn" "export" "bidir" 1
   add_interface_port "pci_lite" "perrn" "export" "bidir" 1
   add_interface_port "pci_lite" "par" "export" "bidir" 1
   add_interface_port "pci_lite" "serrn" "export" "bidir" 1
   #} else { 
   #add_interface_port "pci_lite" "idsel" "export" "input" 1
   #add_interface_port "pci_lite" "intan" "export" "output" 1
   #add_interface_port "pci_lite" "ad" "export" "bidir" 32
   #add_interface_port "pci_lite" "cben" "export" "input" 4
   #add_interface_port "pci_lite" "framen" "export" "input" 1
   #add_interface_port "pci_lite" "irdyn" "export" "input" 1
   #add_interface_port "pci_lite" "devseln" "export" "output" 1
   #add_interface_port "pci_lite" "trdyn" "export" "output" 1
   #add_interface_port "pci_lite" "stopn" "export" "output" 1
   #add_interface_port "pci_lite" "perrn" "export" "output" 1
   #add_interface_port "pci_lite" "par" "export" "output" 1
   #add_interface_port "pci_lite" "serrn" "export" "output" 1
   #}

   if {$prefetchable_bar_selected} {
   # Interface Avalon_Bus_Access PM
   add_interface "Pm_Avalon_Bus_Access" "avalon" "master" "pci_clk"
   set_interface_property "Pm_Avalon_Bus_Access" "burstOnBurstBoundariesOnly" "false"
   set_interface_property "Pm_Avalon_Bus_Access" "doStreamReads" "false"
   set_interface_property "Pm_Avalon_Bus_Access" "linewrapBursts" "false"
   set_interface_property "Pm_Avalon_Bus_Access" "doStreamWrites" "false"
   # Ports in interface Avalon_Bus_Access
   add_interface_port "Pm_Avalon_Bus_Access" "PmReadData_i" "readdata" "input" 32
   add_interface_port "Pm_Avalon_Bus_Access" "PmReadDataValid_i" "readdatavalid" "input" 1
   add_interface_port "Pm_Avalon_Bus_Access" "PmWaitRequest_i" "waitrequest" "input" 1
   add_interface_port "Pm_Avalon_Bus_Access" "PmAddress_o" "address" "output" $bar_prefetchable_size
   add_interface_port "Pm_Avalon_Bus_Access" "PmRead_o" "read" "output" 1
   add_interface_port "Pm_Avalon_Bus_Access" "PmWrite_o" "write" "output" 1
   add_interface_port "Pm_Avalon_Bus_Access" "PmByteEnable_o" "byteenable" "output" 4
   add_interface_port "Pm_Avalon_Bus_Access" "PmWriteData_o" "writedata" "output" 32
   add_interface_port "Pm_Avalon_Bus_Access" "PmBurstCount_o" "burstcount" "output" 8
}
   if {$nonprefetchable_bar_selected} {
   # Interface Avalon_Bus_Access NPM
   add_interface "Npm_Avalon_Bus_Access" "avalon" "master" "pci_clk"
   set_interface_property "Npm_Avalon_Bus_Access" "burstOnBurstBoundariesOnly" "false"
   set_interface_property "Npm_Avalon_Bus_Access" "doStreamReads" "false"
   set_interface_property "Npm_Avalon_Bus_Access" "linewrapBursts" "false"
   set_interface_property "Npm_Avalon_Bus_Access" "doStreamWrites" "false"
   # Ports in interface Avalon_Bus_Access
   add_interface_port "Npm_Avalon_Bus_Access" "NpmReadData_i" "readdata" "input" 32
   add_interface_port "Npm_Avalon_Bus_Access" "NpmReadDataValid_i" "readdatavalid" "input" 1
   add_interface_port "Npm_Avalon_Bus_Access" "NpmWaitRequest_i" "waitrequest" "input" 1
   add_interface_port "Npm_Avalon_Bus_Access" "NpmAddress_o" "address" "output" $bar_nonprefetchable_size
   add_interface_port "Npm_Avalon_Bus_Access" "NpmRead_o" "read" "output" 1
   add_interface_port "Npm_Avalon_Bus_Access" "NpmWrite_o" "write" "output" 1
   add_interface_port "Npm_Avalon_Bus_Access" "NpmByteEnable_o" "byteenable" "output" 4
   add_interface_port "Npm_Avalon_Bus_Access" "NpmWriteData_o" "writedata" "output" 32
}
   if {$io_bar_selected} {
   # Interface Avalon_Bus_Access IO
   add_interface "IO_Avalon_Bus_Access" "avalon" "master" "pci_clk"
   set_interface_property "IO_Avalon_Bus_Access" "burstOnBurstBoundariesOnly" "false"
   set_interface_property "IO_Avalon_Bus_Access" "doStreamReads" "false"
   set_interface_property "IO_Avalon_Bus_Access" "linewrapBursts" "false"
   set_interface_property "IO_Avalon_Bus_Access" "doStreamWrites" "false"
   # Ports in interface Avalon_Bus_Access
   add_interface_port "IO_Avalon_Bus_Access" "IoReadData_i" "readdata" "input" 32
   add_interface_port "IO_Avalon_Bus_Access" "IoReadDataValid_i" "readdatavalid" "input" 1
   add_interface_port "IO_Avalon_Bus_Access" "IoWaitRequest_i" "waitrequest" "input" 1
   add_interface_port "IO_Avalon_Bus_Access" "IoAddress_o" "address" "output" $bar_io_size
   add_interface_port "IO_Avalon_Bus_Access" "IoRead_o" "read" "output" 1
   add_interface_port "IO_Avalon_Bus_Access" "IoWrite_o" "write" "output" 1
   add_interface_port "IO_Avalon_Bus_Access" "IoByteEnable_o" "byteenable" "output" 4
   add_interface_port "IO_Avalon_Bus_Access" "IoWriteData_o" "writedata" "output" 32
}

 if {$master_selection || $master_host_bridge} {
      # Interface PCI_Bus_Access
      add_interface "PCI_Bus_Access" "avalon" "slave" "pci_clk"
      set_interface_property "PCI_Bus_Access" "isNonVolatileStorage" "false"
      set_interface_property "PCI_Bus_Access" "burstOnBurstBoundariesOnly" "false"
      set_interface_property "PCI_Bus_Access" "readLatency" "0"
      set_interface_property "PCI_Bus_Access" "holdTime" "0"
      set_interface_property "PCI_Bus_Access" "printableDevice" "false"
      set_interface_property "PCI_Bus_Access" "readWaitTime" "1"
      set_interface_property "PCI_Bus_Access" "setupTime" "0"
      set_interface_property "PCI_Bus_Access" "addressAlignment" "DYNAMIC"
      set_interface_property "PCI_Bus_Access" "writeWaitTime" "0"
      set_interface_property "PCI_Bus_Access" "timingUnits" "Cycles"
      set_interface_property "PCI_Bus_Access" "minimumUninterruptedRunLength" "1"
      set_interface_property "PCI_Bus_Access" "isMemoryDevice" "false"
      set_interface_property "PCI_Bus_Access" "linewrapBursts" "false"
      set_interface_property "PCI_Bus_Access" "maximumPendingReadTransactions" "1"
      # Ports in interface PCI_Bus_Access
      add_interface_port "PCI_Bus_Access" "PbaChipSelect_i" "chipselect" "input" 1
      add_interface_port "PCI_Bus_Access" "PbaByteEnable_i" "byteenable" "input" 4
      add_interface_port "PCI_Bus_Access" "PbaWriteData_i" "writedata" "input" 32
      add_interface_port "PCI_Bus_Access" "PbaAddress_i" "address" "input" [expr $master_access_address_size - 2]
      add_interface_port "PCI_Bus_Access" "PbaRead_i" "read" "input" 1
      add_interface_port "PCI_Bus_Access" "PbaWrite_i" "write" "input" 1
      add_interface_port "PCI_Bus_Access" "PbaBurstCount_i" "burstcount" "input" 8
      add_interface_port "PCI_Bus_Access" "PbaBeginTransfer_i" "begintransfer" "input" 1
      add_interface_port "PCI_Bus_Access" "PbaBeginBurstTransfer_i" "beginbursttransfer" "input" 1
      add_interface_port "PCI_Bus_Access" "PbaReadData_o" "readdata" "output" 32
      add_interface_port "PCI_Bus_Access" "PbaReadDataValid_o" "readdatavalid" "output" 1
      add_interface_port "PCI_Bus_Access" "PbaWaitRequest_o" "waitrequest" "output" 1
  # Interface CRA_Access
      add_interface "CRA_Access" "avalon" "slave" "pci_clk"
      set_interface_property "CRA_Access" "isNonVolatileStorage" "false"
      set_interface_property "CRA_Access" "burstOnBurstBoundariesOnly" "false"
      set_interface_property "CRA_Access" "readLatency" "0"
      set_interface_property "CRA_Access" "holdTime" "0"
      set_interface_property "CRA_Access" "printableDevice" "false"
      set_interface_property "CRA_Access" "readWaitTime" "1"
      set_interface_property "CRA_Access" "setupTime" "0"
      set_interface_property "CRA_Access" "addressAlignment" "DYNAMIC"
      set_interface_property "CRA_Access" "writeWaitTime" "0"
      set_interface_property "CRA_Access" "timingUnits" "Cycles"
      set_interface_property "CRA_Access" "minimumUninterruptedRunLength" "1"
      set_interface_property "CRA_Access" "isMemoryDevice" "false"
      set_interface_property "CRA_Access" "linewrapBursts" "false"
      
      # Ports in interface CRA_Access

      add_interface_port "CRA_Access" "CraChipSelect_i" "chipselect" "input" 1
      add_interface_port "CRA_Access" "CraByteEnable_i" "byteenable" "input" 4
      add_interface_port "CRA_Access" "CraWriteData_i" "writedata" "input" 32
      add_interface_port "CRA_Access" "CraAddress_i" "address" "input" 12
      add_interface_port "CRA_Access" "CraRead_i" "read" "input" 1
      add_interface_port "CRA_Access" "CraWrite_i" "write" "input" 1
      add_interface_port "CRA_Access" "CraBeginTransfer_i" "begintransfer" "input" 1
      add_interface_port "CRA_Access" "CraReadData_o" "readdata" "output" 32
      add_interface_port "CRA_Access" "CraWaitRequest_o" "waitrequest" "output" 1
}

   # Interface interrupt_receiver
   add_interface "interrupt_receiver" "interrupt" "receiver" "pci_clk"
   set_interface_property "interrupt_receiver" "irqScheme" "INDIVIDUAL_REQUESTS"
   if {$prefetchable_bar_selected} {
   	set_interface_property "interrupt_receiver" "associatedAddressablePoint" "Pm_Avalon_Bus_Access"
   } elseif {$nonprefetchable_bar_selected} {
	set_interface_property "interrupt_receiver" "associatedAddressablePoint" "Npm_Avalon_Bus_Access"
   } elseif {$io_bar_selected} {
	set_interface_property "interrupt_receiver" "associatedAddressablePoint" "IO_Avalon_Bus_Access"
   }
   # Ports in interface interrupt_receiver
   add_interface_port "interrupt_receiver" "NIrq_i" "irq" "input" 1
 }


