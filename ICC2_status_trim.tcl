
proc status_tim { args } {
        global arr db scenario env DMSA

        if [regexp {\-pba}              $args] { set pba_args "-pba_mode ex" ; set pba_prefix ".pba"    } else { set pba_args "" ; set pba_prefix "" } 
        if [regexp {\-neg_only}         $args] { set neg_only 1                                         } else { set neg_only 0 } 
        if [regexp {\-min}              $args] { set max_or_min "min"  ; set setup_or_hold "hold"       } else { set max_or_min "max" ; set setup_or_hold "setup" } 
        if [regexp {\-expand_groups}    $args] { set expand_groups 1                                    } else { set expand_groups 0 } 
        if [regexp {(\-scenarios)(\s+[\w\{\} ]+)} $args -> a sc] { set scenarios 1; echo "DBG::$sc"          } else { set scenarios 0 } 
        
        file mkdir summary_reports
	array unset db status_tim*${setup_or_hold}*


	set path summary_reports/status_tim.${setup_or_hold}.tcl
	foreach path [glob -nocomplain $path           ] { catch {file delete -force -- $path }}

        set db(status_tim,tcl_table,${setup_or_hold}) ""
        if { [info exist DMSA] && $DMSA == "YES" } { set scenario DMSA }
        
        # --- Parse "report_global_timing" ---
        set wns 0 ; set tns 0 ; set nns 0
        set cmd "report_global_timing -separate_all_groups $pba_args -delay_type $max_or_min"
        if {$scenarios} {set cmd "$cmd -scenarios $sc "}
        redirect -variable cat_file { eval $cmd  }
        set wns_flag 0 ; set tns_flag 0 ; set nns_flag 0 ; set start_group 0 ; set finish_flag 1
        foreach line [split  $cat_file "\n"] {
                if [regexp {(Setup|Hold) violations for paths in (\S+)} $line -> stam group ] { 
                        if !$finish_flag { echo "ERROR: Could not find the requires \"report_global_timing\" filelds!" ; XXX}
                        set finish_flag 0
                        set start_group 1
                }
                if [ regexp {WNS\s+(\S+)} $line -> wns ] { set wns_flag 1 }
                if [ regexp {TNS\s+(\S+)} $line -> tns ] { set tns_flag 1 }
                if [ regexp {NUM\s+(\S+)} $line -> nns ] { set nns_flag 1 }
        
                if { $start_group && $wns_flag     && $tns_flag && $nns_flag } {
                        set db(status_tim,${setup_or_hold},$group) "$wns/$tns/$nns"
                        echo "set db(status_tim,$scenario,${setup_or_hold},$group) $db(status_tim,${setup_or_hold},$group)" >> summary_reports/status_tim.${setup_or_hold}.tcl
                        set wns_flag 0 ; set tns_flag 0 ; set nns_flag 0 ; set start_group 0 ; set finish_flag 1
                }
        }
        
        
        set group_list ""
        if $expand_groups {
                echo "\nThe following froups are going to be expanded:\n"
                foreach ii [array names db status_tim,*$setup_or_hold,*] {
                        #set group [split_index $ii end]
			set group [lindex [split $ii ,] end]
                        regsub -all {\*} $group {\\*} group 
                        echo "\t\t$group"
                        if { ![regexp $group $group_list] && ![regexp INTERNAL $group] } {
                                append group_list " $group "
                        }
                }
                #echo "expand_groups  $group_list $setup_or_hold"
                expand_groups  $group_list $setup_or_hold 

        }
        
        # --- Sort by WNS ---   
        set sorted_table ""
        foreach {k v} [array get db status_tim,${setup_or_hold},* ] {
                #set wns [split_index $v 0 "/" ]
		set wns [lindex [split $v "/"] 0]
                lappend sorted_table "$k\t\t\t $wns"
        }

        append db(status_tim,tcl_table,${setup_or_hold}) "\n\n" 
        append db(status_tim,tcl_table,${setup_or_hold}) "[format "%-*s %-*s %-*s  %-*s"  70  "GROUP NAME ( $setup_or_hold )" 15  "WNS" 15 "TNS" 15 "NNS" ]\n"
	set str "";set str_num 0; while {$str_num<115} {append str "-"; incr str_num}
        append db(status_tim,tcl_table,${setup_or_hold}) "$str\n\n"
        
        foreach line [lsort  -real -index 1 $sorted_table] { 
                set group [lindex [regsub "status_tim,${setup_or_hold}," $line {}] 0]
                
                regsub -all {\*} $group {\\\*} group2 
                if [regexp $group2 $group_list] { continue } 
                set values $db(status_tim,${setup_or_hold},$group)
                #set wns [split_index $values 0 "/" ]
                #set tns [split_index $values 1 "/" ]
                #set nns [split_index $values 2 "/" ]
		set wns [lindex [split $values "/"] 0]
		set tns [lindex [split $values "/"] 1]
		set nns [lindex [split $values "/"] 2]
                if { $wns <0 } {
                append db(status_tim,tcl_table,${setup_or_hold}) "[format "%-*s %-*s %-*s  %-*s"  70  $group 15  $wns 15 $tns 15 $nns ]\n"
                }
        }
        # Total wns\tns\nns
        set wns 0 ; set tns 0 ; set nns 0
        set cmd "report_global_timing $pba_args -delay_type $max_or_min"
        if {$scenarios} {set cmd "$cmd -scenarios $sc "}
        redirect -variable cat_file { eval $cmd  }
        regexp {WNS\s+(\S+).*TNS\s+(\S+).*NUM\s+(\S+)} $cat_file -> wns tns nns
        set db(status_tim,${setup_or_hold},TOTAL) "$wns/$tns/$nns"
        echo "set db(status_tim,$scenario,${setup_or_hold},TOTAL) $db(status_tim,${setup_or_hold},TOTAL)" >> summary_reports/status_tim.${setup_or_hold}.tcl
	set str "";set str_num 0; while {$str_num<115} {append str "-"; incr str_num}
        append db(status_tim,tcl_table,${setup_or_hold}) "$str\n"
        append db(status_tim,tcl_table,${setup_or_hold}) "[format "%-*s %-*s %-*s  %-*s"  70  "TOTAL" 15  $wns 15 $tns 15 $nns ]\n"

        # Print table
        set time_stamp              [clock format [ clock scan now ] -format D%Y%m%dT%H%M%S]
        puts "$db(status_tim,tcl_table,${setup_or_hold})\n"  
        echo "$db(status_tim,tcl_table,${setup_or_hold})\n" > status_tim.${setup_or_hold}${pba_prefix}.rpt
        echo "$db(status_tim,tcl_table,${setup_or_hold})\n" > status_tim.${setup_or_hold}${pba_prefix}.${time_stamp}.rpt

}
