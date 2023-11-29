array set FTDB {}
array unset FTDB
array set FTDB {}
set outputs [all_outputs]
foreach_in_collection  output $outputs {
    set oname  [get_object_name $output]
    if {[regexp {DDR} $oname]} {continue}
    set inputs [filter_collection [all_fanin -to $output -flat -startpoints_only] "object_class==port"]
    set inputs [filter_collection $inputs "full_name!~*DDR*"]
    #set inputs [filter_collection $inputs "full_name!~*tie*"]
    #set inputs [filter_collection $inputs "full_name!~*top__dss_jtag_bsr_ctl*"]
    if {$inputs ne ""} {
        puts "FDFDFDFD"
        
        set inames [get_object_name $inputs]
        set FTDB($oname) $inames
    }
}
parray FTDB
