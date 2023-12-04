proc mirror_hinst_pin { args } {
    if {[mint_parse_args t $args]} {
        if { [info exists t(-pinref)] } { set pinref $t(-pinref) } else { print "pinref arg is missing" ; return -1 }
        if { [info exists t(-pin)] } { set pin $t(-pin) } else { print "pin arg is missing" ; return -1 }
        if { [info exists t(-edge)] } { set edge $t(-edge) } else { print "edge arg is missing" ; return -1 }
    
     }


	    set layer_name [get_db $pinref .layer.name]
            set hinst [get_db $pin .hinst.name ]
	    if {![llength $hinst]} {
		puts "pin doesnt exists"
		return -1
            }
	    
            set pin_w [get_db [get_db layers $layer_name] .width]
            set pin_a [get_db [get_db layers $layer_name] .area]
            set pin_d [expr ceil(1000*($pin_a / $pin_w))/1000]

            set ref_x [get_db $pinref .location.x]
            set ref_y [get_db $pinref .location.y]

        set is_vert [expr !($edge % 2)]
        
        if {$is_vert } {
        set y $ref_y
	set x [lindex {*}[get_db [get_db hinsts $hinst] .boundary.rects ] $edge]
	} else {
        set x $ref_x
	set y [lindex {*}[get_db [get_db hinsts $hinst] .boundary.rects ] $edge]
        }

        set ep_cmd "edit_pin -fixed_pin 1 \
                             -pin_width $pin_w \
                             -pin_depth $pin_d \
                             -fix_overlap 0 \
                             -edge $edge \
                             -include_rectilinear_edge \
                             -layer $layer_name \
                             -global_location \
                             -assign \{$x $y\} \
			     -hinst $hinst \
                             -pin [get_db $pin .base_name]"
       eval $ep_cmd		
}
mint_define_generic_get_cfg_args mirror_hinst_pin \
	"Place specific pin of hinst" \
	{ 
	{ -pinref " reference pin  to mirror" {pinref} string required } \
	{ -pin " reference pin  to mirror" {pin} string required } \
	{ -edge " reference pin  to mirror" {edge} string required } \

}

set_db assign_pins_edit_in_batch true

foreach port [get_db ports rst__pcl_rsh_grstate* rst__pcl_rsh_drstate* fus__pcl_fuse_serial* pcl__til_gib_grant pcl__til_rml*] {

set hnet_obj [get_db $port .hnet]
set hpins [concat [get_db $hnet_obj .drivers] [get_db $hnet_obj .loads]]  

foreach pin_name $hpins {
if { [regexp {tad1/} $pin_name ]} {
set cmd "mirror_hinst_pin -pinref $port -pin $pin_name -edge 2"
puts $cmd
eval $cmd
}
}
}


