set ports [get_selection ]
set yrunner 0
set inr     0

foreach_in_collection  p $ports {
    puts "lioral-Info: runing on port [get_object_name $p]"
    resize_objects -bbox {0 0 0.06 0.06} -no_snap $p
    move_objects -to "-10 $yrunner" $p
    set ydelta [expr {$yrunner + 0.06}]
    create_terminal -bbox "-10. $yrunner -9.94 $ydelta" -layer metal3 -port [get_object_name $p] -name [get_object_name $p] -direction left
    set yrunner [expr {$yrunner + 0.36}]
}
