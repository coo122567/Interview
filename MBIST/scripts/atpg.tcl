set DESIGN "top"

##   Step 1 :Read In Files            ##
read_netlist ./dft_out/${DESIGN}_dft.v
read_netlist /home/m110/m110061576/process/CBDK_TSMC018_Arm_f1.0/CIC/Verilog/tsmc18.v -library
report_modules -summary 
report_modules -error 
report_modules -undefined 

##   Step 2 :Build ATPG Design Model  ##
run_build_mode ${DESIGN}


##   Step 3 :Design Rule Validation   ##
set_drc -allow_unstable_set_resets
run_drc ./dft_out/${DESIGN}_dft.stil

##   Step 4 :Run ATPG                 ##
set_faults -model stuck
add_faults -all
report_faults -summary

set_atpg -merge high -abort_limit 250 -coverage 100 -decision random -fill x
run_atpg

report_summaries > ./atpg_out/report_summaries.rpt
report_patterns -all -type > ./atpg_out/report_patterns.rpt

##   Step 5 :Write Out Files          ##
write_faults ./atpg_out/${DESIGN}_fault.rpt -replace -summary

# For ATE
write_patterns ./atpg_out/${DESIGN}_dft.stil -format stil -replace

# For VCS pattern sim.
# use stil2verilog utility from UNIX
# UNIX% stil2verilog <filename>.stil <testbench_name>