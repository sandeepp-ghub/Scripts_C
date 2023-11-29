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
import json

def print_timing_summary(ignore_list , wns_ep):
    # set diffrent lists.
    modes = ["func", "scan_shift", "scan_atspeed" , "scan_stuckat"]
    checks = ["max" , "min"]
    json_file_path = globs.US["TOP_WORK_AREA"][0]+"/print_timing_summary.json"
    if not os.path.exists(json_file_path):
         for mode in modes:
             globs.TDB[mode] = {}
             for check in checks:
                 globs.TDB[mode][check] = {}
                 # globs.TDB[check][mode] = 
                 rpts = globs.US["TOP_WORK_AREA"][0]+'/reports/'+mode+'*_'+check+'*_failing_paths.rpt.gz'    
                 rpts_glob =glob(rpts)
                 # Make sure list not empty.
                 if rpts_glob == []:
                     continue
                 for rpt in rpts_glob:
                     match  = re.search(r"(\w+)(_)(min|max)(\d+)",rpt)
                     corner = match.group(3)+match.group(4)
                     full_mode = match.group(1)+"_"+match.group(3)+match.group(4)
                     corner = full_mode;# Bug fix for atspeed and stuckat take each corner sep.
                     # TDB scan_atspeed max max3 set the max3 only at the first time as max3 at atspeed may be at number of corners byp cmp ect
                     if corner not in globs.TDB[mode][check]:
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
                                         globs.TDB[mode][check][corner][group]['scenario'] = full_mode+'_'+corner
                                 # if not exists
                                 else:                                
                                     globs.TDB[mode][check][corner][group] = globs.timing_summary_dict_template(mode+'_'+corner)
                                     globs.TDB[mode][check][corner][group]['tns'] =      float(slack)
                                     globs.TDB[mode][check][corner][group]['wns'] =      float(slack)
                                     globs.TDB[mode][check][corner][group]['scenario'] = full_mode
                                     globs.TDB[mode][check][corner][group]['ep']       = 1
     
         json.dump(globs.TDB, open(globs.US["TOP_WORK_AREA"][0]+"print_timing_summary.json",'w'))
    else:
    # json file exists.
        globs.TDB = json.load(open(globs.US["TOP_WORK_AREA"][0]+"print_timing_summary.json"))

    #pprint.pprint(globs.TDB)
 
    # get total table out of all scenarios table WNS.
    for mode in modes:
        for check in checks:
            globs.TDB[mode][check]['Total_wns'] = {} ;# set the total dict
            for corner in globs.TDB[mode][check].keys():
                for group in globs.TDB[mode][check][corner].keys():
                    if group in globs.TDB[mode][check]['Total_wns'].keys():
                        wns_ep = 'wns'
                        if wns_ep is 'ep':
                             if globs.TDB[mode][check]['Total_wns'][group]['ep'] < globs.TDB[mode][check][corner][group]['ep']:
                                 globs.TDB[mode][check]['Total_wns'][group]['tns']      =  globs.TDB[mode][check][corner][group]['tns']                                         
                                 globs.TDB[mode][check]['Total_wns'][group]['wns']      =  globs.TDB[mode][check][corner][group]['wns']     
                                 globs.TDB[mode][check]['Total_wns'][group]['scenario'] =  globs.TDB[mode][check][corner][group]['scenario']
                                 globs.TDB[mode][check]['Total_wns'][group]['ep']       =  globs.TDB[mode][check][corner][group]['ep']
                        else:
                             if globs.TDB[mode][check]['Total_wns'][group]['wns'] > globs.TDB[mode][check][corner][group]['wns']:
                                 globs.TDB[mode][check]['Total_wns'][group]['tns']      =  globs.TDB[mode][check][corner][group]['tns']                                         
                                 globs.TDB[mode][check]['Total_wns'][group]['wns']      =  globs.TDB[mode][check][corner][group]['wns']     
                                 globs.TDB[mode][check]['Total_wns'][group]['scenario'] =  globs.TDB[mode][check][corner][group]['scenario']
                                 globs.TDB[mode][check]['Total_wns'][group]['ep']       =  globs.TDB[mode][check][corner][group]['ep']
                    else:
                         globs.TDB[mode][check]['Total_wns'][group] = globs.timing_summary_dict_template(mode)
                         globs.TDB[mode][check]['Total_wns'][group]['tns']      =  globs.TDB[mode][check][corner][group]['tns']                                         
                         globs.TDB[mode][check]['Total_wns'][group]['wns']      =  globs.TDB[mode][check][corner][group]['wns']     
                         globs.TDB[mode][check]['Total_wns'][group]['scenario'] =  globs.TDB[mode][check][corner][group]['scenario']
                         globs.TDB[mode][check]['Total_wns'][group]['ep']       =  globs.TDB[mode][check][corner][group]['ep']
    # set empty group if min or max not exists.
    for mode in modes:
        for check in checks:
            if globs.TDB[mode][check]['Total_wns'] == {}:
                globs.TDB[mode][check]['Total_wns']['N/A'] = globs.timing_summary_dict_template('N/A')                
                globs.TDB[mode][check]['Total_wns']['N/A']['tns']      = 'N/A'                                          
                globs.TDB[mode][check]['Total_wns']['N/A']['wns']      = 'N/A'      
                globs.TDB[mode][check]['Total_wns']['N/A']['scenario'] = 'N/A' 
                globs.TDB[mode][check]['Total_wns']['N/A']['ep']       = 'N/A' 




    # get total table out of all scenarios table EP.
    for mode in modes:
        for check in checks:
            globs.TDB[mode][check]['Total_ep'] = {} ;# set the total dict
            for corner in globs.TDB[mode][check].keys():
                for group in globs.TDB[mode][check][corner].keys():
                    if group in globs.TDB[mode][check]['Total_ep'].keys():
                        wns_ep = 'ep'
                        if wns_ep is 'ep':
                             if globs.TDB[mode][check]['Total_ep'][group]['ep'] < globs.TDB[mode][check][corner][group]['ep']:
                                 globs.TDB[mode][check]['Total_ep'][group]['tns']      =  globs.TDB[mode][check][corner][group]['tns']                                         
                                 globs.TDB[mode][check]['Total_ep'][group]['wns']      =  globs.TDB[mode][check][corner][group]['wns']     
                                 globs.TDB[mode][check]['Total_ep'][group]['scenario'] =  globs.TDB[mode][check][corner][group]['scenario']
                                 globs.TDB[mode][check]['Total_ep'][group]['ep']       =  globs.TDB[mode][check][corner][group]['ep']
                        else:
                             if globs.TDB[mode][check]['Total_ep'][group]['wns'] > globs.TDB[mode][check][corner][group]['wns']:
                                 globs.TDB[mode][check]['Total_ep'][group]['tns']      =  globs.TDB[mode][check][corner][group]['tns']                                         
                                 globs.TDB[mode][check]['Total_ep'][group]['wns']      =  globs.TDB[mode][check][corner][group]['wns']     
                                 globs.TDB[mode][check]['Total_ep'][group]['scenario'] =  globs.TDB[mode][check][corner][group]['scenario']
                                 globs.TDB[mode][check]['Total_ep'][group]['ep']       =  globs.TDB[mode][check][corner][group]['ep']
                    else:
                         globs.TDB[mode][check]['Total_ep'][group] = globs.timing_summary_dict_template(mode)
                         globs.TDB[mode][check]['Total_ep'][group]['tns']      =  globs.TDB[mode][check][corner][group]['tns']                                         
                         globs.TDB[mode][check]['Total_ep'][group]['wns']      =  globs.TDB[mode][check][corner][group]['wns']     
                         globs.TDB[mode][check]['Total_ep'][group]['scenario'] =  globs.TDB[mode][check][corner][group]['scenario']
                         globs.TDB[mode][check]['Total_ep'][group]['ep']       =  globs.TDB[mode][check][corner][group]['ep']
    # set empty group if min or max not exists.
    for mode in modes:
        for check in checks:
            if globs.TDB[mode][check]['Total_ep'] == {}:
                globs.TDB[mode][check]['Total_ep']['N/A'] = globs.timing_summary_dict_template('N/A')                
                globs.TDB[mode][check]['Total_ep']['N/A']['tns']      = 'N/A'                                          
                globs.TDB[mode][check]['Total_ep']['N/A']['wns']      = 'N/A'      
                globs.TDB[mode][check]['Total_ep']['N/A']['scenario'] = 'N/A' 
                globs.TDB[mode][check]['Total_ep']['N/A']['ep']       = 'N/A' 





    # Print a timing summary table.
    # init some vars
    table_full_width = 120
    check_name_width = 35
    ep_width         = 7
    wns_width        = 10
    tns_width        = 11
    rpt_width        = table_full_width - check_name_width -  ep_width - wns_width - tns_width - 16 -12 ;# All the lines

    tbvline           = "+"+"-"*(check_name_width+2)+"-"+"-"*(ep_width+2)+'-'+"-"*(rpt_width+2)+"-"+"-"*(wns_width+2)+"-"+"-"*(tns_width+2)+"-"+"-"*(rpt_width+2)+"+"
    etbvline          = "+"+"="*(check_name_width+2)+"="+"="*(ep_width+2)+'='+"="*(rpt_width+2)+"="+"="*(wns_width+2)+"="+"="*(tns_width+2)+"="+"="*(rpt_width+2)+"+"
    vline             = "+"+"-"*(check_name_width+2)+"+"+"-"*(ep_width+2)+"+"+"-"*(rpt_width+2)+'+'+"-"*(wns_width+2)+"+"+"-"*(tns_width+2)+"+"+"-"*(rpt_width+2)+"+"
    evline            = "+"+"="*(check_name_width+2)+"+"+"="*(ep_width+2)+'+'+"="*(rpt_width+2)+"+"+"="*(wns_width+2)+"+"+"="*(tns_width+2)+"+"+"="*(rpt_width+2)+"+"
    lhline            = "| "
    rhline            = " |"
    mhline            = " | "
    

    print('')
    for check in checks:
        print(etbvline)
        print(tbvline)
        sps = table_full_width - len(lhline+"Check:: "+check+rhline) + rpt_width + 2 -11
        print(lhline+"Check:: "+check.upper()+" "*sps+rhline)
        print(tbvline)
        print(etbvline)
        print('')
        for mode in modes:
            group_2d = [];
            groups_sorted = [];
            i =        0;
            sps = table_full_width - len(lhline+"Mode::  "+mode+rhline) + rpt_width + 2 -11
            print(etbvline)
            print(lhline+"Mode::  "+mode+" "*sps+rhline)
            print(vline)
            print(lhline+'Group name'.ljust(check_name_width)+mhline+'EP'.ljust(ep_width)+mhline+"EP Scenario".ljust(rpt_width)+mhline+'WNS'.ljust(wns_width)+mhline+'TNS'.ljust(tns_width)+mhline+"WNS/TNS Scenario".ljust(rpt_width)+rhline)
            print(evline)

            # set groups order
            groups = globs.TDB[mode][check]['Total_wns'].keys()
            for grp in groups:
                group_2d.append([grp , globs.TDB[mode][check]['Total_wns'][grp]['wns']])
            group_2d = sorted(group_2d, key=lambda x:x[1])
            for grp in group_2d:
                groups_sorted.append(grp[0])

            for group in groups_sorted:
                #if 'INPUT' in group:
                #    continue
                #if 'OUTPUT' in group:
                #    continue
                globs.TDB[mode][check]['Total_wns'][group]
                if len(group) > check_name_width:
                    print(lhline+group)
                    print(lhline+str(' ').ljust(check_name_width)+mhline+str(globs.TDB[mode][check]['Total_ep'][group]['ep']).ljust(ep_width)+mhline+ str(globs.TDB[mode][check]['Total_ep'][group]['scenario']).ljust(rpt_width)+mhline+str(globs.TDB[mode][check]['Total_wns'][group]['wns']).ljust(wns_width)+mhline+str(globs.TDB[mode][check]['Total_wns'][group]['tns']).ljust(tns_width)+mhline+ str(globs.TDB[mode][check]['Total_wns'][group]['scenario']).ljust(rpt_width)+rhline)
                else:
                    print(lhline+str(group).ljust(check_name_width)+mhline+str(globs.TDB[mode][check]['Total_ep'][group]['ep']).ljust(ep_width)+mhline+ str(globs.TDB[mode][check]['Total_ep'][group]['scenario']).ljust(rpt_width)+mhline+str(globs.TDB[mode][check]['Total_wns'][group]['wns']).ljust(wns_width)+mhline+str(globs.TDB[mode][check]['Total_wns'][group]['tns']).ljust(tns_width)+mhline+ str(globs.TDB[mode][check]['Total_wns'][group]['scenario']).ljust(rpt_width)+rhline)                    
                print(vline)
            print("\n")    
