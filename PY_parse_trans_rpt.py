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
    

def parse_transition_rpt(blocks):
    var = globs.US["TOP_WORK_AREA"][0]+'/reports/*max_tran_failures.txt'
    lnt = len(glob(var))                                     
    print("Summing max transition reports ("+str(lnt)+" Files) ....")
    globs.total_files +=lnt
    # Init dict pr block
    fout = {}
    # Keep print order in a list
    globs.PARR.append('Transition Internal')
    globs.PARR.append('Transition Interface')
    for block in blocks + ["TOP"]:
        intr = os.getcwd()+"/"+block+".transition_internal.rpt"
        extr = os.getcwd()+"/"+block+".transition_interface.rpt"
        globs.MDB[block]['Transition Internal']  = globs.dict_template(os.getcwd()+"/"+block+".transition_internal.rpt");
        globs.MDB[block]['Transition Interface'] = globs.dict_template(os.getcwd()+"/"+block+".transition_interface.rpt");
        fout[block+'.transition_internal'] = open(intr, "w")
        fout[block+'.transition_interface'] = open(extr, "w")

 
    # Going over trans mrg file.
    fin = open("transition.rpt", "r")
    lines = fin.readlines()
    # reset vars foreach run.
    # print(list(fout.keys()))
    for lline in lines:
        line = str.rstrip(lline)
        if re.search(r"Joined transition report :", line):
            continue
        if re.search(r"Pin   ",                     line):
            continue
        if re.search(r"Slack     Report_File     ", line):
            continue
        if re.match(r'^\s*$', line):
            continue

        sline = line.split()
        block     = "TOP"
        for b in blocks:
            if re.search('^'+b,sline[0]):
                block=b   
        if re.search('/',sline[2]):
            if float(sline[6]) <= globs.MDB[block]['Transition Internal']['wns']:
                globs.MDB[block]['Transition Internal']['wns'] = float(sline[6])
            globs.MDB[block]['Transition Internal']['tns'] += float(sline[6])
            globs.MDB[block]['Transition Internal']['ep'] += 1
            fout[block+'.transition_internal'].write(lline)
            globs.MDB[block]['Transition Internal']['eplist'].append(sline[0])
        else:
            if float(sline[6]) <= globs.MDB[block]['Transition Interface']['wns']:
                globs.MDB[block]['Transition Interface']['wns'] = float(sline[6])
            globs.MDB[block]['Transition Interface']['tns'] += float(sline[6])
            globs.MDB[block]['Transition Interface']['ep'] += 1
            fout[block+'.transition_interface'].write(lline)
            globs.MDB[block]['Transition Interface']['eplist'].append(sline[0])

    # Some float number formating.
    for block in (blocks+['TOP']):
        if isinstance(globs.MDB[block]['Transition Interface']['tns'] , float):
            globs.MDB[block]['Transition Interface']['tns'] = round(globs.MDB[block]['Transition Interface']['tns'],globs.RTNS)
        if isinstance(globs.MDB[block]['Transition Interface']['wns'] , float):
            globs.MDB[block]['Transition Interface']['wns'] = round(globs.MDB[block]['Transition Interface']['wns'],globs.RWNS)
        if isinstance(globs.MDB[block]['Transition Internal']['tns'] , float):
            globs.MDB[block]['Transition Internal']['tns']  = round(globs.MDB[block]['Transition Internal']['tns'],globs.RTNS)
        if isinstance(globs.MDB[block]['Transition Internal']['wns'] , float):
            globs.MDB[block]['Transition Internal']['wns']  = round(globs.MDB[block]['Transition Internal']['wns'],globs.RWNS)
        
        # Close file and stuff.
        fout[block+'.transition_interface'].close()
        fout[block+'.transition_interface'].close()
    #pprint.pprint(globs.MDB)
