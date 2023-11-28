def init ():
    global US
    global MDB
    global TDB ;# timing db for report timing sum & report timing.
    global SDB ;# snps check db
    global LDB ;# log prs db
    global BDB ; # block to inst
    global SPDB;# split reports db
    global PARR;
    global USEDLOG;
    global total_files
    global RTNS
    global RWNS
    global modes
    US   =    {}
    MDB  =    {}
    TDB  =    {}
    SDB  =    {}
    LDB  =    {}
    BDB  =    {}
    SPDB =    {}
    PARR =    [] ; # keep the print table order.
    modes =   [] ; # Take the modes array from run timing log 
    USEDLOG = {}
    total_files = 0
    RTNS = 3
    RWNS = 3

def dict_template (file_path):
    return {
                "wns":       0 ,
                "tns":       0 ,
                "ep":        0 ,
                "file_path": file_path,
                "eplist":    []
           }

def timing_summary_dict_template (scenario):
    return {
                "wns":       0 ,
                "tns":       0 ,
                "ep":        0 ,
                "scenario":  scenario,
           }
def timing_summary_na_dict_template (scenario):
    return {
                "wns":       'N/A' ,
                "tns":       'N/A' ,
                "ep":        'N/A' ,
                "scenario":  scenario,
           }


def snps_check_dict_template (test):
    return {
                "req":      'N/A' ,
                "act":      'N/A' ,
                "slack":    'N/A' ,
                "pass":     'N/A' ,
                "pin":      '',
                "name":     test,
           }
def log_dict_template (test , filenm):
    return {
        'Unfiltered Errors'  : 'N/A' ,
        'Total Errors'       : 'N/A' ,
        'Unfiltered Warnings': 'N/A' ,
        'Total Warnings'     : 'N/A' ,
        'Lines Count'        : 0,
        'name'               : test,
        'file'               : filenm,

        } 



