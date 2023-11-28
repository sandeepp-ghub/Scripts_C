##############################################
## Script to report high pin denisity cells ##
##############################################

proc userReportCellPinDensity {} {
    Puts "Searching available cells and measuring pin density..."
    set outfile [open density.rpt "w"]
    set cellNameList {}
    set count 0
    dbForEachHeadTlsCell [dbgHead] tlsCell {
        set cell [dbTlsCellCell $tlsCell]
        if {[dbIsCellTimeDefined $cell]} {
        set cellName [dbCellName $cell]
if {[lsearch $cellNameList $cellName] == -1} {
if {![dbIsCellBlock $cell]} {
lappend cellNameList $cellName
incr count
}
}
}
}
set unsortedList {}
foreach cellName $cellNameList {
set cell [dbGetCellByName $cellName]
set termCount [dbCellNrFTerm $cell]
set x [lindex [dbCellDim $cell] 0]
set y [lindex [dbCellDim $cell] 1]
set micronX [dbDBUToMicrons $x]
set micronY [dbDBUToMicrons $y]
set area [expr $micronX * $micronY]
set density [expr $termCount / $area]
lappend unsortedList [list $cellName $termCount $area $density]
}
set sortedList [lsort -decreasing -index 3 $unsortedList]
puts $outfile "Cell Name Pin Count Area Pin Density:"
puts $outfile "---------------------------------------------"
foreach entry $sortedList {
set cellName [lindex $entry 0]
set pinCount [lindex $entry 1]
set area [lindex $entry 2]
set density [lindex $entry 3]
puts $outfile [format "%-11s %s %16.3f %7.3f" $cellName $pinCount $area $density]
}
close $outfile
Puts "Done. Wrote sorted pin densities for $count unique standard cells to \"density.rpt\""
}

########################################################
