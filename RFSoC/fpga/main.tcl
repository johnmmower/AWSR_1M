
# vivado -mode batch -source main.tcl -tclargs build

set _build no

for {set i 0} {$i < $argc} {incr i} {
    if {[lindex $argv $i] eq "build"} {
	puts "will build, also"
	set _build yes
    }
}

set origin_dir [file dirname [info script]]

create_project main $origin_dir/main -part xczu28dr-ffvg1517-2-e

set obj [current_project]
set_property -name "board_part" -value "xilinx.com:zcu111:part0:1.4" -objects $obj

add_files [glob srcs/hdl/*.v]
add_files [glob srcs/hdl/*.vh]
add_files -fileset constrs_1 [glob srcs/xdc/*.xdc]
import_files -force -norecurse

source design_main.tcl

set_property top main [current_fileset]

if { $_build } {
    launch_runs synth_1
    wait_on_run synth_1

    launch_runs impl_1 -to_step write_bitstream
    wait_on_run impl_1

    write_hw_platform -fixed -include_bit -force -file ./main/main.xsa
}
