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



def get_modes_list_from_run_timing_log(blocks):
    file = globs.US["TOP_WORK_AREA"][0]+'/run_timing.log'
    fin = open(file, "r")
    lines = fin.readlines()
    for lline in lines:
        line = str.rstrip(lline)
        if re.search(r"#", line):
            continue
        if re.search(r"--modes", line):
            line_array = line.split(' ')
            modes_str  = line_array[1]
            modes      = modes_str.split(',')
            globs.modes = modes
            #print(globs.modes)
    fin.close()


def collect_timing_split_sum_table(blocks):
    rpt = globs.US["TOP_WORK_AREA"][0]+'/reports/split_rpt/*/hierarchical_full/SUMMARY.gz'
    rpt_glob = glob(rpt)
    lnt = len(rpt_glob)
    globs.total_files +=lnt
    print("Summing split reports ("+str(lnt)+" Files) ....")
    
    #modes  = ['func' , 'scan_shift' , 'scan_atspeed_intest_byp' , 'scan_atspeed_intest_cmp' , 'scan_atspeed_extest_byp' , 'scan_atspeed_extest_cmp' , 'scan_stuckat_intest_byp' , 'scan_stuckat_intest_cmp' , 'scan_stuckat_extest_byp' , 'scan_stuckat_extest_cmp' ]
    #modes  = ['func' , 'scan_shift' , 'scan_atspeed' , 'scan_atspeed_intest' , 'scan_atspeed_intest_byp' , 'scan_atspeed_intest_cmp' , 'scan_atspeed_extest' , 'scan_atspeed_extest_byp' , 'scan_atspeed_extest_cmp' , 'scan_stuckat' , 'scan_stuckat_intest' , 'scan_stuckat_intest_byp' , 'scan_stuckat_intest_cmp' , 'scan_stuckat_extest' , 'scan_stuckat_extest_byp' , 'scan_stuckat_extest_cmp' ]
    checks = ['max' , 'min']
    wheres  = ['Internal' , 'External']
    for chk in checks:
        globs.SPDB[chk] = {}
        for mode in globs.modes:
            globs.SPDB[chk][mode] = {}
            for block in (blocks+['TOP']):
                globs.SPDB[chk][mode][block] = {}
                for where in wheres:
                    globs.SPDB[chk][mode][block][where] = {}
                    #globs.SPDB[chk][mode][block][where]['TOT'] = globs.timing_summary_na_dict_template('N/A')


    for file in rpt_glob:
        #print(file)
        mtch=re.search(r"(\w+?)((_intest_cmp|_intest_byp|_intest|_extest_cmp|_extest_byp|_extest)*)(_)(m[axin]+\d+)(/hierarchical_full/SUMMARY.gz)", file)
        mode  =   mtch.group(1)
        submode = mtch.group(2)
        check =   mtch.group(5)
        delay = re.sub(r'\d+','',    check)
        #print(mode)
        #print(submode)
        #print(check)
        with gzip.open( file ,'r') as fin:
            for lline in fin:
                line = str.rstrip(lline)
                if re.search(r"------------", line):
                    continue
                if re.search(r"BLOCK ", line):
                    continue
                if re.search(r"^#", line):
                    continue
                if re.search(r"^\s*$", line):
                    continue
                line_array = line.split()
                rblock = line_array[0]
                tns    = line_array[1]
                wns    = line_array[2]
                ep     = line_array[3]
 
                # Make sure block is in blocks list.
                block     = "TOP"
                for b in blocks:
                    if re.search('^'+b,rblock):
                        block=b   
            
                if re.search('non_interface',rblock) or re.search('internal',rblock):
                    where = 'Internal'
                else:
                    where = 'External'
                #Ex SPDB['max']['func']['internal']['dmc']['max5']
                globs.SPDB[delay][mode+submode][block][where][check] = globs.timing_summary_na_dict_template('N/A')
                globs.SPDB[delay][mode+submode][block][where][check]['wns']      = wns
                globs.SPDB[delay][mode+submode][block][where][check]['tns']      = tns
                globs.SPDB[delay][mode+submode][block][where][check]['ep']       = ep
                globs.SPDB[delay][mode+submode][block][where][check]['scenario'] = check
                # Get an array of pin -> slack file line
                #if pin in DB:
                #    continue
                #    #if float(slack) <= DB[pin]['slack']:
                #        #DB[pin]['slack']    = slack;   
                #        #DB[pin]['scenario'] = scenario;   
                #        #DB[pin]['line']     = line;
                #        #DB[pin]['block']    = block;
                #else:
                #    DB[pin] = {
                #        'slack':'N/A' ,
                #        'scenario':scenario,
                #        'line':line,
                #        'block':block,   
                #    }
        fin.close()
    #pprint.pprint(globs.SPDB)
    return

def print_timing_split_sum_table(blocks):
    pt0l        = 45
    pt1l        = 10
    pt2l        = 12
    pt3l        = 10
    vlp         = "+"+"-"*(pt0l+2)+"+"+"-"*(pt1l+2)+"+"+"-"*(pt2l++2)+"+"+"-"*(pt3l++2)+"+"
    vl          = "+"+"-"*(pt0l+2)+"-"+"-"*(pt1l+2)+"-"+"-"*(pt2l++2)+"-"+"-"*(pt3l++2)+"+"
    table_full_width = pt0l+pt1l+pt2l+pt3l+15
    #modes  = ['func' , 'scan_shift' , 'scan_atspeed' , 'scan_stuckat' ]
    #modes  = ['func' , 'scan_shift' , 'scan_atspeed_intest_byp' , 'scan_atspeed_intest_cmp' , 'scan_atspeed_extest_byp' , 'scan_atspeed_extest_cmp' , 'scan_stuckat_intest_byp' , 'scan_stuckat_intest_cmp' , 'scan_stuckat_extest_byp' , 'scan_stuckat_extest_cmp' ]    
    delays = ['max' , 'min']
    wheres  = ['Internal' , 'External']
    for delay in delays:
        # max/min
        print(vl)
        print(vl)
        prnt = '| '+delay.upper() + " Summary"
        print(prnt.ljust(pt0l+pt1l+pt2l+pt3l+12)+ '|')
        print(vl)  
        #for block in (blocks+['TOP']):
        for block in (blocks):
            print(vl)
            prnt = '| Block: '+ block + "( " + delay.upper() +" )"
            print(prnt.ljust(pt0l+pt1l+pt2l+pt3l+12)+ '|')
            print(vlp)
            for where in wheres:
            # Internal /External
                for mode in globs.modes:
                # func shift stuckat atspeed ....
                    # Sort to find worst wns
                    checks_2d = [];
                    checks_sorted = [];
                    # set groups order
                    checks = globs.SPDB[delay][mode][block][where].keys()
                    for chk in checks:
                        checks_2d.append([chk , globs.SPDB[delay][mode][block][where][chk]['wns']])
                    checks_2d = sorted(checks_2d, key=lambda x:x[1])
                    for chk in checks_2d:
                        checks_sorted.append(chk[0])
                    print('| '+'Scenario'.ljust(pt0l)+' | '+'WNS'.rjust(pt1l)+' | '+'TNS'.rjust(pt2l)+' | '+'EP'.rjust(pt3l)+' | ')
                    print(vlp)
                    if len(checks_sorted) ==0:
                        prnt = '| HAL-Warning: \"'+delay+'\" \"'+mode+'\" Is empty, reports do not exists.'
                        print(prnt.ljust(pt0l+pt1l+pt2l+pt3l+12)+ '|')

                    for check in reversed(checks_sorted):
                        # max1,2 min1 min2 ... 
                        if re.search(r"TOT", check):
                            continue
                        #Ex SPDB['max']['func']['internal']['dmc']['max5']
                        pt0 = mode+'_'+check+'_'+where
                        pt1 = globs.SPDB[delay][mode][block][where][check]['wns']
                        pt2 = globs.SPDB[delay][mode][block][where][check]['tns']
                        pt3 = globs.SPDB[delay][mode][block][where][check]['ep']
                        print('| '+pt0.ljust(pt0l)+' | '+pt1.rjust(pt1l)+' | '+pt2.rjust(pt2l)+' | '+pt3.rjust(pt3l)+' | ')
                    print(vlp)
            print('')


def add_split_sum_to_drc_table(blocks):
    #modes  = ['func' , 'scan_shift' , 'scan_atspeed' , 'scan_stuckat' ]
    #modes  = ['func' , 'scan_shift' , 'scan_atspeed_intest_byp' , 'scan_atspeed_intest_cmp' , 'scan_atspeed_extest_byp' , 'scan_atspeed_extest_cmp' , 'scan_stuckat_intest_byp' , 'scan_stuckat_intest_cmp' , 'scan_stuckat_extest_byp' , 'scan_stuckat_extest_cmp' ]        
    delays = ['max' , 'min']
    wheres  = ['Internal' , 'External']
    DB   = {}
    for delay in delays:
        # Internal /External
        for where in wheres:
            for mode in globs.modes:
                globs.PARR.append(mode+'_'+delay+'_'+where)
            globs.PARR.append('LINE')
    #globs.PARR.append('LINE')             
    globs.PARR.append('LINE')             
    for block in (blocks+['TOP']):
        DB[block] = {}
        for mode in globs.modes:
            for delay in delays:
            # Internal /External
                for where in wheres:
                    # If empty list, func report do not exists ect.
                    if not globs.SPDB[delay][mode][block][where].keys():
                        DB[block][mode+'_'+delay+'_'+where] = {
                            'wns':'N/A',
                            'scenario':'N/A, Report do not exists.',
                            'tns':'N/A',
                            'ep':'N/A',
                            'block':block
                        } 
                    # If not empty find the worst wns
                    for check in  globs.SPDB[delay][mode][block][where].keys():
                        wns      = globs.SPDB[delay][mode][block][where][check]['wns']
                        tns      = globs.SPDB[delay][mode][block][where][check]['tns']
                        ep       = globs.SPDB[delay][mode][block][where][check]['ep']
                        scenario = check
                        if mode+'_'+delay+'_'+where in DB[block]:
                            if float(wns) < float(DB[block][mode+'_'+delay+'_'+where]['wns']):
                                DB[block][mode+'_'+delay+'_'+where]['wns']      = wns
                                DB[block][mode+'_'+delay+'_'+where]['tns']      = tns
                                DB[block][mode+'_'+delay+'_'+where]['ep']       = ep
                                DB[block][mode+'_'+delay+'_'+where]['scenario'] = scenario 

                        else:
                            DB[block][mode+'_'+delay+'_'+where] = {
                                'wns':wns ,
                                'scenario':scenario,
                                'tns':tns,
                                'ep':ep,
                                'block':block
                            }   
                            
                            
                        

    # Find wns /tns /ep
    for block in (blocks+['TOP']): 
        for line in DB[block]:
            block = DB[block][line]['block']
            globs.MDB[block][line] = globs.dict_template('N/A')        
            globs.MDB[block][line]['wns']       = DB[block][line]['wns']
            globs.MDB[block][line]['tns']       = DB[block][line]['tns']
            globs.MDB[block][line]['ep']        = DB[block][line]['ep']
            globs.MDB[block][line]['file_path'] = DB[block][line]['scenario']

    #pprint.pprint(globs.MDB)
    # Some float number formating.
    #for block in (blocks+['TOP']):
    #    if isinstance(globs.MDB[block][mode+' '+delay+' '+where]['tns'] , float):
    #        globs.MDB[block][mode+' '+delay+' '+where]['tns'] = round(globs.MDB[block][mode+' '+delay+' '+where]['tns'],globs.RTNS)
    #    if isinstance(globs.MDB[block][mode+' '+delay+' '+where]['wns'] , float):
    #        globs.MDB[block][mode+' '+delay+' '+where]['wns'] = round(globs.MDB[block][mode+' '+delay+' '+where]['wns'],globs.WNS)
         

