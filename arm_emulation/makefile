TARGET_ARCHITECTURE=arm9
LINKER_SCRIPT=linker.ld

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

fibo.o: src/fibo.S
	${AS} ${ASFLAGS} obj/fibo.o src/fibo.S

sort.o: src/sort.S
	${AS} ${ASFLAGS} obj/sort.o src/sort.S
			 
startup.o: src/startup.S
	${AS} ${ASFLAGS} obj/startup.o src/startup.S
			 
forwarding.o: src/forwarding.S
	${AS} ${ASFLAGS} obj/forwarding.o src/forwarding.S

data_transfer.o: src/data_transfer.S
	${AS} ${ASFLAGS} obj/data_transfer.o src/data_transfer.S

link: fibo.o sort.o startup.o data_transfer.o forwarding.o 
	${LD} ${LDFLAGS} bin/exec.elf obj/fibo.o obj/sort.o obj/startup.o obj/forwarding.o obj/data_transfer.o 

install: link
	${OBJCOPY} ${OBJCOPYFLAGS} binary bin/exec.elf bin/exec.bin
	
debug: exec
	qemu-system-arm -M versatilepb -m 128M -nographic -serial /dev/null -kernel exec -s -S
			 
gdb: exec
	${GDB} exec
			
clean:
	rm -rf bin/*
	rm -rf obj/*
