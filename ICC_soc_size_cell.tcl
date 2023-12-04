#########################################################
# soc_size_cell                                         #
# get a collection and a -up <num> OR -down <num> flag  #
# size cell up or down in the same lib                  #
# OR swap VT using vt_swap                              #
#                                                       #
# Lior Allerhand 23/9/12                                #
# #######################################################

proc soc_size_cell { args } {
global synopsys_program_name
    parse_proc_arguments -args ${args} results
    
    foreach_in_collection cell $results(cells_col) {

# get a sorted collection of libCells in the current lib
        if {![info exists results(-vt_swap)]} {
            set pattern ""
            set cur_num ""
            set post_fix ""
            regexp {(.*/[a-zA-Z_0-9]*x)([^_]*)(.*)} [get_object_name [get_lib_cells  -of_object $cell]] --> pattern cur_num post_fix
#puts " ${-->} \n $pattern \n $cur_num \n $post_fix"
            if {[catch {set lib_cells [get_lib_cells -regexp ${pattern}\[xo\]*(0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36)${post_fix}]}]} {puts "Error : input object [get_object_name $cell] is not a cell"; continue;}
# pc [get_lib_cells -regexp ${pattern}\[xo\]*(0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32)${post_fix}]
            if {$synopsys_program_name eq "pt_shell"} {
                set sorted_lib [sort_collection -dictionary $lib_cells full_name]
            } else {
                set sorted_lib [sort_collection -dictionary $lib_cells name]
                   
            }
            set min 0
            set max [expr {[sizeof_collection $sorted_lib] -1}] 
        } else {
            regexp {([a-zA-Z_]*[0-9]*)([^_]*)([^/]*\/)([^_]*)(.*)} [get_object_name [get_lib_cells  -of_object $cell]]  a b c d e f;
            append str $b "*" $d "*" $f
            set lib_cells [get_lib_cells $str]
            set vts(lnd) 1
            set vts(lzd) 2
#   set vts(lpd) 3
            set vts(snd) 3
            set vts(szd) 4
#            set vts(spd) 6
#            set vts(hnd) 7
#            set vts(hzd) 8
#           set vts(hpd) 9
            foreach_in_collection lc $lib_cells {
                set lcn [get_object_name $lc]
                regexp {([a-zA-Z_]*[0-9]*)([^_]*)([^/]*\/)([^_]*)(.*)} $lcn a b vt
                set temp_arr($vts($vt)) $lc
                lappend num $vts($vt)
            }
            set num_sort [lsort -integer $num]
            foreach n $num_sort {
                append_to_collection sorted_lib $temp_arr($n)  
            }
            set min 0
            set max [expr {[sizeof_collection $sorted_lib] -1}]
            if {$max > 24} {set max 24}
        }
# get_the index of the current cell lib in the sorted libs collection
        set current_lib [get_lib_cells  -of_object $cell]
        set index 0
        foreach_in_collection l $sorted_lib {
            if { [compare_collections $l $current_lib ]==0 } { break } else { incr index }
        }
# move the cell up or down the lib collection 
         if {![info exists results(-print_command_pt)] && ![info exists results(-print_command_icc)]} {puts "CELL: [get_object_name $cell]"}
        if {[info exists results(-up)] == 1 } {
            set new_index [expr {$results(-up) + $index }] 
            if { $new_index >= $max } { set new_index $max }
            if { $new_index eq $index } { puts "Warning cell is at his max strength no change have been done"; continue; }
            set new_lib [index_collection $sorted_lib $new_index]

            if { [catch {
                    if {[info exists results(-print_command_pt)]} {
                        puts "change_link [get_object_name $cell] [get_object_name $new_lib]"
                    } elseif {[info exists results(-print_command_icc)]} {
                        puts "size_cell [get_object_name $cell] [get_object_name $new_lib]"
                    } else {
                          if { $synopsys_program_name eq "pt_shell" } {
                              size_cell [get_object_name $cell] [get_object_name $new_lib]
                          } else {
                              change_link [get_object_name $cell] [get_object_name $new_lib] 
                          }
                    }
             } err]} {
                puts "could not change link of cell \n $err"
            } else {
            if {![info exists results(-print_command_pt)] && ![info exists results(-print_command_icc)]} {puts  "cell lib change successfully from [get_object_name $current_lib] --> [get_object_name [get_lib_cells  -of_object $cell]]"}
            if {[info exists results(-highlight)]} { gui_change_highlight -add -color $results(-highlight)  -collection $cell }
            }
        }
        if {[info exists results(-down)] == 1 } {
            set new_index [expr { $index - $results(-down) }] 
            if { $new_index <= $min } { set new_index $min }
            if { $new_index eq $index } { puts "Warning cell is at his min strength no change have been done"; continue; }
            set new_lib [index_collection $sorted_lib $new_index]
            if { [catch { 
                    if {[info exists results(-print_command_pt)]} {
                        puts "change_link [get_object_name $cell] [get_object_name $new_lib]"
                    } elseif {[info exists results(-print_command_icc)]} {
                        puts "size_cell [get_object_name $cell] [get_object_name $new_lib]"
                    } else {
                          if { $synopsys_program_name eq "pt_shell" } {
                              size_cell [get_object_name $cell] [get_object_name $new_lib]
                          } else {
                              change_link [get_object_name $cell] [get_object_name $new_lib] 
                          }
                    }
                 } err] } {
                puts "could not change link of cell \n $err"
            } else {
            if {![info exists results(-print_command_pt)] && ![info exists results(-print_command_icc)]} { puts  "cell lib change successfully from [get_object_name $current_lib] --> [get_object_name [get_lib_cells  -of_object $cell]]"}
            if {[info exists results(-highlight)]} { gui_change_highlight -add -color $results(-highlight)  -collection $cell }
            }
        }

        
    }
}
define_proc_attributes soc_size_cell  \
    -info "soc_size_cell \n get a collection and a -up <num> OR -down <num> flag \n size cells up or down in the same lib" \
    -define_args {
                   {cells_col "input collection of cells"  cell_col list required}
                   {-up       " up size a cell by <n>" <n> int optional}
                   {-down     " down size a cell <n>"  <n> int optional}
                   {-vt_swap " set cell vt instead of sizing -down to lvt or up to svt"  "" boolean optional}
                   {-print_command_pt  "will only print the command not ex" "" boolean optional}
                   {-print_command_icc "will only print the command not ex" "" boolean optional}
                   {-highlight "highlight the changed cells in gui" ""  one_of_string {optional value_help {values {yellow orange red green blue purple light_orange light_red light_green light_blue light_purple}}}}
}

