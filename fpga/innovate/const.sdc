
set_time_format -unit ns -decimal_places 3                                      

create_clock -name {FPGA_CLK1_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {FPGA_CLK1_50}]
derive_pll_clocks -create_base_clocks -use_net_name
derive_clock_uncertainty
