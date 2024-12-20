# Use it to see all signals on WaveForm on Questa

set SIM_DIR "scripts/questa/sim_results"
set SEED_VALUE "4"

if [file exist /scripts/questa/sim_results/work] {vdel -all}

vlib $SIM_DIR/work
vmap work $SIM_DIR/work

vlog -coveropt 3 +acc -f scripts/file_lists/file.f -svinputport=relaxed +define+WAVEFORM+STOP_DURING_ERROR
vsim -t ns -autofindloop -detectzerodelayloop -iterationlimit=5k -sv_seed $SEED_VALUE -coverage -vopt work.que_search -c +UVM_VERBOSITY=UVM_LOW -wlf $SIM_DIR/waves/vsim.wlf

do wave.do

run -all
