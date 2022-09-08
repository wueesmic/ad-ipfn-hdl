
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl

# get_env_param retrieves parameter value from the environment if exists,
# other case use the default value
#
#   Use over-writable parameters from the environment.
#
#    e.g.
#      make RX_JESD_L=4 RX_JESD_M=2
#      make RX_JESD_L=4 RX_JESD_M=4 

# Parameter description:
#   RX_JESD_M : Number of converters per link
#   RX_JESD_L : Number of lanes per link
#   RX_JESD_S : Number of samples per frame
#   RX_JESD_NP : Number of bits per sample

adi_project fmcjesdadc1_kc705 0 [list \
  RX_JESD_M    [get_env_param RX_JESD_M    4 ] \
  RX_JESD_L    [get_env_param RX_JESD_L    4 ] \
  RX_JESD_S    [get_env_param RX_JESD_S    1 ] \
  RX_JESD_NP   [get_env_param RX_JESD_NP   16] \
]

#  "system_top.v" 
adi_project_files fmcjesdadc1_kc705 [list \
  "../common/fmcjesdadc1_spi.v" \
  "system_constr.xdc" \
  "./src/hdl/system_top.sv" \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/library/common/ad_sysref_gen.v" \
  "$ad_hdl_dir/projects/common/kc705/kc705_system_constr.xdc" \
  "src/constraints/kc705_sma_constr.xdc" \
  "src/ip/xdma_0/xdma_0.xci" \
  "src/hdl/shapi_regs_v1.sv" \
  "src/hdl/shapi_stdrt_dev_inc.vh" \
  "src/constraints/pcie_xdma_kc705_x4g2.xdc" \
  "src/hdl/trigger_gen.v" ]

# Uncomment  to implement project with make ... (takes time)
# adi_project_run fmcjesdadc1_kc705

