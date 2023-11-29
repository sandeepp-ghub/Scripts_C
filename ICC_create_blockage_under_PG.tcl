###########################################
# create place blockage under power metal #
###########################################
# set the lower and upper rec dot of first vddvss pair
set x1 5.970
set y1 0.000
set x2 7.450
set y2 1550.000
set pitch 14.58

# 
set ux1 0
set uy1 0
set ux2 0
set uy2 0
set i 0
create_placement_blockage -coordinate [list $x1 $y1 $x2 $y2] -name metal2_placement_blockage_${i} -type hard
for {set i 1} {$i<89} {incr i} {
    set x1 [expr {$x1+$pitch}]
#   set y1 [expr {}]
    set x2 [expr {$x2+$pitch}]
#    set y2 [expr {}]
        create_placement_blockage -coordinate [list $x1 $y1 $x2 $y2] -name metal2_placement_blockage_${i} -type hard 
 
}
