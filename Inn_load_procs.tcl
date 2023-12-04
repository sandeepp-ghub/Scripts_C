set PROC_DIR {/mrvl/il1homes/lioral/scripts/INN}

echo ""
foreach proc [glob ${SOC_PROC_DIR}/*] {
    if {$proc eq "${SOC_PROC_DIR}\/load_proc.tcl"} {continue}
    if {$proc eq "${SOC_PROC_DIR}\/innovus_aliases.tcl"} {continue}
    echo "sourcing $proc ..."
    source $proc
    echo "... Done"
}
echo ""
echo "sourcing innovus aliases ..."
source  ${SOC_PROC_DIR}/innovus_aliases.tcl
echo "... Done"

echo ""

