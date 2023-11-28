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

set PROC_DIR {/user/lioral/scripts/PT}



echo ""

foreach proc [glob ${PROC_DIR}/*] {
    if {$proc eq "${PROC_DIR}\/load_proc.tcl"}                {continue}
    if {$proc eq "${PROC_DIR}\/innovus_aliases.tcl"}          {continue}
    if {$proc eq "${PROC_DIR}\/NEEDaFIX"}                     {continue}
    if {$proc eq "${PROC_DIR}\/filter_report_constraint.tcl"} {continue}
    if {$proc eq "${PROC_DIR}\/find_none_ck_cells.tcl"}       {continue}
    if {$proc eq "${PROC_DIR}\/add_delay_on_endpoints.tcl"}   {continue}
    if {$proc eq "${PROC_DIR}\/run_ok.tcl"}                   {continue}
    echo   "sourcing $proc ..."
    source  $proc
    echo   "... Done"
}
echo ""
echo    "sourcing aliases ..."
echo    "sourcing ${PROC_DIR}/pt_aliases.tcl"
source   ${PROC_DIR}/pt_aliases.tcl
echo    "... Done"
echo    ""
source ${PROC_DIR}/run_ok.tcl
echo ""
