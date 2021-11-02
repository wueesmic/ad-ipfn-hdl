###############################################################################
#
# project_implement_all.tcl: Tcl script for creating the VIVADO project
#
# Usage:
# vivado -mode batch -source project_implement_all.tcl
# See https://github.com/Digilent/digilent-vivado-scripts
################################################################################
set DEBUG_CORE true
# set DEBUG_CORE false
set WRITE_MCS true

# Set the reference directory to where the script is
set origin_dir [file dirname [info script]]
cd $origin_dir

source ../../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl

# set top_file system_top.v
set prog_file system_top


################################################################################
# install UltraFast Design Methodology from TCL Store
#################################################################################

tclapp::install -quiet ultrafast

#
################################################################################
# define paths
################################################################################

set path_rtl ../src/hdl
set path_ip  ../src/ip
set path_sdc ../src/constraints
set path_out ../output
set path_bd  ../fmcjesdadc1_kc705.srcs/sources_1/bd/system

if {$DEBUG_CORE == true} {
    set path_out ../output_dbg
} else {
    set path_out ../output
}

file mkdir $path_out
################################################################################
# setup the project
################################################################################

set device "xc7k325tffg900-2"
set board [lindex [lsearch -all -inline [get_board_parts] *kc705*] end]

## Create project
# set project_system_dir ".srcs/sources_1/bd/system"
create_project -in_memory -part $device

set_property board_part $board [current_project]

#create_bd_design "system"
#source ../system_bd.tcl

#save_bd_design
# add_files .srcs/sources_1/bd/system/system.bd
add_files "$path_bd/system.bd"

# open_bd_design .srcs/sources_1/bd/system/system.bd
open_bd_design "$path_bd/system.bd"
#validate_bd_design
#

read_verilog "$path_rtl/system_top.sv"
read_verilog "$path_rtl/shapi_regs_v1.sv"
read_verilog "$path_rtl/shapi_stdrt_dev_inc.vh"
read_verilog "$path_rtl/trigger_gen.v"

read_verilog  "../../common/fmcjesdadc1_spi.v"
read_verilog  "$ad_hdl_dir/library/common/ad_iobuf.v"
read_verilog  "$ad_hdl_dir/library/common/ad_sysref_gen.v"
# read_verilog  ".srcs/sources_1/bd/system/hdl/system_wrapper.v"
read_verilog  "$path_bd/hdl/system_wrapper.v"

# read_ip "$path_ip/xdma_0/xdma_0.xci"
read_ip "$path_ip/xdma_8g2/xdma_8g2.xci"

read_xdc "../system_constr.xdc" 
read_xdc "$ad_hdl_dir/projects/common/kc705/kc705_system_constr.xdc"

read_xdc "$path_sdc/kc705_sma_constr.xdc"
read_xdc "$path_sdc/pcie_xdma_kc705_x8g2.xdc"

update_compile_order -fileset sources_1
update_compile_order -fileset sources_1

# Optional: to implement put on Tcl Console
################################################################################
# run synthesis
# report utilization and timing estimates
# write checkpoint design (open_checkpoint filename)
################################################################################

set_param general.maxThreads 8

auto_detect_xpm
synth_design -top system_top -flatten_hierarchy none
#synth_design -top red_pitaya_top -flatten_hierarchy none -bufg 16 -keep_equivalent_registers

write_checkpoint         -force   $path_out/post_synth
report_timing_summary    -file    $path_out/post_synth_timing_summary.rpt
report_power             -file    $path_out/post_synth_power.rpt
################################################################################
## insert debug core
##
#################################################################################
if {$DEBUG_CORE == true} {
    source debug_core.tcl
}

opt_design
power_opt_design

place_design
# place_design -effort_level high
phys_opt_design
write_checkpoint         -force   $path_out/post_place
# report_timing_summary    -file    $path_out/post_place_timing_summary.rpt

#####################################################################
# run router
# report actual utilization and timing,
# write checkpoint design
# run drc, write verilog and xdc out
################################################################################

route_design
# route_design -effort_level high
write_checkpoint         -force   $path_out/post_route
report_timing_summary    -file    $path_out/post_route_timing_summary.rpt
# report_timing            -file    $path_out/post_route_timing.rpt -sort_by group -max_paths 100 -path_type summary

# report_clock_utilization -file    $path_out/clock_util.rpt
report_utilization       -file    $path_out/post_route_util.rpt
# report_power             -file    $path_out/post_route_power.rpt
#report_drc               -file    $path_out/post_imp_drc.rpt
# report_io                -file    $path_out/post_imp_io.rpt
#write_verilog            -force   $path_out/bft_impl_netlist.v
#write_xdc -no_fixed_only -force   $path_out/bft_impl.xdc

if {$DEBUG_CORE == true} {
    write_debug_probes -force $path_out/${prog_file}.ltx
}

# xilinx::ultrafast::report_io_reg -verbose -file $path_out/post_route_iob.rpt
write_bitstream -force        $path_out/${prog_file}.bit

close_project

# exit
