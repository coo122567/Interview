# read file
read_file -type verilog { \
./rtl/top.v
./rtl/bist_controller.v
./rtl/bist_pat_gen.v 
./rtl/bist_addr_gen.v 
./rtl/bist_buf.v 
./rtl/bist_cmp.v
}

# read lib
read_file -type gateslib { \
	/home/m110/m110061576/process/CBDK_TSMC018_Arm_f1.0/CIC/SynopsysDC/lib/slow.lib}

# constraint
read_file -type sgdc ./scripts/top.sgdc

# lint check

# goal setup (lint_rtl)
current_goal lint/lint_rtl -alltop

# run goal 
run_goal

# create a report file and write report message to the file
capture ./report/top_sg.rpt {write_report moresimple}

# setup another goal
current_goal lint/lint_turbo_rtl -alltop

# run goal 
run_goal 

# append the report message to the same file created above 
capture -append ./report/top_sg.rpt {write_report moresimple}


# goal setup (lint_functional_rtl)
current_goal lint/lint_functional_rtl -alltop
run_goal
capture -append ./report/top_sg.rpt {write_report moresimple}

# goal setup (lint_abstract)
current_goal lint/lint_abstract -alltop
run_goal
capture -append ./report/top_sg.rpt {write_report moresimple}


# CDC check

# cdc setup
#current_goal cdc/cdc_setup -alltop
#run_goal
#capture -append ./report/top_sg.rpt {write_report moresimple}

# cdc setup
#current_goal cdc/cdc_setup_check -alltop
#run_goal
#capture -append ./report/top_sg.rpt {write_report moresimple}

# cdc reset
#current_goal cdc/clock_reset_integrity -alltop
#run_goal
#capture -append ./report/top_sg.rpt {write_report moresimple}

# cdc struct
#current_goal cdc/cdc_verify_struct -alltop
#run_goal
#capture -append ./report/top_sg.rpt {write_report moresimple}

# cdc verify
#current_goal cdc/cdc_verify -alltop
#run_goal
#capture -append ./report/top_sg.rpt {write_report moresimple}

# cdc abstract
#current_goal cdc/cdc_abstract -alltop
#run_goal
#capture -append ./report/top_sg.rpt {write_report moresimple}