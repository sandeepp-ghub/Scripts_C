#!/bin/tcsh

set input_file = $1

if ( ! -e $input_file ) then
   echo "Input_File not valid: '$input_file'"

else
    if ( `gzip -t $input_file` == "" ) then
	set CAT_CMD = "zcat"
	echo "gzipped file"
    else
	set CAT_CMD = "cat"
	echo "unzipped file"
    endif

    if ( `echo $PROJ_TECHNOLOGY | grep tsmc003` != "" ) then
	echo "3nm technology"
	set SCRIPT_SUFFIX = "3nm.sh"
    else
	set SCRIPT_SUFFIX = "sh"
    endif

    if ( `$CAT_CMD $input_file | head | grep Innovus` != "" ) then
	set SP_EP_SCRIPT = /user/dnetrabile/scripts/show_startpoint_endpoints_from_INV_rpt.$SCRIPT_SUFFIX
	#show_startpoint_endpoints_from_INV_rpt.3nm.sh
	#show_startpoint_endpoints_from_INV_rpt.sh
    else
	set SP_EP_SCRIPT = /user/dnetrabile/scripts/show_startpoint_endpoint_from_DC_rpt.$SCRIPT_SUFFIX
	#show_startpoint_endpoint_from_DC_rpt.3nm.sh
	#show_startpoint_endpoint_from_DC_rpt.sh
    endif

    #echo $SP_EP_SCRIPT 
    $SP_EP_SCRIPT $input_file | less

    #show_startpoint_endpoint_from_PT_rpt.sh


endif
