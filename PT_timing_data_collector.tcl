#-- remove global dbs from previous runs
    if {[info exists db_in] == 1} {
        unset db_in
    }
    if {[info exists db] == 1} {
        unset db
    }
    if {[info exists db_out] == 1} {
        unset db_out
    }

set db_in(sessions,wc)  /nfs/pt/tmp_dumps/areas/prj_supp_aman_il/lioral/PT_SESSIONS/kw28_alpha_macro_nomdrive/setup/func/slow/wc/
set db_in(sessions,bc)  /nfs/pt/tmp_dumps/areas/prj_supp_aman_il/lioral/PT_SESSIONS/kw28_alpha_macro_overdrive/hold/func/fast_n40_overdrive/bc/Min_Min20/

#-- wc
restore_session $db_in(sessions,wc)
#source -e -v /nfs/pt/store/project_store12/store_kw28/USERS_V/lioral/kw28/default_area_manof/MODELS/Backend/kw28_alpha_macro/sta/r0/work/sw_fix_eco_vt_only_20_11_13_pt.tcl
set paths [get_timing_path -group CORE_CLK -max_path 2000000 -slack_lesser_than 0.0]
set db_out(wc,FAP) [sizeof_collection $paths]
set db_out(wc,WNS) 0
set db_out(wc,WNS) [get_attr [index_collection  $paths 0] slack]
set db_out(wc,TNS) 0
foreach_in_collection path $paths {
    set slack [get_attr $path slack]
    set db_out(wc,TNS) [expr {$db_out(wc,TNS) + $slack }]
}

#-- bc
restore_session $db_in(sessions,bc)
#source -e -v /nfs/pt/store/project_store12/store_kw28/USERS_V/lioral/kw28/default_area_manof/MODELS/Backend/kw28_alpha_macro/sta/r0/work/sw_fix_eco_vt_only_20_11_13_pt.tcl
set paths [get_timing_path -group CORE_CLK -max_path 2000000 -slack_lesser_than 0.0 -delay_type min]
set db_out(bc,FAP) [sizeof_collection $paths]
set db_out(bc,WNS) 0
set db_out(bc,WNS) [get_attr [index_collection  $paths 0] slack]
set db_out(bc,TNS) 0
foreach_in_collection path $paths {
    set slack [get_attr $path slack]
    set db_out(bc,TNS) [expr {$db_out(bc,TNS) + $slack }]
}


#-- print to screen
puts "wc -> FEP $db_out(wc,FAP) , WNS $db_out(wc,WNS) , TNS $db_out(wc,TNS)"
puts "bc -> FEP $db_out(bc,FAP) , WNS $db_out(bc,WNS) , TNS $db_out(bc,TNS)"

exit
