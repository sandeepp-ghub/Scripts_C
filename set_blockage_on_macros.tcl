proc set_hard_blockage_on_macro_right {} {

set dbs [get_db selected]
set ymin 10000
set ymax 0
foreach  db $dbs  {
    set x1 [get_db $db .overlap_rects.ur.x]
    set y1 [get_db $db .overlap_rects.ur.y]
    set x0 [get_db $db .overlap_rects.ll.x]
    set y0 [get_db $db .overlap_rects.ll.y]
    
    set xmin $x1
    set xmax [expr double($x1 +100)]
    if {${y0} < $ymin} {set ymin ${y0}}
    if {${y1} > $ymax} {set ymax ${y1}}
}
echo "$xmin $ymin $xmax $ymax"
create_place_blockage -type hard -name LIORAL -rects "$xmin $ymin $xmax $ymax"

}

proc set_hard_blockage_on_macro_left {} {

set dbs [get_db selected]
set ymin 10000
set ymax 0
foreach  db $dbs  {
    set x1 [get_db $db .overlap_rects.ur.x]
    set y1 [get_db $db .overlap_rects.ur.y]
    set x0 [get_db $db .overlap_rects.ll.x]
    set y0 [get_db $db .overlap_rects.ll.y]
    
    set xmax $x1
    set xmin [expr double($x1 - 100)]
    if {${y0} < $ymin} {set ymin ${y0}}
    if {${y1} > $ymax} {set ymax ${y1}}
}
echo "$xmin $ymin $xmax $ymax"
create_place_blockage -type hard -name LIORAL -rects "$xmin $ymin $xmax $ymax"

}


