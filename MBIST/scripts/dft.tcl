set DESIGN "top"
set CLK_period 10

##      Step 1 : Read In Files                ##
read_file ./netlist/${DESIGN}_syn.v -format verilog
current_design "top"
create_clock -name "clk" -period $CLK_period clk
report_area > ./report/${DESIGN}.rpt
report_timing >> ./report/${DESIGN}.rpt
report_power  >> ./report/${DESIGN}.rpt

##      Step 2 : Set ATE Configuration        ##
set_scan_configuration -style multiplexed_flip_flop -chain_count 1
create_clock -name "clk" -period $CLK_period clk

set_dft_signal -view existing_dft -type ScanClock -port clk -timing {45 55}
set_dft_signal -view existing_dft -type reset -port rst_n  -active_state 0

##      Step 3 : Design Rule Validation       ##
create_test_protocol
dft_drc

##      Step 4 : Scan Chain Synthesis         ##
insert_dft

##      Step 5 : Write Out Files              ##
report_area > ./report/${DESIGN}_dft.rpt
report_timing >> ./report/${DESIGN}_dft.rpt
report_power >> ./report/${DESIGN}_dft.rpt


write -format verilog -hierarchy -output ./dft_out/${DESIGN}_dft.v
write_test_protocol -output ./dft_out/${DESIGN}_dft.stil
exit
