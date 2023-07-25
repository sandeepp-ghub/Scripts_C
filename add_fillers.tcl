#delete padding
  mCmd delete_all_cell_padding
  #delete prefilled fillers
  mCmd delete_filler -prefix FILLER
  mCmd delete_filler -prefix EDI_FILL
#### GA cell fillers
 
 set gafiller ""
  if {[mVar -exist LIBCELL(gafiller)] && ([mVar LIBCELL(gafiller)] ne "")} {
    foreach c [mVar LIBCELL(gafiller)] {
      set fs [get_db base_cells .base_name $c -u]
      foreach f $fs {
        if {[lsearch -exact $gafiller $f] ne "-1"} continue
        set gafiller [concat $gafiller $f]
      }
    }
  } else {
    #Do Nothing. Not setting any default GAFILL cells
  }

#### DECAP fillers
  set dcapCell ""

  if {[mVar -exist LIBCELL(metfiller)] && ([mVar LIBCELL(metfiller)] ne "")} {
    foreach c [mVar LIBCELL(metfiller)] {
      set fs [get_db base_cells .base_name $c -u]
      foreach f $fs {
        if {[lsearch -exact $dcapCell $f] ne "-1"} continue
        set dcapCell [concat $dcapCell $f]
      }
    }
  } else {
    if { [encIsTechNode -tech 3nm]} {
      set svtdcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*CPDSVT -u]]"
      set lvtlldcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*CPDLVTLL -u]]"
      set lvtdcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*CPDLVT -u]]"
      set ulvtlldcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*CPDULVTLL -u]]"
      set ulvtdcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*CPDULVT -u]]"
      set elvtdcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*CPDELVT -u]]"
      set dcapCell "$svtdcap $lvtlldcap $lvtdcap $ulvtlldcap $ulvtdcap $elvtdcap"
    } elseif {[encIsTechNode -tech 5nm]} {
      set svtdcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*CNODSVT -u]]"
      set lvtlldcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*CNODLVTLL -u]]"
      set lvtdcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*CNODLVT -u]]"
      set ulvtlldcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*CNODULVTLL -u]]"
      set ulvtdcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*CNODULVT -u]]"
      set elvtdcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*CNODELVT -u]]"
      set dcapCell "$svtdcap $lvtlldcap $lvtdcap $ulvtlldcap $ulvtdcap $elvtdcap"
    } elseif {[encIsTechNode -tech 7nm]} {
      set svtdcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*PDSVT -u]]"
      set lvtdcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*PDLVT -u]]"
      set ulvtdcap "[lsort -dict -decreas  [get_db base_cells .name DCAP*PDULVT -u]]"
      set dcapCell "$svtdcap $lvtdcap $ulvtdcap"
    }
  }

#### std cell fillers 
  set filler ""
  if {[mVar -exist LIBCELL(filler)] && ([mVar LIBCELL(filler)] ne "")} {
    set filler ""
    foreach c [mVar LIBCELL(filler)] {
      set fs [get_db base_cells .base_name $c -u]
      foreach f $fs {
        if {[lsearch -exact $filler $f] ne "-1"} continue
        set filler [concat $filler $f]
      }
    }
  } else {
    if {[encIsTechNode -tech 3nm]} {
      set svtfiller "[lsort -dict -decreas  [get_db [get_db base_cells FILL*CPDSVT -u ] .name -invert *WALL*]]"
      set lvtllfiller "[lsort -dict -decreas  [get_db [get_db base_cells FILL*CPDLVTLL -u] .name -invert *WALL*]]"
      set lvtfiller "[lsort -dict -decreas  [get_db [get_db base_cells FILL*CPDLVT -u ] .name -invert *WALL*]]"
      set ulvtllfiller "[lsort -dict -decreas  [get_db [get_db base_cells FILL*CPDULVTLL -u ] .name -invert *WALL*]]"
      set ulvtfiller "[lsort -dict -decreas  [get_db [get_db base_cells FILL*CPDULVT -u] .name -invert *WALL*]]"
      set elvtfiller "[lsort -dict -decreas  [get_db [get_db base_cells FILL*CPDELVT -u ] .name -invert *WALL*]]"
      set filler "$svtfiller $lvtllfiller $lvtfiller $ulvtllfiller $ulvtfiller $elvtfiller"
    } elseif {[encIsTechNode -tech 5nm]} {
      set svtfiller "[lsort -dict -decreas  [get_db [get_db base_cells FILL*CNODSVT -u ] .name -invert *NOBCM*]]"
      set lvtllfiller "[lsort -dict -decreas  [get_db [get_db base_cells FILL*CNODLVTLL -u] .name -invert *NOBCM*]]"
      set lvtfiller "[lsort -dict -decreas  [get_db [get_db base_cells FILL*CNODLVT -u ] .name -invert *NOBCM*]]"
      set ulvtllfiller "[lsort -dict -decreas  [get_db [get_db base_cells FILL*CNODULVTLL -u ] .name -invert *NOBCM*]]"
      set ulvtfiller "[lsort -dict -decreas  [get_db [get_db base_cells FILL*CNODULVT -u] .name -invert *NOBCM*]]"
      set elvtfiller "[lsort -dict -decreas  [get_db [get_db base_cells FILL*CNODELVT -u ] .name -invert *NOBCM*]]"
      set filler "$svtfiller $lvtllfiller $lvtfiller $ulvtllfiller $ulvtfiller $elvtfiller"
    } elseif {[encIsTechNode -tech 7nm]} {
      set svtfiller "[lsort -dict -decreas  [get_db -e [get_db base_cells  FILL*PDSVT -u ] .name -invert *NOBCM*]]"
      set lvtfiller "[lsort -dict -decreas  [get_db -e [get_db base_cells  FILL*PDLVT -u ] .name -invert *NOBCM*]]"
      set ulvtfiller "[lsort -dict -decreas  [get_db -e [get_db base_cells  FILL*PDULVT -u] .name -invert *NOBCM*]]"
      set filler "$svtfiller $lvtfiller $ulvtfiller"
    }
  }
  
###### setting virtual align constraints to align pins of g lofic cell after swapping G filler/decap to a G logic cel.
  if {[encIsTechNode -tech 5nm]} {
    if {[mVar -exist MTECH(cell_track) ] && [mVar MTECH(cell_track)] eq "H280"} {
      if {[info exists gafiller] && ($gafiller ne "")} {
        set_cell_virtual_align -mask 2 -pin_x_location 0.0285 -cells $gafiller
      }
    } elseif {[mVar MTECH(cell_track)] eq "H210"}  {
      if {[info exists gafiller] && ($gafiller ne "")} {
        set_cell_virtual_align -mask 2 -pin_x_location 0.0255 -cells $gafiller
      }
    }
  }

##### setting to swap pair of same FILL1s to pair of FILL1 and FILL1NOBCM
  if {[encIsTechNode -tech 5nm] || [encIsTechNode -tech 7nm]} {
    set design [mVar DESIGN]
    if {[llength [get_db base_cells FILL*]]} {
      mInfo "Setting up for swapping of TSMC FILL1 cells"
      if {[mVar -exist MTECH(cell_track) ] && [mVar MTECH(cell_track)] eq "H280"} {
        set pat_cur FILL1KABWP*
        set pat_swap FILL1NOBCMKABWP*
      } else {
        set pat_cur FILL1BWP*
        set pat_swap FILL1NOBCMBWP*
      }
    } elseif {[llength [get_db base_cells *VT*_FILL*]]} {
      mInfo "Setting up for swapping of SYNOPSYS FILL1 cells"
      #synopsys std cells
      set pat_cur *_FILL1
      set pat_swap *_FILL_MVT_1
    } else {
      mError "Unknown std cell library. Skipping setting up swapping of FILL1 cells"
    }
    set replaceList ""
    foreach cell [get_db [get_db base_cells $pat_cur] .name -invert *NOBCM*] {
      set from_filler $cell
      set to_filler [string map "[join [split $pat_cur *] ""] [join [split $pat_swap *] ""]" $cell]
      lappend replaceList "$from_filler $to_filler"
    }
    mCmd set_db add_fillers_swap_cell "$replaceList"
  }

  mInfo "Starting dcap insertion..."
  mCmd set_db add_fillers_cells "$gafiller $dcapCell $filler"
  #mCmd add_fillers -prefix EDI_FILL 
  mCmd add_fillers
