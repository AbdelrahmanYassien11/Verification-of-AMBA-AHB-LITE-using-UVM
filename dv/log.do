# Clean previous work library if it exists
if { [file exists "work"] } {
    vdel -all
}

# Create a new work library
vlib work

# Compile the DUT files with coverage enabled
vlog -f dut.f +cover -covercells

# Compile the TB files with coverage enabled
vlog -f tb.f +cover -covercells