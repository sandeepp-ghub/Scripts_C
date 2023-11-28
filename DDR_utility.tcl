################################################################################
## File Contents
## ----------------------------------------------------------------------------
## 1. Aliases
##
## 2. Procedures
##
################################################################################

##==============================================================================
## 1. Aliases
##==============================================================================
                                                       
alias cyclepath               "eval set_multicycle_path"
alias falsepath               "eval set_false_path"
alias ck_uncertain            "set_clock_uncertainty"
alias disable_timing          "set_disable_timing"
alias disable_ck_gating_check "set_disable_clock_gating_check"
alias dft_signal              "set_dft_signal"
alias fc                      "filter_collection"
alias rfc		      "remove_from_collection"
alias fc                      "filter_collection"
alias fic                     "foreach_in_collection"
alias pck                     "create_clock -name"
alias gck                     "create_generated_clock -name"
alias idelay                  "set_input_delay  -add -clock"
alias odelay                  "set_output_delay -add -clock"
alias ck_latency	      "set_clock_latency"


##==============================================================================
## 2. Procedures
##==============================================================================

##------------------------------------------------------------------------------- 
## Extract define values from the given "define" file to the TCL "def" array
## Example: extract_defines <define_file_name>
##------------------------------------------------------------------------------- 
proc extract_defines {phy_cfg_file} {
  global env def
  puts "DDR_IP_INFO:  Extracts defines from $phy_cfg_file to def array..."

  set IF [open $phy_cfg_file r]
  set DF [open "defs.c" w]
  while {[gets $IF line] >=0} {
    regsub {\/\/.+$} $line "" line
    regsub -all "`" $line \# line 
    puts $DF $line
  }
  close $IF
  close $DF
  catch {exec gcc -dM -E defs.c > defs_pp.c} msg
  set IF [open "defs_pp.c" r]
  while {[gets $IF line] >=0} {
    regsub {\'[\s\t]*$} $line "" line
    if [regexp {\#define[\s\t]+(.+)$} [string trim $line] m name_val] {
      if [regexp {([^\s\t]+)[\s\t]+(.+)} $name_val m name val] {
        if {[string index $val 0] == "\#"} {
          set subst_name [string trimleft $val "#"]
  	  if  [info exists def($subst_name)] {
            set val $def($subst_name)
  	  }
	}
        set def($name) $val
      } else {
        set def($name_val) ""
      }
    }  
  }
  close $IF
  file delete defines.v defs_pp.c defs.c
}



proc port_ck {n p} {
    pck $n -p $p [get_port $n]
}

proc caps s {
    global cs
    return [expr $s * $cs * 1.0]
}

proc tims s {
    global ts
    return [expr $s * $ts * 1.0]
}

proc suppress_errors s {
    global suppress_errors
    set suppress_errors "$s $suppress_errors"
}

proc unsuppress_errors s {
    global suppress_errors
    
    set ers ""
    foreach er $suppress_errors {
	if {$s != $er} {
	    set ers "$er $ers"
        }
    } 
    set suppress_errors $ers
}

proc remove_tail s {
    if {[regexp "/" $s]} {
        return [string range $s 0 [expr [string last "/" $s] -1]]
    } else {
	return $s
    }
}

proc remove_sfix s {
    if {[regexp "\." $s]} {
        return [string range $s 0 [expr [string last "\." $s] -1]]
    } else {
        return $s
    }
}

proc remove_head  s {
    if {[regexp "/" $s]} {
        return \
	[string range $s [expr [string last "/" $s] + 1] [string length $s]]
    } else {
	return $s
    }
}

proc remove_top s {
    if {[regexp "/" $s]} {
        return \
        [string range $s [expr [string first "/" $s] + 1] [string length $s]]
    } else {
	return $s
    }
}

proc is_net args {
    if {[eval get_nets -quiet $args] == ""} {
	return 0;
    } else {
	return 1;
    }
}

proc is_pin args {
    if {[eval get_pins -quiet $args] == ""} {
	return 0;
    } else {
	return 1;
    }
}

proc is_port args {
    if {[eval get_port -quiet $args] == ""} {
	return 0;
    } else {
	return 1;
    }
}

proc is_cell args {
    if {[eval get_cells -quiet $args] == ""} {
        return 0;
    } else {
        return 1;
    }
}

proc get_ipins args {
    return [get_pins -quiet -of_object [get_cells $args] \
                     -filter {@pin_direction == in}]
}

proc get_opins args {
    return [get_pins -quiet -of_object [get_cells $args] \
                     -filter {@pin_direction == out}]
}

proc get_srpins args {

    global syn_ff_sr

    foreach_in_collection acel [get_cells $args] {
        set acn [get_object_name $acel] 
        if {[sizeof_collection [get_pins -quiet $acn/clocked_on]] != 0} {
	    append_to_collection srpins [get_pins -quiet $acn/preset]
            append_to_collection srpins [get_pins -quiet $acn/clear]
	    append_to_collection srpins [get_pins -quiet $acn/sync_preset]
            append_to_collection srpins [get_pins -quiet $acn/sync_clear]

        } else {
	    foreach sr $syn_ff_sr {
	        append_to_collection srpins [get_pins -quiet $acn/$sr]
	    }
        }
    }

    return $srpins
}

proc get_qpins args {

    global syn_ff_q

    foreach_in_collection acel [get_cells $args] {
        set acn [get_object_name $acel]
        if {[sizeof_collection [get_pins -quiet $acn/clocked_on]] != 0} {
            append_to_collection qpins [get_pins -quiet $acn/Q]
        } else {
            append_to_collection qpins [get_pins -quiet $acn/$syn_ff_q]
        }
    }

    return $qpins
}

proc get_qbpins args {

    global syn_ff_qb

    foreach_in_collection acel [get_cells $args] {
        set acn [get_object_name $acel]
        if {[sizeof_collection [get_pins -quiet $acn/clocked_on]] != 0} {
            append_to_collection qbpins [get_pins -quiet $acn/QN]
        } else {
            append_to_collection qbpins [get_pins -quiet $acn/$syn_ff_qb]
        }
    }
    return $qbpins
}


proc get_pin_type args {
    set pintype [get_attribute $args pin_direction -quiet]
    if {[is_pin $args]} { 
        if {$pintype eq ""} {
	    set hnet [all_connected -leaf [get_pins $args]]
	    set hist [remove_trail [get_object_name [get_pins $args]]]
            foreach_in_collection hpin [all_connected -leaf $hnet] {
		set hpinn [get_object_name $hpin]
		if {[regexp ^$hist $hpinn]} {
		    return [get_attribute $hpin pin_direction]
		}
            }
        } else {
	    return $pintype
        }
    } elseif {[is_port $args]} {
	if       {$pintype eq "in"} {
	    return "out" 
        } elseif {$pintype eq "out"} { 
            return "in"
	} else {
	    return $pintype
        }
    } else {
        return $pintype
    }
}
proc get_load_p {opt obj} {
    set arg "" 
    if {$opt eq "leaf"} { set arg "-leaf" }
    if {[is_net $obj]} {
        set net [get_nets $obj]
    } elseif {[is_port $obj]} {
        set net [eval all_connected $arg [get_port $obj]]
    } else {
        set net [eval all_connected $arg [get_pins $obj]]
    }
    foreach_in_collection conn [eval all_connected $arg $net] {
	set pintype [get_pin_type $conn]
        if {$pintype eq "in"} {
	    append_to_collection base $conn
        }
	if {$pintype eq "inout"} {
            append_to_collection base $conn
        }
    }
    return $base
}
proc get_load_c {opt obj} {
    foreach_in_collection glp [get_load_p $opt $obj] {
	append_to_collection base \
                             [get_cell [remove_trail [get_object_name $glp]]]
    }
    return $base
}
proc get_drive_p {opt obj} {
    set arg "" 
    if {$opt eq "leaf"} { set arg "-leaf" }
    if {[is_pin $obj]} {
        set net [eval all_connected $arg [get_pins $obj]]
    } elseif {[is_port $obj]} {
        set net [eval all_connected $arg [get_port $obj]]
    } else {
        set net [get_nets $obj]
    }
    foreach_in_collection conn [eval all_connected $arg $net] {
        set pintype [get_pin_type $conn]
        if {$pintype eq "out"} {
            append_to_collection base $conn
        }
        if {$pintype eq "inout"} {
            append_to_collection base $conn
        }
    }
    return $base
}
proc get_drive_c {opt obj} {
    foreach_in_collection glp [get_drive_p $opt $obj] {
        append_to_collection base \
                             [get_cell [remove_tail [get_object_name $glp]]]
    }
    return $base
}
proc get_load_pin_hier obj {
    get_load_p hier $obj
}
proc get_load_pin_leaf obj {
    get_load_p leaf $obj
}
proc get_load_cell_hier obj {
    get_load_c hier $obj
}
proc get_load_cell_leaf obj {
    get_load_c leaf $obj
}
proc get_drive_pin_hier obj {
    get_drive_p hier $obj
}
proc get_drive_pin_leaf obj {
    get_drive_p leaf $obj
}
proc get_drive_cell_hier obj {
    get_drive_c hier $obj
}
proc get_drive_cell_leaf obj {
    get_drive_c leaf $obj
}
proc get_load_pin obj {
    get_load_pin_leaf $obj
}
alias get_load_cell  "get_load_cell_leaf"
alias get_drive_pin  "get_drive_pin_leaf"
alias get_drive_cell "get_drive_cell_leaf"

proc get_net_con {net cell} {
    set cellc [get_object_name [get_cells $cell]]
    set netn [get_object_name [get_nets -hier -segment $net]]
    foreach_in_collection cp [get_pins $cellc/*] {
        set cpn  [get_object_name [get_nets -hier -segment -of_object $cp]]
	if {$cpn eq $netn} {
	    return [get_pins $cp]
        }
    }
}

alias ck_uncertain_fromto set_clock_uncertainty_fromto
proc iso_ck {clk} {
   set clks [rfc [get_clocks] [get_clocks $clk]]
   falsepath_fromto $clks $clk
}

proc other_ck {clk} {
   set clks [rfc [get_clocks] [get_clocks $clk]]
   return $clks
}

proc falsepath_fromto {t1 t2} {
    set_false_path -from $t1 -to $t2
    set_false_path -from $t2 -to $t1
}

proc set_idelay {min max clk loc} {
    global lib_cell_buf2
    global syn_cell_buf2
    global syn_cell_buf2_i
    global syn_cell_buf2_o
    global syn_trans

    set_input_delay  $min -min -clock $clk -add_delay $loc
    set_input_delay  $max -max -clock $clk -add_delay $loc
}

proc set_ifdelay {min max clk loc} {
    global lib_cell_buf2
    global syn_cell_buf2
    global syn_cell_buf2_i
    global syn_cell_buf2_o
    global syn_trans

    set_input_delay  $min -min -clock $clk -clock_fall -add_delay $loc
    set_input_delay  $max -max -clock $clk -clock_fall -add_delay $loc
}

proc set_odelay {min max clk loc} {
    global lib_cell_buf16
    global syn_cell_buf16
    global syn_cell_buf16_i
    global syn_cell_buf16_o

    set_output_delay $min -min -clock $clk -add_delay $loc
    set_output_delay $max -max -clock $clk -add_delay $loc
    #set_load [load_of $lib_cell_buf16/$syn_cell_buf16_i] $loc
}


proc buf_port port {
    global lib_slow_cell_ibuf
    global lib_slow_cell_obuf

    foreach_in_collection aport [get_ports $port] {
        if       {[get_attribute [get_ports $aport] direction] == "in"} {
            set buf $lib_slow_cell_ibuf
        } elseif {[get_attribute [get_ports $aport] direction] == "out"} {
            set buf $lib_slow_cell_obuf
        }
        insert_buf [get_port $aport] $buf
    }
}

proc change_net {org new} {
    set o [get_nets $org]
    create_net $new
    set cpins [all_connected $o]
    remove_net $o
    connect_net $new $cpins
}

proc change_buf {cell newc} {
    set cn [get_object_name [get_cells $cell]]
    set in [all_connected [get_pins $cn/* -filter {@pin_direction == in}]]
    set on [all_connected [get_pins $cn/* -filter {@pin_direction == out}]]
    remove_cell $cn
    create_cell $cn $newc
    connect_net $in [get_pins $cn/* -filter {@pin_direction == in}]
    connect_net $on [get_pins $cn/* -filter {@pin_direction == out}]
}
proc replace_tie {cell newc} {
    set cn [get_object_name [get_cells $cell]]
    set on [all_connected [get_pins $cn/* -filter {@pin_direction == out}]]
    remove_cell $cn
    create_cell $cn $newc
    connect_net $on [get_pins $cn/* -filter {@pin_direction == out}]
}

proc trace_org_drive args {
    set dp   [get_drive_pin  $args]
    set dr   [get_drive_cell $args]
    set ip   [get_ipin $dr]
    set np   [sizeof_collection $ip]
    if {$np == 1} {
        set args [get_drive_pin $ip]
        set dp [trace_org_drive $args]
    }
    return $dp 
}
proc dft_spec args {
    eval set_dft_signal -view spec  -type $args
}
proc dft_exsi args {
    eval set_dft_signal -view exist -type $args
}
proc dft_both args {
    eval dft_spec $args
    eval dft_exsi $args
}
proc set_search_path {} {
    global search_path
    global link_library
    foreach llib $link_library {
        if {[regexp "/" $llib]} {
	    set search_path "$search_path [remove_trail $llib]"
        }
    }
}

proc write_report_legacy args {

    global design

    report_reference -nosplit            > ../rpt/${design}_${args}.ref
    report_reference -nosplit -hierarchy > ../rpt/${design}_${args}.href
    report_area -nosplit                 > ../rpt/${design}_${args}.area
    report_power -nosplit                > ../rpt/${design}_${args}.power
    report_timing -delay max -inp -net -path full_clock_expanded -nosplit \
                                         > ../rpt/${design}_${args}.max
    report_design -nosplit               > ../rpt/${design}_${args}.design
    report_design -physical -nosplit     > ../rpt/${design}_${args}.pr
    report_qor                           > ../rpt/${design}_${args}.qor
}

proc write_report args {
   global design

   report_qor > ../rpt/${design}_qor.rpt
   report_timing -path end        -delay max -max_paths 200 -sort_by slack > ../rpt/${design}_${args}_path_end.rpt
   report_timing -path full_clock -delay max -max_paths 200 -sort_by slack \
      -transition_time -capacitance                             > ../rpt/${design}_${args}_path_full.rpt
   report_timing -path end        -delay min -max_paths 200 -sort_by slack > ../rpt/${design}_${args}_hold_end.rpt
   report_timing -path full       -delay min -max_paths 200 -sort_by slack \
      -transition_time -capacitance                             > ../rpt/${design}_${args}_hold_full.rpt
   report_timing -loop                       -max_paths 200                > ../rpt/${design}_${args}_feedback_loop.rpt
 
   report_constraints -all_violators -nosplit > ../rpt/${design}_${args}_constr.rpt
 
   report_hierarchy           > ../rpt/${design}_${args}_hierarchy.rpt
   report_cell                > ../rpt/${design}_${args}_cell.rpt
   report_reference           > ../rpt/${design}_${args}_reference.rpt
   report_area                > ../rpt/${design}_${args}_area.rpt
   report_port                > ../rpt/${design}_${args}_port.rpt
   report_isolate_ports       > ../rpt/${design}_${args}_isolate.rpt
   report_constraint -verbose > ../rpt/${design}_${args}_constraint.rpt
 
   report_clock -attributes -skew                   > ../rpt/${design}_${args}_clock.rpt
 
   report_net_fanout -nosplit -threshold 500        > ../rpt/${design}_${args}_fanout_check.rpt
   report_net_fanout -nosplit -tree -threshold 500 >> ../rpt/${design}_${args}_fanout_check.rpt
   report_net_fanout -nosplit -threshold 100       >> ../rpt/${design}_${args}_fanout_check.rpt
   report_net_fanout -nosplit -tree -threshold 100 >> ../rpt/${design}_${args}_fanout_check.rpt

   check_design > ../rpt/${design}_${args}_chk_netlist.rpt
   check_timing > ../rpt/${design}_${args}_chk_timing.rpt

   current_design $design
   report_reference -hier -nosplit                  > ../rpt/${design}_${args}_area_hier.rpt
}

proc print_collection args {
    foreach_in_collection c $args {
	echo [get_object_name $c]
    }
}
proc port_latency {max_r max_f min_r min_f pn} {
    set_clock_latency -rise -source -max $max_r $pn
    set_clock_latency -fall -source -max $max_f $pn
    set_clock_latency -rise -source -min $min_r $pn
    set_clock_latency -fall -source -min $min_f $pn
}

proc dummyname {prefix name} {
    set head [remove_tail $name]
    set tail [remove_head $name]

    if {$prefix == ""} {
        set dummy $head/${tail}_0
    } else {
        set dummy $head/${prefix}_${tail}_0
    }

    if {[get_cells -quiet $dummy] != ""} {
	set dummy [dummyname "" $dummy]
    }
    return $dummy
}

proc insert_dummy_cg {pin cg_ref exp} {

    global syn_cell_tiehi

    set drcel [get_cells $cg_ref]
    set drpin [get_pins $pin]
    set drnet [get_nets -of_object $pin]

    set cellname [dummyname CTB [get_object_name $drcel]]
    set ref [get_attribute $drcel ref_name]
    create_cell $cellname $ref
    create_net  ${cellname}_net
    connect_net ${cellname}_net [get_opin $cellname]

    set tiename [dummyname TIE [get_object_name $drcel]]
    create_cell $tiename $syn_cell_tiehi
    create_net  ${tiename}_net 
    connect_net ${tiename}_net [get_opin $tiename]

    if {$exp != ""} {
        set copin [rfc [rfc [all_connected $drnet] $drpin] [get_pins $exp]]
    } else {
        set copin [rfc [all_connected $drnet] $drpin]
    }

    disconnect_net $drnet $copin
    connect_net ${cellname}_net $copin

    foreach_in_collection ci [get_ipin $cellname] {
	set c [get_attribute -quiet [get_lib_pin -of $ci] clock_gate_clock_pin]
	if {$c == "true"} {
	    connect_net $drnet $ci
	} else {
	    connect_net ${tiename}_net $ci
	}
    }
}
proc insert_dummy_mux {pin mux_ref exp} {

    global syn_cell_tielo

    set drcel [get_cells $mux_ref]
    set drpin [get_pins $pin]
    set drnet [get_nets -of_object $pin]

    set cellname [dummyname CTB [get_object_name $drcel]]
    set ref [get_attribute $drcel ref_name]
    create_cell $cellname $ref
    create_net  ${cellname}_net
    connect_net ${cellname}_net [get_opin $cellname]

    set tiename [dummyname TIE [get_object_name $drcel]]
    create_cell $tiename $syn_cell_tielo
    create_net  ${tiename}_net 
    connect_net ${tiename}_net [get_opin $tiename]

    set ms  [fc [get_ipin $drcel] "@is_on_clock_network==false"]
    set msi [remove_head [get_object_name $ms]]
    connect_net ${tiename}_net $cellname/$msi

    if {$exp != ""} {
        set copin [rfc [rfc [all_connected $drnet] $drpin] [get_pins $exp]]
    } else {
        set copin [rfc [all_connected $drnet] $drpin]
    }
    disconnect_net $drnet $copin
    connect_net ${cellname}_net $copin
    
    set cis [sort_collection -dic [get_ipin $cellname] name]
    set flag 0
    foreach_in_collect ci $cis {
	if {[get_nets -quiet -of $ci] == ""} {
	    if {$flag == 0} {
	        connect_net $drnet $ci
	echo [get_object_name $ci]
	        set flag 1
	    } else {
		connect_net ${tiename}_net $ci
	    }
        }
    }
}

proc insert_dummy_or {pin or_ref exp} {

    global syn_cell_tielo

    set drcel [get_cells $or_ref]
    set drpin [get_pins $pin]
    set drnet [get_nets -of_object $pin]

    set cellname [dummyname CTB [get_object_name $drcel]]
    set ref [get_attribute $drcel ref_name]
    create_cell $cellname $ref
    create_net  ${cellname}_net
    connect_net ${cellname}_net [get_opin $cellname]

    set tiename [dummyname TIE [get_object_name $drcel]]
    create_cell $tiename $syn_cell_tielo
    create_net  ${tiename}_net
    connect_net ${tiename}_net [get_opin $tiename]

    if {$exp != ""} {
        set copin [rfc [rfc [all_connected $drnet] $drpin] [get_pins $exp]]
    } else {
        set copin [rfc [all_connected $drnet] $drpin]
    }
    disconnect_net $drnet $copin
    connect_net ${cellname}_net $copin

    set flag 0
    foreach_in_collect ci [get_ipin $cellname] {
        if {$flag == 0} {
            connect_net $drnet $ci
            set flag 1
        } else {
            connect_net ${tiename}_net $ci
        }
    }
}

proc report_latency_skew_notendpoints {tp clock pinlist latencyLimit skewLimit } {
    set count 0

    foreach_in_collection my_path $tp {
     foreach_in_collection my_point [get_attribute $my_path points ] {
      set point_name [get_attribute [get_attribute $my_point object] full_name]
      if {[string match $pinlist $point_name]} {
	set this_arrival [get_attr $my_point arrival]
	set this_name    $point_name
        echo "     $this_name $this_arrival"
	if {$count == 0} {
	    set max_arrival  $this_arrival
	    set min_arrival  $this_arrival
	    set max_name $this_name
	    set min_name $this_name
	    set count 1
	} else {
	    if {$this_arrival > $max_arrival} {
		set max_arrival $this_arrival
		set max_name $this_name
	    }
	    if {$this_arrival < $min_arrival} {
		set min_arrival $this_arrival
		set min_name $this_name
	    }
	}
      }
    }
   }


    echo "     Latest $clock Arrival to $max_name: $max_arrival"
    echo "     $clock Latency Limit: $latencyLimit "
    set latency_slack [expr $latencyLimit - $max_arrival]
    if { $latency_slack < 0 } {
	echo "     latency slack (VIOLATED):   $latency_slack "
    } else {
	echo "     latency slack (PASS):   $latency_slack "
    }

    set skewValue [expr $max_arrival - $min_arrival]
    echo ""
    echo ""
    echo "       Latest $clock Arrival to $max_name: $max_arrival"
    echo "     Earliest $clock Arrival to $min_name: $min_arrival"
    echo "     $clock Skew Value: $skewValue "
    echo "     $clock Skew Limit: $skewLimit "
    set skew_slack [expr $skewLimit - $skewValue]
    if { $skew_slack < 0 } {
	echo "     skew slack (VIOLATED):   $skew_slack "
    } else {
	echo "     skew slack (PASS):   $skew_slack "
    }
}


proc report_latency_skew_notsp_notep {tp clock startpinlist endpinlist latencyLimit skewLimit } {
    set count 0

    foreach_in_collection my_path $tp {
      set my_p_name2 [get_attr [get_attr $my_path startpoint] full_name]
      set my_p_name1 [get_attr [get_attr $my_path endpoint] full_name]
      #echo "1 $my_p_name2 $my_p_name1"
      foreach_in_collection my_point [get_attribute $my_path points ] {
        set point_name [get_attribute [get_attribute $my_point object] full_name]
        if {[string match $startpinlist $point_name]} {
          set sparrival [get_attr $my_point arrival]
          set spname    $point_name
        }
        if {[string match $endpinlist $point_name]} {
          set eparrival [get_attr $my_point arrival]
          set epname    $point_name
          set this_latency [expr $eparrival - $sparrival]
          echo "        Latency  from $spname to $epname is: $this_latency "

          if {$count == 0} {
              set max_latency  $this_latency 
              set min_latency  $this_latency
              set max_name $epname
              set min_name $epname
              set count 1
          } else {
            if {$this_latency > $max_latency} {
              set max_latency $this_latency
              set max_name $epname
            }
            if {$this_latency <= $min_latency} {
              set min_latency $this_latency
              set min_name $epname
            }
          }
        }
      }
    }


    echo "     Latest $clock Arrival to $max_name: $max_latency"
    echo "     $clock Latency Limit: $latencyLimit "
    set latency_slack [expr $latencyLimit - $max_latency]
    if { $latency_slack < 0 } {
	echo "     latency slack (VIOLATED):   $latency_slack "
    } else {
	echo "     latency slack (PASS):   $latency_slack "
    }

    set skewValue [expr $max_latency - $min_latency]
    echo ""
    echo ""
    echo "       Latest $clock Arrival to $max_name: $max_latency"
    echo "     Earliest $clock Arrival to $min_name: $min_latency"
    echo "     $clock Skew Value: $skewValue "
    echo "     $clock Skew Limit: $skewLimit "
    set skew_slack [expr $skewLimit - $skewValue]
    if { $skew_slack < 0 } {
	echo "     skew slack (VIOLATED):   $skew_slack "
    } else {
	echo "     skew slack (PASS):   $skew_slack "
    }
}


proc report_latency_skew_endpoints {tp clock latencyLimit skewLimit } {
    set count 0

    foreach_in_collection my_path $tp {

	set this_arrival [get_attr $my_path arrival]
	set this_name    [get_attr [get_attr $my_path endpoint] full_name]
        echo "     $this_name $this_arrival"
	if {$count == 0} {
	    set max_arrival  $this_arrival
	    set min_arrival  $this_arrival
	    set max_name $this_name
	    set min_name $this_name
	    set count 1
	} else {
	    if {$this_arrival > $max_arrival} {
		set max_arrival $this_arrival
		set max_name $this_name
	    }
	    if {$this_arrival < $min_arrival} {
		set min_arrival $this_arrival
		set min_name $this_name
	    }
	}
    }


    echo "     Latest $clock Arrival to $max_name: $max_arrival"
    echo "     $clock Latency Limit: $latencyLimit "
    set latency_slack [expr $latencyLimit - $max_arrival]
    if { $latency_slack < 0 } {
	echo "     latency slack (VIOLATED):   $latency_slack "
    } else {
	echo "     latency slack (PASS):   $latency_slack "
    }

    set skewValue [expr $max_arrival - $min_arrival]
    echo ""
    echo ""
    echo "       Latest $clock Arrival to $max_name: $max_arrival"
    echo "     Earliest $clock Arrival to $min_name: $min_arrival"
    echo "     $clock Skew Value: $skewValue "
    echo "     $clock Skew Limit: $skewLimit "
    set skew_slack [expr $skewLimit - $skewValue]
    if { $skew_slack < 0 } {
	echo "     skew slack (VIOLATED):   $skew_slack "
    } else {
	echo "     skew slack (PASS):   $skew_slack "
    }
}

proc report_skew {tp clock skewLimit } {
    set count 0

    foreach_in_collection my_path $tp {

	set this_arrival [get_attr $my_path arrival]
	set this_name    [get_attr [get_attr $my_path endpoint] full_name]
        echo "     $this_name $this_arrival"
	if {$count == 0} {
	    set max_arrival  $this_arrival
	    set min_arrival  $this_arrival
	    set max_name $this_name
	    set min_name $this_name
	    set count 1
	} else {
	    if {$this_arrival > $max_arrival} {
		set max_arrival $this_arrival
		set max_name $this_name
	    }
	    if {$this_arrival < $min_arrival} {
		set min_arrival $this_arrival
		set min_name $this_name
	    }
	}
    }

    set skewValue [expr $max_arrival - $min_arrival]
    echo "       Latest $clock Arrival to $max_name: $max_arrival"
    echo "     Earliest $clock Arrival to $min_name: $min_arrival"
    echo "     $clock Skew Value: $skewValue "
    echo "     $clock Skew Limit: $skewLimit "
    set skew_slack [expr $skewLimit - $skewValue]
    if { $skew_slack < 0 } {
	echo "     skew slack (VIOLATED):   $skew_slack "
    } else {
	echo "     skew slack (PASS):   $skew_slack "
    }
}


proc report_latency {tp clock} {
    set count 0

    foreach_in_collection my_path $tp {

	set this_arrival [get_attr $my_path arrival]
	set this_name    [get_attr [get_attr $my_path endpoint] full_name]
        echo "     $this_name $this_arrival"
	if {$count == 0} {
	    set max_arrival  $this_arrival
	    set min_arrival  $this_arrival
	    set max_name $this_name
	    set min_name $this_name
	    set count 1
	} else {
	    if {$this_arrival > $max_arrival} {
		set max_arrival $this_arrival
		set max_name $this_name
	    }
	    if {$this_arrival < $min_arrival} {
		set min_arrival $this_arrival
		set min_name $this_name
	    }
	}
    }


    echo "       Latest $clock Arrival to $max_name: $max_arrival"
    echo "     Earliest $clock Arrival to $min_name: $min_arrival"
    return "$max_arrival $min_arrival"
}

#-----------------------------------------------------------------------------------
# Checks for occurence of specified warning messages
# Example: check_warn_status <list of warning IDs>
# Returns 1 in a case warnings found; othewise 0
#-----------------------------------------------------------------------------------
proc check_warn_status args {
  set ret_val 0
  foreach mess_id $args { 
    if {[get_message_info -occurrences $mess_id] > 0} {
      set ret_val 1
    }
  }
  return $ret_val
}

#-----------------------------------------------------------------------------------
# Get VDEFINE.v from filelist
#-----------------------------------------------------------------------------------
proc get_VDEFINE_file {filelist} {
  puts "DDR_IP_INFO:  Get dwc_ddrphy_*_VDEFINES.v from synthesis filelist..."

  set IF [open $filelist r]
  while {[gets $IF line] >=0} {
    if {[regexp {dwc_ddrphy.*_VDEFINES.v} $line m ]} {
      set file_name $line
    }
  }
  close $IF
  return $file_name
}
#-----------------------------------------------------------------------------------
# Get premap cells from generic file
#-----------------------------------------------------------------------------------
proc get_premap_modules {premap_file} {
  puts "DDR_IP_INFO:  Get premap modules from ${premap_file}"
  set module_list ""
  set module ""
  set IF [open $premap_file r]
  while {[gets $IF line] >=0} {
    if {[regexp {\mmodule\M[ ]+([^ ]+)[ ]*} $line match name  ]} {
      set module $name
      set module_list [concat $module_list $module]
    }
  }
  close $IF
  return $module_list
}

