if [file exists "work"] {vdel -all}
vlib work
vlog -f dut.f +cover -covercells
vlog -f tb.f +cover -covercells
vopt top_test_uvm -o top_optimized +acc +cover=bcefsx+ahb_lite(rtl)

#set test_names {"WRITE_READ_INCR_test" "WRITE_READ_INCR4_test" "WRITE_READ_INCR8_test" "WRITE_READ_INCR16_test" "WRITE_READ_WRAP4_test" "WRITE_READ_WRAP8_test" "WRITE_READ_WRAP16_test" "runall_test"}
set test_names {reset_test}

foreach test_name $test_names {
	vsim top_optimized -cover -voptargs=+acc -solvefaildebug=2 -debugDB +UVM_TESTNAME=$test_name

	add wave -position insertpoint sim:/top_test_uvm/DUT/subordinate1/*
	add wave -position insertpoint sim:/top_test_uvm/DUT/subordinate2/*
	add wave -position insertpoint sim:/top_test_uvm/DUT/subordinate3/*
	add wave -position insertpoint sim:/top_test_uvm/DUT/subordinate_p_r/*
	add wave -position insertpoint sim:/top_test_uvm/DUT/subordinate_p_wr/*

	add wave -position insertpoint sim:/top_test_uvm/DUT/mux1/*

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

	set NoQuitOnFinish 1
	onbreak {resume}
	log /* -r
	run -all
	coverage report -assert -details -zeros -verbose -output reports/assertion_based_coverage_report.txt -append /.
	coverage report -detail -cvg -directive -comments -option -memory -output reports/functional_coverage_report.txt {}

	coverage attribute -name TESTNAME -value $test_name
	coverage save reports/$test_name.ucdb

}

#vcover merge reports/WRITE_READ_INCR_test.ucdb reports/WRITE_READ_INCR4_test.ucdb reports/WRITE_READ_INCR8_test.ucdb reports/WRITE_READ_INCR16_test.ucdb reports/WRITE_READ_WRAP4_test.ucdb reports/WRITE_READ_WRAP8_test.ucdb reports/WRITE_READ_WRAP16_test.ucdb reports/runall_test.ucdb -out reports/AHB_lite_tb.ucdb

#quit -sim

#vcover report -output reports/AHB_lite_coverage_report.txt reports/AHB_lite_tb.ucdb -zeros -details -annotate -all