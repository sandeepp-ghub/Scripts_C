
#catch {setEcoMode -batchMode false}
#catch {setEcoMode -batchMode true -honorDontTouch false  -honorDontUse false  -honorFixedNetWire false -honorFixedStatus false -LEQCheck false  -refinePlace false -updateTiming false -prefixName ECO_HFix_1109}

###################
proc addBuffAlongRoute {NetName PinName {buff_cell BUFFD6BWP300H8P64PDULVT } {inv_cell INVD6BWP300H8P64PDULVT} {prefix on_route_buff}} {
    global k
    if {![info exists k]} {set k [format %0.0f [expr ceil([expr rand()] * 100000)]]}
    set BufBased 1; set InvBased 0

    set ViolTerm [dbGetTermByName $PinName]
    set NetObj [dbGetNetByName $NetName] 

    #set driveTerm [dbGet -e  $NetObj.allTerms.isOutput 1 -p1]
    set driveTerm [dbGet -e  $NetObj.instTerms.isOutput 1 -p1]
    set recvTerms [dbGet -e  $NetObj.allTerms.isInput 1 -p1]
    if {$driveTerm == ""} {set driveTerm [dbget -e  [dbget -e top.terms.name $NetName -p].direction input -p]}
    if {$recvTerms == ""} {set recvTerms [dbget -e  [dbget -e top.terms.name $NetName -p].direction output -p]}
    if {$recvTerms != "" && $driveTerm != ""} {
    set numInTerms [llength $recvTerms]

    foreach Wire [dbGet $NetObj.wires] {
	foreach recvTerm $recvTerms {
	    set WireHash($Wire,$recvTerm) 0
	}
    }

    foreach recvTerm $recvTerms {
	deselectAll
	selectNetP2P $driveTerm $recvTerm
	foreach Wire [dbGet selected.objType wire -p1] {
	    set WireHash($Wire,$recvTerm) 1   
	}
    }

    set TotalWire 0
    deselectAll
    selectNetP2P $driveTerm $ViolTerm

    set LongestWireLength [dbGet [lindex [dbGet selected.objType wire -p1] 0].length]
    set LongestWire [lindex [dbGet selected.objType wire -p1] 0]
    foreach Wire [dbGet selected.objType wire -p1] {
	set WireLength [dbGet $Wire.length]
	if {$WireLength > $LongestWireLength} {
	    set LongestWire $Wire
	    set LongestWireLength $WireLength
	}
	set TotalWire [expr $TotalWire + $WireLength]
    }  

    deselectAll
    set LLX [dbGet $LongestWire.box_llx]
    set LLY [dbGet $LongestWire.box_lly]
    set URX [dbGet $LongestWire.box_urx]
    set URY [dbGet $LongestWire.box_ury]

    set ReqTerms ""
    foreach recvTerm $recvTerms {
	if {$WireHash($LongestWire,$recvTerm)==1} {
	    lappend ReqTerms [dbGet $recvTerm.name]
	}
    }

    set  llx_lly_dist  [get_distance [dbget  $driveTerm.pt] [list $LLX $LLY]]
    set  urx_ury_dist  [get_distance [dbget  $driveTerm.pt] [list $URX $URY]]

    if {$LongestWireLength >= 70 } {set BufBased 0; set InvBased 1} else {set BufBased 1; set InvBased 0}
    if {$BufBased} {
	if {$urx_ury_dist > $llx_lly_dist} {
	    set Scale 0.3
	} else {
	    set Scale 0.7
	}
	set NewX [expr ($LLX + $Scale*($URX-$LLX))]
	set NewY [expr ($LLY + $Scale*($URY-$LLY))]
    }
    if ($InvBased) {
	if {$urx_ury_dist > $llx_lly_dist} {
	    set Scale 0.05
	    set NewX1 [expr ($LLX + $Scale*($URX-$LLX))]
	    set NewY1 [expr ($LLY + $Scale*($URY-$LLY))]
	    set Scale 0.5
	    set NewX2 [expr ($LLX + $Scale*($URX-$LLX))]
	    set NewY2 [expr ($LLY + $Scale*($URY-$LLY))]
	} else {
	    set Scale 0.95
	    set NewX1 [expr ($LLX + $Scale*($URX-$LLX))]
	    set NewY1 [expr ($LLY + $Scale*($URY-$LLY))]
	    set Scale 0.5
	    set NewX2 [expr ($LLX + $Scale*($URX-$LLX))]
	    set NewY2 [expr ($LLY + $Scale*($URY-$LLY))]

	}
    }

    if {$BufBased} {
	incr k
	catch {ecoAddRepeater -term $ReqTerms  -cell $buff_cell  -name u_${prefix}_${k} -new_net_name n_${prefix}_${k} -loc [list  $NewX $NewY ]}
	#echo "ecoAddRepeater -term $ReqTerms  -cell $buff_cell  -name u_${prefix}_${k} -new_net_name n_${prefix}_${k} -loc [list  $NewX $NewY ]"
    } elseif {$InvBased} {
	incr k
	catch {ecoAddRepeater -term $ReqTerms -cell $inv_cell -loc [list $NewX1 $NewY1 ] -name u_${prefix}_${k} -new_net_name n_${prefix}_${k}}
	#echo "ecoAddRepeater -term $ReqTerms -cell $inv_cell -loc [list $NewX1 $NewY1 ] -name u_${prefix}_${k} -new_net_name n_${prefix}_${k}"
	incr k
	catch {ecoAddRepeater -term $ReqTerms -cell $inv_cell -loc [list $NewX2 $NewY2 ] -name u_${prefix}_${k} -new_net_name n_${prefix}_${k}}
	#echo "ecoAddRepeater -term $ReqTerms -cell $inv_cell -loc [list $NewX2 $NewY2 ] -name u_${prefix}_${k} -new_net_name n_${prefix}_${k}"
    }
    }  else {
	echo "INFO:: ------> Terms not found for $NetName"
    }
    #echo $ReqTerms
}
################
