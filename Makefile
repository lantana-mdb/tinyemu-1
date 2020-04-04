#
# TinyEMU
# 
# Copyright (c) 2016-2018 Fabrice Bellard
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# if set, compile the 128 bit emulator. Note: the 128 bit target does
# not compile if gcc does not support the int128 type (32 bit hosts).
#CONFIG_INT128=y

CC=$(CROSS_PREFIX)gcc
STRIP=$(CROSS_PREFIX)strip
CFLAGS=-O2 -Wall -g -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -MMD
CFLAGS+=-D_GNU_SOURCE -DCONFIG_VERSION=\"$(shell cat VERSION)\"
LDFLAGS=

bindir=/usr/local/bin
INSTALL=install

PROGS+= temu$(EXE)

all: $(PROGS)

EMU_OBJS:=virtio.o pci.o fs.o cutils.o iomem.o simplefb.o \
    json.o machine.o temu.o

EMU_OBJS+=fs_disk.o
EMU_LIBS=-lrt

EMU_OBJS+=riscv_machine.o softfp.o riscv_cpu32.o riscv_cpu64.o
ifdef CONFIG_INT128
CFLAGS+=-DCONFIG_RISCV_MAX_XLEN=128
EMU_OBJS+=riscv_cpu128.o
else
CFLAGS+=-DCONFIG_RISCV_MAX_XLEN=64
endif

temu$(EXE): $(EMU_OBJS)
	$(CC) $(LDFLAGS) -o $@ $^ $(EMU_LIBS)

riscv_cpu32.o: riscv_cpu.c
	$(CC) $(CFLAGS) -DMAX_XLEN=32 -c -o $@ $<

riscv_cpu64.o: riscv_cpu.c
	$(CC) $(CFLAGS) -DMAX_XLEN=64 -c -o $@ $<

riscv_cpu128.o: riscv_cpu.c
	$(CC) $(CFLAGS) -DMAX_XLEN=128 -c -o $@ $<

install: $(PROGS)
	$(STRIP) $(PROGS)
	$(INSTALL) -m755 $(PROGS) "$(DESTDIR)$(bindir)"

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.d *~ $(PROGS)

-include $(wildcard *.d)
