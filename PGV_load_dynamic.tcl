#! /bin/csh -f
../../tools/projflow/pgv/script/chn3app2 voltus@21.13-s102_1 -sgq normal -sgm 64 -sgc 4 -wait 10000  -log top_interactive.log

source top.setup
set_distribute_host -local;
set_multi_cpu_usage -localCpu 32;
read_lib     $lib_list
read_lib     -lef $lef_list
read_verilog $vg_list
set_top_module -ignore_undefined_cell dmc
read_def      $def_list
read_power_rail_results -rail_directory adsRail/dmc_105C_dynamic_1/
read_power_rail_results -power_db adsPower/power.db
#start_gui
