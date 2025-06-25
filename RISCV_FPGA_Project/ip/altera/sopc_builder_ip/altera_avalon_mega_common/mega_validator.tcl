# +----------------------------------------------------------
# | 
# | Name: mega_validator.tcl
# |
# | Description: Common *_hw.tcl code for the integration 
# | 		 of the Altera megafunctions with the SOPC
# | 		 Builder environemnet
# |
# | Version: 1.0
# |
# | Avalon-compatible Altera PLL module
# |
# +----------------------------------------------------------
package require -exact sopc 9.1

set qrd $env(QUARTUS_ROOTDIR)
set_module_property helper_jar $qrd/../ip/altera/sopc_builder_ip/altera_avalon_mega_common/JRValidator.jar

	
# ----------------------------------------------------
# |  
# |  validate
# |
# |  
# |  
# ----------------------------------------------------
proc validate {input_name_value_list} {
	set result [join $input_name_value_list | ]
	set validation_result [call_helper doValidation $result ]
}
