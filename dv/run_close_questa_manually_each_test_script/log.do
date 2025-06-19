if [file exists "work"] {vdel -all}
vlib work
vlog -f dut.f +cover -covercells
vlog -f tb.f +cover -covercells
quit -f