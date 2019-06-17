################################################################################
##### SMA CLOCKS and GPOI
###############################################################################
set_property IOSTANDARD LVCMOS25 [get_ports user_sma_clk_*]
#user_sma_clk_p SMA J11
set_property PACKAGE_PIN L25 [get_ports user_sma_clk_p]
#create_clock -period 100.000 -name sma_clk [get_ports user_sma_clk_p]
set_property PACKAGE_PIN K25 [get_ports user_sma_clk_n]

set_property IOSTANDARD LVCMOS25 [get_ports user_sma_gpio_*]
set_property PACKAGE_PIN Y23 [get_ports user_sma_gpio_p]
set_property PACKAGE_PIN Y24 [get_ports user_sma_gpio_n]
#set_property IOSTANDARD LVCMOS25 [get_ports user_sma_gpio_n]

