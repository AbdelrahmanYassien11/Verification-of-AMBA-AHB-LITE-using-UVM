#!/bin/bash

# Define the path to the Verilog header file
HEADER_FILE="../config/ahb_subordinate_defines.vh"

# Arguments passed from the do file
HWDATA_WIDTH=$1
ADDR_WIDTH=$2

echo "HWDATA_WIDTH: $HWDATA_WIDTH"
echo "ADDR_WIDTH: $ADDR_WIDTH"

# Backup the original header file
cp $HEADER_FILE $HEADER_FILE.bak

# Modify both HWDATA_WIDTH and ADDR_WIDTH macros
sed -i "1,2s/\`define HWDATA_WIDTH[0-9]\+/\`define HWDATA_WIDTH$HWDATA_WIDTH/" $HEADER_FILE
sed -i "1,2s/\`define ADDR_WIDTH[0-9]\+/\`define ADDR_WIDTH$ADDR_WIDTH/" $HEADER_FILE

echo "Header file updated: \`define HWDATA_WIDTH$HWDATA_WIDTH and \`define ADDR_WIDTH$ADDR_WIDTH"
