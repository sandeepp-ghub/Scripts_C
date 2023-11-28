set MDB ""
set SDB ""
set pins [get_pins  dss*/dss_dch_top/* -filter "direction==in"]
#set ip [get_pins dss0/dss_dch_top/top__dch_tdr_ctl[1]]
foreach_in_collection  ip $pins {
    set fo [all_fanout -from $ip ]
    set ipn [get_object_name $ip]
    set prfx [regexp {(dss./dss_dch_top/)(.*)} $ipn -> rgx bla]
    set outs [filter_collection $fo "full_name=~${rgx}*&&cell.full_name=~*dss_dch_top&&direction==out"]
    if {$outs eq ""} {continue}
    if {[sizeof_collection $outs] > 1 }   {echo "$ipn -> [get_object_name $outs]"} 
    foreach_in_collection op $outs {
        set tp  [get_timing_path -thr $ip -thr $op -include_hierarchical_pins]
        set slack  [get_attribute $tp slack]
        if {$slack eq ""}         {continue}
        if {$slack eq "INFINITY"} {continue}
    
        set points [get_attr $tp points]
        set objs_pre [get_attr $points object]    
        set objs [get_pins $objs_pre]
        set start_clock [get_object_name [get_attribute $tp startpoint_clock]]
        set end_clock [get_object_name [get_attribute $tp endpoint_clock]]
        set prfx [regexp {(dss./dss_dch_top/)(.*)} $ipn -> rgx bla]
    #    echo $rgx
        set in  [filter_collection $objs "full_name=~${rgx}*&&cell.full_name=~*dss_dch_top&&direction==in" ]
        set out [filter_collection $objs "full_name=~${rgx}*&&cell.full_name=~*dss_dch_top&&direction==out"]
        if {$in eq ""}  {continue}
        if {$out eq ""} {continue}
        set inn  [get_attr $in lib_pin_name]
        set outn [get_attr $out lib_pin_name]
    #    echo "$inn $outn  $slack"
        if {![info exists MDB($inn,$outn)]} {
            set MDB($inn,$outn) "$inn $outn $slack $start_clock $end_clock"
            set SDB($inn,$outn) $slack
        } elseif {$SDB($inn,$outn) < $slack} {
            set MDB($inn,$outn) "$inn $outn $slack $start_clock $end_clock"
            set SDB($inn,$outn) $slack
        }
    }
}

foreach key [array names MDB] {
    echo "$MDB($key)" >> max_delay_file.csv
}
