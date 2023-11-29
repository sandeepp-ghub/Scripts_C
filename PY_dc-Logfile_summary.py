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

parser = argparse.ArgumentParser(description='Print dc logfile summary.',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('Fin' ,default = False , nargs='+',  help='A path to the user run or sta run main work area.')
#-- parse arguments                        --#
args = parser.parse_args()
Fin = args.Fin

#print(Fin[0])

SCDB =	{}
new_cmd  = "YES"
fin = open(Fin[0], "r")
lines = fin.readlines()
for lline in lines:
    line = str.rstrip(lline)
    #print (line)

    if re.search(r"STEP-START: ", line):
        mtch=re.search(r"(STEP-START: )([\w\d\s\(\)]*)(|)", line)
        step_name = mtch.group(2)
        print("STEP:: "+step_name)
        new_cmd = "YES"   

    if re.search(r"M1DP-CMD:::mExecStep:::", line):
        mtch=re.search(r"(M1DP-CMD:::mExecStep:::)([{}\w\d\s\(\)]*)", line)
        cmd_name = mtch.group(2)
        if new_cmd != cmd_name:
            print("\tCMD:: "+cmd_name)
            new_cmd = cmd_name;
    if re.search(r"M1DP-CMD:::mRunStep:::mExecStep --- ", line):
        mtch=re.search(r"(M1DP-CMD:::mRunStep:::mExecStep --- )([{}\w\d\s\(\)]*)", line)
        cmd_name = mtch.group(2)
        if new_cmd != cmd_name:
            print("\tCMD:: "+cmd_name)
            new_cmd = cmd_name;

    if re.search(r"ERROR: ", line):
        #mtch=re.search(r"(STEP-START: )([\w\d\s\(\)]*)(|)", line)
        #step_name = mtch.group(2)
        print("ERROR:: "+line)
