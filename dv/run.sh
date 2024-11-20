#!/bin/bash

# Define the path to the Verilog header file
HEADER_FILE="config/ahb_subordinate_defines.vh"
DO_FILE="run1.do"
LOG_FILE="log.do"  # Assuming log.do is the file you want to run first

# Function to modify the header file with the given values for HWDATA_WIDTH and HADDR_WIDTH
modify_header_file() {
    local hwd_value=$1
    local haddr_value=$2
    
    # Backup the original header file
    cp $HEADER_FILE $HEADER_FILE.bak
    
    # Modify the header file with the new values
    sed -i "1,2s/\`define HWDATA_WIDTH[0-9]\+/`define HWDATA_WIDTH$hwd_value/" $HEADER_FILE
    sed -i "1,2s/\`define ADDR_WIDTH[0-9]\+/`define ADDR_WIDTH$haddr_value/" $HEADER_FILE


    echo "Header file updated with: \`define HWDATA_WIDTH$hwd_value and \`define HADDR_WIDTH$haddr_value"
}

# Function to modify the test name inside the .do file
modify_do_file() {
    local test_name=$1
    
    # Backup the original do file (optional)
    cp $DO_FILE $DO_FILE.bak
    
    # Modify the test name in the .do file
    # Assume there's a line like "set test_name <name>" in your .do file
    sed -i "s/set test_name .*/set test_name $test_name/" $DO_FILE
    
    echo "Test name set to: $test_name"
}

# Run log.do first (this will run inside the same vsim session)
echo "Running log.do script inside Questa"
vsim -do $LOG_FILE  # This will open Questa, run vlog commands, and block until done

# After log.do finishes, proceed with the test simulations
echo "log.do completed. Starting simulations..."

# Loop through different configurations for HWDATA_WIDTH, HADDR_WIDTH, and test names
HWDATA_WIDTH_values=("32")
HADDR_WIDTH_values=("32")
TEST_NAMES=("runall_test" "WRITE_READ_INCR_test")

# Loop over the configurations
for (( j = 0; j < ${#TEST_NAMES[@]}; j++ )); do
    test_name=${TEST_NAMES[$j]}
    for ((i = 0; i < ${#HWDATA_WIDTH_values[@]}; i++)); do
        hwd_value=${HWDATA_WIDTH_values[$i]}
        haddr_value=${HADDR_WIDTH_values[$i]}

        echo "Running simulation for HWDATA_WIDTH=$hwd_value, HADDR_WIDTH=$haddr_value, and test=$test_name"

        # Step 1: Modify the header file with the new defines
        modify_header_file $hwd_value $haddr_value
        
        # Step 2: Modify the .do file with the new test name
        modify_do_file $test_name
        
        # Step 3: Execute the .do file for simulation
        echo "Running the .do file with test $test_name"
        vsim -do $DO_FILE  # Run the simulation for the given configuration
        
    done
done

echo "Simulation finished for all configurations."
