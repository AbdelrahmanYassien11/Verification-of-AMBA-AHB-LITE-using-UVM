if {![file isdirectory "reports"]} {
    file mkdir "reports"
}

set test_names {"WRITE_READ_INCR_test" "WRITE_READ_INCR4_test" "WRITE_READ_INCR8_test" "WRITE_READ_INCR16_test" "WRITE_READ_WRAP4_test" "WRITE_READ_WRAP8_test" "WRITE_READ_WRAP16_test" "runall_test"}
set test_data_defines {"32" "64" "128" "256" "512" "1024"}
set test_addr_defines {"32" "32" "32" "32" "32" "32"}

# Loop through each test name
foreach test_name $test_names {
    # Loop over the test_data_defines and test_addr_defines using the same index
    set num_tests [llength $test_data_defines]  ;# Get the number of elements in the test_data_defines array
    for {set index 0} {$index < $num_tests} {incr index} {
        set test_data_define [lindex $test_data_defines $index]
        set test_addr_define [lindex $test_addr_defines $index]

        # Output the current configuration
        puts "Running simulation for $test_name with data define: $test_data_define and addr define: $test_addr_define"

        # Run the bash script to update the header file with both data and address defines
        exec bash ./update_header.sh $test_data_define $test_addr_define

        do log.do

        # Run the simulation
        vopt top_test_uvm -o top_optimized +acc +cover=bcefsx+ahb_lite(rtl)
        vsim top_optimized -cover -solvefaildebug=2 +UVM_TESTNAME=$test_name

        # Simulation control and coverage collection
        set NoQuitOnFinish 1
        onbreak {resume}
        log /* -r
        run -all
        coverage report -assert -details -zeros -verbose -output /reports/assertion_based_coverage_report.txt -append /.
        coverage report -detail -cvg -directive -comments -option -memory -output /reports/functional_coverage_report.txt {}

        coverage attribute -name TESTNAME -value ${test_name}_${test_data_define}_${test_addr_define}
        coverage save reports/${test_name}_${test_data_define}_${test_addr_define}.ucdb
    }
}


vcover merge vcover merge reports/WRITE_READ_INCR_test_32_32.ucdb reports/WRITE_READ_INCR_test_64_32.ucdb reports/WRITE_READ_INCR4_test_64_32.ucdb reports/WRITE_READ_INCR4_test_64_32.ucdb reports/WRITE_READ_INCR8_test_64_32.ucdb reports/WRITE_READ_INCR8_test_64_32.ucdb reports/WRITE_READ_INCR16_test_64_32.ucdb reports/WRITE_READ_INCR16_test_64_32.ucdb reports/WRITE_READ_WRAP4_test_64_32.ucdb reports/WRITE_READ_WRAP4_test_64_32.ucdb reports/WRITE_READ_WRAP8_test_64_32.ucdb reports/WRITE_READ_WRAP8_test_64_32.ucdb reports/WRITE_READ_WRAP16_test_64_32.ucdb reports/WRITE_READ_WRAP16_test_64_32.ucdb reports/runall_test_32_32.ucdb reports/runall_test_64_32.ucdb -out AHB_lite_tb.ucdb

quit -sim

vcover report -output reports/AHB_lite_coverage_report.txt reports/AHB_lite_tb.ucdb -zeros -details -annotate -all