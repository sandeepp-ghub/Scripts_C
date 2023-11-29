# Libraries
import argparse
import sys
import glob
import re
import gzip
import globs
import os
from glob import glob
import pprint
import json

global DB
global Fin
global inv_desin_summary
global fusion_design_summary
global fusion_util_rpt
global fusion_qor_rpt
global fusion_pvt_rpt
global dc_design_summary

parser = argparse.ArgumentParser(description='Print better table of time design summary.',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('Fin' ,default = False , nargs='+',  help='A path to the user run or sta run main work area.')
#-- parse arguments                        --#
args = parser.parse_args()
Fin = args.Fin
DB   = {}



def return_inv_desin_summary ():
    global Fin
    global inv_desin_summary
    #-- Go over timing summary report.
    rpt  = str(Fin[0])+"/*/report/*.summary.gz"
    inv_desin_summary = glob(rpt)

def return_fusion_files ():
    global Fin
    global fusion_desin_summary
    global fusion_util_rpt
    global fusion_qor_rpt
    global fusion_pvt_rpt
    #-- Go over timing summary report.
    if 1 < len(Fin):
        rpt  = str(Fin[1])+"/rpts_fc/compile.report_global_timing"
        utl  = str(Fin[1])+"/rpts_fc/compile.report_utilization"
        qor  = str(Fin[1])+"/rpts_fc/compile.report_qor"
        pvt  = str(Fin[1])+"/rpts_fc/compile.report_pvt"
        fusion_desin_summary = glob(rpt)
        fusion_util_rpt      = glob(utl)
        fusion_qor_rpt       = glob(qor)
        fusion_pvt_rpt       = glob(pvt)
    else:
        print("Info: No input file exists")

def collect_fusion_design_summary ():
    global Fin
    if 1 >= len(Fin):
        return 0
    global fusion_desin_summary 
    global DB
    check   = 'setup'
    session = 'Fusion compile'
    DB[session] =          {}
    DB[session]['setup'] = {}
    DB[session]['hold']  = {}

    for file in fusion_desin_summary:
        #print(file)
        fin = open(file, "r")
        lines = fin.readlines()
        for lline in lines:
            line = str.rstrip(lline)
            #print(line)
            if re.search(r"Total", line):
                groups=line.split()
                for i in range(0,len(groups)):
                    #print(groups[i].strip())
                    DB[session][check][groups[i].strip()] ={}
            if re.search(r"WNS", line):
                WNS=line.split()
                for i in range(0,len(WNS)-1):
                    #print(WNS[i].strip())
                    #print(groups[i].strip())
                    DB[session][check][groups[i].strip()]["WNS"] =  WNS[i+1].strip()
            if re.search(r"TNS", line):
                TNS=line.split()
                for i in range(0,len(TNS)-1):
                    #print(TNS[i].strip())
                    DB[session][check][groups[i].strip()]["TNS"] =  TNS[i+1].strip()
            if re.search(r"NUM", line):
                EP=line.split()
                for i in range(0,len(EP)-1):
                    #print(EP[i].strip())
                    DB[session][check][groups[i].strip()]["EP"] =  EP[i+1].strip()
        for i in range(0,len(groups)):
            #print(AP[i].strip())
            DB[session][check][groups[i].strip()]["AP"] =  'N/A'

def collect_fusion_util_num ():
    global Fin
    if 1 >= len(Fin):
        return 0
    global DB
    global fusion_util_rpt
    session = 'Fusion compile'
    file = fusion_util_rpt[0]
    #print(file)
    fin = open(file, "r")
    lines = fin.readlines()
    for lline in lines:
        line = str.rstrip(lline)
        #print(line)
        if re.search(r"Utilization Ratio", line):
            util_num=line.split()
            DB[session]["DENSITY"] = str(float(util_num[2])*100)+"%"

def collect_inv_design_summary ():
    global inv_desin_summary
    global DB
    for file in inv_desin_summary:
        print(file)
        session_temp=file.split("/")[-1]
        print(session_temp)
        session_list=session_temp.split(".")[1:-2]
        session='.'.join(session_list)
        session=re.sub('_hold_hold', '', session)
        session=re.sub('_hold$', '', session)
   

        print(session)
        
        if session not in DB:
            DB[session]={}
        if 'setup' not in DB[session]:
            #print("AAAAAAAAAAAAAAAAAA"+session+"::setup")
            #print(DB[session]) 
            DB[session]['setup']={}
        if 'hold' not in DB[session]:
            #print("AAAAAAAAAAAAAAAAAA"+session+"::hold")
            #print(DB[session])
            DB[session]['hold']={}
        with gzip.open( file ,'r') as fin:
            for lline in fin:
                #print(lline)
                line = str.rstrip(str(lline.decode("utf-8")))
                #print(line)
                if re.search(r"(Setup|Hold) mode", line):
                    groups=line.split("|")
                    if re.search(r"Setup", groups[1]):
                        check = 'setup'
                    else:
                        check = 'hold'
                    for i in range(2,len(groups)-1):
                        #print(groups[i].strip())
                        DB[session][check][groups[i].strip()] ={}
                if re.search(r"WNS", line):
                    WNS=line.split("|")
                    for i in range(2,len(WNS)-1):
                        #print(WNS[i].strip())
                        DB[session][check][groups[i].strip()]["WNS"] =  WNS[i].strip()
                if re.search(r"TNS", line):
                    TNS=line.split("|")
                    for i in range(2,len(TNS)-1):
                        #print(TNS[i].strip())
                        DB[session][check][groups[i].strip()]["TNS"] =  TNS[i].strip()
                if re.search(r"Violating Paths", line):
                    EP=line.split("|")
                    for i in range(2,len(EP)-1):
                        #print(EP[i].strip())
                        DB[session][check][groups[i].strip()]["EP"] =  EP[i].strip()
                if re.search(r"All Paths", line):
                    AP=line.split("|")
                    for i in range(2,len(AP)-1):
                        #print(AP[i].strip())
                        DB[session][check][groups[i].strip()]["AP"] =  AP[i].strip()
                if re.search(r"Density", line):
                    AP=line.split(":")
                    DB[session]["DENSITY"] =  AP[1].strip()



# Print table to screen.
def print_table ():
    global DB
    c0l = 20
    c1l = 9
    c2l = 9
    c3l = 9
    c4l = 9
    vlp = "+"+"-"*(c0l+2)+"+"+"-"*(c1l+2)+"+"+"-"*(c2l+2)+"+"+"-"*(c3l+2)+"+"+"-"*(c4l+2)+"+"
    vl  = "+"+"-"*(c0l+2)+"-"+"-"*(c1l+2)+"-"+"-"*(c2l+2)+"-"+"-"*(c3l+2)+"-"+"-"*(c4l+2)+"+"
    table_full_width = c0l+c1l+c2l+c3l+c4l+12
    print("")
    print(vl)
    print("| "+"Allerhand\'s Time Design Summary: ".ljust(table_full_width)+" |")
    print(vl)
    for session in DB.keys():
        check = 'setup'
        print("|"+" "+session.ljust(table_full_width)+" |")
        #print("|"+" "+session.ljust(table_full_width-1)+" |")
        print(vlp)
        # Print setup timing.
        if DB[session]['hold'] != {}:
            print("| "+"Setup Timing:".ljust(table_full_width)+" |")
            print(vlp)
        print("| "+"Group".ljust(c0l)+" | "+"WNS".ljust(c1l)+" | "+"TNS".ljust(c2l)+" | "+"EP".ljust(c3l)+" | "+"AP".ljust(c4l)+" |")
        print(vlp)
        for group in DB[session][check].keys():
            if group == "DENSITY":
                continue
            grp = group
            wns = DB[session][check][grp]["WNS"]
            tns = DB[session][check][grp]["TNS"]
            ep  = DB[session][check][grp]["EP"]
            ap  = DB[session][check][grp]["AP"]
            print("| "+grp.ljust(c0l)+" | "+wns.ljust(c1l)+" | "+tns.ljust(c2l)+" | "+ep.ljust(c3l)+" | "+ap.ljust(c4l)+" |")
        print(vlp)
        # Print hold timing
        if DB[session]['hold'] != {}:
            check = 'hold'
            print("| "+"Hold Timing:".ljust(table_full_width)+" |")
            print(vlp)

            print("| "+"Group".ljust(c0l)+" | "+"WNS".ljust(c1l)+" | "+"TNS".ljust(c2l)+" | "+"EP".ljust(c3l)+" | "+"AP".ljust(c4l)+" |")
            print(vlp)
            for group in DB[session][check].keys():
                if group == "DENSITY":
                    continue
                grp = group
                wns = DB[session][check][grp]["WNS"]
                tns = DB[session][check][grp]["TNS"]
                ep  = DB[session][check][grp]["EP"]
                ap  = DB[session][check][grp]["AP"]
                print("| "+grp.ljust(c0l)+" | "+wns.ljust(c1l)+" | "+tns.ljust(c2l)+" | "+ep.ljust(c3l)+" | "+ap.ljust(c4l)+" |")
            print(vlp)




        print("| DENSITY: "+DB[session]["DENSITY"].ljust(table_full_width-9)+" |")
        #print(vl)
        print(vl)
    




return_fusion_files()
collect_fusion_design_summary()
collect_fusion_util_num()
return_inv_desin_summary()
collect_inv_design_summary()
#pprint.pprint(DB) 
print_table()






                #mtch=re.search(r"(M1DP-CMD:::mExecStep:::)([{}\w\d\s\(\)]*)", line)
                #cmd_name = mtch.group(2)





