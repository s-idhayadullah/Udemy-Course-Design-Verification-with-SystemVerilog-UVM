vlib work

vlog -f run.f

vsim work.top_testbench +UVM_TESTNAME=reg_access_test

add wave -position insertpoint sim:/top_testbench/apb_inf/*
