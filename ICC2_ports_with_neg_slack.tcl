set allPorts [get_ports *]


foreach_in_collection port $allPorts {
    set slk [get_attr $port max_slack]
    if {$slk >= 0} {
        append_to_collection pos $port

    } else {
        append_to_collection neg $port

    }
}
