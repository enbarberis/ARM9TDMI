#!/bin/sh
hexdump -ve '1/1 "%.2x" "\n"' instruction_memory_file.hex | grep -v "\*" > instruction_memory_file.asciihex
hexdump -ve '1/1 "%.2x" "\n"' data_memory_file.hex | grep -v "\*" > data_memory_file.asciihex
