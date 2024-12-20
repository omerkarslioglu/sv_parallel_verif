# Use it to take sim results fast on Questa

set SIM_DIR "scripts/questa/sim_results"
set SEED_VALUE "1"

if [file exist /scripts/questa/sim_results/work] {vdel -all}

vlib $SIM_DIR/work
vmap work $SIM_DIR/work

vlog -f scripts/file_lists/file.f -svinputport=relaxed +define+STOP_DURING_ERROR
vsim -t ns -autofindloop -detectzerodelayloop -iterationlimit=5k -wlf /dev/null -sv_seed $SEED_VALUE -vopt work.que_search -c +UVM_VERBOSITY=UVM_LOW

run -all