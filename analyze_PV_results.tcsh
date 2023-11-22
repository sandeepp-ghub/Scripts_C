#!/bin/tcsh

echo ""
echo "CURRENT_DIR = $PWD"

set DEFAULT_BASE_DIR = "$PWD"
set INPUT_BASE_DIR = $1;

set GO = 0
if ( $INPUT_BASE_DIR == "" ) then
    set BASE_DIR = $DEFAULT_BASE_DIR
    set GO = 1
else if ( -e $INPUT_BASE_DIR ) then
    set BASE_DIR = $INPUT_BASE_DIR
    set GO = 1
else if ( ! -e $INPUT_BASE_DIR ) then
    echo "(E): Specified $INPUT_BASE_DIR doesn't exist."
else
    set GO = 1
    set BASE_DIR = "."
endif

if ( $GO == "1" ) then
    echo "(I): Looking in $BASE_DIR ..."


    # Look for LVS results
    set LVS_DIR = ${BASE_DIR}/pv.signoff.lvsq/lvsq_*/COBRA_TOP
    echo "# --------------------------------------------------------------------------------------"
    echo "# Performing ERC analysis @ $LVS_DIR"
    if ( ! -e $LVS_DIR ) then
	echo "(E): Can't find lvs dir"
    else 

	# Look for timestamps start/end
	set session_start = $LVS_DIR/../../.session_start
	set session_end = $LVS_DIR/../../.session_end

	if ( ! -e $session_start ) then
	    echo "(E): Can't find $session_start ... RUN MAY NOT HAVE STARTED YET"
	else if ( ! -e $session_end ) then
	    echo "(I): Run has started ..."
	    ls -l $session_start
	    echo "(E): Can't find $session_end  ... RUN MAY NOT HAVE FINISHED YET"
	else 
	    echo "(I): Run has started ..."
	    echo "(I): Run has completed ..."
	    ls -l $session_start
	    ls -l $session_end   
	    # Look for ERC violations
	    set ERC_REP_FILE = $LVS_DIR/ERC.rep
	    if ( ! -e $ERC_REP_FILE ) then
		echo "(E): Can't find $ERC_REP_FILE file"
	    else
		echo "(I): Looking for ERC results in $ERC_REP_FILE ..."
		cat $ERC_REP_FILE | \grep -A 10 SUMMARY | sed 's/  */ /g' | awk -F: '/Generated:/{printf "      %40s: %-s\n", $1, $2}' ; # THIS LINE DOES THE DATA FINDING
		echo "(I): Done Looking for ERC results"
	    endif
	    echo ""
	endif
    endif
    
    echo "# --------------------------------------------------------------------------------------"
    echo "# Performing LVS analysis @ $LVS_DIR"
    if ( ! -e $LVS_DIR ) then
	echo "(E): Can't find lvs dir"
    else 
	# Look for timestamps start/end
	set session_start = $LVS_DIR/../../.session_start
	set session_end = $LVS_DIR/../../.session_end
	if ( ! -e $session_start ) then
	    echo "(E): Can't find $session_start ... RUN MAY NOT HAVE STARTED YET"
	else if ( ! -e $session_end ) then
	    echo "(I): Run has started ..."
	    ls -l $session_start
	    echo "(E): Can't find $session_end  ... RUN MAY NOT HAVE FINISHED YET"
	else 
	    echo "(I): Run has started ..."
	    echo "(I): Run has completed ..."
	    ls -l $session_start
	    ls -l $session_end   

	    # Look for LVS shorts
	    set LVS_REP_FILE = $LVS_DIR/lvs.rep
	    set LVS_SUM_FILE = $LVS_DIR/lvs.sum
	    set LVS_REP_SHORTS_FILE = $LVS_DIR/lvs.rep.shorts

	    if ( ! -e $LVS_REP_FILE ) then
		echo "(E): Can't find $LVS_REP_FILE file"
	    else
		if ( `grep -l INCORRECT $LVS_REP_FILE` != "" ) then
		    echo "(E): LVS FAILED!"

		    #echo "(I): Looking for LVS errors in $LVS_SUM_FILE ..."
		    #cat $LVS_SUM_FILE | \grep "INCORRECT  " | awk '{printf "      %s\n", $0}'
		    echo "(I): Looking for LVS INCORRECT NETS in $LVS_REP_FILE ..."
		    cat $LVS_REP_FILE | sed -n '/INCORRECT NETS/,/INFORMATION/p' | \grep "  Net " | awk '{printf "      %s\n", $0}' ; # THIS LINE DOES THE DATA FINDING
		    echo "(I): Done Looking for LVS INCORRECT NETS"

		    echo "(I): Looking for LVS shorts in $LVS_REP_SHORTS_FILE ..."
		    if ( ! -e $LVS_REP_SHORTS_FILE ) then
			echo "(I): No $LVS_REP_SHORTS_FILE was found ... no shorts detected"
		    endif
		else
		    echo "(I): LVS PASSED!"
		endif
	    endif
	endif
	echo ""
    endif
    
    # Look for ANT results
    set ANT_DIR = ${BASE_DIR}/pv.signoff.ant/ant_*/COBRA_TOP
    echo "# --------------------------------------------------------------------------------------"
    echo "# Performing ANT analysis @ $ANT_DIR"
    if ( ! -e $ANT_DIR ) then
	echo "(E): Can't find ant dir"
    else 
    	# Look for timestamps start/end
	set session_start = $ANT_DIR/../../.session_start
	set session_end = $ANT_DIR/../../.session_end
	if ( ! -e $session_start ) then
	    echo "(E): Can't find $session_start ... RUN MAY NOT HAVE STARTED YET"
	else if ( ! -e $session_end ) then
	    echo "(I): Run has started ..."
	    ls -l $session_start
	    echo "(E): Can't find $session_end  ... RUN MAY NOT HAVE FINISHED YET"
	else 
	    echo "(I): Run has started ..."
	    echo "(I): Run has completed ..."
	    ls -l $session_start
	    ls -l $session_end   

	    # Look for ANT violations
	    set ANT_REP_FILE = $ANT_DIR/DRC.rep
	    if ( ! -e $ANT_REP_FILE ) then
		echo "(E): Can't find $ANT_REP_FILE file"
	    else
		echo "(I): Looking for ANT violations in $ANT_REP_FILE ..."
		cat $ANT_REP_FILE | \grep -A 10 SUMMARY | sed 's/  */ /g'| awk -F: '/Generated:/{printf "      %40s: %-s\n", $1, $2}' ; # THIS LINE DOES THE DATA FINDING  
		echo "(I): Done Looking for ANT violations"
		
	    endif
	endif
	echo ""
    endif
    
    # Look for DRC results
    set DRC_DIR = ${BASE_DIR}/pv.signoff.drc/drc_*/COBRA_TOP
    echo "# --------------------------------------------------------------------------------------"
    echo "# Performing DRC analysis @ $DRC_DIR"
    if ( ! -e $DRC_DIR ) then
	echo "(E): Can't find drc dir:"
    else 
        # Look for timestamps start/end
	set session_start = $DRC_DIR/../../.session_start
	set session_end = $DRC_DIR/../../.session_end
	if ( ! -e $session_start ) then
	    echo "(E): Can't find $session_start ... RUN MAY NOT HAVE STARTED YET"
	else if ( ! -e $session_end ) then
	    echo "(I): Run has started ..."
	    ls -l $session_start
	    echo "(E): Can't find $session_end  ... RUN MAY NOT HAVE FINISHED YET"
	else 
	    echo "(I): Run has started ..."
	    echo "(I): Run has completed ..."
	    ls -l $session_start
	    ls -l $session_end   

	    # Look for DRC violations
	    set DRC_REP_FILE = $DRC_DIR/DRC.rep
	    if ( ! -e $DRC_REP_FILE ) then
		echo "(E): Can't find $DRC_REP_FILE file"
	    else
		echo "(I): Looking for DRC violations in $DRC_REP_FILE ..."
		cat $DRC_REP_FILE | \grep -A 20 SUMMARY$ | sed 's/  */ /g'| \grep -v Time: | awk -F: '{printf "      %40s: %-s\n", $1, $2}' ; # THIS LINE DOES THE DATA FINDING
		echo "(I): Done Looking for DRC violations"
		set DRC_MARKER_FILE = $DRC_DIR/DRC_RES.drc
		if ( -e $DRC_MARKER_FILE ) then
		    echo "(I): DRC Marker File: $DRC_MARKER_FILE"
		endif
	    endif
	endif
	echo ""
    endif
endif
    
    
