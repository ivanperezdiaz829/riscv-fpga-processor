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


package provide alt_xcvr::utils::fileset 11.1

namespace eval ::alt_xcvr::utils::fileset:: {
  namespace export \
    is_hdl_source_file \
    common_fileset_group \
    common_fileset_group_plain \
    common_fileset_tags_all_simulators \
    common_fileset_group_encrypted \
    common_find_sim_encrypt_dir \
    common_enable_summary_sim_support_warnings \
    common_add_fileset_files \
    common_add_fileset_for_tool \
    get_alt_xcvr_path \
    get_altera_xcvr_generic_path \
    abs_to_rel_path \
    rel_to_abs_path

    # record fileset files paths, type and tags
    # each entry is a list: [list $destDirNs/$fsFile $fileType $tags $toolFlowTags ]
    # $tags and $toolFlowTags are sub-lists
    variable common_fsf
    array set common_fsf {}
    # if marked 0, means simulator-specific file was missing
    variable common_sim_support
    array set common_sim_support {}
    # show a single warning per sim vendor for missing files
    variable common_summary_sim_support_warnings 0
    # fileset file order
    variable common_fsf_order {}
}

proc alt_xcvr::utils::fileset::is_hdl_source_file { fileName } {
  if {[file extension $fileName] == ".v" ||
      [file extension $fileName] == ".sv" ||
      [file extension $fileName] == ".vhd" } {
    return 1
  }
  return 0
}

######################################
# +-----------------------------------
# | Fileset management via tagging
# +-----------------------------------
######################################


# +-------------------------------------------------------------------------
# | Tag each fileset file with given implementation tags and tool-flow tags
# | 
# | Implementation tags are user-defined.
# | Tool-flow tags must be the following:
# | 	tool-flow tag        'add_fileset_file' mapping
# | 	   {PLAIN}            {SYNTHESIS} and {SIMULATION} (all simulators)
# | 	   {QENCRYPT}         {SYNTHESIS} only
# | 	   {MENTOR}           {MENTOR_SPECIFIC}
# | 	   {CADENCE}          {CADENCE_SPECIFIC}
# | 	   {SYNOPSYS}         {SYNOPSYS_SPECIFIC}
# | 	   {ALDEC}            {ALDEC_SPECIFIC}
# | 
# | $fileType can be AUTOTYPE or AUTOTYPE_ENCRYPT for auto-selection by extension
# | 
proc alt_xcvr::utils::fileset::common_fileset_group {destDir srcDir fileType fileList tags toolFlowTags} {
	variable common_fsf
	variable common_sim_support
	variable common_fsf_order

	#set srcDirNs [string trimright $srcDir "/\\"] ;# remove trailing slash
	regsub -all {([^/])//+} $srcDir {\1/} srcDirSi0	;# simplify "dir//" to "dir/"
	regsub -all {/[^.][^/]+/[.][.]/} $srcDirSi0 {/} srcDirSi	;# simplify "/dir/../" combinations
	set srcDirNs [string trimright $srcDirSi "/\\"] ;# remove trailing slash
	set destDirNs [string trimright $destDir "/\\"] ;# remove trailing slash

  # Convert QUARTUS_ROOTDIR paths to relative paths for ACDS environment
  set srcDirNs [rel_to_abs_path $srcDirNs]
  set cwdDir [pwd]
  set srcStart [string first "ip/altera/" $srcDirNs ]
  set cwdStart [string first "ip/altera/" $cwdDir ]
  if {$srcStart != -1 && $cwdStart != -1} {
    set cwdDir [string replace $cwdDir $cwdStart end]
    set srcStart [expr $srcStart - 1]
    set srcDirNs [string replace $srcDirNs 0 $srcStart $cwdDir]
  }
  set srcDirNs [abs_to_rel_path $srcDirNs]

	# save each potential fileset file with associated tags for later retrieval
	set fileSetFiles {}
	foreach f $fileList {
		if {[string first "*" $f ] > -1} {
			foreach fTail [glob -nocomplain $srcDirNs/$f ] {
				lappend fileSetFiles [file tail $fTail]
			}
		} else {
			# no wildcard, just append
			lappend fileSetFiles $f
		}
	}

	if {[llength $fileSetFiles] > 0} {

		# remember each file
		foreach fsFile $fileSetFiles {
			if {[file exists $srcDirNs/$fsFile]} {

				# get type based on extension for autotypes
				set fExt [file extension $fsFile]
				if {$fExt == ".v"} {
					set plainType VERILOG
				} elseif {$fExt == ".sv"} {
					set plainType SYSTEM_VERILOG
				} elseif {$fExt == ".vhd"} {
					set plainType VHDL
				} else {
					set plainType OTHER
				}

				# get file type
				if {$fileType == "AUTOTYPE"} {
					set fileTypeR ${plainType}
				} elseif {$fileType == "AUTOTYPE_ENCRYPT"} {
					set fileTypeR "${plainType}_ENCRYPT"
				} else {
					set fileTypeR $fileType
				}

				# save fileset details
				set fsfData [list $destDirNs/$fsFile $fileTypeR $tags $toolFlowTags ]
				if {[ info exists common_fsf($srcDirNs/$fsFile) ]} {
					# foreach abuse, just expands list into multiple variables
					foreach {oldDestFile oldFileType oldTags oldToolFlowTags} $common_fsf($srcDirNs/$fsFile) {break}
					
					# merge tag sets with existing entry
					set newTags [common_merge_lists $tags $oldTags ]
					set newToolFlowTags [common_merge_lists $toolFlowTags $oldToolFlowTags ]
					set fsfData [list $destDirNs/$fsFile $fileTypeR $newTags $newToolFlowTags ]
					
					#send_message warning "common_fileset_group{}: merged tags now $fsfData"
				} else {
					# first time file is added, append to fileset file order list
					lappend common_fsf_order "$srcDirNs/$fsFile"
				}
				set common_fsf($srcDirNs/$fsFile) $fsfData
			} else {
				# file doesn't exist
				set tagsForAllSimulators [common_fileset_tags_all_simulators]
				if {[lsearch -exact $tagsForAllSimulators $toolFlowTags ] < 0 } {
					# warn for files other than simulator encrypted files
					send_message warning "common_fileset_group{}: $srcDirNs/$fsFile is not a valid file"
				}
			}
		}
	} else {
		# no files found - flag an error
		send_message warning "common_fileset_group{}: $srcDirNs/$fileList returns an empty file list"
	}
}

# +---------------------------------------------------------------------------------------
# | Tag each fileset file with given implementation tags, and add {PLAIN MENTOR} tool-flow tags
# | 
# | This is a helper function for the very common case of plain text .v/.sv source
# | that must also be encrypted in Mentor simulators for:
# | (1) VHDL simulation support, (2) OEM simulation in both languages
# | 
proc alt_xcvr::utils::fileset::common_fileset_group_plain {destDir srcDir fileList tags} {
	set srcDirNs [string trimright $srcDir "/\\"] ;# remove trailing slash
	set destDirNs [string trimright $destDir "/\\"] ;# remove trailing slash

	# Plain-text file for most uses
	common_fileset_group $destDirNs $srcDirNs AUTOTYPE $fileList $tags {PLAIN}

	# Mentor-specific encrypted files in mentor/ sub-directory
	set srcEncrypt [common_find_sim_encrypt_dir $srcDirNs mentor ]	;# find mentor directory
	if {$srcEncrypt != "missing"} {
		common_fileset_group $destDirNs/mentor $srcEncrypt AUTOTYPE_ENCRYPT $fileList $tags {MENTOR}
	}
}

# +---------------------------------------------------------------------------------------
# | Return list of tags for all supported simulators
# | 
proc alt_xcvr::utils::fileset::common_fileset_tags_all_simulators {} {
	return [list MENTOR CADENCE SYNOPSYS ALDEC ]
}

# +---------------------------------------------------------------------------------------
# | Tag each fileset file with given implementation tags, and add these tool-flow tags:
# | 	{QENCRYPT MENTOR CADENCE SYNOPSYS ALDEC}
# | 
# | This is a helper function for the common case of encrypted .v/.sv source
# | that must be encrypted for Quartus and all simulators
# | 
proc alt_xcvr::utils::fileset::common_fileset_group_encrypted {destDir srcDir fileList tags} {
	set srcDirNs [string trimright $srcDir "/\\"] ;# remove trailing slash 
	set destDirNs [string trimright $destDir "/\\"] ;# remove trailing slash 

	# Quartus encrypted file
	common_fileset_group $destDirNs $srcDirNs AUTOTYPE_ENCRYPT $fileList $tags {QENCRYPT}

	# simulator-specific encrypted files in sub-directories
	foreach sim [common_fileset_tags_all_simulators] {
		set simLc [string tolower $sim ]
		set srcEncrypt [common_find_sim_encrypt_dir $srcDirNs $simLc ]
		if {$srcEncrypt != "missing"} {
			common_fileset_group $destDirNs/$simLc $srcEncrypt AUTOTYPE_ENCRYPT $fileList $tags $sim
		}
	}
}

# +---------------------------------------------------------------------------------------
# | Attempt to find a vendor-named directory for the given source directory
# | 
proc alt_xcvr::utils::fileset::common_merge_lists {l1 l2} {
	array set eMap {}
	foreach e [concat $l1 $l2 ] {
		set eMap($e) 1
	}
	return [array names eMap ]
}

# +---------------------------------------------------------------------------------------
# | Attempt to find a vendor-named directory for the given source directory
# | 
proc alt_xcvr::utils::fileset::common_find_sim_encrypt_dir {srcDirNs simLc} {
	variable common_summary_sim_support_warnings
	variable common_sim_support

	set srcEncrypt "$srcDirNs/$simLc"
	if { ! [file isdirectory $srcEncrypt ] } {
		set fDirs [file split $srcDirNs ]	;# try moving the sim directory up level(s)

		# try all levels above bottom level
		set numDirs [llength $fDirs ]
		set i [expr $numDirs - 1 ]
		while {$i >= 0} {
			if {$i > 0} {
				set fDirsBefore [lrange $fDirs 0 [expr $i - 1] ]
			} else {
				set fDirsBefore {}
			}
			set fDirsAfter [lrange $fDirs $i end ]
			set srcEncrypt1 [join [concat $fDirsBefore $simLc $fDirsAfter ] "/" ]
			
			# check if this directory exists
			if {[file isdirectory $srcEncrypt1 ] } {
				set srcEncrypt $srcEncrypt1	;# found a matching vendor directory
				break
			}
			incr i -1
		}
		
		# vendor directory not found, issue warning?
		if {![file isdirectory $srcEncrypt1 ]} {
			# summary warning only per sim vendor
			if {! [info exists common_sim_support($simLc) ] } {
				set Vendor [string totitle $simLc ]
				#send_message warning "Simulation libraries for $Vendor simulators may not be present"
				set common_sim_support($simLc) 1	;# value not important, only existence of value
			}
			set srcEncrypt "missing"	;# no matching vendor directory found
		}
	}
	return $srcEncrypt
}

# +---------------------------------------------------------------------------------------
# | Identify fileset files with given implementation tags, and given tool-flow tags
# | 
proc alt_xcvr::utils::fileset::common_enable_summary_sim_support_warnings {enable} {
	variable common_summary_sim_support_warnings
	set common_summary_sim_support_warnings $enable
}

# +---------------------------------------------------------------------------------------
# | Identify fileset files with given implementation tags, and given tool-flow tags
# | 
proc alt_xcvr::utils::fileset::common_add_fileset_files {tags toolFlowTags} {
	variable common_fsf
	variable common_fsf_order

	# save fileset details
	#set common_fsf($srcDirNs/$fsFile) [list $destDirNs/$fsFile $fileType $tags $toolFlowTags ]
	set tagsForAllSimulators [common_fileset_tags_all_simulators]
        set file_suffix "_files"
        
        # Create file list arrays (used to generate listing file)
        foreach tag $toolFlowTags {
          set genFile [string tolower "${tag}${file_suffix}"]
          set genFileList "${genFile}List"
          array set $genFile {} 
          set $genFileList {}
        }

	# find all saved fileset files that match implementation and tool-flow tags
	foreach srcPath $common_fsf_order {
    if {[file exists $srcPath]} {
		  # abuse of 'foreach' to extract list data into multiple variables
		  foreach {destPath fileType srcTags srcToolFlowTags} $common_fsf($srcPath) { break }
      #puts "File: $srcPath : ${srcTags}"
		  set tagMatch [common_has_matching_list_entry $srcTags $tags]
                  set fname [file tail $destPath]
		  
		  if {$tagMatch} {
		  	# add this entry to the current fileset
		  	set matchingTools [common_get_matching_list_entries $srcToolFlowTags $toolFlowTags]
		  	
		  	foreach toolTag $matchingTools {
		  		if {[lsearch -exact $tagsForAllSimulators $toolTag ] > -1 } {
		  			# simulator tag translation
		  			send_message info "add_fileset_file $destPath $fileType PATH $srcPath ${toolTag}_SPECIFIC"
		  			add_fileset_file $destPath $fileType PATH $srcPath "${toolTag}_SPECIFIC"

                                          # Add file to array and list (replace non-specific version if it exists)
                                          set genFile [string tolower "${toolTag}${file_suffix}"]
                                          set genFileList "${genFile}List"
                                          set ${genFile}($fname) $destPath
                                          if {[lsearch [set $genFileList] $fname] == -1} {
                                            lappend $genFileList $fname
                                          }
		  		} else {
		  			# plain-text, Quartus encrypted, or other - no tool attributes needed
		  			send_message info "add_fileset_file $destPath $fileType PATH $srcPath"
		  			add_fileset_file $destPath $fileType PATH $srcPath

                                          # Add files to generated file list
                                          foreach tag $toolFlowTags {
                                            set genFile [string tolower "${tag}${file_suffix}"]
                                            set genFileList "${genFile}List"
                                            array set thisArray [array get $genFile]
                                            # Don't add the plain file if there is a specific version
                                            if {[lsearch [set $genFileList] $fname] == -1 } {
                                              set ${genFile}($fname) $destPath
                                              lappend $genFileList $fname
                                            }
                                          }
		  		}
		  	}
		  }
    }
	}

        # Generate source file lists for each tag
        foreach tag $toolFlowTags {
          if {[lsearch -exact {QIP} $tag ] == -1 } {
            set genFile [string tolower "${tag}${file_suffix}"]
            array set thisArray [array get $genFile]
            set filestring ""
            foreach f [set $genFileList] {
              if { [info exists thisArray($f) ] } {
                set thisString $thisArray($f)
                if { [is_hdl_source_file $thisString] } {
                  set filestring "${filestring}${thisString}\n"
                }
              }
            }
            # Add generated file list to fileset
            add_fileset_file "${genFile}.txt" OTHER TEXT $filestring
          }
        }
}

# +---------------------------------------------------------------------------------------
# | Find intersection (common elements) of two lists
# | 
proc alt_xcvr::utils::fileset::common_get_matching_list_entries {l1 l2} {
	set res {}
	foreach element $l1 {
		if {[lsearch -exact $l2 $element] >= 0} {
			lappend res $element
		}
	}
	return $res
}

# +---------------------------------------------------------------------------------------
# | Return true if the given lists have any common elements
# | 
proc alt_xcvr::utils::fileset::common_has_matching_list_entry {l1 l2} {
	set found 0
	foreach element $l1 {
		if {[lsearch -exact $l2 $element] >= 0} {
			set found 1 ; break
		}
	}
	return $found
}

# +------------------------------------------
# | Define fileset by family for given tools
# | Helper when using common tags:
# |  - ALL_HDL, C4, S4, S5, A5, C5
# | 
proc alt_xcvr::utils::fileset::common_add_fileset_for_tool {tool} {

	# S4-generation family?
	set device_family [get_parameter_value device_family]
	if { [has_s4_style_hssi $device_family] } {
		common_add_fileset_files {S4 ALL_HDL} $tool
	} elseif { [has_c4_style_hssi $device_family] } {
		# C4 and derivatives
		common_add_fileset_files {C4 ALL_HDL} $tool
	} elseif { [has_s5_style_hssi $device_family] } {
		# S5 and derivatives
		common_add_fileset_files {S5 ALL_HDL} $tool
	} elseif { [has_a5_style_hssi $device_family] } {
		# A5 and derivatives
		common_add_fileset_files {A5 ALL_HDL} $tool
	} elseif { [has_c5_style_hssi $device_family] } {
		# A5 and derivatives
		common_add_fileset_files {C5 ALL_HDL} $tool
	} else {
		# Unknown family
		send_message error "Current device_family ($device_family) is not supported"
	}
}


proc alt_xcvr::utils::fileset::get_alt_xcvr_path {} {
  set quartus_rootdir $::env(QUARTUS_ROOTDIR)
  return "${quartus_rootdir}/../ip/altera/alt_xcvr"
}

## NOTE - Please don't continue this practice. This function was placed here as a
# temporary exception in the expectation that the functionality of "altera_xcvr_generic"
# will be relocated here at some point.
proc alt_xcvr::utils::fileset::get_altera_xcvr_generic_path {} {
  set quartus_rootdir $::env(QUARTUS_ROOTDIR)
  return "${quartus_rootdir}/../ip/altera/altera_xcvr_generic"
}


proc alt_xcvr::utils::fileset::abs_to_rel_path {absPath} {
  set cwd [pwd]
  set absPath [rel_to_abs_path $absPath]
  #return [::fileutil::relative $cwd $absPath]; #Not supported with current TCL interpreter
  set separator "/";#[file separator $cwd]
  set relCwd [file split $cwd] 
  set relPath [file split $absPath]

  #for {set i 0} {$i < [llength $relCwd]} {incr i} {
  #  set arg [lindex $relCwd $i]
  #  puts "${i}:${arg}\n"
  #}
  #for {set i 0} {$i < [llength $relPath]} {incr i} {
  #  set arg [lindex $relPath $i]
  #  puts "${i}:${arg}\n"
  #}

  set sameCount 0
  while {[expr {$sameCount < [llength $relCwd]}] && [expr {$sameCount < [llength $relPath]}] \
          && [expr {[lindex $relCwd $sameCount] == [lindex $relPath $sameCount]}]} {
    incr sameCount
  }
  
  set prefix ""
  set relHops 0
  set relHops [llength $relCwd]
  if {$sameCount != 0} {
    set relHops [expr {$relHops - $sameCount}]
  }
  #puts "relHops:$relHops\n"
  #puts "sameCount:$sameCount\n"

  if {$sameCount == [llength $relCwd]} {
    set prefix  ".${separator}"
  } else {
    for {set i 0} {$i < $relHops} {incr i} {
      set prefix "..${separator}${prefix}"
    }
  }

  # Remove unneeded absolute prefix
  set relPath [lreplace $relPath 0 [expr {$sameCount - 1}]]
  
  for {set i 0} {$i < [llength $relPath]} {incr i} {
    set prefix [file join $prefix [lindex $relPath $i]]
  }
  return $prefix
}


proc alt_xcvr::utils::fileset::rel_to_abs_path {relPath} {
  set cwd [pwd]
  set fullPath [file join $cwd $relPath]
  set fullList [file split $fullPath]
  
  #puts "fullPath: $fullPath"
  set i 0
  while {$i < [llength $fullList]} {
    set var [lindex $fullList $i]
    #puts "i=${i}"
    #puts "lindex fullList: ${var}"
    #puts "llength fullList [llength $fullList]"
    if {$var == "."} {
      set fullList [lreplace $fullList $i $i]
    } elseif {$var == ".."} {
      if {$i > 0} {
        set fullList [lreplace $fullList $i $i]
        set i [expr $i - 1]
      }
      set fullList [lreplace $fullList $i $i]
    } else {
      incr i
    }
  }

  set fullPath ""
  for {set i 0} {$i < [llength $fullList]} {incr i} {
    set fullPath [file join $fullPath [lindex $fullList $i]]
  }

  return $fullPath
}

