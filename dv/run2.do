set test_names {"runall_test" "WRITE_READ_INCR_test"}
set test_data_defines {"32" "64"}
set test_addr_defines {"32" "64"}

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

        # Run the simulation
        vopt top_test_uvm -o top_optimized +acc +cover=bcefsx+ahb_lite(rtl)
        vsim top_optimized -cover -solvefaildebug=2 +UVM_TESTNAME=$test_name

        # Simulation control and coverage collection
        set NoQuitOnFinish 1
        onbreak {resume}
        log /* -r
        run -all
        coverage report -assert -details -zeros -verbose -output reports/assertion_based_coverage_report.txt -append /.
        coverage report -detail -cvg -directive -comments -option -memory -output reports/functional_coverage_report.txt {}

        coverage attribute -name TESTNAME -value $test_name
        coverage save reports/$test_name.ucdb
    }
}
