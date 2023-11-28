proc groups_to_endpoints {groups} {
    set tps  [get_timing_paths -group $groups -max_p 1000000 -nworst 100 -delay_type min]
    set ep   [get_object_name [get_attr $tps endpoint]]
    set epsu [lsort -unique $ep]
    return $epsu
#    foreach e $epsu {
#        echo $e
#    }
}
