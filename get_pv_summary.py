#!/proj/eda/UNSUPPORTED/PYTHON/3.6.8/bin/python3.6 -B
# -*- mode: python; indent-tabs-mode: nil; tab-width: 4; -*-
import re, argparse, os, tempfile, gzip, time, shutil, codecs, glob, sys
from os.path import exists
#from os.path import join


def get_drc_data(drc_file):
    print (drc_file)
    lines = []
    drc_results = []
    found = 0
    done = 0

    try:
        with open(drc_file , 'r') as fp:
            lines = fp.readlines()
    except IOError as e:
            print(f'FILE NOT FOUND:{drc_file}')
            exit()

    for line in lines:
        if "RULECHECK RESULTS STATISTICS (BY CELL)" in line:
            found = 1
            drc_results.append(line)
           # print (line)
        elif (("SUMMARY" in line) and (found == 1)):
            done = 1
            return drc_results
        elif ((found == 1) and (done == 0)) :
            if "---" not in line:
                drc_results.append(line)
                #print (line)

def get_erc_data(erc_file):
    print (erc_file)
    lines = []
    erc_results = []
    found = 0
    done = 0

    try:
        with open(erc_file , 'r') as fp:
            lines = fp.readlines()
    except IOError as e:
            print(f'FILE NOT FOUND:{erc_file}')
            exit()

    for line in lines:
        if "ERC RULECHECK RESULTS STATISTICS (BY CELL)" in line:
            found = 1
            erc_results.append(line)
           # print (line)
        elif (("SUMMARY" in line) and (found == 1)):
            done = 1
            return erc_results
        elif ((found == 1) and (done == 0)) :
            if "---" not in line:
                erc_results.append(line)
                #print (line)


def get_lvs_data(lvs_rep):
    print (lvs_rep)
    lines = []
    lvs_results = []
    incorrect_cell_res = []
    found = 0
    done = 0
    lvs_pass = 1
    trace_comp = 0
    overall_comparision = 1
    top_comparision = 0
    dump_top_comp = 0
    cell_summary = 0
    dump_incorrect_cells = 0
    found_incorrect_cell = 0
    new_cell = 0
    try:
        with open(lvs_rep , 'r') as fp:
            lines = fp.readlines()
    except IOError as e:
            print(f'FILE NOT FOUND:{lvs_rep}')
            exit()

    for line in lines:
        if (overall_comparision == 1):
            if "OVERALL COMPARISON RESULTS" in line:
                found = 1
                lvs_results.append(line)
                #print (line)
            elif (("Warning:" in line) and (found == 1)):
                done = 1
                if (lvs_pass == 1):
                    return lvs_results
                else:
                    trace_comp = 1
                    overall_comparision = 0
                    cell_summary = 1
                    #return lvs_results
            elif ((found == 1) and (done == 0)) :
                if "INCORRECT" in line:
                    lvs_pass = 0
                lvs_results.append(line)
                #print (line)
        elif ((lvs_pass == 0) and (trace_comp == 1)):
                #print (line)
                #return lvs_results
                if (cell_summary == 1):
                   if (re.search(r'(CELL  SUMMARY|INCORRECT|Result|\*|\-)' , line)):
                        lvs_results.append(line)
                   elif "LVS PARAMETERS" in line:
                        cell_summary = 0
                        dump_incorrect_cells = 1
                        #top_comparision = 1
                        #return lvs_results
                elif (dump_incorrect_cells == 1):
                    if "CELL COMPARISON RESULTS" in line:
                        if "( TOP LEVEL )" in line:
                            top_comparision = 1
                            dump_incorrect_cells = 0
                            dump_top_comp = 1
                            if (found_incorrect_cell == 1):
                                lvs_results.extend(incorrect_cell_res)
                            lvs_results.append(line)
                        
                        else:
                            if (found_incorrect_cell == 1):
                                lvs_results.extend(incorrect_cell_res)
                            incorrect_cell_res = []
                            incorrect_cell_res.append(line)
                            new_cell = 1
                            found_incorrect_cell = 0
                        
                    elif "INCORRECT" in line:
                        found_incorrect_cell = 1
                        incorrect_cell_res.append(line)
                    elif (new_cell == 1):
                        incorrect_cell_res.append(line)

                elif (top_comparision == 1):
                        if (dump_top_comp == 1):
                            if "INFORMATION AND WARNINGS" in line:
                                dump_top_comp = 0
                                top_comparision = 0
                                return lvs_results
                            else:
                                 lvs_results.append(line)   


    return lvs_results



def main():
    #dir_path = os.path.dirname(os.path.realpath(__file__))
    dir_path = os.getcwd()
    drc_file_name = glob.glob(os.path.join(dir_path  , 'pv.signoff.drc/*/DRC.rep' ))
    ant_file_name = glob.glob(os.path.join(dir_path  , 'pv.signoff.ant/*/DRC.rep' ))
    lvs_file_name = glob.glob(os.path.join(dir_path  , 'pv.signoff.lvsq/*/lvs.rep' ))
    erc_file_name = glob.glob(os.path.join(dir_path  , 'pv.signoff.lvsq/*/ERC.rep' ))
    #print (drc_file_name)
    results = []
       

    
    if drc_file_name:
        results.append("-----------------------------------------------------------------------------DRC SUMMARY-------------------------------------------------------------\n\n")
        results.extend(get_drc_data(drc_file_name[0]))
        
    if ant_file_name:
        results.append("-----------------------------------------------------------------------------ANT SUMMARY-------------------------------------------------------------\n\n")
        results.extend(get_drc_data(ant_file_name[0]))
        
    if lvs_file_name:
        results.append("-----------------------------------------------------------------------------LVS SUMMARY-------------------------------------------------------------\n\n")
        results.extend(get_lvs_data(lvs_file_name[0]))
    
    if erc_file_name:
        results.append("-----------------------------------------------------------------------------ERC SUMMARY-------------------------------------------------------------\n\n")
        results.extend(get_erc_data(erc_file_name[0]))
    
    fp = open('PV_summary.txt','w')

    for line in results:
        fp.write(line)
        print (line,end='')

    fp.close() 
         

if __name__ == '__main__':
    main()


