#########################################################
# color design macros                                   #
# all macros of a common hierarchy are colored with     #
# the same color.                                       #
#                                                       #
# Lior Allerhand                                        #
#########################################################

proc color_macros_by_hierarchy {args} {
    set results(-levels) 1
    parse_proc_arguments -args ${args} results
    if {$results(-levels)> 4||$results(-levels)<= 0} {puts "Error : -levels value need to be 0 >< 4"; return; }
################################################
# get all rams in array                        #
################################################
    set all_rams [all_macro_cells]
# array unset ram_arr
    set uid 0
    set hier_list [list]
    foreach_in_collection ram_col $all_rams {
        set ram_name [get_object_name $ram_col]

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

################################################
# color all rams by unit                       #
################################################
gui_change_highlight -remove -all_colors
gui_set_highlight_options -current_color blue
gui_set_highlight_options -auto_cycle_color true
    foreach h $hier_list {
        puts "$h [gui_get_highlight_options -current_color]"
        gui_change_highlight -add -collection [get_cell $ram_arr($h)]
        gui_set_highlight_options -next_color
    }
}

define_proc_attributes color_macros_by_hierarchy \
    -info "color design macro cells by hierarchy." \
    -define_args {
        {-levels int "color hiearchical macro cell at level"  int optional}
    }
