proc relax_budget_for_cts {args} {


        # parse input args
    redirect ../cts_relax.tcl {puts "" }
    parse_proc_arguments -args ${args} results

#----------------------proc body----------------------------------
    set INOUTpaths  [get_timing_paths -nworst 1 -slack_lesser_than -0.01 -max_paths 20 -group INOUT ]
    set INpaths  [get_timing_paths -nworst 1 -slack_lesser_than -0.01 -max_paths 20 -group IN ]
    set OUTpaths  [get_timing_paths -nworst 1 -slack_lesser_than -0.01 -max_paths 20 -group OUT ]
    foreach_in_collection p $INOUTpaths {
        set spoint        [get_object_name [get_attr $p startpoint]] ;# path start point
        set epoint        [get_object_name [get_attr $p endpoint  ]] ;# path end point
        set slack         [get_attr $p slack] 
        set sdel [get_attr $p startpoint_input_delay_value]
        set edel [get_attr $p endpoint_output_delay_value]
        set spointClock   [get_attr $p startpoint_clock]           ;# path start point clock
        set epointClock   [get_attr $p endpoint_clock]             ;# path end point clock
        set const "set_output_delay \[expr \{$edel - $slack\}\] -clock \[get_clocks [get_object_name $epointClock]\] \[get_ports $epoint\]"
        puts "$const"
    }
    foreach_in_collection p $INpaths {
        set spoint        [get_object_name [get_attr $p startpoint]] ;# path start point
        set epoint        [get_object_name [get_attr $p endpoint  ]] ;# path end point
        set slack         [get_attr $p slack] 
        set sdel [get_attr $p startpoint_input_delay_value]
        set edel [get_attr $p endpoint_output_delay_value]
        set spointClock   [get_attr $p startpoint_clock]           ;# path start point clock
        set epointClock   [get_attr $p endpoint_clock]             ;# path end point clock
        set const "set_output_delay \[expr \{$sdel - $slack\}\] -clock \[get_clocks [get_object_name $spointClock]\] \[get_ports $spoint\]"
        puts $const
    }
    foreach_in_collection p $OUTpaths {
        set spoint        [get_object_name [get_attr $p startpoint]] ;# path start point
        set epoint        [get_object_name [get_attr $p endpoint  ]] ;# path end point
        set slack         [get_attr $p slack] 
        set sdel [get_attr $p startpoint_input_delay_value]
        set edel [get_attr $p endpoint_output_delay_value]
        set spointClock   [get_attr $p startpoint_clock]           ;# path start point clock
        set epointClock   [get_attr $p endpoint_clock]             ;# path end point clock
        set const "set_output_delay \[expr \{$edel - $slack\}\] -clock \[get_clocks [get_object_name $epointClock]\] \[get_ports $epoint\]"
        puts $const
    }
    


}; # end of proc
#---------------------define proc attributes----------------------
define_proc_attributes relax_budget_for_cts \
    -info "this stuff will print whan user write <porc_name> -help" \
    -define_args {
        
{-debug  "use for debug stuff"    "" boolean optional}
}





