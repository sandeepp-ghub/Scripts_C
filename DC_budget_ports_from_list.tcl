set my_list [file_to_list aaa] 

foreach pp $my_list {
    #-- set the bus w
    if {[regexp {(.*)(\[.*\])} $pp -> name ]} {
        set p "${name}[*]";
    } else {
        set p $pp
    }
    #-- see if in or out
    set dir     [lindex [get_attr [get_ports $p] port_direction] 0] 
    #-- get_clocks 
    puts "Info : $p"
    set clocks  [soc_find_possible_clocks [index_collection [get_ports $p]  0]]
    set clock_out "";
    foreach c $clocks {
        if {[get_attr  [get_clocks $c] is_generated]} {set c [get_attr  [get_clocks $c] master_clock_name]} else {set c $c}
        if {[get_attr  [get_clocks $c] is_generated]} {set c [get_attr  [get_clocks $c] master_clock_name]} else {set c $c}
        lappend clock_out $c;
    }
    set clock_out [lsort -unique $clock_out ]
    
#    if {[regexp {serdes0} $p]} {set posib [list from_serdes0 FROM_LANE0 CORE_CLK serdes0_rxdclk serdes0_txdclk ]}
#    if {[regexp {serdes1} $p]} {set posib [list from_serdes1 FROM_LANE1 CORE_CLK serdes1_rxdclk serdes1_txdclk from_serdes0 FROM_LANE0 CORE_CLK serdes0_rxdclk serdes0_txdclk ]}
#    if {[regexp {serdes2} $p]} {set posib [list from_serdes2 FROM_LANE2 CORE_CLK serdes2_rxdclk serdes2_txdclk from_serdes0 FROM_LANE0 CORE_CLK serdes0_rxdclk serdes0_txdclk ]}
#    if {[regexp {serdes3} $p]} {set posib [list from_serdes3 FROM_LANE3 CORE_CLK serdes3_rxdclk serdes3_txdclk from_serdes0 FROM_LANE0 CORE_CLK serdes0_rxdclk serdes0_txdclk ]}
#    if {[regexp {serdes4} $p]} {set posib [list from_serdes4 FROM_LANE4 CORE_CLK serdes4_rxdclk serdes4_txdclk]}
#    if {[regexp {serdes5} $p]} {set posib [list from_serdes5 FROM_LANE5 CORE_CLK serdes5_rxdclk serdes5_txdclk]}
#    if {[regexp {serdes6} $p]} {set posib [list from_serdes6 FROM_LANE6 CORE_CLK serdes6_rxdclk serdes6_txdclk]}
#    if {[regexp {pex002serdes} $p]} {set posib [list from_serdes0 FROM_LANE0 CORE_CLK serdes0_rxdclk serdes0_txdclk from_serdes1 FROM_LANE1 CORE_CLK serdes1_rxdclk serdes1_txdclk from_serdes2 FROM_LANE2 CORE_CLK serdes2_rxdclk serdes2_txdclk from_serdes3 FROM_LANE3 CORE_CLK serdes3_rxdclk serdes3_txdclk]}
#    if {[regexp {pex012serdes} $p]} {set posib [list from_serdes6 FROM_LANE6 CORE_CLK serdes6_rxdclk serdes6_txdclk from_serdes2 FROM_LANE2 CORE_CLK serdes2_rxdclk serdes2_txdclk from_serdes4 FROM_LANE4 CORE_CLK serdes4_rxdclk serdes4_txdclk]}
#    if {[regexp {pex22serdes} $p]}  {set posib [list from_serdes4 FROM_LANE4 CORE_CLK serdes4_rxdclk serdes4_txdclk from_serdes5 FROM_LANE5 CORE_CLK serdes5_rxdclk serdes5_txdclk]}
#    if {[regexp {pex32serdes} $p]}  {set posib [list from_serdes3 FROM_LANE3 CORE_CLK serdes3_rxdclk serdes3_txdclk]}
#    foreach c $clock_out {
#        
#
#    }



    #-- print debug out
    echo "set_${dir}put_delay 2.6 -clock \[get_clocks CORE_CLK\] \[get_ports $p\] ; # $dir  $clock_out" >> bbb

}

