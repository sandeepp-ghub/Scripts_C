foreach_in_collection p [get_pins * -hierarchical -filter "is_clock_used_as_clock==true&&is_clock_pin==false"]  {
    set bp  [get_attr $p lib_pin -q]
    if {$bp eq ""} {echo "BBOX [get_object_name $p]"; continue}
    set bpn [get_attr $bp full_name]
    if {[regexp {*CK*DULVT} $bpn]} {
        # Good Apple
    } else {
        echo "[get_object_name $p ]  $bpn"
    }
}
