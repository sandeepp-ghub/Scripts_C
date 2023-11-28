return 
# input pins with no nets.
set missing_net_list ""
set missing_pin_list ""
foreach_in_collection  pin [get_pins * -hierarchical -leaf  -filter "direction==in"] {
    set net [get_nets -of $pin -segments -quiet]
    if {$net eq ""} {
        echo [get_object_name $pin]
        lappend missing_net_list [get_object_name $pin]
    } else {
        set inport [get_ports -of $net  -quiet -filter "direction==in||direction==inout"]
        if {$inport ne ""} {continue}
        set opin [get_pins -of $net -filter "direction==out" -leaf -quiet]
        if {$opin eq ""} {
            echo [get_object_name $pin]
            lappend missing_pin_list [get_object_name $pin]
        }
    }
}
