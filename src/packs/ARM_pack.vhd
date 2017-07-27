library IEEE;
use IEEE.std_logic_1164.all;

library WORK;

package ARM_pack is

  --  CONSTANTS
  constant  REG_ADDR_w    : integer :=  4;
  constant  ADDR_BUS_w    : integer :=  32;
  constant  DATA_BUS_w    : integer :=  32;
  constant  DATA_BUSx2_w  : integer :=  DATA_BUS_w * 2;
  constant  DATA_BUSx4_w  : integer :=  DATA_BUS_w * 4;
  constant  SHIFT_BUS_w   : integer :=  6;
  constant  SHIFT_OP_w    : integer :=  2;

  constant  ARM_INSTR_w   : integer :=  32;
  constant  TMB_INSTR_w   : integer :=  16;

  constant  OPCODE_w      : integer :=  ARM_INSTR_w + 4;

  constant  ARM_ROM_len   : integer :=  2**12;
  constant  TMB_ROM_len   : integer :=  2**TMB_INSTR_w;

  constant  CTRL_WORD_w   : integer :=  7; -- TO BE MODIFIED

  constant  CPSR_MODE_w   : integer :=  5;
  constant  CPSR_FLAG_w   : integer :=  4;

  constant  CPSR_FLAG_N   : natural :=  31;
  constant  CPSR_FLAG_Z   : natural :=  30;
  constant  CPSR_FLAG_C   : natural :=  29;
  constant  CPSR_FLAG_V   : natural :=  28;
  constant  CPSR_FLAG_I   : natural :=   7;
  constant  CPSR_FLAG_F   : natural :=   6;
  constant  CPSR_FLAG_TMB : natural :=   5;

  constant  DATA_PROC_OP_w: natural :=   4;

  --  RANGE SUBTYPES
  subtype   REG_ADDR_r     is integer range  (REG_ADDR_w   - 1)  downto 0;
  subtype   ADDR_BUS_r     is integer range  (ADDR_BUS_w   - 1)  downto 0;
  subtype   DATA_BUS_r     is integer range  (DATA_BUS_w   - 1)  downto 0;
  subtype   DATA_BUSx2_r   is integer range  (DATA_BUSx2_w - 1)  downto 0;
  subtype   DATA_BUSx4_r   is integer range  (DATA_BUSx4_w - 1)  downto 0;
  subtype   SHIFT_BUS_r    is integer range  (SHIFT_BUS_w  - 1)  downto 0;
  subtype   SHIFT_OP_r     is integer range  (SHIFT_OP_w   - 1)  downto 0;

  subtype   ARM_INSTR_r    is integer range  (ARM_INSTR_w  - 1)  downto 0;
  subtype   TMB_INSTR_r    is integer range  (TMB_INSTR_w  - 1)  downto 0;
  subtype   OPCODE_r       is integer range  (OPCODE_w     - 1)  downto 0;
  subtype   CTRL_WORD_r    is integer range  (CTRL_WORD_w  - 1)  downto 0;
  subtype   CPSR_MODE_r    is integer range  (CPSR_MODE_w  - 1)  downto 0;
  subtype   CPSR_FLAG_r    is integer range  (DATA_BUS_w   - 1)  downto (DATA_BUS_w - CPSR_FLAG_w + 1);
  subtype   DATA_PROC_OP_r is integer range  (DATA_PROC_OP_w - 1) downto 0;

  subtype   ARM_ROM_r      is integer range  0 to (ARM_ROM_len - 1);
  subtype   TMB_ROM_r      is integer range  0 to (TMB_ROM_len - 1);

  --  BUS SUBTYPES
  subtype   REG_ADDR_t     is std_logic_vector (REG_ADDR_r);
  subtype   ADDR_BUS_t     is std_logic_vector (ADDR_BUS_r);
  subtype   DATA_BUS_t     is std_logic_vector (DATA_BUS_r);
  subtype   DATA_BUSx2_t   is std_logic_vector (DATA_BUSx2_r);
  subtype   DATA_BUSx4_t   is std_logic_vector (DATA_BUSx4_r);
  subtype   SHIFT_BUS_t    is std_logic_vector (SHIFT_BUS_r);
  subtype   SHIFT_OP_t     is std_logic_vector (SHIFT_OP_r);

  subtype   ARM_INSTR_t    is std_logic_vector (ARM_INSTR_r);
  subtype   TMB_INSTR_t    is std_logic_vector (TMB_INSTR_r);
  subtype   OPCODE_t       is std_logic_vector (OPCODE_r);
  subtype   CPSR_MODE_t    is std_logic_vector (CPSR_MODE_r);
  subtype   CPSR_FLAG_t    is std_logic_vector (CPSR_FLAG_r);

  subtype   DATA_PROC_OP_t is std_logic_vector (DATA_PROC_OP_r);

  --  EXECUTE BUS SELECTION TYPES
  type      A_BUS_SEL_t   is (Rn_SEL     ,
                              PSR_SEL    ,
                              EXE_FWD_SEL,
                              MEM_FWD_SEL,
                              MRD_FWD_SEL);
  type      B_BUS_SEL_t   is (Rm_SEL     ,
                              Imm_SEL    ,
                              EXE_FWD_SEL,
                              MEM_FWD_SEL,
                              MRD_FWD_SEL);
  type      C_BUS_SEL_t   is (Rd_SEL     ,
                              EXE_FWD_SEL,
                              MEM_FWD_SEL,
                              MRD_FWD_SEL);


  --  ROM TYPES
  type      ARM_ROM_ID_t  is array (ARM_ROM_r)  of std_logic_vector (CTRL_WORD_r);
  type      TMB_ROM_ID_t  is array (TMB_ROM_r)  of ARM_INSTR_t;

  --  REGISTER TYPES
  type      STD_REGS_t    is array ( 0 to 15)   of DATA_BUS_t;
  type      FIQ_REGS_t    is array ( 8 to 14)   of DATA_BUS_t;
  type      IRQ_REGS_t    is array (13 to 14)   of DATA_BUS_t;
  type      SVC_REGS_t    is array (13 to 14)   of DATA_BUS_t;
  type      ABT_REGS_t    is array (13 to 14)   of DATA_BUS_t;
  type      UND_REGS_t    is array (13 to 14)   of DATA_BUS_t;

  ----------------------------------------------------------------------------
  --  PROCESSOR MODES - CPSR[4:0]                                           --
  ----------------------------------------------------------------------------
  constant  USR           : CPSR_MODE_t :=  "10000";                             -- User Mode
  constant  SYS           : CPSR_MODE_t :=  "11111";                             -- System Mode                       [Priviledged]
  constant  FIQ           : CPSR_MODE_t :=  "10001";                             -- Fast Interrupt Request Mode       [Priviledged]
  constant  IRQ           : CPSR_MODE_t :=  "10010";                             -- Interrupt Request Mode            [Priviledged, Exception]
  constant  SVC           : CPSR_MODE_t :=  "10011";                             -- Supervisor Mode                   [Priviledged, Exception]
  constant  ABT           : CPSR_MODE_t :=  "10111";                             -- Abort Instruction/Data Fetch Mode [Priviledged, Exception]
  constant  UND           : CPSR_MODE_t :=  "11011";                             -- Undefined Instruction Mode        [Priviledged, Exception]

  ----------------------------------------------------------------------------
  --  REGISTER ADDRESSES                                                    --
  ----------------------------------------------------------------------------
  constant  R0            : REG_ADDR_t  :=  "0000";
  constant  R1            : REG_ADDR_t  :=  "0001";
  constant  R2            : REG_ADDR_t  :=  "0010";
  constant  R3            : REG_ADDR_t  :=  "0011";
  constant  R4            : REG_ADDR_t  :=  "0100";
  constant  R5            : REG_ADDR_t  :=  "0101";
  constant  R6            : REG_ADDR_t  :=  "0110";
  constant  R7            : REG_ADDR_t  :=  "0111";
  constant  R8            : REG_ADDR_t  :=  "1000";
  constant  R9            : REG_ADDR_t  :=  "1001";
  constant  R10           : REG_ADDR_t  :=  "1010";
  constant  R11           : REG_ADDR_t  :=  "1011";
  constant  R12           : REG_ADDR_t  :=  "1100";
  constant  R13           : REG_ADDR_t  :=  "1101";
  constant  R14           : REG_ADDR_t  :=  "1110";
  constant  R15           : REG_ADDR_t  :=  "1111";

  constant  SP            : REG_ADDR_t  :=  R13;
  constant  LR            : REG_ADDR_t  :=  R14;
  constant  PC            : REG_ADDR_t  :=  R15;

  ----------------------------------------------------------------------------
  --  SHIFT OPERATIONS                                                      --
  ----------------------------------------------------------------------------

  constant  SLL_OP        : SHIFT_OP_t  :=  "00";                                --  Shift Logic Left
  constant  SLR_OP        : SHIFT_OP_t  :=  "01";                                --  Shift Logic Right
  constant  SAR_OP        : SHIFT_OP_t  :=  "10";                                --  Shift Arithmetic Right
  constant  ROR_OP        : SHIFT_OP_t  :=  "11";                                --  Rotate Right

  ----------------------------------------------------------------------------
  --  CONDITIONAL CODES                                                     --
  ----------------------------------------------------------------------------

  constant  EQ            : DATA_PROC_OP_t := "0000";
  constant  NE            : DATA_PROC_OP_t := "0001";
  constant  CS_HS         : DATA_PROC_OP_t := "0010";
  constant  CC_LO         : DATA_PROC_OP_t := "0011";
  constant  MI            : DATA_PROC_OP_t := "0100";
  constant  PL            : DATA_PROC_OP_t := "0101";
  constant  VS            : DATA_PROC_OP_t := "0110";
  constant  VC            : DATA_PROC_OP_t := "0111";
  constant  HI            : DATA_PROC_OP_t := "1000";
  constant  LS            : DATA_PROC_OP_t := "1001";
  constant  GE            : DATA_PROC_OP_t := "1010";
  constant  LT            : DATA_PROC_OP_t := "1011";
  constant  GT            : DATA_PROC_OP_t := "1100";
  constant  LE            : DATA_PROC_OP_t := "1101";
  constant  AL            : DATA_PROC_OP_t := "1110";

  ----------------------------------------
  -- FORWARDING MUX SELECTOR CONSTANTS  --
  ----------------------------------------
  constant  B_DATA_MEM_OUT    : std_logic_vector(2 downto 0)  := "000";
  constant  B_REG_FILE        : std_logic_vector(2 downto 0)  := "001";
  constant  B_IMMEDIATE       : std_logic_vector(2 downto 0)  := "010";
  constant  B_ALU_OUT         : std_logic_vector(2 downto 0)  := "011";
  constant  B_ALU_OUT_SKEWED  : std_logic_vector(2 downto 0)  := "100";


  constant  A_REG_FILE        : std_logic_vector(2 downto 0)  := "000";
  constant  A_DATA_MEM_OUT    : std_logic_vector(2 downto 0)  := "010";
  constant  A_CPSR            : std_logic_vector(2 downto 0)  := "011";
  constant  A_SPSR            : std_logic_vector(2 downto 0)  := "100";
  constant  A_ALU_OUT         : std_logic_vector(2 downto 0)  := "101";
  constant  A_ALU_OUT_SKEWED  : std_logic_vector(2 downto 0)  := "110";
------------------------------------------------------------------------


end package ARM_pack;
