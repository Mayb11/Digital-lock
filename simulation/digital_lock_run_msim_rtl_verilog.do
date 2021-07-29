transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/84674/Desktop/MSC/ELEC5566M/Github/ELEC5566M-Assignment2-haozhe1 {C:/Users/84674/Desktop/MSC/ELEC5566M/Github/ELEC5566M-Assignment2-haozhe1/digital_lock.v}

vlog -vlog01compat -work work +incdir+C:/Users/84674/Desktop/MSC/ELEC5566M/Github/ELEC5566M-Assignment2-haozhe1 {C:/Users/84674/Desktop/MSC/ELEC5566M/Github/ELEC5566M-Assignment2-haozhe1/digital_lock_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  digital_lock_tb

do C:/Users/84674/Desktop/MSC/ELEC5566M/Github/ELEC5566M-Assignment2-haozhe1/../ELEC5566M-Resources/simulation/load_sim.tcl
