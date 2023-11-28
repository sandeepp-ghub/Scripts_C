
proc findUnconnectedPorts {} {
    set outfile [open "report.out" w]
    set iports [get_db [get_db ports -if {.name!=*BP* && .direction==in }] .name]
    set oports [get_db [get_db ports -if {.name!=*BP* && .direction==out}] .name]
    set i 0
    set j 0
    foreach port $iports {
        set afo [all_fanout -from $port -trace_through all -endpoints_only]
        set afon [get_object_name $afo]
        if {$afon eq $port} {puts $outfile "IN:: $port"; incr i}
        incr j
    }
    foreach port $oports {
        set afi [all_fanin -to $port -trace_through all -startpoints_only] 
        set afin [get_object_name $afi]
        if {$afin eq $port } {puts $outfile "OUT:: $port"; incr i}
        incr j
    }

    puts $outfile "Number of unconnected ports $i of $j"
    close $outfile
}
