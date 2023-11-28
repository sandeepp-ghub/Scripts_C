proc color_memories_by_hier {args} {
   global all_rams
   global inst_arr
   parse_proc_arguments -args ${args} results
    if {$results(-levels)> 4||$results(-levels)<= 0} {puts "Error : -levels value need to be 0 >< 4"; return; }
    #==============================================#
    # get all rams in array                        #
    #==============================================#
    if {![info exists all_rams]} {
        set all_rams [get_db [get_db insts -if ".is_memory"] .name]
    }
    if {[info exists ram_arr]} {
        array unset ram_arr
    }
#    if {[info exists inst_arr]} {
#        array unset inst_arr
#    }
    if {[info exists port_arr]} {
        array unset port_arr
    }
    gui_clear_highlight

    set uid 0
    set hier_list [list]
    foreach ram_name $all_rams {

        if {$results(-levels)== 1} {regexp {([^/]*)(/)} $ram_name a hier c}
        if {$results(-levels)== 2} {regexp {([^/]*/[^/]*)(/)} $ram_name a hier c}
        if {$results(-levels)== 3} {regexp {([^/]*/[^/]*/[^/]*)(/)} $ram_name a hier c}
        if {$results(-levels)== 4} {regexp {([^/]*/[^/]*/[^/]*/[^/]*)(/)} $ram_name a hier c}
        if {[info exists ram_arr($hier)]} { 
            lappend ram_arr($hier) $ram_name 
        } else {
            set ram_arr($hier) $ram_name
            lappend hier_list $hier
        }
    }

    if {[info exists results(-selected)]} {
        set hier_list [list]
        set all_selected_rams [get_db [get_db selected] .name]
        foreach ram_name $all_selected_rams {
            puts $ram_name
            if {$results(-levels)== 1} {regexp {([^/]*)(/)} $ram_name a hier c}
            if {$results(-levels)== 2} {regexp {([^/]*/[^/]*)(/)} $ram_name a hier c}
            if {$results(-levels)== 3} {regexp {([^/]*/[^/]*/[^/]*)(/)} $ram_name a hier c}
            if {$results(-levels)== 4} {regexp {([^/]*/[^/]*/[^/]*/[^/]*)(/)} $ram_name a hier c}
            if {[info exists forfilter_ram_arr($hier)]} { 
                lappend forfilter_ram_arr($hier) $ram_name 
            } else {
                set forfilter_ram_arr($hier) $ram_name
                lappend hier_list $hier
                puts $hier
            }
        }

    } else {

    }

    #==============================================#
    # get cells in array                           #
    #==============================================#
    if {[info exists results(-cells)]} {
        foreach hi $hier_list {
            if {[info exists inst_arr($hi)]} {
                # do notting
            } else {
                set insts [get_db insts -if ".name==$hi/*"]
                set inst_arr($hi) $insts
            }
        }
    }

    #==============================================#
    # get ports in  array                          #
    #==============================================#



    #==============================================#
    # Print results                                #
    #==============================================#

    deselect_obj -all
    foreach hi $hier_list {
        puts "Hier: $hi"
        foreach r $ram_arr($hi) {
            puts "$r"
        }
        puts "========================"

        select_obj $ram_arr($hi)
        if {[info exists results(-cells)]} {
            select_obj $inst_arr($hi)
        }
        gui_highlight  -auto_color
        deselect_obj -all

    }
}



define_proc_arguments color_memories_by_hier  \
    -info "color memories ports and logic cld for FP debug" \
    -define_args {
        {-selected   "Get selected macros"  "" boolean optional}
        {-cells   "color hier cells"  "" boolean optional}
        {-levels int "color hiearchical macro cell at level"  int optional}
        {-all        "Run on all macros"  "" boolean optional}
        {-macros_list  "Get an inst: list of macros to run on"    "" list    optional}
        {-reset      "Remove arrows "                          "" boolean optional}
        {-color_macros   "Color macros by fly lines length threshold. Short fly line Green, Medium fly line yellow, long fly line red."  "" boolean optional}
        {-flylines_thresholds   "None default thresholds 0--\$short , \$short--\$medium , \$medium--INF {medium short}"    "" list    optional}

    }



proc sort_ports_by_hire {} {
    set pout [get_db ports -if ".direction==out && .is_clock_used_as_clock!=true  && .is_special!=true"]
    set pin  [get_db ports -if ".direction==in  && .is_clock_used_as_clock!=true  && .is_special!=true"]
    foreach po $pout {
        set fi  [get_object_name [all_fanin -to $po -trace_through all -startpoints_only -only_cells ]]

    }
}
