##
procedure ::inv::clock::retrieve_cts_delay_corner {
    -description "This proc is addressing Jira IPBUBF-4426. 
                  In case default CTS delay corner is not valid or not defined, the proc re-defines it based on available CTS scenarios. 
                  It requires two inputs - $::CLOCK(cts_primary_mode) and $::CLOCK(cts_primary_corner).
                  These variables have to match one of the available cts scenarios"                   
    -args { }        
} {

log -info "::inv::clock::retrieve_cts_delay_corner - START"

if {[info exists ::CLOCK(cts_primary_delay_corner)]} {
    if {[llength [get_db delay_corners $::CLOCK(cts_primary_delay_corner)]] eq "1"} {
        set_db cts_primary_delay_corner $::CLOCK(cts_primary_delay_corner)
        log -info "cts_primary_delay_corner got set to $::CLOCK(cts_primary_delay_corner)"
    } else {
        log -info "cts_primary_delay_corner does not exist or not defined for design $::DESIGN ."

        if {[info exists ::CLOCK(cts_primary_mode)] && [info exists ::CLOCK(cts_primary_corner)]} {
            if { [llength $::CLOCK(cts_primary_mode)] > 0 && [llength $::CLOCK(cts_primary_corner)] > 0  } { 
                log -info "Now looking for available corner.. Using $::CLOCK(cts_primary_mode):$::CLOCK(cts_primary_corner) "

                if {![regexp "$::CLOCK(cts_primary_mode):$::CLOCK(cts_primary_corner)" $::SCENARIOS(cts) ]} { 
                    error  "ERROR: $::CLOCK(cts_primary_mode):$::CLOCK(cts_primary_corner) does not match valid CTS scenarios. \n \
                    Please update ::CLOCK(cts_primary_mode) and ::CLOCK(cts_primary_corner) and run again \
                    \n\nlist of available CTS corners: \n$::SCENARIOS(cts)"
                    } 
                
                foreach cts_scenario $::SCENARIOS(cts) {
                    if {[regexp "$::CLOCK(cts_primary_mode):$::CLOCK(cts_primary_corner)" $cts_scenario ]} { 
                        set my_cts_primary_delay_corner  [lindex [split [get_db [get_db analysis_views $cts_scenario] .delay_corner]  "/"] 1]
                        set_db cts_primary_delay_corner  $my_cts_primary_delay_corner
                        log -info "Matched CTS scenario: $cts_scenario"
                        log -info "cts_primary_delay_corner is set to $my_cts_primary_delay_corner"
                        }
                    }
                }
            }
        }
    }
log -info "::inv::clock::retrieve_cts_delay_corner - END"
}

