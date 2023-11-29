#! /usr/local/bin/tclsh

##################################################
# procedure to find the slack from and to cell #
##################################################
#Usage: soc_get_slack_on_path    # Find the slacks to/from the cell you request
#        -cell cell             (The cell you wish to know slack to/from)
#        [-execute]              (If you wish to execute the command)

proc soc_get_slack_on_path {args} {

    #-- Parse command line
    set results(-execute) {false}
    #-- parse command line arguments
    parse_proc_arguments -args $args results
    foreach v [array names results] {
        regsub {^\-} $v {} vn
        eval "set i_${vn} \$results($v)"
    }

############
# Get date #
############
	
    set my_date [date]
    regexp {^[A-Za-z]* ([A-Za-z]*) *([0-9]*) [0-9]*\:[0-9]*\:[0-9]* [0-9]* *$} $my_date match Month Day
    
    if {$Month == "Jan"} {
        set Month 01
    } elseif {$Month == "Feb"} {
        set Month 02
    } elseif {$Month == "Mar"} {
        set Month 03
    } elseif {$Month == "Apr"} {
        set Month 04
    } elseif {$Month == "May"} {
        set Month 05
    } elseif {$Month == "Jun"} {
        set Month 06
    } elseif {$Month == "Jul"} {
        set Month 07
    } elseif {$Month == "Aug"} {
        set Month 08
    } elseif {$Month == "Sep"} {
        set Month 09
    } elseif {$Month == "Oct"} {
        set Month 10
    } elseif {$Month == "Nov"} {
        set Month 11
    } elseif {$Month == "Dec"} {
        set Month 12
    }
    
    set my_date "${Day}_${Month}"
    
#########################################
# Write reports that include transition #
#########################################

    redirect tmp_path_from_cell_${my_date} {
	report_timing -significant_digits 4 -transition_time -thr [get_pins ${i_cell}/* -filter "pin_direction == out"] -nosplit
    }
    redirect tmp_path_to_cell_${my_date} {
	report_timing -significant_digits 4 -transition_time -thr [get_pins ${i_cell}/* -filter "pin_direction == in AND pin_on_clock_network != true"] -nosplit
    }

####################
# Read the reports #
####################

    set fp_from_cell [open tmp_path_from_cell_${my_date} r]
    set data_from_cell [read $fp_from_cell]
    close $fp_from_cell

    set fp_to_cell [open tmp_path_to_cell_${my_date} r]
    set data_to_cell [read $fp_to_cell]
    close $fp_to_cell

####################################################
# Find avg transition and peak transition from_cell #
####################################################

    ##  Process data file ##
    set data_from_cell [split $data_from_cell "\n"]
    set from_cell_num_of_trans 0
    set from_cell_total_trans 0
    set from_cell_peak_trans 0
    set from_cell_slack 10000
    foreach line $data_from_cell {
	if {[string match {*[0-9]*\.[0-9]* *[0-9]*\.[0-9]* *[\*\&rc]* *[0-9]*\.[0-9]*} $line ]} {
# puts "i go in"
	    regexp {.*\) *([0-9]+\.[0-9]+) *[0-9]+\.[0-9]+ *[\*\&rc]* *[0-9]+\.[0-9]+ [a-z]} $line match trans
	    incr from_cell_num_of_trans
	    set from_cell_total_trans [expr $from_cell_total_trans + $trans]
	    if {$trans > $from_cell_peak_trans} {
		set from_cell_peak_trans $trans
	    }
	} elseif {[string match {*slack \(*} $line]} {
	    regexp {.*slack *\([A-Z]*\) *(\-*[0-9]*\.[0-9]*)} $line match slack
#      puts "look at from cell slack $slack"
	    if {$slack < $from_cell_slack} {
		set from_cell_slack $slack
#       puts "from cell slack $slack"
	    }
	} elseif {[string match {*clock network delay*} $line]} {
	    regexp {.*clock network delay \([a-z]*\) *(\-*[0-9]*\.[0-9]*) *(\-*[0-9]*\.[0-9]*)} $line match latency path
	    if {$path > 0} {
		set clock_latency $latency
	    }
	}

    }
    set from_cell_avg_trans [expr $from_cell_total_trans / $from_cell_num_of_trans]


##################################################
# Find avg transition and peak transition to_cell #
##################################################

    ##  Process data file ##
    set data_to_cell [split $data_to_cell "\n"]
    set to_cell_num_of_trans 1
    set to_cell_total_trans 0
    set to_cell_peak_trans 0
    set to_cell_slack 10000    
    foreach line $data_to_cell {
	if {[string match {*[0-9]*\.[0-9]* *[0-9]*\.[0-9]* *[\*\&rc]* *[0-9]*\.[0-9]*} $line ]} {
	    regexp {.*\) *([0-9]+\.[0-9]+) *[0-9]+\.[0-9]+ *[\*\&rc]* *[0-9]+\.[0-9]+ [a-z]} $line match trans
	    incr to_cell_num_of_trans
	    set to_cell_total_trans [expr $to_cell_total_trans + $trans]
	    if {$trans > $to_cell_peak_trans} {
		set to_cell_peak_trans $trans
	    }
	} elseif {[string match {*slack \(*} $line]} {
	    regexp {.*slack *\([A-Z]*\) *(\-*[0-9]*\.[0-9]*)} $line match slack
#       puts "look at to cell slack $slack"
	    if {$slack < $to_cell_slack} {
		set to_cell_slack $slack
#       puts "to cell slack $slack"
	    }
	}     
    }
    set to_cell_avg_trans [expr $to_cell_total_trans / $to_cell_num_of_trans]

    set slack_diff [expr $from_cell_slack - $to_cell_slack]
    puts ""
    puts "Current clock latency is :   $clock_latency"
    puts "New clock latency should be: [expr $clock_latency + ($slack_diff/2) ]"
    set pin_ [get_pins ${i_cell}/* -filter {pin_on_clock_network == true}]
    set pin_name_ [get_object_name $pin_]
    puts ""
    if {$clock_latency == [expr $clock_latency + ($slack_diff/2) ]} {
	puts "\[WARNING\] Need to find other cell. clock_latency already optimized !"
    } else {
	puts "Recommand \"set_clock_latency [expr $clock_latency + ($slack_diff/2) ] \[get_pins $pin_name_ \]\""
	if {$i_execute != "false"} {
	    set_clock_latency [expr $clock_latency + ($slack_diff/2) ] [get_pins $pin_name_ ]
	}
    }


#################
# print results #
#################

    set var_length [string length $i_cell]   
    set underline_var ""
    for {set i 1} {$i<=[expr $var_length + 4]} {incr i} {
	append underline_var "" "="
    }
    echo ""
    echo "$underline_var"
    echo "= $i_cell ="
    echo "$underline_var"
    echo ""    
    echo [format "                   | %-10s | %6s" "From cell" "To cell"]
    echo "---------------------------------------------------"
    echo [format "%-18s | %-10s | %-20s" slack $from_cell_slack $to_cell_slack ]
    echo [format "%-18s | %-0.3f      | %-0.3f" "avg transition" $from_cell_avg_trans $to_cell_avg_trans ]
    echo [format "%-18s | %-10s | %-20s" "peak transition" $from_cell_peak_trans $to_cell_peak_trans ]
    echo "---------------------------------------------------"    

    sh rm tmp_path_from_cell_${my_date}
    sh rm tmp_path_to_cell_${my_date}
}

define_proc_attributes soc_get_slack_on_path \
    -info "Find the slacks to/from the cell you request" -define_args {
              {-cell "The cell you wish to know slack to/from" cell string required}
	      {-execute "If you wish to execute the command" "" boolean optional}

}
