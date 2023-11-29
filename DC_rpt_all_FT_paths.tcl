
proc report_all_FT_paths_in_the_design {} {
    redirect -file ../reports/kw28_alpha_macro_FT.rpt {puts ""}
    set real_FT             ""
    set FT_pluseFF2OUT      ""
    set FT_pluseIN2FF       ""
    set FT_pluseFF2INANDOUT ""
    set inputs [all_inputs]
    set id 0
    foreach_in_collection input $inputs {
        set in  [get_object_name $input]
        set afo [all_fanout -from $in -flat -endpoints_only] 
        set afo_ports ""
        set afo_ports [filter_collection $afo "object_class==port AND pin_direction==out"]
        if {$afo_ports != ""} {
            foreach_in_collection output $afo_ports {
                set out  [get_object_name $output]
                set afi ""
                set afi  [all_fanin -to $out -flat -startpoints_only]
                set FT_table($id,iport)  $in
                set FT_table($id,oport)  $out
               set FT_table($id,ipin)   [filter_collection $afo  "object_class==pin AND pin_direction==in"  ]
               set FT_table($id,opin)   [filter_collection $afi "object_class==pin AND pin_direction==out" ]
                
#       puts $id
# puts "$FT_table($id,iport) ---- > $FT_table($id,oport) "
                  incr id;
             }
#            puts "out of iner loop"

        }
       
#        if { $id >= "50" } {break}

    } ; # end of first run on inputs

    for {set i 0} {$i<$id} {incr i} {
#   if {$FT_table($i,ipin) eq "" &&  $FT_table($i,opin) eq ""} {redirect -variable real_FT             -append {puts "$FT_table($i,iport) ---> $FT_table($i,oport)" }}
#   if {$FT_table($i,ipin) eq "" &&  $FT_table($i,opin) ne ""} {redirect -variable FT_pluseFF2OUT      -append {puts "$FT_table($i,iport) ---> $FT_table($i,oport)" }}
#        if {$FT_table($i,ipin) ne "" &&  $FT_table($i,opin) eq ""} {redirect -variable FT_pluseIN2FF       -append {puts "$FT_table($i,iport) ---> $FT_table($i,oport)" }}
#        if {$FT_table($i,ipin) ne "" &&  $FT_table($i,opin) ne ""} {redirect -variable FT_pluseFF2INANDOUT -append {puts "$FT_table($i,iport) ---> $FT_table($i,oport)" }}
        if {$FT_table($i,ipin) ne "" &&  $FT_table($i,opin) eq ""} {puts "$FT_table($i,iport)" }
        if {$FT_table($i,ipin) ne "" &&  $FT_table($i,opin) ne ""} {puts "$FT_table($i,iport)" }
    }

    #-- printing reports to file
#    redirect -file ../reports/kw28_alpha_macro_FT.rpt -append {puts "INFO: REAL FT"}
#    redirect -file ../reports/kw28_alpha_macro_FT.rpt -append {puts "$real_FT"}
#    redirect -file ../reports/kw28_alpha_macro_FT.rpt -append {puts "INFO:IO PATHS. INPUT PORT HAVE A PORT2FF PATH IN PARALLEL TO FT PATH"}
#    redirect -file ../reports/kw28_alpha_macro_FT.rpt -append {puts "$FT_pluseFF2OUT"}
#    redirect -file ../reports/kw28_alpha_macro_FT.rpt -append {puts "INFO:IO PATHS. OUTPUT PORT HAVE A FF2PORT PATH IN PARALLEL TO FT PATH"}
#  redirect -file ../reports/kw28_alpha_macro_FT.rpt -append {puts "$FT_pluseIN2FF"}
#    redirect -file ../reports/kw28_alpha_macro_FT.rpt -append {puts "INFO:IO PATHS. OUTPUT PORT HAVE A FF2PORT PATH IN PARALLEL TO FT PATH"}
#    redirect -file ../reports/kw28_alpha_macro_FT.rpt -append {puts "$FT_pluseFF2INANDOUT"}

    return 0
}
