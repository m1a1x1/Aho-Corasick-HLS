Aho-Corasick-HLS
================

Synopsys
--------

Implementation of [Aho-Corasic algorithm](https://en.wikipedia.org/wiki/Aho%E2%80%93Corasick_algorithm) on the FPGA using the Intel HLS compiler.

Build
-----

Export paths to Modelsim, Quartus and Modelsim gcc headers.

export PATH=PATH_TO_MODELSIM/modelsim/linux_x86_64:$PATH

export PATH=PATH_TO_QUARTUS/quartus/bin:$PATH

export INCL_MODELSIM=PATH_TO_MODELSIM/modelsim/gcc-4.5.0-linux_x86_64/include/c++/4.5.0

export INCL_MODELSIM_GNU=PATH_TO_MODELSIM/modelsim/gcc-4.5.0-linux_x86_64/include/c++/4.5.0/x86_64-unknown-linux-gnu

source PATH_TO_QUARTUS/hls/init_hls.sh

make test-fpga
