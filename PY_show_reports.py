# Libraries
import numpy  as np
import argparse
import sys
import glob
import re
import gzip
import globs
import os
from glob import glob
import pprint
import shlex
import csv

def show_reports():
    # Prime Time run.
    func_run_rpts = globs.US["TOP_WORK_AREA"][0]+'/reports/func_m*failing_paths.rpt.gz'
    scan_run_rpts = globs.US["TOP_WORK_AREA"][0]+'/reports/scan_*_m*failing_paths.rpt.gz'
    func_run_rpts_glob = glob(func_run_rpts)
    scan_run_rpts_glob = glob(scan_run_rpts)
    rpts = []
    rpts = func_run_rpts_glob + scan_run_rpts_glob
    for rpt in rpts:
        print(rpt)

