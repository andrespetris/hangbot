###############################################################################
# Makefile for the project grblshield
###############################################################################

## General Flags
PROJECT = grblshield
MCU = atmega328p
TARGET = grblshield.elf
CC = avr-gcc

CPP = avr-g++

## Options common to compile, link and assembly rules
COMMON = -mmcu=$(MCU)

## Compile options common for all C compilation units.
CFLAGS = $(COMMON)
CFLAGS += -Wall -gdwarf-2 -std=gnu99                                  -DF_CPU=16000000UL -O0 -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CFLAGS += -MD -MP -MT $(*F).o -MF dep/$(@F).d 

## Assembly specific flags
ASMFLAGS = $(COMMON)
ASMFLAGS += $(CFLAGS)
ASMFLAGS += -x assembler-with-cpp -Wa,-gdwarf2

## Linker flags
LDFLAGS = $(COMMON)
LDFLAGS +=  -Wl,-Map=grblshield.map


## Intel Hex file production flags
HEX_FLASH_FLAGS = -R .eeprom -R .fuse -R .lock -R .signature

HEX_EEPROM_FLAGS = -j .eeprom
HEX_EEPROM_FLAGS += --set-section-flags=.eeprom="alloc,load"
HEX_EEPROM_FLAGS += --change-section-lma .eeprom=0 --no-change-warnings


## Objects that must be built in order to link
OBJECTS = eeprom.o gcode.o limits.o main.o motion_control.o nuts_bolts.o planner.o protocol.o settings.o spindle_control.o stepper.o wiring_serial.o 

## Objects explicitly added by the user
LINKONLYOBJECTS = 

## Build
all: $(TARGET) grblshield.hex grblshield.eep grblshield.lss size

## Compile
eeprom.o: ../eeprom.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

gcode.o: ../gcode.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

limits.o: ../limits.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

main.o: ../main.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

motion_control.o: ../motion_control.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

nuts_bolts.o: ../nuts_bolts.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

planner.o: ../planner.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

protocol.o: ../protocol.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

settings.o: ../settings.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

spindle_control.o: ../spindle_control.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

stepper.o: ../stepper.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

wiring_serial.o: ../wiring_serial.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

##Link
$(TARGET): $(OBJECTS)
	 $(CC) $(LDFLAGS) $(OBJECTS) $(LINKONLYOBJECTS) $(LIBDIRS) $(LIBS) -o $(TARGET)

%.hex: $(TARGET)
	avr-objcopy -O ihex $(HEX_FLASH_FLAGS)  $< $@

%.eep: $(TARGET)
	-avr-objcopy $(HEX_EEPROM_FLAGS) -O ihex $< $@ || exit 0

%.lss: $(TARGET)
	avr-objdump -h -S $< > $@

size: ${TARGET}
	@echo
	@avr-size -C --mcu=${MCU} ${TARGET}

## Clean target
.PHONY: clean
clean:
	-rm -rf $(OBJECTS) grblshield.elf dep/* grblshield.hex grblshield.eep grblshield.lss grblshield.map


## Other dependencies
-include $(shell mkdir dep 2>NUL) $(wildcard dep/*)

