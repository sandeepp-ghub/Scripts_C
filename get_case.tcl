proc get_case {pin} {
    foreach v [get_db analysis_views .name] {
        set c [get_property [get_pins $pin] case_value -view $v -quiet]
        puts "[format "%-52s   %-10s" $v $c]"
    }
}
