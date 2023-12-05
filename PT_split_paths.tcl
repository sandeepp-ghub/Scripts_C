set check_clks {sclk all}
set print_travel false ; # only use this if you load locations for your partition
set inter_only true ; # only dump interblock paths when set to true
unset -nocomplain slack_less
array unset slack_less
set slack_less(max) -0.100
set slack_less(min) -0.003

set skip_blocks {
gser_com_roc
gser_lane_roc
gsern_qlm_roc
gser_clkrst_x4
gser_com_ls_shim
gser_com_pnr_roc
gser_lane_ls_shim
gser_lane_pnr_roc
gser_pll_pnr
gser_refc_pnr
gser_rx_cdr_pnr
gser_rx_os_pnr_deser
gser_rx_trim_pnr_deser
}
######################################################
######################################################

array unset slack_of

proc tstamp {} {
  return [clock format [clock seconds] -format %m_%d_%H_%M]
}

set ts [tstamp]
set ts ${TOP}_[get_top_version]
if {$timing_all_clocks_propagated} {
  set ts "${ts}_prop"
} else {
  set ts "${ts}_ideal"
}

set split_pats {}
array unset ref_of
foreach part [concat $pnr_blks $phys_partitions $grout_partitions] {
  if {[lsearch -exact $skip_blocks $part] < 0} {
    set cells [get_cells -quiet -hier -filter "ref_name=~$part"]
    set celln [sizeof_collection $cells]
    if {$celln == 1} { set cellidx {} } else { set cellidx 0 }
    foreach_in_collection cell $cells {
      set name [get_object_name $cell]
      set digits [regexp -all -inline {\d+} $name]
      if {$digits != ""} { set digits [join $digits _] }
      set rrefname [get_attribute $cell ref_name]
      set split_pats [concat $split_pats $name]
      if {$celln > 1} {
        if {$digits != ""} {
          set ref_of($name) ${rrefname}_$digits
        } else {
          set ref_of($name) ${rrefname}${cellidx}
        }
        incr cellidx 1
      } else {
        set ref_of($name) $rrefname
      }
      puts "INFO: $part : $name (id = $ref_of($name))"
    }
  }
}
proc by_length {A B} {
  if {[string length $B] > [string length $A]} { return 1 } else { return -1 }
}
set split_pats [lsort -command by_length $split_pats]

foreach check_clk $check_clks {

    regsub -all {/} $check_clk {_} dir_friendly

    set split_dir split_results_${dir_friendly}_${run_type_specific}_$ts
    file delete -force $split_dir
    file mkdir $split_dir
    file mkdir $split_dir/intra

    set ref_of(top) top
    foreach ref [array names ref_of] {
	for {set sb 0.0} {$sb <= -2.0} {incr $sb -0.1} {
	    set key $ref,$sb
	    set slack_of($key) 0
	}
    }
    if {$check_clk != "all"} {
	set paths [get_timing_paths -delay $run_type -slack_less $slack_less($run_type) -max_paths 100000 -include -from [get_clocks $check_clk] -to [get_clocks $check_clk]]
    } else {
	set paths [get_timing_paths -delay $run_type -slack_less $slack_less($run_type) -max_paths 100000 -include]
    }
    foreach_in_collection path $paths {
	set sppat top
	set eppat top
	set last $path
	set sp [get_object_name [get_attribute $path startpoint]]
	set ep [get_object_name [get_attribute $path endpoint]]
	foreach pat $split_pats {
	    if {[regexp "^$pat" $ep]} {
		set eppat $pat
		break
	    }
	}
	foreach pat $split_pats {
	    if {[regexp "^$pat" $sp]} {
		set sppat $pat
		break
	    }
	}
	if {$sppat != $eppat || ! $inter_only} {
	    set slack [format "%0.1f" [get_attribute $path slack]]
	    if {$slack < -2.0} {set slack -2.0}
	    if {$sppat == $eppat} {
		set fn $split_dir/intra/$ref_of($sppat).rpt
	    } else {
		set fn $split_dir/$ref_of($sppat)_____$ref_of($eppat).rpt
	    }
	    set binkey $ref_of($eppat),$slack
	    incr slack_of($binkey) 1
	    report_timing -nosplit $path >> $fn
	    if {$print_travel} {
		set travel [path_travel $path]
		echo "TRAVEL: $travel" >> $fn
	    }
	    echo "" >> $fn
	}
    }

}

proc by_hier {A B} {
  set fa [split $A {,}]
  set ha [lindex $fa 0]
  set sa [lindex $fa 1]
  set fb [split $B {,}]
  set hb [lindex $fb 0]
  set sb [lindex $fb 1]
  if {$fb < $fa} {
    return 1
  } elseif {$fa < $fb} {
    return -1
  } else {
    if {$sa < $sb} {
      return 1
    } else {
      return -1
    }
  }
}

set last_ref null
set fout [open histogram.rpt w]
foreach key [lsort -command by_hier [array names slack_of]] {
  set fields [split $key {,}]
  set ref [lindex $fields 0]
  if {$last_ref != $ref} {
    puts $fout "\nVIOLATIONS INSIDE $ref:"
    set last_ref $ref
  }
  set slack [lindex $fields 1]
  puts $fout "$slack [format "%10i" $slack_of($key)] $ref"
}
close $fout
