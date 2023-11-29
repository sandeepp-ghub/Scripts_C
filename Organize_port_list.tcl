###########################################
# get file return an organized port list  #
# Lior Allerhand 1/12/12                  #
###########################################

proc organize_port_list {file_path} {

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
    set pins [lsort -dictionary $pins]
    return $pins
}




    set infile   [open $file_path r]
    while {[gets $infile line] >= 0}  {
        lappend out_list $line
        }
    close $infile;
    set pins [merge_pin_list $out_list]


return $pins
}


