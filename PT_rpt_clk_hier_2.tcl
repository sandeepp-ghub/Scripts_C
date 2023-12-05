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
