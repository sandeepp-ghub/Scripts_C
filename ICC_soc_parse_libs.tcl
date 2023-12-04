###########################################################################################
# Log changes
#===============
#
# 30/10/11 [eyal]: change the parser to use hash table instead of parsing lib
# 22/11/11 [eyal]: added "-allow_estimation" to the command line. If using this variable
#                  the returned value will be an estimate, in case out_cap or in_trans 
#                  are out of range. If not used it will return 10000
#
###########################################################################################

#Usage: hs_cts_parse_lib    # Parses lib file to build the cell timing table. Require either cts_cell or lib_cell
#        [-cts_cell ]           (the cts cell name)
#        [-lib_cell ]           (the library cell name)
#        -rise_fall             (rise or fall)
#        -input_trans           (input transition)
#        -output_cap            (output capacity)
#        [-transition]          (return transition instead of timing)
#        [-allow_estimation]    (return estimated value in case cap or trans is out of range. If not return 10000)
#        [-debug]               (debug mode)
if {[info exists LOADED_LIB_LIST]} {} else {set    LOADED_LIB_LIST ""}
global LOADED_LIB_LIST
global db


proc soc_parse_lib {args} {

    set start_time [date]
    global current_scenario
    global env
    global LOADED_LIB_LIST
    global db

    #-- Parse command line
    set results(-pin)              {}
    set results(-lib_pin)          {}
    set results(-rise_fall)        {rise}
    set results(-max_min)          {max}    
    set results(-input_trans)      {}
    set results(-output_cap)       {}
    set results(-transition)       {false}
    set results(-allow_estimation) {}
    set results(-debug)            {false}
    #-- parse command line arguments
    parse_proc_arguments -args $args results
    foreach v [array names results] {
        regsub {^\-} $v {} vn
        eval "set i_${vn} \$results($v)"
    }
    #======================#
    #-- check input args --#
    #======================#
    #-- if both pin and lib_pin given
    if {($i_pin != "") && ($i_lib_pin != "")} {
	error "ERROR (soc_parse_lib) -> need to provide either lib_pin or pin_obj, not both !"
        return 0
    }
    if {($i_pin == "") && ($i_lib_pin == "")} {
	error "ERROR (soc_parse_lib) -> need to provide either lib_pin or pin_obj !"
        return 0
    }
    if {($i_input_trans == "") && ($i_lib_pin != "")} {
	error "ERROR (soc_parse_lib) -> lib pin mast come with -input_trans & -output_cap for delay calc !"
        return 0
    }
    if {($i_output_cap == "") && ($i_lib_pin != "")} {
	error "ERROR (soc_parse_lib) -> lib pin mast come with -input_trans & -output_cap for delay calc !"
        return 0
    }


    #======================================================#
    #-- load the lib table in to db array if not exists  --#
    #======================================================#
    #-- get the lib name from pin 
    if {$i_pin != ""} {
	    set cell_type [get_attribute [get_cells -of_objects $i_pin ] ref_name]
        set lib_type  [get_object_name [get_lib_cells -of_objects [get_cells -of_objects $i_pin]]]	
        set pin_name  [get_attr [get_pins $i_pin] lib_pin_name]
    } else {
        set lib_type  [get_object_name [get_lib_cells -of [get_lib_pins  $i_lib_pin]]]
        set cell_type [get_attr [get_lib_cells -of [get_lib_pins  $i_lib_pin]] base_name]		
        set pin_name  [get_attr [get_lib_pins $i_lib_pin] base_name]
    }
    if {$i_debug != "false"} {puts "\[DEBUG\] cell_type = $cell_type"}	
    if {$i_debug != "false"} {puts "\[DEBUG\] lib_type  = $lib_type"}	
    if {$i_debug != "false"} {puts "\[DEBUG\] pin_name  = $pin_name"}	
    #-- get lib name
    regexp {(\S+)\/\S+} $lib_type -> lib_name
    if {$i_debug != "false"} {puts "\[DEBUG\] lib_name = $lib_name"}
    #-- get file name
    set library_path   $env(LIBRARY_PATH)
    set file_full_path "${library_path}/lib/${lib_name}.lib"
    if {[file exists $file_full_path]} {
        set current_file_is_gz "NO"
    } else {
        #-- this is a patch so if the file is gz AND already loaded to db it will not get null gzip -d 
        if {[lsearch $LOADED_LIB_LIST $lib_name] >= 0} {
            set current_file_is_gz "YES"
        } else {
           set file_full_path     "${file_full_path}.gz"
            sh gzip -d -c  $file_full_path > soc_parse_lib_temp_file
            set current_file_is_gz "YES"
            puts "Info: unzip zipped lib file in to temp file"
        }
    } 
    if {$i_debug != "false"} {puts "\[DEBUG\] file full path = $file_full_path"}
    if {$current_file_is_gz eq "YES"} {
        set file_full_path "soc_parse_lib_temp_file"
        if {$i_debug != "false"} {puts "\[DEBUG\] file full path = $file_full_path"}
    }
    #-- reading the lib file to db array
    #- see if lib need to be loaded to db
    if {[lsearch $LOADED_LIB_LIST $lib_name] >= 0} {
        #-- lib is already loaded do notting 
        puts "Info: $lib_name is already to glob db going on to calc... "
    } else {
        #-- load lib into db
        puts "Info: loading $lib_name to glob db can take 5min... "
        parse_lib_file_to_db_array "./$file_full_path"
        lappend LOADED_LIB_LIST $lib_name
    } 

    #======================================================#
    #-- find two points for linear calculation           --#
    #======================================================#
    #-- get input pin trans
    if {$results(-lib_pin) ne ""} {
        set input_trans $results(-input_trans)
    } else {
        set input_trans [get_attr [get_pins $i_pin] actual_${i_rise_fall}_transition_${i_max_min} ]
    }
    #-- get z pin output cap
    if {$results(-lib_pin) ne ""} {
        set output_cap $results(-output_cap)
    } else {
    #-- get z pin of input pin
    set zpin [get_pins -of [get_cells -of [get_pins $i_pin]] -filter "direction==out"]
    if {[sizeof_collection $zpin] > 1} {puts "Error: cell have more then one output pin"}
    set output_cap [get_attr $zpin effective_capacitance_${i_max_min}]
    }
    if {$i_debug != "false"} {puts "\[DEBUG\] input_trans = $input_trans"}
    if {$i_debug != "false"} {puts "\[DEBUG\] output_cap  = $output_cap"}


    #-- find the two point in lib for linear calc
    if {($i_rise_fall eq "rise") && ($i_transition eq "false")} {set table "cell_rise"      }
    if {($i_rise_fall eq "rise") && ($i_transition ne "false")} {set table "rise_transition"}
    if {($i_rise_fall ne "rise") && ($i_transition eq "false")} {set table "cell_fall"      }
    if {($i_rise_fall ne "rise") && ($i_transition ne "false")} {set table "fall_transition"}

#db(${lib},${pin},${table},trs_index_list)
#$db(${lib},${pin},${table},cap_index_list)

    #-- print table of x (index 2) input trans y (index 1) cap
    if {$i_debug != "false"} {puts "\[DEBUG\] table = $table"}
    if {$i_debug != "false"} {puts "\[DEBUG\] index1 output cap   (Y) = $db(${cell_type},${pin_name},${table},cap_index_list)"}
    if {$i_debug != "false"} {puts "\[DEBUG\] index2 input  trans (x) = $db(${cell_type},${pin_name},${table},trs_index_list)"}
    if {$i_debug != "false"} {
        foreach t $db(${cell_type},${pin_name},${table},trs_index_list) {
            puts -nonewline [format "%10s " $t]
        }
        puts ""
        foreach t $db(${cell_type},${pin_name},${table},trs_index_list) {
            puts -nonewline [format "%11s" "=========="]
        }
        puts ""

        foreach c $db(${cell_type},${pin_name},${table},cap_index_list) {
            foreach t $db(${cell_type},${pin_name},${table},trs_index_list) {
                puts -nonewline [format "%10s " $db(${cell_type},${pin_name},${table},$c,$t)] ;# [format "%3.2f "  $lnd]
            }
            puts -nonewline " || $c"
            puts "";# next line
        }
    }
    #-- find two points for input trans 
    foreach trans_val $db(${cell_type},${pin_name},${table},trs_index_list) {
	    if {$trans_val > $input_trans} {
		    set trans_point_plus_1 $trans_val
		    break
	    } else {
            set trans_point_minus_1 $trans_val
	    }
	}
    if {$i_debug != "false"} {puts "\[DEBUG\] Input transition ($input_trans) is between $trans_point_minus_1 & $trans_point_plus_1"}

    set i 0
    foreach cap_val $db(${cell_type},${pin_name},${table},cap_index_list) {
	    if {$cap_val > $output_cap} {
		    set cap_point_plus_1 $cap_val
		    set cap_point_plus_1_indx $i
		    break
	    } else {
		    set cap_point_minus_1 $cap_val
		    set cap_point_minus_1_indx $i
	    }
	        incr i
	}
        if {![info exists cap_point_minus_1]} {set $cap_point_minus_1 10000}
    	if {$i_debug != "false"} {puts "\[DEBUG\] cap_point_plus_1 = $cap_point_plus_1"}
        if {$i_debug != "false"} {puts "\[DEBUG\] cap_point_plus_1_indx = $cap_point_plus_1_indx"}
        if {$i_debug != "false"} {puts "\[DEBUG\] cap_point_minus_1 = $cap_point_minus_1"}
        if {$i_debug != "false"} {puts "\[DEBUG\] cap_point_minus_1_indx = $cap_point_minus_1_indx"}


    #=================================================================================#
    #--  calculate the accurate value - interpolate. Assuming linearity. Y = aX + b --#
    #=================================================================================#
    #-- calc delay/trans asu high points of cap : cap_point_plus_1(trans_point_minus_1 , trans_point_plus_1)
    set {x0} $trans_point_minus_1
    set {y0} $db(${cell_type},${pin_name},${table},$cap_point_plus_1,$trans_point_minus_1)
    set {x1} $trans_point_plus_1
    set {y1} $db(${cell_type},${pin_name},${table},$cap_point_plus_1,$trans_point_plus_1)
    set {xp} $input_trans
    set {yy1} [find_linear_eq_and_return_y_from_x ${x0} ${y0} ${x1} ${y1} ${xp} ]
    if {$i_debug != "false"} {puts "\[DEBUG\] input points for calc high line ${x0} ${y0} ${x1} ${y1} ${xp}"}
    if {$i_debug != "false"} {puts "\[DEBUG\] output points from calc high line yy1 == ${yy1}"}

#-- calc delay/trans asu low points of cap :  cap_point_minus_1(trans_point_minus_1 , trans_point_plus_1)
    set {x0} $trans_point_minus_1
    set {y0} $db(${cell_type},${pin_name},${table},$cap_point_minus_1,$trans_point_minus_1)
    set {x1} $trans_point_plus_1
    set {y1} $db(${cell_type},${pin_name},${table},$cap_point_minus_1,$trans_point_plus_1)
    set {xp} $input_trans
    set {yy0} [find_linear_eq_and_return_y_from_x ${x0} ${y0} ${x1} ${y1} ${xp}]
    if {$i_debug != "false"} {puts "\[DEBUG\] input points for calc low line ${x0} ${y0} ${x1} ${y1} ${xp}"}
    if {$i_debug != "false"} {puts "\[DEBUG\] output points from calc high line yy0 == ${yy0}"}

    #-- calc delay/trans with ast points of cap and trans as var
    set {xx0} $cap_point_minus_1
    set {xx1} $cap_point_plus_1
    set {xp}  $output_cap  
    set return_val [find_linear_eq_and_return_y_from_x ${xx0} ${yy0} ${xx1} ${yy1} ${xp}]
    if {$i_debug != "false"} {puts "\[DEBUG\] input points for calc low line ${xx0} ${yy0} ${xx1} ${yy1} ${xp}"}
    if {$i_debug != "false"} {puts "\[DEBUG\] output points from calc high line return_val == $return_val"}


    #====================#
    #--  return value  --#
    #====================#
    return $return_val

}; #end of main proc


define_proc_attributes soc_parse_lib \
    -info "Parses lib file to build the cell timing table. Require either cts_cell or lib_cell" \
    -define_args {
    {-pin              "the pin name"                        "" list    optional}
    {-lib_pin          "the library cell name"               "" list    optional}	
    {-rise_fall        "rise or fall"                        "" list    required}
    {-max_min          "min or max"                          "" list    optional}
	{-input_trans      "input transition"                    "" list    optional}
	{-output_cap       "output capacity"                     "" list    optional}
	{-transition       "return transition instead of timing" "" boolean optional}
	{-allow_estimation "return estimated value in case cap or trans is out of range. If not return 10000" "" boolean optional}
	{-debug            "debug mode"                          "" boolean optional}

}
##================================================================================================================##
##================================================================================================================##
##================================================================================================================##

proc parse_lib_file_to_db_array {args} {
    puts "GO IN  parse_lib_file_to_db_array"
    set start_time [date]
    global current_scenario
    global env
    global LOADED_LIB_LIST
    global db
    set read_values 0;
    set check       0;
    set i_debug  "false"
    parse_proc_arguments -args ${args} results
    foreach v [array names results] {
        regsub {^\-} $v {} vn
        eval "set i_${vn} \$results($v)"
    }
    #-- reading the lib file to db array
    set fileIn   [open $results(file_full_path) r]
    while {[gets $fileIn line] >= 0}  {
        if {[regexp {(cell \( )(.+?)( \) \{)}        $line --> pre mid pos ]}  {
            set lib   $mid; set cell_line_check "YES"; set check "NO"; set pin_line_check "NO";  
            if {$i_debug != "false"} {puts "\[DEBUG\] lib = $lib"}        
        }
        if {[regexp {(related_pin : \")(.+?)(\")}    $line --> pre mid pos ]}  {
            set pin   $mid; 
            if {$cell_line_check eq "YES"} {set pin_line_check  "YES"}
            if {$i_debug != "false"} {puts "\[DEBUG\] pin = $pin"}                    
        }
        if {[regexp {(cell_rise)(\(.+?\) \{)}        $line --> str end     ]}  {set table $str; set check  "YES"}  
        if {[regexp {(rise_transition)(\(.+?\) \{)}  $line --> str end     ]}  {set table $str; set check  "YES"}  
        if {[regexp {(cell_fall)(\(.+?\) \{)}        $line --> str end     ]}  {set table $str; set check  "YES"}  
        if {[regexp {(fall_transition)(\(.+?\) \{)}  $line --> str end     ]}  {set table $str; set check  "YES"}  
        if {($check eq "YES") && ($cell_line_check eq "YES") && ($pin_line_check eq "YES" )} {
            if {[regexp {(index_1\(\")(.+?)(\"\))}       $line --> pre mid pos ]}  {
                set cap_index_temp $mid
                regsub -all { } $cap_index_temp "" cap_index_temp
                set cap_index_list [split $cap_index_temp ","]
                set db(${lib},${pin},${table},cap_index_list) $cap_index_list            
            }
            if {[regexp {(index_2\(\")(.+?)(\"\))}       $line --> pre mid pos ]}  {
                set trs_index_temp $mid
                regsub -all { } $trs_index_temp "" trs_index_temp                    
                set trs_index_list [split $trs_index_temp ","]
                set db(${lib},${pin},${table},trs_index_list) $trs_index_list           
            }
            #-- after getting index as a list startwork on valuse
            if {[regexp {values} $line]} {set read_values 1; set cap_index 0}
            if {[regexp {[ ]+\}} $line]} {set read_values 0}
            if {$read_values eq 1} {
                #-- go over values line and make it a list
                regsub -all { }          $line ""     new_line
                regsub -all {values\(}   $new_line "" new_line
                regsub -all {\"}         $new_line "" new_line
                regsub -all {,\\}        $new_line "" new_line
                regsub -all {\)\;}       $new_line "" new_line
                set line_list            [split $new_line ","]
                if {$i_debug != "false"} {puts "\[DEBUG\] values = $line_list"}                    
                #-- take each value line and put it in the db array
                foreach t $db(${lib},${pin},${table},trs_index_list) v $line_list {
                    set cap [lindex $db(${lib},${pin},${table},cap_index_list) $cap_index]
                    set db(${lib},${pin},${table},$cap,$t) $v
                }
                incr cap_index;
            }
        }
        # reset STM
#    if {[regexp {internal_power} $line]} {set cell_line_check "NO"}

    }
    close $fileIn;




}

define_proc_attributes parse_lib_file_to_db_array \
    -info "Parses lib file to db array" \
    -define_args {
    {file_full_path        "file_full_path"                        "" string    required}
	{-debug                "debug mode"                            "" boolean   optional}

}


##================================================================================================================##
##================================================================================================================##
##================================================================================================================##
#-- get x1 y1 x2 y2 xp make a linear point  from (x0 y0) (x1 y1) and return yp for xp
proc find_linear_eq_and_return_y_from_x {x0 y0 x1 y1 xp} {
#   ^ (timing)
#   |
# ur+            
#   |      
#   |     
# ll+   .
#   |
#   |
#   ----+--------+-----> (cap)
#     cap-1    cap+1
#
# Y0 = aX0 + b
# Y1 = aX1 + b
# ==> a = (Y0 - Y1)/(X0 - X1)
# ====> b = Y0 - aX0
	set a [expr (${y0} - ${y1})/(${x0} - ${x1})]
    set b [expr ${y0} - ($a * ${x0})]
#    if {$i_debug != "false"} {puts "\[DEBUG\] The formula is: Y=${a}X+$b"}
	return [expr (${a} * $xp) + $b]
}

