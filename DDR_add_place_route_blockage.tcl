
set bx0 525
set bx1 540
set by0 600
set by1 3700

create_place_blockage -type hard -name MSCTSBOX -rects "$bx0 $by0 $bx1 $by1"
create_route_blockage -layers "M15 M13 M11" -except_pg_nets -name MSCTSBOX -rects "$bx0 $by0 $bx1 $by1"

for {set i $by0} { $i < 3700} {set i $y1} {

    set i [expr $i + 80]
    set x0 $bx0
    set y0 $i
    set x1 $bx1
    set y1 [expr $y0+1.05]
    create_route_blockage -all {route cut} -except_pg_nets -name MSCTSBOX -rects "$x0 $y0 $x1 $y1"
}


