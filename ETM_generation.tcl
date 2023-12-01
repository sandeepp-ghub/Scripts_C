procedure ::inv::ETM::write_outputs {
    -description "Writes ETM in all stages"
    -args {
        {-suffix
            -type string
            -description "Suffix that goes in as a part of the name \$name_\$suffix"
            -optional 
        }
}
} {
    
set out [expr {[info exists outdir ] ? "$outdir" : "dataout"}]
set file_name "$out/$::SESSION(design).$::SESSION(session).$::SESSION(step)"

        get_db analysis_views -foreach {
            set scen $obj(.name)
            log -info "Writing ETM file for scenario $scen"
            set mode   [mExtractFromScenario $scen mode]
            set check  [mExtractFromScenario $scen check]

            if {[info exists suffix]} {
                set lib_filename $file_name.$mode.$check.lib_$suffix
            } else {
                set lib_filename $file_name.$mode.$check.lib
            }
                # Load Design
                set_analysis_view -setup $scen -hold $scen
                #To generate PBA based ETM
                set_db timing_extract_model_slew_propagation_mode path_based_slew
                set timing_enable_timing_window_pessimism_removal false 
                #To model Waveform Propagation (WFP) in ETM, use below global. This also requires to set timing_extract_model_slew_propagation_mode gl                obal to path_based_slew since WFP based ETM is generated in PBA mode only.
                set_db timing_extract_model_enable_waveform_propagation true

                #To generate ETM
                write_timing_model -view $scen $lib_filename
            
        }

}

#::inv::ETM::write_outputs
