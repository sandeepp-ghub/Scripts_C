##################################################################
# header file to be source with all of my icc procs              #
#                                                                #
# lior allerhand                                                 #
# 5/11/12                                                        #
##################################################################

######################################################
# print stuff                                        # 
######################################################
# my print collection (pc)
source ~/scripts/icc/my_print_collection.tcl
# my print pin (pp)
source ~/scripts/icc/my_print_pins.tcl
# my print port direction (ppd)
source ~/scripts/icc/my_print_port_direction.tcl
# my print list (pl)
source ~/scripts/icc/my_print_list.tcl
# get_full lib as a collection. get cell name (glib)
source ~/scripts/icc/my_get_lib.tcl
# wrap proc for all_fanin/out return ports rams regs cells start from pin or cell
source ~/scripts/icc/look_one_level_up.tcl
######################################################
# reports                                            # 
######################################################
# give slack summary info
source ~/scripts/icc/report_design_slack_information.tcl
# report macro to macro relation
source ~/scripts/icc/soc_report_macro_relation.tcl
# report macro port relation
source ~/scripts/icc/soc_report_macro_port_relation.tcl
# summary report for worst path foreach group
source ~/scripts/icc/report_worst_path_foreach_group.tcl
# summary report of cross clock paths 
source ~/scripts/icc/report_cross_clocks_slack.tcl
# summary report same format as report_timing
source ~/scripts/icc/report_summary.tcl
# Eyals report utilization 
source /nfs/pt/store/areas/prj_supp_aman_il/eyald/tcl/hs_icc_report_utilization.tcl
# report unconnected ports to design (input: port collection)
source ~/scripts/dc/report_ports_unconnected_to_design.tcl

######################################################
# dc only and sdc stabilization procs                #
######################################################
# find unconnected ports. 
source ~/scripts/dc/find_unconnected_mpins_to_io_buf.tcl
# generate io constraints from port --> FF --> clock_port -->port.
source ~/scripts/dc/soc_generate_io_constraints.tcl
# my generate io constraints from port --> FF --> clock_port -->port(script not proc)
###~/scripts/dc/my_generate_io_constraints_in.tcl
###~/scripts/dc/my_generate_io_constraints_out.tcl
# find all unconnected regs.
source /proj14/filerpt109/milos5/BE/Model_RTL_FREEZE/scripts/dc/sw_report_unclocked_regs.tcl
# return 1 if port is a clock source.
source ~/scripts/dc/is_clock_port.tcl
# find a possible clock to port or clock pin
source ~/scripts/dc/find_possible_clocks.tcl
# report on max slack/trans in input vs. output pins of a cell
source ~/scripts/dc/hs_get_slack_on_path.tcl
# give util after synt (manor script not proc)
### source ~/scripts/dc/report_hier_area_cell.tcl
# fast synt flow from dima (script not proc)
### source ~/scripts/dc/fast_synt.tcl

######################################################
# floor plan and PG procs                            #
######################################################

# remove small pg nets to be use after pg to fix small unconnected metals between rams
source ~/scripts/icc/remove_small_pg_nets.tcl
# place ports on new design
#source /mrvl/aman_users/shuaa/work/shua_scripts/tcl/soc_place_ports.tcl
# export def of box pin cell
source ~/scripts/icc/my_export_def_fp.tcl
# convert def from hier to flat format (script not proc)
#source ~/scripts/icc/convert_def_to_flat.tcl

######################################################
# ECO's procs                                        # 
######################################################
# size up down a given cell 
source ~/scripts/icc/soc_size_cell.tcl
# set one cell vt
#source /mrvl/aman_users/shuaa/work/shua_scripts/tcl/soc_low_cells_vt.tcl
# set the vt of all cells in a timing path
#source /mrvl/aman_users/shuaa/work/shua_scripts/tcl/soc_low_cells_vt_in_a_path.tcl

######################################################
# GUI procs                                          # 
######################################################
# zoom on selection 
source ~/scripts/icc/zoom.tcl
# color macros by hierarchy
source ~/scripts/icc/color_macros_by_hierarchy.tcl
# color timing path
source ~/scripts/icc/highlight_timing_paths.tcl
# color port by hierarchy
source ~/scripts/icc/highlight_ports_by_hierarchy.tcl

#####################################################
# util procs                                        #
#####################################################
# go over a file line by line end return a list
source ~/scripts/service_procs/file_to_list.tcl
# go over a file of ports. return a list of ports with bus merge
source ~/scripts/service_procs/organize_port_list.tcl
# re-source the last proc sourced by it by typing rp (rp)
source ~/scripts/icc/load_proc.tcl
# print run ok 
source ~/lior_allerhand_cool_scripts/run_ok.tcl
# get timing report as file and break it to an array 
source ~/scripts/icc/soc_split_rt.tcl
# merge budget or max del file 
source ~/scripts/dc/merge_budget_file.tcl

######################################################
# P.T                                                #
######################################################
# sw fix_eco
source ~puma3b/BE/Model_BE_Exploration/scripts/pt/sw_fix_eco_timing.tcl


######################################################
# my alias                                           #
######################################################
alias p    "puts"
alias s    "set"
alias a    "open_mw_lib"
alias aa   "list_mw_cel"
alias aaa  "open_mw_cel"
alias amc  "all_macro_cells"
alias aclk "all_clocks"
alias ac   "all_connected"
alias ad   "all_designs"
alias ai   "all_inputs"
alias ao   "all_outputs"
alias ar   "all_registers"
alias afi "all_fanin -flat -startpoints_only -to"
alias afo "all_fanout -flat -endpoints_only -from"
alias cml "close_mw_lib"
alias cmc "close_mw_cel"
alias gc   "get_cells"
alias gco  "get_cells -of_object"
alias gcl  "get_clocks"
alias gs   "get_selection"
alias gp   "get_pins"
alias gpo  "get_pins -of_object"
alias gports  "get_ports"
alias gportso "get_ports -of_object"
alias gn   "get_net"
alias gno  "get_net -of_object"
alias glc  "get_lib_cells"
alias glco "get_lib_cells -of_object"
alias glp  "get_lib_pins"
alias glpo "get_lib_pins -of_object"
alias ga   "get_attribute"
alias gon  "get_object_name"
alias sa   "set_attribute"
alias rd "read_ddc"
alias ra "report_attribute -application"
alias rt   "report_timing"
alias soc "sizeof_collection"
alias sc  "size_cell"
alias cs "change_selection"
alias csam {change_selection [all_macro_cells]}
alias soc "sizeof_collection"
alias rcc "report_cell -connections"
alias rnc "report_net -connections"
alias fic "foreach_in_collection"
alias famc {set_object_fixed_edit [all_macro_cells] 1}
alias ufamc {set_object_fixed_edit [all_macro_cells] 0}
alias fs    {set_object_fixed_edit [get_selection] 1}
alias ufs   {set_object_fixed_edit [get_selection] 0}
alias hs "hs_get_slack_on_path -cell"
alias sop {soc [get_cells -hierarchical -filter "is_placed==true"]}
alias rt "report_timing -capacitance -transition_time -input_pins"
alias rtg "report_timing -capacitance -transition_time -input_pins -group "
alias rsg "report_summary -group "
alias rs "report_summary"
alias rds "report_design_slack_information -nworst 10"
alias rc "remove_cell"
alias rn "remove_net"
alias myc {clock format [clock scan now] -format "%m-%d-%y_%H-%M"}

source ~kw28/USERS/eyald/kw28_FC_Timing/MODELS/Backend/FullChip/Timing/f2f/scripts/source_scripts
