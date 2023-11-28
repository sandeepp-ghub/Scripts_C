#*************************************************************************#
# DISCLAIMER: The code is provided for Cadence customers                  #
# to use at their own risk. The code may require modification to          #
# satisfy the requirements of any user. The code and any modifications    #
# to the code may not be compatible with current or future versions of    #
# Cadence products. THE CODE IS PROVIDED \"AS IS\" AND WITH NO WARRANTIES,# 
# INCLUDING WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED          #
# WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.          #
#*************************************************************************#





proc net_total_length {pin} {  
   set total 0
   if { [get_pins -quiet $pin] != ""} {
       foreach wire_len [get_db pin:$pin .net.wires.length] {
          set total "[expr $total + $wire_len]"
       }
    } else {
       foreach wire_len [get_db port:$pin .net.wires.length] {
          set total "[expr $total + $wire_len]"
       }
    }
    return $total
}

proc layer_distribution {pin} {
    set layer_dist ""
    if {[get_pins $pin -quiet] != ""} {
       set layers [get_db pin:$pin .net.wires.layer.name -unique]
       foreach lay $layers {
         set layer_length 0
         foreach layer_index [lsearch -all [get_db pin:$pin .net.wires.layer.name] $lay] {
            set layer_length [expr $layer_length + [lindex  [get_db pin:$pin .net.wires.length] $layer_index]]
         }
         lappend layer_dist "$lay:$layer_length"
       }
    } else {
       set layer_dist ""
       set layers [get_db port:$pin .net.wires.layer.name -unique]
       foreach lay $layers {
         set layer_length 0
         foreach layer_index [lsearch -all [get_db port:$pin .net.wires.layer.name] $lay] {
            set layer_length [expr $layer_length + [lindex  [get_db port:$pin .net.wires.length] $layer_index]]
         }
         lappend layer_dist "$lay:$layer_length"
       }
    }
    set layer_dist [lsort $layer_dist]
    return $layer_dist
}

proc report_timing_wrapper {from to} {
    set_db timing_report_fields { delay arrival cell timing_point }   
    redirect rpt "report_timing -from $from -to $to -path_type full_clock "
	sed -i /^#/d rpt
    set fp [open "rpt" r]
    set file_data [read $fp]
    close $fp
    set data [split $file_data "\n"]
    set flag "0"
    foreach line $data {
       if {[regexp {.*Timing.*Point*} $line match ]} {
          echo "$line [format %[expr 135 - [string length "Timing Point"]]s NetLength] \t LayerDistribution"
          set flag "1"
       } elseif {[regexp {.*report_timing*} $line match ]} {
          echo $line
       } elseif {$flag == "1"} {
        # set pin_name "[lindex $line 9]"
          set pin_name "[lindex $line 3]"
          if {[get_pins $pin_name -quiet] != "" || [get_ports $pin_name -quiet] != ""} {
              echo "$line [format %[expr 75 - [string length $pin_name]]s [net_total_length $pin_name]] \t [layer_distribution $pin_name]"
          } else {
               echo $line
          }
       } else {
           echo $line
       }
    }
}
