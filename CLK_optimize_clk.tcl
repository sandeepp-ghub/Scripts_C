procedure ::inv::clock::optimize_clock {
    -description "Proc to optimize clocks"
} {
    if {[info exists ::CLOCK(skip_post_cts_hold_timing_opt)] && $::CLOCK(skip_post_cts_hold_timing_opt) eq "1" } {
        log -info "Skiping hold opt"
    } else {
        set reports_dir $::env(PWD)/report
        opt_design -post_cts -hold -report_dir $reports_dir
    }
    # 
    # # pre route 
    # #- insert filler cells before final routing
    # if {[get_db add_fillers_cells] ne "" } {
    #     add_fillers
    # }
}
