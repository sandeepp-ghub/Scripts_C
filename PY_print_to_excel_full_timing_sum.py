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


def print_to_excel_full_timing_summary(ignore_list):
    # set diffrent lists.
    modes = ["func", "scan_shift", "scan_atspeed" , "scan_stuckat"]
    checks = ["max" , "min"]

    for mode in modes:
        globs.TDB[mode] = {}
        for check in checks:
            globs.TDB[mode][check] = {}
            # globs.TDB[check][mode] = 
            rpts = globs.US["TOP_WORK_AREA"][0]+'reports/'+mode+'_'+check+'*_failing_paths.rpt.gz'    
            rpts_glob =glob(rpts)
            # Make sure list not empty.
            if rpts_glob == []:
                continue
            for rpt in rpts_glob:
                match  = re.search(r"(_)(min|max)(\d+)",rpt)
                corner = match.group(2)+match.group(3)
                #globs.TDB[mode][check][corner]['group'] = globs.timing_summary_dict_template(mode+'_'+corner)
                globs.TDB[mode][check][corner] = {}
                with gzip.open( rpt ,'r') as fin:
                    print(rpt)
                    # Running line by line to collect data.    
                    for line in fin:

                        # Get path group name.
                        match=re.search(r"(Path Group:)(\s*)(.*)", line)   
                        if match is not None:
                            group = str(match.group(3)).strip('[]')

                        # Get slack.
                        match=re.search(r"(slack \(VIOLATED\))(\s*)(.*)", line)   
                        if match is not None:
                            slack = str(match.group(3)).strip('[]')
                            # if exists
                            if group in globs.TDB[mode][check][corner].keys():
                                globs.TDB[mode][check][corner][group]['tns'] = globs.TDB[mode][check][corner][group]['tns'] + float(slack)
                                globs.TDB[mode][check][corner][group]['ep']      += 1
                                if float(slack) < globs.TDB[mode][check][corner][group]['wns']:
                                    globs.TDB[mode][check][corner][group]['wns']      = float(slack)
                                    globs.TDB[mode][check][corner][group]['scenario'] = mode+'_'+corner
                            # if not exists
                            else:                                
                                globs.TDB[mode][check][corner][group] = globs.timing_summary_dict_template(mode+'_'+corner)
                                globs.TDB[mode][check][corner][group]['tns'] =      float(slack)
                                globs.TDB[mode][check][corner][group]['wns'] =      float(slack)
                                globs.TDB[mode][check][corner][group]['scenario'] = mode+'_'+corner
                                globs.TDB[mode][check][corner][group]['ep']       = 1

#    pprint.pprint(globs.TDB)     
    # get total table out of all scenarios table.
    for mode in modes:
        for check in checks:
            globs.TDB[mode][check]['Total'] = {} ;# set the total dict
            for corner in globs.TDB[mode][check].keys():
                for group in globs.TDB[mode][check][corner].keys():
                    if group in globs.TDB[mode][check]['Total'].keys():
                        if globs.TDB[mode][check]['Total'][group]['wns'] > globs.TDB[mode][check][corner][group]['wns']:
                            globs.TDB[mode][check]['Total'][group]['tns']      =  globs.TDB[mode][check][corner][group]['tns']                                         
                            globs.TDB[mode][check]['Total'][group]['wns']      =  globs.TDB[mode][check][corner][group]['wns']     
                            globs.TDB[mode][check]['Total'][group]['scenario'] =  globs.TDB[mode][check][corner][group]['scenario']
                            globs.TDB[mode][check]['Total'][group]['ep']       =  globs.TDB[mode][check][corner][group]['ep']
                    else:
                         globs.TDB[mode][check]['Total'][group] = globs.timing_summary_dict_template(mode)
                         globs.TDB[mode][check]['Total'][group]['tns']      =  globs.TDB[mode][check][corner][group]['tns']                                         
                         globs.TDB[mode][check]['Total'][group]['wns']      =  globs.TDB[mode][check][corner][group]['wns']     
                         globs.TDB[mode][check]['Total'][group]['scenario'] =  globs.TDB[mode][check][corner][group]['scenario']
                         globs.TDB[mode][check]['Total'][group]['ep']       =  globs.TDB[mode][check][corner][group]['ep']
    # set empty group if min or max not exists.
    for mode in modes:
        for check in checks:
            if globs.TDB[mode][check]['Total'] == {}:
                globs.TDB[mode][check]['Total']['N/A'] = globs.timing_summary_dict_template('N/A')                
                globs.TDB[mode][check]['Total']['N/A']['tns']      = 'N/A'                                          
                globs.TDB[mode][check]['Total']['N/A']['wns']      = 'N/A'      
                globs.TDB[mode][check]['Total']['N/A']['scenario'] = 'N/A' 
                globs.TDB[mode][check]['Total']['N/A']['ep']       = 'N/A' 
                             
    # Print a timing summary table.
    # init some vars
    table_full_width = 120
    check_name_width = 35
    ep_width         = 7
    wns_width        = 10
    tns_width        = 10
    rpt_width        = table_full_width - check_name_width -  ep_width - wns_width - tns_width - 16 ;# All the lines

    tbvline           = "+"+"-"*(check_name_width+2)+"-"+"-"*(ep_width+2)+"-"+"-"*(wns_width+2)+"-"+"-"*(tns_width+2)+"-"+"-"*(rpt_width+2)+"+"
    etbvline          = "+"+"="*(check_name_width+2)+"="+"="*(ep_width+2)+"="+"="*(wns_width+2)+"="+"="*(tns_width+2)+"="+"="*(rpt_width+2)+"+"
    vline             = "+"+"-"*(check_name_width+2)+"+"+"-"*(ep_width+2)+"+"+"-"*(wns_width+2)+"+"+"-"*(tns_width+2)+"+"+"-"*(rpt_width+2)+"+"
    evline             = "+"+"="*(check_name_width+2)+"+"+"="*(ep_width+2)+"+"+"="*(wns_width+2)+"+"+"="*(tns_width+2)+"+"+"="*(rpt_width+2)+"+"
    lhline            = "| "
    rhline            = " |"
    mhline            = " | "
    

    print('')
    for check in checks:
        print(etbvline)
        print(tbvline)
        sps = table_full_width - len(lhline+"Check:: "+check+rhline)
        print(lhline+"Check:: "+check+" "*sps+rhline)
        print(tbvline)
        print(etbvline)
        print('')
        for mode in modes:
            group_2d = [];
            groups_sorted = [];
            i =        0;
            sps = table_full_width - len(lhline+"Mode::  "+mode+rhline)
            print(etbvline)
            print(lhline+"Mode::  "+mode+" "*sps+rhline)
            print(vline)
            print(lhline+'Group name'.ljust(check_name_width)+mhline+'EP'.ljust(ep_width)+mhline+'WNS'.ljust(wns_width)+mhline+'TNS'.ljust(tns_width)+mhline+"Scenario".ljust(rpt_width)+rhline)
            print(evline)

            # set groups order
            groups = globs.TDB[mode][check]['Total'].keys()
            for grp in groups:
                group_2d.append([grp , globs.TDB[mode][check]['Total'][grp]['wns']])
            group_2d = sorted(group_2d, key=lambda x:x[1])
            for grp in group_2d:
                groups_sorted.append(grp[0])

            for group in groups_sorted:
                globs.TDB[mode][check]['Total'][group]
                print(lhline+str(group).ljust(check_name_width)+mhline+str(globs.TDB[mode][check]['Total'][group]['ep']).ljust(ep_width)+mhline+str(globs.TDB[mode][check]['Total'][group]['wns']).ljust(wns_width)+mhline+str(globs.TDB[mode][check]['Total'][group]['tns']).ljust(tns_width)+mhline+ str(globs.TDB[mode][check]['Total'][group]['scenario']).ljust(rpt_width)+rhline)
                print(vline)
            print("\n")    
