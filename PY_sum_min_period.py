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


def sum_min_period(blocks):
    DB   = {}
    fout = {}
    rpt = globs.US["TOP_WORK_AREA"][0]+'/reports/*_period_failures_not_waived.txt'
    rpt_glob = glob(rpt)
    lnt = len(rpt_glob)
    print("Summing min period ("+str(lnt)+" Files) ....")
    globs.total_files +=lnt    
    globs.PARR.append('Min Period')
    for block in blocks + ["TOP"]:
        intr = os.getcwd()+"/"+block+".min_period.rpt"
        globs.MDB[block]['Min Period']  = globs.dict_template(os.getcwd()+"/"+block+".min_period.rpt");
        fout[block+'.min_period'] = open(intr, "w")

    for file in rpt_glob:
        mtch=re.search(r"(.*/)(.+?)(_min_p)", file)
        scenario = mtch.group(2)
        # print(scenario)
        fin = open(file, "r")
        lines = fin.readlines()
        for lline in lines:
            line = str.rstrip(lline)
            if re.search(r"Pin high_low required_min_pulse_width", line):
                continue
            if re.search(r"Pin Clock rise_fall required_min_period", line):
                continue
            if re.search(r"------------------", line):
                continue
            if re.search(r"^\s*$", line):
                continue
            line_array = line.split()
            pin    = line_array[0]
            req    = line_array[3]
            act    = line_array[4]
            slack  = line_array[6]
            rblock = line_array[8].split('=')[1]
            # print(line_array)
            # print(line_array[0])
            # print(line_array[3])
            # print(line_array[4])
            # print(line_array[6])
            # print(line_array[8]).split('=')[1]

            # Make sure block is in blocks list.
            block     = "TOP"
            for b in blocks:
                if re.search(b,rblock):
                    block=b   
            
            # Get an array of pin -> slack file line
            if pin in DB:
                if float(slack) <= DB[pin]['slack']:
                    DB[pin]['slack']    = slack;   
                    DB[pin]['scenario'] = scenario;   
                    DB[pin]['line']     = line;
                    DB[pin]['block']    = block;
            else:
                DB[pin] = {
                    'slack':slack ,
                    'scenario':scenario,
                    'line':line,
                    'block':block,   
                }
        fin.close()

    # Find wns /tns /ep
    for pin in DB:
        block = DB[pin]['block']
        if float(DB[pin]['slack']) <= globs.MDB[block]['Min Period']['wns']:
            globs.MDB[block]['Min Period']['wns'] = float(DB[pin]['slack'])
        globs.MDB[block]['Min Period']['tns'] += float(DB[pin]['slack'])
        globs.MDB[block]['Min Period']['ep'] += 1
        fout[block+'.min_period'].write(DB[pin]['line'] +' Scenario = '+DB[pin]['scenario']+'\n')
        globs.MDB[block]['Min Period']['eplist'].append(pin)


    # Some float number formating.
    for block in (blocks+['TOP']):
        if isinstance(globs.MDB[block]['Min Period']['tns'] , float):
            globs.MDB[block]['Min Period']['tns'] = round(globs.MDB[block]['Min Period']['tns'],globs.RTNS)
        if isinstance(globs.MDB[block]['Min Period']['wns'] , float):
            globs.MDB[block]['Min Period']['wns'] = round(globs.MDB[block]['Min Period']['wns'],globs.RWNS)
         
        # Close file and stuff.
        fout[block+'.min_period'].close()
  
