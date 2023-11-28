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


def implicit_clock_termination(blocks):
    DB   = {}
    fout = {}
    rpt = globs.US["TOP_WORK_AREA"][0]+'/reports/*implicit_clock_termination.rpt.gz'
    rpt_glob = glob(rpt)
    lnt = len(rpt_glob)
    globs.total_files +=lnt
    print("Summing implicit clock termination ("+str(lnt)+" Files) ....")
    globs.PARR.append('Implicit Clock Termination')
    for block in blocks + ["TOP"]:
        intr = os.getcwd()+"/"+block+".implicit_clock_termination.rpt"
        globs.MDB[block]['Implicit Clock Termination']  = globs.dict_template(os.getcwd()+"/"+block+".implicit_clock_termination.rpt");
        fout[block+'.implicit_clock_termination'] = open(intr, "w")

    for file in rpt_glob:
        mtch=re.search(r"(.*/)(.+?)(_implicit_clock_termination.rpt.gz)", file)
        scenario = mtch.group(2)
        # print(scenario)
        with gzip.open( file ,'r') as fin:
            for lline in fin:
                line = str.rstrip(lline)
                if re.search(r"GOOD:", line):
                    continue
                if re.search(r"TERMINATED :", line):
                    continue
                if re.search(r"^#", line):
                    continue
                if re.search(r"^\s*$", line):
                    continue
                line_array = line.split()
                pin    = line_array[2]
                #req    = line_array[3]
                #act    = line_array[4]
                #slack  = 0 - abs(float(line_array[0]))
                rblock = line_array[2]
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
                    continue
                    #if float(slack) <= DB[pin]['slack']:
                        #DB[pin]['slack']    = slack;   
                        #DB[pin]['scenario'] = scenario;   
                        #DB[pin]['line']     = line;
                        #DB[pin]['block']    = block;
                else:
                    DB[pin] = {
                        'slack':'N/A' ,
                        'scenario':scenario,
                        'line':line,
                        'block':block,   
                    }
        fin.close()

    # Find wns /tns /ep
    for pin in DB:
        block = DB[pin]['block']
        #if float(DB[pin]['slack']) <= globs.MDB[block]['Implicit Clock Termination']['wns']:
        globs.MDB[block]['Implicit Clock Termination']['wns'] = 'N/A'
        globs.MDB[block]['Implicit Clock Termination']['tns'] = 'N/A'
        globs.MDB[block]['Implicit Clock Termination']['ep'] += 1
        fout[block+'.implicit_clock_termination'].write(DB[pin]['line'] +' Scenario = '+DB[pin]['scenario']+'\n')
        globs.MDB[block]['Implicit Clock Termination']['eplist'].append(pin)


    # Some float number formating.
    for block in (blocks+['TOP']):
        if isinstance(globs.MDB[block]['Implicit Clock Termination']['tns'] , float):
            globs.MDB[block]['Implicit Clock Termination']['tns'] = round(globs.MDB[block]['Implicit Clock Termination']['tns'],globs.RTNS)
        if isinstance(globs.MDB[block]['Implicit Clock Termination']['wns'] , float):
            globs.MDB[block]['Implicit Clock Termination']['wns'] = round(globs.MDB[block]['Implicit Clock Termination']['wns'],globs.WNS)
         
        # Close file and stuff.
        fout[block+'.implicit_clock_termination'].close()

