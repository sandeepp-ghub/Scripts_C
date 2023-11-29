procedure ::inv::clock::mscts_clock_qor_report  {
    -short_description "mscts_clock_qor_report."
    -description       "mscts_clock_qor_report."
    -example           "::inv::clock::mscts_clock_qor_report"
    -args              {{args -type string -optional -multiple -description "args list"}}
} {

    log -info "::inv::clock::mscts_clock_qor_report - START"
    set FILE [open ./report/$::SESSION(session).clock_qor.rpt w]
    foreach m {min max} {
        if {$m eq "min"} {
            redirect -variable templmin {report_clock_timing  -type latency -early }
            redirect -variable tempsmin {report_clock_timing  -type skew    -early }
        } else {
            redirect -variable templmax {report_clock_timing  -type latency -late }
            redirect -variable tempsmax {report_clock_timing  -type skew    -late }
        }
    }
    puts $FILE "============================================"
    puts $FILE "Latency"
    puts $FILE "============================================"
    foreach m {min max} {
        foreach line [split [set templ$m] "\n"] {
            if {[regexp {(Clock: )(\w+)} $line -> a cname]}                                                       {}
            if {[regexp {(Analysis View: )([\w_\:]+)} $line -> a scenario]}                                            {}
            if {[regexp {(\s+)([\d\.\-]+)(\s+)([\d\.\-]+)(\s+)([\d\.\-]+)(\s+)} $line -> s0 sou s1 net s2 tot]}   {
                puts $FILE "Clock       $cname" 
                puts $FILE "Scenario    $scenario" 
                puts $FILE "Max latency $tot"
            }
        }
    }
    puts $FILE "============================================"
    puts $FILE "Skew"
    puts $FILE "============================================"
    foreach m {min max} {
        foreach line [split [set temps$m] "\n"] {
            if {[regexp {(Clock: )(\w+)} $line -> a cname]}                                                       {}
            if {[regexp {(Analysis View: )([\w_\:]+)} $line -> a scenario]}                                            {}
            if {[regexp {(\s+)([\d\.\-]+)(\s+)([\d\.\-]+)(\s+)([\d\.\-]+)(\s+)} $line -> s0 skew s1 ku s2 uk]}   {
                puts $FILE "Clock       $cname" 
                puts $FILE "Scenario    $scenario" 
                puts $FILE "Max skew    $skew"
            }
        }
    }


    puts $FILE "============================================"
    puts $FILE "Clock tree stat"
    puts $FILE "============================================"

    redirect -variable temp {report_clock_trees}
    foreach line [split [set temp] "\n"] {
        regexp {(Report for clock tree:\s+)(\w+?)(:)} $line -> maa cname
        if {[regexp {(Maximum depth\s+:\s+)(\d+)} $line -> maa depth]} {
            puts $FILE "Clock tree: $cname"
            puts $FILE "Max depth : $depth" 
        }
    }


    # removed till debug.
    if {0} {
        set log_file [glob ./logfiles/*log]
        if {[llength $log_file] > 0} {
            set lname [lindex $log_file end]
            puts $FILE " "
            puts $FILE "============================================"
            puts $FILE "ICG info"
            puts $FILE "============================================"
            catch {exec grep -m 1 -A 20 {ICG depth} $lname | awk {/ICG depth/,/Via Selection/}  | grep -v Via}  ICGinfo
            puts $FILE $ICGinfo

            puts $FILE " "
            puts $FILE "============================================"
            puts $FILE "Clock Gate info"
            puts $FILE "============================================"

            catch {exec awk {/Clock gate merging summary/,/Disconnecting clock tree from netlist/} $lname | grep -v Disco}  Clkgateinfo
            puts $FILE $Clkgateinfo
        } 
    } ;# end of remove till debug.    

    #AR: fixing regression issue in release V033
    set block_name [lindex [get_db [get_db designs] .name] 0]

    if {![info exists ::CDB(mscts_clocks_list)] || $::CDB(mscts_clocks_list) eq ""} {
        log -info "::inv::clock::mscts_clock_qor_report - no MSCTS"
        close $FILE;
        return 1
    }
     # print tap point sink stats.
    foreach clk $::CDB(mscts_clocks_list) {
        puts $FILE "============================================"
        puts $FILE "Tap points fanout for clock $clk"
        puts $FILE "============================================"
        #AR: fixing regression issue in release V033
        set clk3 [get_db clock_trees ${block_name}_${clk}*MSCTS*TAP*]
        set i   0
        set min 1000000
        set max 0
        set tot 0
        foreach ck $clk3 {
            set t [get_db $ck .source -if {.obj_type==pin}]
            if {$t ne ""} {set tap [get_db $t .inst]} else {set tap "NOTAP"}
            set s [get_db $ck .sinks -if {.obj_type==pin}]
            if {$s ne ""} {set sink [get_db $s .inst]} else {set sink ""}
            set size [llength $sink]
            puts "$tap => $size "
            puts $FILE "$tap => $size "
            if {$size < $min} {set min $size}
            if {$size > $max} {set max $size}
            set tot [expr $tot + $size]
            incr i
        }
        set avr [expr $tot / $i]
        set $FILE ""
        puts $FILE "INFO:: Min tap fanout: $min"
        puts $FILE "INFO:: Max tap fanout: $max"
        puts $FILE "INFO:: Avr tap fanout: $avr"
    }


    close $FILE;
    log -info  "::inv::clock::mscts_clock_qor_report - END"
}

