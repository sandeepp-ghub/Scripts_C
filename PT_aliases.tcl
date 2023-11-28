#====================================================================#
#                       M A R V E L L  SOC                           #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: SOC Environment aliases file                          #
#====================================================================#
# Example:                                                           #
#====================================================================#

alias p       "puts"
alias s       "set"
alias oml     "open_mw_lib"
alias lmc     "list_mw_cel"
alias amc     "open_mw_cel"
alias amc     "all_macro_cells"
alias aclk    "all_clocks"
alias ac      "all_connected"
alias ad      "all_designs"
alias ai      "all_inputs"
alias ao      "all_outputs"
alias ar      "all_registers"
alias afi     "all_fanin -flat -startpoints_only -to"
alias afo     "all_fanout -flat -endpoints_only -from"
alias cml     "close_mw_lib"
alias cmc     "close_mw_cel"
alias gc      "get_cells"
alias gco     "get_cells -of_object"
alias gcl     "get_clocks"
alias gs      "get_selection"
alias gp      "get_pins"
alias gpo     "get_pins -of_object"
alias gports  "get_ports"
alias gportso "get_ports -of_object"
alias gn      "get_net"
alias gno     "get_net -of_object"
alias glc     "get_lib_cells"
alias glco    "get_lib_cells -of_object"
alias glp     "get_lib_pins"
alias glpo    "get_lib_pins -of_object"
alias ga      "get_attribute"
alias gon     "get_object_name"
alias sa      "set_attribute"
alias rd      "read_ddc"
alias ra      "report_attribute -application"
#alias rt      "report_timing"
alias soc     "sizeof_collection"
alias sc      "size_cell"
alias cs      "change_selection"
alias csam    {change_selection [all_macro_cells]}
alias rcc     "report_cell -connections"
alias rnc     "report_net -connections"
alias fic     "foreach_in_collection"
alias famc    {set_object_fixed_edit [all_macro_cells] 1}
alias ufamc   {set_object_fixed_edit [all_macro_cells] 0}
alias fs      {set_object_fixed_edit [get_selection] 1}
alias ufs     {set_object_fixed_edit [get_selection] 0}
alias rc      "remove_cell"
alias rn      "remove_net"
alias gdate   {clock format [clock scan now] -format "%m_%d_%y__%H_%M"}
alias rt      "report_timing -capacitance -transition_time -input_pins"
alias rtg     "report_timing -capacitance -transition_time -input_pins -group "
alias rtm      "report_timing -delay_type min -capacitance -transition_time -input_pins"
alias rtgm     "report_timing -delay_type min -capacitance -transition_time -input_pins -group "

alias rtf      "report_timing -path_type full_clock_e -capacitance -transition_time -input_pins"
alias rtfg     "report_timing -path_type full_clock_e -capacitance -transition_time -input_pins -group "
alias rtfm     "report_timing -path_type full_clock_e -delay_type min -capacitance -transition_time -input_pins"
alias rtfgm    "report_timing -path_type full_clock_e -delay_type min -capacitance -transition_time -input_pins -group "

#alias libget   "get_attr [get_libs -of [get_lib_cells \1]] source_file_name"


