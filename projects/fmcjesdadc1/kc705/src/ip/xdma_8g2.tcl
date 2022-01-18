#https://grittyengineer.com/creating-vivado-ip-the-smart-tcl-way/
#
set path_ip [file dirname [info script]]

set part xc7k325tffg900-2
## Create project
create_project -in_memory -part $part
set board [lindex [lsearch -all -inline [get_board_parts] *kc705*] end]
set_property board_part $board [current_project]

set ip_name xdma_8g2
# Just in case
if { [file exists $path_ip/$ip_name/$ip_name.dcp]} {
    puts "file exist: $path_ip/$ip_name.dcp, delete it."
    file delete -force $path_ip/$ip_name/$ip_name.dcp
}
#
#create_ip -name xdma -vendor xilinx.com -library ip -version 4.1 
create_ip -vlnv xilinx.com:ip:xdma:4.1 -module_name $ip_name \
    -dir $path_ip -force

set_property -dict [list CONFIG.Component_Name {$ip_name} \
    CONFIG.pl_link_cap_max_link_width {X8} \
    CONFIG.pl_link_cap_max_link_speed {5.0_GT/s} \
    CONFIG.axi_data_width {128_bit} \
    CONFIG.axisten_freq {250} CONFIG.pf0_device_id {7028} \
    CONFIG.axilite_master_en {true} CONFIG.xdma_wnum_rids {32} \
    CONFIG.plltype {QPLL1} CONFIG.xdma_axi_intf_mm {AXI_Stream} \
    CONFIG.pf0_msix_cap_table_bir {BAR_1} \
    CONFIG.pf0_msix_cap_pba_bir {BAR_1} CONFIG.cfg_mgmt_if {false} \
    CONFIG.PF0_DEVICE_ID_mqdma {9028} CONFIG.PF2_DEVICE_ID_mqdma {9028} \
    CONFIG.PF3_DEVICE_ID_mqdma {9028}] [get_ips $ip_name]


generate_target all [get_ips]

# Synthesize all the IP
synth_ip [get_ips]
