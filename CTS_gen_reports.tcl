### ************************************************************************
### *                                                                      *
### *  MARVELL CONFIDENTIAL AND PROPRIETARY NOTE                           *
### *                                                                      *
### *  This software contains information confidential and proprietary     *
### *  to Marvell, Inc. It shall not be reproduced in whole or in part,    *
### *  or transferred to other documents, or disclosed to third parties,   *
### *  or used for any purpose other than that for which it was obtained,  *
### *  without the prior written consent of Marvell, Inc.                  *
### *                                                                      *
### *  Copyright 2019-2019, Marvell, Inc.  All rights reserved.            *
### *                                                                      *
### ************************************************************************
### * Author      : Lior Allerhand (lioral)
### * Description : 
### ************************************************************************

procedure ::inv::clock::cts_gen_reports  {
    -short_description "Gen post cts reports.."
    -description       "Gen post cts reports.."
    -example           "::inv::clock::cts_gen_reports"
    -args              {{args -type string -optional -multiple -description "args list"}}
} {
    log -info "::inv::clock::cts_gen_reports - START"
    if {$args eq "cts"} {
        # report cts.
        set file_prefix "$::SESSION(session).cts"
        #Long run time# time_design -post_cts -expanded_views -report_dir ./report -report_prefix $file_prefix
        report_clock_trees -out_file ./report/$file_prefix.clock_clock_trees.rpt
        report_skew_groups -out_file ./report/$file_prefix.clock_skew_groups.rpt
        #Long run time# check_design -type cts -out_file ./report/$file_prefix.clock.check_design.rpt
        report_clock_tree_convergence -out_file ./report/$file_prefix.clock_report_clock_tree_convergence
        #Long run time# check_timing -verbose  > report/$file_prefix.clock.check_timing.rpt
    } else {
        # report cts.
        set file_prefix "$::SESSION(session).opt"
        #Long run time# time_design -post_cts -expanded_views -report_dir ./report -report_prefix $file_prefix
        report_clock_trees -out_file ./report/$file_prefix.clock_opt_clock_trees.rpt
        report_skew_groups -out_file ./report/$file_prefix.clock_opt_skew_groups.rpt
        #Long run time# check_design -type cts -out_file ./report/$file_prefix.clock_opt_post_cts.check_design.rpt
        report_clock_tree_convergence -out_file ./report/$file_prefix.clock_opt_report_clock_tree_convergence
        #Long run time# check_timing -verbose  > report/$file_prefix.clock_opt.check_timing.rpt
        # report_power
        # report_timing_summary
        # create_snapshot -name clock_metrics
        # report_metric -format html -file ./report/clock_metrics.html
    }
    log -info "::inv::clock::cts_gen_reports - END"
}
