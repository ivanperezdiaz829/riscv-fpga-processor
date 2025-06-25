package require -exact qsys 12.0
source $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl

#-------------------------------------------------------------------------------
# module properties
#-------------------------------------------------------------------------------

set_module_property NAME {altera_avalon_onchip_memory2}
set_module_property DISPLAY_NAME {On-Chip Memory (RAM or ROM)}
set_module_property VERSION {13.1}
set_module_property GROUP {Memories and Memory Controllers/On-Chip}
set_module_property AUTHOR {Altera Corporation}
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property INTERNAL false
set_module_property HIDE_FROM_SOPC true
set_module_property EDITABLE true
set_module_property VALIDATION_CALLBACK validate
set_module_property ELABORATION_CALLBACK elaborate

# generation fileset

add_fileset quartus_synth QUARTUS_SYNTH sub_quartus_synth
add_fileset sim_verilog SIM_VERILOG sub_sim_verilog
add_fileset sim_vhdl SIM_VHDL sub_sim_vhdl

# links to documentation

add_documentation_link {Data Sheet } {http://www.altera.com/literature/hb/qts/qts_qii54006.pdf}

#-------------------------------------------------------------------------------
# module parameters
#-------------------------------------------------------------------------------

# parameters

add_parameter allowInSystemMemoryContentEditor BOOLEAN
set_parameter_property allowInSystemMemoryContentEditor DEFAULT_VALUE {false}
set_parameter_property allowInSystemMemoryContentEditor DISPLAY_NAME {Enable In-System Memory Content Editor feature}
set_parameter_property allowInSystemMemoryContentEditor AFFECTS_GENERATION {1}
set_parameter_property allowInSystemMemoryContentEditor HDL_PARAMETER {0}

add_parameter blockType STRING
set_parameter_property blockType DEFAULT_VALUE {AUTO}
set_parameter_property blockType DISPLAY_NAME {Block type}
set_parameter_property blockType ALLOWED_RANGES {AUTO MRAM M4K M512 M9K M144K M20K M10K MLAB MRAM}
set_parameter_property blockType AFFECTS_GENERATION {1}
set_parameter_property blockType HDL_PARAMETER {0}

add_parameter dataWidth INTEGER                                                        
set_parameter_property dataWidth DEFAULT_VALUE {32}                                     
set_parameter_property dataWidth DISPLAY_NAME {Data width}
set_parameter_property dataWidth ALLOWED_RANGES {8 16 32 64 128 256 512 1024}       
set_parameter_property dataWidth AFFECTS_GENERATION {1}
set_parameter_property dataWidth HDL_PARAMETER {0}                      
                                                                        
add_parameter dualPort BOOLEAN                                          
set_parameter_property dualPort DEFAULT_VALUE {false}                   
set_parameter_property dualPort DISPLAY_NAME {Dual-port access}                       
set_parameter_property dualPort AFFECTS_GENERATION {1}                  
set_parameter_property dualPort HDL_PARAMETER {0}                       
                                                                        
add_parameter initMemContent BOOLEAN                                    
set_parameter_property initMemContent DEFAULT_VALUE {true}
set_parameter_property initMemContent DISPLAY_NAME {Initialize memory content}
set_parameter_property initMemContent AFFECTS_GENERATION {1}
set_parameter_property initMemContent HDL_PARAMETER {0}

add_parameter initializationFileName STRING
set_parameter_property initializationFileName DEFAULT_VALUE {onchip_mem.hex}
set_parameter_property initializationFileName DISPLAY_NAME {          User created initialization file}
set_parameter_property initializationFileName DISPLAY_HINT {file:hex}
set_parameter_property initializationFileName DESCRIPTION {Type the filename (e.g: my_ram.hex) or select the hex file using the file browser button.}
set_parameter_property initializationFileName AFFECTS_GENERATION {1}
set_parameter_property initializationFileName HDL_PARAMETER {0}

add_parameter instanceID STRING
set_parameter_property instanceID DEFAULT_VALUE {NONE}
set_parameter_property instanceID DISPLAY_NAME {Instance ID}
set_parameter_property instanceID AFFECTS_GENERATION {1}
set_parameter_property instanceID HDL_PARAMETER {0}  

add_parameter memorySize LONG
set_parameter_property memorySize DEFAULT_VALUE {4096}
set_parameter_property memorySize DISPLAY_NAME {Total memory size}
set_parameter_property memorySize UNITS {Bytes}
set_parameter_property memorySize ALLOWED_RANGES {0:10485760}
set_parameter_property memorySize AFFECTS_GENERATION {1}
set_parameter_property memorySize HDL_PARAMETER {0}

add_parameter readDuringWriteMode STRING
set_parameter_property readDuringWriteMode DEFAULT_VALUE {DONT_CARE}
set_parameter_property readDuringWriteMode DISPLAY_NAME {Read During Write Mode}
set_parameter_property readDuringWriteMode ALLOWED_RANGES {DONT_CARE OLD_DATA}
set_parameter_property readDuringWriteMode AFFECTS_GENERATION {1}
set_parameter_property readDuringWriteMode HDL_PARAMETER {0}

add_parameter simAllowMRAMContentsFile BOOLEAN
set_parameter_property simAllowMRAMContentsFile DEFAULT_VALUE {false}
set_parameter_property simAllowMRAMContentsFile DISPLAY_NAME {Allow MRAM contents file for simulation}
set_parameter_property simAllowMRAMContentsFile VISIBLE {0}
set_parameter_property simAllowMRAMContentsFile AFFECTS_GENERATION {1}
set_parameter_property simAllowMRAMContentsFile HDL_PARAMETER {0}

add_parameter simMemInitOnlyFilename INTEGER
set_parameter_property simMemInitOnlyFilename DEFAULT_VALUE {0}
set_parameter_property simMemInitOnlyFilename DISPLAY_NAME {Simulation meminit only has filename}
set_parameter_property simMemInitOnlyFilename VISIBLE {0}
set_parameter_property simMemInitOnlyFilename ALLOWED_RANGES {0:1}
set_parameter_property simMemInitOnlyFilename DESCRIPTION {set to 1 to omit ../ in simulation meminit path, default is 0}
set_parameter_property simMemInitOnlyFilename AFFECTS_GENERATION {1}
set_parameter_property simMemInitOnlyFilename HDL_PARAMETER {0}

add_parameter singleClockOperation BOOLEAN           
set_parameter_property singleClockOperation DEFAULT_VALUE {false}
set_parameter_property singleClockOperation DISPLAY_NAME {Single clock operation}
set_parameter_property singleClockOperation AFFECTS_GENERATION {1}
set_parameter_property singleClockOperation HDL_PARAMETER {0}

add_parameter slave1Latency INTEGER
set_parameter_property slave1Latency DEFAULT_VALUE {1}
set_parameter_property slave1Latency DISPLAY_NAME {Slave s1 Latency}
set_parameter_property slave1Latency ALLOWED_RANGES {1 2}
set_parameter_property slave1Latency AFFECTS_GENERATION {1}
set_parameter_property slave1Latency HDL_PARAMETER {0}

add_parameter slave2Latency INTEGER
set_parameter_property slave2Latency DEFAULT_VALUE {1}
set_parameter_property slave2Latency DISPLAY_NAME {Slave s2 Latency}
set_parameter_property slave2Latency ALLOWED_RANGES {1 2}
set_parameter_property slave2Latency AFFECTS_GENERATION {1}
set_parameter_property slave2Latency HDL_PARAMETER {0}

add_parameter useNonDefaultInitFile BOOLEAN
set_parameter_property useNonDefaultInitFile DEFAULT_VALUE {false}
set_parameter_property useNonDefaultInitFile DISPLAY_NAME {Enable non-default initialization file}
set_parameter_property useNonDefaultInitFile AFFECTS_GENERATION {1}
set_parameter_property useNonDefaultInitFile HDL_PARAMETER {0}

add_parameter useShallowMemBlocks BOOLEAN
set_parameter_property useShallowMemBlocks DEFAULT_VALUE {false}
set_parameter_property useShallowMemBlocks DISPLAY_NAME {Minimize memory block usage (may impact fmax)}
set_parameter_property useShallowMemBlocks AFFECTS_GENERATION {1}
set_parameter_property useShallowMemBlocks HDL_PARAMETER {0}

add_parameter writable BOOLEAN
set_parameter_property writable DEFAULT_VALUE {true}
set_parameter_property writable DISPLAY_NAME {Type}
set_parameter_property writable ALLOWED_RANGES {{true:RAM (Writable)} {false:ROM (Read-only)}}
set_parameter_property writable AFFECTS_GENERATION {1}
set_parameter_property writable HDL_PARAMETER {0}

add_parameter ecc_enabled BOOLEAN
set_parameter_property ecc_enabled DEFAULT_VALUE {false}
set_parameter_property ecc_enabled DISPLAY_NAME {ECC}
set_parameter_property ecc_enabled ALLOWED_RANGES {{true:Enabled} {false:Disabled}}
set_parameter_property ecc_enabled AFFECTS_GENERATION {1}
set_parameter_property ecc_enabled HDL_PARAMETER {0}

# system info parameters

add_parameter autoInitializationFileName STRING
set_parameter_property autoInitializationFileName DISPLAY_NAME {autoInitializationFileName}
set_parameter_property autoInitializationFileName VISIBLE {0}
set_parameter_property autoInitializationFileName AFFECTS_GENERATION {1}
set_parameter_property autoInitializationFileName HDL_PARAMETER {0}
set_parameter_property autoInitializationFileName SYSTEM_INFO {unique_id}
set_parameter_property autoInitializationFileName SYSTEM_INFO_TYPE {UNIQUE_ID}

add_parameter deviceFamily STRING
set_parameter_property deviceFamily DEFAULT_VALUE {NONE}
set_parameter_property deviceFamily DISPLAY_NAME {deviceFamily}
set_parameter_property deviceFamily VISIBLE {0}
set_parameter_property deviceFamily AFFECTS_GENERATION {1}
set_parameter_property deviceFamily HDL_PARAMETER {0}
set_parameter_property deviceFamily SYSTEM_INFO {device_family}
set_parameter_property deviceFamily SYSTEM_INFO_TYPE {DEVICE_FAMILY}

add_parameter deviceFeatures STRING
set_parameter_property deviceFeatures DEFAULT_VALUE {NONE}
set_parameter_property deviceFeatures DISPLAY_NAME {deviceFeatures}
set_parameter_property deviceFeatures VISIBLE {0}
set_parameter_property deviceFeatures AFFECTS_GENERATION {1}
set_parameter_property deviceFeatures HDL_PARAMETER {0}
set_parameter_property deviceFeatures SYSTEM_INFO {device_feature}
set_parameter_property deviceFeatures SYSTEM_INFO_TYPE {DEVICE_FEATURES}
                                                     

# derived parameters
add_parameter derived_set_addr_width INTEGER
set_parameter_property derived_set_addr_width DEFAULT_VALUE {3}
set_parameter_property derived_set_addr_width DISPLAY_NAME {slave_address_width}
set_parameter_property derived_set_addr_width VISIBLE {0}
set_parameter_property derived_set_addr_width DERIVED {1}
set_parameter_property derived_set_addr_width AFFECTS_GENERATION {1}
set_parameter_property derived_set_addr_width HDL_PARAMETER {0}

add_parameter derived_set_data_width INTEGER
set_parameter_property derived_set_data_width DEFAULT_VALUE {32}
set_parameter_property derived_set_data_width DISPLAY_NAME {slave_data_width}
set_parameter_property derived_set_data_width VISIBLE {0}
set_parameter_property derived_set_data_width DERIVED {1}
set_parameter_property derived_set_data_width AFFECTS_GENERATION {1}
set_parameter_property derived_set_data_width HDL_PARAMETER {0}

add_parameter derived_gui_ram_block_type STRING
set_parameter_property derived_gui_ram_block_type DEFAULT_VALUE {Automatic}
set_parameter_property derived_gui_ram_block_type DISPLAY_NAME {derived_gui_ram_block_type}
set_parameter_property derived_gui_ram_block_type VISIBLE {0}
set_parameter_property derived_gui_ram_block_type DERIVED {1}
set_parameter_property derived_gui_ram_block_type AFFECTS_GENERATION {1}
set_parameter_property derived_gui_ram_block_type HDL_PARAMETER {0}

add_parameter derived_is_hardcopy BOOLEAN
set_parameter_property derived_is_hardcopy DEFAULT_VALUE {false}
set_parameter_property derived_is_hardcopy DISPLAY_NAME {derived_is_hardcopy}
set_parameter_property derived_is_hardcopy VISIBLE {0}
set_parameter_property derived_is_hardcopy DERIVED {1}
set_parameter_property derived_is_hardcopy AFFECTS_GENERATION {1}
set_parameter_property derived_is_hardcopy HDL_PARAMETER {0}

add_parameter derived_init_file_name STRING
set_parameter_property derived_init_file_name DISPLAY_NAME {derived_init_file_name}
set_parameter_property derived_init_file_name VISIBLE {0}
set_parameter_property derived_init_file_name DERIVED {1}
set_parameter_property derived_init_file_name AFFECTS_GENERATION {1}
set_parameter_property derived_init_file_name HDL_PARAMETER {0}

#-------------------------------------------------------------------------------
# module GUI
#-------------------------------------------------------------------------------         

# display group
add_display_item {} {Memory type} GROUP
add_display_item {} {Size} GROUP
add_display_item {} {Read latency} GROUP
add_display_item {} {ECC Parameter} GROUP
add_display_item {} {Memory initialization} GROUP    

# group parameter
add_display_item {Memory type} writable PARAMETER
add_display_item {Memory type} dualPort PARAMETER
add_display_item {Memory type} singleClockOperation PARAMETER
add_display_item {Memory type} readDuringWriteMode PARAMETER
add_display_item {Memory type} blockType PARAMETER
add_display_item {Memory type} ramTypeMessage TEXT ""

add_display_item {Size} dataWidth PARAMETER
add_display_item {Size} memorySize PARAMETER
add_display_item {Size} useShallowMemBlocks PARAMETER

add_display_item {Read latency} slave1Latency PARAMETER
add_display_item {Read latency} slave2Latency PARAMETER

add_display_item {ECC Parameter} ecc_enabled PARAMETER

add_display_item {Memory initialization} initMemContent PARAMETER
add_display_item {Memory initialization} useNonDefaultInitFile PARAMETER
add_display_item {Memory initialization} initializationFileNameMessage TEXT "          Type the filename (e.g: my_ram.hex) or select the hex file using the file browser button."
set_display_item_property initializationFileName DISPLAY_HINT {file:hex}
add_display_item {Memory initialization} initializationFileName PARAMETER
add_display_item {Memory initialization} allowInSystemMemoryContentEditor PARAMETER
add_display_item {Memory initialization} instanceID PARAMETER
add_display_item {Memory initialization} ramInitMessage TEXT ""

#-------------------------------------------------------------------------------
# module validation
#-------------------------------------------------------------------------------
proc proc_updated_legal_blocks_type { deviceFamily } {
  set legal_blocks [list]
  lappend legal_blocks "AUTO"
  array set device_feature_array [get_parameter_value deviceFeatures]   
  
  foreach mem_feature [array names device_feature_array] {
      if { [ string match "*_MEMORY*" "$mem_feature" ] } {
          if {($mem_feature == "M512_MEMORY") && ($deviceFamily == "HARDCOPYII")} {
          # Don't use M512 for Hardcopy II
          } else {                                                 
              if { $device_feature_array($mem_feature) } {	    
      	          switch $mem_feature {
                      "MRAM_MEMORY"  { lappend legal_blocks "MRAM" }
                      "M4K_MEMORY"   { lappend legal_blocks "M4K" }
                      "M512_MEMORY"  { lappend legal_blocks "M512" }
                      "M9K_MEMORY"   { lappend legal_blocks "M9K" }
                      "M144K_MEMORY" { lappend legal_blocks "M144K" }
                      "M20K_MEMORY"  { lappend legal_blocks "M20K" }
                      "M10K_MEMORY"  { lappend legal_blocks "M10K" }
                      "MLAB_MEMORY"  { lappend legal_blocks "MLAB" }
                      default { send_message error "$mem_feature is not a valid ram type" }
                  } 
              }
          }       
      }
  }                       
  set_parameter_property blockType ALLOWED_RANGES "$legal_blocks"
}


proc hasM512 { } {
  set has_m512 0
  set legal_blocks [ get_parameter_property blockType ALLOWED_RANGES ]
  
  foreach mem_type $legal_blocks {
      if { $mem_type == "M512" } {
        set has_m512 1    
      }
  }
  return $has_m512
}

proc validate {} {

	# read parameter
	
	set NAME [ get_module_property NAME ]
	set allowInSystemMemoryContentEditor [ proc_get_boolean_parameter allowInSystemMemoryContentEditor ]
	set autoInitializationFileName [ get_parameter_value autoInitializationFileName ]
	set blockType [ get_parameter_value blockType ]
	set dataWidth [ get_parameter_value dataWidth ]
	set deviceFamily [ get_parameter_value deviceFamily ]
	set deviceFeatures [ get_parameter_value deviceFeatures ]
	set dualPort [ proc_get_boolean_parameter dualPort ]
	set initMemContent [ proc_get_boolean_parameter initMemContent ]
	set initializationFileName [ get_parameter_value initializationFileName ]
	set instanceID [ get_parameter_value instanceID ]
	set memorySize [ get_parameter_value memorySize ]
	set readDuringWriteMode [ get_parameter_value readDuringWriteMode ]
	set simAllowMRAMContentsFile [ proc_get_boolean_parameter simAllowMRAMContentsFile ]
	set simMemInitOnlyFilename [ get_parameter_value simMemInitOnlyFilename ]
	set singleClockOperation [ proc_get_boolean_parameter singleClockOperation ]
	set slave1Latency [ get_parameter_value slave1Latency ]
	set slave2Latency [ get_parameter_value slave2Latency ]
	set useNonDefaultInitFile [ proc_get_boolean_parameter useNonDefaultInitFile ]
	set useShallowMemBlocks [ proc_get_boolean_parameter useShallowMemBlocks ]
	set writable [ proc_get_boolean_parameter writable ]
	set ecc_enabled [ proc_get_boolean_parameter ecc_enabled ]
	set ramInitMessage "</br>"
	set ramTypeMessage "</br>" 
	
	# validate parameter
	set derived_set_addr_width [ get_parameter_value derived_set_addr_width ]
	set derived_gui_ram_block_type [ get_parameter_value derived_gui_ram_block_type ]
	set derived_is_hardcopy [ proc_get_boolean_parameter derived_is_hardcopy ]
	# get device_Features into array  
	array set device_feature_array [get_parameter_value deviceFeatures]

# ---- part 1 validate GUI interactive ----  
  # Update useShallowMemBlocks PARAM 
  set_parameter_property useShallowMemBlocks ENABLED [ expr {[ expr {$blockType == "M4K"}] ? 1 : 0 }]
  
  # Update instanceID PARAM
  set_parameter_property instanceID ENABLED $allowInSystemMemoryContentEditor
  
  # Update slave2Latency PARAM
  set_parameter_property slave2Latency ENABLED $dualPort 
  
  # Update readDuringWriteMode PARAM
  set_parameter_property readDuringWriteMode ENABLED $dualPort 
  
  # Update singleClockOperation PARAM
  set_parameter_property singleClockOperation ENABLED $dualPort 
  
  # Update useNonDefaultInitFile & initializationFileName PARAM
  set_parameter_property useNonDefaultInitFile ENABLED $initMemContent 
  set_parameter_property initializationFileName ENABLED [ expr {[ expr {$useNonDefaultInitFile && $initMemContent}] ? 1 : 0 }]

# ---- part 2 validate GUI input parameter ----
# All parameter Range
         
  # Check that the device family was set 
  if { $deviceFamily == "Unknown" } {
    send_message error "Device family is unknown."
  } else {                                         
      proc_updated_legal_blocks_type $deviceFamily
      # 1. update new parameter for [initMemContent] is not needed because it is an old PTF/SOPC
      # 2. update validate Block type if invalid in allowed ranges - remove this feature because 
      #    Qsys will notify user on "out of ranges" error message 
      
      # Validate prohibited device
      set prohibited_device { "MERCURY" "APEX20K" "APEX20KE" "APEX20KC" "APEXII" "ACEX1K" "FLEX10KE" "EXCALIBUR_ARM" "MAX II" }
      foreach prohibited $prohibited_device {
          if { $prohibited == $deviceFamily } {
            send_message error "Selected device family does not support this module."
          }	      
      }
      
      # Validate RAM initialization messages
      if { $device_feature_array(HARDCOPY) } {
          if { $writable && $initMemContent } {
            send_message error "RAM cannot be initialized in HardCopy."
          }
      }     
  }
  
  # Validate and generate MRAM messages
  if { $blockType == "MRAM" } {
      if { !$writable } {
        send_message error "MRAM blocks cannot be read only because MRAM blocks cannot be initialized."   
      } elseif { $initMemContent } {
        send_message error "MRAM blocks cannot be initialized."	    
      }
  }
  # Validate block type cannot be dual port
  if { (($blockType == "M512") || ($blockType == "MLAB")) && $dualPort } {
    send_message error "$blockType blocks cannot be selected for dual-port memory." 
  }
  
  # Validate minimum memory size 
  if { $memorySize < ($dataWidth/ 8*4 ) } {
    send_message error "Memory size must be at least four $dataWidth-bit words." 
  }
  if { ($blockType == "AUTO") &&  ($dataWidth != 8) && ([ hasM512 ]) } {
    set ramTypeMessage "$ramTypeMessage<br><b>Selecting AUTO block type will not infer M512.</b>"
  }
  # Validate in system memory content editor
  if { $allowInSystemMemoryContentEditor } {
      if { ($blockType == "M512") || ($blockType == "MLAB") } {
        send_message error "Invalid memory block type for In-System Memory Content Editor"
      }
      if { $dualPort } {
        send_message error "Dual-port memory is not supported by In-System Memory Content Editor"
      }
      if { ([string length $instanceID] > 4) || ([string length $instanceID] < 1) } {
        send_message error "Instance ID must be between 1-4 characters long"
      }
  }
  # Validate read during write option
  if { ($readDuringWriteMode == "OLD_DATA") && ($blockType == "MRAM") && $dualPort } {
    send_message error "MRAM blocks don't support \"OLD_DATA\" option" 
  }
  # Validate old data read/write mode 
  if { ($readDuringWriteMode == "OLD_DATA") && $dualPort } {
    set ramTypeMessage "$ramTypeMessage<br><b>Read During Write Mode of OLD_DATA across ports only supported for single clock operation.</b>"
  }
  # Validate dual port single clock
  if { $singleClockOperation && $dualPort } {
    set ramTypeMessage "$ramTypeMessage<br><b>Tightly Coupled Memory operation require dual port & dual clock sources.</b>"
  }                   
  # Validate un-init memory as instruction memory
  if { !$initMemContent } {
    set ramInitMessage "$ramInitMessage<br><b>This memory is not initialized during device programming.</b>" 
  }  
  # Validate warning about using non-default init file 
  if { $useNonDefaultInitFile && $initMemContent} {
    set ramInitMessage "$ramInitMessage<br><b>User is required to provide memory initialization files for memory."
  }

  # Validate ROM must be initialized
  if { !$writable && !$initMemContent && ($blockType != "MRAM") } {
    send_message error "ROM must be initialized." 
  }
 
  # Derive the filename
  if { $useNonDefaultInitFile } {
      # if user provided name
      set derived_init_file_name "${initializationFileName}"
      # Old sopc allow just filename without extension 
      if { "[ file extension ${initializationFileName} ]" != ".hex" } {
          set derived_init_file_name "${initializationFileName}.hex"
      }
  } else {
      # else, default name, which is UNIQUE_ID/module name  with ".hex"
      set derived_init_file_name "${autoInitializationFileName}.hex"
  }
  
  if { $initMemContent && ($blockType != "MRAM") } {
      if { ($dataWidth != 8) &&  ($blockType == "M512")} {
        set ramInitMessage "$ramInitMessage<br><b>Memory will be initialized from multiple byte-lane files $derived_init_file_name\_lane\[0-[expr ($dataWidth/8-1)]\].hex</b>"
      } else { 
        set ramInitMessage "$ramInitMessage<br><b>Memory will be initialized from $derived_init_file_name</b>"	      
      }
  }
  set htmlRamInitMessage "<html><table border=\"0\" width=\"100%\"><tr><td valign=\"top\"><font size=3>$ramInitMessage</td></tr></table></html>"
  set_display_item_property ramInitMessage TEXT $htmlRamInitMessage
  set htmlRamTypeMessage "<html><table border=\"0\" width=\"100%\"><tr><td valign=\"top\"><font size=3>$ramTypeMessage</td></tr></table></html>"
  set_display_item_property ramTypeMessage TEXT $htmlRamTypeMessage
  
  # Calculate and set address width 
  set byte_per_word [ expr $dataWidth/8 ]
  set bits_to_addr [ expr { [log2ceil $memorySize] - [ log2ceil $byte_per_word ] } ]
  set derived_set_addr_width $bits_to_addr
  
  # Validate device feature is Hardcopy
  if { $device_feature_array(HARDCOPY) } {
    set derived_is_hardcopy 1
  } else {
    set derived_is_hardcopy 0
  }
  
  if { $ecc_enabled } {
    # A loop used to obtain the ecc parity width
    for { set ecc_bits 0 } { [ expr { pow(2,$ecc_bits) - $ecc_bits - 1 } < $dataWidth]  } { incr ecc_bits } {}
    set ecc_bits [ expr $ecc_bits + 1 ]
    set derived_data_width [ expr $dataWidth + $ecc_bits ]
  } else {
    # Else the data_width is a user parameter value
    set derived_data_width $dataWidth
  }
                                                    
  # embedded software assignments
  set derived_gui_ram_block_type [ expr {[ expr {$blockType == "AUTO"}] ? "Automatic" : $blockType }]
  set has_byte_lane [ expr {($derived_data_width > 8) && ($blockType == "M512")} ]
  set hex_file_max_size [ expr 1<<20 ]
  set hex_file_size [ expr { $memorySize / ($derived_data_width/8) } ]
  
	# get the filename no ext, for BSP
	set mem_init_filename [ file tail [ file rootname "$derived_init_file_name" ] ]
	set_module_assignment embeddedsw.CMacro.ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR "$allowInSystemMemoryContentEditor"
	set_module_assignment embeddedsw.CMacro.ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE "$simAllowMRAMContentsFile"
	set_module_assignment embeddedsw.CMacro.CONTENTS_INFO {""}
	set_module_assignment embeddedsw.CMacro.DUAL_PORT "$dualPort"
	set_module_assignment embeddedsw.CMacro.GUI_RAM_BLOCK_TYPE "$blockType"
	set_module_assignment embeddedsw.CMacro.INIT_CONTENTS_FILE "$mem_init_filename"
	set_module_assignment embeddedsw.CMacro.INIT_MEM_CONTENT "$initMemContent"
	set_module_assignment embeddedsw.CMacro.INSTANCE_ID "$instanceID"
	set_module_assignment embeddedsw.CMacro.NON_DEFAULT_INIT_FILE_ENABLED "$useNonDefaultInitFile"
	set_module_assignment embeddedsw.CMacro.RAM_BLOCK_TYPE "$blockType"
	set_module_assignment embeddedsw.CMacro.READ_DURING_WRITE_MODE "$readDuringWriteMode"
	set_module_assignment embeddedsw.CMacro.SINGLE_CLOCK_OP "$singleClockOperation"
	set_module_assignment embeddedsw.CMacro.SIZE_MULTIPLE {1}
	set_module_assignment embeddedsw.CMacro.SIZE_VALUE "$memorySize"
	set_module_assignment embeddedsw.CMacro.WRITABLE "$writable"
	set_module_assignment embeddedsw.memoryInfo.MEM_INIT_DATA_WIDTH "$derived_data_width" 
	set_module_assignment embeddedsw.memoryInfo.HAS_BYTE_LANE "$has_byte_lane"
	
	if { $hex_file_size > $hex_file_max_size } {
	  set_module_assignment embeddedsw.memoryInfo.GENERATE_HEX {0}
	  set_module_assignment embeddedsw.memoryInfo.INCLUDE_WARNING_MSG {On-chip memory size is too large for hex initialization file to be created.}
	} else {
	  set_module_assignment embeddedsw.memoryInfo.GENERATE_HEX {1}
	  set_module_assignment embeddedsw.memoryInfo.HEX_INSTALL_DIR {QPF_DIR}
	}
	
	set_module_assignment embeddedsw.memoryInfo.GENERATE_DAT_SYM {1}
	set_module_assignment embeddedsw.memoryInfo.DAT_SYM_INSTALL_DIR {SIM_DIR}	
	set_module_assignment embeddedsw.memoryInfo.MEM_INIT_FILENAME "$mem_init_filename"
	
	set_module_assignment postgeneration.simulation.init_file.param_name {INIT_FILE}
	set_module_assignment postgeneration.simulation.init_file.type {MEM_INIT}

	# update derived parameter
  set_parameter_value derived_set_data_width $derived_data_width
  set_parameter_value derived_set_addr_width $derived_set_addr_width 
  set_parameter_value derived_gui_ram_block_type $derived_gui_ram_block_type 
  set_parameter_value derived_is_hardcopy $derived_is_hardcopy 
  set_parameter_value derived_init_file_name $derived_init_file_name
        
}

#-------------------------------------------------------------------------------
# module elaboration
#-------------------------------------------------------------------------------

proc elaborate {} {

	# read parameter
        
	set allowInSystemMemoryContentEditor [ proc_get_boolean_parameter allowInSystemMemoryContentEditor ]
	set autoInitializationFileName [ get_parameter_value autoInitializationFileName ]
	set blockType [ get_parameter_value blockType ]
	set dataWidth [ get_parameter_value derived_set_data_width ]
	set deviceFamily [ get_parameter_value deviceFamily ]
	set dualPort [ proc_get_boolean_parameter dualPort ]
	set initMemContent [ proc_get_boolean_parameter initMemContent ]
	set initializationFileName [ get_parameter_value initializationFileName ]
	set instanceID [ get_parameter_value instanceID ]
	set memorySize [ get_parameter_value memorySize ]
	set readDuringWriteMode [ get_parameter_value readDuringWriteMode ]
	set simAllowMRAMContentsFile [ proc_get_boolean_parameter simAllowMRAMContentsFile ]
	set simMemInitOnlyFilename [ get_parameter_value simMemInitOnlyFilename ]
	set singleClockOperation [ proc_get_boolean_parameter singleClockOperation ]
	set slave1Latency [ get_parameter_value slave1Latency ]
	set slave2Latency [ get_parameter_value slave2Latency ]
	set useNonDefaultInitFile [ proc_get_boolean_parameter useNonDefaultInitFile ]
	set useShallowMemBlocks [ proc_get_boolean_parameter useShallowMemBlocks ]
	set writable [ proc_get_boolean_parameter writable ]
	set ecc_enabled [ proc_get_boolean_parameter ecc_enabled ]

	#update derived parameter 
	set derived_set_addr_width [ get_parameter_value derived_set_addr_width ]   
	
	# interfaces
	add_interface clk1 clock sink
	set_interface_property clk1 clockRate {0.0}
	set_interface_property clk1 externallyDriven {0}
	add_interface_port clk1 clk clk Input 1

	add_interface s1 avalon slave
	set_interface_property s1 addressAlignment {DYNAMIC}
	set_interface_property s1 addressGroup {0}
	set_interface_property s1 addressSpan {4096}
	set_interface_property s1 addressUnits {WORDS}
	set_interface_property s1 alwaysBurstMaxBurst {0}
	set_interface_property s1 associatedClock {clk1}
	set_interface_property s1 associatedReset {reset1}
	
	set_interface_property s1 burstOnBurstBoundariesOnly {0}
	set_interface_property s1 burstcountUnits {WORDS}
	set_interface_property s1 constantBurstBehavior {0}
	set_interface_property s1 explicitAddressSpan $memorySize
	set_interface_property s1 holdTime {0}
	set_interface_property s1 interleaveBursts {0}
	set_interface_property s1 isBigEndian {0}
	set_interface_property s1 isFlash {0}
	set_interface_property s1 isMemoryDevice {1}
	set_interface_property s1 isNonVolatileStorage {0}
	set_interface_property s1 linewrapBursts {0}
	set_interface_property s1 maximumPendingReadTransactions {0}
	set_interface_property s1 minimumUninterruptedRunLength {1}
	set_interface_property s1 printableDevice {0}
	set_interface_property s1 readLatency $slave1Latency
	set_interface_property s1 readWaitStates {0}
	set_interface_property s1 readWaitTime {0}
	set_interface_property s1 registerIncomingSignals {0}
	set_interface_property s1 registerOutgoingSignals {0}
	set_interface_property s1 setupTime {0}
	set_interface_property s1 timingUnits {Cycles}
	set_interface_property s1 transparentBridge {0}
	set_interface_property s1 wellBehavedWaitrequest {0}
	set_interface_property s1 writeLatency {0}
	set_interface_property s1 writeWaitStates {0}
	set_interface_property s1 writeWaitTime {0}

	add_interface_port s1 address address Input $derived_set_addr_width
	
	if { !$writable } {
	  add_interface_port s1 debugaccess debugaccess Input 1
	}
	
	add_interface_port s1 clken clken Input 1
	add_interface_port s1 chipselect chipselect Input 1
	add_interface_port s1 write write Input 1
	add_interface_port s1 readdata readdata Output $dataWidth
	add_interface_port s1 writedata writedata Input $dataWidth
	
	if { $ecc_enabled } {
            set_interface_property s1 bitsPerSymbol "$dataWidth"
        } else {
	    set_interface_property s1 bitsPerSymbol {8}
	    set be_width [ expr $dataWidth/8 ]
	    if { $be_width > 1 } {
	      add_interface_port s1 byteenable byteenable Input $be_width
	    }
        }

	set_interface_assignment s1 embeddedsw.configuration.isMemoryDevice {1}
	set_interface_assignment s1 embeddedsw.configuration.isNonVolatileStorage [ expr !$writable ]

	add_interface reset1 reset sink
	set_interface_property reset1 associatedClock {clk1}
	set_interface_property reset1 synchronousEdges {DEASSERT}

	add_interface_port reset1 reset reset Input 1
	add_interface_port reset1 reset_req reset_req Input 1

	# if dual port, create a second slave
    if { $dualPort } {
      add_interface s2 avalon slave
	
      # If it is dual port, then we need to specify noth ports in the same address group 
      set_interface_property s1 addressGroup {1}
	  set_interface_property s2 addressGroup {1}
	  
	  set_interface_property s2 readLatency $slave2Latency 	  
	  set_interface_property s2 explicitAddressSpan $memorySize  
          set_interface_property s2 addressAlignment {DYNAMIC}
	  set_interface_property s2 addressSpan {4096}
	  set_interface_property s2 addressUnits {WORDS}
	  set_interface_property s2 alwaysBurstMaxBurst {0}
	  if { $singleClockOperation } {
	      set_interface_property s2 associatedClock {clk1}
	      set_interface_property s2 associatedReset {reset1}
	  } else {
	      set_interface_property s2 associatedClock {clk2}
	      set_interface_property s2 associatedReset {reset2}
	  }

	  set_interface_property s2 burstOnBurstBoundariesOnly {0}
	  set_interface_property s2 burstcountUnits {WORDS}
	  set_interface_property s2 constantBurstBehavior {0}
	  set_interface_property s2 holdTime {0}
	  set_interface_property s2 interleaveBursts {0}
	  set_interface_property s2 isBigEndian {0}
	  set_interface_property s2 isFlash {0}
	  set_interface_property s2 isMemoryDevice {1}
	  set_interface_property s2 isNonVolatileStorage {1}
	  set_interface_property s2 linewrapBursts {0}
	  set_interface_property s2 maximumPendingReadTransactions {0}
	  set_interface_property s2 minimumUninterruptedRunLength {1}
	  set_interface_property s2 printableDevice {0}
	  set_interface_property s2 readWaitStates {0}
	  set_interface_property s2 readWaitTime {0}
	  set_interface_property s2 registerIncomingSignals {0}
	  set_interface_property s2 registerOutgoingSignals {0}
	  set_interface_property s2 setupTime {0}
	  set_interface_property s2 timingUnits {Cycles}
	  set_interface_property s2 transparentBridge {0}
	  set_interface_property s2 wellBehavedWaitrequest {0}
	  set_interface_property s2 writeLatency {0}
	  set_interface_property s2 writeWaitStates {0}
	  set_interface_property s2 writeWaitTime {0}
          
	  add_interface_port s2 address2 address Input $derived_set_addr_width
	  add_interface_port s2 chipselect2 chipselect Input 1
	  add_interface_port s2 clken2 clken Input 1
	  add_interface_port s2 write2 write Input 1
	  add_interface_port s2 readdata2 readdata Output $dataWidth
	  add_interface_port s2 writedata2 writedata Input $dataWidth

	  if { $ecc_enabled } {
	      set_interface_property s2 bitsPerSymbol "$dataWidth"
      } else {
          set_interface_property s2 bitsPerSymbol {8}
          if { $be_width > 1 } {
              add_interface_port s2 byteenable2 byteenable Input $be_width
          }
      }

	  # FB 22608 (TODO: to be add in) - missing debugaccess2 signal ineuropa 
	  #if { !$writable } {
	  #  add_interface_port s2 debugaccess debugaccess Input 1
	  #}     
	  
	  set_interface_assignment s2 embeddedsw.configuration.isMemoryDevice {1}
	  set_interface_assignment s2 embeddedsw.configuration.isNonVolatileStorage [ expr !$writable ]
          
	    if { $singleClockOperation } {
	      add_interface clk1 clock sink
	      set_interface_property clk1 clockRate {0.0}
	      set_interface_property clk1 externallyDriven {0}
	      add_interface_port clk1 clk clk Input 1
              
	      add_interface reset1 reset sink
	      set_interface_property reset1 associatedClock {clk1}
	      set_interface_property reset1 synchronousEdges {DEASSERT}
	      add_interface_port reset1 reset reset Input 1
	      add_interface_port reset1 reset_req reset_req Input 1
            } else {
              add_interface clk2 clock sink
	      set_interface_property clk2 clockRate {0.0}
	      set_interface_property clk2 externallyDriven {0}
	      add_interface_port clk2 clk2 clk Input 1
              
	      add_interface reset2 reset sink
	      set_interface_property reset2 associatedClock {clk2}
	      set_interface_property reset2 synchronousEdges {DEASSERT}
	      add_interface_port reset2 reset2 reset Input 1
	      add_interface_port reset2 reset_req2 reset_req Input 1
            }
        } else {
          set_interface_property s1 addressGroup {0}
        }
}

#-------------------------------------------------------------------------------
# module generation
#-------------------------------------------------------------------------------

# generate
proc generate {output_name output_directory rtl_ext simgen} {
	global env
	set QUARTUS_ROOTDIR         "$env(QUARTUS_ROOTDIR)"
	set component_directory     "$QUARTUS_ROOTDIR/../ip/altera/sopc_builder_ip/altera_avalon_onchip_memory2"
	set component_config_file   "$output_directory/${output_name}_component_configuration.pl"

	# read parameter
	set allowInSystemMemoryContentEditor [ proc_get_boolean_parameter allowInSystemMemoryContentEditor ]
	set autoInitializationFileName [ get_parameter_value autoInitializationFileName ]
	set blockType [ get_parameter_value blockType ]
	set dataWidth [ get_parameter_value derived_set_data_width ]
	set deviceFamily [ get_parameter_value deviceFamily ]
	set dualPort [ proc_get_boolean_parameter dualPort ]
	set initMemContent [ proc_get_boolean_parameter initMemContent ]
	set initializationFileName [ get_parameter_value initializationFileName ]
	set instanceID [ get_parameter_value instanceID ]
	set memorySize [ get_parameter_value memorySize ]
	set readDuringWriteMode [ get_parameter_value readDuringWriteMode ]
	set simAllowMRAMContentsFile [ proc_get_boolean_parameter simAllowMRAMContentsFile ]
	set simMemInitOnlyFilename [ get_parameter_value simMemInitOnlyFilename ]
	set singleClockOperation [ proc_get_boolean_parameter singleClockOperation ]
	set slave1Latency [ get_parameter_value slave1Latency ]
	set slave2Latency [ get_parameter_value slave2Latency ]
	set useNonDefaultInitFile [ proc_get_boolean_parameter useNonDefaultInitFile ]
	set useShallowMemBlocks [ proc_get_boolean_parameter useShallowMemBlocks ]
	set writable [ proc_get_boolean_parameter writable ]
	# add derived parameter 
	set derived_gui_ram_block_type [ get_parameter_value derived_gui_ram_block_type ]
	set derived_set_addr_width [ get_parameter_value derived_set_addr_width ]
	set derived_is_hardcopy [ proc_get_boolean_parameter derived_is_hardcopy ]
	set derived_init_file_name [ get_parameter_value derived_init_file_name ] 
	set derived_device_family [ string2upper_noSpace "$deviceFamily" ]
	set ecc_enabled [ proc_get_boolean_parameter ecc_enabled ]

	set blockType [ expr {[ expr {$blockType == "MRAM"}] ? "M-RAM" : "$blockType" }]
	
	# prepare config file
	set component_config    [open $component_config_file "w"]

	puts $component_config "# ${output_name} Component Configuration File"
	puts $component_config "return {"

	puts $component_config "\tallow_mram_sim_contents_only_file	=> $simAllowMRAMContentsFile,"
    	puts $component_config "\tram_block_type           		=> \"$blockType\","
    	
    set init_file_base_name $derived_init_file_name
    # europa dont want the ".hex" if use default name. 
    if { !$useNonDefaultInitFile } {
        set init_file_base_name [ file rootname $derived_init_file_name ]
    }
	puts $component_config "\tinit_contents_file           		=> \'$init_file_base_name\',"
    	puts $component_config "\tnon_default_init_file_enabled         => $useNonDefaultInitFile,"
    	puts $component_config "\tgui_ram_block_type           		=> $derived_gui_ram_block_type,"	
	puts $component_config "\tdevice_family           		=> $derived_device_family,"
    	puts $component_config "\tWriteable           			=> $writable,"
    	puts $component_config "\tdual_port           			=> $dualPort,"
    	puts $component_config "\tsingle_clock_operation           	=> $singleClockOperation,"
    	puts $component_config "\tSize_Value           			=> $memorySize,"
    	puts $component_config "\tSize_Multiple           		=> 1," 	
	puts $component_config "\tuse_shallow_mem_blocks           	=> $useShallowMemBlocks,"
    	puts $component_config "\tinit_mem_content           		=> $initMemContent,"
    	puts $component_config "\tallow_in_system_memory_content_editor	=> $allowInSystemMemoryContentEditor,"
    	puts $component_config "\tinstance_id           		=> $instanceID,"
    	puts $component_config "\tread_during_write_mode           	=> $readDuringWriteMode,"
    	puts $component_config "\tsim_meminit_only_filename           	=> $simMemInitOnlyFilename,"
    	# This extra parameter is used to tell hdl generator to ignore auto ramBlockType assignment
	puts $component_config "\tignore_auto_block_type_assignment     => 1,"
    	
	puts $component_config "\tData_Width           			=> $dataWidth,"
    	puts $component_config "\tAddress_Width        			=> $derived_set_addr_width,"
    	puts $component_config "\tslave1Latency        			=> $slave1Latency,"
    	puts $component_config "\tslave2Latency        			=> $slave2Latency,"
    	puts $component_config "\tderived_is_hardcopy        		=> $derived_is_hardcopy,"
    	puts $component_config "\tecc_enabled             		=> $ecc_enabled,"
    	
   
	puts $component_config "};"
	close $component_config

	# generate rtl
	proc_generate_component_rtl  "$component_config_file" "$component_directory" "$output_name" "$output_directory" "$rtl_ext" "$simgen"
	proc_add_generated_files "$output_name" "$output_directory" "$rtl_ext" "$simgen"
}

