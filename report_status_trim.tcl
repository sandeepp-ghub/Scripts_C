proc status_tim {} {

redirect -variable rpt -tee  {time_design -num_paths 50000 -expanded_views -report_only -report_dir ./}

if {[info exists sdb]}           {unset sdb}
if {[info exists grouplist]}     {unset grouplist}
if {[info exists new_group]}     {unset new_group}
if {[info exists sortgrouplist]} {unset sortgrouplist}
if {[info exists 2dlist]}        {unset 2dlist}

set id 0
set tm 0
foreach line [split $rpt \n] {

    if {[regexp {DRVs} $line]}         {break}
    if {[regexp {Total} $line]} {break}

    if {[regexp ID $line ]} {set id 1; continue}
    if {[regexp {\-\-\-} $line ]} {
        continue 
    }
    if {$line eq ""} {continue}
    if {[regexp {Setup mode} $line] || [regexp {Hold mode} $line]} {
        set id     0
        set tm     1
        set type   0
        set corner "ALL"
        regsub -all { } $line "" new_line
        set grouplist [split $new_line |]
        # Trim group list;
        set grouplist [lrange $grouplist 2 end-1]
        # Set re-re-name group
        foreach group $grouplist {
            if {[regexp {([0-9]+)(:)} $group -> a b]} {
                lappend new_group $sdb(id,$a)
            } else {
                lappend new_group $group
            }
        }
        set grouplist $new_group
        continue
    }
    if {[regexp {(max[0-9]_setup)} $line corner ] || [regexp {(min[0-9]_hold)} $line corner]} {
        set type 0
        continue
    }

    if {$id} {
        set  temp [split $line |]
        set i    [lindex $temp 1]
        regsub -all { } $i "" i
        set name [lindex $temp 2]
        regsub -all { } $name "" name
        set sdb(id,$i) $name 
    }
    if {[regexp {All Paths} $line]} {continue}
    if {$tm} {
        if {$type eq 0 } {set vio WNS}        
        if {$type eq 1 } {set vio TNS}        
        if {$type eq 2 } {set vio ANP}
        regsub -all { } $line "" new_line
        set violist [split $new_line |]
        set run 2
        foreach h $grouplist {
#            if {$run < 2 } {incr run ; continue} ;# skip the first coulmn
#            if {$h eq ""} {continue} ;# last coulmn
            #puts "$corner $h $vio [lindex $violist $run]"
            set sdb($corner,$h,$vio) [lindex $violist $run]
            incr run
        }

        incr type
    }
}
    # Print report.
    set corner ALL
    # sort groups by WNS.
    foreach group $grouplist {
        if {$sdb($corner,$group,WNS) eq "N/A"} {
            lappend 2dlist "$group  10000"
        } else {
            lappend 2dlist "$group  $sdb($corner,$group,WNS)"
        }
    }
    set 2dlist [lsort -real -index 1 $2dlist]
    foreach i $2dlist {
        set group [lindex $i 0] 
        lappend sortgrouplist $group
    }
    puts [format "|=%-25s=|=%-9s=|=%-9s=|=%-9s=|" "========================="  "=========" "=========" "=========" ]
    puts [format "| %-25s | %-9s | %-9s | %-9s |" "Group"  "WNS" "TNS" "ANP" ]
    puts [format "|=%-25s=|=%-9s=|=%-9s=|=%-9s=|" "========================="  "=========" "=========" "=========" ]
    foreach group $sortgrouplist {
#        if {$run < 2 } {incr run ; continue} ;# skip the first coulmn
#        if {$group eq ""} {continue} ;# last coulmn
        puts [format "| %-25s | %-9s | %-9s | %-9s |" $group  $sdb($corner,$group,WNS) $sdb($corner,$group,TNS) $sdb($corner,$group,ANP) ]    
    }

        
}
