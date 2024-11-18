#!/bin/bash

# Define the path to the Verilog header file
HEADER_FILE="config/ahb_subordinate_defines.vh"
DO_FILE="run.do"

# Function to modify the header file with the given values for HWDATA_WIDTH and HADDR_WIDTH
modify_header_file() {
    local hwd_value=$1
    local haddr_value=$2
    
    # Backup the original header file
    cp $HEADER_FILE $HEADER_FILE.bak
    
    # Modify the header file with the new values
    sed -i "s/\`define HWDATA_WIDTH[0-9]\+/`define HWDATA_WIDTH$hwd_value/" $HEADER_FILE
    sed -i "s/\`define HADDR_WIDTH[0-9]\+/`define HADDR_WIDTH$haddr_value/" $HEADER_FILE

    echo "Header file updated with: `define HWDATA_WIDTH$hwd_value and `define HADDR_WIDTH$haddr_value"
}

# Function to modify the test name inside the .do file
modify_do_file() {
    local test_name=$1
    
    # Backup the original do file (optional)
    cp $DO_FILE $DO_FILE.bak
    
    # Modify the test name in the .do file
    # Assume there's a line like "set test_name <name>" in your .do file
    sed -i "s/+UVM_TESTNAME=.*/+UVM_TESTNAME=$test_name/" $DO_FILE
    
    echo "Test name set to: $test_name"
}

# Loop through different configurations for HWDATA_WIDTH, HADDR_WIDTH, and test names
HWDATA_WIDTH_values=("32" "64" "128")
HADDR_WIDTH_values=("32" "32" "32")
TEST_NAMES=("test_case1" "test_case2" "test_case3")

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
        
        # Step 3: Execute the .do file
        echo "Running the .do file with test $test_name"
        vsim -do $DO_FILE
        
        # Optional: collect coverage data or handle simulation results here if needed
    done
done


echo "Simulation finished for all configurations."
