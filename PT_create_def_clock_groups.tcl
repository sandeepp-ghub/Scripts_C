
  #this proc is from Synopsys:
	# report_clock_hierarchy.tcl - show parent/generated clock relationships (requires D-2009.12 or later)
	#
	# v1.0  10/26/2009  chrispy
	#  initial release
	
	
	proc report_clock_hierarchy {args} {
	 regexp {^.-(....\...)} $::sh_product_version dummy v  ;# not really a float but it gets the job done...
	 if {$v < 2009.12} {
	  echo "Error: This procedure requires D-2009.12 or later."
	  return 0
	 }
	
	 set results(clock) {}
	 parse_proc_arguments -args $args results
	
	 if {$results(clock) eq {}} {
	  # default to all physical clocks which are not children of other clocks
	  set clocks [sort_collection [get_clocks * -filter {defined(sources) && undefined(master_clock)}] full_name]
	 } else {
	  set clocks [get_clocks $results(clock)]
	  if {[sizeof_collection $clocks] != 1} {
	   echo "Error: only a single parent clock can be specified."
	   return 0
	  }
	 }
	
	 # push seed clocks onto the stack at level 0
	 set stack {}
	 foreach_in_collection clock $clocks {
	  lappend stack [list $clock 0]
	 }
	
	 # pull clocks off stack and process until stack is empty
	 while {$stack ne {}} {
	  foreach {clock level} [lindex $stack 0] {}
	  set stack [lrange $stack 1 end]
	  set clockname [get_object_name $clock]
	  if {[info exists visited($clockname)]} {continue}
	
	  echo "[string repeat {| } [expr {$level-1}]][expr {$level > 0 ? {+-} : {}}]$clockname"
	  set visited($clockname) {}
	
	  # if this clock is the parent of generated clocks, insert them directly at the front of the stack (one level deeper)
	  # so they are processed next
	  #
	  # note we push them onto the front of the stack in *reverse* name order so that we proceed to process them in
	  # the correct order after pushing them
	  foreach_in_collection gclock [sort_collection -descending [get_attribute -quiet $clock generated_clocks] full_name] {
	   set stack [linsert $stack 0 [list $gclock [expr $level+1]]]
	  }
	 }
	}
	
	define_proc_attributes report_clock_hierarchy \
	 -info {show parent/generated clock relationships} \
	 -define_args \
	 {
	  { clock "restrict reporting to this parent clock" "clock" string optional }
	 }

proc cn_pt_create_default_clock_groups {args} {
  set results(-group_name_of_master) {}
  set results(-merge_masters) {}
  parse_proc_arguments -args $args results

  #convert the list back into an array:
  array set group_name_of_master_ $results(-group_name_of_master)
  array set merge_masters_ $results(-merge_masters)

  #upvar group_name_of_master group_name_of_master
  #gser_rx_clk_dcc_shift90 gser_rx_clk_dcc
  array unset master_of
  redirect -variable master_info {report_clock_hierarchy}
  foreach line [split $master_info "\n"] {
    if {[regexp {^.*\+-(\S+)} $line match clock]} {
      set master_of($clock) $master
      lappend gen_clocks_of($master) $clock
    } elseif {[regexp {^\s*$} $line]} {
      #puts "EMPTY: $line"
    } else {
      set new_master $line
      foreach {frompat topat} [array get merge_masters_] {
        regsub $frompat $new_master $topat new_master
      }
      if {$new_master != $line} {
        puts "INFO: REMAPPING MASTER: $line -> $new_master"
        set master $new_master
        lappend gen_clocks_of($master) $line
      } else {
        set master $line
        set master_of($line) $line
        set seen_master($line) $line
      }
    }
  }

  set fn default_clock_group.pt
  set f2 cn_pt_set_clock_groups.pt
  #set fout [open $fn w]
  set fo2  [open $f2 w]
  set csv [open root_master_info.csv w]
  puts $csv "CLOCK,SOURCE(S),ROOT_MASTER_CLOCK,NOTES"
  #puts $fout "set_clock_groups -asynchronous -name DEFAULT \\"
  set i 0
  foreach mclk [lsort [array names seen_master]] {
    if {![info exists group_name_of_master_($mclk)]} {
      puts "INFO: Autonaming $mclk ... group"
      set groupsname M$i
	  set groupsname ${mclk}_MASTER
      incr i 1
    } else {
      set groupsname $group_name_of_master_($mclk)
    }
    puts $fo2 "\n# MASTER CLOCK: $mclk"
    set src [get_object_name [get_attribute [get_clocks $mclk] sources]]
    puts $csv "$mclk,$src,$mclk,ROOT"
    if {[info exists gen_clocks_of($mclk)]} {
      #puts $fout "  -group \[list $mclk \\"
      puts $fo2  "cn_pt_set_clock_groups -type async -name TOP -group_name $groupsname -clocks \[list $mclk\] ; # Master Clock"
      foreach gclk [lsort $gen_clocks_of($mclk)] {
        #puts $fout "               $gclk \\"
        puts $fo2  "cn_pt_set_clock_groups -type async -name TOP -group_name $groupsname -clocks \[list $gclk\]"
        set src [get_object_name [get_attribute [get_clocks $gclk] sources]]
        puts $csv "$gclk,$src,$mclk,"
      }
      #puts $fout "         \]"
    } else {
      #puts $fout "  -group $mclk \\"
      puts $fo2  "cn_pt_set_clock_groups -type async -name TOP -group_name $groupsname -clocks \[list $mclk\] ; # A lone clock"
    }
  }
  #close $fout
  close $fo2
  #source $fn
  close $csv
}
	
define_proc_attributes cn_pt_create_default_clock_groups \
-info {Create a default cn_pt_create_clock_groups file for the *TOP* level} \
-define_args \
{
{ -merge_masters        "force master clocks and their derived clocks to be synchronous" "<clock1 clock2> <clock3 clock4>..." string optional }
{ -group_name_of_master "force custom naming of clock group names by master clock" "<clock1 name1> <clock2 name2>..." string optional }
}

array unset group_name_of_master
set group_name_of_master(bts_clk) BTS_CLK
foreach qlm {0 1} {
  set group_name_of_master(gser__gsern/qlm${qlm}/com/gser_com_gser_fbclk) GSER_Q${qlm}_COM_FBCLK
  set group_name_of_master(gser__gsern/qlm${qlm}/com/gser_pll_ref_clk) GSER_Q${qlm}_COM_PLL_REF_CLK
  set group_name_of_master(gser__gsern/qlm${qlm}/com/gser_refc_clk) GSER_Q${qlm}_COM_REFC_CLK
  foreach lane {0 1 2 3} {
    set group_name_of_master(eth25_gser__gsern/qlm${qlm}/lane${lane}/gser_rx_clk_dcc)       ROC_ETH25_RX_Q${qlm}_L${lane}
    set group_name_of_master(eth25_gser__gsern/qlm${qlm}/lane${lane}/gser_tx_clk_dcc)       ROC_ETH25_TX_Q${qlm}_L${lane}
    set group_name_of_master(sgmii2p5_gser__gsern/qlm${qlm}/lane${lane}/gser_rx_clk_dcc)    ROC_SGMII2P5_RX_Q${qlm}_L${lane}
    set group_name_of_master(sgmii2p5_gser__gsern/qlm${qlm}/lane${lane}/gser_tx_clk_dcc)    ROC_SGMII2P5_TX_Q${qlm}_L${lane}
    set group_name_of_master(sata6_gser__gsern/qlm${qlm}/lane${lane}/gser_rx_clk_dcc)       ROC_SATA6_RX_Q${qlm}_L${lane}
    set group_name_of_master(sata6_gser__gsern/qlm${qlm}/lane${lane}/gser_tx_clk_dcc)       ROC_SATA6_TX_Q${qlm}_L${lane}
    set group_name_of_master(pcie16_gser__gsern/qlm${qlm}/lane${lane}/gser_rx_clk_dcc)      ROC_PCIE16_RX_Q${qlm}_L${lane}
    set group_name_of_master(pcie16_gser__gsern/qlm${qlm}/lane${lane}/gser_tx_clk_dcc)      ROC_PCIE16_TX_Q${qlm}_L${lane}
    set group_name_of_master(gser__gsern/qlm${qlm}/lane${lane}/gser_fbclk)                  ROC_GSER_Q${qlm}_L${lane}_FBCLK
  }
}

set group_name_of_master(pi_bts_bfn_clk) PI_BTS_BFN_CLK
set group_name_of_master(pi_bts_extref0_clk) PI_BTS_EXTREF0_CLK
set group_name_of_master(pi_bts_extref1_clk) PI_BTS_EXTREF1_CLK
set group_name_of_master(pi_bts_extref2_clk) PI_BTS_EXTREF2_CLK
set group_name_of_master(pi_ejtck) PI_EJTCK
set group_name_of_master(pi_ncsi_ref_clk) PI_NCSI_REF_CLK
set group_name_of_master(pi_refclk) PI_REFCLK
set group_name_of_master(pi_tck) PI_TCK
set group_name_of_master(pulse_osc_clk) PULSE_OSC_CLK
set group_name_of_master(rclk_clu0) RCLK
set group_name_of_master(rclk_early) RCLK
set group_name_of_master(rclk_iobn0) RCLK
set group_name_of_master(sclk) SCLK
#NEW FOR GSERR
set group_name_of_master(cpu_clk) CPU_CLK

set groups_as_list [array get group_name_of_master]
set remaps_list {gser_rx_clk_dcc_shift90 gser_rx_clk_dcc}

#RUN IT!
#cn_gen_top_clock_groups {gser_rx_clk_dcc_shift90 gser_rx_clk_dcc}
cn_pt_create_default_clock_groups -group_name_of_master $groups_as_list -merge_masters $remaps_list
