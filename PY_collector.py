#!/usr/bin/python
# Importing the libraries
# import pandas as pd
import numpy  as np
import argparse
import sys
import os
import glob
import re
import gzip

scns = []
mydict = {}
# get user args
#glb=sys.argv[1:]
parser = argparse.ArgumentParser(description='Go over reports file and print a Sum table for each scenario.',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('src_path' , nargs='+',  help='A global path to all reports that should be included in summary.')
args = parser.parse_args()
fout = open("/user/lioral/onefile", "w")
print("SRC PATH:"+ str(args.src_path[0]))
for path, subdirs, files in os.walk(str(args.src_path[0])):
    for name in files:
        if '~' not in name:
            print(os.path.join(path, name))
            fout.write("FILESTART:: "+os.path.join(path, name)+"\n")
            fin = open(os.path.join(path, name), "r")
            lines = fin.readlines()
            for lline in lines:
                line = str.rstrip(lline)
                fout.write(line+"\n")
            fout.write("FILEEND:: "+os.path.join(path, name)+"\n")
            fin.close()



fout.close()           
