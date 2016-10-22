# Makefile for ADABoot modified from ATmegaBOOT
# 
# $Id$
#
#------------------------------------------------------------
#
# Brian B Riley  <brianbr@wulfden.org>  -- BBR
#
# 20090413: Modfified for ADAboot for 644P (BBR)
# 20090325: Modified for the ADABoot for 168 and 328 (BBR) 
# 20050718: Created - E. Lins
#
# Instructions
#
#  make atmega168       - compile for 168
#
#  make atmega168_isp   - burn bootloader with ISP
#
#  make atmega328p      - compile for 328
#
#  make atmega328p_isp  - burn bootloader with ISP
#
#  (suggestions for 644 and 324p, but they are not implemented yet
#    need Fuse settings for 644 and 324p -- BBR
#
#  make atmega644p      - compile for 644p (alternately use 644 or 324p)
#
#  make atmega644p_isp  - burn bootloader with ISP (alternately use 644 or 324p)
#
#------------------------------------------------------------
#
# - if changes made only to Makefile, remember to "touch *.c"
#   to force make to recompile -- BBR
#
#------------------------------------------------------------
#
#

# program name should not be changed...
PROGRAM    = ATmegaBOOT_168

# enter the parameters for the avrdude isp tool
ISPTOOL	   = stk500v2
ISPPORT	   = usb
ISPSPEED   = -b 115200

MCU_TARGET = atmega168
LDSECTION  = --section-start=.text=0x3800

# the efuse should really be 0xf8; since, however, only the lower
# three bits of that byte are used on the atmega168, avrdude gets
# confused if you specify 1's for the higher bits, see:
# http://tinker.it/now/2007/02/24/the-tale-of-avrdude-atmega168-and-extended-bits-fuses/
#
# similarly, the lock bits should be 0xff instead of 0x3f (to
# unlock the bootloader section) and 0xcf instead of 0x0f (to
# lock it), but since the high two bits of the lock byte are
# unused, avrdude would get confused.

ISPFUSES    = avrdude -c $(ISPTOOL) -p $(MCU_TARGET) -P $(ISPPORT) $(ISPSPEED) \
-e -u -U lock:w:0x3f:m -U efuse:w:0x$(EFUSE):m -U hfuse:w:0x$(HFUSE):m -U lfuse:w:0x$(LFUSE):m
ISPFLASH    = avrdude -c $(ISPTOOL) -p $(MCU_TARGET) -P $(ISPPORT) $(ISPSPEED) \
-U flash:w:$(TARGET).hex -U lock:w:0x0f:m

STK500 = "C:\Program Files\Atmel\AVR Tools\STK500\Stk500.exe"
STK500-1 = $(STK500) -e -d$(MCU_TARGET) -pf -vf -if$(TARGET).hex \
-lFF -LFF -f$(HFUSE)$(LFUSE) -EF8 -ms -q -cUSB -I200kHz -s -wt
STK500-2 = $(STK500) -d$(MCU_TARGET) -ms -q -lCF -LCF -cUSB -I200kHz -s -wt


OBJ        = $(PROGRAM).o
OPTIMIZE   = -O2

DEFS       = 
LIBS       =

AVRTOOLSDIR: = ~/avrtools.old/bin/
CC         = $(AVRTOOLSDIR)avr-gcc

# Override is only needed by avr-lib build system.

override CFLAGS        = -g -Wall $(OPTIMIZE) -mmcu=$(MCU_TARGET) -DF_CPU=$(AVR_FREQ) $(DEFS)
override LDFLAGS       = -Wl,$(LDSECTION)
#override LDFLAGS       = -Wl,-Map,$(PROGRAM).map,$(LDSECTION)

OBJCOPY        = avr-objcopy
OBJDUMP        = avr-objdump

all:


atmega168: TARGET = atmega168
atmega168: MCU_TARGET = atmega168
atmega168: CFLAGS += '-DMAX_TIME_COUNT=F_CPU>>4' '-DADABOOT=4' '-DWATCHDOG_MODS'
atmega168: AVR_FREQ = 16000000L 
atmega168: LDSECTION  = --section-start=.text=0x3800
atmega168: ADABoot_168.hex

atmega168_isp: atmega168
atmega168_isp: TARGET = ADABoot_168
atmega168_isp: MCU_TARGET = atmega168
atmega168_isp: HFUSE = DD
atmega168_isp: LFUSE = FF
atmega168_isp: EFUSE = 00
atmega168_isp: isp

noled18: CFLAGS += '-DNOLED'
noled18: AVR_FREQ = 18432000L
noled18: adaboot328
	mv ADABoot_328.hex ADABoot_328_noled18.hex

ada16: AVR_FREQ = 16000000L
ada16: adaboot328
	mv ADABoot_328.hex ADABoot_328_16.hex

ada18: AVR_FREQ = 18432000L
ada18: adaboot328
	mv ADABoot_328.hex ADABoot_328_18.hex

x10116: AVR_FREQ = 16000000L
x10116: CFLAGS += '-DMCUSIG_2=0x16'
x10116: adaboot328
	mv ADABoot_328.hex ADABoot_x101_16.hex

x10118: AVR_FREQ = 18432000L
x10118: CFLAGS += '-DMCUSIG_2=0x16'
x10118: adaboot328
	mv ADABoot_328.hex ADABoot_x101_18.hex

x10120: AVR_FREQ = 20000000L
x10120: CFLAGS += '-DMCUSIG_2=0x16'
x10120: adaboot328
	mv ADABoot_328.hex ADABoot_x101_20.hex

usb128: AVR_FREQ = 16000000L
usb128: MCU_TARGET = at90usb1287
usb128: CFLAGS += '-DMAX_TIME_COUNT=F_CPU>>4' '-DBAUD_RATE=57600' '-DADABOOT=4' '-DWATCHDOG_MODS'
usb128: LDSECTION  = --section-start=.text=0x1F000
usb128: ADABoot_usb128_16.hex


atmega328p: adaboot328
	mv ADABoot_328.hex ADABoot_328_Arduino.hex

adaboot328: MCU_TARGET = atmega328p
adaboot328: CFLAGS += '-DMAX_TIME_COUNT=F_CPU>>4' '-DBAUD_RATE=57600' '-DADABOOT=4' '-DWATCHDOG_MODS'
#adaboot328: AVR_FREQ:=16000000L
adaboot328: LDSECTION  = --section-start=.text=0x7800
adaboot328: ADABoot_328.hex

atmega328p_isp: adaboot328
atmega328p_isp: TARGET = ADABoot_328_Arduino
atmega328p_isp: MCU_TARGET = atmega328p
atmega328p_isp: HFUSE = DA
atmega328p_isp: LFUSE = FF
atmega328p_isp: EFUSE = 05
atmega328p_isp: isp

atmega644p: TARGET = atmega644p
atmega644p: MCU_TARGET = atmega644p
atmega644p: CFLAGS += '-DMAX_TIME_COUNT=F_CPU>>4' '-DBAUD_RATE=38400' '-DADABOOT=4' '-DWATCHDOG_MODS'
atmega644p: AVR_FREQ = 16000000L 
atmega644p: LDSECTION  = --section-start=.text=0xF800
atmega644p: ADABoot_644p.hex

atmega644p_isp: atmega644p
atmega644p_isp: TARGET = ADABoot_644p
atmega644p_isp: MCU_TARGET = atmega644p
atmega644p_isp: HFUSE = DC
atmega644p_isp: LFUSE = FF
atmega644p_isp: EFUSE = FD
atmega644p_isp: isp


isp: $(TARGET)
	$(ISPFUSES)
	$(ISPFLASH)

isp-stk500: $(TARGET).hex
	$(STK500-1)
	$(STK500-2)

%.elf: $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	rm -rf *.o *.elf *.lst *.map *.sym *.lss *.eep *.srec *.bin

%.lst: %.elf
	$(OBJDUMP) -h -S $< > $@

%.hex: %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

%.srec: %.elf
	$(OBJCOPY) -j .text -j .data -O srec $< $@

%.bin: %.elf
	$(OBJCOPY) -j .text -j .data -O binary $< $@
	
