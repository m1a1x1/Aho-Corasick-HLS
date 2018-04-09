SOURCE_FILES  := ac.cpp ac_tb.cpp
HLS_CXX_FLAGS :=  -I $(INCL_MODELSIM) -I $(INCL_MODELSIM_GNU) -Wc++11-extensions -Wnon-pod-varargs -v

CXX := i++
override CXXFLAGS := $(CXXFLAGS)
CXXFLAGS :=  -I $(LIB_MODELSIM) 
 
LIBRARIES:=  

# OS-dependant tools
RM  := rm -rfv

ifeq ($(MAKECMDGOALS),)
  $(info No target specified, defaulting to test-x86-64)
  $(info Available targets: test-x86-64, test-fpga, test-gpp, clean)
endif

# Any tools installed with HLS can be found relative to the location of i++
HLS_INSTALL_DIR := $(shell which i++ | sed 's|/bin/i++||g')

# Run the i++ x86 test by default
.PHONY: default
default: test-x86-64

# Compile the component and testbench using g++ and run them as a regular program
.PHONY: test-gpp
test-gpp: CXX := g++
test-gpp: CXXFLAGS := $(CXXFLAGS) -I"$(HLS_INSTALL_DIR)/include" -L"$(HLS_INSTALL_DIR)/host/linux64/lib" -lhls_emul -o test-gpp $(LIBRARIES) -g --std=c++11
test-gpp: $(SOURCE_FILES)
	$(CXX) $(SOURCE_FILES) $(CXXFLAGS)
	@echo "+-------------------------------------+"
	@echo "| Run ./test-gpp to execute the test. |"
	@echo "+-------------------------------------+"

# Run the testbench and the component as a regular program
.PHONY: test-x86-64
test-x86-64: CXXFLAGS := $(CXXFLAGS) $(HLS_CXX_FLAGS) -march=x86-64 -o test-x86-64 
test-x86-64: $(SOURCE_FILES)
	$(CXX) $(SOURCE_FILES) $(CXXFLAGS)
	@echo "+----------------------------------------+"
	@echo "| Run ./test-x86-64 to execute the test. |"
	@echo "+----------------------------------------+"

# Run a simulation with the C testbench and verilog component
.PHONY: test-fpga
test-fpga: CXXFLAGS := $(CXXFLAGS) $(HLS_CXX_FLAGS) -march=5CSEBA6U23I7 -o test-fpga -ghdl 

test-fpga: $(SOURCE_FILES)
	$(CXX) $(SOURCE_FILES) $(CXXFLAGS)
	@echo "+--------------------------------------+"
	@echo "| Run ./test-fpga to execute the test. |"
	@echo "+--------------------------------------+"

.PHONY: hw-fpga
hw-fpga: CXXFLAGS := $(CXXFLAGS) $(HLS_CXX_FLAGS) -march=5CSEBA6U23I7 -o hw-fpga -D __ALWAYS_RUN__ --simulator none 
hw-fpga: $(SOURCE_FILES)
	$(CXX) $(SOURCE_FILES) $(CXXFLAGS)
	@echo "+--------------------------------------+"
	@echo "| Build whith always_run is end.       |"
	@echo "+--------------------------------------+"



# Clean up temprary and delivered files
CLEAN_FILES := test-gpp \
               test-gpp.prj \
               test-fpga \
               test-fpga.prj \
               test-x86-64 \
               test-x86-64.prj \
               *.tmp *.o *.txt
clean:
	-$(RM) $(CLEAN_FILES)
