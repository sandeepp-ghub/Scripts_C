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

def show_logs():
    # Prime Time run.
    func_run_logs = globs.US["TOP_WORK_AREA"][0]+'/func_m*.log'
    scan_run_logs = globs.US["TOP_WORK_AREA"][0]+'/scan_*_m*.log'
    func_run_logs_glob = glob(func_run_logs)
    scan_run_logs_glob = glob(scan_run_logs)
    logs = []
    logs = func_run_logs_glob + scan_run_logs_glob
    for log in logs:
        print(log)

