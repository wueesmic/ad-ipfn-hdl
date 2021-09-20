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

# source ../../../scripts/adi_env.tcl
# source $ad_hdl_dir/projects/scripts/adi_board.tcl
# source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl

# set top_file system_top.v
set prog_file system_top

# Set the reference directory to where the script is
set origin_dir [file dirname [info script]]

cd $origin_dir
#
################################################################################
# install UltraFast Design Methodology from TCL Store
#################################################################################

tclapp::install -quiet ultrafast

#
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


set_param general.maxThreads 8


open_checkpoint            $path_out/post_synth.dcp
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

# xilinx::ultrafast::report_io_reg -verbose -file $path_out/post_route_iob.rpt
write_bitstream -force            $path_out/${prog_file}.bit

close_project

# exit
