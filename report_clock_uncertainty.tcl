set clocks [get_clocks ]
foreach_in_collection  clka $clocks {
    foreach_in_collection  clkb $clocks {
        set clkan [get_object_name $clka]
        set clkbn [get_object_name $clkb]
        set tp [get_timing_path -from $clka -to $clkb]
        if {$tp eq ""} {
            echo "$clkan <> $clkbn <> N/A" >> clock_unc.rpt
            continue
        }
        set unc [get_attr $tp clock_uncertainty]
        echo "$clkan <> $clkbn <> $unc"
        echo "$clkan <> $clkbn <> $unc" >> clock_unc.rpt

    }
}

