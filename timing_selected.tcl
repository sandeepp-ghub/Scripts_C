gui_bind_key t  -cmd "timing_selected"
proc timing_selected {} {
    set insts [get_db selected]
    foreach inst $insts {
    # set inst $insts
        #set ipin [get_db [get_db $inst .pins -if {.direction==in} ] .name]
        #set opin [get_db [get_db $inst .pins -if {.direction==out}] .name]
        set instn [get_db $inst .name]
        set ofi [all_fanin -to "${instn}/*" -trace_through all -startpoints_only]
        set ofic [get_object_name [all_fanin -to "${instn}/*" -trace_through all -startpoints_only -only_cells]]
        foreach_in_collection start $ofi { 
            set path [report_timing -collection -from $start -through ${instn}/*]
            set slack [format {%0.3f} [get_property $path slack]]
            set startpoint [get_object_name [get_property $path startpoint]]
            puts "$startpoint $slack"                                                             
        }


        set ofo  [all_fanout -from "${instn}/*" -trace_through all -endpoints_only]
        set ofoc [get_object_name [all_fanout -from "${instn}/*" -trace_through all -endpoints_only -only_cells]]
        foreach_in_collection end $ofo { 
            set path [report_timing -collection -to $end -through ${instn}/*]
            set slack [format {%0.3f} [get_property $path slack]]
            set endpoint [get_object_name [get_property $path endpoint]]
            puts "$endpoint $slack"                                                             
        }
        puts "\n\n"
    }

}
