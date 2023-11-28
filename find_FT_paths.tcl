proc find_ft_paths {} {
    set oport [get_object_name [get_ports -filter "direction==out"]]
    foreach o $oport {
        set opafi [all_fanin -to $o -trace_through all -startpoints_only]
        set ports  [filter_collection $opafi  "is_port==true"]
        set pins   [filter_collection $opafi  "is_pin==true" ]
        set nports [get_object_name $ports]
        set npins  [get_object_name $pins ]
        if {$nports ne ""} {
            echo "Input: $nports to output $o FT" >> ft.rpt
            if {$npins ne ""} {
                echo "Warning: not pure FT output also connected to $npins" >> ft.rpt
            }
        }
        
    }
}
