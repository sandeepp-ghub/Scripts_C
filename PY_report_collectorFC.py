#!/usr/bin/python
# list to string    == str(sys.argv[1:]).strip('[]')
# if string in text == if "bus_compressed" in d:
#    # Get scenario from file name.
#    match = re.search(r"(\w+?)(_failing_paths)", d)
#    sc    = match.group(1)

#
#
#
# Importing the libraries
# import pandas as pd
import numpy  as np
import argparse
import sys
import glob
import re
import gzip

# Set vars:
mydict  = {}
pmydict = {}


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
    match = re.search(r"(\w+?)(_failing_paths)", d)
    sc    = match.group(1)
    # Is this min or max scenario
    if re.search(r"min", d) is not None:
        chk = "min"
    else:
        chk = "max"
    # Some init setting.    
    is_inport  = False
    is_outport = False

    with gzip.open( d ,'r') as fin: 
        # Running line by line to collect data.    
        for line in fin:
            # StratPoint.
            match=re.search(r"(Startpoint: )([\w\[\]]+)([^\s]*)", line)   
            if match is not None:
                # Some p2p init setting.
                is_inport  = False
                is_outport = False
                group      = "None"
                sclock     = "None"
                eclock     = "None"
                sheader    = True ;# to mark if a clock is s/e clock.
                startPoint = str(match.group(2,3)).strip('[]')
                sblock   = str(match.group(2)).strip('[]')
                if match.group(3) is "":
                    is_inport =  True ;# to mark the group of the report.
            # EndPoint.
            match=re.search(r"(Endpoint: )([\w+\[\]]+)([^\s]*)", line)   
            if match is not None:
                sheader    = False ;# to mark if a clock is s/e clock
                endPoint = str(match.group(2,3)).strip('[]')
                eblock   = str(match.group(2)).strip('[]')
                if match.group(3) is "":
                    is_outport = True ;# to mark the group of the report.
            # Clocks stuff.
            match=re.search(r"( clocked by )([\w+\[\]\/\\]+)", line) 
            if match is not None:
                if sheader:
                    sclock = str(match.group(2)).strip('[]')
                else:
                    eclock = str(match.group(2)).strip('[]')

            # Select group
            if is_inport and is_outport:
                group = "IO"
            elif is_inport:
                group = "INPUT"
            elif is_outport:
                group = "OUTPUT"

            # Get slack.
            match=re.search(r"(slack \(VIOLATED\))(\s*)(.*)", line)   
            if match is not None:
                slack = str(match.group(3)).strip('[]')
                # Print debug info
                #XX Filter none dss stuff.
                sblock = sblock.replace("dss0","dss")
                sblock = sblock.replace("dss1","dss")
                sblock = sblock.replace("dss2","dss")
                eblock = eblock.replace("dss0","dss")
                eblock = eblock.replace("dss1","dss")
                eblock = eblock.replace("dss2","dss")
               
                sclock = sclock.replace("dss0","dss")
                sclock = sclock.replace("dss1","dss")
                sclock = sclock.replace("dss2","dss")
                eclock = eclock.replace("dss0","dss")
                eclock = eclock.replace("dss1","dss")
                eclock = eclock.replace("dss2","dss")
##FC                if sblock != "dss" and eblock != "dss":
##FC                    continue
#                print("debug")
#                print(sc)
#                print(chk)
#                print(sblock) 
#                print(sclock)
#                print(eblock)
#                print(eclock)
#                print(slack)
#                print(group)

                wns  = sc+","+sblock+","+eblock+","+sclock+","+eclock+","+"wns"
                tns  = sc+","+sblock+","+eblock+","+sclock+","+eclock+","+"tns"
                nop  = sc+","+sblock+","+eblock+","+sclock+","+eclock+","+"nop"
                twns = chk+sblock+eblock+sclock+eclock+"wns"
                ttns = chk+sblock+eblock+sclock+eclock+"tns"
                tnop = chk+sblock+eblock+sclock+eclock+"nop"
                if wns in mydict:
                    print(mydict[wns],slack)
                    if float(mydict[wns]) > float(slack):
                        mydict[wns] = slack 
                    mydict[tns] = float(mydict[tns])+float(slack)
                    mydict[nop] = int(mydict[nop]) + int(1)
                    print(mydict[wns]) 
                        
                else:
                    mydict[wns] = slack       
                    mydict[tns] = slack       
                    mydict[nop] = 1
                    print(mydict[wns])      

    fin.close() 
    for x in mydict:
        print(x)
        print (mydict[x])
#        match=re.search(r"wns", x)
#        if match is not None:   
#            rx = x.replace("wns","wns")
#            pmydict[rx] = str(mydict[rx])+","+str(mydict[x])

        match=re.search(r"tns", x)
        if match is not None:   
            rx = x.replace("tns","wns")
            pmydict[rx] = str(mydict[rx])+","+str(mydict[x])
    for x in mydict:
        match=re.search(r"nop", x)
        if match is not None:   
            rx = x.replace("nop","wns")
            pmydict[rx] = str(pmydict[rx])+","+str(mydict[x])
    print(pmydict)
    print("\n\n")

fout = open("/user/lioral/report_sum.csv", "w")
for x in pmydict:
    match=re.search(r"wns", x)
    if match is not None:
        rx = x.replace("wns","")
        fout.write(rx+str(pmydict[x]+"\n"))


fout.close()
