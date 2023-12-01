proc create_hotspot_marker {args} {
    parse_proc_arguments -args $args option
    set name $option(-marker_type)
    set col $option(-color)
    set filename $option(-out_file)
    if {! [info exists option(-color)]} {
        set col "blue"
    }
    set file [open $filename w]
    set rCong ""
    if {[llength [get_db markers .user_type $name ]] > 0 } {
        if {[is_common_ui_mode]} {puts $file "if {\[llength \[get_db markers .user_type $name\]\]} {eval_legacy {violationBrowserDelete -tool Other -type $name}}"} else {puts $file "if {\[llength \[get_db markers .user_type $name\]\]} {violationBrowserDelete -tool Other -type $name}"}
    }
    if {[is_common_ui_mode]} {
        if { [info exist option(-num_hotspots)]} {
            redirect rCong { [eval_legacy {reportCongestion -hotSpot -includeBlockage -num_hotspot $option(-num_hotspots)} ] } -variable
        } else {
            redirect rCong {[eval_legacy {reportCongestion -hotSpot -includeBlockage}] } -variable
        }
    } else {
        if { [info exist option(-num_hotspots)]} {
            redirect rCong { reportCongestion -hotSpot -includeBlockage -num_hotspot $option(-num_hotspots)  } -variable
        } else {
            redirect rCong {reportCongestion -hotSpot -includeBlockage } -variable
        }
    }
    set splitFileByLine [split $rCong "\n"]
    foreach sp $splitFileByLine {
        #puts $sp
        if {[scan $sp "%s %s %d %s %f %f %f %f %s %f %s" j1 j2 j3 j4 llx lly urx ury j5 j6 j7] == 11} {
     	    set coord "$llx $lly $urx $ury "
    	    join $coord
    	    if {[is_common_ui_mode]} {
    	        set cmd "eval_legacy {createMarker -bbox {${coord}} -type $name}"
    	        puts $file "eval {$cmd}" 
    	    } else {
    	        set cmd "createMarker -bbox {${coord}} -type $name"
    	        puts $file "eval {$cmd}" 
    	    }
        }
    }
    if {[is_common_ui_mode]} {
        puts $file "eval_legacy {violationBrowserHide -all}"
        puts $file "eval_legacy {violationBrowserShow -tool NanoRoute -type Geometry -subtype {Metal Short}}"
        puts $file "eval_legacy {eval {violationBrowserHilite -tool Other -type $name -color $col}}"
        puts $file "eval_legacy {violationBrowserShow -tool Other}"
    } else {
        puts $file "violationBrowserHide -all"
        puts $file "redirect -variable ret {violationBrowserShow -tool NanoRoute -type Geometry -subtype {Metal Short}}"
        puts $file "if {\[regexp {IMPVB-37} \$ret\]} {"
        puts $file "    redirect -variable ret {violationBrowserShow -tool NanoRoute -type Geometry -subtype {Metal_Short}}"
        puts $file "    if {\[regexp {IMPVB-37} \$ret\]} {Puts \"Warning: No shorts found\"}"
        puts $file "}"
        puts $file "eval {violationBrowserHilite -tool Other -type $name -color $col}"
        puts $file "violationBrowserShow -tool Other"
    }
    close $file
}
define_proc_arguments create_hotspot_marker -info "This proc will create marker on the hotspot boxes " \
    -define_args {
        {-num_hotspots "Specify the number of hotspots you want create marker for, defualt is top 5 hotspots" "" integer optional}
        {-marker_type "Specify the name you want to set for the marker" "" string required}
	    {-color "Specify the color you want to set for the hotspot marker" "" string optional}
	    {-out_file "Specify the output file name" "" string required}
    }


