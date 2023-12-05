set si_enable_analysis false
reset_timing_derate [get_cells -hier]
reset_timing_derate [get_nets -hier]
set_timing_derate 1.0 -early [get_nets -hier *]
set_timing_derate 1.0 -late  [get_nets -hier *]

reset_timing_derate [get_lib_cells */*]
reset_timing_derate [current_design]

suppress_message {RC-004 SDF-036 RC-009}
write_sdf -version 3.0 -include {SETUPHOLD RECREM edge_specific_preset_clear} ${TOP}_raw_${run_type_specific}.sdf30
unsuppress_message {RC-004 SDF-036 RC-009}

#eval exec {sed \"s/infinity::infinity/0.14::0.14/g;w everest_raw_noinf.sdf\" everest_raw.sdf}
#eval exec {gzip everest_raw_noinf.sdf}
#mmw SDF READY TO PROCESS [pwd]

  array unset seen
  set seen(${TOP}_raw_${run_type_specific}.sdf30) 1
  foreach block $pnr_blks {
    set fn inp/pnr/$block/${block}.v
    if {[file exists $fn]} {
      file copy $fn .
      set seen($fn) 1
    }
  }  
  foreach block $phys_partitions {
    foreach rft {phys routes routes_dcap} {
      set fn inp/router/$block/${block}_${rft}.v
      if {[file exists $fn] && ![file exists ./[lindex [file split $fn] end]]} {
        file copy $fn .
      }
      set seen($fn) 1
    }
  }

  set fout [open tar_sdf_verilog_${run_type_specific}.scr w]
  puts $fout "tar cvfhz sdf_verilog_${run_type_specific}.tgz \\"
  foreach fn [lsort [array names seen]] {
    puts $fout "  $fn \\"
  }
  puts $fout ""
  puts $fout ""
  close $fout
  file attributes ./tar_sdf_verilog_${run_type_specific}.scr -permissions 0755
  eval exec ./tar_sdf_verilog_${run_type_specific}.scr
