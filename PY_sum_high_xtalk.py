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


def sum_high_xtalk(blocks):
    DB   = {}
    fout = {}
    rpt = globs.US["TOP_WORK_AREA"][0]+'/reports/quality_reports/*/high_xtalk_nets_checklist_*.rpt'
    rpt_glob = glob(rpt)
    lnt = len(rpt_glob)
    globs.total_files +=lnt
    print("Summing high xtalk ("+str(lnt)+" Files) ....")
    globs.PARR.append('High Xtalk')
    for block in blocks + ["TOP"]:
        intr = os.getcwd()+"/"+block+".high_xtalk.rpt"
        globs.MDB[block]['High Xtalk']  = globs.dict_template(os.getcwd()+"/"+block+".high_xtalk.rpt");
        fout[block+'.high_xtalk'] = open(intr, "w")

    for file in rpt_glob:
        mtch=re.search(r"(.*/high_xtalk_nets_checklist_)(.+?)(\.rpt)", file)
        scenario = mtch.group(2)
        # print(scenario)
        fin = open(file, "r")
        lines = fin.readlines()
        for lline in lines:
            line = str.rstrip(lline)
            if re.search(r"MAX_DELTA", line):
                continue
            if re.search(r"------------------", line):
                continue
            if re.search(r"^\s*$", line):
                continue
            line_array = line.split(',')
            pin    = line_array[1]
            #req    = line_array[3]
            #act    = line_array[4]
            slack  = 0 - abs(float(line_array[0]))
            rblock = line_array[1]
            # print(line_array)
            # print(line_array[0])
            # print(line_array[3])
            # print(line_array[4])
            # print(line_array[6])
            # print(line_array[8]).split('=')[1]

            # Make sure block is in blocks list.
            block     = "TOP"
            for b in blocks:
                if re.search('^'+b,rblock):
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
        if float(DB[pin]['slack']) <= globs.MDB[block]['High Xtalk']['wns']:
            globs.MDB[block]['High Xtalk']['wns'] = float(DB[pin]['slack'])
        globs.MDB[block]['High Xtalk']['tns'] += float(DB[pin]['slack'])
        globs.MDB[block]['High Xtalk']['ep'] += 1
        fout[block+'.high_xtalk'].write(DB[pin]['line'] +' Scenario = '+DB[pin]['scenario']+'\n')
        globs.MDB[block]['High Xtalk']['eplist'].append(pin)


    # Some float number formating.
    for block in (blocks+['TOP']):
        if isinstance(globs.MDB[block]['High Xtalk']['tns'] , float):
            globs.MDB[block]['High Xtalk']['tns'] = round(globs.MDB[block]['High Xtalk']['tns'],globs.RTNS)
        if isinstance(globs.MDB[block]['High Xtalk']['wns'] , float):
            globs.MDB[block]['High Xtalk']['wns'] = round(globs.MDB[block]['High Xtalk']['wns'],globs.RWNS)
         
        # Close file and stuff.
        fout[block+'.high_xtalk'].close()

