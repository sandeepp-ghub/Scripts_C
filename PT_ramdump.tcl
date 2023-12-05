
if {1} {

set files [glob /nfs/bigdisk01/stdcells/mem_verif/2017_0723_enable_sec_cvm_pvts/verif_genmem_edits/e5/comp_mem/db/*.db]

array unset seen
foreach file $files {
  if {[regexp {^(.*?)_(ss|ff|nn)} [lindex [file split $file] end] match type corner]}  {
    set seen($type) 1
  }
}

set all_cells {}
foreach el [lsort [array names seen]] {
  puts "Adding cells of type: $el"
  set all_cells [add_to_collection $all_cells [get_cells -hier -filter "ref_name==$el"]]
}

}

set fout [open dump_${run_type_specific}_[tstamp].rpt w]
foreach_in_collection cell [sort_collection $all_cells full_name] {
  set pins [get_pins -of $cell -filter "defined(min_slack) || defined(max_slack)"]
  #puts "[sizeof_collection $pins] [get_object_name $cell]"
  foreach_in_collection pin $pins {
    puts $fout "[get_object_name $pin],[get_attribute $pin min_slack],[get_attribute $pin max_slack]"
  }
}
close $fout
