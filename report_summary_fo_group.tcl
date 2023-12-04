############################################################################
# give a summary report for 1 worst path foreach path group                #
#                                                                          #
# Lior Allerhand                                                           #
# 28.12.12                                                                 #
############################################################################


proc report_summary_for_group {args} {

    # parse input args
    set results(-nworst) 1
    set results(-max_paths) 10
    set results(-group) *
   
    parse_proc_arguments -args ${args} results
    redirect ../reports/report_summary_for_group.rpt {puts "summary report \n nworst: $results(-nworst) \n max_paths: $results(-max_paths) \n groups: $results(-group)  \n [date] \n" }
#----------------------proc body----------------------------------
    foreach_in_collection group [get_path_groups $results(-group)] {
        set paths  [get_timing_paths -nworst $results(-nworst) -slack_lesser_than 0 -max_paths $results(-max_paths) -group [get_object_name $group]]
        redirect -append ../reports/report_summary_for_group.rpt {
            puts "GROUP:                    [get_object_name $group ]";
            puts "--------------------------------------------"
        }
        foreach_in_collection path $paths { 
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
            redirect -append ../reports/report_summary_for_group.rpt {
                puts "START_POINT:              $spoint"
                puts "END POINT:                $epoint"
                puts "SLACK:                    $slack"
                if {[get_object_name $spointClock] eq [get_object_name $epointClock]} {puts "---"} else {puts "cross clock:[get_object_name $spointClock] TO [get_object_name $epointClock]  \n --- "}

            }
        }
    }
    
}; # end of proc
#---------------------define proc attributes----------------------
define_proc_attributes report_summary_for_group \
    -info "give a summary report for 1 worst path foreach path group  -help" \
    -define_args {
        
    {-debug  "use for debug stuff"    "" boolean optional}
    {-group "" "" string optional}
    {-max_paths "" "" int optional}
    {-nworst "" "" int optional}
}



