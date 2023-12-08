
set_property -dict {PACKAGE_PIN AL16 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports ref_p]
set_property -dict {PACKAGE_PIN AK17 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports sys_p]

create_clock -period 4.650 -name ref_clk [get_ports ref_p]

set_property -dict {PACKAGE_PIN AR13 IOSTANDARD LVCMOS18} [get_ports {status[0]}]
set_property -dict {PACKAGE_PIN AP13 IOSTANDARD LVCMOS18} [get_ports {status[1]}]
set_property -dict {PACKAGE_PIN AR16 IOSTANDARD LVCMOS18} [get_ports {status[2]}]
set_property -dict {PACKAGE_PIN AP16 IOSTANDARD LVCMOS18} [get_ports {status[3]}]
set_property -dict {PACKAGE_PIN AP15 IOSTANDARD LVCMOS18} [get_ports {status[4]}]
set_property -dict {PACKAGE_PIN AN16 IOSTANDARD LVCMOS18} [get_ports {status[5]}]
set_property -dict {PACKAGE_PIN AN17 IOSTANDARD LVCMOS18} [get_ports {status[6]}]
set_property -dict {PACKAGE_PIN AV15 IOSTANDARD LVCMOS18} [get_ports {status[7]}]

set_property -dict {PACKAGE_PIN  N13 IOSTANDARD LVCMOS12} [get_ports pmod1_3]; # pps

set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]




