source .synopsys_dc.setup
read_verilog <your module>.v
link
source <your module>.sdc
set_fix_multiple_port_nets -all -buffer_constants [get_designs *] 
set verilogout_no_tri     true 




compile -inc

report_timing  -delay_type max >> setup_timing_max.txt; 	#set up time
report_timing  -delay_type min >> setup_timing_min.txt;  	#hold time 
report_area >> area.txt

write -hierarchy -format verilog -output  <your module>_syn.v
write_sdf -version 2.1 -context verilog  <your module>_syn.sdf
write -hierarchy -format ddc -output <your module>_syn.ddc
