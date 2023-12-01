proc userDrawHotSpots { { filename "" } } {

   global env

   set hotspotfilename $filename

   if { $hotspotfilename == "" } {
      if { [ is_common_ui_mode ] } {
         eval_legacy { reportCongestion -hotspot > userDrawHotSpots.txt }
      } else {
         reportCongestion -hotspot > userDrawHotSpots.txt
      }
      set hotspotfilename "userDrawHotSpots.txt"
   } elseif { [ file exists $filename ] == 0 } {
      puts "ERROR:  Cannot find hot spot file named filename"
      return
   }

   set f [ open $hotspotfilename "r" ]

   gets $f buf

   while { ( [ eof $f ] == 0 ) && ( [ string first " top " $buf ] == -1 ) } {
      gets $f buf
   }
 
   set numhotspots 0

   set topndx [ string first " top " $buf ]

   if { $topndx == 9 } {

      scan $buf "%s %s %i" tmp1 tmp2 numhotspots

      gets $f buf
      gets $f buf
      gets $f buf

      for { set i 1 } { $i <= $numhotspots } { incr i } {

         gets $f buf
   
         set hotspotnum -1
         set x1 -1.0
         set y1 -1.0
         set x2 -1.0
         set y2 -1.0
         set score -1.0

         scan $buf "%s %s %i %s %f %f %f %f %s %f" tmp1 tmp2 hotspotnum tmp3 x1 y1 x2 y2 tmp4 score

         if { [ is_common_ui_mode ] } {
            set env(CongScore) $score
            set env(CongX1) $x1
            set env(CongY1) $y1
            set env(CongX2) $x2
            set env(CongY2) $y2
            eval_legacy { global env ; createMarker -tool reportCongestion -type CongHotSpot -bbox [ list $env(CongX1) $env(CongY1) $env(CongX2) $env(CongY2) ] -desc "Congestion Hotspot - Score: $env(CongScore) " }
         } else {
            createMarker -tool reportCongestion -type HotSpot -bbox [ list $x1 $y1 $x2 $y2 ] -desc "Congestion Hotspot - Score: $score "
         }

         gets $f buf
      }
   }

   close $f

   puts "INFO: $numhotspots hot spot markers drawn."
}

