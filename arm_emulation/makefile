TARGET_ARCHITECTURE=arm9
LINKER_SCRIPT=linker_emulation.ld

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

mem_init.o: src/mem_init.S
	${AS} ${ASFLAGS} obj/mem_init.o src/mem_init.S

entry.o: src/entry.S
	${AS} ${ASFLAGS} obj/entry.o src/entry.S

fibo.o: src/fibo.S
	${AS} ${ASFLAGS} obj/fibo.o src/fibo.S

forwarding.o: src/forwarding.S
	${AS} ${ASFLAGS} obj/forwarding.o src/forwarding.S

sort.o: src/sort.S
	${AS} ${ASFLAGS} obj/sort.o src/sort.S
			 
startup.o: src/startup.S
	${AS} ${ASFLAGS} obj/startup.o src/startup.S
			 
sum_vector.o: src/sum_vector.S
	${AS} ${ASFLAGS} obj/sum_vector.o src/sum_vector.S

link: mem_init.o entry.o fibo.o forwarding.o sort.o startup.o sum_vector.o 
	${LD} ${LDFLAGS} bin/exec.elf obj/*.o

install: link
	${OBJCOPY} ${OBJCOPYFLAGS} binary bin/exec.elf bin/exec.bin
	./create_flash.sh ./bin/exec.bin	
debug: 
	qemu-system-arm -echr 0x14 -M connex -m 128M -nographic -pflash flash.bin -s -S
			 
gdb: exec
	${GDB} exec
			
clean:
	rm -rf bin/*
	rm -rf obj/*
