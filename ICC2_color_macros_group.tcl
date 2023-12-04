#########################################################
# color design macros.                                  #
#                                                       #
# Lior Allerhand                                        #
#########################################################
proc color_macros_by_groups {args} {
    set results(-levels)    1
    set results(-delimiter) "_"
    set results(-hier)      "*"

    parse_proc_arguments -args ${args} results
################################################
# get all rams in array                        #
################################################
    set all_rams [get_flat_cells -filter "design_type==macro&&full_name=~$results(-hier)*"]


# array unset ram_arr
    set uid 0
    set hier_list [list]
    set levels  $results(-levels)
    foreach_in_collection ram_col $all_rams {
        set ram_name      [get_object_name $ram_col]
        set ram_name_list [split $ram_name $results(-delimiter)]
        set length        [llength $ram_name_list]
        if {$length > $levels} {set MAX [expr $levels -1]} else { set MAX [expr $length - 2]}
        set hier [join [lrange $ram_name_list 0 $MAX] $results(-delimiter)]

        if {[info exists ram_arr($hier)]} { 
            lappend ram_arr($hier) $ram_name 
        } else {
            set ram_arr($hier) $ram_name
            lappend hier_list $hier
        }
    }

################################################
# color all rams by unit                       #
################################################
gui_change_highlight -remove -all_colors
gui_set_highlight_options -current_color blue
gui_set_highlight_options -auto_cycle_color true
    foreach h $hier_list {
        puts [format "%-*s  %-*s %-*s" 50 $h 20 [gui_get_highlight_options -current_color] 10 [llength $ram_arr($h)]]
        gui_change_highlight -add -collection [get_cell $ram_arr($h)]
#        echo $ram_arr($h)
        gui_set_highlight_options -next_color
    }
}

define_proc_attributes color_macros_by_groups \
    -info "color design macro cells by hierarchy." \
    -define_args { \
        {-levels  "Color hiearchical macro cell by levela"        "" int    optional} \
        {-delimiter " _ OR / "                                    "" string optional} \
        {-hier "Get cell will add this as a prefix for searching" "" string optional}
    }










