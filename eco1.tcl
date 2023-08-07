
##################
#### Don't Change anything below -
#### Please remove fillers before sourcing this file
### After sourcing perform - refineplace/ecoplace & ecoroute
source /t11k/pnrwork35/users/kpavan/Scripts/scripts/my_procs.tcl
##################
## Do net-segment based split or not
if {![info exists use_on_route_for_all]} {set use_on_route_for_all 0}
##################

set all_init_noise_nets [get_nets -quiet -of [get_pins -quiet  $vio_list]]
set dtouch_nets [get_db nets -if {.is_dont_touch}]
set skip_nets   [get_db nets -if {.skip_routing}]

set all_noise_nets [remove_from_collection [remove_from_collection $all_init_noise_nets [get_nets -quiet $dtouch_nets]] [get_nets -quiet $skip_nets]]

#set split_length_inverter 150
#set min_length 50
set split_length_inverter 120
set min_length 35

#############
if {![info exists day_stamp]} {set day_stamp [exec date +%m%d]}
if {![info exists j]} {set j 0}
if {![info exists block]} {set block ""}

##################
global k
set k 0
set prefix xtalk_noisefix_${block}_${day_stamp}_${j}
redirect  xtalk_fix_swap_cell_eco_${day_stamp}.tcl {}
#################

set_eco_mode

foreach net [get_object_name $all_noise_nets] {
    ################

    set length [gnl $net]
    set add_buff 1
    set load_pins [get_property [get_nets -quiet $net] num_load_pins]
    if {$load_pins > 1} {
	set add_buff 0
    }
    if {$length <= $min_length} {
	set add_buff 0
    }
    set add_inverter 0
    if {$length > $split_length_inverter} {set add_inverter 1}

    ##############
    set driver_inst [get_driver $net]
    set driver [get_driver_cell $net]
    set driver_ds [ get_strength $driver]

    ## Upsizing and VTSWAP
    if {[regexp BWP $driver]} {
	if { ( [regexp BUFF $driver] ||  [regexp INV $driver])  && ![regexp CVM $driver] && ![regexp LVL $driver]} {
	    #redirect -append xtalk_fix_swap_cell_eco_${day_stamp}.tcl {get_my_upsize_cell $driver_inst 4 0 1}
	    redirect -append xtalk_fix_swap_cell_eco_${day_stamp}.tcl {get_my_upsize_cell $driver_inst 0 0 1}
	} else {
	    redirect -append xtalk_fix_swap_cell_eco_${day_stamp}.tcl {get_my_upsize_cell $driver_inst 0 0 1}
	}
    }
    ###
    ## Macro DRIVERS
    if {![regexp BWP $driver]} {
	set driver NA
    }
    ###
    ## Default 
    set buff_cell BUFFSKPD12BWP300H8P64PDULVT
    set buff_short BUFFSKPD4BWP300H8P64PDULVT

    set inv_cell INVSKPD12BWP300H8P64PDULVT
    set inv_short INVSKPD4BWP300H8P64PDULVT

    ## Make default driver as 6?
    if {$driver_ds == "NA"} { set driver_ds 6}
    if {$driver_ds == "NA"} {
    } else {
	set buff_cell [lindex [dbget -e head.libcells.name BUFFD${driver_ds}*ULVT] 0]
	set buff_short $buff_cell

	set inv_cell [lindex [dbget -e head.libcells.name INVD${driver_ds}*ULVT] 0]
	set inv_short $inv_cell
    }


    #####

    if {$add_buff} {
	if {$use_on_route_for_all} {
	    ## Multi-Fanout Nets
	    
	    set multi_fo_pins [remove_from_collection -intersect [get_pins -quiet $vio_list ] [get_property [get_nets -quiet  $net] load_pins]]
	    
	    set _dist 0
	    set _driver [get_object_name [get_attribute [get_nets -quiet  $net] driver_pins]]
	    set farthest_load ""
	    if { [llength $_driver] > 0} {
		foreach _load [get_object_name $multi_fo_pins] {
		    set _dist1 [get_distance [get_location $_driver] [get_location $_load]]
		    if {$_dist1 >= $_dist} {set _dist $_dist1 ; set farthest_load $_load}
		}
		if {[llength $farthest_load] > 0} {
		    catch {addBuffAlongRoute $net $farthest_load $buff_cell $inv_cell $prefix}
		}
	    }
	} else {
	    if {$add_inverter} {
		incr k
		catch {ecoAddRepeater -net $net -cell $inv_cell -relativeDistToSink 0.33 -name u_${prefix}_${k} -new_net_name n_${prefix}_${k}}
		incr k
		catch {ecoAddRepeater -net $net -cell $inv_cell -relativeDistToSink 0.5 -name u_${prefix}_${k} -new_net_name n_${prefix}_${k}}
	    } else {
		incr k
		catch {ecoAddRepeater -net $net -cell $buff_cell -relativeDistToSink 0.5 -name u_${prefix}_${k} -new_net_name n_${prefix}_${k}}
	    }
	    if {$driver_ds == "NA"} {
		## For Macro - Outputs and for INput-PortNets - add one extra buffer close to driver
		#### incr k
		#### catch {ecoAddRepeater -net $net -cell $buff_cell -relativeDistToSink 0.99 -name u_${prefix}_${k} -new_net_name n_${prefix}_${k}}
	    }
	}
    } else {
	## Multi-Fanout Nets
	if {$length >= 30} {
	    set multi_fo_pins [remove_from_collection -intersect [get_pins -quiet $vio_list ] [get_property [get_nets -quiet  $net] load_pins]]

	    set _dist 0
	    set _driver [get_object_name [get_attribute [get_nets -quiet  $net] driver_pins]]
	    set farthest_load ""
	    if { [llength $_driver] > 0} {
		foreach _load [get_object_name $multi_fo_pins] {
		    set _dist1 [get_distance [get_location $_driver] [get_location $_load]]
		    if {$_dist1 >= $_dist} {set _dist $_dist1 ; set farthest_load $_load}
		}
		if {[llength $farthest_load] > 0} {
		    echo "Doing MF BUFFERING for Net -- $net"
		    catch {addBuffAlongRoute $net $farthest_load $buff_cell $inv_cell ${prefix}_mfo}
		}
	    }
	}
    }
}
catch {setEcoMode -batchMode false -honorDontTouch true  -honorDontUse true  -honorFixedNetWire true -honorFixedStatus true -LEQCheck true  -refinePlace true -updateTiming true -prefixName ECO}	
##################################################
## Source Cell Swaps
catch {setEcoMode -batchMode false}
catch {setEcoMode -batchMode true -honorDontTouch false  -honorDontUse false  -honorFixedNetWire false -honorFixedStatus false -LEQCheck true  -refinePlace false -updateTiming false -prefixName ECO_HFix_${day_stamp}}

source -verbose xtalk_fix_swap_cell_eco_${day_stamp}.tcl

catch {setEcoMode -batchMode false -honorDontTouch true  -honorDontUse true  -honorFixedNetWire true -honorFixedStatus true -LEQCheck true  -refinePlace true -updateTiming true -prefixName ECO}

##################################################
catch {foreach net [get_object_name [get_nets -quiet -of [get_pins -quiet *xtalk_noisefix_*/*]]] {setAttribute -net $net -avoid_detour true}}
##################################################
