if {[llength $phys_partitions] > 0} {
  puts "ERROR: There are Stega partitions in this design.  Results will be unpredictable and may not be produced AT ALL."
}

array unset seen_lef
array unset seen_def
unset -nocomplain tech_lef
set lef_files {}
set def_files {}

echo {
VERSION 5.8 ;
BUSBITCHARS "[]"  ;
DIVIDERCHAR "/" ;

SITE unit
  CLASS CORE ;
  SIZE 0.084 BY 0.576 ;
  SYMMETRY Y ;
END unit

END LIBRARY
} > unit.lef

foreach blk $pnr_blks {
  puts "INFO: Processing $blk references..."
  set lef_ref inp/pnr/$blk/${blk}.lef_ref
  set seen_def($blk) inp/pnr/$blk/$blk.def.gz
  set fin [open $lef_ref r]
  while {[gets $fin line] >= 0} {
    set fields [split $line]
    foreach field $fields {
      if {[file exists $field]} {
        set localfile [lindex [file split $field] end]
        if {![info exists seen_lef($localfile)]} {
          if {[regexp -nocase _tech.lef $localfile]} {
            if {![info exists tech_lef]} {
              puts "INFO: Initializing tech lef to $field"
              set tech_lef $field
            } elseif {$field == $tech_lef} {
              #puts "INFO: Tech file is the same."
            } elseif {[file mtime $field] > [file mtime $tech_lef]} {
              puts "INFO: Updating tech lef to $field"
              set tech_lef $field
            }
          } else {
            set seen_lef($localfile) $field
          }
        } elseif {$field == $seen_lef($localfile)} {
          #puts "INFO: Same file encountered for $localfile: $field"
        } else {
          if {[file mtime $field] > [file mtime $seen_lef($localfile)]} {
            #VERY COMMON: puts "WARNING: $field is newer than $seen_lef($localfile)... updating the master list to the newer file."
            set seen_lef($localfile) $field
          }
        }
      }
    }
  }
  close $fin
}

foreach blk $grout_partitions {
  puts "INFO: Processing $blk references..."
  set def_fn ${blk}.def.gz
  set seen_def($blk) inp/grout/$blk/$def_fn
  #foreach subblkf [glob -nocomplain inp/grout/$blk/defs/*.def.gz]
  foreach subblkf [glob -nocomplain inp/grout/$blk/defs/*.def.gz] {
    set localfile [lindex [file split $subblkf] end]
    if {[regexp {(\S+).def.gz} $localfile match subname]} {
      if {[file exists $subblkf]} {
        if {![info exists seen_def($subname)]} {
          set seen_def($subname) $subblkf
        } elseif {$subblkf == $seen_def($subname)} {
          puts "INFO: Same file encountered for $localfile: $subblkf"
        } else {
          if {[file mtime $subblkf] > [file mtime $seen_def($subname)]} {
            puts "WARNING: $subblkf is newer than $seen_def($subname)... updating the master list to the newer file."
            set seen_def($subname) $subblkf
          }
        }
      }
    }
  }
}

foreach key [array names seen_lef] { lappend lef_files $seen_lef($key) }
foreach key [array names seen_def] {
  if {![regexp POWERONRESET $key]} {
    lappend def_files $seen_def($key)
  } else {
    puts "INFO: Skipping DEF file for $key ($seen_def($key))"
  }
}
set lef_files [concat [list $tech_lef unit.lef] [lsort $lef_files]]
set def_files [lsort $def_files]

#puts "set_eco_options -physical_tech_lib_path \$tech_lef -physical_lib_path \$lef_files -physical_design_path \$def_files"
puts "reset_eco_options"
puts "set_eco_options -physical_lib_path \$lef_files -physical_design_path \$def_files"
puts "fix_eco_drc -type max_transition -methods {size_cell insert_buffer} -physical_mode open_site -buffer_list BUFH_X8N_A9PP84TL_C14"

if {0} {
 set_eco_options      # Set ECO configuration information
   [-physical_tech_lib_path list]
                          (Specify the Physical Technology Library Exchange Format (LEF) files)
   [-physical_lib_path list]
                          (Specify the list of Physical Cell Library Exchange Format (LEF) files)
   [-physical_design_path list]
                          (Specify the list of Physical Design Exchange Format (DEF) files)
}
