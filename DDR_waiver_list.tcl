#set paths [get_timing_paths -delay_type min -group {fc_scan___PBA__scan_rclk gpio_scan_rclk} -max_paths 1000000 -nworst 100 -pba_mode e -significant_digits 6]
set paths [get_timing_paths -delay_type max -group {dss0__PBA__dwc_phy_ref_clk_ddr5} -max_paths 1000000 -nworst 100 -pba_mode e ]
set paths [get_timing_paths -delay_type min -group {fc_scan___PBA__scan_rclk} -max_paths 1000000 -nworst 100 -pba_mode e ]

set paths [get_timing_paths -delay_type min -group {fc_scan___PBA__scan_rclk gpio_scan_rclk} -max_paths 1000000 -nworst 100 -pba_mode e ]


set i 0
if {[info exists MYDB]} {unset MYDB}
echo "" > mtmp
foreach_in_collection path $paths {
    set slack [get_attribute $path slack]
    set ptm [get_attribute $path path_margin]
    set oslack [get_attribute $path slack]
    set startpoint [get_object_name [get_attribute $path startpoint]]
    set endpoint [get_object_name [get_attribute $path endpoint]]
    if {[info exists MYDB($startpoint,$endpoint)]} {
        continue
    } else {
        set MYDB($startpoint,$endpoint) 1
        set slack [expr $slack + $ptm - 0.00005]
        if  {$slack > -0.0005} {set slack -0.0005 }
#set slack -0.0005
# echo "$slack $startpoint $endpoint"
        incr i
        if {![regexp {dss0} $startpoint] && ![regexp {dss0} $endpoint]} {continue}
#        echo $i
        #echo "set_path_margin -hold $slack -to $endpoint" 
         echo "set_path_margin -hold $slack -from $startpoint -to $endpoint ;# $oslack" 
#echo $endpoint >> qqqqqq

    }
}
