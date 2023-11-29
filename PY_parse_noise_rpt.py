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
    

def parse_noise_rpt(blocks):
    var = globs.US["TOP_WORK_AREA"][0]+'/reports/*report_noise.rpt.gz'
    lnt = len(glob(var))
    print("Summing noise reports ("+str(lnt)+" Files) ....")
    globs.total_files +=lnt
    # Init dict pr block
    fout = {}
    # Keep print order in a list
    globs.PARR.append('Noise Internal')
    globs.PARR.append('Noise Interface')
    for block in blocks + ["TOP"]:
        intr = os.getcwd()+"/"+block+".noise_internal.rpt"
        extr = os.getcwd()+"/"+block+".noise_interface.rpt"
        globs.MDB[block]['Noise Internal']  = globs.dict_template(os.getcwd()+"/"+block+".noise_internal.rpt");
        globs.MDB[block]['Noise Interface'] = globs.dict_template(os.getcwd()+"/"+block+".noise_interface.rpt");
        fout[block+'.noise_internal'] = open(intr, "w")
        fout[block+'.noise_interface'] = open(extr, "w")

 
    # Going over trans mrg file.
    fin = open("noise.rpt", "r")
    lines = fin.readlines()
    # reset vars foreach run.
    # print(list(fout.keys()))
    for lline in lines:
        line = str.rstrip(lline)
        if re.search(r"joined Noise report", line):
            continue
        if re.search(r"-------------", line):
            continue
        if re.search(r"Pin ",                     line):
            continue
        if re.search(r"Slack     Report_File     ", line):
            continue
        if re.match(r'^\s*$', line):
            continue

        sline = line.split()
        block     = "TOP"
        
        for b in blocks:
            if re.search('^'+b,sline[1]):
                block=b   
        if re.search('/',sline[3]):
            if float(sline[5]) <= globs.MDB[block]['Noise Internal']['wns']:
                globs.MDB[block]['Noise Internal']['wns'] = float(sline[5])
            globs.MDB[block]['Noise Internal']['tns'] += float(sline[5])
            globs.MDB[block]['Noise Internal']['ep'] += 1
            fout[block+'.noise_internal'].write(lline)
            globs.MDB[block]['Noise Internal']['eplist'].append(sline[0])
        else:
            if float(sline[5]) <= globs.MDB[block]['Noise Interface']['wns']:
                globs.MDB[block]['Noise Interface']['wns'] = float(sline[5])
            globs.MDB[block]['Noise Interface']['tns'] += float(sline[5])
            globs.MDB[block]['Noise Interface']['ep'] += 1
            fout[block+'.noise_interface'].write(lline)
            globs.MDB[block]['Noise Interface']['eplist'].append(sline[0])

    # Some float number formating.
    for block in (blocks+['TOP']):
        if isinstance(globs.MDB[block]['Noise Interface']['tns'] , float):
            globs.MDB[block]['Noise Interface']['tns'] = round(globs.MDB[block]['Noise Interface']['tns'],globs.RTNS)
        if isinstance(globs.MDB[block]['Noise Interface']['wns'] , float):
            globs.MDB[block]['Noise Interface']['wns'] = round(globs.MDB[block]['Noise Interface']['wns'],globs.RWNS)
        if isinstance(globs.MDB[block]['Noise Internal']['tns'] , float):
            globs.MDB[block]['Noise Internal']['tns']  = round(globs.MDB[block]['Noise Internal']['tns'],globs.RTNS)
        if isinstance(globs.MDB[block]['Noise Internal']['wns'] , float):
            globs.MDB[block]['Noise Internal']['wns']  = round(globs.MDB[block]['Noise Internal']['wns'],globs.RWNS)
        
        # Close file and stuff.
        fout[block+'.noise_interface'].close()
        fout[block+'.noise_interface'].close()
    #pprint.pprint(globs.MDB)
