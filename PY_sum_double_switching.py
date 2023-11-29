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


def sum_double_switching(blocks):
    DB   = {}
    fout = {}
    rpt = globs.US["TOP_WORK_AREA"][0]+'/reports/*_report_si_double_switching_clock_network.rpt.gz'
    rpt_glob = glob(rpt)
    lnt = len(rpt_glob)
    globs.total_files +=lnt
    print("Summing double switching ("+str(lnt)+" Files) ....")
    globs.PARR.append('Double Switching')
    for block in blocks + ["TOP"]:
        intr = os.getcwd()+"/"+block+".double_switching.rpt"
        globs.MDB[block]['Double Switching']  = globs.dict_template(os.getcwd()+"/"+block+".double_switching.rpt");
        fout[block+'.double_switching'] = open(intr, "w")

    for file in rpt_glob:
        mtch=re.search(r"(.*/)(.+?)(_report_si_double_switching_clock_network)", file)
        scenario = mtch.group(2)
        # print(scenario)
        with gzip.open( file ,'r') as fin:
             #fin = open(file, "r")
             #lines = fin.readlines()
             for lline in fin:
                 line = str.rstrip(lline)
                 if re.search(r"\*\*\*\*\*", line):
                     continue
                 if re.search(r"-nosplit", line):
                     continue
                 if re.search(r"Report : si_double_switching", line):
                     continue
     
                 if re.search(r"-clock_network", line):
                     continue
                 if re.search(r"Design : ", line):
                     continue
                 if re.search(r"Version:", line):
                     continue
                 if re.search(r"Date   :", line):
                     continue
                 if re.search(r"here are no double switching violations detected", line):
                     continue
                 if re.search(r"^1$", line):
                     continue
                 if re.search(r"^\s*$", line):
                     continue
                 # line_array = line.split()
                 # pin    = line_array[0]
                 # req    = line_array[3]
                 # act    = line_array[4]
                 # slack  = line_array[6]
                 # rblock = line_array[8].split('=')[1]
                 # print(line_array)
                 # print(line_array[0])
                 # print(line_array[3])
                 # print(line_array[4])
                 # print(line_array[6])
                 # print(line_array[8]).split('=')[1]
     
                 # Make sure block is in blocks list.
                 block     = "TOP"
                 for b in blocks:
                     if re.search(b,line):
                         block=b   
                 
                 # Get an array of pin -> slack file line
                 pin = line
                 if pin in DB:
                    continue 
                     #if float(slack) == DB[pin]['slack']:
                     #    DB[pin]['slack']    = 'N/A';   
                     #    DB[pin]['scenario'] = scenario;   
                     #    DB[pin]['line']     = line;
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
        #if float(DB[pin]['slack']) <= globs.MDB[block]['Double Switching']['wns']:
        globs.MDB[block]['Double Switching']['wns'] = 'N/A'
        globs.MDB[block]['Double Switching']['tns'] = 'N/A'
        globs.MDB[block]['Double Switching']['ep'] += 1
        fout[block+'.double_switching'].write(DB[pin]['line'] +' Scenario = '+DB[pin]['scenario']+'\n')
        globs.MDB[block]['Double Switching']['eplist'].append(pin)


    # Some float number formating.
    for block in (blocks+['TOP']):
        if isinstance(globs.MDB[block]['Double Switching']['tns'] , float):
            globs.MDB[block]['Double Switching']['tns'] = round(globs.MDB[block]['Double Switching']['tns'],globs.RTNS)
        if isinstance(globs.MDB[block]['Double Switching']['wns'] , float):
            globs.MDB[block]['Double Switching']['wns'] = round(globs.MDB[block]['Double Switching']['wns'],globs.RWNS)
         
        # Close file and stuff.
        fout[block+'.double_switching'].close()
  

