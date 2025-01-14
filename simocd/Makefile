VERILATOR ?= verilator
VDIRFB := obj_dir

CXX := g++

VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e " s/^.*=\s*//"')
VROOT   := $(VERILATOR_ROOT)
VINCD   := $(VROOT)/include
VSRCRAW := verilated.cpp verilated_vcd_c.cpp
VSRC    := $(addprefix $(VINCD)/,$(VSRCRAW))

all: clean
	make comp

comp:
	rm -rf obj_dir
	verilator \
	--cc \
	--exe \
	--trace-fst \
	--trace-params \
	--trace-structs \
	--trace-underscore \
	--timescale 10ns/1ns \
	--Wno-lint \
	--no-timing \
	--top-module debug_top \
	-F ./rtl_list.lst \
	./jtag_vpi/jtag_common.c \
	./jtag_vpi/jtagServer.cpp \
	tb_sim_top.cpp
	make -C obj_dir -f Vdebug_top.mk

setup:
	git clone --recurse-submodules https://github.com/fjullien/jtag_vpi.git

sim:
	make comp
	./obj_dir/Vdebug_top

clean:
	rm -f *.vcd
	rm -f *.fst
	rm -f *.hier
	rm -f *.o
	rm -rf obj_dir
