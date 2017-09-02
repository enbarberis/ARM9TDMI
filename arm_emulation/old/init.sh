#!/bin/bash

if [ ! -d "obj" ]; then 
  mkdir obj
fi 

if [ ! -d "bin" ]; then 
  mkdir bin
fi 

arm-none-eabi-as -mcpu=arm9 -g src/simple_startup.s -o simple_startup.o
arm-none-eabi-as -mcpu=arm9 -g src/sum_2.s -o sum_2.o
arm-none-eabi-gcc -c -mcpu=arm9 -g src/simple_init.c -o simple_init.o
arm-none-eabi-ld -T linker.ld simple_init.o sum_2.o simple_startup.o -o bin/output.elf
arm-none-eabi-objcopy -O binary bin/output.elf bin/output.bin
