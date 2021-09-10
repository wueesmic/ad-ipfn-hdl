
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl

adi_project fmcjesdadc1_kc705
adi_project_files fmcjesdadc1_kc705 [list \
  "../common/fmcjesdadc1_spi.v" \
  "./src/hdl/system_top.sv" \
  "system_constr.xdc" \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/library/common/ad_sysref_gen.v" \
  "$ad_hdl_dir/projects/common/kc705/kc705_system_constr.xdc" \
  "src/constraints/kc705_sma_constr.xdc" \
  "src/ip/xdma_0/xdma_0.xci" \
  "src/hdl/shapi_regs_v1.vh" \
  "src/constraints/pcie_xdma_kc705_x4g2.xdc" \
  "src/hdl/trigger_gen.v" ]

# adi_project_run fmcjesdadc1_kc705

