# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct F:\GitKraken\XILINX_BASYS_3\Vitis\CPU1_platform\platform.tcl
# 
# OR launch xsct and run below command.
# source F:\GitKraken\XILINX_BASYS_3\Vitis\CPU1_platform\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {CPU1_platform}\
-hw {F:\GitKraken\XILINX_BASYS_3\Vivado_BASYS_3\main.xsa}\
-proc {microblaze_0} -os {standalone} -out {F:/GitKraken/XILINX_BASYS_3/Vitis}

platform write
platform generate -domains 
platform active {CPU1_platform}
platform generate
platform active {CPU1_platform}
platform config -updatehw {F:/GitKraken/XILINX_BASYS_3/Vivado_BASYS_3/main.xsa}
platform generate -domains 
