set cells [get_cells * -hier  -filter "is_hierarchical == false"]
foreach c $cells {
    set ref ""
    set ref [get_attr $c ref_name]
    puts "$ref"
    if {[info exists ref_table($ref)]} {
        incr ref_table($ref)
    } else {
        set ref_table($ref) 1
        lappend ref_list $ref
    }
}

foreach ref $ref_list {
    puts "$ref  $ref_table($ref)"
}
