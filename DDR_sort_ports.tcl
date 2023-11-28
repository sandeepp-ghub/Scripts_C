set ports [get_db ports -if {.name!=*BP*}]
foreach port $ports {
    set loc  [get_db $port .location.y]
    set name [get_db $port .name]
    set bus  [get_db $port .bus.name]
    if {$bus eq ""} {set is_bus 0 } else {set is_bus 1}
    set PDB($name,name)    $name
    set PDB($name,loc)     $loc
    set PDB($name,bus)     $bus
    set PDB($name,is_bus)  $is_bus

}






set 2dlist "";   unset 2dlist
foreach key [array names PDB *,name] {
    set name $PDB($key)
    lappend 2dlist "$PDB($name,name) $PDB($name,loc)"
}
set portlist ""; unset portlist
set 2dlist [lsort -real -index 1 $2dlist]
    foreach i $2dlist {
        set port [lindex $i 0] 
        lappend portlist $port
    }

foreach name $portlist {
    puts "$PDB($name,name)  $PDB($name,loc)"
}

set min 1000000
set max 0
foreach name $portlist {
    if {$PDB($name,is_bus)} {
        set bname $PDB($name,bus)
        if {![info exists PDB(sort,$bname,min)]} {
            set PDB(sort,$bname,min) $PDB($name,loc)
            set PDB(sort,$bname,max) $PDB($name,loc)
            set 
        } else {
            if {$PDB(sort,$bname,min) > $PDB($name,loc)} {set PDB(sort,$bname,min)  $PDB($name,loc)}
            if {$PDB(sort,$bname,max) < $PDB($name,loc)} {set PDB(sort,$bname,max)  $PDB($name,loc)}
        }
    }
}





set ports [get_db ports -if {.name!=*BP*}]
foreach port $ports {
#set loc  [get_db $port .location.y]
    set name [get_db $port .name]
    set dir  [get_db $port .direction]
    set bus  [get_db $port .bus.name]
    if {$bus eq ""} {
        set PDB($name,name)    $name
        set PDB($name,lsb)    0
        set PDB($name,msb)    0
        set PDB($name,dir)    $dir
        
    } else {
        set PDB($bus,name)     $bus
        set PDB($bus,lsb)    [get_db $port .bus.lsb]
        set PDB($bus,msb)    [get_db $port .bus.msb]
        set PDB($bus,dir)    $dir

    }
}

foreach key [array names PDB  *,name] {
    set name $PDB($key)
    puts "$PDB($name,name),$PDB($name,lsb),$PDB($name,msb),$PDB($name,dir)" >> ports.list

}


