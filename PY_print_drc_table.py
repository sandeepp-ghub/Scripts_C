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

def print_drc_table(rblocks):
    # init some vars
    table_full_width = 166
    check_name_width = 36
    ep_width         = 7
    wns_width        = 10
    tns_width        = 10
    rpt_width        = table_full_width - check_name_width -  ep_width - wns_width - tns_width - 16 ;# All the lines

    tbvline           = "+"+"-"*(check_name_width+2)+"-"+"-"*(ep_width+2)+"-"+"-"*(wns_width+2)+"-"+"-"*(tns_width+2)+"-"+"-"*(rpt_width+2)+"+"
    vline             = "+"+"-"*(check_name_width+2)+"+"+"-"*(ep_width+2)+"+"+"-"*(wns_width+2)+"+"+"-"*(tns_width+2)+"+"+"-"*(rpt_width+2)+"+"
    lhline            = "| "
    rhline            = " |"
    mhline            = " | "
    # Priniting the table.
    blocks = rblocks+["TOP"]

    for block in blocks:
        print(tbvline)
        sps = table_full_width - len(lhline+"Block:: "+block+rhline)
        print(lhline+"Block:: "+block+" "*sps+rhline)
        print(tbvline)
        print(vline)
        print(lhline+'Check name'.ljust(check_name_width)+mhline+'EP'.ljust(ep_width)+mhline+'WNS'.ljust(wns_width)+mhline+'TNS'.ljust(tns_width)+mhline+"Report path".ljust(rpt_width)+rhline)
        print(vline)
        for key in globs.PARR:
            if key is "LINE":
                print(vline)
            else:
                print(lhline+key.ljust(check_name_width)+mhline+str(globs.MDB[block][key]['ep']).rjust(ep_width)+mhline+str(globs.MDB[block][key]['wns']).rjust(wns_width)+mhline+str(globs.MDB[block][key]['tns']).rjust(tns_width)+mhline+ str(globs.MDB[block][key]['file_path']).ljust(rpt_width)+rhline)                
        print(vline)
        # Sep between blocks
        print("\n"*2)
