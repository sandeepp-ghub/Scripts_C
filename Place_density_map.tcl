proc userReportDensityMap {gifFile rptFile {gui_zoom gui_show}} {
   if { $gui_zoom == "gui_show" } { gui_show }
   if { $gui_zoom != "gui_show" } { eval "[concat gui_zoom $gui_zoom]" }
   update idletasks

   # Set Density map color settings, can comment if want default color settings
   #set_layer_preference densityMap -color {navy blue green yellow red red red red red red}
   
   # Set layout options
   set net [get_layer_preference net -is_visible]
   set stdCell [get_layer_preference stdCell -is_visible]
   set stdRow [get_layer_preference stdRow -is_visible]
   set power [get_layer_preference power -is_visible]
   set congest [get_layer_preference congest -is_visible]
   set_layer_preference densityMap -is_visible 1
   set_layer_preference congest -is_visible 0
   set_layer_preference power -is_visible 0
   set_layer_preference net -is_visible 0
   set_layer_preference stdCell -is_visible 0
   set_layer_preference stdRow -is_visible 0

   # Modify settings if necessary.
   set_db report_place_density_map_grid_size 5 
   set_db report_place_density_map_threshold 0.65 
   
   redirect -quiet $rptFile {report_density_map}
   
   # Dump into a gif file
   write_to_gif $gifFile
   
   # Reset the mapping file
   set_layer_preference densityMap -is_visible 0
   set_layer_preference net -is_visible $net
   set_layer_preference stdCell -is_visible $stdCell
   set_layer_preference stdRow -is_visible $stdRow
   set_layer_preference power -is_visible $power
   set_layer_preference congest -is_visible $congest
   
}
proc userReportCongestionMap {gifFile rptFile {gui_zoom gui_show}} {
   if { $gui_zoom == "gui_show" } { gui_show }
   if { $gui_zoom != "gui_show" } { eval "[concat gui_zoom $gui_zoom]" }
   update idletasks

   # Set Density map color settings, can comment if want default color settings
   #set_layer_preference densityMap -color {navy blue green yellow red red red red red red}
   set_layer_preference congestV -color {#000066 #0000c9 #0053ff #00fcfa #00a953 #53a900 #f9fc00 #ff5300 #ff5858 #ffffff} 
   # Set layout options
   set net [get_layer_preference net -is_visible]
   set stdCell [get_layer_preference stdCell -is_visible]
   set stdRow [get_layer_preference stdRow -is_visible]
   set power [get_layer_preference power -is_visible]
   set congest [get_layer_preference congest -is_visible]
   set_layer_preference densityMap -is_visible 0
   set_layer_preference groupmain_Congestion -is_visible 1
   set_layer_preference congestH -is_visible 1
   set_layer_preference congestV -is_visible 1
   set_layer_preference congest -is_visible 1
   set_layer_preference power -is_visible 0
   set_layer_preference node_net -is_visible 0   
   set_layer_preference net -is_visible 0
   set_layer_preference stdCell -is_visible 1
   set_layer_preference stdRow -is_visible 0
   set_layer_preference node_blockage -is_visible 0

   # Modify settings if necessary.
   set_db report_place_density_map_grid_size 5 
   set_db report_place_density_map_threshold 0.65 
   
   redirect -quiet $rptFile {report_congestion}
   
   # Dump into a gif file
   write_to_gif $gifFile
   
   # Reset the mapping file
   set_layer_preference densityMap -is_visible 0
   set_layer_preference net -is_visible $net
   set_layer_preference stdCell -is_visible $stdCell
   set_layer_preference stdRow -is_visible $stdRow
   set_layer_preference power -is_visible $power
   set_layer_preference congest -is_visible $congest
   
}





