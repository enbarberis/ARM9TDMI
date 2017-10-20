#!/bin/bash

cp ./bin/main.bin ../src/memory/util/
cd ../src/memory/util
cp main.bin instruction_memory_file.hex
cp main.bin data_memory_file.hex
./hex_to_ascii_hex.sh
cp instruction_memory_file.asciihex ../
cp data_memory_file.asciihex ../
