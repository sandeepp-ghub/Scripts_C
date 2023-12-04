#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: highlight all the cells in a timing path              #
#====================================================================#
# Example:  soc_highlight_timing_paths -from -to                     #
#====================================================================#


proc soc_highlight_timing_paths { args } {

    parse_proc_arguments -args ${args} results
    set cmd "get_timing_paths"
    if {[info exists results(-group)]}      {append cmd " -group $results(-group)"}
    if {[info exists results(-from)]}       {append cmd " -from $results(-from)"}
    if {[info exists results(-to)]}         {append cmd " -to $results(-to)"}
    if {[info exists results(-thr)]}        {append cmd " -thr $results(-thr)"}
    if {[info exists results(-max_paths)]}  {append cmd " -max_paths $results(-max_paths)"}
    if {[info exists results(-nworst)]}     {append cmd " -nworst $results(-nworst)"}
    if {[info exists results(-slack_lesser_than)]}    {append cmd " -slack_lesser_than $results(-slack_lesser_than)"}
    if {[info exists results(-slack_greater_than)]}   {append cmd " -slack_greater_than $results(-slack_greater_than)"}

    set paths [eval $cmd]
    
    gui_change_highlight -remove -all_colors
    gui_set_highlight_options -current_color red
    gui_set_highlight_options -auto_cycle_color true

    foreach_in_collection path $paths {
        redirect -variable dontprinttoscreen {
            set points  [get_attr $path points]
            set objects [get_attr $points object]
            set cells   [get_cells -of_object $objects -quiet]
            set ports   [get_ports -of_object $objects -quiet] 
        }
        if {[info exists results(-verbose)]} {
                foreach_in_collection o $objects {
                    puts [get_object_name $o]
                }
                
        }
        gui_change_highlight -add -collection [add_to_collection $cells $ports]
        change_selection [add_to_collection $cells $ports]
        gui_set_highlight_options -next_color
        # -- highlight next level (will work only on FF OR MUX)
        if {[info exists results(-next_level)]} {
            set endpoint [get_attr $path endpoint]
            #-- see if end point is a valid pin AKA FF D
            if {[get_attr $endpoint name] ne "D"} {
                puts "[get_object_name $endpoint] is not avalid point for next level flag"
                continue
            }
            set cell [get_cells -of_object $endpoint]
            set pin  [filter_collection [get_pins -of_object $cell] pin_direction==out]
            if {[sizeof_collection $pin] != 1} {puts "out pin ne to 1"; continue}
            set next_path [get_timing_paths -from $pin]
            redirect -variable dontprinttoscreen {
                set points  [get_attr $next_path points]
                set objects [get_attr $points object]
                set cells   [get_cells -of_object $objects -quiet]
                set ports   [get_ports -of_object $objects -quiet] 
            }
            if {[info exists results(-verbose)]} {
                foreach_in_collection o $objects {
                    puts [get_object_name $o]
                }
                
            }
            gui_change_highlight -add -collection [add_to_collection $cells $ports]
            change_selection -add [add_to_collection $cells $ports]
            gui_set_highlight_options -next_color

        }
    }

    return ""

}


define_proc_attributes soc_highlight_timing_paths \
    -info "highlight all the cells in a timing path    -help" \
    -define_args {
    {-group "" "" string optional}
    {-from "" "" string optional}
    {-to "" "" string optional}
    {-thr "" "" string optional}
    {-max_paths "" "" string optional}
    {-nworst "" "" string optional}
    {-slack_lesser_than "" "" string optional}
    {-slack_greater_than "" "" string optional}
    {-verbose boolean ""  boolean optional}
    {-next_level boolean ""  boolean optional}
  }

