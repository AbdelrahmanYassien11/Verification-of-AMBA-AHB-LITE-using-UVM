if [file exists "work"] {vdel -all}
vlib work
vlog -f dut.f +cover -covercells
vlog -f tb.f +cover -covercells
vopt top_test_uvm -o top_optimized +acc +cover=bcefsx+ahb_lite(rtl)



vsim top_optimized -cover -solvefaildebug=2 +UVM_TESTNAME=runall_test
#add wave -position insertpoint sim:/top_test_uvm/DUT/*
#add wave -position insertpoint  \
#sim:/top_test_uvm/f_if/counter
#add wave -position insertpoint  \
#sim:/top_test_uvm/f_if/RECIEVING_PHASE_FLAG
add wave -position insertpoint sim:/top_test_uvm/DUT/subordinate2/*
add wave -position insertpoint sim:/top_test_uvm/DUT/subordinate1/*
add wave -position insertpoint sim:/top_test_uvm/DUT/subordinate3/*
add wave -position insertpoint sim:/top_test_uvm/DUT/mux1/*
add wave -position insertpoint sim:/top_test_uvm/DUT/mux1/HRESP
add wave -position insertpoint sim:/top_test_uvm/DUT/mux1/HSEL_bus_reg_s


add wave /top_test_uvm/DUT/subordinate1/sva/idle_inputs_assert
add wave /top_test_uvm/DUT/subordinate1/sva/idle_ready_assert

add wave /top_test_uvm/DUT/subordinate1/sva/reset_addr_assert
add wave /top_test_uvm/DUT/subordinate1/sva/reset_duration_assert

add wave /top_test_uvm/DUT/subordinate1/sva/burst_trans_nonseq_assert
add wave /top_test_uvm/DUT/subordinate1/sva/burst_trans_seq_assert

add wave /top_test_uvm/DUT/subordinate1/sva/incr4_idle_assert
add wave /top_test_uvm/DUT/subordinate1/sva/incr8_idle_assert
add wave /top_test_uvm/DUT/subordinate1/sva/incr16_idle_assert
add wave /top_test_uvm/DUT/subordinate1/sva/wrap4_idle_assert
add wave /top_test_uvm/DUT/subordinate1/sva/wrap8_idle_assert
add wave /top_test_uvm/DUT/subordinate1/sva/wrap16_idle_assert


add wave /top_test_uvm/DUT/subordinate2/sva/incr4_idle_assert
add wave /top_test_uvm/DUT/subordinate2/sva/incr8_idle_assert
add wave /top_test_uvm/DUT/subordinate2/sva/incr16_idle_assert
add wave /top_test_uvm/DUT/subordinate2/sva/wrap4_idle_assert
add wave /top_test_uvm/DUT/subordinate2/sva/wrap8_idle_assert
add wave /top_test_uvm/DUT/subordinate2/sva/wrap16_idle_assert

add wave /top_test_uvm/DUT/subordinate2/sva/idle_inputs_assert
add wave /top_test_uvm/DUT/subordinate2/sva/idle_ready_assert

add wave /top_test_uvm/DUT/subordinate2/sva/reset_addr_assert
add wave /top_test_uvm/DUT/subordinate2/sva/reset_duration_assert

add wave /top_test_uvm/DUT/subordinate2/sva/burst_trans_nonseq_assert
add wave /top_test_uvm/DUT/subordinate2/sva/burst_trans_seq_assert



add wave /top_test_uvm/DUT/subordinate3/sva/incr4_idle_assert
add wave /top_test_uvm/DUT/subordinate3/sva/incr8_idle_assert
add wave /top_test_uvm/DUT/subordinate3/sva/incr16_idle_assert
add wave /top_test_uvm/DUT/subordinate3/sva/wrap4_idle_assert
add wave /top_test_uvm/DUT/subordinate3/sva/wrap8_idle_assert
add wave /top_test_uvm/DUT/subordinate3/sva/wrap16_idle_assert

add wave /top_test_uvm/DUT/subordinate3/sva/idle_inputs_assert
add wave /top_test_uvm/DUT/subordinate3/sva/idle_ready_assert

add wave /top_test_uvm/DUT/subordinate3/sva/reset_addr_assert
add wave /top_test_uvm/DUT/subordinate3/sva/reset_duration_assert

add wave /top_test_uvm/DUT/subordinate3/sva/burst_trans_nonseq_assert
add wave /top_test_uvm/DUT/subordinate3/sva/burst_trans_seq_assert

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