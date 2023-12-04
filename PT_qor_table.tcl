#!/usr/bin/env ipbu_tcl
source /proj/ccpd01/wa_pnr/ngummi/impl/scripts/tabulate.tcl

    set file_list [list  {*}[glob -directory ./pt.signoff/report/ *func_max*qor.csv ] \
                        {*}[glob -directory ./pt.signoff/report/ *func_min*qor.csv ] \
                        {*}[glob -directory ./pt.signoff/report/ *scan*qor.csv ]   ]
    set qor_list ""

   foreach csvf $file_list {
   regexp {.*/pt.signoff\.(.*)_qor\.csv} $csvf  match corner_name
   lappend qor_list $corner_name 
     
    #set fp [open "|zcat $csvf"]
	set fp [open "$csvf"]
	set file_data [read $fp]
	close $fp
    set cols_ln 0
    set CG_ln 0
     
	set data [split $file_data "\n"]
	foreach line $data {
	    #Get lists of the column labels and data in each column of WNS, TNS and violating paths.
	    #Also get the density value.
	    set cols_ln [regexp {^Path_group.*} $line cols_match]
	    if {$cols_ln == 1} {
		set col_lst [split $cols_match ","]
        lappend qor_list $col_lst 
	    }
	    #set clk_ln [regexp {rclk.*} $line clk_match]
	    #if {$clk_ln == 1} {
		#set clk_lst [split $clk_match ","]
	    #}
        if {![regexp {^Path_group|clock_gating_default} $line ]} {
        set clk_lst [split $line ","]
        lappend qor_list $clk_lst 
        }    

	    set CG_ln [regexp {clock_gating_default.*} $line CG_match]
	    if {$CG_ln == 1} {
		set CG_lst [split $CG_match ","]
        lappend qor_list $CG_lst 
	    }
	}
}

set table [::tabulate::tabulate -data $qor_list ]

set out_file [open pt_qor.txt w]
puts $out_file $table
close $out_file
puts "QOR file : [pwd]/pt_qor.txt"
