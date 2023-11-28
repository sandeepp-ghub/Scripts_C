set clocks [get_db clocks .base_name -unique ]

foreach clkA $clocks {
    foreach clkB $clocks {
        if {$clkA eq $clkB}           {continue}
        if {[regexp {Virtual} $clkA]} {continue}
        if {[regexp {Virtual} $clkB]} {continue}
        redirect  temp {mrt -from $clkA -to $clkB -clocks} -append
    }
}
