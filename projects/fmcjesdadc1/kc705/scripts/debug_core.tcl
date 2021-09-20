# https://gitlab.cern.ch/rce/pixelrce/blob/78b980d3085d636e368e9b3a49b86f62d46685a5/rce/fw-hsio2/firmware/modules/StdLib/build/vivado_proc_v1.tcl


## source after synth_design step
# Probe Configuring function
proc ConfigProbe {ilaName netName} {

   # increment the probe index
   create_debug_port ${ilaName} probe
   # determine the probe index
   set probeIndex ${ilaName}/probe[expr [llength [get_debug_ports ${ilaName}/probe*]] - 1]

   # get the list of netnames
   set probeNet [lsort -increasing -dictionary [get_nets ${netName}]]
   puts "ProbeNet $probeNet"

   # calculate the probe width
   set probeWidth [llength ${probeNet}]
   puts "probeWidth $probeWidth"

   # set the width of the probe
   set_property port_width ${probeWidth} [get_debug_ports ${probeIndex}]

   # connect the probe to the ila module
   connect_debug_port ${probeIndex} ${probeNet}

}
proc ConfigSingleProbe {ilaName netName} {

   # increment the probe index
   create_debug_port ${ilaName} probe
    #determine the probe index
   set probeIndex ${ilaName}/probe[expr [llength [get_debug_ports ${ilaName}/probe*]] - 1]
   puts "ProbeIndex $probeIndex"
   #puts $probeInde
   ## set the width of the probe
   set_property port_width 1 [get_debug_ports  ${probeIndex}]

   # connect the probe to the ila module
   connect_debug_port ${probeIndex} [get_nets ${netName}]
#connect_debug_port u_ila_0/probe2 [get_nets [list s_axis_tx_tvalid]]
}
#set_property CONTROL.TRIGGER_POSITION 1024 [get_hw_ilas -of_objects [get_hw_devices xc7k325t_0] -filter {CELL_NAME=~"u_ila_0"}]
#Create the debug core
create_debug_core u_ila_0 ila
#set debug core properties
set_property C_DATA_DEPTH 8192   [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false   [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false  [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0   [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true    [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU true  [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
#connect the probe ports in the debug core to the signals being probed in the design
set_property port_width 1 [get_debug_ports u_ila_0/clk]
# connect_debug_port u_ila_0/clk [get_nets main_clk_100]
# connect_debug_port u_ila_0/clk [get_nets [list rx_clk]]
connect_debug_port u_ila_0/clk [get_nets  rx_clk]

set trig_i  "trigger_gen_i"

set_property port_width 1 [get_debug_ports u_ila_0/probe0] 
connect_debug_port u_ila_0/probe0 [get_nets detect_0_i]

# ConfigProbe u_ila_0 clk_100_cnt_i[*]

ConfigProbe u_ila_0 trigger1_i
ConfigProbe u_ila_0 ${trig_i}/state[*]
ConfigProbe u_ila_0 ${trig_i}/adc_sum_a[*]



