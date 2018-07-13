
source $ad_hdl_dir/library/jesd204/scripts/jesd204.tcl

# adc peripherals

ad_ip_instance axi_ad9208 axi_ad9208_core

adi_axi_jesd204_rx_create axi_ad9208_jesd 8

ad_ip_instance axi_adxcvr axi_ad9208_xcvr
ad_ip_parameter axi_ad9208_xcvr CONFIG.NUM_OF_LANES 8
ad_ip_parameter axi_ad9208_xcvr CONFIG.QPLL_ENABLE 0
ad_ip_parameter axi_ad9208_xcvr CONFIG.TX_OR_RX_N 0
ad_ip_parameter axi_ad9208_xcvr CONFIG.LPM_OR_DFE_N 1
ad_ip_parameter axi_ad9208_xcvr CONFIG.SYS_CLK_SEL 0
ad_ip_parameter axi_ad9208_xcvr CONFIG.OUT_CLK_SEL 2

ad_ip_instance axi_dmac axi_ad9208_dma
ad_ip_parameter axi_ad9208_dma CONFIG.DMA_TYPE_SRC 1
ad_ip_parameter axi_ad9208_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_ad9208_dma CONFIG.ID 0
ad_ip_parameter axi_ad9208_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_ad9208_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_ad9208_dma CONFIG.SYNC_TRANSFER_START 0
ad_ip_parameter axi_ad9208_dma CONFIG.DMA_LENGTH_WIDTH 24
ad_ip_parameter axi_ad9208_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_ad9208_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_ad9208_dma CONFIG.DMA_DATA_WIDTH_SRC 128
ad_ip_parameter axi_ad9208_dma CONFIG.DMA_DATA_WIDTH_DEST 128

ad_ip_instance util_adxcvr util_ad9208_xcvr
ad_ip_parameter util_ad9208_xcvr CONFIG.XCVR_TYPE 2
ad_ip_parameter util_ad9208_xcvr CONFIG.QPLL_FBDIV 20
ad_ip_parameter util_ad9208_xcvr CONFIG.QPLL_REFCLK_DIV 1
ad_ip_parameter util_ad9208_xcvr CONFIG.CPLL_FBDIV 1
ad_ip_parameter util_ad9208_xcvr CONFIG.TX_NUM_OF_LANES 0
ad_ip_parameter util_ad9208_xcvr CONFIG.RX_NUM_OF_LANES 8
ad_ip_parameter util_ad9208_xcvr CONFIG.RX_OUT_DIV 1
ad_ip_parameter util_ad9208_xcvr CONFIG.RX_CLK25_DIV 30

ad_ip_instance util_cpack ad9208_cpack
ad_ip_parameter ad9208_cpack CONFIG.CHANNEL_DATA_WIDTH 128
ad_ip_parameter ad9208_cpack CONFIG.NUM_OF_CHANNELS 2

ad_ip_instance clk_wiz dma_clk_wiz
ad_ip_parameter dma_clk_wiz CONFIG.PRIMITIVE MMCM
ad_ip_parameter dma_clk_wiz CONFIG.RESET_TYPE ACTIVE_LOW
ad_ip_parameter dma_clk_wiz CONFIG.USE_LOCKED false
ad_ip_parameter dma_clk_wiz CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 332.9
ad_ip_parameter dma_clk_wiz CONFIG.PRIM_SOURCE No_buffer

ad_ip_instance proc_sys_reset sys_dma_rstgen


# reference clocks & resets

create_bd_port -dir I rx_ref_clk_0
create_bd_port -dir I rx_core_clk

ad_xcvrpll  rx_ref_clk_0 util_ad9208_xcvr/qpll_ref_clk_*
ad_xcvrpll  rx_ref_clk_0 util_ad9208_xcvr/cpll_ref_clk_*
ad_xcvrpll  axi_ad9208_xcvr/up_pll_rst util_ad9208_xcvr/up_qpll_rst_*
ad_xcvrpll  axi_ad9208_xcvr/up_pll_rst util_ad9208_xcvr/up_cpll_rst_*
ad_connect  sys_cpu_resetn util_ad9208_xcvr/up_rstn
ad_connect  sys_cpu_clk util_ad9208_xcvr/up_clk

# connections (adc)

ad_xcvrcon  util_ad9208_xcvr axi_ad9208_xcvr axi_ad9208_jesd {} rx_core_clk
ad_connect  rx_core_clk axi_ad9208_core/rx_clk
ad_connect  axi_ad9208_jesd/rx_data_tdata axi_ad9208_core/rx_data
ad_connect  axi_ad9208_jesd/rx_sof axi_ad9208_core/rx_sof

ad_connect axi_ad9208_core/adc_clk ad9208_cpack/adc_clk
ad_connect axi_ad9208_core/adc_enable_0 ad9208_cpack/adc_enable_0
ad_connect axi_ad9208_core/adc_valid_0 ad9208_cpack/adc_valid_0
ad_connect axi_ad9208_core/adc_data_0 ad9208_cpack/adc_data_0
ad_connect axi_ad9208_core/adc_enable_1 ad9208_cpack/adc_enable_1
ad_connect axi_ad9208_core/adc_valid_1 ad9208_cpack/adc_valid_1
ad_connect axi_ad9208_core/adc_data_1 ad9208_cpack/adc_data_1

ad_connect sys_cpu_clk dma_clk_wiz/clk_in1
ad_connect sys_cpu_resetn dma_clk_wiz/resetn
ad_connect sys_dma_clk dma_clk_wiz/clk_out1

ad_connect sys_dma_rstgen/slowest_sync_clk dma_clk_wiz/clk_out1
ad_connect sys_dma_rstgen/ext_reset_in sys_rstgen/peripheral_aresetn

ad_connect ad9208_cpack/adc_data axi_ad9208_fifo/adc_wdata
ad_connect ad9208_cpack/adc_valid axi_ad9208_fifo/adc_wr
ad_connect axi_ad9208_fifo/adc_clk axi_ad9208_core/adc_clk
ad_connect rx_core_clk_rstgen/peripheral_reset ad9208_cpack/adc_rst
ad_connect axi_ad9208_fifo/adc_rst rx_core_clk_rstgen/peripheral_reset
ad_connect axi_ad9208_dma/s_axis_ready axi_ad9208_fifo/dma_wready
ad_connect axi_ad9208_dma/s_axis_valid axi_ad9208_fifo/dma_wr
ad_connect axi_ad9208_dma/s_axis_data axi_ad9208_fifo/dma_wdata
ad_connect axi_ad9208_fifo/dma_clk dma_clk_wiz/clk_out1
ad_connect axi_ad9208_dma/s_axis_aclk dma_clk_wiz/clk_out1
ad_connect axi_ad9208_dma/s_axis_xfer_req axi_ad9208_fifo/dma_xfer_req

# interconnect (cpu)

ad_cpu_interconnect 0x44A60000 axi_ad9208_xcvr
ad_cpu_interconnect 0x44A10000 axi_ad9208_core
ad_cpu_interconnect 0x44AA0000 axi_ad9208_jesd
ad_cpu_interconnect 0x7c420000 axi_ad9208_dma

# gt uses hp3, and 100MHz clock for both DRP and AXI4

ad_mem_hp3_interconnect sys_cpu_clk sys_ps7/S_AXI_HP3
ad_mem_hp3_interconnect sys_cpu_clk axi_ad9208_xcvr/m_axi

# interconnect (mem/adc)

ad_mem_hp2_interconnect sys_dma_clk sys_ps7/S_AXI_HP2
ad_mem_hp2_interconnect sys_dma_clk axi_ad9208_dma/m_dest_axi

# interrupts

ad_cpu_interrupt ps-12 mb-13 axi_ad9208_jesd/irq
ad_cpu_interrupt ps-13 mb-12 axi_ad9208_dma/irq
