#!/usr/bin/env python
"""
get_cap_data.py - print selected index cap data from NLDM tables for specified base cells

Usage:
    ./get_cap_data.py <cell_and_pin_file> [<cap_index>]

Args:
    cell and pin file:  a file containing one or more cell prefix and associated output base_pin
                        Ex.: 
                            BUFFSKR Z
                            INVSKR ZN
                            AN2 Z
                            ND2 ZN
    cap_index:          desired index in cap values for NLDM table (default 3)
                        a more aggressive value (> 3) will result in more aggressive downsizes
                        must be an integer between 0 and 7 inclusive
"""

import re
import os
import gzip
import subprocess
import signal
from sys import argv

# global params
PRECISION = 1
CAP_IDX = 3
ELVT_NLDM = '/proj/cayman/release/IP/tcbn05_bwph210l6p51cnod_base_elvt/120b/synopsys/nldm/tcbn05_bwph210l6p51cnod_base_elvtssgnp_0p675v_0c_cworst_CCworst_T_hm.lib.gz'
ULVT_NLDM = '/proj/cayman/release/IP/tcbn05_bwph210l6p51cnod_base_ulvt/120b/synopsys/nldm/tcbn05_bwph210l6p51cnod_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm.lib.gz'
ULVTLL_NLDM = '/proj/cayman/release/IP/tcbn05_bwph210l6p51cnod_base_ulvtll/120b/synopsys/nldm/tcbn05_bwph210l6p51cnod_base_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_hm.lib.gz'
LVT_NLDM = '/proj/cayman/release/IP/tcbn05_bwph210l6p51cnod_base_lvt/120b/synopsys/nldm/tcbn05_bwph210l6p51cnod_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm.lib.gz'
LVTLL_NLDM = '/proj/cayman/release/IP/tcbn05_bwph210l6p51cnod_base_lvtll/120b/synopsys/nldm/tcbn05_bwph210l6p51cnod_base_lvtllssgnp_0p675v_0c_cworst_CCworst_T_hm.lib.gz'
SVT_NLDM = '/proj/cayman/release/IP/tcbn05_bwph210l6p51cnod_base_svt/120b/synopsys/nldm/tcbn05_bwph210l6p51cnod_base_svtssgnp_0p675v_0c_cworst_CCworst_T_hm.lib.gz'
FORBIDDEN_REGEX = ['^CK.*D1BWP', \
                   '^DCCK.*D1BWP', \
                   # '.*D1BWP', \
                   '^(?!SDFQ).{1,20}D1BWP', \
                   # '^(?!CKAN2|CKMUX2|CKLNQ|SDFQ).{1,20}D2BWP', \
                   # '^(?!CKAN2|CKMUX2|CKLNQ|SDFQ).{1,20}D4BWP', \
                   # '.*D3BWP', \
                   #'^(BUFF|INV)(SK(R|F))?D2BWP', \
                   #'^(BUFF|INV)(SK(R|F))?D3BWP', \
                   #'^(BUFF|INV)(SK(R|F))?D4BWP', \
                   '^OAI211SKRD2BWP210H6P51CNODULVT', \
                   '^OAI211SKRD4BWP210H6P51CNODELVT', \
                   '^OAI211SKRD6BWP210H6P51CNODELVT', \
                   '^OAI211SKRD8BWP210H6P51CNODELVT', \
                   '^OAI221D1BWP210H6P51CNODELVT', \
                   '^CMPE42D(1|2|4)' \
                   ]
TSMC_DISALLOWED_ALTERNATES = {'CKLHQD4': 'CKLHQTWBD4', \
                              'CKLNQD4': 'CKLNQTWCD4', \
                              'CKLNQD8': 'CKLNQTWBD8', \
                              'CKLNQOPTBBD4': 'CKLNQOPTBBTWCD4', \
                              'CKLNQOPTBBD8': 'CKLNQOPTBBTWBD8', \
                              'CKMUX2D4': 'CKMUX2TWBD4', \
                              'CKND18': 'CKNTWCD18', \
                              'CKND2D2': 'CKND2TWCD2', \
                              'CKND2D4': 'CKND2TWCD4', \
                              'CKND2D8': 'CKND2TWBD8', \
                              'CKND2TWAD4': 'CKND2TWCD4', \
                              'CKND2TWAD8': 'CKND2TWBD8', \
                              'CKNR2D2': 'CKNR2TWCD2', \
                              'CKNR2D4': 'CKNR2TWCD4', \
                              'CKNR2D8': 'CKNR2TWCD8', \
                              'CKXOR2D4': 'CKXOR2TWAD4', \
                              'DCCKND18': 'DCCKNTWCD18', \
                              'ND3SKFD3': 'ND3SKFFEMD3', \
                              'ND3SKFD4': 'ND3SKFFEMD4', \
                              'ND3SKFD6': 'ND3SKFFEMD6', \
                              'ND3SKFD8': 'ND3SKFFEMD8', \
                              'NR3SKRD3': 'NR3SKRFEMD3', \
                              'NR3SKRD4': 'NR3SKRFEMD4', \
                              'NR3SKRD6': 'NR3SKRFEMD6', \
                              'NR3SKRD8': 'NR3SKRFEMD8', \
                              'SDFQOPTBCD1': 'SDFQOPTBCED1', \
                              'SDFQOPTBCD2': 'SDFQOPTBCED2', \
                              'SDFQOPTBCD4': 'SDFQOPTBCED4', \
                              'SDFRPQOPTBCD1': 'SDFRPQOPTBCED1', \
                              'SDFRPQOPTBCD2': 'SDFRPQOPTBCED2', \
                              'SDFRPQOPTBCD4': 'SDFRPQOPTBCED4', \
                              'SDFSNQOPTBCD1': 'SDFSNQOPTBCED1', \
                              'SDFSNQOPTBCD2': 'SDFSNQOPTBCED2', \
                              'SDFSNQOPTBCD4': 'SDFSNQOPTBCED4', \
                              'SDFSRPQOPTBCD1': 'SDFSRPQOPTBCED1', \
                              'SDFSRPQOPTBCD2': 'SDFSRPQOPTBCED2', \
                              'SDFSRPQOPTBCD4': 'SDFSRPQOPTBCED4', \
                              }


def print_usage():
    s4 = ' ' * 4
    s24 = ' ' * 24
    s28 = ' ' * 28
    print('Usage:\n%s./get_cap_data.py <cell_and_pin_file> [<cap_index>]' % s4)
    print('Args:\n%scell and pin file:  a file containing one or more cell prefix and associated output base_pin' % s4)
    print('%sEx:\n%sBUFFSKR Z\n%sINVSKR ZN\n%sAN2 Z\n%sND2 ZN\n' % (s24, s28, s28, s28, s28))
    print('%scap_index:          desired index in cap values for NLDM table (default 4)' % s4)
    print('%sa more aggressive value (> 4) will result in more aggressive downsizes' % s24)
    print('%smust be an integer between 0 and 7 inclusive\n' % s24)


def atoi(text):
    return int(text) if text.isdigit() else text


def natural_keys(text):
    return [atoi(c) for c in re.split('(\d+)', text)]


def get_cap_data(cell, pin, cap_idx):

    # with gzip.open(ELVT_NLDM, 'rb') as f:
        # elvt_nldm_list = [line.strip() for line in f.readlines()]
    # with gzip.open(ULVT_NLDM, 'rb') as f:
        # ulvt_nldm_list = [line.strip() for line in f.readlines()]
    # with gzip.open(ULVTLL_NLDM, 'rb') as f:
        # ulvtll_nldm_list = [line.strip() for line in f.readlines()]
    # with gzip.open(LVT_NLDM, 'rb') as f:
        # lvt_nldm_list = [line.strip() for line in f.readlines()]
    # with gzip.open(LVTLL_NLDM, 'rb') as f:
        # lvtll_nldm_list = [line.strip() for line in f.readlines()]
    # with gzip.open(SVT_NLDM, 'rb') as f:
        # svt_nldm_list = [line.strip() for line in f.readlines()]

    # subprocess zgrep to get subset of lines, gzip.open() and iteration too slow
    grep_cmd = 'zgrep -E "(cell \(%s.*D[0-9]{1,2}BWP210H6P51CNODELVT|pin\(%s\)|cell_rise|index_2)" %s' % (cell, pin, ELVT_NLDM)
    elvt_output = subprocess.check_output(grep_cmd, shell=True, stderr=subprocess.STDOUT).decode('utf-8').splitlines()
    grep_cmd = 'zgrep -E "(cell \(%s.*D[0-9]{1,2}BWP210H6P51CNODULVT|pin\(%s\)|cell_rise|index_2)" %s' % (cell, pin, ULVT_NLDM)
    ulvt_output = subprocess.check_output(grep_cmd, shell=True, stderr=subprocess.STDOUT).decode('utf-8').splitlines()
    grep_cmd = 'zgrep -E "(cell \(%s.*D[0-9]{1,2}BWP210H6P51CNODULVTLL|pin\(%s\)|cell_rise|index_2)" %s' % (cell, pin, ULVTLL_NLDM)
    ulvtll_output = subprocess.check_output(grep_cmd, shell=True, stderr=subprocess.STDOUT).decode('utf-8').splitlines()
    grep_cmd = 'zgrep -E "(cell \(%s.*D[0-9]{1,2}BWP210H6P51CNODLVT|pin\(%s\)|cell_rise|index_2)" %s' % (cell, pin, LVT_NLDM)
    lvt_output = subprocess.check_output(grep_cmd, shell=True, stderr=subprocess.STDOUT).decode('utf-8').splitlines()
    grep_cmd = 'zgrep -E "(cell \(%s.*D[0-9]{1,2}BWP210H6P51CNODLVTLL|pin\(%s\)|cell_rise|index_2)" %s' % (cell, pin, LVTLL_NLDM)
    lvtll_output = subprocess.check_output(grep_cmd, shell=True, stderr=subprocess.STDOUT).decode('utf-8').splitlines()
    grep_cmd = 'zgrep -E "(cell \(%s.*D[0-9]{1,2}BWP210H6P51CNODSVT|pin\(%s\)|cell_rise|index_2)" %s' % (cell, pin, SVT_NLDM)
    svt_output = subprocess.check_output(grep_cmd, shell=True, stderr=subprocess.STDOUT).decode('utf-8').splitlines()

    # ULVT only for CK* cells, otherwise all VTs
    # if re.search('^CK', cell):
    if re.search('^(DC)?CK', cell):
        all_grep_outputs = [ulvt_output]
    else:
        all_grep_outputs = [elvt_output, ulvt_output, ulvtll_output, lvt_output, lvtll_output, svt_output]
    all_strings = []

    # print dict for each VT
    for grep_output in all_grep_outputs:

        # get all cell matches
        cell_list = []
        for line in grep_output:
            pattern = '^cell \(%sD[0-9]{1,2}BWP' % cell
            if re.search(pattern, line):
                cell_name = re.search('\((.*)\)', line).group(1)
                cell_list.append(cell_name)

        # natural-sort list and remove FORBIDDEN_REGEX matches
        cell_list.sort(key=natural_keys)
        for c in cell_list.copy():
            for r in FORBIDDEN_REGEX:
                if re.search(r, c) and c in cell_list:
                    cell_list.remove(c)

        # replace TSMC forbidden cells with alternate
        for c in range(0, len(cell_list)):
            for t in TSMC_DISALLOWED_ALTERNATES.keys():
                pattern = '^%sBWP' % t
                if re.search(pattern, cell_list[c]):
                    cell_list[c] = cell_list[c].replace(t, TSMC_DISALLOWED_ALTERNATES[t])

        cell_dict = {key: None for key in cell_list}

        # find cap index corresponding to pin for each cell in cell_dict
        for c in cell_dict.keys():
            found_cell = found_pin = found_rise = False
            for line in grep_output:
                if not found_cell and not found_pin and not found_rise:
                    if re.search(c, line):
                        found_cell = True
                    continue
                elif found_cell and not found_pin and not found_rise:
                    if re.search('pin\(%s\)' % pin, line):
                        found_pin = True
                    continue
                elif found_cell and found_pin and not found_rise:
                    if re.search('cell_rise', line):
                        found_rise = True
                    continue
                elif found_cell and found_pin and found_rise:
                    if re.search('index_2', line):
                        cell_dict[c] = line
                        break
                else:
                    print('DEBUG: unexpected case')
                    exit()
                    
        # generate output
        if len(cell_dict) > 0:
            vt = re.search('CNOD([A-Z]{1,2}VT(LL)?)', list(cell_dict.keys())[0]).group(1)
            cap_dict_str = 'set ::%s%s [dict create \\\n' % (cell.lower(), vt)
            cap_low = 0.0
            for key, value in cell_dict.items():
                cap_high = round(float(value.split()[cap_idx + 1].rstrip(',')) * 1000, PRECISION)
                s = '  %s [list %s %s] \\\n' % (key, cap_low, cap_high)
                cap_dict_str += s
                cap_low = cap_high
            cap_dict_str += ']\n'
            all_strings.append(cap_dict_str)

    return all_strings


def main():

    # check for correct number of args
    if len(argv) < 2 or len(argv) > 3:
        print('ERROR: incorrect number of arguments provided')
        print_usage()
        exit()

    # handle cap_idx arg
    if len(argv) == 3:
        try:
            cap_idx = int(argv[2])
        except ValueError as e:
            print('ERROR: cap_index argument must be an integer\n')
            exit()
    else:
        cap_idx = CAP_IDX

    # Process cell_and_pin_file
    f_name = argv[1]
    if '.gz' in f_name:
        try:
            f = gzip.open(f_name, 'r')
        except IOError as e:
            print('FILE NOT FOUND: %s' % f_name)
            exit()
    else:
        try:
            f = open(f_name, 'r')
        except IOError as e:
            print('FILE NOT FOUND: %s' % f_name)
            exit()

    # store cell_and_pin_file as list
    f_list = [line.strip() for line in f.readlines()]

    # close file
    f.close()

    # generate cap tables for each cell/pin pair
    supported_cells = []
    for line in f_list:
        if re.search('^\s*#|^\s*$', line):
            continue
        try:
            cell, pin = line.split()
        except ValueError as e:
            print('ERROR: cell_and_pin_file must contain only cell prefix and pin pairs')
            print_usage()
            exit()
        all_strings = get_cap_data(cell, pin, cap_idx)
        supported_cells.append(cell)
        for s in all_strings:
            print(s)

    # print list of all supported cell prefixes
    print('set ::supported_fams [list \\')
    for c in supported_cells:
        print('  %s \\' % c)
    print(']\n')


# run main function
if __name__ == '__main__':
    main()
