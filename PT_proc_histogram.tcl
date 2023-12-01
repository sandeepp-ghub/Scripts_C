
proc proc_histogram {args} {

set version 1.12
set ::timing_save_pin_arrival_and_slack true
#fixed -define_args
#add tns/-paths support
#dont take the below echo, used by proc_compare_qor
echo "\nStarting  Histogram (proc_histogram) $version\n"

parse_proc_arguments -args $args results

set s_flag  [info exists results(-slack_lesser_than)]
set gs_flag [info exists results(-slack_greater_than)]
set path_flag [info exists results(-paths)]
set h_flag [info exists results(-hold)]
set pba_mode "none"

if {[info exists results(-number_of_bins)]} { set numbins $results(-number_of_bins) } else { set numbins 10 }
if {[info exists results(-slack_lesser_than)]} { set slack $results(-slack_lesser_than) } else { set slack 0.0 }
if {[info exists results(-slack_greater_than)]} { set gslack $results(-slack_greater_than) }
if {[info exists results(-hold)]} { set attr "min_slack" ; set delay_type min } else { set attr "max_slack" ; set delay_type max }
if {[info exists results(-number_of_critical_hierarchies)]} { set number $results(-number_of_critical_hierarchies) } else { set number 10 }

if {[info exists results(-pba_mode)]} {
  if {$::synopsys_program_name!="pt_shell"} { echo "Error!! -pba_mode supported only in pt_shell" ; return }
  set pba_mode $results(-pba_mode)
}

if {$gs_flag&&!$s_flag} { echo "Error!! -slack_greater_than can only be used with -slack_lesser_than ....Exiting\n" ; return }
if {$gs_flag&&$gslack>$slack} { echo "Error!! -slack_greater_than should be more than -slack_lesser_than ....Exiting\n" ; return }

if {[info exists results(-clock)]} {
  set clock [get_clocks -quiet $results(-clock)]
  if {[sizeof $clock]!=1} { echo "Error!! provided -clock value did not results in 1 clock" ; return }
  set clock_arg "-clock [get_object_name $clock]"
  set clock_per [get_attr $clock period]
} else {
  set clock_arg ""
}

foreach_in_collection clock [all_clocks] { if {[get_attribute -quiet $clock sources] != "" } { append_to_collection -unique real_clocks $clock } }
set min_period [lindex [lsort -real [get_attr -quiet $real_clocks period]] 0]

catch {redirect -var y {report_units}}
if {[regexp {(\S+)\s+Second} $y match unit]} {
  if {[regexp {e-12} $unit]} { set unit 1000000 } else { set unit 1000 }
} elseif {[regexp {ns} $y]} { set unit 1000
} elseif {[regexp {ps} $y]} { set unit 1000000 }

#if unit cannot be determined make it ns
if {![info exists unit]} { set unit 1000 }

if {[info exists clock_per]} { set min_period $clock_per }
if {$min_period<=0} { echo "Error!! Failed to calculate min_period of real clocks .... Exiting\n" ; return }

if {$path_flag} {

  set paths $results(-paths)
  if {[sizeof $paths]<2} { echo "Error! Not enough -paths [sizeof $paths] given for histogram" ; return }

  set paths [filter_coll $paths "slack!=INFINITY"]
  if {[sizeof $paths]<2} { echo "Error! Not enough -paths [sizeof $paths] with real slack given for histogram" ; return }

  set path_type [lsort -unique [get_attr -quiet $paths path_type]]
  if {[llength $path_type]!=1} { echo "Error! please provide only max paths or min paths - not both" ; return }
  if {$path_type=="min"} { set attr "min_slack" ; set h_flag 1 } else { set attr "max_slack" ; set h_flag 0 }

  echo "Analayzing given [sizeof $paths] path collection - ignores REGOUT\n"
  set coll $paths 
  set endpoint_coll [get_pins -quiet [get_attr -quiet $paths endpoint]]
  if {[sizeof $endpoint_coll]<2} { echo "\nNo Violations or Not enough Violations Found" ; return }
  set check_attr "slack"
}

if {!$path_flag} {

  if {$pba_mode =="none"} 		{ set type "GBA"
  } elseif {$pba_mode =="path"} 		{ set type "PBA Path"
  } elseif {$pba_mode =="exhaustive"} 	{ set type "PBA Exhaustive"
  }

  if {$gs_flag} {
    echo -n "Acquiring $type Endpoints ($gslack > Slack < $slack) - ignores REGOUT ... "
  } else {
    echo -n "Acquiring $type Endpoints (Slack < $slack) - ignores REGOUT ... "
  }

  set coll   [sort_coll [filter_coll [eval all_registers -data_pins $clock_arg] "$attr<$slack"] $attr]
  if {$gs_flag} { set coll [sort_coll [filter_coll $coll "$attr>$gslack"] $attr] }

  if {[sizeof $coll]<2} { echo "\nNo Violations or Not enough Violations Found" ; return }
  set endpoint_coll $coll

  if {$pba_mode!="none"} {
    set check_attr "slack"
    if {$gs_flag} {
      redirect /dev/null {set coll [get_timing_path -to $coll -pba_mode $pba_mode -max_paths [sizeof $coll] -slack_lesser $slack -slack_greater $gslack -delay_type $delay_type] }
      set endpoint_coll [get_attr -quiet $coll endpoint]
    } else {
      redirect /dev/null {set coll [get_timing_path -to $coll -pba_mode $pba_mode -max_paths [sizeof $coll] -slack_lesser $slack -delay_type $delay_type] }
      set endpoint_coll [get_attr -quiet $coll endpoint]
    }
  } else {
    set check_attr $attr
  }

  echo "Done\n"
}

if {[sizeof $coll]<2} { echo "\nNo Violations or Not enough Violations Found" ; return }

echo -n "Initializing Histogram ... "
set values [lsort -real [get_attr -quiet $coll $check_attr]]
set min    [lindex $values 0]
set max    [lindex $values [expr {[llength $values]-1}]]
set new_max    [expr $max+0.1] ; # to avoid rounding errors
set range  [expr {$max-$min}]
set width  [expr {$range/$numbins}]

for {set i 1} {$i<=$numbins} {incr i} { 
  set compare($i) [expr {$min+$i*$width}] 
  set histogram($i) 0
  set tns_histogram($i) 0
}
set compare($i) $new_max

echo -n "Populating Bins ... "
foreach v $values {
  for {set i 1} {$i<=$numbins} {incr i} {
    if {$v<=$compare($i)} {
      incr histogram($i)
      if {$v<0} { set tns_histogram($i) [expr {$tns_histogram($i)+$v}] }
      break
    }
  }
}
echo "Done - TNS can be slightly off\n"

set tot_tns 0
for {set i 1} {$i<=$numbins} {incr i} { set tot_tns [expr $tot_tns+$tns_histogram($i)] }

echo "========================================================================="
echo "          WNS RANGE        -          Endpoints                       TNS"
echo "========================================================================="
if {[llength $values]>1} {
  for {set i $numbins} {$i>=1} {incr i -1} {
    set low [expr {$min+$i*$width}]
    set high [expr {$min+($i-1)*$width}]
    set f_low [format %.3f $low]
    set f_high [format %.3f $high]
    set pct [expr {100.0*$histogram($i)/[llength $values]}]
    echo -n "[format "% 10s" $f_low] to [format "% 10s" $f_high]   -  [format %9i $histogram($i)] ([format %4.1f $pct]%)"
    if {$attr=="max_slack"} {
      if {[expr {($min_period-$high)*$unit}]>0} { set freq [expr {(1.0/($min_period-$high))*$unit}] } else { set freq 0.0 }
      echo -n " - [format %4.0f ${freq}]Mhz"
    }
    if {$h_flag} { echo " [format "% 25.1f" $tns_histogram($i)]" } else { echo " [format "% 15.1f" $tns_histogram($i)]" }
  }
}
echo "========================================================================="
echo "Total Endpoints            - [format %10i [llength $values]] [format "% 33.1f" $tot_tns]"
if {$attr=="max_slack"} { echo "Clock Frequency            - [format %10.0f [expr (1.0/$min_period)*$unit]]Mhz (estimated)" }
echo "========================================================================="
echo ""

if {$::synopsys_program_name=="icc2_shell"||$::synopsys_program_name=="pt_shell"} {
  set allicgs [get_cells -quiet -hi -f "is_hierarchical==false&&is_integrated_clock_gating_cell==true"]
} else {
  set allicgs [get_cells -quiet -hi -f "is_hierarchical==false&&clock_gating_integrated_cell=~*"]
}
set slkff [remove_from_coll [get_cells -quiet -of $endpoint_coll] $allicgs]

foreach c [get_attr -quiet $slkff full_name] {
  set cell $c
  for {set i 1} {$i<20} {incr i} {
    set parent [file dir $cell]
    if {$parent=="."} { break }
    set parent_coll [get_cells -quiet $parent -f "is_hierarchical==true"]
    if {[sizeof $parent_coll]<1} { set cell $parent ; continue }
    if {[info exists hier_repeat($parent)]} { incr hier_repeat($parent) } else { set hier_repeat($parent) 1 }
    set cell $parent
  }
}

echo "========================================================================="
echo " Viol.   $number Critical"
echo " Count - Hierarchies - ignores ICGs"
echo "========================================================================="

if {![array exists hier_repeat]} { echo "No Critial Hierarchies found" ; return }

foreach {a b} [array get hier_repeat] { lappend repeat_list [list $a $b] }

set cnt 0
foreach i [lsort -real -decreasing -index 1 $repeat_list] { 
  echo "[format %6i [lindex $i 1]] - [lindex $i 0]" 
  incr cnt
  if {$cnt==$number} { break }
}
echo "========================================================================="
echo ""

}

define_proc_attributes proc_histogram -info "USER_PROC: Prints histogram of setup or hold slack endpoints" \
  -define_args { \
  {-number_of_bins      "Optional - number of bins for histgram, default 10"			"<int>"               int  optional}
  {-slack_lesser_than   "Optional - histogram for endpoints with slack less than, default 0" 	"<float>"               float  optional}
  {-slack_greater_than  "Optional - histogram for endpoints with slack greater than, can only be used with -slack_greater_than, default wns" 	"<float>"               float  optional}
  {-hold		"Optional - Generates histogram for hold slack, default is setup"	""                      boolean  optional}
  {-number_of_critical_hierarchies      "Optional - number of critical hierarchies to display viol. count, default 10" "<int>" int  optional}
  {-clock      		"Optional - Generates histogram only for the specified clock endpoints, default all clocks" "<clock>" string  optional}
  {-pba_mode 		"Optional - PBA mode supported in PrimeTime only" "<path or exhaustive>" one_of_string {optional value_help {values {path exhaustive}}}}
  {-paths 		"Optional - Generates histogram for given user path collection" "<path coll>" string optional}
}


