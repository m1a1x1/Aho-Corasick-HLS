vlib work

vlog /home/mt/Altera/altera/intelFPGA_lite/17.0/quartus/eda/sim_lib/altera_mf.v
vlog -sv ../rtl/rd_dma_regs_pkg.sv
vlog -sv ../rtl/rd_dma.sv
vlog -sv ../rtl/sc_fifo.sv

vlog -sv top_tb.sv

vsim -novopt top_tb

add wave -hex -r top_tb/*

run -all
