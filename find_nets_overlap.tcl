
set domain_checking_for_feedthru wdt0_inst_DW_wdt_dcls_core1_safetyGroup
set domain_used_as_feedthru axi_dmac_inst_axi_dmac_axi_dmac_U_DW_axi_dmac_shdw_safetyGroup


proc getNetPDOverlap {pNet pPdPtr} {
  set pdBoxLst [getObjFPlanBoxList Group  $pPdPtr]

  set overlapLen 0
  dbForEachNetWire $pNet wire {
    # this is via
    if {![dbIsWireHor $wire] && ![dbIsWireVer $wire]} continue

    set wireBox [dbWireBox $wire]
    set wire_ll_x [dbDBUToMicrons [lindex $wireBox 0]]
    set wire_ll_y [dbDBUToMicrons [lindex $wireBox 1]]
    set wire_ur_x [dbDBUToMicrons [lindex $wireBox 2]]
    set wire_ur_y [dbDBUToMicrons [lindex $wireBox 3]]

    for {set i 0} {$i < [llength $pdBoxLst]} {incr i} {
      set pd_ll_x [lindex $pdBoxLst $i]
      incr i
      set pd_ll_y [lindex $pdBoxLst $i]
      incr i
      set pd_ur_x [lindex $pdBoxLst $i]
      incr i
      set pd_ur_y [lindex $pdBoxLst $i]
      if {($wire_ur_x <= $pd_ll_x) || ($wire_ll_x >= $pd_ur_x) || ($wire_ur_y <= $pd_ll_y) || ($wire_ll_y >= $pd_ur_y)} {
        # no overlap
        continue
      } elseif {[dbIsWireHor $wire]} {
        if {$wire_ll_x > $pd_ll_x} {
          set ll_x $wire_ll_x
        } else {
          set ll_x $pd_ll_x
        }
        if {$wire_ur_x > $pd_ur_x} {
          set ur_x $pd_ur_x
        } else {
          set ur_x $wire_ur_x
        }
        set overlapLen [expr $overlapLen + $ur_x - $ll_x]
      } else {
        if {$wire_ll_y > $pd_ll_y} {
          set ll_y $wire_ll_y
        } else {
          set ll_y $pd_ll_y
        }
        if {$wire_ur_y > $pd_ur_y} {
          set ur_y $pd_ur_y
        } else {
          set ur_y $wire_ur_y
        }
        set overlapLen [expr $overlapLen + $ur_y - $ll_y]
      }
    }
  }
  return $overlapLen
}


set flag_not_feedthru 0 
deselectAll 

dbForEachCellNet [dbgTopCell] netPtr {
  set net [dbNetName $netPtr] 
  set flag_pwr [ dbIsNetPwrOrGnd $net ]
  if { $flag_pwr != 1 } {
    dbForEachNetTerm [dbGetNetByName $net] term_ptr {
      if { [dbIsObjTerm $term_ptr] == 1 } {
        set term_name [dbTermName $term_ptr] 
        set term_inst_name [ dbTermInstName $term_ptr ]
        set pd_name [ getTermPowerDomain $term_inst_name/$term_name ]
        if { $pd_name == "$domain_used_as_feedthru" } {
          set flag_not_feedthru 1 
          continue 

        }
      }
    }
  }
  if { $flag_not_feedthru == 0 } {
    set length [getNetPDOverlap $net $domain_used_as_feedthru ]
    if { $length > 0 } {
      Puts "$net has feedthrough as $length "
      selectNet $net
    }
  }
  set flag_not_feedthru 0
}
 
