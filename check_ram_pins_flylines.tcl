#"Check that at least 70% of the rams's ports route is not going over the ram itself. Check should be perform per ram instance."
#- Please set:
#- set stage                                             place
#- set arr(check,${stage}:Check_RAMs_Ports_FlyLines,max) 70
proc Check_RAMs_Ports_FlyLines {}    {

    # --- Initializations ---
    set status ""   ; # PASS/FAIL 
    global arr
    global stage

        # --- Initializations ---
        set name Check_RAMs_Ports_FlyLines
        set result     0
        set violations ""
        set info "The following memories have more than 70% of their route above itself: \
        \n[format "%-*s %-*s" 12 "<Percentage>" 120  "<Inst name>"] \
        \n[string repeat "-" 120]\n"
        set num_of_check     0
        set no_memories_flag 1
        if {![info exists arr(check,${stage}:Check_RAMs_Ports_FlyLines,max)]} {set arr(check,${stage}:Check_RAMs_Ports_FlyLines,max) 70}
        set max  $arr(check,${stage}:Check_RAMs_Ports_FlyLines,max)
        foreach mmdb [get_db insts -if {.is_macro==true}] {

        #foreach mmdb [dbGet selected ] {}
                #if ![regexp /memory [dbget $mmdb.name]] { continue } 
                set no_memories_flag 0
                foreach {x1 y1 x2 y2 } [lindex [get_db  $mmdb .bbox] 0] {}
#               append info [dbget $mmdb.name]
                set list [get_db  $mmdb .pins]
                set llPin [llength $list]
                set xOk 0; set xNok 0; set ConPins 0
                foreach trdb $list {
                        set pin [get_db $trdb .name]
                        set xp1 [get_db $trdb .location.x]
                        set yp2 [get_db $trdb .location.y]
                        set net [get_db $trdb .net]
                        set aX 0; set aY 0; set cnt 0
                        foreach ip [get_db $net .load_pins] {
                            if {$ip==$pin} { continue }
                            
                            set xi1 [get_db $ip .location.x]
                            set yi1 [get_db $ip .location.y]
                            #puts ===[dbget $ipdb.pt]==\n$net=net\n==$ipdb;
                            if {$xi1!="NA"} {
                                incr cnt ; set aX [expr $aX+$xi1]; set aY [expr $aY+$yi1];  
                                #puts ===$xi1:$aX==$cnt==ip
                            }
                        }
                        if {$cnt>0} {
                                incr ConPins
                                set avx [expr $aX/$cnt] 
                                set ayx [expr $aY/$cnt]
                                if {[expr abs($x1-$xp1)]<0.2} {
                                        if {$x2<$avx}   { incr xNok 
                                        } else          { incr xOk }
                                } else {
                                        if {$x1>$avx}   { incr xNok 
                                        } else          { incr xOk }
                                }
                                
                        }
                }
                set pre [expr int(100*$xNok/$ConPins) ]
            #   if {$pre>$max} { append info "$pre%  = pre\t\t  $xOk=xOk $xNok=xNok  $ConPins/$llPin=pins  [dbget $mmdb.name]   Check_RAMs_Ports_FlyLines\n";}              
                if {$pre>$max} { 
                    append violations "[format "%-*s %-*s" 12 "$pre%" 120  "[get_db  $mmdb .name]"]\n"
                    incr result
                }
                #append result "[format "%-*s %-*s" 12 "$pre%" 120  "[get_db  $mmdb .name]"]\n"  
            incr num_of_check
        }
    # if there are no memories - the checker should pass     
    if $no_memories_flag {
        append info "INFO: There are no rams in the design"
        set num_of_check 0
    }


    if {$violations eq ""} {
        set status "PASS"
    } else {
        set status "FAIL"
    }

    # --- Results Values ---    
    set arr($stage,$name,info)         $info
    set arr($stage,$name,num_of_check) $num_of_check
    set arr($stage,$name,violations)   $violations
    set arr($stage,$name,result)       $result
    set arr($stage,$name,status)       $status



}

