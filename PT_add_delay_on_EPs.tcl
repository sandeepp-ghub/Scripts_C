set file_path /mrvl2g/dc5purecl01_s_ccpd01_wa_004/ccpd01/ccpd01/wa_004/nightly/nightly_multiple_modes_rundirs/dss_2ch____20210221_002239/hold_rpt
if {[info exists MDB]} {unset MDB }
set infile   [open $file_path r]
while {[gets $infile line] >= 0}  {
    set line_list [split $line " "]
    set endp  [lindex $line_list 2]
    set slack [lindex $line_list 5]
    echo "$endp $slack"
    if {[info exists MDB($endp)]} {
        if {$slack < $MDB($endp)} {set MDB($endp) $slack}
    } else {
        set MDB($endp) $slack
    }
}
parray MDB
DEL(DELAD1BWP210H6P51CNODULVTLL) 0.01
DEL(DELBD1BWP210H6P51CNODULVTLL) 0.017
DEL(DELCD1BWP210H6P51CNODULVTLL) 0.03
DEL(DELDD1BWP210H6P51CNODULVTLL) 0.045
DEL(DELED1BWP210H6P51CNODULVTLL) 0.060
DEL(DELFD1BWP210H6P51CNODULVTLL) 0.070
DEL(DELGD1BWP210H6P51CNODULVTLL) 0.080

close $infile;
set i 0
foreach endp [array names MDB] {
    set tslack  $MDB($endp)
    while {tslack < 0.00} {
        if {$tslack < -0.080} {
            echo "insert_buffer $endp DELGD1BWP210H6P51CNODULVTLL  -new_net_names net_PTECO_HOLD_NET_FEB22_$i -new_cell_names U_PTECO_HOLD_BUF_FEB22_$i"
            set tslack [expr $tslack + 0.080]
        } elseif {$tslack < -0.070} {
            echo "insert_buffer $endp DELFD1BWP210H6P51CNODULVTLL  -new_net_names net_PTECO_HOLD_NET_FEB22_$i -new_cell_names U_PTECO_HOLD_BUF_FEB22_$i"
            set tslack [expr $tslack + 0.070]
        } elseif {$tslack < -0.06} {
            echo "insert_buffer $endp DELED1BWP210H6P51CNODULVTLL  -new_net_names net_PTECO_HOLD_NET_FEB22_$i -new_cell_names U_PTECO_HOLD_BUF_FEB22_$i"
            set tslack [expr $tslack + 0.06]
        } elseif {$tslack < -0.045} {
            echo "insert_buffer $endp DELDD1BWP210H6P51CNODULVTLL  -new_net_names net_PTECO_HOLD_NET_FEB22_$i -new_cell_names U_PTECO_HOLD_BUF_FEB22_$i"
            set tslack [expr $tslack + 0.045]
        } elseif {$tslack < -0.03} {
            echo "insert_buffer $endp DELCD1BWP210H6P51CNODULVTLL  -new_net_names net_PTECO_HOLD_NET_FEB22_$i -new_cell_names U_PTECO_HOLD_BUF_FEB22_$i"
            set tslack [expr $tslack + 0.03]
        } elseif {$tslack < -0.017} {
            echo "insert_buffer $endp DELBD1BWP210H6P51CNODULVTLL  -new_net_names net_PTECO_HOLD_NET_FEB22_$i -new_cell_names U_PTECO_HOLD_BUF_FEB22_$i"
            set tslack [expr $tslack + 0.017]
        } elseif {$tslack < -0.01} {
            echo "insert_buffer $endp DELAD1BWP210H6P51CNODULVTLL  -new_net_names net_PTECO_HOLD_NET_FEB22_$i -new_cell_names U_PTECO_HOLD_BUF_FEB22_$i"
            set tslack [expr $tslack + 0.01]
        } 
        incr i
    }
}

