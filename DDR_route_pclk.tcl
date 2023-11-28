set nets "net:dwc_ddrphy_pnr_block/dwc_ddrphy_macro_0/u_DWC_DDRPHY0_top/dwc_ddrphy_top_i/PclkC0 \
net:dwc_ddrphy_pnr_block/dwc_ddrphy_macro_0/u_DWC_DDRPHY0_top/dwc_ddrphy_top_i/PclkC1 \
net:dwc_ddrphy_pnr_block/dwc_ddrphy_macro_0/u_DWC_DDRPHY0_top/dwc_ddrphy_top_i/PclkDatC0 \
net:dwc_ddrphy_pnr_block/dwc_ddrphy_macro_0/u_DWC_DDRPHY0_top/dwc_ddrphy_top_i/PclkDatC1"

set_db [get_db $nets] .dont_touch true
create_route_rule -name snet_ndr -width_multiplier {M4:M16 2} -spacing_multiplier {M4:M16 2}

foreach net $nets {
    set_route_attributes -nets [get_db $net .name]  -top_preferred_routing_layer 16 -bottom_preferred_routing_layer 15 -preferred_routing_layer_effort high -weight 8 -shield_net VSS -shield_side two_sides -route_rule snet_ndr
}

select_obj $nets
set_db route_design_selected_net_only true
set_db route_design_with_timing_driven false
set_db route_design_with_si_driven false
route_eco / route_design
edit_update_route_status -nets [get_db $net .name ] -to fixed
