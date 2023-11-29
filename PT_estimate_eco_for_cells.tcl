proc estimate_eco_for_cells {args} {
    parse_proc_arguments -args ${args} results
    set results(-swap_method) "both"
parse_proc_arguments -args ${args} results
    if {[info exists results(-cell_obj)]} {
        foreach_in_collection c $results(-cell_obj) {
            estimate_eco_for_cells -swap_method $results(-swap_method) -cell [get_object_name $c]
        }
    }

    set cell $results(-cell)
    set cell_name   $cell
    set cell_obj   [get_cells $cell]
    set cell_lib   [get_lib_cell */[get_attr $cell_obj ref_name]]
    set cell_lib_name [get_object_name $cell_lib]
        #-- get regexp string for lib cell to be used in estimate_eco
            unset -nocomplain str
            set point 0
            puts "-->results(-swap_method) $results(-swap_method)"
            if {[regexp {([a-zA-Z_]*[0-9]*)([^_]*)([^/]*\/)([^_]*)(.*)(x[0-9ox]*)(.*)} $cell_lib_name a b vt1 d vt2 f size h]} {
                if {$results(-swap_method) eq "both"}      { append str $b ".*" $d ".*" $f "\[xo\]*(0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24)" $h }
                if {$results(-swap_method) eq "vt_swap"}   { append str $b ".*" $d ".*" $f $size $h }
                if {$results(-swap_method) eq "size_cell"} { append str $b $vt1 $d $vt2 $f "\[xo\]*(0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24)" $h }
            } else {
                puts "#non normal lib can not work on this cell"
                return 0
            }
            set lib_cell [get_lib_cells -regexp $str]
            redirect -variable cell_estimate {estimate_eco -max -type size_cell $cell_obj -nosplit -lib_cells $lib_cell -rise -sort_by slack }
            set splited_cell_estimate [split $cell_estimate "\n"]
            if {[info exists results(-verbos)]} {puts $cell_name; foreach l $splited_cell_estimate {puts $l}}
      #-- get all the slacks and libs for currend cid
            foreach line $splited_cell_estimate {
                if {$point < 4} {incr point; continue} else {}; #skip estimate_eco header
                set line_parts [join $line " "]
                if {[regexp {^(\*)} $line_parts]} {
                    set line_parts [split $line_parts " "]
                    set lib        [string range [lindex $line_parts 0] 1 end]
                    set slack      [lindex $line_parts 4]
                    set cell_table($point,slack) $slack
                    set cell_table($point,lib) $lib
                    regexp {(.*/[a-zA-Z_0-9]*x)([^_]*)(.*)} $cell_table($point,lib) --> pattern size post_fix
                    set cell_table($point,lib_size) $size
                    set cell_table(start_point) $point
                    set cur_lib $lib
                    set cur_slack $slack
                    break; # min lib is current lib no need to look any more;

                 } else {
                     set line_parts [split $line_parts " "]
                     set lib        [lindex $line_parts 0]
                     set slack      [lindex $line_parts 4]
                     set cell_table($point,slack) $slack
                     set cell_table($point,lib) $lib
                     regexp {(.*/[a-zA-Z_0-9]*x)([^_]*)(.*)} $cell_table($point,lib) --> pattern size post_fix
                     set cell_table($point,lib_size) $size

                }
                incr point
                    
            } ;# end of first run on point 
        #-- get slack_improvement on all points from * --> 4 
            for {set p $cell_table(start_point)} {$p>=4} {incr p -1} {
                set cell_table($p,slack_improvement) [expr {$cell_table($p,slack)- $cur_slack}]
              
#puts "  point $p slack improvement $cell_table($p,slack_improvement)"
            }
       #-- get the "lowest" point of unsignificant change 
            for {set p $cell_table(start_point)} {$p>=4} {incr p -1} {
                if { [expr {$cell_table(4,slack) - $cell_table($p,slack)}] <=0.020 || $p==4 } {
                    if {$p == $cell_table(start_point)} {
                        set max_point_of_point_list_to_find_best_lib_to_change_to $p
#                       puts "max_point_of_point_list_to_find_best_lib_to_change_to $max_point_of_point_list_to_find_best_lib_to_change_to"
                        break;
                    } else {
                        set max_point_of_point_list_to_find_best_lib_to_change_to [expr {$p + 1}]
# puts "max_point_of_point_list_to_find_best_lib_to_change_to $max_point_of_point_list_to_find_best_lib_to_change_to"
                        break;
                    }
                }
            }; #end of second run on point
        #-- see if there a smaller cell in the not significant cells
            set min_size_point 4
            for {set p 4} {$p<=$max_point_of_point_list_to_find_best_lib_to_change_to} {incr p } {
                 if {$cell_table($p,lib_size)< $cell_table($min_size_point,lib_size)} {set min_size_point $p}
#                puts $min_size_point
#                 puts $p    

            }
            set p $min_size_point
            set cell_table(best_point) $p;
            set cell_table($p,lib)
            set cell_table(slack_best_improvement) [expr {$cell_table($p,slack)- $cur_slack}]

            puts "size_cell $cell_name $cell_table($p,lib)"
            

return ""
}

define_proc_attributes estimate_eco_for_cells  \
    -info "estimate if an eco can be done to improve timing on a cell. return an eco command    -help" \
    -define_args {
        {-cell "the cell to work on" "" string optional}
        {-cell_obj  "the cell_obj to work on" "" list optional}
        {-verbos  "use for debug stuff"    "" boolean optional}
        {-swap_method "vt swap, size cell OR both (default both)" ""  one_of_string {optional value_help {values {vt_swap size_cell both}}}}
    }
