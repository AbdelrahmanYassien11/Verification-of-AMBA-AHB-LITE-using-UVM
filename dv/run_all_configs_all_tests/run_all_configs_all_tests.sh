#!/bin/bash

# *** CLEAN EVERYTHING from previous runs ***
#rm -rf run_outputs

# Create a timestamped output folder for this run
timestamp=$(date +%Y%m%d_%H%M%S)
RUN_ROOT="run_outputs/$timestamp"
COMP_LOGS="$RUN_ROOT/compilation_logs"
SIM_LOGS="$RUN_ROOT/simulation_logs"
REPORTS="$RUN_ROOT/reports"

mkdir -p "$COMP_LOGS" "$SIM_LOGS" "$REPORTS"

# Define the path to the Verilog header file
HEADER_FILE="../config/ahb_subordinate_defines.vh"
DO_FILE="run_all_configs_all_tests.do"
LOG_FILE="log.do"

# Function to modify the header file with the given values for HWDATA_WIDTH and ADDR_WIDTH
modify_header_file() {
    local hwd_value=$1
    local addr_value=$2

    cp $HEADER_FILE $HEADER_FILE.bak

    sed -i "1,2s/\`define HWDATA_WIDTH[0-9]\+/\`define HWDATA_WIDTH$hwd_value/" $HEADER_FILE
    sed -i "1,2s/\`define ADDR_WIDTH[0-9]\+/\`define ADDR_WIDTH$addr_value/" $HEADER_FILE

    echo "Header file updated with: \`define HWDATA_WIDTH$hwd_value and \`define ADDR_WIDTH$addr_value"
}

HWDATA_WIDTH_values=("32" "64" "128")
ADDR_WIDTH_values=("32" "32" "32")
TEST_NAMES=("runall_test" "WRITE_READ_INCR4_test")

for ((i = 0; i < ${#HWDATA_WIDTH_values[@]}; i++)); do
    hwd_value=${HWDATA_WIDTH_values[$i]}
    addr_value=${ADDR_WIDTH_values[$i]}

    echo "Updating configuration: HWDATA_WIDTH=$hwd_value, ADDR_WIDTH=$addr_value"
    modify_header_file $hwd_value $addr_value

    # Compile sources, redirect log output to compilation_logs directory
    compile_log="$COMP_LOGS/compile_DATAWIDTH${hwd_value}_ADDRWIDTH${addr_value}.log"
    echo "Compiling with new configuration using log.do script inside Questa"
    vsim -c -do $LOG_FILE | tee "$compile_log"

    for test_name in "${TEST_NAMES[@]}"; do
        echo "Running simulation: test=$test_name, HWDATA_WIDTH=$hwd_value, ADDR_WIDTH=$addr_value"
        sim_log="$SIM_LOGS/${test_name}_DATAWIDTH${hwd_value}_ADDRWIDTH${addr_value}_simulation.log"
        vsim -c -do "set test_name $test_name; set DATA_WIDTH $hwd_value; set ADDR_WIDTH $addr_value; set REPORTS_DIR $REPORTS; do $DO_FILE; exit" | tee "$sim_log"
    done
done

echo "All outputs for this run are in: $RUN_ROOT"