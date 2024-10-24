if [file exists "work"] {vdel -all}
vlib work
vlog -f dut.f +cover -covercells
vlog -f tb.f +cover -covercells
vopt top_test_uvm -o top_optimized +acc +cover=bcefsx+ahb_lite(rtl)



vsim top_optimized -cover -solvefaildebug=2 +UVM_TESTNAME=write_twice_test
#add wave -position insertpoint sim:/top_test_uvm/DUT/*
#add wave -position insertpoint  \
#sim:/top_test_uvm/f_if/counter
#add wave -position insertpoint  \
#sim:/top_test_uvm/f_if/RECIEVING_PHASE_FLAG
add wave -position insertpoint sim:/top_test_uvm/DUT/slave1/*
add wave -position insertpoint  \
sim:/top_test_uvm/DUT/mux1/HRESP
add wave -position insertpoint  \
sim:/top_test_uvm/DUT/mux1/HSEL_bus_reg_s
run -all
#set NoQuitOnFinish 1
#onbreak {resume}
#log /* -r
#run -all
#coverage report -assert -details -zeros -verbose -output reports/assertion_based_coverage_report.txt -append /.
#coverage report -detail -cvg -directive -comments -option -memory -output reports/functional_coverage_report.txt {}

#coverage attribute -name TESTNAME -value reset_test
#coverage save reports/reset_test.ucdb



#vsim top_optimized -cover +UVM_TESTNAME=reset_write_read_all_test
#set NoQuitOnFinish 1
#onbreak {resume}
#log /* -r
#run -all
#coverage report -assert -details -zeros -verbose -output reports/assertion_based_coverage_report.txt -append /.
#coverage report -detail -cvg -directive -comments -option -memory -output reports/functional_coverage_report.txt {}

#coverage attribute -name TESTNAME -value reset_write_read_all_test
#coverage save reports/reset_write_read_all_test.ucdb



#vsim top_optimized -cover +UVM_TESTNAME=write_read_rand_test
#set NoQuitOnFinish 1
#onbreak {resume}
#log /* -r
#run -all
#coverage report -assert -details -zeros -verbose -output reports/assertion_based_coverage_report.txt -append /.
#coverage report -detail -cvg -directive -comments -option -memory -output reports/functional_coverage_report.txt {}

#coverage attribute -name TESTNAME -value write_read_rand_test
#coverage save reports/write_read_rand_test.ucdb


#vsim top_optimized -cover +UVM_TESTNAME=concurrent_write_read_rand_test
#set NoQuitOnFinish 1
#onbreak {resume}
#log /* -r
#run -all
#coverage report -assert -details -zeros -verbose -output reports/assertion_based_coverage_report.txt -append /.
#coverage report -detail -cvg -directive -comments -option -memory -output reports/functional_coverage_report.txt {}

#coverage attribute -name TESTNAME -value concurrent_write_read_rand_test
#coverage save reports/concurrent_write_read_rand_test.ucdb


#vcover merge reports/reset_write_read_all_test.ucdb reports/write_read_rand_test.ucdb reports/reset_test.ucdb reports/concurrent_write_read_rand_test.ucdb -out reports/FIFO_tb.ucdb

#quit -sim

#vcover report -output reports/FIFO_coverage_report.txt reports/FIFO_tb.ucdb -zeros -details -annotate -all