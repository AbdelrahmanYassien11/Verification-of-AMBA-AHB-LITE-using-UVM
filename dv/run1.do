set test_name WRITE_READ_INCR_test

vopt top_test_uvm -o top_optimized +acc +cover=bcefsx+ahb_lite(rtl)

vsim top_optimized -cover -solvefaildebug=2 +UVM_TESTNAME=$test_name

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all
coverage report -assert -details -zeros -verbose -output reports/assertion_based_coverage_report.txt -append /.
coverage report -detail -cvg -directive -comments -option -memory -output reports/functional_coverage_report.txt {}

coverage attribute -name TESTNAME -value $test_name
coverage save reports/$test_name.ucdb