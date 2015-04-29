# Konfiguracja procesu kompilacji i linkowania





# Nazwa pliku wynikowego
MAIN_OUT = Kamami_Stm32_blinky




# Format pliku wynikowego
FORMAT = ihex





# Opcje kompilacji dla mikrokontrolerów Cortex M3
# Optymalizacja na 0
COMPILE_OPTS = -mcpu=cortex-m3 -mthumb -Wall -g -O0






# Katalogi zawierające kod użytkownika
INCLUDE_DIRS = -I . -I Include
INCLUDE_DIRS += -I . -I Src






# Katalogi zawierające pliki bibliotek ST
INCLUDE_DIRS += -I . -I STLibrary/inc
INCLUDE_DIRS += -I . -I STLibrary/src






# Katalogi zawierające skrypty linkera
LIBRARY_DIRS += -L Ldscripts
LIBRARY_DIRS += -L STLibrary





#Katalog dla plików wynikowych *.hex, *.elf, *.bin *.lss itd.
OUT_DIR = ./Output/




#Skrypt Linkera
LNKSCRIPT = ./Ldscripts/




# Pliki źródłowe użytkownika
LIBRARY = Src/main.o
LIBRARY += Src/stm32f10x_it.o
LIBRARY += Src/Stm32l_level.o
LIBRARY += Src/Lcd3310.o
LIBRARY += Src/StringsConv.o





# Biblioteki dostarczone przez firmę ST Microelectronics
#LIBRARY += STLibrary/src/stm32f10x_adc.o
#LIBRARY += STLibrary/src/stm32f10x_bkp.o
#LIBRARY += STLibrary/src/stm32f10x_can.o
#LIBRARY += STLibrary/src/stm32f10x_dma.o
#LIBRARY += STLibrary/src/stm32f10x_exti.o
#LIBRARY += STLibrary/src/stm32f10x_flash.o
#LIBRARY += STLibrary/src/stm32f10x_gpio.o
#LIBRARY += STLibrary/src/stm32f10x_i2c.o
#LIBRARY += STLibrary/src/stm32f10x_iwdg.o
#LIBRARY += STLibrary/src/stm32f10x_lib.o
#LIBRARY += STLibrary/src/stm32f10x_nvic.o
#LIBRARY += STLibrary/src/stm32f10x_pwr.o
#LIBRARY += STLibrary/src/stm32f10x_rcc.o
#LIBRARY += STLibrary/src/stm32f10x_rtc.o
#LIBRARY += STLibrary/src/stm32f10x_spi.o
#LIBRARY += STLibrary/src/stm32f10x_systick.o
#LIBRARY += STLibrary/src/stm32f10x_tim.o
#LIBRARY += STLibrary/src/stm32f10x_tim1.o
#LIBRARY += STLibrary/src/stm32f10x_usart.o
#LIBRARY += STLibrary/src/stm32f10x_wwdg.o
#LIBRARY += STLibrary/src/cortexm3_macro.o
LIBRARY += STLibrary/src/stm32f10x_vector.o

# Dodanie bibliotek dla kompilacji C++
#MATH_LIB = -lm
#CPLUSPLUS_LIB = -lstdc++

CC = arm-none-eabi-gcc
CFLAGS = $(COMPILE_OPTS) $(INCLUDE_DIRS)

CXX = arm-none-eabi-g++
CXXFLAGS = $(COMPILE_OPTS) $(INCLUDE_DIRS)
CXXFLAGS +=-fno-exceptions
CXXFLAGS +=-fno-rtti

# Pozwolenie na Debug dla C++
CXXFLAGS += -g

AS = arm-none-eabi-gcc
ASFLAGS = $(COMPILE_OPTS) -c

LD = arm-none-eabi-gcc
#LD = arm-none-eabi-g++
# Tu należy zmienić opcje -Map=$@.map aby otrzymać poprawny plik map w katalogu Output
#LDFLAGS = -Wl,--gc-sections,-Map=$@.map,-cref,-u,Reset_Handler $(INCLUDE_DIRS) $(LIBRARY_DIRS) $(CPLUSPLUS_LIB) -T $(LNKSCRIPT)stm32.ld
LDFLAGS = -Wl,--gc-sections,-Map=$(OUT_DIR)$(MAIN_OUT).map,-cref,-u,Reset_Handler $(INCLUDE_DIRS) $(LIBRARY_DIRS) $(CPLUSPLUS_LIB) -T $(LNKSCRIPT)stm32.ld

# Tu koniecznie należy dodać tą opcję jeśli chce się korzystać z C++ dla Cortexa on am tylko Thumb mode
LDFLAGS += -mthumb

OBJCP = arm-none-eabi-objcopy
#OBJCPFLAGS = -O binary

OBJCPFLAGSH = -O ihex

AR = arm-none-eabi-ar
ARFLAGS = cr

# Rozmiar plików po skompilowaniu
SIZE = arm-none-eabi-size


MAIN_OUT_ELF = $(OUT_DIR)$(MAIN_OUT).elf
MAIN_OUT_BIN = $(OUT_DIR)$(MAIN_OUT).bin
MAIN_OUT_HEX = $(OUT_DIR)$(MAIN_OUT).hex

MSG_SIZE_BEFORE = Rozmiar przed rozpoczęciem kompilacji: 
MSG_SIZE_AFTER = Rozmiar po zakończeniu kompilacji:
ODZIELENIE_DIALOGOW = --------------------------------------------------------------

# all

#all: gccversion $(MAIN_OUT_ELF) $(MAIN_OUT_BIN) sizeafter
all: gccversion $(MAIN_OUT_ELF) $(MAIN_OUT_HEX) sizeafter  

# main

# Wyświetl informację o versji kompilatora
gccversion : 
	@$(CC) --version; echo $(ODZIELENIE_DIALOGOW);

#$(MAIN_OUT_ELF): $(MAIN_OUT).o $(LIBRARY) 
#$(LD) $(LDFLAGS) $(MAIN_OUT).o $(LIBRARY) --output $@  
#@echo $(ODZIELENIE_DIALOGOW);

$(MAIN_OUT_ELF): $(LIBRARY) 
	$(LD) $(LDFLAGS) $(LIBRARY) --output $@  
	@echo $(ODZIELENIE_DIALOGOW);

$(MAIN_OUT_BIN): $(MAIN_OUT_ELF)
	$(OBJCP) $(OBJCPFLAGS) $< $@

$(MAIN_OUT_HEX): $(MAIN_OUT_ELF)
	$(OBJCP) $(OBJCPFLAGSH) $< $@


# Display size of file.
#BINNARYSIZE = $(SIZE) --target=$(FORMAT) $(OUT_DIR)$(MAIN_OUT).bin
ELFSIZE = $(SIZE) -A $(OUT_DIR)$(MAIN_OUT).elf

sizebefore:
	@if [ -f $(OUT_DIR)$(MAIN_OUT).elf ]; then echo; echo $(MSG_SIZE_BEFORE); $(ELFSIZE); echo; fi

sizeafter:
	@if [ -f $(OUT_DIR)$(MAIN_OUT).elf ]; then echo; echo $(MSG_SIZE_AFTER); $(ELFSIZE); echo; fi
	@echo $(ODZIELENIE_DIALOGOW);

# flash

flash: $(MAIN_OUT)
	@cp $(MAIN_OUT_ELF) jtag/flash
	@cd jtag; openocd -f flash.cfg
	@rm jtag/flash

clean:
#-rm *.o lib/src/*.o $(LIBSTM32_OUT) $(MAIN_OUT_ELF) $(MAIN_OUT_BIN)
#-rm $(LIBRARY)*.o $(LIBSTM32_OUT) $(MAIN_OUT_ELF) $(MAIN_OUT_BIN)
	-rm $(LIBRARY) $(MAIN_OUT_ELF) $(MAIN_OUT_HEX)
