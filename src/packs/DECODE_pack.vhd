library IEEE;
use IEEE.std_logic_1164.all;

library WORK;

package DECODE_pack is

  --  CONSTANTS
  constant  REG_ADDR_w    : integer :=  4;
  constant  ALU_OPCODE_DIM    : integer :=  4;
  constant  ALU_OPCODE_SRT    : integer := 21;
  constant  ALU_OPCODE_END    : integer := 24;
  constant  S                 : integer := 20;
  constant  L                 : integer := 20;
  constant  P                 : integer := 24;
  constant  U                 : integer := 23;
  constant  B                 : integer := 22;
  constant  W                 : integer := 21;
  constant  IMMED_8_END       : integer :=  7;
  
  constant  IMMED_8_SRT       : integer :=  0;
  constant  ROT_IMM_END       : integer := 11;
  constant  ROT_IMM_SRT       : integer :=  8;
  constant  SHIFT_IMM_END     : integer := 11;
  constant  SHIFT_IMM_SRT     : integer :=  7;
  constant  SHIFT_OPCODE_SRT  : integer :=  5;
  constant  SHIFT_OPCODE_END  : integer :=  6;
  constant  OFFSET_12_SRT     : integer :=  0;
  constant  OFFSET_12_END     : integer := 11;
  constant  SH_END            : integer :=  6;
  constant  SH_SRT            : integer :=  5;
  constant  OFFSET_L_SRT     : integer :=  0;
  constant  OFFSET_H_SRT     : integer :=  8;
  constant  OFFSET_L_END     : integer :=  3;
  constant  OFFSET_H_END     : integer :=  11;


  constant  ALU_OUT               : std_logic_vector(1 downto 0)  :=  "00";
  constant  A_BYPASS              : std_logic_vector(1 downto 0)  :=  "01";
  constant  NXT_CPSR_SPSR_SEL     : std_logic_vector(1 downto 0)  :=  "00";

  constant  IMMEDIATE_SHIFT       : std_logic                     :=  '0' ;
  constant  PC_SEQ                : std_logic_vector(1 downto 0)  :=  "00";
  constant  IA_FROM_EXCEPTION     : std_logic_vector(1 downto 0)  :=  "01"; 
  constant  IA_FROM_ALU           : std_logic_vector(1 downto 0)  :=  "10";
  constant  IA_FROM_MEM           : std_logic_vector(1 downto 0)  :=  "11";

  constant  UNSIGNED_ACCESS       : std_logic                     :=  '0' ;
  constant  SIGNED_ACCESS         : std_logic                     :=  '1' ;
  constant  BYTE                  : std_logic_vector(1 downto 0)  :=  "01";
  constant  HALF_WORD             : std_logic_vector(1 downto 0)  :=  "00";
  constant  WORD                  : std_logic_vector(1 downto 0)  :=  "10";

  constant  NORMAL_RC             : std_logic                     :=  '0' ;
  constant  DELAYED_RC            : std_logic                     :=  '1' ;

  constant  ALU_ADD               : std_logic_vector(3 downto 0)  :=  "0100";
  constant  ALU_SUB               : std_logic_vector(3 downto 0)  :=  "0010";

  constant  DT                    : std_logic                     :=  '0';

  constant  FLAG_FROM_EXE         : std_logic_vector(1 downto 0)  :=  "00"; 
  constant  FLAG_FROM_SPSR        : std_logic_vector(1 downto 0)  :=  "01";
  constant  FLAG_FROM_ALU_OUT     : std_logic_vector(1 downto 0)  :=  "10";


  constant  Rn_SRT     : integer := 16;
  constant  Rn_END     : integer := 19;
  constant  Rm_SRT     : integer :=  0;
  constant  Rm_END     : integer :=  3;
  constant  Rd_SRT     : integer := 12;
  constant  Rd_END     : integer := 15;
  constant  Rs_SRT     : integer :=  8;
  constant  Rs_END     : integer := 11;
  constant  CC_SRT     : integer := 28;
  constant  CC_END     : integer := 31;

  constant  SHIFT_AMNT_FROM_REG   : std_logic                      := '0';
  constant  SHIFT_AMNT_FROM_IMM   : std_logic                      := '1';



end package DECODE_pack;
