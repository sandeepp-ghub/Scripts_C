proc clock2clockWGS {} {
    set 2dlist ""
    set allclocks [get_object_name [get_clocks ]]
    foreach ckA $allclocks {
        foreach ckB $allclocks {
            # skip pre reported clocks
            if {[info exists db($ckA,$ckB)]} {continue}
            set db($ckA,$ckB) 1
            # Do stuff.
            redirect -variable path {mrt -from [get_clocks $ckA] -to [get_clocks $ckB]}
            if {[regexp {(\-*\d\.\d\d\d)} $path -> wgs]} {} else {continue}
            set ckAp [lindex [get_property  [get_clock $ckA] period] 0]
            set ckBp [lindex [get_property  [get_clock $ckB] period] 0]
            set pgn "${ckA}\($ckAp\),${ckB}\($ckBp\)"
            #echo [format "%-40s %-13s" $pgn     $wgs]
            lappend 2dlist "$pgn $wgs"            
        }
    }
    set 2dlist [lsort -real -index 1 $2dlist]
    foreach i $2dlist {
        set path [lindex $i 0] 
        set wgs  [lindex $i 1] 
        echo [format "%-35s %-8s" $path     $wgs]
    }
}
