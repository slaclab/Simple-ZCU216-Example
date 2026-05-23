# Simple-ZCU216-Example

Reference RFSoC ADC/DAC application for the SLAC SoC platform on the Xilinx ZCU216 evaluation board (`xczu49dr-ffvf1760-2-e`).

**Application docs:** https://slaclab.github.io/Simple-ZCU216-Example/

**Shared workflow docs (clone, FW build, Yocto, SD card, Rogue install/launch, remote bitstream update):** https://slaclab.github.io/axi-soc-ultra-plus-core/

## Board-specific deltas

- **Target directory:** `firmware/targets/SimpleZcu216Example/`
- **Default DHCP IP convention:** `10.0.0.10` (used in remote-update and GUI launch examples on the docs site)
- **Board:** Xilinx ZCU216 evaluation board; FPGA part: `xczu49dr-ffvf1760-2-e`; firmware version: `v3.1.0.0` (`PRJ_VERSION = 0x03010000`)
- **Conda env (SLAC AFS):** `rogue_v6.12.0`
- **SD boot mode:** `Mode SW2 [4:1] = 1110` (switch OFF = 1 = High; ON = 0 = Low).
- **ZCU216-specific Yocto notes:** none beyond the shared procedure (the bare-metal-vs-Docker, build-output redirection, host-package prereqs all live on the hub).
