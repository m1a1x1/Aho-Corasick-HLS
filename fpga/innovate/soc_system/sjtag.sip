set_global_assignment -entity "sjtag" -library "lib_sjtag" -name IP_TOOL_NAME "altera_soft_core_jtag_io"
set_global_assignment -entity "sjtag" -library "lib_sjtag" -name IP_TOOL_VERSION "17.1"
set_global_assignment -entity "sjtag" -library "lib_sjtag" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_sjtag" -name SPD_FILE [file join $::quartus(sip_path) "sjtag.spd"]

set_global_assignment -library "lib_sjtag" -name MISC_FILE [file join $::quartus(sip_path) "sjtag_sim/sjtag.v"]
set_global_assignment -library "lib_sjtag" -name MISC_FILE [file join $::quartus(sip_path) "sjtag_sim/altera_soft_core_jtag_io/altera_soft_core_jtag_io.v"]
