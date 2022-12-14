#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "10.0 MHz" [get_ports ADC_CLK_10]
create_clock -period "50.0 MHz" [get_ports MAX10_CLK1_50]
create_clock -period "50.0 MHz" [get_ports MAX10_CLK2_50]

create_clock -period "30.303 ns" -name {altera_reserved_tck} {altera_reserved_tck}

#Create 25MHz divided clock for VGA
#create_clock -period "25.0 MHz" [get_ports vga0|clkdiv]
#Create 60Hz frame clock (vs) for VGA
#create_clock -period "60Hz" [get_ports vga0|vs]

# SDRAM CLK
#create_generated_clock -source [get_pins { u0|altpll_0|sd1|pll7|clk[1] }] \#
#Here you need to find the mapped name of the pin clk[1] in Technology Map Viewer (Post-Mapping),
#replace u0 with the name of your instance of the lab61_soc module (Here the instance name is "m_lab61_soc",
#replace altpll_0 with the name of your instance of the PLL (lab61_soc_sdram_pll module) (Here the instance name is "sdram_pll",
#the rest of the hierarchies are the same since we generate the PLL using the Platform Designer.
#create_generated_clock -source [get_pins {  m_lab61_soc|sdram_pll|sd1|pll7|clk[1] }] \#
create_generated_clock -source [get_pins {  u0|sdram_pll|sd1|pll7|clk[1] }] \
                      -name clk_dram_ext [get_ports {DRAM_CLK}]
#create_generated_clock -source [get_pins {vga0|clkdiv}]\
							 -name vga_clkdiv [get_ports {vga0|pixel_clk}]
#create_generated_clock -source [get_pins {vga0|vs|Q}]\
							 -name vga_vs [get_ports {vga0|vs}]		
derive_clocks -period "25.0 MHz"
derive_clocks -period "60.0 Hz"

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************
# suppose +- 100 ps skew
# Board Delay (Data) + Propagation Delay - Board Delay (Clock)
# max 5.4(max) +0.4(trace delay) +0.1 = 5.9
# min 2.7(min) +0.4(trace delay) -0.1 = 3.0
set_input_delay -max -clock clk_dram_ext 5.9 [get_ports DRAM_DQ*]
set_input_delay -min -clock clk_dram_ext 3.0 [get_ports DRAM_DQ*]

#Constrain the new added inputs: SW for switches and KEY for bottons, * represents for a string with any length.
set_input_delay -max -clock clk_dram_ext 5.9 [get_ports SW*]
set_input_delay -min -clock clk_dram_ext 3.0 [get_ports SW*]
set_input_delay -max -clock clk_dram_ext 5.9 [get_ports KEY*]
set_input_delay -min -clock clk_dram_ext 3.0 [get_ports KEY*]

#Constrain the auto-generated inputs "alter_reserved_tdi" and "alter_reserved_tms", which are used by JTAG.
set_input_delay -max -clock clk_dram_ext 5.9 [get_ports altera_reserved_*]
set_input_delay -min -clock clk_dram_ext 3.0 [get_ports altera_reserved_*]

#shift-window
set_multicycle_path -from [get_clocks {clk_dram_ext}] \
						  -to [get_clocks { u0|sdram_pll|sd1|pll7|clk[0] }] \
						  -setup 2
						  #-to [get_clocks { m_lab61_soc|sdram_pll|sd1|pll7|clk[0] }] \#
                    #-to [get_clocks { u0|altpll_0|sd1|pll7|clk[0] }] \#
						  
#Here you need to find the mapped name of the pin clk[1] in Technology Map Viewer (Post-Mapping),
#replace u0 with the name of your instance of the lab61_soc module (Here the instance name is "m_lab61_soc",
#replace altpll_0 with the name of your instance of the PLL (lab61_soc_sdram_pll module) (Here the instance name is "sdram_pll",
#the rest of the hierarchies are the same since we generate the PLL using the Platform Designer.	
			  
#**************************************************************
# Set Output Delay
#**************************************************************
# suppose +- 100 ps skew
# max : Board Delay (Data) - Board Delay (Clock) + tsu (External Device)
# min : Board Delay (Data) - Board Delay (Clock) - th (External Device)
# max 1.5+0.1 =1.6
# min -0.8-0.1 = 0.9
set_output_delay -max -clock clk_dram_ext 1.6  [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -min -clock clk_dram_ext -0.9 [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -max -clock clk_dram_ext 1.6  [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]
set_output_delay -min -clock clk_dram_ext -0.9 [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]

#Constrain the new added outputs: LEDR for the leds, * represents for a string with any length.
set_output_delay -max -clock clk_dram_ext 1.6  [get_ports LEDR*]
set_output_delay -min -clock clk_dram_ext -0.9 [get_ports LEDR*]

#Constrain the auto-generated output "alter_reserved_tdo", which is used by JTAG.
set_output_delay -max -clock clk_dram_ext 1.6  [get_ports altera_reserved_*]
set_output_delay -min -clock clk_dram_ext -0.9 [get_ports altera_reserved_*]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from * -to [get_ports LEDR*]
set_false_path -from [get_ports SW*] -to *
set_false_path -from [get_ports KEY*] -to *
set_false_path -from * -to [get_ports HEX*]
set_false_path -from * -to [get_ports ARDUINO*]
set_false_path -from [get_ports ARDUINO*] -to *
set_false_path -from * -to [get_ports VGA*]



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************



