######################################################################
# look_one_level_up                                                  #
# get a collection and return a collection of cells regs rams ports  #
# in the data paths going from/to the given collection               #
#                                                                    #
# Lior Allerhand                                                     #
# 2/10/12                                                            #
# ####################################################################


proc look_one_level_up { args } {

# parse input args
parse_proc_arguments -args ${args} results

# sanity check on input arguments
if { $results(-type) ne "ram" && $results(-type) ne "cell" && $results(-type) ne "reg" && $results(-type) ne "mpin" && $results(-type) ne "ram_pin" || $results(-type) eq {} } {
      puts "Error: -type can only be of type ram, reg, cell, mpin ram_pin"
      return
}

  
#---------------- proc body -----------------------------------------#
# set all non clock or scan pins of all cells in inupt collection (can be one cell or more)
if {[info exists results(-pins)]} { 
    set cellsPinsIn  [filter_collection $results(input_collection) "direction == in AND name != SI AND name !=SE" ] ; # filter clock & scan & select pins
    set cellsPinsOut [filter_collection $results(input_collection) "direction == out AND name != SI AND name != SE"] ; # filter clock & scan & select pins
} else {
     set cellsPinsIn  [filter_collection [get_pins -of_object $results(input_collection) ] "is_on_clock_network != true AND is_scan_in != true AND is_scan_out != true AND direction == in AND name != SI AND name !=SE" ] ; # filter clock & scan & select pins
     set cellsPinsOut [filter_collection [get_pins -of_object $results(input_collection) ] "is_on_clock_network != true AND is_scan_in != true AND is_scan_out != true AND direction == out AND name != SI AND name != SE"] ; # filter clock & scan & select pins
  } 
# convert collection to list to be used by all_fan_in/out proc
 set inPinList ""
 set outPinList ""
 if { $cellsPinsIn ne ""  } { set inPinList [collection_to_list $cellsPinsIn   -name_only -no_braces] ; } 
 if { $cellsPinsOut ne "" } { set outPinList [collection_to_list $cellsPinsOut -name_only -no_braces] ; }

if {$results(-type) eq "ram"} {
     if {[info exists results(-flow)]} {
         if {$results(-flow) eq "in"} {
            set Points [all_fanin -to $inPinList -startpoints_only -only_cells -flat ]
         }
         if {$results(-flow) eq "out"} {
            set Points [all_fanout -from $outPinList -endpoints_only -only_cells -flat]
         }
     } else {
        set rami [all_fanin -to $inPinList -startpoints_only -only_cells -flat ]
        set ramo [all_fanout -from $outPinList -endpoints_only -only_cells -flat]
        set Points [add_to_collection $rami $ramo]  ; ###
       }
     #filter rams from start/end point collection
     set rams [filter_collection  $Points  "ref_name !~ *DRO* AND ref_name !~ *tcd* AND ref_name !~ *SERDES* AND ref_name !~ *PDCK* AND is_hard_macro == true"]; 
     if {[sizeof_collection $rams] > 0 } {  set my_return $rams } else { set my_return {} }
} 

if {$results(-type) eq "ram_pin"} {
     if {[info exists results(-flow)]} {
         if {$results(-flow) eq "in"} {
            set Points [all_fanin -to $inPinList -startpoints_only   -flat ]
            
#     set Points [remove_from_collection $Points [get_pins $inPinList]]
         }
         if {$results(-flow) eq "out"} {
            set Points [all_fanout -from $outPinList -endpoints_only  -flat]
#           set Points [remove_from_collection $Points [get_pins $outPinList]]
         }
     } else {
        set rami [all_fanin -to $inPinList -startpoints_only  -flat ]
        set ramo [all_fanout -from $outPinList -endpoints_only  -flat]
        set Points [add_to_collection $rami $ramo]  ; ###
       }
     #filter rams from start/end point collection
     set Points  [filter_collection $Points "object_class ==pin" ]
     set Points  [filter_collection $Points "is_on_clock_network != true AND is_scan_in != true AND is_scan_out != true AND name != SI AND name !=SE AND name !=D AND name !=Q" ] 
     
     set rams_pin ""
     foreach_in_collection p $Points {
        set rams [filter_collection  [get_cells -of_object $p]  "ref_name !~ *DRO* AND ref_name !~ *tcd* AND ref_name !~ *SERDES* AND ref_name !~ *PDCK* AND is_hard_macro == true"]; 
        if {[sizeof_collection $rams] > 0 } {  append_to_collection rams_pin $p  } else { append_to_collection rams_pin "" }     
     }
     if {[sizeof_collection $rams_pin] > 0 } {  set my_return $rams_pin } else { set my_return {} }

} 

if {$results(-type) eq "reg" } {
    if {[info exists results(-flow)]} {
        if {$results(-flow) eq "in" } {
            set Points [all_fanin -to $inPinList -startpoints_only -only_cells -flat ]
        }
        if {$results(-flow) eq "out" } {
            set Points [all_fanout -from $outPinList -endpoints_only -only_cells -flat]
        }
     } else {
         set regi [all_fanin -to $inPinList -startpoints_only -only_cells -flat ]
         set rego [all_fanout -from $outPinList -endpoints_only -only_cells -flat]
         set Points [add_to_collection $regi $rego]  ; #####only reg -only_cells do not take pins so no mpin in the collection.removing it is a problem as all pins in all the data paths will be in the collection
       }
     set regs [filter_collection  $Points  "is_hard_macro != true AND is_sequential == true"]; 
     if {[sizeof_collection $regs] > 0 } { set my_return $regs } else {  set my_return {} }
} 

if {$results(-type) eq "cell"} {
     if {[info exists results(-flow)]} {
         if {$results(-flow) eq "in"} {
             set Points [all_fanin -to $inPinList -only_cells -flat ]
         }
         if {$results(-flow) eq "out"} {
             set Points [all_fanout -from $outPinList -only_cells -flat]
         } 
     } else {
             set cellpi [all_fanin -to $inPinList -only_cells -flat ]
             set cellpo [all_fanout -from $outPinList -only_cells -flat]
             set Points [add_to_collection $cellpi $cellpo]  ; 
           }

     set cells $Points ; 
     if {[sizeof_collection $cells] > 0 } { puts "find cells at level" ; set my_return $cells } else { puts "no cells for this level"; set my_return {} }
} 

if {$results(-type) eq "mpin"} {
     if {[info exists results(-flow)]} {
         if {$results(-flow) eq "in"} {
            set Points [all_fanin -to $inPinList -startpoints_only  -flat ]
         }
         if {$results(-flow) eq "out"} {
            set Points [all_fanout -from $outPinList -endpoints_only  -flat]
         } 
      } else {
          set mpini [all_fanin -to $inPinList -startpoints_only  -flat ]
          set mpino [all_fanout -from $outPinList -endpoints_only  -flat]
          set Points [add_to_collection $mpini $mpino]  ; #####only reg -only_cells do not take pins so no mpin in the collection.
        }

     
     set mpin [filter_collection  $Points  "object_class == port"]; 
     if {[sizeof_collection $mpin] > 0 } { set my_return $mpin } else { set my_return {} }
} 


if {[info exists results(-highlight)]} { gui_change_highlight -add -color $results(-highlight)  -collection $my_return } 

return $my_return
}; #end of procs

define_proc_attributes look_one_level_up  \
    -info "will find reg || cells || pins ||rams that are on a timing path with a input collcetion of cells" \
    -define_args {
                   {-flow "get only object flowing in to or out of the input collection" "in OR out" string optional}        
                   {input_collection "input collection of cells"       input_collection list required}
                   {-pins "boolean flag used if starting point collection is of pins instead of cells"   "" boolean optional}                   
                   {-highlight "highlight the new collection in gui" ""  one_of_string {optional value_help {values {yellow orange red green blue purple light_orange light_red light_green light_blue light_purple}}}}
                   {-type "type of object to look for one level up the timing path" {required value_help {values {ram ram_pin reg cell mpin}}}}
                  

}

#  set DpinLevelOneFlowIn [filter_collection [get_pins -of_object $regi] "name==D"]
#     set QpinLevelOneFlowOut [filter_collection [get_pins -of_object $rego] "name=~*Q*"]


