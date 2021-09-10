##-----------------------------------------------------------------------------
##
## Project    : The Xilinx PCI Express DMA
## File       : xilinx_pcie_xdma_ref_board.xdc
## Version    : 4.1
##-----------------------------------------------------------------------------
#
###############################################################################
# User Configuration
# Link Width   - x4
# Link Speed   - gen2
# Family       - kintex7
# Part         - xc7k325t
# Package      - ffg900
# Speed grade  - -2
# PCIe Block   - X0Y0

###############################################################################
#
#########################################################################################################################
# User Constraints
#########################################################################################################################

###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################
create_clock -period 10.000 -name pci_sys_clk [get_ports pci_sys_clk_p]
set_false_path -from [get_ports pci_sys_rst_n]
#set_false_path -through [get_pins xdma_0_i/inst/pcie3_ip_i/inst/pcie_top_i/pcie_7vx_i/PCIE_3_0_i/CFGMAX*]
#set_false_path -through [get_nets xdma_0_i/inst/cfg_max*]

###############################################################################
# User Physical Constraints
###############################################################################

###############################################################################
# Pinout and Related I/O Constraints
###############################################################################


###############################################################################
# Pinout and Related I/O Constraints
###############################################################################
##### SYS RESET###########
set_property LOC G25 [get_ports pci_sys_rst_n]
set_property PULLUP true [get_ports pci_sys_rst_n]
set_property IOSTANDARD LVCMOS25 [get_ports pci_sys_rst_n]

###############################################################################
# Physical Constraints
###############################################################################
#
# SYS clock 100 MHz (input) signal. The pci_sys_clk_p and pci_sys_clk_n
# signals are the PCI Express reference clock.
set_property LOC IBUFDS_GTE2_X0Y1 [get_cells pci_refclk_ibuf]

