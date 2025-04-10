# Load RUCKUS environment and library
source $::env(RUCKUS_PROC_TCL)

# Load submodule code
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/axi-soc-ultra-plus-core/hardware/XilinxZcu216

# Load RTL code
loadSource -dir "$::DIR_PATH/rtl"

# Load IP cores
loadIpCore -dir "$::DIR_PATH/ip"

