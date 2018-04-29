CXXFLAGS := -D __APP__ -g --std=c++11 -static
CFLAGS := -D __APP__ -g -std=c99 
SOURCE_FILES  := ac.cpp main.cpp

default: 
	$(CROSS_COMPILE)g++ $(SOURCE_FILES) $(CXXFLAGS) -o ac_app 
	$(CROSS_COMPILE)gcc mem.c $(CFLAGS) -o send_pattern

clean:
	rm ac_app send_pattern 
