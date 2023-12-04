#! /usr/bin/tcl
puts "  select nets in the input file to do manual fixes"
puts " @@@ \"SHIFT+y\" @@@ to select next net\n"

global tranNetCnt
set tranNetCnt 1
global lastNet
set lastNet 1
global uniqTranNetCnt
set uniqTranNetCnt 1
array unset tranNets

proc select_nets_tofix {} {
global tranNetCnt
global lastNet
global uniqTranNetCnt
global tranNets


set NETS [open "../violNets.list" "r"]
set localTranNetCnt 0
while {[gets $NETS Violnet] > -1} {
set net_name [get_db nets $Violnet]

#regexp {^#\s+Net:\s+(\S+)\s+} $Violnet junk net_name
incr localTranNetCnt
if {[expr {$tranNetCnt > $localTranNetCnt}]} {
continue
}
if {[expr {$net_name != $lastNet}]} {
set  tranNetCnt $localTranNetCnt
set lastNet $net_name

if {![info exists tranNets($net_name)] } {
    deselect_obj -all
    puts "Net: $net_name \n"
    select_obj  $net_name
    gui_zoom -selected 
    set tranNets($net_name) 1
    break
} else {
puts "Net: $net_name is already fixed"
}    



}
}
close $NETS
}

gui_bind_key Shift-Y -cmd "select_nets_tofix" 
