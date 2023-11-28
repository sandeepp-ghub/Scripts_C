set block  dwc_ddrphy_pnr_block
set UPF    [open /user/lioral/scripts/config/new_upf/${block}.upf  w]
set RGN    [open /user/lioral/scripts/config/new_upf/${block}.mv_supplemental_region.tcl  w]
if {[info exists MDB]}          {unset MDB}
if {[info exists other]}        {unset other}
if {[info exists regions_name]} {unset regions_name}

set regions  {\
{0 500    31.008 620} \
{0 1114   31.008 1155} \
{0 1648   31.008 1688} \
{0 2181.8 31.008 2223} \
{0 2716   31.008 2755} \
{0 3250   31.008 3290} \
}


#==================================
#>>> Print upf header
#==================================

puts $UPF "#############################################################################################"
puts $UPF "## ${block} upf"
puts $UPF "##############################################################################################"
puts $UPF "create_supply_port VDD"
puts $UPF "create_supply_port VDD_D"
puts $UPF "create_supply_port VSS"
puts $UPF "create_power_domain PD_${block} -include_scope"
puts $UPF "create_supply_net VDD -domain PD_${block}"
puts $UPF "create_supply_net VDD_D -domain PD_${block}"
puts $UPF "create_supply_net VSS -domain PD_${block}"
puts $UPF "set_domain_supply_net PD_${block} -primary_power_net VDD -primary_ground_net VSS"
puts $UPF "set_level_shifter ls -domain PD_${block} -location self -applies_to both \\"
puts $UPF " -rule both -name_prefix LS_"
puts $UPF "connect_supply_net VDD -ports VDD"
puts $UPF "connect_supply_net VDD_D -ports VDD_D"
puts $UPF "connect_supply_net VSS -ports VSS "
puts $UPF "add_port_state VDD -state {LOW 0.675} -state {HIGH 0.750}"
puts $UPF "add_port_state VDD_D -state {LOW 0.675} -state {HIGH 0.750} "
puts $UPF "add_port_state VSS -state {ON_VSS 0.0}"
puts $UPF "create_pst pst -supplies {VDD VDD_D VSS} "
puts $UPF "add_pst_state S1 -pst pst -state {HIGH HIGH ON_VSS} "
puts $UPF "add_pst_state S2 -pst pst -state {LOW HIGH ON_VSS}"
puts $UPF "add_pst_state S3 -pst pst -state {HIGH LOW ON_VSS} "
puts $UPF "add_pst_state S4 -pst pst -state {LOW LOW ON_VSS}"
puts $UPF ""
puts $UPF "##############################################################################################"
puts $UPF "## Ports"
puts $UPF "##############################################################################################"
puts $UPF ""

#==================================
#>>> Print upf body
#==================================
set ports [lsort -u [get_object_name [get_ports * -filter  "direction==in&&full_name!~*BP*&&full_name!~*VDD*&&full_name!~*VAA*&&full_name!~*VSS*"]]]
foreach port $ports {
    puts $UPF "set_related_supply_net -ground VSS -power VDD_D -object_list ${port}"
}

#==================================
#>>> Print supplemental_region header
#==================================
puts $RGN "set MV_SUPPLEMENTAL_REGION \[dict create \\"

#==================================
#>>> Split ports to regions 
#==================================
set i     1
set other ""
foreach region $regions {
    set miny [lindex $region 1]
    set maxy [lindex $region 3]
    set name "region${i}"
    set MDB($name,miny)  $miny
    set MDB($name,maxy)  $maxy
    set MDB($name,ports) ""
    set MDB($name,box)   $region
    lappend regions_name $name
    incr i
}

foreach port $ports {
    puts $port
    set ok 0
    set y [get_db port:${port} .location.y]
    foreach name $regions_name {
        if { $MDB($name,miny) <= $y && $y <= $MDB($name,maxy) } {
            lappend MDB($name,ports) $port
            set ok 1 
        }
    }
    if {$ok eq 0 } {lappend other  $port}
}

foreach name $regions_name {
    puts $RGN "\t$name \[dict create \\"
    puts $RGN "\tnet VDD_D \\"
    puts $RGN "\tbbox \{$MDB($name,box)\} \\"
    puts $RGN "\tportlist \{ \\"
    foreach port $MDB($name,ports) {
        puts $RGN "\t\t$port \\"
    }
    puts $RGN "\t\}\] \\"
}



close $UPF
close $RGN

