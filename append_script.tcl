puts "You can get your collaterals from the following \n
        1. pt 
        2. opt 
        3. place 
        4. cts 
        5. route 
        6. genfill 
        7. none     \n"

puts "Track path from where collaterals are to be picked up"
set user_input_track [gets stdin]
set input_track_split [split $user_input_track "\/"]
set input_track_split_2 [split [lindex $input_track_split 4] "."]
set input_block_name [lindex $input_track_split_2 0]
#puts $input_track_split_2

puts "Where do want Libs from?"
set user_input_libs [gets stdin]

puts "Where do want DBs from?"
set user_input_dbs [gets stdin]

puts "Where do want lefs from?"
set user_input_lefs [gets stdin]

puts "Where do want gds from?"
set user_input_gds [gets stdin]

set w [pwd]
set temp $w
set splitbuff [split $temp "/"]
set splitbuff2 [split [lindex $splitbuff 8] "."]
set blockname [lindex $splitbuff2 0]
 
cd $w

set file_name ${w}/${blockname}.defacto.rtl.defacto:get_rtl.tcl_collateral_defacto_copy
if {[file exist $file_name] == 0} {
    file copy -force ${w}/defacto.rtl/dataout/${blockname}.defacto.rtl.defacto:get_rtl.tcl_collateral_defacto ${w}/${blockname}.defacto.rtl.defacto:get_rtl.tcl_collateral_defacto_copy
}
if {[file exist $file_name]} {
    source ${w}/${blockname}.defacto.rtl.defacto:get_rtl.tcl_collateral_defacto_copy
} else {
    source ${w}/defacto.rtl/dataout/${blockname}.defacto.rtl.defacto:get_rtl.tcl_collateral_defacto
}

file delete -force ${w}/defacto.rtl/dataout/${blockname}.defacto.rtl.defacto:get_rtl.tcl_collateral_defacto  

puts [global LIB]
proc append_libs {} {
    global LIB
    set LIBtt0p85v85c [glob  -nocomplain -type f *85*85*.lib.gz *max7*.lib]
    foreach name $LIBtt0p85v85c {
        set file_name [file join [pwd] $name]
        lappend  LIB(tt0p85v85c) $file_name 
    }
    set LIBffgnp0p935v125c [glob -nocomplain -type f *935*125*.lib.gz *min1*.lib]
    foreach name $LIBffgnp0p935v125c {
        set file_name [file join [pwd] $name]
        lappend LIB(ffgnp0p935v125c) $file_name
    }
    
    set LIBffgnp0p935vm40c [glob -nocomplain -type f *935*40*.lib.gz *min2*.lib]
    foreach name $LIBffgnp0p935vm40c {
        set file_name [file join [pwd] $name]
        lappend LIB(ffgnp0p935vm40c) $file_name
    }
    
    set LIBssgnp0p765v125c [glob -nocomplain -type f *765*125*.lib.gz *min7*.lib]
    foreach name $LIBssgnp0p765v125c {
        set file_name [file join [pwd] $name]
        lappend LIB(ssgnp0p765v125c) $file_name
    }
    
    set LIBssgnp0p765vm40c [glob -nocomplain -type f *765*40*.lib.gz *max10*.lib]
    foreach name $LIBssgnp0p765vm40c {
        set file_name [file join [pwd] $name]
        lappend LIB(ssgnp0p765vm40c) $file_name
    }
    
    set LIBffgnp0p825v125c [glob -nocomplain -type f *825*125*.lib.gz *min3*.lib]
    foreach name $LIBffgnp0p825v125c {
        set file_name [file join [pwd] $name]
        lappend LIB(ffgnp0p825v125c) $file_name
    }
    
    set LIBtt0p75v85c   [glob -nocomplain -type f    *75*85*.lib.gz *max6*.lib]
    foreach name $LIBtt0p75v85c {
        set file_name [file join [pwd] $name]
        lappend LIB(tt0p75v85c) $file_name
    }
    
    set LIBffgnp0p825vm40c [glob -nocomplain -type f *825*40*.lib.gz *min12*.lib]
    foreach name $LIBffgnp0p825vm40c {
        set file_name [file join [pwd] $name]
        lappend LIB(ffgnp0p825vm40c) $file_name
    }
    
    set LIBtt0p95v85c   [glob -nocomplain -type f    *95*85.lib.gz *min11*.lib]
    foreach name $LIBtt0p95v85c {
        set file_name [file join [pwd] $name]
        lappend LIB(tt0p95v85c) $file_name
    }
    
    set LIBssgnp0p675v125c [glob -nocomplain -type f *675*125*.lib.gz *max2*.lib]
    foreach name $LIBssgnp0p675v125c {
        set file_name [file join [pwd] $name]
        lappend LIB(ssgnp0p675v125c) $file_name
    }
    
    set LIBssgnp0p855v125c [glob -nocomplain -type f *855*125*.lib.gz *max4*.lib]
    foreach name $LIBssgnp0p855v125c {
        set file_name [file join [pwd] $name]
        lappend LIB(ssgnp0p855v125c) $file_name
    }
    
    set LIBssgnp0p675vm40c [glob -nocomplain -type f *675*40*.lib *max1*.lib]
    foreach name $LIBssgnp0p675vm40c {
        set file_name [file join [pwd] $name]
        lappend LIB(ssgnp0p675vm40c) $file_name
    }
}    




proc append_db {} {
    global DB
    set DBtt0p85v85c   [glob -nocomplain -type f     *85*85*.db *max7*.db ]
    foreach name $DBtt0p85v85c {
        set file_name [file join [pwd] $name]
        lappend DB(tt0p85v85c) $file_name
    }
    
    set DBffgnp0p935v125c [glob -nocomplain -type f *935*125*.db *min1*.db]
    foreach name $DBffgnp0p935v125c {
        set file_name [file join [pwd] $name]
        lappend DB(ffgnp0p935v125c) $file_name
    }
    set DBffgnp0p935vm40c [glob -nocomplain -type f *935*40*.db *min2*.db]
    foreach name $DBffgnp0p935vm40c {
        set file_name [file join [pwd] $name]
        lappend DB(ffgnp0p935vm40c) $file_name
    }
    
    set DBssgnp0p765v125c [glob -nocomplain -type f *765*125*.db *min7*.db]
    foreach name $DBssgnp0p765v125c {
        set file_name [file join [pwd] $name]
        lappend DB(ssgnp0p765v125c) $file_name
    }
    
    set DBssgnp0p765vm40c [glob -nocomplain -type f *765*40*.db *max10*.db]
    foreach name $DBssgnp0p765vm40c {
        set file_name [file join [pwd] $name]
        lappend DB(ssgnp0p765vm40c) $file_name
    }
    
    set DBffgnp0p825v125c [glob -nocomplain -type f *825*125*.db *min3*.db]
    foreach name $DBffgnp0p825v125c {
        set file_name [file join [pwd] $name]
        lappend DB(ffgnp0p825v125c) $file_name
    }
    
    set DBtt0p75v85c   [glob -nocomplain -type f    *75*85*.db *max6*.db]
    foreach name $DBtt0p75v85c {
        set file_name [file join [pwd] $name]
        lappend DB(tt0p75v85c) $file_name
    }
    
    set DBffgnp0p825vm40c [glob -nocomplain -type f *825*40*.db *min12*.db]
    foreach name $DBffgnp0p825vm40c {
        set file_name [file join [pwd] $name]
        lappend DB(ffgnp0p825vm40c) $file_name
    }
    
    set DBtt0p95v85c   [glob -nocomplain -type f    *95*85.db *min11*.db]
    foreach name $DBtt0p95v85c {
        set file_name [file join [pwd] $name]
        lappend DB(tt0p95v85c) $file_name
    }
    
    set DBssgnp0p675v125c [glob -nocomplain -type f *675*125*.db *max2*.db]
    foreach name $DBssgnp0p675v125c {
        set file_name [file join [pwd] $name]
        lappend DB(ssgnp0p675v125c) $file_name
    }
    
    set DBssgnp0p855v125c [glob -nocomplain -type f *855*125*.db *max4*.db]
    foreach name $DBssgnp0p855v125c {
        set file_name [file join [pwd] $name]
        lappend DB(ssgnp0p855v125c) $file_name
    }
    
    set DBssgnp0p675vm40c [glob -nocomplain -type f *675*40*.db *max1*.db]
    foreach name $DBssgnp0p675vm40c {
        set file_name [file join [pwd] $name]
        lappend DB(ssgnp0p675vm40c) $file_name
    }
}

proc append_lef {} {
    global PHYSICAL
    set PHYSICALlef [glob -nocomplain -type f         *.lef.gz]
    foreach name $PHYSICALlef {
        set file_name [file join [pwd] $name]
        lappend PHYSICAL(lef) $file_name
    }
}

proc append_gds {} {    
    global PHYSICAL
    set PHYSICALgds   [glob -nocomplain -type f       *.gds *oas_merged*]
    foreach name $PHYSICALgds {
        set file_name [file join [pwd] $name]
        lappend PHYSICAL(gds) $file_name
    }
}



switch $user_input_libs {
    pt {
        cd ${user_input_track}/pt.signoff/dataout/
        append_libs 
        cd $user_input_track
    }

    opt {
        cd ${user_input_track}/invcui.post.opt/${input_block_name}.invcuidb/${input_block_name}/libs/mmmc/
        append_libs
        cd $user_input_track
    }

    place {
        cd ${user_input_track}/invcui.pre.place/${input_block_name}.invcuidb/${input_block_name}/libs/mmmc/
        append_libs
        cd $user_input_track
    }

    cts {
        cd ${user_input_track}/invcui.pre.cts/${input_block_name}.invcuidb/${input_block_name}/libs/mmmc/
        append_libs
        cd $user_input_track
    }

    route {
        cd ${user_input_track}invcui.pre.cts/${input_block_name}.invcuidb/${input_block_name}/libs/mmmc/
        append_libs
        cd $user_input_track
    }

    default {
        puts "Please select the right option for libs :)"
    }


}

switch $user_input_dbs {
    pt {
        cd ${user_input_track}/pt.signoff/dataout/
        append_db 
        cd $user_input_track
    }

    opt {
        cd ${user_input_track}/invcui.post.opt/${input_block_name}.invcuidb/${input_block_name}/libs/mmmc/
        append_db
        cd $user_input_track
    }
     place {
        cd ${user_input_track}/invcui.pre.place/${input_block_name}.invcuidb/${input_block_name}/libs/mmmc/
        append_db
        cd $user_input_track
    }

    cts {
        cd ${user_input_track}/invcui.pre.cts/${input_block_name}.invcuidb/${input_block_name}/libs/mmmc/
        append_db
        cd $user_input_track
    }

    route {
        cd ${user_input_track}/invcui.pre.cts/${input_block_name}.invcuidb/${input_block_name}/libs/mmmc/
        append_db
        cd $user_input_track
    }

    default {
        puts "Please select the right option for dbs :)"
    }
}

switch $user_input_lefs {
    opt {
        cd ${user_input_track}/invcui.post.opt/dataout/
        append_lef
        cd $user_input_track
    }
#     place {
#        cd ${user_input_track}/invcui.pre.place/dataout/${input_block_name}
#        append_lef
#        cd $user_input_track
#    }
#
#    cts {
#        cd ${user_input_track}/invcui.pre.cts/dataout/${input_block_name}
#        append_lef
#        cd $user_input_track
#    }
#
#    route {
#        cd ${user_input_track}/invcui.pre.route/dataout/${input_block_name}
#        append_lef
#        cd $user_input_track
#    }
#
    default {
        puts "Please select the right option for lef :)"
    }
}

switch $user_input_gds {
    genfill {
        cd ${user_input_track}/pv.signoff.genfill/dataout
        append_gds
        cd $user_input_track
    }
    default {
        puts "Please select the right option for gds :)"
    }
}


#set LOGICALipspec   [glob -nocomplain -type f {}          ]
#foreach name $LOGICALipspec {
#    set file_name [file join [pwd] $name]
#    lappend LOGICAL(ipspec) $file_name
#}
#
#set LOGICALbehav_pg   [glob -nocomplain -type f  *pwr*.v]
#foreach name $LOGICALbehav_pg {
#    set file_name [file join [pwd] $name]
#    lappend LOGICAL(behav_pg) $file_name
#}
#
#set LOGICALspice   [glob -nocomplain -type f     *.spi]
#foreach name $LOGICALspice {
#    set file_name [file join [pwd] $name]
#    lappend LOGICAL(spice) $file_name
#}
#
#set LOGICALmdt   [glob -nocomplain -type f       *.mdt]
#foreach name $LOGICALmdt {
#    set file_name [file join [pwd] $name]
#    lappend LOGICAL(mdt) $file_name
#}
#
#set LOGICALgate   [glob -nocomplain -type f  {}         ]
#foreach name $LOGICALgate {
#    set file_name [file join [pwd] $name]
#    lappend LOGICAL(gate) $file_name
#}
#
#set LOGICALbehav   [glob -nocomplain -type f     *.v]
#foreach name $LOGICALbehav {
#    set file_name [file join [pwd] $name]
#    lappend LOGICAL(behav) $file_name
#}
#set LOGICALgate_pg   [glob -nocomplain -type f   {}     ]
#foreach name $LOGICALgate_pg {
#    set file_name [file join [pwd] $name]
#    lappend LOGICAL(gate_pg) $file_name
#}
#set PHYSICALmky [glob -nocomplain -type f    {}         ]
#foreach name $PHYSICALmky {
#    set file_name [file join [pwd] $name]
#    lappend PHYSICAL(mky) $file_name
#}

#set PHYSICALndm   [glob -nocomplain -type f       *.ndm]
#foreach name $PHYSICALndm {
#    set file_name [file join [pwd] $name]
#    lappend PHYSICAL(ndm)  $file_name
#}


set fp [open ${w}/defacto.rtl/dataout/${blockname}.defacto.rtl.defacto:get_rtl.tcl_collateral_defacto a]


# if {[catch set LIB(tt0p85v85c)      {$LIB(tt0p85v85c)  }}  {
 #    puts $fp "set LIB(tt0p85v85c)      {$LIB(tt0p85v85c) }"
 #}

 #puts $fp " set LIB(tt0p85v85c)      {$LIB(tt0p85v85c)  }"
 #puts $fp " set LIB(ffgnp0p935v125c) {$LIB(ffgnp0p935v125c)}"
 #puts $fp " set LIB(ffgnp0p935vm40c) {$LIB(ffgnp0p935vm40c)}"
 #puts $fp " set LIB(ssgnp0p765v125c) {$LIB(ssgnp0p765v125c)}"
 #puts $fp " set LIB(ssgnp0p765vm40c) {$LIB(ssgnp0p765vm40c)}"
 puts $fp " set LIB(ffgnp0p825v125c) {$LIB(ffgnp0p825v125c)}"
 puts $fp " set LIB(tt0p75v85c)      {$LIB(tt0p75v85c)  }"
 puts $fp " set LIB(ffgnp0p825vm40c) {$LIB(ffgnp0p825vm40c)}"
# puts $fp " set LIB(tt0p95v85c)      {$LIB(tt0p95v85c)}"
 puts $fp " set LIB(ssgnp0p675v125c) {$LIB(ssgnp0p675v125c)}"
# puts $fp " set LIB(ssgnp0p855v125c) {$LIB(ssgnp0p855v125c)}"
 puts $fp " set LIB(ssgnp0p675vm40c) {$LIB(ssgnp0p675vm40c)}"
# puts $fp " set DB(tt0p85v85c)       {$DB(tt0p85v85c)  }"
 #puts $fp " set DB(ffgnp0p935v125c)  {$DB(ffgnp0p935v125c) }"
 #puts $fp " set DB(ffgnp0p935vm40c)  {$DB(ffgnp0p935vm40c) }"
 #puts $fp " set DB(ssgnp0p765v125c)  {$DB(ssgnp0p765v125c) }"
 #puts $fp " set DB(ssgnp0p765vm40c)  {$DB(ssgnp0p765vm40c) }"
 puts $fp " set DB(ffgnp0p825v125c)  {$DB(ffgnp0p825v125c) }"
 puts $fp " set DB(tt0p75v85c)       {$DB(tt0p75v85c)  }"
 puts $fp " set DB(ffgnp0p825vm40c)  {$DB(ffgnp0p825vm40c) }"
 #puts $fp " set DB(tt0p95v85c)       {$DB(tt0p95v85c)  }"
 puts $fp " set DB(ssgnp0p675v125c)  {$DB(ssgnp0p675v125c) }"
 #puts $fp " set DB(ssgnp0p855v125c)  {$DB(ssgnp0p855v125c) }"
 puts $fp " set DB(ssgnp0p675vm40c)  {$DB(ssgnp0p675vm40c) }"
 puts $fp " set LOGICAL(ipspec)      {$LOGICAL(ipspec) }"
 puts $fp " set LOGICAL(behav_pg)    {$LOGICAL(behav_pg)}"
 puts $fp " set LOGICAL(spice)       {$LOGICAL(spice)  }"
 puts $fp " set LOGICAL(mdt)         {$LOGICAL(mdt) }"
 puts $fp " set LOGICAL(gate)        {$LOGICAL(gate)  }"
 puts $fp " set LOGICAL(behav)       {$LOGICAL(behav) }"
 puts $fp " set LOGICAL(gate_pg)     {$LOGICAL(gate_pg)}"
 puts $fp " set PHYSICAL(gds)        {$PHYSICAL(gds)   }"
 puts $fp " set PHYSICAL(mky)        {$PHYSICAL(mky)   }"
 puts $fp " set PHYSICAL(ndm)        {$PHYSICAL(ndm)  }"
 puts $fp " set PHYSICAL(lef)        {$PHYSICAL(lef)  }"

close $fp



