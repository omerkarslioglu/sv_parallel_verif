
TIMESTAMP = $(shell date +'report%F-%T.txt')

defined_macros  = # +define+
SEED            = 1

# Questa TCL files:
RUN_FAST_ON_QUESTA_PATH := scripts/questa/run_fast.do
RUN_GUI_ON_QUESTA_PATH := scripts/questa/run_gui.do

XCELIUM_TIMESCALE_FLAGS = -timescale 1ns/100ps # -override_precision 100ps matrix_mul.sv -override_timescale

.PHONY: all

clean:
	rm -rf *.d *.log *.history *.cmd *.simvision *.logv *.key *.diag transcript work DefaultVlogALib .simvision *.vstf *.wlf *.shm .vscode *.err *.bpad wlft* matrix_mul_cov.ucdb modelsim.ini logs/data_mem_logs/*.txt *.do *.out

clean-all: clean
	rm -rf covhtmlreport *.ucdb scripts/questa/sim_results/work/* scripts/questa/sim_results/logs/* scripts/questa/sim_results/waves/*
	rm -rf report/*.txt covhtmlreport *.ucdb

runq-fast:
	clear
	vsim -t ns -c -do $(RUN_FAST_ON_QUESTA_PATH) | tee ./report/${TIMESTAMP}

runq-gui:
	clear
	vsim -t ns -do $(RUN_GUI_ON_QUESTA_PATH)

runx:
	clear
	mkdir report -p
	xrun -svseed ${SEED} -profile -prof_enable_cpuload -prof_dump_once 5 -64bit -nowarn ENUMERR ${XCELIUM_TIMESCALE_FLAGS} -f scripts/file_lists/file.f -disable_sem2009 -uvmhome CDNS-1.2 ${defined_macros} | tee ./report/${TIMESTAMP}

runx-gui: create-mem-log-files report-build
	clear
	xrun -64bit -nowarn ENUMERR ${XCELIUM_TIMESCALE_FLAGS} -f scripts/file_lists/file.f -disable_sem2009 -access +rwc -gui -uvmhome CDNS-1.2 ${defined_macros} -svseed ${SEED}

help:
	@echo
	@echo  ================================================================================================================
	@echo  " - runq: "
	@echo	 "     to run fast the Questa simulation on console "
	@echo  " - runq-gui: "
	@echo  "     to run the Questa simulation on gui "
	@echo  ================================================================================================================
