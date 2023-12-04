############################################################################
# give a summary report for 1 worst path foreach path group                #
#                                                                          #
# Lior Allerhand                                                           #
# 28.12.12                                                                 #
############################################################################


proc report_worst_path_foreach_group {args} {

    # parse input args
    redirect ../reports/report_worst_path_foreach_group.rpt {puts "" }
    parse_proc_arguments -args ${args} results

#----------------------proc body----------------------------------
    foreach_in_collection group [get_path_groups *] {
        set path  [get_timing_paths -nworst 1 -slack_lesser_than 0 -max_paths 1 -group [get_object_name $group]]
        if {$path eq ""} {continue}
        set slack         [get_attr $path slack]                        ;# path slack 
        set spoint        [get_object_name [get_attr $path startpoint]] ;# path start point
        set epoint        [get_object_name [get_attr $path endpoint  ]] ;# path end point
        set sPointobjcc    [get_attr $spoint object_class]               ;# path start point object class 
        set ePointobjcc   [get_attr $epoint object_class]               ;# path end point object class
        set spointClock   [get_attr $path startpoint_clock]           ;# path start point clock
        set epointClock   [get_attr $path endpoint_clock]             ;# path end point clock
        set spointClockP [get_attr [get_clocks $spointClock] period]
        set epointClockP [get_attr [get_clocks $epointClock] period]
        redirect -append ../reports/report_worst_path_foreach_group.rpt {
            puts "GROUP:                    [get_object_name $group ]"
            puts "START_POINT:              $spoint"
            puts "START POINT CLOCK:        [get_object_name $spointClock]"
            puts "START POINT CLOCK PERIOD: $spointClockP"
            puts "END POINT:                $epoint"
            puts "END POINT CLOCK:          [get_object_name $epointClock]"
            puts "END POINT CLOCK PERIOD:   $epointClockP"
            puts "SLACK:                    $slack"
            puts "--------------------------------------------"

        }
    }
    
}; # end of proc
#---------------------define proc attributes----------------------
define_proc_attributes report_worst_path_foreach_group \
    -info "give a summary report for 1 worst path foreach path group  -help" \
    -define_args {
        
{-debug  "use for debug stuff"    "" boolean optional}
}



