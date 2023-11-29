#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: run a fast synt to see maping problems                #
#====================================================================#
# Example:  fast_synt                                                #
#====================================================================#


proc fast_synt {} {
    sig_read_unit $TopModule
    sig_change_name_rules
    current_design ${TopModule}
    sig_rename_design
    uniquify -force
    eee {sig_include_defaults}
    link
    compile_ultra -no_design_rule -no_seq_output_inversion -no_boundary_optimization -no_autoungroup -exact_map
    change_names -rules verilog -hierarchy
    write -f ddc -hier -output ./read_verilog.ddc
}
