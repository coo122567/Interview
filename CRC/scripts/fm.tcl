# Formality script for top design

# synopsys_auto_setup variable must be set to true before the set_svf command
set synopsys_auto_setup true
set_svf top.svf

# read db
read_db "/home/m110/m110061576/process/CBDK_TSMC018_Arm_f1.0/CIC/SynopsysDC/db/slow.db"

# design ware library
set hdlin_dwroot /usr/cad/synopsys/synthesis/cur/

# read reference design 
read_verilog -r "./rtl/top.v ./rtl/rst_sync.v ./rtl/clk_1_module.v ./rtl/clk_2_module.v ./rtl/clk_3_module.v ./rtl/crc_step.v ./rtl/pulse_sync.v ./rtl/plsgen.v ./rtl/cdc_sync.v ./rtl/toggleff.v"
set_top -a

# read implementation design
read_verilog -i ./netlist/top_syn.v
set_top -a

match

verify

exit
