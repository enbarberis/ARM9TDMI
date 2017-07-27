#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 with bin file to copy at the beginning"
  exit -1
fi

dd if=/dev/zero of=flash.bin bs=4096 count=4096
dd if=$1 of=flash.bin bs=4096 conv=notrunc
