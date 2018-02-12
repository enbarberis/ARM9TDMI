vcom packs/ARM_pack.vhd
vcom packs/MATH_FUNCTION_pack.vhd
vcom packs/SHIFT_FUNCTION_pack.vhd
vcom packs/DECODE_pack.vhd
vcom packs/CU_pack.vhd


vcom generic/D_FF.vhd
vcom generic/DFF.vhd
vcom generic/MUX21_GEN.vhd
vcom generic/MUX41_GEN.vhd

vcom generic/LOAD_REG_NEGEDGE_GEN.vhd
vcom generic/REG_NEGEDGE_GEN_ACTIVE.vhd
vcom generic/REG_NEGEDGE_GEN.vhd



vcom fetch/NEXT_CPSR.vhd
vcom fetch/FETCH.vhd


vcom execute/HIGHSPEED_MULT/SIGN_EXTENTION_GEN.vhd
vcom execute/HIGHSPEED_MULT/INVERTER_GEN.vhd
vcom execute/HIGHSPEED_MULT/CSA_GEN.vhd
vcom execute/HIGHSPEED_MULT/MULT_DECODER.vhd
vcom execute/HIGHSPEED_MULT/Rmx3_GENERATOR.vhd
vcom execute/HIGHSPEED_MULT/LSR8_REG32.vhd
vcom execute/HIGHSPEED_MULT/HIGHSPEED_MULT.vhd


vcom execute/ALU/adder/sum_generator/iv.vhd
vcom execute/ALU/adder/sum_generator/nd2.vhd
vcom execute/ALU/adder/sum_generator/fa.vhd
vcom execute/ALU/adder/sum_generator/mux21_generic.vhd

vcom execute/ALU/adder/carry_generator/my_math_function.vhd
vcom execute/ALU/adder/carry_generator/pg.vhd
vcom execute/ALU/adder/carry_generator/general_pg.vhd
vcom execute/ALU/adder/carry_generator/general_g.vhd

vcom execute/ALU/adder/sum_generator/rca_generic.vhd

vcom execute/ALU/adder/carry_generator/carry_generator.vhd
vcom execute/ALU/adder/sum_generator/carry_select_reduced.vhd
vcom execute/ALU/adder/sum_generator/carry_select.vhd
vcom execute/ALU/adder/sum_generator/sum_generator.vhd


vcom execute/ALU/adder/P4ADDER.vhd

vcom execute/ALU/LOGIC_UNIT.vhd

vcom execute/ALU/ALU.vhd

vcom execute/TO_BE_EXE.vhd
vcom execute/BARREL_SHIFTER.vhd

vcom execute/EXECUTE.vhd


vcom decode/count_one.vhd
vcom decode/CU_FSM.vhd
vcom decode/decode_table.vhd
vcom decode/priority_encoder.vhd
vcom decode/address_encoder.vhd
vcom decode/UPDATE_FLAG.vhd
vcom decode/NZCV_SEL.vhd
vcom decode/REGBANK_3R2W.vhd
vcom decode/FORWARDING_UNIT.vhd
vcom decode/DEC_OUT_STAGE.vhd
vcom decode/control_unit.vhd


vcom memory/BYTE_ROT_SIGN_EXT.vhd
vcom memory/BYTE_WORD_REPLICATION.vhd
vcom memory/DATA_MEMORY_SIGNAL_GENERATION.vhd
vcom memory/DATA_MEMORY.vhd
vcom memory/INSTRUCTION_MEMORY.vhd


vcom ARM9TDMI.vhd

vlog testbench/fetch_disassembly.sv
vcom testbench/ARM9TDMI_TB.vhd
vcom testbench/DATA_MEMORY_TESTBENCH.vhd
vcom testbench/INSTRUCTION_MEMORY_TESTBENCH.vhd


