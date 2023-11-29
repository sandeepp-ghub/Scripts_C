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
import textwrap


def print_snps_checkers_rpt_sum():
    snps_checks = globs.US["TOP_WORK_AREA"][0]+'/*_extra_checks.rpt'
    snps_checks_glob = glob(snps_checks)
    for chk in snps_checks_glob:
        mtch=re.search(r"(func_m\w+\d+)", chk)
        op = mtch.group(1)
        globs.SDB[mtch.group(1)] = {
            '1.1.1':globs.snps_check_dict_template(' XXX 1.1.1 Pclk Latency for DBYTE XXX') ,
            '1.1.2':globs.snps_check_dict_template(' XXX 1.1.2 Pclk skew for DBYTE XXX') ,
            '1.2.1':globs.snps_check_dict_template(' XXX 1.2.1 Pclk Latency for ACX4 XXX') ,
            '1.2.2':globs.snps_check_dict_template(' XXX 1.2.2 Pclk skew for ACX4 XXX') ,
            '2.1':globs.snps_check_dict_template(' 2.1 DfiClk Latency to all dbyte and acx4 and master DfiClk pins') ,
            '2.2':globs.snps_check_dict_template(' 2.2 DfiClk skew to all dbyte and acx4 and master DfiClk pins') ,
            '3':globs.snps_check_dict_template(' XXX 3 Port atpg_PllRefClk to master input pin PllRefClk Latency XXX') ,
            '4':globs.snps_check_dict_template(' 4 PllBypClk Latency From port PllBypClk to master input pin PllBypClk ') ,
            '5.1':globs.snps_check_dict_template(' 5.1 latency from port DfiClk to u_DWC_DDRPHYMASTER_top/PllRefClk is sorter then from port DfiClk to All HardIPs DfiClk pin') ,
            '5.2':globs.snps_check_dict_template(' XXX 5.2 latency from port atpg_PllRefClk to u_DWC_DDRPHYMASTER_top/PllRefClk is sorter then from port DfiClk to All HardIPs DfiClk pin XXX')
            }
        test_array = ['1.1.1' ,'1.1.2', '1.2.1' , '1.2.2' , '2.1' ,'2.2' , '3' , '4' , '5.1' , '5.2']
        #globs.SDB[mtch.group(1)] = globs.snps_check_dict_template('aaa')
        print(chk)
        fin = open(chk, "r")
        lines = fin.readlines()
        test = 'NON'
        for lline in lines:
            line = str.rstrip(lline)
            if re.search(r"## 1.1. Pclk Latency and skew for DBYTE", line):
                test = '1.1';
                post = '';
            if re.search(r"## 1.2. Pclk Latency and skew for ACX4", line):
                test = '1.2';
                post = '';
            if re.search(r"## 2. DfiClk Latency and skew", line):
                test = '2';
                post = '';
                
            #XXX Not in Use XXX#if re.search(r"## 3. PllRefClk Latency", line):
            #XXX Not in Use XXX#    test = '3';
            #XXX Not in Use XXX#    post = '';

            if re.search(r"## 4. PllBypClk Latency", line):
                test = '4';
                post = '';
            if re.search(r"## 5. Skew between DfiClk and PllRefClk", line):
                test = '5.1';
                post = '';
            
            #1.1 / 1.2
            # Latency
            mtch = re.search(r"(PClk|DfiClk)( Latency Limit: )([\d\.\-]+)", line)
            if mtch:
                post = '.1'
                globs.SDB[op][test+post]["req"] = mtch.group(3)
            mtch = re.search(r"(latency slack \()(VIOLATED|MET|PASS)(\):\s+)([\d\.\-]+)", line)
            if mtch:
                globs.SDB[op][test+post]["pass"]  = mtch.group(2)
                globs.SDB[op][test+post]["slack"] = mtch.group(4)
                if globs.SDB[op][test+post]["req"] == 'N/A':
                     globs.SDB[op][test+post]["act"] = 'N/A'
                else:
                    globs.SDB[op][test+post]["act"] = float(globs.SDB[op][test+post]["req"]) -  float(globs.SDB[op][test+post]["slack"])

            # Skew
            mtch = re.search(r"(PClk|DfiClk)( Skew Value: )([\d\.\-]+)", line)
            if mtch:
                post = '.2'
                globs.SDB[op][test+post]["act"] = mtch.group(3)
            mtch = re.search(r"(PClk|DfiClk)( Skew Limit: )([\d\.\-]+)", line)
            if mtch:
                globs.SDB[op][test+post]["req"] = mtch.group(3)
            mtch = re.search(r"(skew slack \()(VIOLATED|MET|PASS)(\):\s+)([\d\.\-]+)", line)
            if mtch:
                globs.SDB[op][test+post]["pass"]  = mtch.group(2)
                globs.SDB[op][test+post]["slack"] = mtch.group(4)
          
            # 4      
            mtch = re.search(r"(PllBypClk Master Latency Limit: )([\d\.\-]+)", line)
            if mtch:
                post = ''
                globs.SDB[op][test+post]["req"] = mtch.group(2)

            mtch = re.search(r"(latency slack \()(VIOLATED|MET|PASS)(\):\s+)([\d\.\-]+)", line)
            if mtch:
                globs.SDB[op][test+post]["pass"]  = mtch.group(2)
                globs.SDB[op][test+post]["slack"] = mtch.group(4)


            # 5      
#            mtch = re.search(r"(PllBypClk Master Latency Limit: )([\d\.\-]+)", line)
#            if mtch:
#                post = ''
#                globs.SDB[op][test+post]["req"] = mtch.group(2)

            mtch = re.search(r"(latency slack \()(VIOLATED|MET|PASS)(\):\s+)([\d\.\-]+)", line)
            if mtch:
                globs.SDB[op][test+post]["pass"]  = mtch.group(2)
                globs.SDB[op][test+post]["slack"] = mtch.group(4)

            mtch = re.search(r"(Latency from port DfiClk to u_DWC_DDRPHYMASTER_top/PllRefClk: )([\d\.\-]+)", line)
            if mtch:
                post = ''
                globs.SDB[op][test+post]["act"] = mtch.group(2)
            mtch = re.search(r"(The shortest latency from DfiClk port to All HardIP's DfiClk input pin is : )([\d\.\-]+)", line)
            if mtch:
                globs.SDB[op][test+post]["req"] = mtch.group(2)


    #pprint.pprint(globs.SDB)
    # Print it all.
    # init some vars
    table_full_width = 95
    scenario_width    = 20
    required          = 10
    actual            = 10
    slack_width       = 10
    pass_width        = table_full_width - scenario_width -  required - actual - slack_width - 16 ;# All the lines

    tbvline           = "+"+"-"*(scenario_width+2)+"-"+"-"*(required+2)+"-"+"-"*(actual+2)+"-"+"-"*(slack_width+2)+"-"+"-"*(pass_width+2)+"+"
    vline             = "+"+"-"*(scenario_width+2)+"+"+"-"*(required+2)+"+"+"-"*(actual+2)+"+"+"-"*(slack_width+2)+"+"+"-"*(pass_width+2)+"+"
    lhline            = "| "
    rhline            = " |"
    mhline            = " | "




    for test in test_array:

        # set groups order
        op_2d     = []
        op_sorted = []
        for op in globs.SDB:
            op_2d.append([op , globs.SDB[op][test]['slack']])
        op_2d = sorted(op_2d, key=lambda x:x[1])
        for grp in op_2d:
            op_sorted.append(grp[0])
        op_sorted = reversed(op_sorted)

        # Print Table. 
        print(tbvline)
        # Wrap name.       
        name = textwrap.fill('Test: '+globs.SDB[op][test]['name'], 80).split('\n')
        for n in name:
            print((lhline+str(n).ljust(table_full_width-len(rhline)-2)+rhline)) ;# Take last op to get name it those not mtr.
        print(vline)
        print(lhline+'Scenario'.ljust(scenario_width)+mhline+'Required'.ljust(required)+mhline+'Actual'.ljust(actual)+mhline+'Slack'.ljust(slack_width)+mhline+"PASS".ljust(pass_width)+rhline)
        print(vline)
        for op in op_sorted:
            print(lhline+str(op).ljust(scenario_width)+mhline+str(globs.SDB[op][test]["req"]).ljust(required)+mhline+str(globs.SDB[op][test]["act"]).ljust(actual)+mhline+str(globs.SDB[op][test]["slack"]).ljust(slack_width)+mhline+str(globs.SDB[op][test]["pass"]).ljust(pass_width)+rhline)
        print(vline)
        print('')
## 2. DfiClk Latency and skew

