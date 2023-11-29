

procedure ::inv::clock::init_settings {
    -description "Initialize the clock settings.
    This is needed so that we can use the same clock
    settings at pre cts flow and normal cts flow."

} {
    log -info "::inv::clock::init_settings - START"
    log -info "Initializing clocking settings"
    global ::CDB
    #global mscts_clocks_list;
    #global h3_clocks_list;

    
    # Paint the cells to be used in CT build. (look at user us file for def)
    if {[info exists ::CLOCK(clock_cells_vt_class)]} {
        set ::CDB(clock_cells_vt_class) $::CLOCK(clock_cells_vt_class)
    } else {
        set ::CDB(clock_cells_vt_class) "ulvt"
    }
    # Make sure ::CLOCK(clock_cells_vt_class) exists at FLOW(cts_target_libs_vt)
    # If not take the low vt of FLOW(cts_target_libs_vt) as clock cells vt.
#    set ::CDB(elvt)   0 
#    set ::CDB(ulvt)   1
#    set ::CDB(ulvtll) 2
#    set ::CDB(lvt)    3
#    set ::CDB(lvtll)  4
#    set ::CDB(svt)    5
#    if {[info exists ::FLOW(cts_target_libs_vt)] && $::FLOW(cts_target_libs_vt) ne ""} {
#        set ::CDB(clock_cells_vt_class) ""
#        set mtch                        0
#        set min                         "svt"
#        foreach fvt $::FLOW(cts_target_libs_vt) {
#            if {$::CDB($fvt) < $::CDB($min)} {set min $fvt}
#            foreach cvt $::CLOCK(clock_cells_vt_class) {
#                if {$fvt eq $cvt} {
#                    lappend ::CDB(clock_cells_vt_class) $cvt
#                    set mtch 1
#                }
#            }
#        }
#        if {$mtch == 0} {set ::CDB(clock_cells_vt_class) $min}
#    }
    set  ::CDB(clock_cells_vt_class)  [string toupper $::CDB(clock_cells_vt_class)]

    # get a list of vts and create a regexp var.
    set regx ""
    foreach vt $::CDB(clock_cells_vt_class) {
        set regx "${regx}D${vt}$|\\*${vt}$|"
    }
    set regx [string range $regx 0 end-1]

    # Adding TWA/B cell to the LIBCELLS.
   if {[regexp {280} $::ARR2TDB(cell_tracks)]}  {
    # H280
        lappend ::LIBCELL(clock_buf) CKBK*
        lappend ::LIBCELL(clock_buf) DCCKBK*
        lappend ::LIBCELL(clock_inv) CKNT*
        lappend ::LIBCELL(clock_inv) DCCKNT*
        lappend ::LIBCELL(clock_gate) CKLHQT*
        lappend ::LIBCELL(clock_gate) CKLHQK*
        lappend ::LIBCELL(clock_gate) CKLNQT*
        lappend ::LIBCELL(clock_gate) CKLNQK*
        lappend ::LIBCELL(clock_comb) *CKOR2D2*
        lappend ::LIBCELL(clock_comb) *CKAN2D2*
        lappend ::LIBCELL(clock_comb) *CKMUX2*

    } else {
    # H210 
        lappend ::LIBCELL(clock_gate) CKLHQTWAD*210H6P51CNOD*
        lappend ::LIBCELL(clock_gate) CKLHQTWBD*210H6P51CNOD*
        lappend ::LIBCELL(clock_gate) CKLNQTWAD*210H6P51CNOD*
        lappend ::LIBCELL(clock_gate) CKLNQTWBD*210H6P51CNOD*
        lappend ::LIBCELL(clock_gate) CKLHQTWAD*280H6P57CNOD*
        lappend ::LIBCELL(clock_gate) CKLHQTWBD*280H6P57CNOD*
        lappend ::LIBCELL(clock_gate) CKLNQTWAD*280H6P57CNOD*
        lappend ::LIBCELL(clock_gate) CKLNQTWBD*280H6P57CNOD*
        lappend ::LIBCELL(clock_comb) *CKOR2D2*
        lappend ::LIBCELL(clock_comb) *CKAN2D2*
        lappend ::LIBCELL(clock_comb) *CKMUX2D2*
    }
    


    # Filter cells list to the one we are going to use.    
    set clock_buf  [get_db [get_db base_cells $::LIBCELL(clock_buf) ] .name]
    set clock_inv  [get_db [get_db base_cells $::LIBCELL(clock_inv) ] .name]
    set clock_gate [get_db [get_db base_cells $::LIBCELL(clock_gate) ] .name]
    set clock_comb  [get_db [get_db base_cells $::LIBCELL(clock_comb) ] .name]
    

    # one more filter by 280 / 210 in case the LIBCELL array will change
    if {[regexp {280} $::ARR2TDB(cell_tracks)]}  {
        set clock_buf  [::common::tdb_filter_key -filter "^CKBKAD2B|^CKBKAD3B|^DCCKBKAD4B|^DCCKBKAD5B|^DCCKBKAD6B|^DCCKBKAD7B|^DCCKBKAD8B|^DCCKBKAD10B|^DCCKBKAD12B|^DCCKBKAD14B|^DCCKBKAD16B" -key $clock_buf]
        set clock_inv  [::common::tdb_filter_key -filter "^CKNTWBKAD2B|^CKNTWBKAD3B|^DCCKNTWBKAD4B|^DCCKNTWBKAD5B|^DCCKNTWBKAD6B|^DCCKNTWBKAD7B|^DCCKNTWBKAD8B|^DCCKNTWBKAD10B|^DCCKNTWBKAD12B|^DCCKNTWBKAD14B|^DCCKNTWBKAD16B" -key $clock_inv]
        set clock_gate  [::common::tdb_filter_key -filter "^CK.*D1B.*|^CK.*D2B.*|^CK.*D3B|^CK.*D4B|^CK.*D5B|^CK.*D6B|^CK.*D7B|^CK.*D8B|^CK.*D10B|^CK.*D12B|^CK.*D14B|^CK.*D16B" -key $clock_gate]
        set clock_comb  [::common::tdb_filter_key -filter "^CK.*D1B.*|^CK.*D2B.*|^CK.*D3B|^CK.*D4B" -key $clock_comb]
        if {$clock_buf eq "" } {
            log -error "::LIBCELL(clock_buf) Is not define correctly. Taking default list. Please contact bfw team."
            set clock_buf "DCCKBKAD8BWP280H6P57CNODULVTLL DCCKBKAD6BWP280H6P57CNODULVTLL DCCKBKAD5BWP280H6P57CNODULVTLL DCCKBKAD4BWP280H6P57CNODULVTLL DCCKBKAD16BWP280H6P57CNODULVTLL DCCKBKAD14BWP280H6P57CNODULVTLL DCCKBKAD12BWP280H6P57CNODULVTLL DCCKBKAD10BWP280H6P57CNODULVTLL CKBKAD3BWP280H6P57CNODULVTLL CKBKAD2BWP280H6P57CNODULVTLL DCCKBKAD8BWP280H6P57CNODULVT DCCKBKAD6BWP280H6P57CNODULVT DCCKBKAD5BWP280H6P57CNODULVT DCCKBKAD4BWP280H6P57CNODULVT DCCKBKAD16BWP280H6P57CNODULVT DCCKBKAD14BWP280H6P57CNODULVT DCCKBKAD12BWP280H6P57CNODULVT DCCKBKAD10BWP280H6P57CNODULVT CKBKAD3BWP280H6P57CNODULVT CKBKAD2BWP280H6P57CNODULVT DCCKBKAD8BWP280H6P57CNODLVTLL DCCKBKAD6BWP280H6P57CNODLVTLL DCCKBKAD5BWP280H6P57CNODLVTLL DCCKBKAD4BWP280H6P57CNODLVTLL DCCKBKAD16BWP280H6P57CNODLVTLL DCCKBKAD14BWP280H6P57CNODLVTLL DCCKBKAD12BWP280H6P57CNODLVTLL DCCKBKAD10BWP280H6P57CNODLVTLL CKBKAD3BWP280H6P57CNODLVTLL CKBKAD2BWP280H6P57CNODLVTLL DCCKBKAD8BWP280H6P57CNODLVT DCCKBKAD6BWP280H6P57CNODLVT DCCKBKAD5BWP280H6P57CNODLVT DCCKBKAD4BWP280H6P57CNODLVT DCCKBKAD16BWP280H6P57CNODLVT DCCKBKAD14BWP280H6P57CNODLVT DCCKBKAD12BWP280H6P57CNODLVT DCCKBKAD10BWP280H6P57CNODLVT CKBKAD3BWP280H6P57CNODLVT CKBKAD2BWP280H6P57CNODLVT DCCKBKAD8BWP280H6P57CNODELVT DCCKBKAD6BWP280H6P57CNODELVT DCCKBKAD5BWP280H6P57CNODELVT DCCKBKAD4BWP280H6P57CNODELVT DCCKBKAD16BWP280H6P57CNODELVT DCCKBKAD14BWP280H6P57CNODELVT DCCKBKAD12BWP280H6P57CNODELVT DCCKBKAD10BWP280H6P57CNODELVT CKBKAD3BWP280H6P57CNODELVT CKBKAD2BWP280H6P57CNODELVT"
        }
        if {$clock_inv eq "" } {
            log -error "::LIBCELL(clock_inv) Is not define correctly. Taking default list. Please contact bfw team."
            set clock_inv "DCCKNTWBKAD8BWP280H6P57CNODULVTLL DCCKNTWBKAD6BWP280H6P57CNODULVTLL DCCKNTWBKAD5BWP280H6P57CNODULVTLL DCCKNTWBKAD4BWP280H6P57CNODULVTLL DCCKNTWBKAD16BWP280H6P57CNODULVTLL DCCKNTWBKAD14BWP280H6P57CNODULVTLL DCCKNTWBKAD12BWP280H6P57CNODULVTLL DCCKNTWBKAD10BWP280H6P57CNODULVTLL CKNTWBKAD3BWP280H6P57CNODULVTLL CKNTWBKAD2BWP280H6P57CNODULVTLL DCCKNTWBKAD8BWP280H6P57CNODULVT DCCKNTWBKAD6BWP280H6P57CNODULVT DCCKNTWBKAD5BWP280H6P57CNODULVT DCCKNTWBKAD4BWP280H6P57CNODULVT DCCKNTWBKAD16BWP280H6P57CNODULVT DCCKNTWBKAD14BWP280H6P57CNODULVT DCCKNTWBKAD12BWP280H6P57CNODULVT DCCKNTWBKAD10BWP280H6P57CNODULVT CKNTWBKAD3BWP280H6P57CNODULVT CKNTWBKAD2BWP280H6P57CNODULVT DCCKNTWBKAD8BWP280H6P57CNODLVTLL DCCKNTWBKAD6BWP280H6P57CNODLVTLL DCCKNTWBKAD5BWP280H6P57CNODLVTLL DCCKNTWBKAD4BWP280H6P57CNODLVTLL DCCKNTWBKAD16BWP280H6P57CNODLVTLL DCCKNTWBKAD14BWP280H6P57CNODLVTLL DCCKNTWBKAD12BWP280H6P57CNODLVTLL DCCKNTWBKAD10BWP280H6P57CNODLVTLL CKNTWBKAD3BWP280H6P57CNODLVTLL CKNTWBKAD2BWP280H6P57CNODLVTLL DCCKNTWBKAD8BWP280H6P57CNODLVT DCCKNTWBKAD6BWP280H6P57CNODLVT DCCKNTWBKAD5BWP280H6P57CNODLVT DCCKNTWBKAD4BWP280H6P57CNODLVT DCCKNTWBKAD16BWP280H6P57CNODLVT DCCKNTWBKAD14BWP280H6P57CNODLVT DCCKNTWBKAD12BWP280H6P57CNODLVT DCCKNTWBKAD10BWP280H6P57CNODLVT CKNTWBKAD3BWP280H6P57CNODLVT CKNTWBKAD2BWP280H6P57CNODLVT DCCKNTWBKAD8BWP280H6P57CNODELVT DCCKNTWBKAD6BWP280H6P57CNODELVT DCCKNTWBKAD5BWP280H6P57CNODELVT DCCKNTWBKAD4BWP280H6P57CNODELVT DCCKNTWBKAD16BWP280H6P57CNODELVT DCCKNTWBKAD14BWP280H6P57CNODELVT DCCKNTWBKAD12BWP280H6P57CNODELVT DCCKNTWBKAD10BWP280H6P57CNODELVT CKNTWBKAD3BWP280H6P57CNODELVT CKNTWBKAD2BWP280H6P57CNODELVT"
        }
        if {$clock_gate eq "" } {
            log -error "::LIBCELL(clock_gate) Is not define correctly. Taking default list. Please contact bfw team."
            set clock_gate "CKLNQKAD8BWP280H6P57CNODULVTLL CKLNQKAD6BWP280H6P57CNODULVTLL CKLNQKAD5BWP280H6P57CNODULVTLL CKLNQKAD4BWP280H6P57CNODULVTLL CKLNQKAD3BWP280H6P57CNODULVTLL CKLNQKAD2BWP280H6P57CNODULVTLL CKLNQKAD1BWP280H6P57CNODULVTLL CKLNQKAD16BWP280H6P57CNODULVTLL CKLNQKAD14BWP280H6P57CNODULVTLL CKLNQKAD12BWP280H6P57CNODULVTLL CKLNQKAD10BWP280H6P57CNODULVTLL CKLHQKAD8BWP280H6P57CNODULVTLL CKLHQKAD6BWP280H6P57CNODULVTLL CKLHQKAD5BWP280H6P57CNODULVTLL CKLHQKAD4BWP280H6P57CNODULVTLL CKLHQKAD3BWP280H6P57CNODULVTLL CKLHQKAD2BWP280H6P57CNODULVTLL CKLHQKAD1BWP280H6P57CNODULVTLL CKLHQKAD16BWP280H6P57CNODULVTLL CKLHQKAD14BWP280H6P57CNODULVTLL CKLHQKAD12BWP280H6P57CNODULVTLL CKLHQKAD10BWP280H6P57CNODULVTLL CKLNQKAD8BWP280H6P57CNODULVT CKLNQKAD6BWP280H6P57CNODULVT CKLNQKAD5BWP280H6P57CNODULVT CKLNQKAD4BWP280H6P57CNODULVT CKLNQKAD3BWP280H6P57CNODULVT CKLNQKAD2BWP280H6P57CNODULVT CKLNQKAD1BWP280H6P57CNODULVT CKLNQKAD16BWP280H6P57CNODULVT CKLNQKAD14BWP280H6P57CNODULVT CKLNQKAD12BWP280H6P57CNODULVT CKLNQKAD10BWP280H6P57CNODULVT CKLHQKAD8BWP280H6P57CNODULVT CKLHQKAD6BWP280H6P57CNODULVT CKLHQKAD5BWP280H6P57CNODULVT CKLHQKAD4BWP280H6P57CNODULVT CKLHQKAD3BWP280H6P57CNODULVT CKLHQKAD2BWP280H6P57CNODULVT CKLHQKAD1BWP280H6P57CNODULVT CKLHQKAD16BWP280H6P57CNODULVT CKLHQKAD14BWP280H6P57CNODULVT CKLHQKAD12BWP280H6P57CNODULVT CKLHQKAD10BWP280H6P57CNODULVT CKLNQKAD8BWP280H6P57CNODLVTLL CKLNQKAD6BWP280H6P57CNODLVTLL CKLNQKAD5BWP280H6P57CNODLVTLL CKLNQKAD4BWP280H6P57CNODLVTLL CKLNQKAD3BWP280H6P57CNODLVTLL CKLNQKAD2BWP280H6P57CNODLVTLL CKLNQKAD1BWP280H6P57CNODLVTLL CKLNQKAD16BWP280H6P57CNODLVTLL CKLNQKAD14BWP280H6P57CNODLVTLL CKLNQKAD12BWP280H6P57CNODLVTLL CKLNQKAD10BWP280H6P57CNODLVTLL CKLHQKAD8BWP280H6P57CNODLVTLL CKLHQKAD6BWP280H6P57CNODLVTLL CKLHQKAD5BWP280H6P57CNODLVTLL CKLHQKAD4BWP280H6P57CNODLVTLL CKLHQKAD3BWP280H6P57CNODLVTLL CKLHQKAD2BWP280H6P57CNODLVTLL CKLHQKAD1BWP280H6P57CNODLVTLL CKLHQKAD16BWP280H6P57CNODLVTLL CKLHQKAD14BWP280H6P57CNODLVTLL CKLHQKAD12BWP280H6P57CNODLVTLL CKLHQKAD10BWP280H6P57CNODLVTLL CKLNQKAD8BWP280H6P57CNODLVT CKLNQKAD6BWP280H6P57CNODLVT CKLNQKAD5BWP280H6P57CNODLVT CKLNQKAD4BWP280H6P57CNODLVT CKLNQKAD3BWP280H6P57CNODLVT CKLNQKAD2BWP280H6P57CNODLVT CKLNQKAD1BWP280H6P57CNODLVT CKLNQKAD16BWP280H6P57CNODLVT CKLNQKAD14BWP280H6P57CNODLVT CKLNQKAD12BWP280H6P57CNODLVT CKLNQKAD10BWP280H6P57CNODLVT CKLHQKAD8BWP280H6P57CNODLVT CKLHQKAD6BWP280H6P57CNODLVT CKLHQKAD5BWP280H6P57CNODLVT CKLHQKAD4BWP280H6P57CNODLVT CKLHQKAD3BWP280H6P57CNODLVT CKLHQKAD2BWP280H6P57CNODLVT CKLHQKAD1BWP280H6P57CNODLVT CKLHQKAD16BWP280H6P57CNODLVT CKLHQKAD14BWP280H6P57CNODLVT CKLHQKAD12BWP280H6P57CNODLVT CKLHQKAD10BWP280H6P57CNODLVT CKLNQKAD8BWP280H6P57CNODELVT CKLNQKAD6BWP280H6P57CNODELVT CKLNQKAD5BWP280H6P57CNODELVT CKLNQKAD4BWP280H6P57CNODELVT CKLNQKAD3BWP280H6P57CNODELVT CKLNQKAD2BWP280H6P57CNODELVT CKLNQKAD1BWP280H6P57CNODELVT CKLNQKAD16BWP280H6P57CNODELVT CKLNQKAD14BWP280H6P57CNODELVT CKLNQKAD12BWP280H6P57CNODELVT CKLNQKAD10BWP280H6P57CNODELVT CKLHQKAD8BWP280H6P57CNODELVT CKLHQKAD6BWP280H6P57CNODELVT CKLHQKAD5BWP280H6P57CNODELVT CKLHQKAD4BWP280H6P57CNODELVT CKLHQKAD3BWP280H6P57CNODELVT CKLHQKAD2BWP280H6P57CNODELVT CKLHQKAD1BWP280H6P57CNODELVT CKLHQKAD16BWP280H6P57CNODELVT CKLHQKAD14BWP280H6P57CNODELVT CKLHQKAD12BWP280H6P57CNODELVT CKLHQKAD10BWP280H6P57CNODELVT"
        }
        if {$clock_comb eq "" } {
            log -error "::LIBCELL(clock_comb) Is not define correctly. Taking default list. Please contact bfw team."
            set clock_comb "CKND2NOMSCKAD1BWP280H6P57CNODULVTLL CKND2NOMSBKAD1BWP280H6P57CNODULVTLL CKXOR2KAD4BWP280H6P57CNODULVTLL CKXOR2KAD2BWP280H6P57CNODULVTLL CKXOR2KAD1BWP280H6P57CNODULVTLL CKOR2KAD4BWP280H6P57CNODULVTLL CKOR2KAD2BWP280H6P57CNODULVTLL CKOR2KAD1BWP280H6P57CNODULVTLL CKND2NOMSAKAD1BWP280H6P57CNODULVTLL CKND2KAD4BWP280H6P57CNODULVTLL CKND2KAD2BWP280H6P57CNODULVTLL CKMUX2KAD4BWP280H6P57CNODULVTLL CKMUX2KAD2BWP280H6P57CNODULVTLL CKMUX2KAD1BWP280H6P57CNODULVTLL CKAN2KAD4BWP280H6P57CNODULVTLL CKAN2KAD2BWP280H6P57CNODULVTLL CKAN2KAD1BWP280H6P57CNODULVTLL CKND2NOMSCKAD1BWP280H6P57CNODULVT CKND2NOMSBKAD1BWP280H6P57CNODULVT CKXOR2KAD4BWP280H6P57CNODULVT CKXOR2KAD2BWP280H6P57CNODULVT CKXOR2KAD1BWP280H6P57CNODULVT CKOR2KAD4BWP280H6P57CNODULVT CKOR2KAD2BWP280H6P57CNODULVT CKOR2KAD1BWP280H6P57CNODULVT CKND2NOMSAKAD1BWP280H6P57CNODULVT CKND2KAD4BWP280H6P57CNODULVT CKND2KAD2BWP280H6P57CNODULVT CKMUX2KAD4BWP280H6P57CNODULVT CKMUX2KAD2BWP280H6P57CNODULVT CKMUX2KAD1BWP280H6P57CNODULVT CKAN2KAD4BWP280H6P57CNODULVT CKAN2KAD2BWP280H6P57CNODULVT CKAN2KAD1BWP280H6P57CNODULVT CKND2NOMSCKAD1BWP280H6P57CNODLVTLL CKND2NOMSBKAD1BWP280H6P57CNODLVTLL CKXOR2KAD4BWP280H6P57CNODLVTLL CKXOR2KAD2BWP280H6P57CNODLVTLL CKXOR2KAD1BWP280H6P57CNODLVTLL CKOR2KAD4BWP280H6P57CNODLVTLL CKOR2KAD2BWP280H6P57CNODLVTLL CKOR2KAD1BWP280H6P57CNODLVTLL CKND2NOMSAKAD1BWP280H6P57CNODLVTLL CKND2KAD4BWP280H6P57CNODLVTLL CKND2KAD2BWP280H6P57CNODLVTLL CKMUX2KAD4BWP280H6P57CNODLVTLL CKMUX2KAD2BWP280H6P57CNODLVTLL CKMUX2KAD1BWP280H6P57CNODLVTLL CKAN2KAD4BWP280H6P57CNODLVTLL CKAN2KAD2BWP280H6P57CNODLVTLL CKAN2KAD1BWP280H6P57CNODLVTLL CKND2NOMSCKAD1BWP280H6P57CNODLVT CKND2NOMSBKAD1BWP280H6P57CNODLVT CKXOR2KAD4BWP280H6P57CNODLVT CKXOR2KAD2BWP280H6P57CNODLVT CKXOR2KAD1BWP280H6P57CNODLVT CKOR2KAD4BWP280H6P57CNODLVT CKOR2KAD2BWP280H6P57CNODLVT CKOR2KAD1BWP280H6P57CNODLVT CKND2NOMSAKAD1BWP280H6P57CNODLVT CKND2KAD4BWP280H6P57CNODLVT CKND2KAD2BWP280H6P57CNODLVT CKMUX2KAD4BWP280H6P57CNODLVT CKMUX2KAD2BWP280H6P57CNODLVT CKMUX2KAD1BWP280H6P57CNODLVT CKAN2KAD4BWP280H6P57CNODLVT CKAN2KAD2BWP280H6P57CNODLVT CKAN2KAD1BWP280H6P57CNODLVT CKND2NOMSCKAD1BWP280H6P57CNODELVT CKND2NOMSBKAD1BWP280H6P57CNODELVT CKXOR2KAD4BWP280H6P57CNODELVT CKXOR2KAD2BWP280H6P57CNODELVT CKXOR2KAD1BWP280H6P57CNODELVT CKOR2KAD4BWP280H6P57CNODELVT CKOR2KAD2BWP280H6P57CNODELVT CKOR2KAD1BWP280H6P57CNODELVT CKND2NOMSAKAD1BWP280H6P57CNODELVT CKND2KAD4BWP280H6P57CNODELVT CKND2KAD2BWP280H6P57CNODELVT CKMUX2KAD4BWP280H6P57CNODELVT CKMUX2KAD2BWP280H6P57CNODELVT CKMUX2KAD1BWP280H6P57CNODELVT CKAN2KAD4BWP280H6P57CNODELVT CKAN2KAD2BWP280H6P57CNODELVT CKAN2KAD1BWP280H6P57CNODELVT"
        }

    } else {
        set clock_buf  [::common::tdb_filter_key -filter "^CKBD2B|^CKBD3B|^DCCKBD4B|^DCCKBD5B|^DCCKBD6B|^DCCKBD7B|^DCCKBD8B|^DCCKBD10B|^DCCKBD12B|^DCCKBD14B|^DCCKBD16B" -key $clock_buf]
        set clock_inv  [::common::tdb_filter_key -filter "^CKND2B|^CKND3B|^DCCKND4B|^DCCKND5B|^DCCKND6B|^DCCKND7B|^DCCKND8B|^DCCKND10B|^DCCKND12B|^DCCKND14B|^DCCKND16B" -key $clock_inv]
        set clock_gate  [::common::tdb_filter_key -filter "^CK.*D1B.*|^CK.*D2B.*|^CK.*D3B|^CK.*D4B|^CK.*D5B|^CK.*D6B|^CK.*D7B|^CK.*D8B|^CK.*D10B|^CK.*D12B|^CK.*D14B|^CK.*D16B" -key $clock_gate]
        set clock_comb  [::common::tdb_filter_key -filter "^CK.*D1B.*|^CK.*D2B.*|^CK.*D3B|^CK.*D4B" -key $clock_comb]
        if {$clock_buf eq "" } {
            log -error "::LIBCELL(clock_buf) Is not define correctly. Taking default list. Please contact bfw team."
            set clock_buf "DCCKBD8BWP210H6P51CNODULVTLL DCCKBD6BWP210H6P51CNODULVTLL DCCKBD5BWP210H6P51CNODULVTLL DCCKBD4BWP210H6P51CNODULVTLL DCCKBD16BWP210H6P51CNODULVTLL DCCKBD14BWP210H6P51CNODULVTLL DCCKBD12BWP210H6P51CNODULVTLL DCCKBD10BWP210H6P51CNODULVTLL CKBD3BWP210H6P51CNODULVTLL CKBD2BWP210H6P51CNODULVTLL DCCKBD8BWP210H6P51CNODULVT DCCKBD6BWP210H6P51CNODULVT DCCKBD5BWP210H6P51CNODULVT DCCKBD4BWP210H6P51CNODULVT DCCKBD16BWP210H6P51CNODULVT DCCKBD14BWP210H6P51CNODULVT DCCKBD12BWP210H6P51CNODULVT DCCKBD10BWP210H6P51CNODULVT CKBD3BWP210H6P51CNODULVT CKBD2BWP210H6P51CNODULVT DCCKBD8BWP210H6P51CNODLVTLL DCCKBD6BWP210H6P51CNODLVTLL DCCKBD5BWP210H6P51CNODLVTLL DCCKBD4BWP210H6P51CNODLVTLL DCCKBD16BWP210H6P51CNODLVTLL DCCKBD14BWP210H6P51CNODLVTLL DCCKBD12BWP210H6P51CNODLVTLL DCCKBD10BWP210H6P51CNODLVTLL CKBD3BWP210H6P51CNODLVTLL CKBD2BWP210H6P51CNODLVTLL DCCKBD8BWP210H6P51CNODLVT DCCKBD6BWP210H6P51CNODLVT DCCKBD5BWP210H6P51CNODLVT DCCKBD4BWP210H6P51CNODLVT DCCKBD16BWP210H6P51CNODLVT DCCKBD14BWP210H6P51CNODLVT DCCKBD12BWP210H6P51CNODLVT DCCKBD10BWP210H6P51CNODLVT CKBD3BWP210H6P51CNODLVT CKBD2BWP210H6P51CNODLVT DCCKBD8BWP210H6P51CNODELVT DCCKBD6BWP210H6P51CNODELVT DCCKBD5BWP210H6P51CNODELVT DCCKBD4BWP210H6P51CNODELVT DCCKBD16BWP210H6P51CNODELVT DCCKBD14BWP210H6P51CNODELVT DCCKBD12BWP210H6P51CNODELVT DCCKBD10BWP210H6P51CNODELVT CKBD3BWP210H6P51CNODELVT CKBD2BWP210H6P51CNODELVT"
        }
        if {$clock_inv eq "" } {
            log -error "::LIBCELL(clock_inv) Is not define correctly. Taking default list. Please contact bfw team."
            set clock_inv "DCCKND8BWP210H6P51CNODULVTLL DCCKND6BWP210H6P51CNODULVTLL DCCKND5BWP210H6P51CNODULVTLL DCCKND4BWP210H6P51CNODULVTLL DCCKND16BWP210H6P51CNODULVTLL DCCKND14BWP210H6P51CNODULVTLL DCCKND12BWP210H6P51CNODULVTLL DCCKND10BWP210H6P51CNODULVTLL CKND3BWP210H6P51CNODULVTLL CKND2BWP210H6P51CNODULVTLL DCCKND8BWP210H6P51CNODULVT DCCKND6BWP210H6P51CNODULVT DCCKND5BWP210H6P51CNODULVT DCCKND4BWP210H6P51CNODULVT DCCKND16BWP210H6P51CNODULVT DCCKND14BWP210H6P51CNODULVT DCCKND12BWP210H6P51CNODULVT DCCKND10BWP210H6P51CNODULVT CKND3BWP210H6P51CNODULVT CKND2BWP210H6P51CNODULVT DCCKND8BWP210H6P51CNODLVTLL DCCKND6BWP210H6P51CNODLVTLL DCCKND5BWP210H6P51CNODLVTLL DCCKND4BWP210H6P51CNODLVTLL DCCKND16BWP210H6P51CNODLVTLL DCCKND14BWP210H6P51CNODLVTLL DCCKND12BWP210H6P51CNODLVTLL DCCKND10BWP210H6P51CNODLVTLL CKND3BWP210H6P51CNODLVTLL CKND2BWP210H6P51CNODLVTLL DCCKND8BWP210H6P51CNODLVT DCCKND6BWP210H6P51CNODLVT DCCKND5BWP210H6P51CNODLVT DCCKND4BWP210H6P51CNODLVT DCCKND16BWP210H6P51CNODLVT DCCKND14BWP210H6P51CNODLVT DCCKND12BWP210H6P51CNODLVT DCCKND10BWP210H6P51CNODLVT CKND3BWP210H6P51CNODLVT CKND2BWP210H6P51CNODLVT DCCKND8BWP210H6P51CNODELVT DCCKND6BWP210H6P51CNODELVT DCCKND5BWP210H6P51CNODELVT DCCKND4BWP210H6P51CNODELVT DCCKND16BWP210H6P51CNODELVT DCCKND14BWP210H6P51CNODELVT DCCKND12BWP210H6P51CNODELVT DCCKND10BWP210H6P51CNODELVT CKND3BWP210H6P51CNODELVT CKND2BWP210H6P51CNODELVT"
        }
        if {$clock_gate eq "" } {
            log -error "::LIBCELL(clock_gate) Is not define correctly. Taking default list. Please contact bfw team."
            set clock_gate "CKLNQD8BWP210H6P51CNODULVTLL CKLNQD6BWP210H6P51CNODULVTLL CKLNQD5BWP210H6P51CNODULVTLL CKLNQD4BWP210H6P51CNODULVTLL CKLNQD3BWP210H6P51CNODULVTLL CKLNQD2BWP210H6P51CNODULVTLL CKLNQD1BWP210H6P51CNODULVTLL CKLNQD16BWP210H6P51CNODULVTLL CKLNQD14BWP210H6P51CNODULVTLL CKLNQD12BWP210H6P51CNODULVTLL CKLNQD10BWP210H6P51CNODULVTLL CKLHQD8BWP210H6P51CNODULVTLL CKLHQD6BWP210H6P51CNODULVTLL CKLHQD5BWP210H6P51CNODULVTLL CKLHQD4BWP210H6P51CNODULVTLL CKLHQD3BWP210H6P51CNODULVTLL CKLHQD2BWP210H6P51CNODULVTLL CKLHQD1BWP210H6P51CNODULVTLL CKLHQD16BWP210H6P51CNODULVTLL CKLHQD14BWP210H6P51CNODULVTLL CKLHQD12BWP210H6P51CNODULVTLL CKLHQD10BWP210H6P51CNODULVTLL CKLNQD8BWP210H6P51CNODULVT CKLNQD6BWP210H6P51CNODULVT CKLNQD5BWP210H6P51CNODULVT CKLNQD4BWP210H6P51CNODULVT CKLNQD3BWP210H6P51CNODULVT CKLNQD2BWP210H6P51CNODULVT CKLNQD1BWP210H6P51CNODULVT CKLNQD16BWP210H6P51CNODULVT CKLNQD14BWP210H6P51CNODULVT CKLNQD12BWP210H6P51CNODULVT CKLNQD10BWP210H6P51CNODULVT CKLHQD8BWP210H6P51CNODULVT CKLHQD6BWP210H6P51CNODULVT CKLHQD5BWP210H6P51CNODULVT CKLHQD4BWP210H6P51CNODULVT CKLHQD3BWP210H6P51CNODULVT CKLHQD2BWP210H6P51CNODULVT CKLHQD1BWP210H6P51CNODULVT CKLHQD16BWP210H6P51CNODULVT CKLHQD14BWP210H6P51CNODULVT CKLHQD12BWP210H6P51CNODULVT CKLHQD10BWP210H6P51CNODULVT CKLNQD8BWP210H6P51CNODLVTLL CKLNQD6BWP210H6P51CNODLVTLL CKLNQD5BWP210H6P51CNODLVTLL CKLNQD4BWP210H6P51CNODLVTLL CKLNQD3BWP210H6P51CNODLVTLL CKLNQD2BWP210H6P51CNODLVTLL CKLNQD1BWP210H6P51CNODLVTLL CKLNQD16BWP210H6P51CNODLVTLL CKLNQD14BWP210H6P51CNODLVTLL CKLNQD12BWP210H6P51CNODLVTLL CKLNQD10BWP210H6P51CNODLVTLL CKLHQD8BWP210H6P51CNODLVTLL CKLHQD6BWP210H6P51CNODLVTLL CKLHQD5BWP210H6P51CNODLVTLL CKLHQD4BWP210H6P51CNODLVTLL CKLHQD3BWP210H6P51CNODLVTLL CKLHQD2BWP210H6P51CNODLVTLL CKLHQD1BWP210H6P51CNODLVTLL CKLHQD16BWP210H6P51CNODLVTLL CKLHQD14BWP210H6P51CNODLVTLL CKLHQD12BWP210H6P51CNODLVTLL CKLHQD10BWP210H6P51CNODLVTLL CKLNQD8BWP210H6P51CNODLVT CKLNQD6BWP210H6P51CNODLVT CKLNQD5BWP210H6P51CNODLVT CKLNQD4BWP210H6P51CNODLVT CKLNQD3BWP210H6P51CNODLVT CKLNQD2BWP210H6P51CNODLVT CKLNQD1BWP210H6P51CNODLVT CKLNQD16BWP210H6P51CNODLVT CKLNQD14BWP210H6P51CNODLVT CKLNQD12BWP210H6P51CNODLVT CKLNQD10BWP210H6P51CNODLVT CKLHQD8BWP210H6P51CNODLVT CKLHQD6BWP210H6P51CNODLVT CKLHQD5BWP210H6P51CNODLVT CKLHQD4BWP210H6P51CNODLVT CKLHQD3BWP210H6P51CNODLVT CKLHQD2BWP210H6P51CNODLVT CKLHQD1BWP210H6P51CNODLVT CKLHQD16BWP210H6P51CNODLVT CKLHQD14BWP210H6P51CNODLVT CKLHQD12BWP210H6P51CNODLVT CKLHQD10BWP210H6P51CNODLVT CKLNQD8BWP210H6P51CNODELVT CKLNQD6BWP210H6P51CNODELVT CKLNQD5BWP210H6P51CNODELVT CKLNQD4BWP210H6P51CNODELVT CKLNQD3BWP210H6P51CNODELVT CKLNQD2BWP210H6P51CNODELVT CKLNQD1BWP210H6P51CNODELVT CKLNQD16BWP210H6P51CNODELVT CKLNQD14BWP210H6P51CNODELVT CKLNQD12BWP210H6P51CNODELVT CKLNQD10BWP210H6P51CNODELVT CKLHQD8BWP210H6P51CNODELVT CKLHQD6BWP210H6P51CNODELVT CKLHQD5BWP210H6P51CNODELVT CKLHQD4BWP210H6P51CNODELVT CKLHQD3BWP210H6P51CNODELVT CKLHQD2BWP210H6P51CNODELVT CKLHQD1BWP210H6P51CNODELVT CKLHQD16BWP210H6P51CNODELVT CKLHQD14BWP210H6P51CNODELVT CKLHQD12BWP210H6P51CNODELVT CKLHQD10BWP210H6P51CNODELVT"
        }
    }

    # filter by VT type.
    set ::CDB(clock_buf)  [::common::tdb_filter_key -filter $regx -key $clock_buf]
    set ::CDB(clock_inv)  [::common::tdb_filter_key -filter $regx -key $clock_inv]
    set ::CDB(clock_gate) [::common::tdb_filter_key -filter $regx -key $clock_gate]
    set ::CDB(clock_comb) [::common::tdb_filter_key -filter $regx -key $clock_comb]
    

    # one more filter by 280 / 210 in case the LIBCELL array will change
    if {[regexp {280} $::ARR2TDB(cell_tracks)]}  {
        set regx 280
    } else {
        set regx 210
    }
    set ::CDB(clock_buf)  [::common::tdb_filter_key -filter $regx -key $::CDB(clock_buf)]
    set ::CDB(clock_inv)  [::common::tdb_filter_key -filter $regx -key $::CDB(clock_inv)]
    set ::CDB(clock_gate) [::common::tdb_filter_key -filter $regx -key $::CDB(clock_gate)]
    set ::CDB(clock_comb) [::common::tdb_filter_key -filter $regx -key $::CDB(clock_comb)]
    
    # One more filter. if a cells have a TWB rev drop the NoNe-TWB cell.
    set clock_buf_twb  [::common::tdb_filter_key -filter "TW\[A\|B\]" -key $::CDB(clock_buf)]
    set clock_inv_twb  [::common::tdb_filter_key -filter "TW\[A\|B\]" -key $::CDB(clock_inv)]
    set clock_gate_twb [::common::tdb_filter_key -filter "TW\[A\|B\]" -key $::CDB(clock_gate)]
    set clock_comb_twb [::common::tdb_filter_key -filter "TW\[A\|B\]" -key $::CDB(clock_comb)]
    # buf
    if {$clock_buf_twb eq ""} {puts "Info: no TWB at list ::CDB(clock_buf)"}
    foreach cell $clock_buf_twb {
        regsub {TW[A|B]} $cell {} removed_cell
        set idx [lsearch $::CDB(clock_buf) $removed_cell]
        if {$idx >= 0} {
            set ::CDB(clock_buf) [lreplace $::CDB(clock_buf) $idx $idx]
            puts "Info: for $cell we remove $removed_cell"
        } else {
            puts "Info: no non TWA/B for ::CDB(clock_buf)"
        }
    }
    # inv
    if {$clock_inv_twb eq ""} {puts "Info: no TWA/B at list ::CDB(clock_inv)"}
    foreach cell $clock_inv_twb {
        regsub {TW[A|B]} $cell {} removed_cell
        set idx [lsearch $::CDB(clock_inv) $removed_cell]
        if {$idx >= 0} {
            set ::CDB(clock_inv) [lreplace $::CDB(clock_inv) $idx $idx]
            puts "Info: for $cell we remove $removed_cell"
        } else {
            puts "Info: no non TWA/B for ::CDB(clock_inv)"
        }
    }
    # gate
    if {$clock_gate_twb eq ""} {puts "Info: no TWA/B at list ::CDB(clock_gate)"}
    foreach cell $clock_gate_twb {
        regsub {TW[A|B]} $cell {} removed_cell
        set idx [lsearch $::CDB(clock_gate) $removed_cell]
        if {$idx >= 0} {
            set ::CDB(clock_gate) [lreplace $::CDB(clock_gate) $idx $idx]
            puts "Info: for $cell we remove $removed_cell"
        } else {
            puts "Info: no non TWA/B for $cell"
        }
    }
    # comb
    if {$clock_comb_twb eq ""} {puts "Info: no TWA/B at list ::CDB(clock_comb)"}
    foreach cell $clock_comb_twb {
        regsub {TW[A|B]} $cell {} removed_cell
        set idx [lsearch $::CDB(clock_comb) $removed_cell]
        if {$idx >= 0} {
            set ::CDB(clock_comb) [lreplace $::CDB(clock_comb) $idx $idx]
            puts "Info: for $cell we remove $removed_cell"
        } else {
            puts "Info: no non TWA/B for $cell"
        }
    }


    # set_db
    set_db cts_buffer_cells       $::CDB(clock_buf)
    set_db cts_inverter_cells     $::CDB(clock_inv)
    set_db cts_clock_gating_cells $::CDB(clock_gate)
    set_db cts_logic_cells        $::CDB(clock_comb)



    # Advance CTS cells use settings.
    if {[info exists ::CDB(clock_leaf_buf)]   && $::CDB(clock_leaf_buf) ne {}}         {set_db cts_buffer_cells_leaf   $::CDB(clock_leaf_buf)} else {set_db cts_buffer_cells_leaf $::CDB(clock_buf)}
    if {[info exists ::CDB(clock_top_buf)]    && $::CDB(clock_top_buf) ne {}}          {set_db cts_buffer_cells_top    $::CDB(clock_top_buf)} else {set_db cts_buffer_cells_top $::CDB(clock_buf)}
    if {[info exists ::CDB(clock_source_cells)]  && $::CDB(clock_source_cells) ne {}}  {set_db cts_clock_source_cells  $::CDB(clock_source_cells)}
    if {[info exists ::CDB(clock_delay_cells)]   && $::CDB(clock_delay_cells) ne {}}   {set_db cts_delay_cells         $::CDB(clock_delay_cells)}
    if {[info exists ::CDB(clock_leaf_inv)] && $::CDB(clock_leaf_inv) ne {}}           {set_db cts_inverter_cells_leaf $::CDB(clock_leaf_inv)} else {set_db cts_inverter_cells_leaf $::CDB(clock_inv)}
    if {[info exists ::CDB(clock_top_inv)]  && $::CDB(clock_top_inv) ne {}}            {set_db cts_inverter_cells_top  $::CDB(clock_top_inv)} else {set_db cts_inverter_cells_top $::CDB(clock_inv)}

    # Un dont use the cts cells. if cts cells are at dont use cloning is having a hard time to work.
    


    # DRV settings.
    set_db cts_top_fanout_threshold             15000
    set_db cts_target_max_transition_time       $::TIMING(clk_max_trans)
    set_db cts_target_max_transition_time_top   $::TIMING(clk_max_trans)
    set_db cts_target_max_transition_time_trunk $::TIMING(clk_max_trans)
    set_db cts_target_max_transition_time_leaf  $::TIMING(clk_max_trans)
    set_db cts_target_max_capacitance           $::TIMING(clk_max_cap)
    set_db cts_target_max_capacitance_top       $::TIMING(clk_max_cap)
    set_db cts_target_max_capacitance_trunk     $::TIMING(clk_max_cap)
    set_db cts_target_max_capacitance_leaf      $::TIMING(clk_max_cap)
    set_db cts_max_fanout                       $::TIMING(clk_max_fanouts)
    #If a target max transition is not specified, CTS will examine the cts_target_max_transition_time_sdc

 
    # Set cts halo.
    set_db cts_cell_halo_rows    1
    set_db cts_cell_halo_sites   4
    set_db cts_cell_halo_x       auto
    set_db cts_cell_halo_y       auto

    # Set skew setting.
    set_db cts_target_skew        $::CLOCK(cts_target_skew)
    #set_db skew_group:ck200m/func .cts_target_skew 0.1ns
    #-- set clock latncy pins, skew groups ....
    #set_db pin:mem1/CK .cts_pin_insertion_delay 1.2ns ;# or sdc command  set_clock_latency. tool will use this at ccopt_design
    #-- Restricting CCOpt Skew Scheduling
    set_db ccopt_auto_limit_insertion_delay_factor $::CLOCK(ccopt_auto_limit_insertion_delay_factor) ;# This permits useful skew scheduling to increase the global maximum insertion delay by up to 50%
    foreach sg [get_db skew_groups] {
        set_db $sg .cts_target_skew $::CLOCK(cts_target_skew)
        set_db $sg .cts_skew_group_constrains ccopt
    }


     # - Control whether we use useful skew (ccd)
    if {$::CLOCK(useful_skew_cts) ne "none" && $::CLOCK(useful_skew_cts) ne "None" && $::CLOCK(useful_skew_cts) ne "" && $::CLOCK(useful_skew_cts) ne 0} {
        set_db opt_useful_skew            true
        set_db opt_useful_skew_ccopt      $::CLOCK(useful_skew_cts); # none | standard | extreme
        log -info "useful skew Switched on."
    } else {
        set_db opt_useful_skew            false
        set_db opt_useful_skew_ccopt      none
        log -info "Useful skew Switched off."
    }
    

    # Tool setting.
    # Not needed   set_db cts_spec_config_create_clock_tree_source_groups true
    # AR: IPBUBF-1824 just to be sure - let's force set this variable to "false" which 
    # is the # default, but in case people are re-running from CTS it might still be 
    # sticky set to "true" from ECF flow or what not
    set_db cts_spec_config_create_clock_tree_source_groups false 
    # 
    #set_db cts_clone_clock_gates true
    # set_db cts_clone_clock_logic true
    set_db cts_use_inverters     $::CLOCK(cts_use_inverters)
    set_db cts_balance_mode      $::CLOCK(cts_balance_mode) ;#full ;# cluster | trial | full
    if {[info exists ::CLOCK(cts_clone_clock_gates)]} {set_db cts_clone_clock_gates $::CLOCK(cts_clone_clock_gates)}
    if {[info exists ::CLOCK(cts_clone_clock_logic)]} {set_db cts_clone_clock_logic $::CLOCK(cts_clone_clock_logic)}
    set_db cts_clock_gate_movement_limit  100 ;#df 10
    set_db cts_merge_clock_gates true  ;#df false
    set_db cts_move_clock_gates  true  ;#df true
    set_db cts_size_clock_gates  true  ;#df true

    if {[info exists ::CLOCK(update_io_latency)] && $::CLOCK(update_io_latency) ne ""} {
        if {$::CLOCK(update_io_latency)} {
            set_db cts_update_clock_latency true
        } else {
            set_db cts_update_clock_latency false
        }
    }
    #CPPR settings.
    set_db timing_analysis_cppr                                            both
    set_db timing_cppr_propagate_thru_latches                              false
    set_db timing_cppr_remove_clock_to_data_pessimism                      true
    set_db timing_cppr_self_loop_mode                                      false
    set_db timing_cppr_skip_clock_reconvergence                            false
    set_db timing_cppr_skip_clock_reconvergence_for_unmatched_clocks       false
    set_db timing_cppr_threshold_ps                                        0
    set_db timing_cppr_transition_sense                                    normal
    set_db timing_enable_pessimistic_cppr_for_reconvergent_clock_paths     true
    set_db timing_enable_si_cppr                                           true
    set_db timing_report_enable_cppr_point                                 true
    # Antenna Diode insertion.
    if {[info exists ::CLOCK(diode_insertion_for_clock_nets)] && $::CLOCK(diode_insertion_for_clock_nets) eq 1} {
        puts "setting route_design_diode_insertion_for_clock_nets :: true"
        set_db route_design_diode_insertion_for_clock_nets true
    }

#     #cts_primary_delay_corner
#     if {[info exists ::CLOCK(cts_primary_delay_corner)]} {
#         if { [llength [get_db delay_corners $::CLOCK(cts_primary_delay_corner)]] eq "1"} {
#             set_db cts_primary_delay_corner $::CLOCK(cts_primary_delay_corner)
#             log -info "cts_primary_delay_corner got set to $::CLOCK(cts_primary_delay_corner)"
#         } else {
#             log -error "ERROR: set_db cts_primary_delay_corner is set to $::CLOCK(cts_primary_delay_corner), a none existing corner. please change your ::CLOCK(cts_primary_delay_corner) setting."
#             error "ERROR: set_db cts_primary_delay_corner is set to $::CLOCK(cts_primary_delay_corner), a none existing corner. please change your ::CLOCK(cts_primary_delay_corner) setting. \nType get_db delay_corners and take the a slow max corner"                 
#         }
#     }
    #IPBUBF-4426 fix: Redefine cts_primary_delay_corner if not defined or does not exist.
    ::inv::clock::retrieve_cts_delay_corner

    #IPBUBF2780 fix: prefer inverters on CTS clocks ... [for better balancing to reduce min_pulse_width violations at the end of long slow clock trees]
    #     ... by default unless overriden using "ipbu_set_key {PNR CLOCK cts_use_inverters_on_cts_clocks} 0"
    if {[info exists ::CLOCK(cts_use_inverters_on_cts_clocks)] && $::CLOCK(cts_use_inverters_on_cts_clocks)} {
        foreach clocktree [get_db clock_trees .name] {
            set clock_inst_names [get_db [get_db clock_trees $clocktree] .insts.name]
            if {([lsearch -regexp $clock_inst_names .*MSCTS_TAP.*] == -1)} {
               log -info "Setting $clocktree to prefer inverters for balancing to reduce min_pulse_width violations"
               set_db [get_db clock_trees $clocktree] .cts_use_inverters true
            }
        }
    } else {
      log -info "Using default buffer based balancing on slow clocks"
    }

    # IPBUBF-4015 fix Add "set_db cts_routing_preferred_layer_effort high" as an option to our flow
    # {standard | high | auto}   Default: standard
    # Make sure attr exists before trying to change it. 
    if {[info exists ::CLOCK(cts_routing_preferred_layer_effort)]} {
        set_db cts_routing_preferred_layer_effort $::CLOCK(cts_routing_preferred_layer_effort)
    }

    # IPBUBF-4119 fix Add option to allow cn_stdcell cloning during cts. This requires setting
    # the attribute .dont_touch from size_only to none
    if {[info exists ::CLOCK(allow_cn_stdcell_cloning_list)]} {
        foreach cn_stdcell_inst $::CLOCK(allow_cn_stdcell_cloning_list) {
            # Glob pattern ensures that any pre-exisiting clones (from early-clock-flow)
            # are allowed to clone in cts
            set_db [get_db insts "${cn_stdcell_inst}"] .dont_touch none 
            set_db [get_db insts "${cn_stdcell_inst}*clone*"] .dont_touch none
        }
    }

    log -info "::inv::clock::init_settings - END"
  
# set_db opt_useful_skew_ccopt $::CLOCK(useful_skew_cts)
}

