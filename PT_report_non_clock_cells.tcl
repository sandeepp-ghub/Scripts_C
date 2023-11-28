proc report_non_clock_cells  { clk } {
    set all_fout [filter_collection [all_fanout -flat -trace_arcs all -only_cells -from [get_attribute [get_clock $clk] sources]] "(ref_name!~LHQD*) && (ref_name!~LNQ*) && (ref_name!~SDF*) && (ref_name!~DF*) && (ref_name!~SED*) && (ref_name!~MB*) && (ref_name!~*ULVT) && \
                                                                                                                                   (ref_name!~tprf*) && (ref_name!~sphst*) && (ref_name!~spsbt*) && (ref_name!~spmbt*) && (ref_name!~fnd_d2*) && (ref_name!~TSENE_ADC)"]
    foreach_in_collection fout $all_fout {
        set cell_name [get_object_name $fout]
        set cell_type [get_attr -quiet [get_cell -quiet $cell_name] ref_name]
        set cell_afo [all_fanout -from ${cell_name}/* -endpoints_only -trace_arcs all -q]
        set cell_afi [all_fanin -to   ${cell_name}/* -startpoints_only -trace_arcs all -q]
        set dont_printA 1
        set dont_printB 1
        if {$cell_afo eq ""} {continue}
        foreach_in_collection fo $cell_afo {
            if {[get_attr $fo is_clock_pin -q] eq "true"} {
                set dont_print 0
            }
        }
        foreach_in_collection fi $cell_afi {
            if {[get_attr $fi is_clock_source -q] eq "true"} {
                set dont_print 0
            }
        }        
        if {$dont_printA eq "0" && $dont_printB eq "0"} {
            echo [format "%-250s   %-60s" $cell_name $cell_type]
        }

    }
}

