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

set PROC_DIR {/user/lioral/scripts/INN}

#foreach proc [glob ${PROC_DIR}/subs/*] {
#    echo "sourcing $proc ..."
#    source $proc
#    echo "... Done"
#}


echo ""

foreach proc [glob ${PROC_DIR}/*] {
    if {$proc eq "${PROC_DIR}\/load_proc.tcl"}       {continue}
    if {$proc eq "${PROC_DIR}\/innovus_aliases.tcl"} {continue}
    if {$proc eq "${PROC_DIR}\/NEEDaFIX"}            {continue}
    echo   "sourcing $proc ..."
    source  $proc
    echo   "... Done"
}
echo ""
echo    "sourcing aliases ..."
echo    "sourcing ${PROC_DIR}/innovus_aliases.tcl"
source   ${PROC_DIR}/innovus_aliases.tcl
echo    "... Done"
echo    ""


