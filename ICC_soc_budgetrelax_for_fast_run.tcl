proc soc_budget_relax_for_fast_run {} {
 
###### input paths #######
     echo "#### input ports delay " >  soc_budget_relax_for_fast_run.sdc
    set val_in_paths [get_timing_paths -group IN -slack_lesser_than 0.0 -max_paths 100000 -nworst 10 -start_end_pair]

    # get_data
    foreach_in_collection  path $val_in_paths {
        set clock_name  [get_object_name [get_attr $path startpoint_clock]]
        set pin_name    [get_object_name [get_attr $path startpoint]]
        set delay  [get_attr $path startpoint_input_delay_value]
        set slack  [get_attr $path slack]
        if {[info exists db($pin_name,$clock_name,slack)]} {
            if {$slack < $db($pin_name,$clock_name,slack)} {
                set db($pin_name,$clock_name,slack) $slack
                set db($pin_name,$clock_name,old_delay) $delay
                set db($pin_name,$clock_name,new_delay) [expr $delay + $slack ]
            }
        } else {
             set db($pin_name,$clock_name,slack) $slack
             set db($pin_name,$clock_name,old_delay) $delay
             set db($pin_name,$clock_name,new_delay) [expr $delay + $slack ]
        }

    }
    # output commands    
    foreach key [array names db] {
        if {[regexp {(.+?),(.+?),new_delay} $key all pin_name clock_name ]} {
            set delay $db($pin_name,$clock_name,new_delay)
            echo  "debug $db($pin_name,$clock_name,new_delay)"   
            echo "set_input_delay $delay -clock \[get_clocks $clock_name\] \[get_ports $pin_name\] -add; # delay + slack  == $db($pin_name,$clock_name,old_delay) + $db($pin_name,$clock_name,slack)  " >>  soc_budget_relax_for_fast_run.sdc
        }
    }

    ###### output paths #######

unset db;
     echo "\n\n\n " >> soc_budget_relax_for_fast_run.sdc
     echo "##### output ports delay " >>  soc_budget_relax_for_fast_run.sdc
    set val_in_paths [get_timing_paths -group OUT -slack_lesser_than 0.0 -max_paths 100000 -nworst 10 -start_end_pair]

    # get_data
    foreach_in_collection  path $val_in_paths {
        set clock_name  [get_object_name [get_attr $path endpoint_clock]]
        set pin_name    [get_object_name [get_attr $path endpoint]]
        set delay  [expr 0 - [get_attr $path endpoint_output_delay_value]]
        set slack  [get_attr $path slack]
        if {[info exists db($pin_name,$clock_name,slack)]} {
            if {$slack < $db($pin_name,$clock_name,slack)} {
                set db($pin_name,$clock_name,slack) $slack
                set db($pin_name,$clock_name,old_delay) $delay
                set db($pin_name,$clock_name,new_delay) [expr $delay + $slack - 0.02]
            }
        } else {
             set db($pin_name,$clock_name,slack) $slack
             set db($pin_name,$clock_name,old_delay) $delay
             set db($pin_name,$clock_name,new_delay) [expr $delay + $slack - 0.02]
        }

    }
    # output commands    
    foreach key [array names db] {
        if {[regexp {(.+?),(.+?),new_delay} $key all pin_name clock_name ]} {
            set delay $db($pin_name,$clock_name,new_delay)
            echo  "debug $db($pin_name,$clock_name,new_delay)"   
            echo "set_output_delay $delay -clock \[get_clocks $clock_name\] \[get_ports $pin_name\] -add; # -delay + slack -0.02 == $db($pin_name,$clock_name,old_delay) + $db($pin_name,$clock_name,slack) - 0.02 " >>  soc_budget_relax_for_fast_run.sdc
        }
    }




parray db

}
