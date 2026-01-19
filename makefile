# Default Setting
num_CPU_cores = 10
rtl_sim_file = "filelist_rtl.f"
rtl_log_file = "vcs_rtl.log"
gate_sim_file = "filelist_gate.f"
gate_log_file = "vcs_gate.log"
dft_sim_file = "filelist_dft.f"
dft_log_file = "vcs_dft.log"
syn_tcl = "./scripts/syn.tcl"
syn_log = "syn.log"
TSMC18_SIM  = /home/m110/m110061576/process/CBDK_TSMC018_Arm_f1.0/CIC/Verilog/tsmc18.v
sg_tcl = "./scripts/sg.tcl"
sg_log = "sg.log"
fm_tcl = "./scripts/fm.tcl"
fm_log = "fm.log"
dft_tcl = "./scripts/dft.tcl"
dft_log = "dft.log"
atpg_tcl = "./scripts/atpg.tcl"
atpg_log = "atpg.log"
TOP_NAME = "top"

# VCS
VCS_RTL_SIM = vcs -f ${rtl_sim_file} \
    -j${num_CPU_cores} \
    -sverilog \
    +v2k \
    -full64 \
    -R \
    -debug_access+all \
    -l ${rtl_log_file} \
    +define+RTL \
    +notimingchecks 

VCS_GATE_SIM = vcs -f ${gate_sim_file} \
    -j${num_CPU_cores} \
    -sverilog \
    +v2k \
    -full64 \
    -R \
    -debug_access+all \
    -l ${gate_log_file} \
	-v ${TSMC18_SIM} \
    +define+GATE \
	+neg_tchk 
	
VCS_DFT_SIM = vcs -f ${dft_sim_file} \
    -j${num_CPU_cores} \
    -sverilog \
    +v2k \
    -full64 \
    -R \
    -debug_access+all \
    -l ${dft_log_file} \
	-v ${TSMC18_SIM} \
	+neg_tchk 
	
	
# Spyglass
spyglass_RTL = sg_shell -tcl ${sg_tcl} \
	| tee -i ${sg_log}

# nWave
nWave_RTL = nWave -ssf ./waveform/${TOP_NAME}.fsdb 

nWave_GATE = nWave -ssf ./waveform/${TOP_NAME}_syn.fsdb 

# Verdi
VERDI_RTL = verdi -ssf ./waveform/${TOP_NAME}.fsdb \
	-sv \
	-f ${rtl_sim_file} \
    -nologo           \
	+define+RTL	  \
	+v2k \
	-autoalias

VERDI_GATE = verdi -ssf ./waveform/${TOP_NAME}_syn.fsdb \
	-sv \
	-f ${gate_sim_file} \
    -nologo           \
	+define+GATE	  \
	+v2k \
	-autoalias \
	-v ${TSMC18_SIM} 

dft = dc_shell -f ${dft_tcl} \
	  -x "set_host_options -max_cores ${num_CPU_cores}" \
	  | tee -i ${dft_log}
	  
atpg = tmax -shell < ${atpg_tcl} \
	| tee -i ${atpg_log}
     
# Design compiler	
DC_shell = dc_shell -f ${syn_tcl} \
	  -x "set_host_options -max_cores ${num_CPU_cores}" \
	  | tee -i ${syn_log}

# Formality
FM_shell = fm_shell -f ${fm_tcl} \
	  | tee -i ${fm_log}
	
# Clean
clean_vcs 	= rm -rf *.fsdb ./csrc *.log simv* *.sdf.X *.key
clean_verdi = rm -rf ./nWaveLog ./verdiLog *.conf *.rc *.log ./waveform/*
clean_syn 	= rm -rf ./netlist/*.* ./report/${TOP_NAME}.* *.log alib* *.svf dwsvf* *.ddc *.pvl *.syn *.mr
clean_sg 	= rm -rf ./spyglass-1 *.log ./report/*_sg.rpt
clean_fm 	= rm -rf ./FM_INFO *.log *.rpt ./formality_svf ./formality1_svf ./formality_svf


# RTL simulation
vcs_rtl_sim:
	${VCS_RTL_SIM}
	
# RTL simulation
spyglass_rtl:
	${spyglass_RTL}	&
	
# Waveform viewer for RTL simulation
nWave_rtl:
	${nWave_RTL} &

verdi_rtl:
	${VERDI_RTL} &

# Synthesis
syn:
	${DC_shell} 
	
# DFT
dft:
	${dft}
	
# DFT
atpg:
	${atpg} 	
	
# Gate-level simulation
vcs_gate_sim:
	${VCS_GATE_SIM}

# Waveform viewer for Gate-Level simulation
nWave_gate:
	${nWave_GATE} &

verdi_gate:
	${VERDI_GATE} &

# LEC
fm:
	${FM_shell} 		

# Pattern simulation
vcs_dft_sim:
	${VCS_DFT_SIM}
	
# Clean 
clean:
	${clean_vcs}
	${clean_verdi}
	${clean_syn}
	${clean_sg}
	${clean_fm}
