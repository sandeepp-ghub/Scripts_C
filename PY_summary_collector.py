#!/usr/bin/python
# Importing the libraries
# import pandas as pd
import numpy  as np
import argparse
import sys
import glob
import re
import gzip

scns = []
mydict = {}
# get user args
#glb=sys.argv[1:]
parser = argparse.ArgumentParser(description='Go over reports file and print a Sum table for each scenario.',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('src_path' , nargs='+',  help='A global path to all reports that should be included in summary.')
parser.add_argument('-use_blocks_list', help='Select if to try and find the blocks names by regex the s/e points. Or take block names from a user setting list' , action='store_true')
parser.add_argument('-use_clocks_list', help='Select if to try and find the clocks names by regex the s/e points. Or take block names from a user setting list' , action='store_true')
# parse arguments
args = parser.parse_args()



# get_files to work on.
for d in args.src_path:
    # Skip bus_compressed
    if "bus_compressed" in d:
        continue
    # Get scenario from file name.
    print(d)
    my_file=open(d,"r")
    for line in my_file:
        print(line)
        match = re.search(r"([\w\d_]+?)(\/hierarchical_full\/SUMMARY\.gz\:)([\w\d_\-]+)(\s*)([\d\.\-]*)(\s*)([\d\.\-]*)(\s*)([\d\.\-]*)", line)
        scn    = match.group(1)
        jnk    = match.group(2)
        grp    = match.group(3)
        tns    = match.group(5)
        wns    = match.group(7)
        nop    = match.group(9)
        print (scn)
        print (jnk)
        print (grp)
        print (tns)
        print (wns)
        print (nop)
        
        scns.append(scn) 
        mydict[scn+","+grp+","+"tns"] = tns
        mydict[scn+","+grp+","+"wns"] = wns
        mydict[scn+","+grp+","+"nop"] = nop
    my_file.close()


    my_list = sorted(set(scns))

    print(my_list)
    print(mydict)

    #match = re.search(r"func_max1/hierarchical_full/SUMMARY.gz:dss_2ch-internal             -0.2318   -0.0101     92", d)
    #sc    = match.group(1)

