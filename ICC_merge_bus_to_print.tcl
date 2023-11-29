# set in_list [list D[0] D[1] D[2] D[22] D[23] D[24] D[45]]

# get a list of pins from the same bus and merge
proc merge_bus { in_list } {
    foreach p $in_list {
        regexp {([^\[]*)(\[)([0-9]*)} $p  a name b num
        lappend num_list $num
       
    }
     set num_list [lsort -integer $num_list]
    set start 1
    set start_start 1
    set print 1
    if {[llength $num_list]<=1} {return $in_list}
    for { set i 0 } { $i < [expr {[llength $num_list]-1}] } {incr i } {
        set p [ lindex $num_list $i ]
        set f [ lindex $num_list [expr {$i+1}] ]
        if {[expr {$f-$p}] > 1 } { 
            append str "$p,"; set print "1"
        } else {
            if {$i =="0"} {
                append str "$p-"; set print "0"
            } else {
                if {$print == "1"} {
                 append str "$p-"; set print "0"
                }
            } 
        }
        
        
        set start_start 0
    }
    append str $f
    return "${name}\[$str\]"
}

# get a pin list and output a list with bus pin merge. use merge_bus proc 
proc merge_pin_list { in_list } {
    set pinList [list]
    set nonBusPin [list]
    set busPin [list]
    foreach pin $in_list {
                if {[regexp {([^\[]*)(\[)([0-9]*)(\])} $pin  all name b num]=="1"} {
                    lappend pinArray($name) $all
                    lappend pinList $name
                } else {
                    lappend nonBusPin $pin
                  }
                
    }
        set pinList [lsort -unique $pinList]
    foreach pin $pinList {
      
        append busPin "[merge_bus $pinArray($pin)] "
     }
    append pins $busPin
    append pins " $nonBusPin"
    return $pins
}



# set number of pins to be in a ram/a,b,c 
proc merge_merge_pin_list { in_list } {
# puts "merge_merge_pin_list input is $in_list"
    set  ramList ""
    set output ""
    foreach pin $in_list {
        if {[regexp {(.*)((/)(.*))$} $pin b ram d e pin]=="1"} {
            lappend ramArray($ram) $pin
            lappend ramList $ram        
        }
    }
    set ramList [lsort -unique $ramList]
    foreach ram $ramList {
        append ram "/" [join $ramArray($ram) ,]
        lappend output $ram
    }

    return $output
}
# set a header of pin to ram list and merge_merge
proc merge_merge_pin_list_header { in_list } {
# puts "merge_merge_pin_list input is $in_list"
#puts $in_list
    for {set i 0} {$i < 58} {incr i } { append line "-" }
    set  ramList ""
    set output ""
    foreach pin $in_list {
        if {[regexp {(.*)((/)(.*))$} $pin b ram d e pin]=="1"} {
            lappend ramArray($ram) $pin
            lappend ramList $ram        
        }
    }
    set ramList [lsort -unique $ramList]
# at this point ramArray($ram) have a list of all pins
    foreach ram $ramList {
        lappend ramArraySw([join $ramArray($ram) ,]) $ram  
    }
    set start 1
    foreach pins [array names ramArraySw ] {
        if {$start == 1} {set start 0 } else { lappend output $line }
        lappend output $pins
        lappend output $line
        foreach ram $ramArraySw($pins) {
            lappend output $ram
         }
    }

    return $output
}





