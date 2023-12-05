
set clock clk_pll_main

set fout [open ${clock}_skew_scatter.rpt w]

proc skew_of {PATH} {
  set lcl [get_attribute $PATH startpoint_clock_latency]
  set ccl [get_attribute $PATH endpoint_clock_latency]
  set cpp [get_attribute $PATH common_path_pessimism]
  set skew [expr $ccl + $cpp - $lcl]
  #puts "SKEW = $ccl + $cpp - $lcl == $skew"
  return $skew
}

foreach {a b} {
cfc_pd i_ecore/i_epath0/i_vmain1_pd/i_cfc_pd
clk_divider_100 i_clkgen_top_noscan/i_clk_divider_100_pll_main_25
clk_divider_20 i_clkgen_top_noscan/i_clk_divider_20_125_ref
clk_divider_25 i_clkgen_top_noscan/i_clk_divider_25_svc
clk_divider_6 i_clkgen_top_noscan/i_clk_divider_6_div6
clkgen_logic i_clkgen_top_noscan/i_clkgen_logic
everest_top_codec_blk i_everest_top_codec_blk
fuse_wrap i_fuse_wrap
gser_clkrst_x16 i_pcie_phy_top/gsern/cr0
gser_refc_pnr i_pcie_phy_top/gsern/refc_wrap__pnr
host i_ecore/i_host
ms_pd i_ecore/i_epath0/i_vmain2_pd/i_tmus_pd/i_ms_pd
nm_pd i_ecore/i_nm/i_nm_pd_e0
nmc_bmb_pd i_ecore/i_nm/i_nmc_bmb_pd
nw_pd i_ecore/i_nm/i_nw_pd
pad_left_logic i_padring_wrap/i_pad_left/pad_left_logic_inst
pad_mdio_1p2v_logic i_padring_wrap/i_pad_mdio_1p2v/pad_mdio_1p2v_logic_inst
pad_right_logic i_padring_wrap/i_pad_right/pad_right_logic_inst
ps_pd i_ecore/i_epath0/i_vmain1_pd/i_ps_pd
pxp_pd i_ecore/i_epath0/i_vmain2_pd/i_pxp_pd
qm_pd i_ecore/i_epath0/i_vmain1_pd/i_qm_pd
rx_pd i_ecore/i_epath0/i_vmain2_pd/i_rx_pd
sem_pd_core0 i_ecore/i_epath0/i_vmain1_pd/i_sem_pd_core_ps
sem_pd_core1 i_ecore/i_epath0/i_vmain1_pd/i_sem_pd_core_xs
sem_pd_core2 i_ecore/i_epath0/i_vmain1_pd/i_sem_pd_core_ys
sem_pd_core3 i_ecore/i_epath0/i_vmain2_pd/i_tmus_pd/i_sem_pd_core_ms
sem_pd_core4 i_ecore/i_epath0/i_vmain2_pd/i_tmus_pd/i_sem_pd_core_ts
sem_pd_core5 i_ecore/i_epath0/i_vmain2_pd/i_tmus_pd/i_sem_pd_core_us
ts_pd i_ecore/i_epath0/i_vmain2_pd/i_tmus_pd/i_ts_pd
tx_pd i_ecore/i_epath0/i_vmain2_pd/i_tx_pd
us_pd i_ecore/i_epath0/i_vmain2_pd/i_tmus_pd/i_us_pd
xs_pd i_ecore/i_epath0/i_vmain1_pd/i_xs_pd
ys_pd i_ecore/i_epath0/i_vmain1_pd/i_ys_pd
clkgen_top i_clkgen_top_noscan
gsern_e5 i_pcie_phy_top/gsern
gsern_slm i_ms_top/i_ms_gsern_slm_wrap/i_gsern_slm
ms_gsern_slm_wrap i_ms_top/i_ms_gsern_slm_wrap
pad_left i_padring_wrap/i_pad_left
pad_left_pads i_padring_wrap/i_pad_left/pad_left_pads_inst
pad_mdio_1p2v i_padring_wrap/i_pad_mdio_1p2v
pad_mdio_1p2v_pads i_padring_wrap/i_pad_mdio_1p2v/pad_mdio_1p2v_pads_inst
pad_right i_padring_wrap/i_pad_right
pad_right_pads i_padring_wrap/i_pad_right/pad_right_pads_inst
} {
  set ref_of($b) $a
}

proc by_length {A B} {
  if {[string length $B] > [string length $A]} { return 1 } else { return -1 }
}

set refkeys [lsort -command by_length [array names ref_of]]

proc hier_of {OBJ} {
  upvar ref_of ref_of
  upvar refkeys refkeys
  set name [get_object_name $OBJ]
  set result top
  foreach el $refkeys {
    if {[regexp $el $name]} {
      set result $el
      break
    }
  }
  return $result
}

#set paths [gtp -from [get_clocks $clock] -to [get_clocks $clock] -thro i_ecore/i_epath0/i_vmain2_pd/i_rx_pd/i_brb/clk_gate_NIG_INP_SMP_GEN_FOR_0__i_wc_inp_lb_i_m_enffr_out_reg_371__latch/E]
set paths [gtp -from [get_clocks $clock] -to [get_clocks $clock] -max_paths 100000]

array unset skew_of_inst
array unset spep_pair_of
array unset inst_seen
array unset total_count_of
array unset total_skew_of
foreach_in_collection path $paths {
  set skew [format "%0.2f" [skew_of $path]]
  set spskew [expr -1.0 * $skew]
  set sphier [hier_of [get_attribute $path startpoint]]; set inst_seen($sphier) 1
  set ephier [hier_of [get_attribute $path endpoint]]; set inst_seen($ephier) 1
  set fromtokey $sphier:H2H:$ephier
  #puts "$skew $sphier -> $ephier"
  if {![info exists total_count_of($sphier)]} {
    set total_count_of($sphier) 1
    set total_skew_of($sphier) $spskew
  } else {
    incr total_count_of($sphier) 1
    set total_skew_of($sphier) [expr $total_skew_of($sphier) + $spskew]
  }
  if {![info exists total_count_of($ephier)]} {
    set total_count_of($ephier) 1
    set total_skew_of($ephier) $skew
  } else {
    incr total_count_of($ephier) 1
    set total_skew_of($ephier) [expr $total_skew_of($ephier) + $skew]
  }
  if {$sphier != $ephier} {
    foreach key [list $sphier,$clock,$spskew $ephier,$clock,$skew $fromtokey,$clock,$skew] {
      if {![info exists skew_of_inst($key)]} {
        set skew_of_inst($key) 1
        set spep_pair_of($key) "-from [get_object_name [get_attribute $path startpoint]] -to [get_object_name [get_attribute $path endpoint]]"
      } else {
        incr skew_of_inst($key) 1
      }
    }
  }
}

proc multilevel {A B} {
  upvar skew_of_inst skew_of_inst
  set fieldsA [split $A {,}]
  set fieldsB [split $B {,}]
  set hierA  [lindex $fieldsA 0]
  set clockA [lindex $fieldsA 1]
  set skewA  [lindex $fieldsA 2]
  set hierB  [lindex $fieldsB 0]
  set clockB [lindex $fieldsB 1]
  set skewB  [lindex $fieldsB 2]
 
  set ccomp [string compare $clockA $clockB] 
  if {$ccomp == -1} {
    return -1
  } elseif {$ccomp == 1} {
    return 1
  } else {
    set hcomp [string compare $hierA $hierB]
    if {$hcomp == -1} {
      return -1
    } elseif {$hcomp == 1} {
      return 1
    } else {
      if {$skewA > $skewB} {
        return 1
      } else {
        return -1
      }
    }
  }
}

foreach key [lsort -command multilevel [array names skew_of_inst]] {
  set fields [split $key {,}]
  puts $fout "  [format "%6.2f" [lindex $fields 2]] [format "%10i" $skew_of_inst($key)] [format "%-50s" [lindex $fields 0]] [lindex $fields 1] $spep_pair_of($key)"
}

array unset mean_skew_of
foreach el [array names total_skew_of] {
  set mean_skew [format "%5.2f" [expr $total_skew_of($el)/double($total_count_of($el))]]
  set mean_skew_of($el) $mean_skew
}

proc by_skew {A B} {
  upvar mean_skew_of mean_skew_of
  if {$mean_skew_of($A) > $mean_skew_of($B)} {
    return 1
  } else {
    return -1
  }
}

foreach el [lsort -command by_skew [array names mean_skew_of]] {
  puts $fout "$mean_skew_of($el) to $el on $clock ($total_count_of($el) measurements)"
}

close $fout
