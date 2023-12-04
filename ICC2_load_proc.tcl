#====================================================================#
#                       M A R V E L L                                #
#                       ==============                               #
# Date: 22/4/13                                                      #
#====================================================================#
# Script Owner: Lior Allerhand                                       #
#====================================================================#
# Description: SOC Environment load proc file                        #
#====================================================================#
# Example:                                                           #
#====================================================================#

set SOC_PROC_DIR {/nfs/isrusers1/lioral/scripts/ICC2}

#foreach proc [glob ${SOC_PROC_DIR}/subs/*] {
#    echo "sourcing $proc ..."
#    source $proc
#    echo "... Done"
#}


echo ""

foreach proc [glob ${SOC_PROC_DIR}/*] {
    if {$proc eq "${SOC_PROC_DIR}\/printClockFanout.tcl"} {continue}
    if {$proc eq "${SOC_PROC_DIR}\/load_proc.tcl"} {continue}
    if {$proc eq "${SOC_PROC_DIR}\/icc2_aliases.tcl"} {continue}
    if {$proc eq "${SOC_PROC_DIR}\/translate_to_collection.tcl"} {continue}
    if {$proc eq "${SOC_PROC_DIR}\/MISL_ICC2_GUI_SETUP_FILE.tcl"} {continue}
    echo "sourcing $proc ..."
    source $proc
    echo "... Done"
}
echo ""
echo "sourcing aliases ..."
source  ${SOC_PROC_DIR}/icc2_aliases.tcl
echo "... Done"

echo ""

if {$TOOL eq "icc2"} {
echo "Open gui tool bars ..."

gui_start
cn_interactive_menu
hilite_menu_icc2
    set COLOR_MACRO_BY_GROUPS_DELIMITER '_';
    gui_delete_menu -menu "Allerhand's"
    gui_create_menu -menu "Allerhand's->Prepare" -heading "Allerhand's procs"
#    gui_create_menu -menu "Allerhand's->->Macro 2 Macro" -heading "Macro 2 Macro"    
    gui_create_menu -menu "Allerhand's->Macro 2 Macro" -separator
    gui_create_menu -menu "Allerhand's->Toggle delimiter"      -tcl_cmd "if {$COLOR_MACRO_BY_GROUPS_DELIMITER eq '_'} {set COLOR_MACRO_BY_GROUPS_DELIMITER '/'} else {set COLOR_MACRO_BY_GROUPS_DELIMITER '_'}"
    gui_create_menu -menu "Allerhand's->color macros levele 1" -tcl_cmd "color_macros_by_groups -levels 1 -delimiter '_'"
    gui_create_menu -menu "Allerhand's->color macros levele 2" -tcl_cmd "color_macros_by_groups -levels 2 -delimiter '_'"
    gui_create_menu -menu "Allerhand's->color macros levele 3" -tcl_cmd "color_macros_by_groups -levels 3 -delimiter '_'"
    gui_create_menu -menu "Allerhand's->color macros levele 4" -tcl_cmd "color_macros_by_groups -levels 4 -delimiter '_'"
#    gui_create_menu -menu "Allerhand's->->Macro 2 Flop" -heading "Macro 2 Flop"
        gui_create_menu -menu "Allerhand's->Macro 2 Flop" -separator
    gui_create_menu -menu "Allerhand's->color fanin/out flops" -tcl_cmd "source /nfs/isrusers1/lioral/scripts/ICC2/scripts/GetMacroGravity.tcl"
    gui_create_menu -menu "Allerhand's->Macro to flops arrow"  -tcl_cmd "cn_gui_drew_arrow -selected"
    gui_create_menu -menu "Allerhand's->Macro to flops arrow reset"  -tcl_cmd "cn_gui_drew_arrow -reset"

}

