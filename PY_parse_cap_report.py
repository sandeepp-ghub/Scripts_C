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

#def dict_template ():
#    return {
#                "wns":       0 ,
#                "tns":       0 ,
#                "ep":        0 ,
#                "file_path": "None",
#                "eplist":    []
#           }
    

def parse_capacitance_rpt(blocks):
    var = globs.US["TOP_WORK_AREA"][0]+'/reports/*max_cap_failures.txt'
    lnt = len(glob(var))                                     
    print("Summing max capacitance reports ("+str(lnt)+" Files) ....")
    globs.total_files +=lnt
    # Init dict pr block
    fout = {}
    # Keep print ordr in a list
    globs.PARR.append('Capacitance Internal')
    globs.PARR.append('Capacitance Interface')
    for block in blocks + ["TOP"]:
        intr = os.getcwd()+"/"+block+".capacitance_internal.rpt"
        extr = os.getcwd()+"/"+block+".capacitance_interface.rpt"
        globs.MDB[block]['Capacitance Internal']  = globs.dict_template(os.getcwd()+"/"+block+".capacitance_internal.rpt");
        globs.MDB[block]['Capacitance Interface'] = globs.dict_template(os.getcwd()+"/"+block+".capacitance_interface.rpt");
        fout[block+'.capacitance_internal'] = open(intr, "w")
        fout[block+'.capacitance_interface'] = open(extr, "w")

 
    # Going over trans mrg file.
    fin = open("max_cap.rpt", "r")
    lines = fin.readlines()
    # reset vars foreach run.
    # print(list(fout.keys()))
    for lline in lines:
        line = str.rstrip(lline)
        if re.search(r"Joined max cap report :", line):
            continue
        if re.search(r"Pin   ",                     line):
            continue
        if re.search(r"Slack     Report_File     ", line):
            continue
        if re.search(r"Pin Required Actual Slack Report_File", line):
            continue

        if re.match(r'^\s*$', line):
            continue

        sline = line.split()
        block     = "TOP"
        for b in blocks:
            if re.search('^'+b,sline[0]):
                block=b   
        if re.search('/',sline[0]):
            if float(sline[3]) <= globs.MDB[block]['Capacitance Internal']['wns']:
                globs.MDB[block]['Capacitance Internal']['wns'] = float(sline[3])
            globs.MDB[block]['Capacitance Internal']['tns'] += float(sline[3])
            globs.MDB[block]['Capacitance Internal']['ep'] += 1
            fout[block+'.capacitance_internal'].write(lline)
            globs.MDB[block]['Capacitance Internal']['eplist'].append(sline[0])
        else:
            if float(sline[3]) <= globs.MDB[block]['Capacitance Interface']['wns']:
                globs.MDB[block]['Capacitance Interface']['wns'] = float(sline[3])
            globs.MDB[block]['Capacitance Interface']['tns'] += float(sline[3])
            globs.MDB[block]['Capacitance Interface']['ep'] += 1
            fout[block+'.capacitance_interface'].write(lline)
            globs.MDB[block]['Capacitance Interface']['eplist'].append(sline[0])

    # Some float number formating.
    for block in (blocks+['TOP']):
        if isinstance(globs.MDB[block]['Capacitance Interface']['tns'] , float):
            globs.MDB[block]['Capacitance Interface']['tns'] = round(globs.MDB[block]['Capacitance Interface']['tns'],globs.RTNS)
        if isinstance(globs.MDB[block]['Capacitance Interface']['wns'] , float):
            globs.MDB[block]['Capacitance Interface']['wns'] = round(globs.MDB[block]['Capacitance Interface']['wns'],globs.RWNS)
        if isinstance(globs.MDB[block]['Capacitance Internal']['tns'] , float):
            globs.MDB[block]['Capacitance Internal']['tns']  = round(globs.MDB[block]['Capacitance Internal']['tns'],globs.RTNS)
        if isinstance(globs.MDB[block]['Capacitance Internal']['wns'] , float):
            globs.MDB[block]['Capacitance Internal']['wns']  = round(globs.MDB[block]['Capacitance Internal']['wns'],globs.RWNS)
        
        # Close file and stuff.
        fout[block+'.capacitance_interface'].close()
        fout[block+'.capacitance_internal'].close()

    #pprint.pprint(globs.MDB)
