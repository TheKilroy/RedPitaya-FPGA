################################################################################
# Vivado tcl script for building RedPitaya FPGA in non project mode
#
# Usage:
# vivado -mode batch -source red_pitaya_vivado_project_Z10.tcl -tclargs projectname
################################################################################

set prj_name [lindex $argv 0]
puts "Project name: $prj_name"
cd prj/$prj_name
#cd prj/$::argv 0

################################################################################
# define paths
################################################################################

set path_brd ../../brd
set path_rtl rtl
set path_ip  ip
if {$prj_name eq "stream_app"} {set path_sdc sdc} else {set path_sdc ../../sdc}

################################################################################
# list board files
################################################################################

set_param board.repoPaths [list $path_brd]

################################################################################
# setup an in memory project
################################################################################

set part xc7z010clg400-1

create_project -part $part -force redpitaya ./project

################################################################################
# create PS BD (processing system block design)
################################################################################

# file was created from GUI using "write_bd_tcl -force ip/systemZ10.tcl"
# create PS BD
source                            $path_ip/systemZ10.tcl

# generate SDK files

generate_target all [get_files    system.bd]

################################################################################
# read files:
# 1. RTL design sources
# 2. IP database files
# 3. constraints
################################################################################

add_files                         ../../$path_rtl
add_files                         $path_rtl

#add_files -fileset constrs_1      $path_sdc/red_pitaya.xdc
add_files -fileset constrs_1      $path_sdc/red_pitaya.xdc

################################################################################
# start gui
################################################################################

import_files -force

set_property top red_pitaya_top [current_fileset]
if {$prj_name eq "stream_app"} {add_files -norecurse .srcs/sources_1/bd/system/hdl/system_wrapper.v}
update_compile_order -fileset sources_1