#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: EyalD                                                #
#====================================================================#
# Description: report worst slack for each timing group              #
# in a table format                                                  #
#====================================================================#
# Example: wgs                                                       #
#====================================================================#



proc wgs {args} {

    global synopsys_program_name

    set results(-neg_only) {0}
    set results(-min) {false}
    set results(-slack_lesser_than) {}
    #-- parse command line arguments
    parse_proc_arguments -args $args results
    foreach v [array names results] {
        regsub {^\-} $v {} vn
        eval "set i_${vn} \$results($v)"
    }
    
    set max_path_group_name_length 0 
    array unset group_array
    array unset group_array_sorted

    #-- get all groups and slacks
    foreach_in_collection path_group_ [get_path_groups] {
        if {$synopsys_program_name == "pt_shell"} {	
	    set grp [get_object_name $path_group_ ]
	        if {$i_min != "false"} {
	            set slack [get_attribute [get_timing_paths -delay_type min -group [get_path_group $path_group_]] slack]
	        } else {
	            set slack [get_attribute [get_timing_paths -group [get_path_group $path_group_]] slack]
	        }
        } else {
	        set grp [get_object_name [ get_path_group $path_group_ ]]
	        if {$i_min != "false"} {
	            set slack [get_attribute [get_timing_paths -delay_type min -group $grp] slack]
	        } else {
	            set slack [get_attribute [get_timing_paths -group $grp] slack]
            }
        }
	set group_array($slack) $grp
    }

    #-- sort the array by slack (decreasing)
    foreach slack_ [lsort -decreasing [array names group_array]] {
	set group_ $group_array($slack_)	
	set group_array_sorted($group_) $slack_
    }

    #-- get the max length of group name (for printing)
    foreach slack_ [lsort [array names group_array]] {
	    set group_ $group_array($slack_)
    	if {$i_neg_only} {
	        if {$slack_ < 0} {
		        if {[string length $group_] > $max_path_group_name_length} {
		            set max_path_group_name_length [string length $group_]
		        }
	        }
	    } elseif {$i_slack_lesser_than != ""} {
	        if {$slack_ < $i_slack_lesser_than} {
		        if {[string length $group_] > $max_path_group_name_length} {
		            set max_path_group_name_length [string length $group_]
		        }
	        }
	    } else {
	        if {[string length $group_] > $max_path_group_name_length} {
		        set max_path_group_name_length [string length $group_]
	        }
	    }
    }

    #-- print header
    puts ""
    echo [format "%-${max_path_group_name_length}s | %-12s |" "group name " " WNS"  ]
    set char ""
    set i 0
    set max_char [expr $max_path_group_name_length + 17]
    while {$i < $max_char } {
	set char "${char}\="
	incr i
    }
    puts $char

    #-- print
#    foreach {color count} [array get colorcount] {}
#    foreach {group_ slack_} [array get group_array_sorted] {}
    foreach slack_ [lsort -decreasing [array names group_array]] {
	set group_ $group_array($slack_)	
	if {$i_neg_only} {
	    if {($slack_ < 0) && ($slack_ != "")} {
	        echo [format "%-${max_path_group_name_length}s | %-12s |" $group_ $slack_  ]
	    }
	} elseif {$i_slack_lesser_than != ""} {
	    if {($slack_ < $i_slack_lesser_than) && ($slack_ != "")} {
	        echo [format "%-${max_path_group_name_length}s | %-12s |" $group_ $slack_  ]
	    }
	} else {
	    echo [format "%-${max_path_group_name_length}s | %-12s |" $group_ $slack_  ]
	}
    }
    puts ""
}

define_proc_attributes wgs \
    -info "report wns for each path_group" \
    -define_args {
	{-neg_only           "only negative paths"                         "" boolean optional}
	{-min                "only hold paths "                            "" boolean optional}	
	{-slack_lesser_than  "only paths with slack lesser than <value>"   "" float optional}
}
