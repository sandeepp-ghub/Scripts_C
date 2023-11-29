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

parser = argparse.ArgumentParser(description='Print size cells command from a timing report no split.',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('Fin' ,default = False , nargs='+',  help='A path to the user run or sta run main work area.')
#-- parse arguments                        --#
args = parser.parse_args()
Fin = args.Fin
#print(Fin[0])

SCDB =	{}

fin = open(Fin[0], "r")
lines = fin.readlines()
for lline in lines:
    line = str.rstrip(lline)
    if not re.search(r"BWP", line):
        continue
    line_list = line.split()
    line_list[0] = re.sub("/\w+$",'', line_list[0])
    #print(line_list[0])
    line_list[1] = re.sub("\)",'', line_list[1])
    line_list[1] = re.sub("\(",'', line_list[1])
    #print(line_list[1])
    SCDB[line_list[0]] =  line_list[1]
fin.close()

for cell in  SCDB:
    if re.search(r"ELVT$", SCDB[cell]):
        continue
#    if re.search(r"ULVT$", SCDB[cell]):
#        continue
#    if re.search(r"ULVTLL$", SCDB[cell]):
#        continue

    new_cell  = re.sub('DLVT$','DULVT', SCDB[cell])
    if new_cell is  SCDB[cell]:
        #new_cell  = re.sub('DLVTLL$','DULVT', SCDB[cell])
        new_cell  = re.sub('DLVTLL$','DELVT', SCDB[cell])
    if new_cell is  SCDB[cell]:
        #new_cell  = re.sub('DULVTLL$','DULVT',  SCDB[cell])
        new_cell  = re.sub('DULVTLL$','DELVT',  SCDB[cell])
    if new_cell is  SCDB[cell]:
        #new_cell  = re.sub('DULVTLL$','DULVT',  SCDB[cell])
        new_cell  = re.sub('DULVT$','DELVT',  SCDB[cell])

    print("size_cell "+cell+" "+new_cell)
