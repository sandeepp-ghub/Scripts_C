if {0} {
core_pll_top
gser_com_pll_custom
gser_pll25_custom
pll_interface
}

#5: gser_com_pll_custom_ss_0p800v_0p800v_100c_ss_0p800v_0p800v_100c_sigrcmax_100c_1_late/gser_com_pll_custom
#17: gser_pll25_custom_ss_0p800v_0p800v_100c_ss_0p800v_0p800v_100c_sigrcmax_100c_1_late/gser_pll25_custom

if {0} {
foreach_in_collection lc [get_lib_cells {*/HS56GBF01}] {
  puts ""
  puts "INSTANCES OF [get_attribute $lc base_name]:"
  foreach_in_collection c [get_cells -of $lc] {
    puts ""
    puts "  INST:[get_object_name $c] ([get_attribute $c ref_name])"
    set clkps [get_pins -quiet -of $c -filter "defined(clocks)"]
    if {[sizeof_collection $clkps] > 0} {
      foreach_in_collection p [get_pins -of $c -filter "defined(clocks)"] {
        puts "    PIN:[get_attribute $p lib_pin_name]  DIR:[get_attribute $p direction] CLOCKS:[get_object_name [get_attribute $p clocks]]"
      }
    } else {
      puts "    ERROR: NO pins with clocks on this instance."
    }
  }
}
}
if {1} {
array unset clocks_of
set hiers {i_ecore/i_nm/i_nw_pd i_ecore/i_nm/i_nmc_bmb_pd/i_nmc_pd i_ecore/i_nm/i_nw_pd/i_rbc_clk_nws i_ms_top/i_ms_gsern_slm_wrap/i_gsern_slm}
set hiers {i_ecore/i_nm/i_nmc_bmb_pd i_ms_top/i_ms_gsern_slm_wrap/i_gsern_slm i_pcie_phy_top/gsern}
set hiers i_ecore/i_host
foreach_in_collection c [get_cells $hiers] {
    puts ""
    puts "  INST:[get_object_name $c] ([get_attribute $c ref_name]):"
    # (driver of clk == [get_object_name [all_fanin -start -flat -to [get_object_name $c]/clk]])
    #set clkps [get_pins -quiet -of $c -filter "defined(clocks)"]
    set hpins [sort_collection [get_pins -quiet -of $c] direction]
    set hpins_with_clks {}
    foreach_in_collection hpin $hpins {
      set dr [get_pins -quiet -leaf -of [get_nets -quiet -of $hpin] -filter "direction==out"]
      set drclks [get_attribute -quiet $dr clocks]
      if {[sizeof_collection $drclks] > 0} {
        set clocks_of([get_object_name $hpin]) [get_object_name $drclks]
        set hpins_with_clks [add_to_collection $hpins_with_clks $hpin]
      }
    }
    if {[sizeof_collection $hpins_with_clks] > 0} {
      set abuf_count 0
      foreach_in_collection p [sort_collection $hpins_with_clks full_name] {
        set hname [get_object_name $p]
        if {[regexp {(^p_abuf|^cts)} [get_attribute $p lib_pin_name]]} {
          incr abuf_count 1
        } else {
          puts "    PIN:[get_attribute $p lib_pin_name]  DIR:[get_attribute $p direction]  CLOCKS:$clocks_of($hname)"
        }
      }
      puts "    p_abuf pins with clocks: $abuf_count"
    } else {
      puts "    ERROR: NO pins with clocks on this instance."
    }
}
}
