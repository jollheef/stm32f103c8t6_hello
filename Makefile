TARGET := stm32f103c8t6

STM32_DEVICE := STM32F10X_MD

LDSCRIPT_INC := extra

BUILDDIR := out

SRCS := $(wildcard src/*.c)

OPENOCD := openocd
OPENOCD_CFG := extra/stm32f10x-openocd.cfg

INCDIRS += -I cmsis
INCDIRS += -I spl -I spl/inc

DEFINES += -D USE_STDPERIPH_DRIVER
DEFINES += -D $(STM32_DEVICE)

CFLAGS := -Wall -g -std=c99 -Os
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m3 -march=armv7-m
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -Wl,--gc-sections -Wl,-Map=$(BUILDDIR)/$(TARGET).map
CFLAGS += $(INCDIRS) $(DEFINES)
CFLAGS += -MMD -MP

CC      := arm-none-eabi-gcc
AS      := arm-none-eabi-as
OBJCOPY := arm-none-eabi-objcopy
OBJDUMP := arm-none-eabi-objdump
SIZE    := arm-none-eabi-size

ASRCS += $(wildcard extra/*.s)
SRCS += $(wildcard extra/*.c)

# Libraries
SRCS += $(wildcard cmsis/*.c)
SRCS += $(wildcard spl/src/*.c)

OBJS := $(SRCS:.c=.o)
OBJS += $(ASRCS:.s=.o)

ELF = $(BUILDDIR)/$(TARGET).elf
BIN = $(BUILDDIR)/$(TARGET).bin

all: size

$(BUILDDIR):
	@mkdir -p $(BUILDDIR)

$(ELF): $(OBJS) $(BUILDDIR)
	$(CC) $(CFLAGS) $(OBJS) -o $(ELF) -L$(LDSCRIPT_INC) -Tstm32f103x8_flash.ld

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $(ELF) $(BIN)

size: $(ELF)
	$(SIZE) $(ELF)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(AS) $(AFLAGS) -c $< -o $@

flash: $(BIN)
	$(OPENOCD) -f $(OPENOCD_CFG) -c "stm_flash `pwd`/$(BIN)" -c shutdown

erase:
	$(OPENOCD) -f $(OPENOCD_CFG) -c "stm_erase" -c shutdown

clean:
	$(RM) -r ./$(BUILDDIR) $(OBJS) $(OBJS:.o=.d)

# Other dependencies
-include $(OBJS:.o=.d)
