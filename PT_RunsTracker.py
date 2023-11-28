# Importing the libraries
import numpy  as np
import argparse
import sys
import glob
import re
import gzip
import os.path
import globs
def PTRunsTracker(src_path):
    # Set vars:
    my_set = [];
    i = 0;
    j = 0;
    # FUNC
    my_set.append('func_max1');
    my_set.append('func_max2');
    my_set.append('func_max3');
    my_set.append('func_max4');
    #my_set.append('func_max9');
    #my_set.append('func_max10');
    #my_set.append('func_max12');
    #my_set.append('func_max13');
    my_set.append('func_max15');
    my_set.append('func_max16');
    my_set.append('func_max17');


    my_set.append('func_min1');
    my_set.append('func_min2');
    my_set.append('func_min3');
    my_set.append('func_min4');
    my_set.append('func_min5');
    my_set.append('func_min6');
    my_set.append('func_min9');
    my_set.append('func_min11');
    #my_set.append('func_min12');
    #my_set.append('func_min13');
    my_set.append('func_min15');
    my_set.append('func_min17');
    
    # SHIFT
    my_set.append('scan_shift_max1');
    my_set.append('scan_shift_max2');
    my_set.append('scan_shift_min1');
    my_set.append('scan_shift_min2');
    #my_set.append('scan_shift_min3');
    #my_set.append('scan_shift_min4');
    my_set.append('scan_shift_min5');
    my_set.append('scan_shift_min6');
    my_set.append('scan_shift_min9');
    my_set.append('scan_shift_min15');
    
    # SCAN ATSPEED
    my_set.append('scan_atspeed_max1');
    my_set.append('scan_atspeed_max2');
    my_set.append('scan_atspeed_max3');
    my_set.append('scan_atspeed_max4');
    my_set.append('scan_atspeed_max15');
    my_set.append('scan_atspeed_max16');
    my_set.append('scan_atspeed_max17');
    my_set.append('scan_atspeed_min1');
    my_set.append('scan_atspeed_min2');
    my_set.append('scan_atspeed_min3');
    my_set.append('scan_atspeed_min4');
    my_set.append('scan_atspeed_min5');
    my_set.append('scan_atspeed_min6');
    my_set.append('scan_atspeed_min9');
    my_set.append('scan_atspeed_min11');
    my_set.append('scan_atspeed_min15');
    my_set.append('scan_atspeed_min17');

    # SCAN STUCKAT
    my_set.append('scan_stuckat_max1');
    my_set.append('scan_stuckat_max2');
    my_set.append('scan_stuckat_max3');
    my_set.append('scan_stuckat_max4');
    my_set.append('scan_stuckat_max15');
    my_set.append('scan_stuckat_max16');
    my_set.append('scan_stuckat_max17');
    my_set.append('scan_stuckat_min1');
    my_set.append('scan_stuckat_min2');
    my_set.append('scan_stuckat_min3');
    my_set.append('scan_stuckat_min4');
    my_set.append('scan_stuckat_min5');
    my_set.append('scan_stuckat_min6');
    my_set.append('scan_stuckat_min9');
    my_set.append('scan_stuckat_min11');

#    # extest
#    my_set.append('scan_atspeed_extest_cmp_max1');
#    my_set.append('scan_atspeed_extest_cmp_max2');
#    my_set.append('scan_atspeed_extest_cmp_max3');
#    my_set.append('scan_atspeed_extest_cmp_max4');
#    #my_set.append('scan_atspeed_extest_cmp_max9');
#    #my_set.append('scan_atspeed_extest_cmp_max10');
#    #my_set.append('scan_atspeed_extest_cmp_max12');
#    #my_set.append('scan_atspeed_extest_cmp_max13');
#    
#    my_set.append('scan_atspeed_extest_cmp_min1');
#    my_set.append('scan_atspeed_extest_cmp_min2');
#    my_set.append('scan_atspeed_extest_cmp_min3');
#    my_set.append('scan_atspeed_extest_cmp_min4');
#    my_set.append('scan_atspeed_extest_cmp_min5');
#    my_set.append('scan_atspeed_extest_cmp_min6');
#    my_set.append('scan_atspeed_extest_cmp_min9');
#    my_set.append('scan_atspeed_extest_cmp_min11');
#    #my_set.append('scan_atspeed_extest_cmp_min12');
#    #my_set.append('scan_atspeed_extest_cmp_min13');
#    my_set.append('scan_atspeed_extest_cmp_min15');
#    
#    
#    my_set.append('scan_atspeed_extest_byp_max1');
#    my_set.append('scan_atspeed_extest_byp_max2');
#    my_set.append('scan_atspeed_extest_byp_max3');
#    my_set.append('scan_atspeed_extest_byp_max4');
#    #my_set.append('scan_atspeed_extest_byp_max9');
#    #my_set.append('scan_atspeed_extest_byp_max10');
#    #my_set.append('scan_atspeed_extest_byp_max12');
#    #my_set.append('scan_atspeed_extest_byp_max13');
#    
#    my_set.append('scan_atspeed_extest_byp_min1');
#    my_set.append('scan_atspeed_extest_byp_min2');
#    my_set.append('scan_atspeed_extest_byp_min3');
#    my_set.append('scan_atspeed_extest_byp_min4');
#    my_set.append('scan_atspeed_extest_byp_min5');
#    my_set.append('scan_atspeed_extest_byp_min6');
#    my_set.append('scan_atspeed_extest_byp_min9');
#    my_set.append('scan_atspeed_extest_byp_min11');
#    #my_set.append('scan_atspeed_extest_byp_min12');
#    #my_set.append('scan_atspeed_extest_byp_min13');
#    my_set.append('scan_atspeed_extest_byp_min15');
#    
#    # intest
#    my_set.append('scan_atspeed_intest_cmp_max1');
#    my_set.append('scan_atspeed_intest_cmp_max2');
#    my_set.append('scan_atspeed_intest_cmp_max3');
#    my_set.append('scan_atspeed_intest_cmp_max4');
#    #my_set.append('scan_atspeed_intest_cmp_max9');
#    #my_set.append('scan_atspeed_intest_cmp_max10');
#    #my_set.append('scan_atspeed_intest_cmp_max12');
#    #my_set.append('scan_atspeed_intest_cmp_max13');
#    
#    my_set.append('scan_atspeed_intest_cmp_min1');
#    my_set.append('scan_atspeed_intest_cmp_min2');
#    my_set.append('scan_atspeed_intest_cmp_min3');
#    my_set.append('scan_atspeed_intest_cmp_min4');
#    my_set.append('scan_atspeed_intest_cmp_min5');
#    my_set.append('scan_atspeed_intest_cmp_min6');
#    my_set.append('scan_atspeed_intest_cmp_min9');
#    my_set.append('scan_atspeed_intest_cmp_min11');
#    #my_set.append('scan_atspeed_intest_cmp_min12');
#    #my_set.append('scan_atspeed_intest_cmp_min13');
#    my_set.append('scan_atspeed_intest_cmp_min15');
#    
#    
#    my_set.append('scan_atspeed_intest_byp_max1');
#    my_set.append('scan_atspeed_intest_byp_max2');
#    my_set.append('scan_atspeed_intest_byp_max3');
#    my_set.append('scan_atspeed_intest_byp_max4');
#    #my_set.append('scan_atspeed_intest_byp_max9');
#    #my_set.append('scan_atspeed_intest_byp_max10');
#    #my_set.append('scan_atspeed_intest_byp_max12');
#    #my_set.append('scan_atspeed_intest_byp_max13');
#    
#    my_set.append('scan_atspeed_intest_byp_min1');
#    my_set.append('scan_atspeed_intest_byp_min2');
#    my_set.append('scan_atspeed_intest_byp_min3');
#    my_set.append('scan_atspeed_intest_byp_min4');
#    my_set.append('scan_atspeed_intest_byp_min5');
#    my_set.append('scan_atspeed_intest_byp_min6');
#    my_set.append('scan_atspeed_intest_byp_min9');
#    my_set.append('scan_atspeed_intest_byp_min11');
#    #my_set.append('scan_atspeed_intest_byp_min12');
#    #my_set.append('scan_atspeed_intest_byp_min13');
#    my_set.append('scan_atspeed_intest_byp_min15');
#    
#    # SCAN STUCKAT
#    # extest
#    my_set.append('scan_stuckat_extest_cmp_max1');
#    my_set.append('scan_stuckat_extest_cmp_max2');
#    my_set.append('scan_stuckat_extest_cmp_max3');
#    my_set.append('scan_stuckat_extest_cmp_max4');
#    #my_set.append('scan_stuckat_extest_cmp_max9');
#    #my_set.append('scan_stuckat_extest_cmp_max10');
#    #my_set.append('scan_stuckat_extest_cmp_max12');
#    #my_set.append('scan_stuckat_extest_cmp_max13');
#    
#    my_set.append('scan_stuckat_extest_cmp_min1');
#    my_set.append('scan_stuckat_extest_cmp_min2');
#    my_set.append('scan_stuckat_extest_cmp_min3');
#    my_set.append('scan_stuckat_extest_cmp_min4');
#    my_set.append('scan_stuckat_extest_cmp_min5');
#    my_set.append('scan_stuckat_extest_cmp_min6');
#    my_set.append('scan_stuckat_extest_cmp_min9');
#    my_set.append('scan_stuckat_extest_cmp_min11');
#    #my_set.append('scan_stuckat_extest_cmp_min12');
#    #my_set.append('scan_stuckat_extest_cmp_min13');
#    my_set.append('scan_stuckat_extest_cmp_min15');
#    
#    
#    my_set.append('scan_stuckat_extest_byp_max1');
#    my_set.append('scan_stuckat_extest_byp_max2');
#    my_set.append('scan_stuckat_extest_byp_max3');
#    my_set.append('scan_stuckat_extest_byp_max4');
#    #my_set.append('scan_stuckat_extest_byp_max9');
#    #my_set.append('scan_stuckat_extest_byp_max10');
#    #my_set.append('scan_stuckat_extest_byp_max12');
#    #my_set.append('scan_stuckat_extest_byp_max13');
#    
#    my_set.append('scan_stuckat_extest_byp_min1');
#    my_set.append('scan_stuckat_extest_byp_min2');
#    my_set.append('scan_stuckat_extest_byp_min3');
#    my_set.append('scan_stuckat_extest_byp_min4');
#    my_set.append('scan_stuckat_extest_byp_min5');
#    my_set.append('scan_stuckat_extest_byp_min6');
#    my_set.append('scan_stuckat_extest_byp_min9');
#    my_set.append('scan_stuckat_extest_byp_min11');
#    #my_set.append('scan_stuckat_extest_byp_min12');
#    #my_set.append('scan_stuckat_extest_byp_min13');
#    my_set.append('scan_stuckat_extest_byp_min15');
#    
#    # intest
#    my_set.append('scan_stuckat_intest_cmp_max1');
#    my_set.append('scan_stuckat_intest_cmp_max2');
#    my_set.append('scan_stuckat_intest_cmp_max3');
#    my_set.append('scan_stuckat_intest_cmp_max4');
#    #my_set.append('scan_stuckat_intest_cmp_max9');
#    #my_set.append('scan_stuckat_intest_cmp_max10');
#    #my_set.append('scan_stuckat_intest_cmp_max12');
#    #my_set.append('scan_stuckat_intest_cmp_max13');
#    
#    my_set.append('scan_stuckat_intest_cmp_min1');
#    my_set.append('scan_stuckat_intest_cmp_min2');
#    my_set.append('scan_stuckat_intest_cmp_min3');
#    my_set.append('scan_stuckat_intest_cmp_min4');
#    my_set.append('scan_stuckat_intest_cmp_min5');
#    my_set.append('scan_stuckat_intest_cmp_min6');
#    my_set.append('scan_stuckat_intest_cmp_min9');
#    my_set.append('scan_stuckat_intest_cmp_min11');
#    #my_set.append('scan_stuckat_intest_cmp_min12');
#    #my_set.append('scan_stuckat_intest_cmp_min13');
#    my_set.append('scan_stuckat_intest_cmp_min15');
#
#
#    my_set.append('scan_stuckat_intest_byp_max1');
#    my_set.append('scan_stuckat_intest_byp_max2');
#    my_set.append('scan_stuckat_intest_byp_max3');
#    my_set.append('scan_stuckat_intest_byp_max4');
#    #my_set.append('scan_stuckat_intest_byp_max9');
#    #my_set.append('scan_stuckat_intest_byp_max10');
#    #my_set.append('scan_stuckat_intest_byp_max12');
#    #my_set.append('scan_stuckat_intest_byp_max13');
#
#    my_set.append('scan_stuckat_intest_byp_min1');
#    my_set.append('scan_stuckat_intest_byp_min2');
#    my_set.append('scan_stuckat_intest_byp_min3');
#    my_set.append('scan_stuckat_intest_byp_min4');
#    my_set.append('scan_stuckat_intest_byp_min5');
#    my_set.append('scan_stuckat_intest_byp_min6');
#    my_set.append('scan_stuckat_intest_byp_min9');
#    my_set.append('scan_stuckat_intest_byp_min11');
#    #my_set.append('scan_stuckat_intest_byp_min12');
#    #my_set.append('scan_stuckat_intest_byp_min13');
#    my_set.append('scan_stuckat_intest_byp_min15');
    for s in my_set:
        myglob = str(src_path) + "/" + str(s) + "/saved_session/ndx";
        if os.path.isfile(myglob):
            # file exists
            print(myglob);
            i +=1;
        else:
            print(s)
        j+=1;
    print("\n=============================\nNumber of Done scenarios: "+str(i)+"/"+str(j)); 
