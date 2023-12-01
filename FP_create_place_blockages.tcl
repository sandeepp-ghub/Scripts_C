### Proc to add density screen within a given box x1 y1 x2 y1
#
#### The input variables to the proc is the box --> "x1 y1 x2 y2";
#
#### x and y are the values to split the box into smaller boxes as 50x50 or 50x60 etc
#
#### Density is the partial placement blockage value as an input
#
#
#
proc density_screen {x1 y1 x2 y2 x y density} {


set a1 $x1
set b1 $y1
set a2 [expr $a1 + $x]
set b2 [expr $b1 + $y]
create_place_blockage -type partial -density $density -area "$a1 $b1 $a2 $b2" -use_prefix                              
set j $x1
set i $y1
while {$i <= $y2} {



         while {$j < $x2} {

                          set a1 [expr $a1 + $x]
set a2 [expr $a1 + $x]
set j $a2
if {$a2 <= $x2} {

create_place_blockage -type partial -density $density -area "$a1 $b1 $a2 $b2" -use_prefix                     

}

}
set b1 [expr $b1 + $y]
set b2 [expr $b1 + $y]
set i $b2
set j $x1
set a1 $x1
set a2 [expr $a1 + $x]
if {$b2 <= $y2} {

create_place_blockage -type partial -density $density -area "$a1 $b1 $a2 $b2" -use_prefix                     

}

}

}


