    set ports [get_db ports -if {.name!=*BP*}]
    foreach port $ports {
        # get memory pins.
        deselect_obj -all
        set pinsIN   [get_db [get_db $macro -if {.direction==in}]  .name]
        set pinsOUT  [get_db [get_db $macro -if {.direction==out}] .name]
        if {$pinsIN ne ""} {set afo [all_fanout -from $pinsIN -trace_through all -flat -endpoints_only   -only_cells]} else {set afo ""}
        if {$pinsOUT ne "" } {set afi [all_fanin  -to   $pinsOUT  -trace_through all -flat -startpoints_only -only_cells]} else {set afi ""}
        if {$afi eq "" && $afo eq ""} {puts "No flops: $macro" ; return}
    }



