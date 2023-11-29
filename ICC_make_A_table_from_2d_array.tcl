###################################
# make a table proc get an array width of coulman A & B
# and genereit a table 


proc make_A_table_from_2d_array { args } {
    parse_proc_arguments -args ${args} results
    upvar $results(ramToPrint) ramToPrint
    upvar $results(index_list) index_list

    set Aw      $results(-Acw); # width of column A
    set Bw      $results(-Bcw); # width of column B
    set header  $results(-header)
    set hA $results(-headerA)
    set hB $results(-headerB)
    
    set hAfix [string_pad $hA $Aw -fp 1 ]
    set hBfix [string_pad $hB $Bw -fp 1 ]

    set tablew [expr { $Aw + $Bw + "3" }]
    set stars  [string repeat "*" $tablew ]
    regsub -all {.} $stars "-" lines

    puts $stars;
    puts "*    [string_pad $header [expr {$tablew -6}]]*"
    puts $stars;
    puts "|${hAfix}|${hBfix}|"

# set split list element to one or more element  
#        foreach ID $index_list {
#        puts $lines
#        set ram_list $ramToPrint($ID,rams) 
#        set pin_list $ramToPrint($ID,pin_name)
#          }
      

     foreach ID $index_list {
        puts $lines
        set ram_list $ramToPrint($ID,rams) 
        set pin_list $ramToPrint($ID,pin_name)
        set new_ram_list ""
    #-- make sure no name is to big for the column (ram_list) 
        foreach ram $ram_list {
            set i 0
            set j [expr {$Bw-1}]
            if {[string length $ram]> [expr {$Bw-1}]} {
                while {$j < [string length $ram] } {
                    lappend new_ram_list [string range $ram $i $j]
                    set i [expr {$j+1}]
                    set j [expr {$j+$Bw}]
                }
                set tail [string range $ram $i end ]
                if {$tail!=""} {lappend new_ram_list $tail}
            } else {
                lappend new_ram_list $ram
            }
            lappend new_ram_list " "
        }
      #-- make sure no name is to big for the column (pin_list)
        set new_pin_list ""
        foreach pin $pin_list {
            set i 0
            set j [expr {$Aw-1}]
            if {[string length $pin]> [expr {$Aw-1}]} {
                while {$j < [string length $pin] } {
                    lappend new_pin_list [string range $pin $i $j]
                    set i [expr {$j+1}]
                    set j [expr {$j+$Aw}]
                }
                set tail [string range $pin $i end ]
                if {$tail!=""} {lappend new_pin_list $tail}
            } else {
                lappend new_pin_list $pin
            }
            lappend new_pin_list " "
        }
    #-- go to print stuff ID by ID
        set ram_list $new_ram_list 
        set pin_list $new_pin_list
        set subt [ expr { [llength $ram_list] - [llength $pin_list] } ]
        if {$subt < 0 } {
            set inv_subt [ expr { [llength $pin_list] - [llength $ram_list]  } ]
            for {set i 0} {$i < $inv_subt } {incr i} { lappend ram_list " "}
        }
        if {$subt > 0 } {
            for {set i 0} {$i < $subt } {incr i} { lappend pin_list " "}
        }
        set max [llength $pin_list]
        for {set i 0} { $i < $max } { incr i } {
            set p   [lindex $pin_list $i]
            set ram [lindex $ram_list $i]
            puts "|[string_pad $p $Aw -fp 1]|[string_pad $ram $Bw -fp 1]|"
        }
        
    }
    puts $lines;


    }

define_proc_attributes make_A_table_from_2d_array   \
    -info "wrapper for report_timing. this proc get two or more cells as input find the i/o/c pins of these cells and print a timing report" \
    -define_args {
                   {-Acw  "the width of column A"                "" string required}
                   {-Bcw  "the width of column B"                "" string required}
                   {-headerA  "the header of column A"           "" string required}
                   {-headerB  "the header of column B"           "" string required}
                   {-header  "the header of the table"           "" string required}
                   {ramToPrint "array of collections to prints string for upvar"  "" string required}
                   {index_list "index of line to print from 2d array, string for upvar"  "" string required}

    } 

