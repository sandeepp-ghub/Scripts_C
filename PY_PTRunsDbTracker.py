# Importing the libraries
import numpy  as np
import argparse
import sys
import glob
import re
import gzip
import os.path
import globs
def PTRunsDbTracker(src_path):
    myglob = str(src_path) + "/run_timing.log" ;
    if os.path.isfile(myglob):
        # file exists
        f = open(myglob, "r")
        lines = f.readlines()
        for line in lines:
            if re.search(r"DESIGN_INPUT", line):
                lst = str(line).split();
                print('%-25s  %-100s' % (lst[2] , lst[4]))
        f.close()

    else:
        print("Error: No run_timing.log File at this area.")
