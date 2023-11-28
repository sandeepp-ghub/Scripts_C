proc wgs {} {
    set 2dlist ""
    foreach_in_collection pg [get_path_groups ] {
        redirect -variable path {mrt -path_group [get_object_name $pg]}
        if {[regexp {(\-*\d\.\d\d\d)} $path -> wgs]} {} else {continue}
        set pgn [get_object_name $pg]
#        echo [format "%-40s %-13s" $pgn     $wgs]
        lappend 2dlist "$pgn $wgs"
    }
    redirect -variable path {mrt -path_group default}
    regexp {(\-*\d\.\d\d\d)} $path -> wgs
    lappend 2dlist "$pgn $wgs"

#echo [format "%-30s %-13s" default     $wgs]
    set 2dlist [lsort -real -index 1 $2dlist]
    foreach i $2dlist {
        set path [lindex $i 0] 
        set wgs  [lindex $i 1] 
        echo [format "%-35s %-8s" $path     $wgs]
    }
}
