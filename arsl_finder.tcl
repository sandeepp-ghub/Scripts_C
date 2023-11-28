return
# For endpoint still collect anntenna cells,removed by text edith. 
set fp [ open rsl_max_delays.tcl w ]
set coll0 [  get_cells -hier  -filter "full_name =~ *arsl*mpbuf*&&is_hierarchical==false" ]
set coll1 [  filter_collection ${coll0}   "full_name !~ *TIE*" ]
foreach_in_collection  i $coll1 {
    set name [get_object_name $i]
    puts $name
    set endc [ all_fanout -from ${name}/Z -endpoint -flat -trace_arcs all]
    set cp [ get_pins -of_objects [get_cells -of_objects $endc ] -filter "is_clock_pin == true" ]
    if {$cp eq ""} {continue}
    set period [ get_attr [ get_attr $cp clocks ] period ]
    set mdelay [ expr 1.5 * $period ]
    set endp [ get_object_name [ all_fanout -from ${name}/Z -endpoint -flat -trace_arcs all] ]
    set coll2 [all_fanin -to ${name}/I -flat -trace_arcs all]
    set coll3 [ filter_collection $coll2 "(full_name =~ *rsl*/Q*) && full_name !~ *stag*" ]
    if {$coll3 eq ""} {continue}
    foreach_in_collection a $coll3 {
        puts $fp "set_max_delay $mdelay -from [ get_object_name $a ] -to $endp -ignore_clock_latency"
    }
}
close $fp




#foreach_in_collection c [get_clocks] {
#    puts "Clock:: [get_object_name $c]"
#    puts "==========================="
#    pc [filter_collection [all_registers -clock $c ] "full_name=~*rsl*"]
#}
#
#
#
#
#
##1. From: *.arsl.rsl__blk_src[2:0]
##    To: *.arsl.rsl__ablk_src[2:0]
#set from [get_pins * -hierarchical -filter "full_name=~*rsl__blk_src*"]
#set to   [get_pins * -hierarchical -filter "full_name=~*rsl__ablk_src*"]
#set_max_delay 0.885 -thr $from -thr $to 
#
#
# #2. From: *.arsl.rsl__blk_secure
##    To: *.arsl.rsl__ablk_secure
#set from [get_pins * -hierarchical -filter "full_name=~*rsl__blk_secure*"]
#set to   [get_pins * -hierarchical -filter "full_name=~*rsl__ablk_secure*"]
#set_max_delay 0.885 -thr $from -thr $to 
#
#
## 3. From: *.arsl.rsl__blk_rw_n
##     To: *.arsl.rsl__ablk_rw_n
#set from [get_pins * -hierarchical -filter "full_name=~*rsl__blk_rw_n*"]
#set to   [get_pins * -hierarchical -filter "full_name=~*rsl__ablk_rw_n*"]
#set_max_delay 0.885 -thr $from -thr $to 
#
##4. From: *arsl.rsl__blk_rsldid[2:0]
##    To: *.arsl.rsl__ablk_rsldid[2:0]
#set from [get_pins * -hierarchical -filter "full_name=~*rsl__blk_rsldid*"]
#set to   [get_pins * -hierarchical -filter "full_name=~*rsl__ablk_rsldid*"]
#set_max_delay 0.885 -thr $from -thr $to 
#
##5. From: *.arsl.rsl__blk_size[1:0]
##    To: *.arsl.rsl__ablk_size[1:0]
#set from [get_pins * -hierarchical -filter "full_name=~*rsl__blk_size*"]
#set to   [get_pins * -hierarchical -filter "full_name=~*rsl__ablk_size*"]
#set_max_delay 0.885 -thr $from -thr $to 
#
#
##6. From: *.arsl.rsl__blk_addr[47:0]
##    To: *.arsl.rsl__ablk_addr[47:0]
#set from [get_pins * -hierarchical -filter "full_name=~*rsl__blk_addr*"]
#set to   [get_pins * -hierarchical -filter "full_name=~*rsl__ablk_addr*"]
#set_max_delay 0.885 -thr $from -thr $to 
#
#
##7. From: *.arsl.rsl__blk_data[63:0]
##    To: *.arsl.rsl__ablk_data[63:0]
#set from [get_pins * -hierarchical -filter "full_name=~*rsl__blk_data*"]
#set to   [get_pins * -hierarchical -filter "full_name=~*rsl__ablk_data*"]
#set_max_delay 0.885 -thr $from -thr $to 
#
#
##8. From: *.arsl.ablk__error_p1
##To: *.arsl.rsl_core.blk__error_p1
#set from [get_pins * -hierarchical -filter "full_name=~*ablk__error_p1*"]
#set to   [get_pins * -hierarchical -filter "full_name=~*rsl_core/blk__error_p1*"]
#set_max_delay 0.885 -thr $from -thr $to 
#
#
##9. From: *.arsl.ablk__rdata_p1[63:0]
## To: *.arsl.rsl_core.blk__rslc_rdata_p1[63:0]
#set from [get_pins * -hierarchical -filter "full_name=~*ablk__rdata_p1*"]
#set to   [get_pins * -hierarchical -filter "full_name=~*blk__rslc_rdata_p1*"]
#set_max_delay 0.885 -thr $from -thr $to 
#
