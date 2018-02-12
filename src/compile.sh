vcom -check_synthesis  packs/ARM_pack.vhd
vcom -check_synthesis  packs/MATH_FUNCTION_pack.vhd
vcom -check_synthesis  packs/SHIFT_FUNCTION_pack.vhd
vcom -check_synthesis  packs/DECODE_pack.vhd
vcom -check_synthesis  packs/CU_pack.vhd


vcom -check_synthesis  generic/D_FF.vhd
vcom -check_synthesis  generic/DFF.vhd
vcom -check_synthesis  generic/MUX21_GEN.vhd
vcom -check_synthesis  generic/MUX41_GEN.vhd

vcom -check_synthesis  generic/LOAD_REG_NEGEDGE_GEN.vhd
vcom -check_synthesis  generic/REG_NEGEDGE_GEN_ACTIVE.vhd
vcom -check_synthesis  generic/REG_NEGEDGE_GEN.vhd



vcom -check_synthesis  fetch/NEXT_CPSR.vhd
vcom -check_synthesis  fetch/FETCH.vhd


vcom -check_synthesis  execute/HIGHSPEED_MULT/SIGN_EXTENTION_GEN.vhd
vcom -check_synthesis  execute/HIGHSPEED_MULT/INVERTER_GEN.vhd
vcom -check_synthesis  execute/HIGHSPEED_MULT/CSA_GEN.vhd
vcom -check_synthesis  execute/HIGHSPEED_MULT/MULT_DECODER.vhd
vcom -check_synthesis  execute/HIGHSPEED_MULT/Rmx3_GENERATOR.vhd
vcom -check_synthesis  execute/HIGHSPEED_MULT/LSR8_REG32.vhd
vcom -check_synthesis  execute/HIGHSPEED_MULT/HIGHSPEED_MULT.vhd


vcom -check_synthesis  execute/ALU/adder/sum_generator/iv.vhd
vcom -check_synthesis  execute/ALU/adder/sum_generator/nd2.vhd
vcom -check_synthesis  execute/ALU/adder/sum_generator/fa.vhd
vcom -check_synthesis  execute/ALU/adder/sum_generator/mux21_generic.vhd

vcom -check_synthesis  execute/ALU/adder/carry_generator/my_math_function.vhd
vcom -check_synthesis  execute/ALU/adder/carry_generator/pg.vhd
vcom -check_synthesis  execute/ALU/adder/carry_generator/general_pg.vhd
vcom -check_synthesis  execute/ALU/adder/carry_generator/general_g.vhd

vcom -check_synthesis  execute/ALU/adder/sum_generator/rca_generic.vhd

vcom -check_synthesis  execute/ALU/adder/carry_generator/carry_generator.vhd
vcom -check_synthesis  execute/ALU/adder/sum_generator/carry_select_reduced.vhd
vcom -check_synthesis  execute/ALU/adder/sum_generator/carry_select.vhd
vcom -check_synthesis  execute/ALU/adder/sum_generator/sum_generator.vhd


vcom -check_synthesis  execute/ALU/adder/P4ADDER.vhd

vcom -check_synthesis  execute/ALU/LOGIC_UNIT.vhd

vcom -check_synthesis  execute/ALU/ALU.vhd

vcom -check_synthesis  execute/TO_BE_EXE.vhd
vcom -check_synthesis  execute/BARREL_SHIFTER.vhd

vcom -check_synthesis  execute/EXECUTE.vhd


vcom -check_synthesis  decode/count_one.vhd
vcom -check_synthesis  decode/CU_FSM.vhd
vcom -check_synthesis  decode/decode_table.vhd
vcom -check_synthesis  decode/priority_encoder.vhd
vcom -check_synthesis  decode/address_encoder.vhd
vcom -check_synthesis  decode/UPDATE_FLAG.vhd
vcom -check_synthesis  decode/NZCV_SEL.vhd
vcom -check_synthesis  decode/REGBANK_3R2W.vhd
vcom -check_synthesis  decode/FORWARDING_UNIT.vhd
vcom -check_synthesis  decode/DEC_OUT_STAGE.vhd
vcom -check_synthesis  decode/control_unit.vhd


vcom -check_synthesis  memory/BYTE_ROT_SIGN_EXT.vhd
vcom -check_synthesis  memory/BYTE_WORD_REPLICATION.vhd
vcom -check_synthesis  memory/DATA_MEMORY_SIGNAL_GENERATION.vhd
vcom -check_synthesis  memory/DATA_MEMORY.vhd
vcom -check_synthesis  memory/INSTRUCTION_MEMORY.vhd


vcom -check_synthesis  ARM9TDMI.vhd

vcom -check_synthesis  testbench/ARM9TDMI_TB.vhd
vcom -check_synthesis  testbench/DATA_MEMORY_TESTBENCH.vhd
vcom -check_synthesis  testbench/INSTRUCTION_MEMORY_TESTBENCH.vhd


