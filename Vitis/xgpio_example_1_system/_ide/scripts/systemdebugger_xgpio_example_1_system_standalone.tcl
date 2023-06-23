# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: F:\GitKraken\XILINX_BASYS_3\Vitis\xgpio_example_1_system\_ide\scripts\systemdebugger_xgpio_example_1_system_standalone.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source F:\GitKraken\XILINX_BASYS_3\Vitis\xgpio_example_1_system\_ide\scripts\systemdebugger_xgpio_example_1_system_standalone.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw F:/GitKraken/XILINX_BASYS_3/Vitis/CPU1_platform/export/CPU1_platform/hw/main.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow F:/GitKraken/XILINX_BASYS_3/Vitis/xgpio_example_1/Debug/xgpio_example_1.elf
bpadd -addr &main
