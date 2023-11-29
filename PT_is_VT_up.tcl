proc can_vt_down {cell} {
    set vts(lzd) 1
    set vts(lnd) 2
    set vts(szd) 3
    set vts(spd) 4
    set vts(hzd) 5
    set vts(hpd) 6
    regexp {(.*/)([a-zA-Z]*)} [get_object_name [get_lib_cells  -of_object $cell]]  a b vt;
    if {$vts($vt)>1} {return 1} else {return 0}
}

proc can_vt_up {cell} {
    set vts(lzd) 1
    set vts(lnd) 2
    set vts(szd) 3
    set vts(spd) 4
    set vts(hzd) 5
    set vts(hpd) 6
    regexp {(.*/)([a-zA-Z]*)} [get_object_name [get_lib_cells  -of_object $cell]]  a b vt;
    if {$vts($vt)<6} {return 1} else {return 0}
}

