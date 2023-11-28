# Importing the libraries
# import pandas as pd
import numpy  as np
import argparse
import sys
import glob
import re
import gzip
import os.path
import globs
import subprocess
from PTRunsTracker                      import PTRunsTracker
from PTRunsDbTracker                    import PTRunsDbTracker
from usReadWriteUpdate                  import ReadUsFile
from usReadWriteUpdate                  import WriteUsFile
from print_check_timing_sum             import print_check_timing_sum
from print_check_logs_sum               import print_check_logs_sum
from parse_transition_rpt               import parse_transition_rpt
from parse_capacitance_rpt              import parse_capacitance_rpt
from parse_noise_rpt                    import parse_noise_rpt
from print_drc_table                    import print_drc_table
from print_timing_summary               import print_timing_summary
from print_logfiles_not_waived_summary  import print_logfiles_not_waived_summary
from print_snps_checkers_rpt_sum        import print_snps_checkers_rpt_sum
from show_logs                          import show_logs
from show_reports                       import show_reports
from show_reports                       import show_reports
from sum_min_period                     import sum_min_period
from sum_min_pulse_width                import sum_min_pulse_width
from sum_double_switching               import sum_double_switching
from sum_high_xtalk                     import sum_high_xtalk
from sum_none_clock_cells               import sum_none_clock_cells
from implicit_clock_termination         import implicit_clock_termination
from sum_parallel_drivers               import sum_parallel_drivers
from sum_high_cap_clock_drivers         import sum_high_cap_clock_drivers
from sum_high_fanout_nets               import sum_high_fanout_nets
from print_timing_split_sum_table       import get_modes_list_from_run_timing_log
from print_timing_split_sum_table       import collect_timing_split_sum_table
from print_timing_split_sum_table       import print_timing_split_sum_table
from print_timing_split_sum_table       import add_split_sum_to_drc_table
from print_to_excel_full_timing_summary import print_to_excel_full_timing_summary


parser = argparse.ArgumentParser(description='hal is a wrapper proc for any MISL report grep function.',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-top_work_area' ,default = False , nargs='+',  help='A path to the user run or sta run main work area.')
parser.add_argument('-blocks_list' ,default = False , nargs='+',  help='Give a list of blocks to split the DRC reports between blocks.')
parser.add_argument('-print_logfiles_not_waived_summary' ,default = False , nargs='+',  help='pass a waiver file to this flag to get a summary of all logfiles after waive.')
parser.add_argument("-print_sta_sessions",default = False, action = "store_true" , help='Print the saved sessions list.') ;# bool value
parser.add_argument("-print_db_used_for_sta_sessions",default = False, action = "store_true" , help='Print the saved sessions input db list.') ;# bool value
parser.add_argument("-print_timing_drc_table",default = False, action = "store_true" , help='Print a drc report.') ;# bool value
parser.add_argument("-print_timing_split_sum_table",default = False, action = "store_true" , help='Print Internal and interface timing foreach block.') ;# bool value
parser.add_argument("-print_check_timing_sum",default = False, action = "store_true" , help='Print a check timing report.') ;# bool value
parser.add_argument("-print_timing_summary",default = False, action = "store_true" , help='Print a check timing report.') ;# bool value
parser.add_argument("-print_timing_summary_sort_by_ep_not_wns",default = False, action = "store_true" , help='Print a check timing report.') ;# bool value
parser.add_argument("-print_to_excel_full_timing_summary",default = False, action = "store_true" , help='Print a check timing report.') ;# bool value
parser.add_argument("-print_snps_checkers_rpt_sum",default = False, action = "store_true" , help='print_snps_checkers_rpt_sum.') ;# bool value
parser.add_argument("-show_logs",default = False, action = "store_true" , help='show_logs') ;# bool valu
parser.add_argument("-show_reports",default = False, action = "store_true" , help='show_reports') ;# bool valu

#-- parse arguments                        --#
args = parser.parse_args()
globs.init()

#-- read "us" file to get run settings.    --#
# ReadUsFile()

if args.top_work_area:
    globs.US["TOP_WORK_AREA"] = args.top_work_area;
if args.print_logfiles_not_waived_summary:
    globs.US['LOG_WAIVE_FILE'] = args.print_logfiles_not_waived_summary;
if args.top_work_area:
    globs.US["BLOCKS_LIST"] = args.blocks_list;
    for block in globs.US["BLOCKS_LIST"]:
        globs.MDB[block] = {}
    globs.MDB['TOP'] ={}

#-- take any new vars from user gui for us --#
# WriteUsFile()

#-- Print the existing STA sessions.       --# 
if args.print_sta_sessions:
   print(globs.US["TOP_WORK_AREA"][0])
   PTRunsTracker(globs.US["TOP_WORK_AREA"][0])

#-- Print the db used for STA sessions.    --# 
if args.print_db_used_for_sta_sessions:
   print(globs.US["TOP_WORK_AREA"][0])
   PTRunsDbTracker(globs.US["TOP_WORK_AREA"][0])

#-- Print timing check timing summary Table.        --#
if args.print_check_timing_sum:
   print(globs.US["TOP_WORK_AREA"][0])
   print_check_timing_sum(globs.US["TOP_WORK_AREA"][0])

#-- Print timing check logs summary Table.        --#
if args.print_logfiles_not_waived_summary:
   print(globs.US["TOP_WORK_AREA"][0])
   print(globs.US["LOG_WAIVE_FILE"][0])
   print_logfiles_not_waived_summary()

if args.print_timing_summary and args.print_timing_summary_sort_by_ep_not_wns:
   print(globs.US["TOP_WORK_AREA"][0])
   print_timing_summary(globs.US["TOP_WORK_AREA"][0] , 'ep')

elif args.print_timing_summary:
   print(globs.US["TOP_WORK_AREA"][0])
   print_timing_summary(globs.US["TOP_WORK_AREA"][0] , 'wns')


if args.print_to_excel_full_timing_summary:
   print(globs.US["TOP_WORK_AREA"][0])
   print_to_excel_full_timing_summary(globs.US["TOP_WORK_AREA"][0])

if args.show_logs:
   print(globs.US["TOP_WORK_AREA"][0])
   show_logs()

if args.show_reports:
   print(globs.US["TOP_WORK_AREA"][0])
   show_reports()


if args.print_snps_checkers_rpt_sum:
   print(globs.US["TOP_WORK_AREA"][0])
   print_snps_checkers_rpt_sum()
 

dbg_timing_sum                 = True
dbg_max_trans                  = True
dbg_max_cap                    = True
dbg_noise                      = True
dbg_min_period                 = True
dbg_min_pulse_width            = True
dbg_double_switching           = True
dbg_high_xtalk                 = True
dbg_none_clock_cells           = True
dbg_implicit_clock_termination = True
dbg_sum_parallel_drivers       = True       
dbg_sum_high_cap_clock_drivers = True
dbg_sum_high_fanout_nets       = True


#-- print_timing_split_sum_table           --#
if args.print_timing_split_sum_table:
    get_modes_list_from_run_timing_log(globs.US["BLOCKS_LIST"])
    collect_timing_split_sum_table(globs.US["BLOCKS_LIST"])
    print_timing_split_sum_table(globs.US["BLOCKS_LIST"])
    
#-- Print timing DRC summary Table.        --#
if args.print_timing_drc_table:
    FNULL = open(os.devnull, 'w')

    # timing sum
    if dbg_timing_sum:
        get_modes_list_from_run_timing_log(globs.US["BLOCKS_LIST"])
        collect_timing_split_sum_table(globs.US["BLOCKS_LIST"])
        add_split_sum_to_drc_table(globs.US["BLOCKS_LIST"])
    


    # Max Trans.
    if dbg_max_trans:
        var = globs.US["TOP_WORK_AREA"][0]+'/reports/*max_tran_failures.txt'
        #var = glob.glob(var) will give var as a list of files not *
        pipe = subprocess.Popen(["perl", os.path.dirname(__file__)+"/create_joined_transition_report.pl", var], stdin=subprocess.PIPE , stdout=FNULL , stderr=FNULL)
        p_status = pipe.wait()
        parse_transition_rpt(globs.US["BLOCKS_LIST"])

    # Max Cap.
    if dbg_max_cap:
        var = globs.US["TOP_WORK_AREA"][0]+'/reports/*max_cap_failures.txt'
        pipe = subprocess.Popen(["perl", os.path.dirname(__file__)+"/create_joined_maxcap_report.pl", var], stdin=subprocess.PIPE , stdout=FNULL , stderr=FNULL)
        p_status = pipe.wait()
        parse_capacitance_rpt(globs.US["BLOCKS_LIST"])

    # Max Noise.
    if dbg_noise:
        var = globs.US["TOP_WORK_AREA"][0]+'/reports/*report_noise.rpt.gz'
        pipe = subprocess.Popen(["perl", os.path.dirname(__file__)+"/create_joined_noise_report.pl", var], stdin=subprocess.PIPE , stdout=FNULL , stderr=FNULL)
        p_status = pipe.wait()
        parse_noise_rpt(globs.US["BLOCKS_LIST"])

    # Min period
    if dbg_min_period:
        sum_min_period(globs.US["BLOCKS_LIST"])

    # Min pulse width
    if dbg_min_pulse_width:
        sum_min_pulse_width(globs.US["BLOCKS_LIST"])

    # Min Cap
    # N/A

    # Min trans
    # N/A
    
    # Xtarp calc

    # Double switching
    if dbg_double_switching:
        sum_double_switching(globs.US["BLOCKS_LIST"])

    # High xtalk
    if dbg_high_xtalk:
        sum_high_xtalk(globs.US["BLOCKS_LIST"])

    # None clock cells
    if dbg_none_clock_cells:
        sum_none_clock_cells(globs.US["BLOCKS_LIST"])

    # implicit_clock_termination
    if dbg_implicit_clock_termination:
        implicit_clock_termination(globs.US["BLOCKS_LIST"])

    # Double Drivers
    if dbg_sum_parallel_drivers:
        sum_parallel_drivers(globs.US["BLOCKS_LIST"])

    # high_cap_clock_drivers
    if dbg_sum_high_cap_clock_drivers:
        sum_high_cap_clock_drivers(globs.US["BLOCKS_LIST"])

    # high_fanout_nets
    if dbg_sum_high_fanout_nets:
        sum_high_fanout_nets(globs.US["BLOCKS_LIST"])



    # Block Shorts.

    # Block physical DRC.
    
    # block PVT

    # Block Gatting.

    # Block power 

    # Print DRC able.
    print('-------------------------------')
    print('Total number of files: '+str(globs.total_files))
    print('')
#if args.print_timing_drc_table or args.print_timing_split_sum_table:
if args.print_timing_drc_table:
    print_drc_table(globs.US["BLOCKS_LIST"])

