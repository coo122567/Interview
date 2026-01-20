#======================================================
# (A) Global Parameters
#======================================================
set DESIGN "top"
set CYCLE1 14.1
set CYCLE2 2.5
set CYCLE3 2.7
set INPUT_DLY 12.05
set OUTPUT_DLY [expr 0.5*$CYCLE3]

#======================================================
# (B) Read RTL Code
#======================================================
# For formality
set_svf top.svf
# (B-1) analyze + elaborate
set hdlin_auto_save_templates TRUE
analyze -f verilog ./rtl -autoread
elaborate $DESIGN  
# (B-2) read_sverilog
#read_sverilog $DESIGN\.v
# (B-3) set current design
current_design $DESIGN
link
check_design
#======================================================
#  (C) Global Setting
#======================================================
#set_wire_load_mode top
#set_wire_load_model -name umc18_wl10 -library slow
set_operating_conditions slow 


#======================================================
#  (D) Set Design Constraints
#======================================================

# (D-1) Setting Clock Constraints
create_clock -name clk1 -period $CYCLE1 [get_ports clk_1] 
create_clock -name clk2 -period $CYCLE2 [get_ports clk_2] 
create_clock -name clk3 -period $CYCLE3 [get_ports clk_3] 
set_dont_touch_network             		[all_clocks]
set_dont_touch_network             		[get_ports rst_n]
# set_fix_hold                       [get_clocks clk]
set_clock_uncertainty       0.1    		[all_clocks]
# set_clock_latency   -source 0      [get_clocks clk]
# set_clock_latency           1      [get_clocks clk] 
set_input_transition        0.5    		[all_inputs] 
set_clock_transition        0.1    		[all_clocks] 

# # (D-2) Setting in/out Constraints
set_input_delay   -max  $INPUT_DLY  -clock clk1    [all_inputs] ;  # set_up time check 
set_input_delay   -min  0           -clock clk1    [all_inputs] ;  # hold   time check 
set_output_delay  -max  $OUTPUT_DLY -clock clk3    [all_outputs] ; # set_up time check 
set_output_delay  -min  0           -clock clk3    [all_outputs] ; # hold   time check 
set_input_delay 0 -clock clk1  clk_1
set_input_delay 0 -clock clk2  clk_2
set_input_delay 0 -clock clk3  clk_3
#set_input_delay 0 -clock clk1  rst_n
# #set_max_delay $CYCLE -from [all_inputs] -to [all_outputs]

# # (D-3) Setting Design Environment
# set_driving_cell -library umc18io3v5v_slow -lib_cell P2C    -pin {Y}  [get_ports clk]
# set_driving_cell -library umc18io3v5v_slow -lib_cell P2C    -pin {Y}  [remove_from_collection [all_inputs] [get_ports clk]]
# set_load  [load_of "umc18io3v5v_slow/P8C/A"]       [all_outputs] ; # ~= 0.038
set_load 0.05 [all_outputs]
read_sdc ./scripts/top.sdc
# # (D-4) Setting DRC Constraint
# #set_max_delay           0     ; # Optimize delay max effort                 
# #set_max_area            0      ; # Optimize area max effort           
# set_max_transition      3       [all_inputs]   ; # U18 LUT Max Transition Value  
# set_max_capacitance     0.15    [all_inputs]   ; # U18 LUT Max Capacitance Value
# set_max_fanout          10      [all_inputs]
# set_dont_use slow/JKFF*
# #set_dont_touch [get_cells core_reg_macro]
# #set hdlin_ff_always_sync_set_reset true

# # (D-5) report Clock skew
# report_clock -skew clk
# check_timing

#======================================================
#  (E) Optimization
#======================================================
check_design > report/$DESIGN\.check
uniquify
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

# set_fix_hold [all_clocks]
compile -map_effort medium
check_design
#compile
#remove_unconnected_ports -blast_buses [get_cells -hierarchical *]
#======================================================
#  (F) Output Reports 
#======================================================
report_design  	> ./report/$DESIGN\.design
report_resource > ./report/$DESIGN\.resource
report_timing -max_paths 3 > ./report/$DESIGN\.timing
report_area 	> ./report/$DESIGN\.area
report_power 	> ./report/$DESIGN\.power
report_clock 	> ./report/$DESIGN\.clock
report_port 	> ./report/$DESIGN\.port
report_power 	> ./report/$DESIGN\.power
#report_reference > report/$DESIGN\.reference

#======================================================
#  (G) Change Naming Rule
#======================================================
set bus_inference_style "%s\[%d\]"
set bus_naming_style "%s\[%d\]"
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed "a-z A-Z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "a-z A-Z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule


#======================================================
#  (H) Output Results
#======================================================
set verilogout_higher_designs_first true
write -format verilog -output ./netlist/$DESIGN\_syn.v -hierarchy
write -format ddc     -hierarchy -output ./$DESIGN\_syn.ddc
# ------------------------------------------------
# - deal with x propagation
#set_annotated_check 0 -setup -hold -from  u_sync2_clk2/q0_reg/CK -to u_sync2_clk2/q0_reg/D
#set_annotated_check 0 -setup -hold -from  u_sync2_clk3/q0_reg/CK -to u_sync2_clk3/q0_reg/D


# ------------------------------------------------
write_sdf -version 3.0 -context verilog -load_delay cell ./netlist/$DESIGN\_syn.sdf -significant_digits 6
write_sdc ./netlist/$DESIGN\_syn.sdc

#======================================================
#  (I) Finish and Quit
#======================================================

report_area
report_timing 
exit

