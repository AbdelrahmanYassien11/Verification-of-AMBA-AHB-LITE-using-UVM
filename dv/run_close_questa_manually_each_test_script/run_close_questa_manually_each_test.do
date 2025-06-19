# Use unique basename for outputs
set basename "${test_name}_${DATA_WIDTH}_${ADDR_WIDTH}"

# Ensure REPORTS_DIR is absolute or exists
file mkdir $REPORTS_DIR

# Use unique transcript file per run (with full path)
transcript file "${REPORTS_DIR}/${basename}_transcript.log"

# Optimize the design
vopt top_test_uvm -o top_optimized +acc +cover=bcefsx+ahb_lite(rtl)

# Simulate with UVM_TESTNAME
vsim top_optimized -cover -solvefaildebug=2 +UVM_TESTNAME=$test_name

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all

# Coverage reports with unique names
coverage report -assert -details -zeros -verbose -output "${REPORTS_DIR}/${basename}_assertion_based_coverage_report.txt" -append .
coverage report -detail -cvg -directive -comments -option -memory -output "${REPORTS_DIR}/${basename}_functional_coverage_report.txt" {}

# Save UCDB with unique name
coverage attribute -name TESTNAME -value $test_name
coverage save "${REPORTS_DIR}/${basename}.ucdb"

# Close transcript
transcript file ""

quit -f