# Acquire Pacakges
package require ::quartus::flow
package require ::quartus::project
package require ::quartus::report
package require ::quartus::device 1.0

# Setup Variables
set pci_lite_source_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/altera_avalon_pci_lite"
set pci_lite_tb_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/altera_avalon_pci_lite/pci_sim/verilog/pci_lite"

puts "\n****************************************"
puts "Info: Setting up PCI Lite for Simulation"

	# Check Project and SOPC System
	if {[project_exists .]} {
		puts "Info: Project Exist"
		set findSopcFile [glob *.sopc]
		set sopcFileList [split $findSopcFile " "]
		set fileCounter 0
		foreach file $sopcFileList {
			incr fileCounter 
			set sopcFile $file
		}
		if {$fileCounter=="1"} {
			set sopcName [split $sopcFile "."]
			set sopcName [lindex $sopcName 0]
			puts "Info: Found System - $sopcName"
		} else {
			puts "*****************************"
			puts "Error: Too many SOPC Systems"
			error ""
		}
	
	# Check PCI Lite existance in System
	set sim_dir "$sopcName\_sim"
	set lite_check [open "$sopcFile" r]
	set lite_data [read $lite_check]
	close $lite_check

	set datas [split $lite_data "\n"]
	set moduleFound 0
	set moduleCounter 0
	set liteModuleName 0
		foreach data $datas {
			set result [regexp {.*kind="pci_lite".*} $data]
			if {$result} {
				regexp {<module name="([a-z].+)" kind="pci_lite".*>} $data temp liteModuleName 			
				set moduleFound 1
				incr moduleCounter
			}
		}
		if {$moduleCounter>1} {
			puts "****************************************"
			puts "Error: Too many PCI Lite found in system"
		}
		if {$moduleFound} {
			puts "Info: Found PCI Lite Module - $liteModuleName"
		} else { 
			puts "*******************************"
			puts "Error: No PCI Lite Module found"
			error ""
		}

	# Check PCI Lite Mode
	set mode_check [open "$sopcFile" r]
	set mode_data [read $mode_check]
	close $mode_check

	set datas [split $mode_data "\n"]
	set value 1
	set mode "master"
		foreach data $datas {
			set result [regexp {.*parameter name="MASTER_ENABLE".*} $data]
			if {$result} {
				regexp {<parameter name="MASTER_ENABLE" value="([0-9])" />} $data temp value
				if {$value=="0"} {
					set mode "target"
				}
			}
		}
	
	# Check Simulation Folder
	
	if {[file exists $sim_dir]} {
		puts "Info: Found Simulation Folder - $sim_dir"

	# Append pci_tb block into top level system file
	set tb_check [open "$sopcName\.v" r]
	set tb_data [read $tb_check]
	close $tb_check

	set datas [split $tb_data "\n"]
	set foundBlock 0
	set tbFound 0
		foreach data $datas {
			set result [regexp {  (pci_tb the_pci_tb)} $data]
			if {$result} {
				set foundBlock 1
			}
		}
		if {$foundBlock} {
		} else {
			set new_tb_check [open "$sopcName\.v.temp" w]
			foreach data $datas {
				set result1 [regexp {module test_bench} $data]
				set result2 [regexp {.+\);} $data]
				if {$result1} {
					set tbFound 1
				}
				if {$result2 && $tbFound} {
				  if {$mode=="master"} {
					puts $new_tb_check $data
					puts $new_tb_check ""
					puts $new_tb_check "  pci_tb the_pci_tb"
					puts $new_tb_check "    ("
					puts $new_tb_check "      .ad               (ad_to_and_from_the_lite),"
					puts $new_tb_check "      .cben             (cben_to_and_from_the_lite),"
					puts $new_tb_check "      .clk              (clk),"
					puts $new_tb_check "      .clk_pci_compiler (clk_pci_compiler),"
					puts $new_tb_check "      .devseln          (devseln_to_and_from_the_lite),"
					puts $new_tb_check "      .framen           (framen_to_and_from_the_lite),"
					puts $new_tb_check "      .gntn             (gntn_to_the_lite),"
					puts $new_tb_check "      .idsel            (idsel_to_the_lite),"
					puts $new_tb_check "      .intan            (intan_from_the_lite),"
					puts $new_tb_check "      .irdyn            (irdyn_to_and_from_the_lite),"
					puts $new_tb_check "      .par              (par_to_and_from_the_lite),"
					puts $new_tb_check "      .perrn            (perrn_to_and_from_the_lite),"
					puts $new_tb_check "      .reqn             (reqn_from_the_lite),"
					puts $new_tb_check "      .rstn             (rstn),"
					puts $new_tb_check "      .serrn            (serrn_to_and_from_the_lite),"
					puts $new_tb_check "      .stopn            (stopn_to_and_from_the_lite),"
					puts $new_tb_check "      .trdyn            (trdyn_to_and_from_the_lite)"
					puts $new_tb_check "    );"
				  } elseif {$mode=="target"} {
		  			puts $new_tb_check $data
					puts $new_tb_check ""
					puts $new_tb_check "  pci_tb the_pci_tb"
					puts $new_tb_check "    ("
					puts $new_tb_check "      .ad               (ad_to_and_from_the_lite),"
					puts $new_tb_check "      .cben             (cben_to_and_from_the_lite),"
					puts $new_tb_check "      .clk              (clk),"
					puts $new_tb_check "      .clk_pci_compiler (clk_pci_compiler),"
					puts $new_tb_check "      .devseln          (devseln_to_and_from_the_lite),"
					puts $new_tb_check "      .framen           (framen_to_and_from_the_lite),"
					puts $new_tb_check "      .idsel            (idsel_to_the_lite),"
					puts $new_tb_check "      .intan            (intan_from_the_lite),"
					puts $new_tb_check "      .irdyn            (irdyn_to_and_from_the_lite),"
					puts $new_tb_check "      .par              (par_to_and_from_the_lite),"
					puts $new_tb_check "      .perrn            (perrn_to_and_from_the_lite),"
					puts $new_tb_check "      .rstn             (rstn),"
					puts $new_tb_check "      .serrn            (serrn_to_and_from_the_lite),"
					puts $new_tb_check "      .stopn            (stopn_to_and_from_the_lite),"
					puts $new_tb_check "      .trdyn            (trdyn_to_and_from_the_lite)"
					puts $new_tb_check "    );"			  
				  }
				} else {
					puts $new_tb_check $data 
				}
			}
			close $new_tb_check
			file rename -force "$sopcName\.v" "$sopcName\.v.old"
			file rename -force "$sopcName\.v.temp" "$sopcName\.v"
			file delete -force "$sopcName.v.old"
			file delete -force "$sopcName.v.temp"

		}
				

	# Copying required files
	# 1. Constraint File
	# 2. Master Transactor Files
		set file_list [list "$pci_lite_tb_dir/mstr_pkg.v" "$pci_lite_tb_dir/mstr_tranx.v"]
		foreach fileName $file_list {
			file copy -force $fileName .
		}
		puts "Info: Copied Files"
	
	# Modifying mstr_tranx for target mode
	if {$mode=="target"} {
		set tb_file [open "mstr_tranx.v" r]	
		set new_tb_file [open "mstr_tranx.v.temp" w]	
		set tb_file_data [read $tb_file]
		close $tb_file

		set datas [split $tb_file_data "\n"]
		foreach data $datas {
			set match1 [regexp {`define trgt.*} $data]
			set match2 [regexp {cfg_wr.*trgt_tranx.*} $data]
		        set match3 [regexp {cfg_rd.*trgt_tranx.*} $data]	
			if {$match1 || $match2 || $match3} {
				puts $new_tb_file "      //$data" 
			} else {
				puts $new_tb_file $data 
			}
		}
		close $new_tb_file
		file rename -force "mstr_tranx.v" "mstr_tranx.v.old"
		file rename -force "mstr_tranx.v.temp" "mstr_tranx.v"
		file delete -force "mstr_tranx.v.old"
		file delete -force "mstr_tranx.v.temp"
	}

	
	# Check if .do files exist
		set simFileList [list "list_presets.do" "wave_presets.do"]
		foreach file $simFileList {
			if {[file exists $sim_dir/$file]} {
			} else {
				puts "***************************"
				puts "Error: .do files not found."
				error ""	
			}
		}

	# Create PCI Lite Bus Signal in .do files
		set list_presets [open "$sim_dir/list_presets.do" r]
		set list_data [read $list_presets]
		close $list_presets

		set datas [split $list_data "\n"]
		set foundList 0
		foreach data $datas {
			set result [regexp "add list -hex /test_bench/DUT/the_$liteModuleName/ad" $data]
			if {$result} {
				set foundList 1
			}
		}
		if {$foundList} {
		} else {
			set new_list_presets [open "$sim_dir/list_presets.do.temp" w]
			foreach data $datas {
				if {$data=="onerr {resume}"} {
					puts $new_list_presets $data
					puts $new_list_presets "add list -hex /test_bench/DUT/the_$liteModuleName/ad"
					puts $new_list_presets "add list -hex /test_bench/DUT/the_$liteModuleName/cben"
					puts $new_list_presets "add list -hex /test_bench/DUT/the_$liteModuleName/devseln"
					puts $new_list_presets "add list -hex /test_bench/DUT/the_$liteModuleName/framen"
					puts $new_list_presets "add list -hex /test_bench/DUT/the_$liteModuleName/irdyn"
					puts $new_list_presets "add list -hex /test_bench/DUT/the_$liteModuleName/par"
					puts $new_list_presets "add list -hex /test_bench/DUT/the_$liteModuleName/perrn"
					puts $new_list_presets "add list -hex /test_bench/DUT/the_$liteModuleName/rstn"
					puts $new_list_presets "add list -hex /test_bench/DUT/the_$liteModuleName/serrn"
					puts $new_list_presets "add list -hex /test_bench/DUT/the_$liteModuleName/stopn"
					puts $new_list_presets "add list -hex /test_bench/DUT/the_$liteModuleName/trdyn"
				} else {	
					puts $new_list_presets $data
				}
			}
			close $new_list_presets
			file rename -force "$sim_dir/list_presets.do" "$sim_dir/list_presets.do.old"
			file rename -force "$sim_dir/list_presets.do.temp" "$sim_dir/list_presets.do"
			file delete -force "$sim_dir/list_presets.do.old"
			file delete -force "$sim_dir/list_presets.do.temp"

		}
	
		set wave_presets [open "$sim_dir/wave_presets.do" r]
		set wave_data [read $wave_presets]
		close $wave_presets
	
		set datas [split $wave_data "\n"]
		set foundList 0
		foreach data $datas {
			set result [regexp "add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_$liteModuleName/ad" $data]
			if {$result} {
				set foundList 1
			}
		}
		if {$foundList} {
		} else {
			set new_wave_presets [open "$sim_dir/wave_presets.do.temp" w]
			puts $new_wave_presets "# Display signals from module pci_compiler"
			puts $new_wave_presets "add wave -noupdate -divider {pci_lite}"
			puts $new_wave_presets "add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_$liteModuleName/ad"
			puts $new_wave_presets "add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_$liteModuleName/cben"
			puts $new_wave_presets "add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_$liteModuleName/devseln"
			puts $new_wave_presets "add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_$liteModuleName/framen"
			puts $new_wave_presets "add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_$liteModuleName/irdyn"
			puts $new_wave_presets "add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_$liteModuleName/par"
			puts $new_wave_presets "add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_$liteModuleName/perrn"
			puts $new_wave_presets "add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_$liteModuleName/rstn"
			puts $new_wave_presets "add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_$liteModuleName/serrn"
			puts $new_wave_presets "add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_$liteModuleName/stopn"
			puts $new_wave_presets "add wave -noupdate -format Logic -radix hexadecimal /test_bench/DUT/the_$liteModuleName/trdyn"
		
			foreach data $datas {
				puts $new_wave_presets $data
			}
			close $new_wave_presets
			file rename -force "$sim_dir/wave_presets.do" "$sim_dir/wave_presets.do.old"
			file rename -force "$sim_dir/wave_presets.do.temp" "$sim_dir/wave_presets.do"	
			file delete -force "$sim_dir/wave_presets.do.old"
			file delete -force "$sim_dir/wave_presets.do.temp"

		}
	
	} else {
		puts "**********************************"
		puts "Error: Simulation Folder Not Found"
		error ""
	}


	} else {
		puts "*****************************"
		puts "Error: Project does not exist"
		error ""
	}

puts "*******************************************************************"
puts "Info: PCI Lite Simulation Setup Finished Successfully."
puts ""



