# ARM9TDMI
## Introduction
This project was created with the goal to obtain a “softcore” processor based on the ARM9TDMI architecture.
The work was created as a final project for the course “Microelectronic System” taught at Politecnico di Torino by professor Graziano.
The project was developed by:
* Barberis Enrico
* Canessa Emanuele
* Cipolletta Antonio
* Circa Alessandro
## What was done
### Architecture
A first step of reverse engineering to extract inner details of the architecture was done by reading documentation provided by ARM. All the obtained informations are reported in these documents to help future readers:
* `doc/datapath.eps` : an high level datapath view of the processor. This diagram helps to visualize the main blocks that compose the processor.
![ARM9TDMI datapath](https://github.com/enbarberis/ARM9TDMI/raw/master/doc/datapath.jpg)
* `doc/ARM9TDMI_notes.pdf` : a document that explain for each instruction encoding, timing and implementation details. This document contains all the information obtained during the architecture definition of the processor.
* `doc/references/` : collection of useful references found on the web. Also the book "ARM System-on-Chip Architecture" by Steve Furber was used.

All the architectural decisions were taken by looking at the cycle count of each instruction reported in the manual in order to obtain a processor with the same timing capabilities of the ARM9TDMI.
### Implementation
After the definition of the architecture a VHDL description of the processor was performed. All the sources are available in the folder `src/`. All the files are contained in the following sub folders:
* `generic` : contains essential components like registers, flip flop and multiplexers.
* `packs` : contains type and constant definition used in other sources. It also contains the functions used by the shifter.
* `fetch` : contains the blocks that implements the fetch stage of the processor.
* `decode` : contains the register file and all the control unit of the processor
* `execute` : contains all the datapath blocks that performs the processor arithmetic or logical operations.
* `memory` : contains simple memory models description for the instruction and data memory. Notice that are used only for simulation purposes. The `utils` folder contains some images and script to convert binary files in text file that can be read by a VHDL simulator.
* `testbench` contains some testbench of sub components and the processor itself.
### Testing
A simple testbench of the processor is available in the folder `src/testbench`. In order to feed easily instruction to the processor a makefile was created to generate a binary file starting from .c or .S sources.


## What’s left to do
