### ************************************************************************
### *                                                                      *
### *  MARVELL CONFIDENTIAL AND PROPRIETARY NOTE                           *
### *                                                                      *
### *  This software contains information confidential and proprietary     *
### *  to Marvell, Inc. It shall not be reproduced in whole or in part,    *
### *  or transferred to other documents, or disclosed to third parties,   *
### *  or used for any purpose other than that for which it was obtained,  *
### *  without the prior written consent of Marvell, Inc.                  *
### *                                                                      *
### *  Copyright 2019-2019, Marvell, Inc.  All rights reserved.            *
### *                                                                      *
### ************************************************************************
### * Author      : Lior Allerhand (lioral)
### * Description : 
### ************************************************************************

procedure ::inv::clock::purge_ecf_buffers_before_ccopt  {
    -short_description "purge_ecf_buffers_before_ccopt."
    -description       "purge_ecf_buffers_before_ccopt."
    -example           "::inv::clock::purge_ecf_buffers_before_ccopt"
    -args              {{args -type string -optional -multiple -description "args list"}}
} {

    log -info "::inv::clock::purge_ecf_buffers_before_ccopt - START"
    global mscts_clocks_list;
    if {![info exists ::CDB(mscts_clocks_list)] || $::CDB(mscts_clocks_list) eq ""} {
        log -info "::inv::clock::purge_ecf_buffers_before_ccopt - SKIP"
        return 1
    }
    set_db eco_honor_fixed_status false
    set_db eco_update_timing      false
    set_db eco_refine_place       false
    set_db eco_batch_mode         true

    foreach clk $::CDB(mscts_clocks_list) {
        set tapsZ [get_db [get_db insts ${clk}_MSCTS_TAP*] .pins -if {.direction==out}]
        foreach tapZ [get_db $tapsZ .name] {
            #first remove buffers, in case we have odd number of inverters before it    
            set cells [get_object_name  [get_cells -q [all_fanout -from  $tapZ -only_cells ] -filter "(ref_name =~BUF*||ref_name=~CKB*||ref_name=~DCCKB*)&&(full_name!~*MSCTS_TAP*&&full_name!~*CTS_cfh_buf*&&full_name!~*FHT_*_flex_Htree*)"]]
            if {[llength $cells]} {
                foreach cell $cells {
                    puts "Info purging buffer $cell"
                }
                eco_delete_repeater -insts $cells
            }
#            remove remaining inverters on path ;# NO!!!! some of them are logic for reptr
#            set cells [get_object_name  [get_cells -q [all_fanout -from  $tapZ -only_cells ] -filter "ref_name =~INV*||ref_name=~CKN*||ref_name=~DCCKN*"]]
#            if {[llength $cells]} {
#                foreach cell $cells {
#                    puts "Info purging Inv $cell"
#                }
#                #eco_delete_repeater -insts $cells
#            }
        }        
    }

    set_db eco_batch_mode         false
    set_db eco_honor_fixed_status true
    set_db eco_update_timing      true
    set_db eco_refine_place       true
    log -info "::inv::clock::purge_ecf_buffers_before_ccopt - END"  
}

