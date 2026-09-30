# Okular bootstrap build (brief §62: readable, modular, portable where possible)
CC      := cc
CFLAGS  := -std=c11 -O2 -Wall -Wextra -Wno-unused-parameter -Ibootstrap/include
RTFLAGS := -O2 -ffreestanding -nostdlib -fno-pie -fno-stack-protector \
           -fno-builtin -fno-asynchronous-unwind-tables -fno-asynchronous-unwind-tables

SRCS := $(wildcard bootstrap/src/*.c)
OBJS := $(patsubst bootstrap/src/%.c,build/bootstrap/%.o,$(SRCS))

.PHONY: all test clean

all: build/okular runtime/rt.o

build/okular: $(OBJS)
	@mkdir -p build/bootstrap
	$(CC) $(CFLAGS) -o $@ $(OBJS)

build/bootstrap/%.o: bootstrap/src/%.c
	@mkdir -p build/bootstrap
	$(CC) $(CFLAGS) -c -o $@ $<

# bootstrap runtime shim: freestanding C + _start trampoline, partial-linked
runtime/rt.o: runtime/rt.c runtime/rt_start.s
	$(CC) $(RTFLAGS) -c -o build/rt_code.o runtime/rt.c
	$(CC) -c -o build/rt_start.o runtime/rt_start.s
	ld -r -o runtime/rt.o build/rt_code.o build/rt_start.o

test: all
	bash tools/run_tests.sh

clean:
	rm -rf build/bootstrap build/okular build/rt_code.o build/rt_start.o runtime/rt.o
	rm -rf examples/*/build tests/tmp
