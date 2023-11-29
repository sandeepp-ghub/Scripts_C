# Importing the libraries
import numpy  as np
import argparse
import sys
import glob
import re
import gzip
#import os.path
import globs
import os
from glob import glob
import pprint


def print_check_timing_sum(src_path):
    # finding the files to work on.
    MDB = {}
    myglob = str(src_path) +  "/reports/*min1_*check_timing.rpt.NOT_waived_phase2";
    myglob =  glob(myglob)
    # going over the files file by file.
    for file in myglob:
        #print("\n\n\n\n\n\n\n");
        print(file);
        f = open(file, "r")
        lines = f.readlines()
        # Going over the file line by line.
        # reset vars foreach run.
        check = "none";
        unconst_pin    = []; 
        unconst_port   = []; 
        unclocked      = []; 
        for lline in lines:
            line = str.rstrip(lline)
            if re.search(r"Information: Checking", line):
                check = "none";
            if re.search(r"endpoints which are not constrained for maximum delay", line):
                check = "unconst_reg";
                continue
            if re.search(r"register clock pins with no clock.", line):
                check = "unclock_reg";
                continue
            if re.search(r"Endpoint", line):
                continue
            if re.search(r"<<", line):
                continue
            if re.search(r"----------", line):
                continue
            if re.match(r'^\s*$', line):
                continue
            if re.match(r"Clock Pin", line):
                continue

            # If in mode collect lines.
            if check == "unconst_reg":
                sline = re.sub("\d+", "*", line)
                #print(sline)
                if re.search(r"/", sline):
                    unconst_pin.append(sline)
                else:
                    unconst_port.append(sline)
            if check == "unclock_reg":
                sline = re.sub("\d+", "*", line)
                #print(sline)
                unclocked.append(sline)
        
        # back to file level.
        # Get file name. 
        name = re.search(r"(func|scan)(.+?)(max|min)", file)
        fname = name.group(1) + name.group(2)
        fname = fname[:-1]
        #print(fname);

        # uniq lists
        unconst_pin_uniq    = sorted(set(unconst_pin))
        unconst_port_uniq   = sorted(set(unconst_port))
        unclocked_uniq      = sorted(set(unclocked))
        #print("DBG:: " + str(len(unconst_pin_uniq))   + " " + str(len(unconst_pin)))
        #print("DBG:: " + str(len(unconst_port_uniq))   + " " + str(len(unconst_port)))
        #print("DBG:: " + str(len(unclocked_uniq)) + " " + str(len(unclocked_uniq)))

        # Create a dict.
        unconst_pin =	{
            "mode":     fname ,
            "check":    "Clean",
            "ep_list":  unconst_pin_uniq,
            "len_uniq": str(len(unconst_pin_uniq)),
            "len":      str(len(unconst_pin))
        }
        unconst_port =	{
            "mode":     fname ,
            "check":    "Clean",
            "ep_list":  unconst_port_uniq,
            "len_uniq": str(len(unconst_port_uniq)),
            "len":      str(len(unconst_port))
        }
        unclock_pin =	{
            "mode":     fname ,
            "check":    "Clean",
            "ep_list":  unclocked_uniq,
            "len_uniq": str(len(unclocked_uniq)),
            "len":      str(len(unclocked))
        }
        fname_dict = fname; # kill the pointer so next time we will get a new dict pointer.
        fname_dict = {
            "unconstrained pins" : unconst_pin ,
            "unconstrained port" : unconst_port ,
            "unclocked pin" : unclock_pin
        }
        # fname = mode = func /shift / ...
        MDB[fname] = fname_dict
        f.close()
    ##  pprint.pprint(MDB)
    # Print stuff into files.
    for mode in MDB:
        # check = unconstrained pins / unconstrained port / unclocked pin
        for check in MDB[mode]:
            # check list not empty.
            pcheck = re.sub(r' ','_',    check)
            if MDB[mode][check]["ep_list"]:
                f = open(mode+"_"+pcheck+".rpt", "w")
                print(os.getcwd()+"/"+mode+"_"+pcheck+".rpt")
                MDB[mode][check]["check"] = mode+"_"+pcheck+".rpt"
                for i in MDB[mode][check]["ep_list"]:
                    f.write(i+"\n")
                f.close()    
    # Print summary table.
    print("");
    print("+--------------------------------------------------------------------------------------------------------+");
    print("| Check Timing sum Table                                                                                 |");
    print("+--------------------------------------------------------------------------------------------------------+");
    print('')
    for mode in MDB:
        print("+--------------------------------------------------------------------------------------------------------+");
        print("| Mode:: %-42s                                                      |" % mode)
        print("+--------------------------------------------------------------------------------------------------------+");
        print("+----------------------+-------------+--------------+----------------------------------------------------+");
        print("| Test                 | Uniq EP     | Total EP     | File Name                                          |")
        print("+----------------------+-------------+--------------+----------------------------------------------------+");
        for check in MDB[mode]:
            print("| %-20s | %-10s  | %-11s  | %-50s |" % (check , MDB[mode][check]["len_uniq"] , MDB[mode][check]["len"] , MDB[mode][check]["check"]))
        print("+----------------------+-------------+--------------+------------------------------------------------- --+");
        print('');
    
