TARGET_ARCHITECTURE=arm9
LINKER_SCRIPT=linker_rtl_simulation.ld

AS=arm-none-eabi-as
ASFLAGS= -mcpu=${TARGET_ARCHITECTURE} -g -o
CC=arm-none-eabi-gcc
CCFLAGS= -g -mcpu=${TARGET_ARCHITECTURE} -c -o 
LD=arm-none-eabi-ld
LDFLAGS= -T ${LINKER_SCRIPT} -o
OBJCOPY= arm-none-eabi-objcopy 
OBJCOPYFLAGS= -O
GDB=arm-elf-gdb

all:link
 
main.o: src/main.S
	${AS} ${ASFLAGS} obj/main.o src/main.S

forwarding.o: src/forwarding.S
	${AS} ${ASFLAGS} obj/forwarding.o src/forwarding.S

link: main.o forwarding.o
	${LD} ${LDFLAGS} bin/main.elf obj/main.o obj/forwarding.o

install: link
	${OBJCOPY} ${OBJCOPYFLAGS} binary bin/main.elf bin/main.bin
	./create_flash.sh ./bin/main.bin	
debug: 
	qemu-system-arm -echr 0x14 -M connex -m 128M -nographic -pflash flash.bin -s -S
			 
gdb: exec
	${GDB} exec
			
clean:
	rm -rf bin/*
	rm -rf obj/*
