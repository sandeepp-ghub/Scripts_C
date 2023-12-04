proc PrintCellsAndRefNameOfHier {str} {
    set cells [get_cells * -hierarchical -filter "full_name=~$str"]
    foreach_in_collection cell $cells {
        set cn [get_object_name $cell]
        set cr [get_attr $cell ref_name]
        puts [format "%-*s  %-*s" 80 $cn 40 $cr]
    }
}
