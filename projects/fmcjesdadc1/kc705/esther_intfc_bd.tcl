
## IPFN Esther-trigger modifications
#
create_bd_port -dir O adc_valid_a
connect_bd_net [get_bd_ports adc_valid_a] [get_bd_pins axi_ad9250_core/adc_valid_0]

create_bd_port -dir O adc_enable_a
connect_bd_net [get_bd_ports adc_enable_a] [get_bd_pins axi_ad9250_core/adc_enable_0]

create_bd_port -dir O -from 31 -to 0 adc_data_a
connect_bd_net [get_bd_ports adc_data_a] [get_bd_pins axi_ad9250_core/adc_data_0]

create_bd_port -dir O adc_valid_b
connect_bd_net [get_bd_ports adc_valid_b] [get_bd_pins axi_ad9250_core/adc_valid_1]

create_bd_port -dir O adc_enable_b
connect_bd_net [get_bd_ports adc_enable_b] [get_bd_pins axi_ad9250_core/adc_enable_1]

create_bd_port -dir O -from 31 -to 0 adc_data_b
connect_bd_net [get_bd_ports adc_data_b] [get_bd_pins axi_ad9250_core/adc_data_1]

create_bd_port -dir O adc_valid_c
connect_bd_net [get_bd_ports adc_valid_c] [get_bd_pins axi_ad9250_core/adc_valid_2]

create_bd_port -dir O adc_enable_c
connect_bd_net [get_bd_ports adc_enable_c] [get_bd_pins axi_ad9250_core/adc_enable_2]

create_bd_port -dir O -from 31 -to 0 adc_data_c
connect_bd_net [get_bd_ports adc_data_c] [get_bd_pins axi_ad9250_core/adc_data_2]

create_bd_port -dir O adc_valid_d
connect_bd_net [get_bd_ports adc_valid_d] [get_bd_pins axi_ad9250_core/adc_valid_3]

create_bd_port -dir O adc_enable_d
connect_bd_net [get_bd_ports adc_enable_d] [get_bd_pins axi_ad9250_core/adc_enable_3]

create_bd_port -dir O -from 31 -to 0 adc_data_d
connect_bd_net [get_bd_ports adc_data_d] [get_bd_pins axi_ad9250_core/adc_data_3]