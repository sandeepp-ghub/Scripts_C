proc highlight_ports_by_hierarchy {args} {
    set i 0
    set j 0
    parse_proc_arguments -args ${args} results
    set inputs  [all_inputs]
    set outputs [all_outputs]
    #-- go on all inputs.
    foreach_in_collection input $inputs {
        incr i
        puts $i
        if {[get_attr $input is_clock_used_as_clock]==true} {puts "not valid port [get_object_name $input]"; continue}
        set afo [all_fanout -from [get_object_name $input] -flat -endpoints_only ]
        set hier_list ""
        foreach_in_collection fo $afo {
            set fo_pin_name [get_object_name $fo]
#  puts $fo_pin_name
#           return
            regexp {([^/]*)(/)} $fo_pin_name aa hier a c
            lappend hier_list $hier
            if {[info exists results(-fast)]} {break}
        }
        set $hier_list [lsort -unique $hier_list]
        if {[llength $hier_list]==1} {
            lappend hier_table($hier)  [get_object_name $input]
            lappend tot_hier_list $hier
        }
    }

    #-- go on all outputs.
    foreach_in_collection output $outputs {
        incr j
        puts $j
        if {[get_attr $output is_clock_used_as_clock]==true} {puts "not valid port [get_object_name $input]"; continue}
        set afi [all_fanin -to [get_object_name $output] -flat -startpoints_only ]
        set hier_list ""
        foreach_in_collection fi $afi {
            set fi_pin_name [get_object_name $output]
#  puts $fo_pin_name
#           return
            regexp {([^/]*)(/)} $fo_pin_name aa hier a c
            lappend hier_list $hier
            if {[info exists results(-fast)]} {break}
        }
        set $hier_list [lsort -unique $hier_list]
        if {[llength $hier_list]==1} {
            lappend hier_table($hier)  $fi_pin_name
            lappend tot_hier_list $hier
        }
    }
    #-- print results
    gui_change_highlight -remove -all_colors
    gui_set_highlight_options -current_color blue
    gui_set_highlight_options -auto_cycle_color true

    set tot_hier_list [lsort -unique $tot_hier_list]
    foreach h $tot_hier_list {
#       puts "hier is :$h"
# puts $hier_table($h)
        puts "$h [gui_get_highlight_options -current_color]"
        gui_change_highlight -add -collection [get_ports $hier_table($h)]
        gui_set_highlight_options -next_color
    }




}

define_proc_attributes highlight_ports_by_hierarchy \
    -info "color macro ports by hierarchy." \
    -define_args {
        {-fast boolean "color hiearchical macro cell at level"  boolean optional}
    }
