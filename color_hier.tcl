proc color_hier {args} {
    global color_hier_inst_arr
	set color_index(1)  "red"
	set color_index(2)  "blue"
	set color_index(3)  "green"
	set color_index(4)  "yellow"
	set color_index(5)  "purple"
	set color_index(6)  "light blue"
	set color_index(7)  "pink"
	set color_index(8)  "dark purple"
	set color_index(9)  "dark blue"
	set color_index(10) "dark yellow"
	set color_index(11) "dark pink"
	set color_index(12) "NOP"
	set color_index(13) "NOP"
	set color_index(14) "NOP"
	set color_index(15) "NOP"
	set color_index(16) "NOP"
	set color_index(17) "NOP"
	set color_index(18) "NOP"
	set color_index(19) "NOP"
	set color_index(20) "NOP"
	set color_index(21) "NOP"
	set color_index(22) "NOP"
	set color_index(23) "NOP"
	set color_index(24) "NOP"
	set color_index(25) "NOP"
	set color_index(26) "NOP"
	set color_index(27) "NOP"
	set color_index(28) "NOP"
	set color_index(29) "NOP"
	set color_index(30) "NOP"

puts "Color_hier Info:: First order debug"
set i 0
set all_cells [get_cells * -hierarchical  -filter "is_hierarchical==false"]
foreach h  [get_object_name [get_cells * -hierarchical -filter "is_hierarchical==true&&hierarchical_level==1"]] {
    if {[regexp {spr_} $h]} {continue}
#    puts "filter_collection $all_cells full_name==${h}/*"
    set insts  [filter_collection $all_cells "full_name=~${h}/*"]
    set linsts [sizeof_collection  $insts]
    puts [format "%-35s %-10s" $h $linsts]
    incr i
    if {$i > 10000 } {
        puts "Stop watch timier triged"
        break
    }
}



set hier_list [list dmc_core_i/u_DWC_ddr_umctl2 dmc_core_i/dss_crypto ]
# color_hier -hier_list [list dmc_core_i/u_DWC_ddr_umctl2 dmc_core_i/dss_crypto ] -levels 2
    
    parse_proc_arguments -args ${args} results
    set hier_list {}
    if {[info exists results(-hier_list)]} {set hlist $results(-hier_list)} else {set hlist "*"}
    foreach h $hlist {
        if {$results(-levels)> 4||$results(-levels)<= 0} {puts "Error : -levels value need to be 0 >< 4"; return; }
        if {$results(-levels)== 1} {set hier_list [concat  $hier_list [get_object_name [get_cells  $h          -filter "is_hierarchical==true&&name!~spr*"]]]}
        if {$results(-levels)== 2} {set hier_list [concat  $hier_list [get_object_name [get_cells  $h/*        -filter "is_hierarchical==true&&name!~spr*"]]]}
        if {$results(-levels)== 3} {set hier_list [concat  $hier_list [get_object_name [get_cells  $h/*/*      -filter "is_hierarchical==true&&name!~spr*"]]]}
        if {$results(-levels)== 4} {set hier_list [concat  $hier_list [get_object_name [get_cells  $h/*/*/*    -filter "is_hierarchical==true&&name!~spr*"]]]}
    }
    puts "DBUG: $hier_list"                                                                                  
    deselect_obj -all
    set i 1
    set sorted_hier_list2d {}
    set tot [llength $hier_list]
    foreach hi $hier_list {
        set insts [get_db insts -if ".name==$hi/*"]
        set lnt [llength $insts]
        set color_hier_inst_arr($hi) $insts
        lappend sorted_hier_list2d [list $hi $lnt]
        puts "hier $i out of $tot"
        incr i
    }
    set sorted_hier_list {}
    set sorted_hier_list2d [lsort -integer -decreasing -index 1 $sorted_hier_list2d]
    foreach i $sorted_hier_list2d {
        set hi [lindex $i 0] 
        lappend sorted_hier_list $hi
    }
    set i 1
    foreach hi $sorted_hier_list {       
        set lnt [llength $color_hier_inst_arr($hi)]
        puts "Hier: $hi  $color_index($i)  $lnt"
        if {$i > "11"} {continue} 
        select_obj $color_hier_inst_arr($hi)
        gui_highlight  -index $i
        deselect_obj -all
        incr i
    }
}

define_proc_arguments color_hier  \
    -info "color memories ports and logic cld for FP debug" \
    -define_args {
        {-hier_list  "Get an inst: list of macros to run on"    "" list    optional}
        {-reset      "Remove arrows "                          "" boolean optional}
        {-levels int "color hiearchical macro cell at level"  int optional}
    }

