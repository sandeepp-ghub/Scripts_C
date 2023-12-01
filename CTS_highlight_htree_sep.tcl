###Below script will print the root allocation summary and highlight all the sinks of the flexible H-Tree

proc highlightSinks {args} {
parse_proc_arguments -args $args opt
set htree_name $opt(-flex_htree)

set index 1
foreach i $htree_name {
    set count 0
    gui_clear_highlight
    eval_legacy {deselectAll}
    set_layer_preference node_layer -is_visible 0
    set tap_htree_names [get_db [get_db clock_trees *$i*] .name]
    puts "-------------------------------------"
    puts "Root Allocation                 Sinks"
    puts "-------------------------------------"
    foreach j $tap_htree_names { 
        puts "$j     [llength [get_clock_tree_sinks -in_clock_trees $j]]" 
        set count [expr [llength [get_clock_tree_sinks -in_clock_trees $j]] + $count]
        gui_highlight [get_cells -of_objects [get_clock_tree_sinks -in_clock_trees $j]] -index $index 
        incr index
    }
    puts "-------------------------------------"
    puts "Total                          $count"
    puts "-------------------------------------"
    eval "write_to_gif $i.gif"
    set index 1
}
}

define_proc_arguments highlightSinks -info "Dumps root allocation summary for each tap points of each flexible Htree. Also, it highlights and dump a gif by coloring all the sinks associated to each tap points"\
    -define_args {
        {-flex_htree "return root allocation summary only for this flexible Htree" "" string required}
    }


