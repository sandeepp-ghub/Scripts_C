foreach_in_collection scenarios  [get_scenarios] {
    current_scenario $scenarios
    echo "scenarios [get_object_name $scenarios]"
    unset -nocomplain arr
	set clocks [get_clocks]
	foreach_in_collection clock $clocks {
	    set num [sizeof_collection [all_registers -clock $clock]]
	    if {$num eq "0"} {continue}
	    set name [get_object_name $clock]
	    lappend arr($num) $name
	#    echo $num $name
	}
	
	#parray arr
	set sorted_keys_array [lsort -integer -uniq [array names arr]]
	
	foreach num $sorted_keys_array {
	#    echo $num
	    if {$num eq "0"} {continue}
	#    echo $num
	    foreach name $arr($num) {
	        echo "\t$name\([get_attr [get_clock sclk] period]n\) : $num FLOPS"
	    }
	}
    
    
}
