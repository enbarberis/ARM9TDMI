library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

library WORK;
use WORK.ARM_pack.all;

--------------------------------------------------------------------------------

entity EXECUTE is
  port (
    CLK                         : in  std_logic;
    nRST                        : in  std_logic;

    --ALU
    A                           : in  DATA_BUS_t;
    B                           : in  DATA_BUS_t;
    ALU_OPCODE                  : in  std_logic_vector(3 downto 0);
    COND_CODE                   : in  DATA_PROC_OP_t;
    MDATA_SRC_ADDR              : in  std_logic_vector(1 downto 0);
    N_in                        : in  std_logic;
    C_in                        : in  std_logic;
    Z_in                        : in  std_logic;
    V_in                        : in  std_logic;
    A_PASS                      : in  std_logic;
    B_PASS                      : in  std_logic;
    OP_A_MUX_SEL                : in  std_logic;
    OP_B_MUX_SEL                : in  std_logic;

    --MUL
    EN_MULT                     : in  std_logic;
    SIGNED_NUNSIGNED_MULT       : in  std_logic;
    HILO_REG_SRC_MULT           : in  std_logic;
    WR_RM_MULT                  : in  std_logic;
    WR_RS_MULT                  : in  std_logic;
    WR_SUM_MULT                 : in  std_logic;
    NRST_SUM_MULT               : in  std_logic;
    NRST_CARRY_MULT             : in  std_logic;

    --SHIFT
    SHIFT_AMOUNT                : in  SHIFT_BUS_t;                  --Immediate shift amount (not from register)
    SHIFT_OPCODE                : in  std_logic_vector(1 downto 0);
    SHIFT_SRC_AMOUNT            : in  std_logic;
    SHIFT_IMM                   : in  std_logic;

    --OUTPUT
    MDATA_ADDR                  : out DATA_BUS_t;
    ALU_OUTPUT                  : out DATA_BUS_t;
    TO_BE_EXECUTED              : out std_logic;
    N_out                       : out std_logic;
    C_out                       : out std_logic;
    Z_out                       : out std_logic;
    V_out                       : out std_logic;
    EARLY_FINISH                : out std_logic

  );
end entity EXECUTE;

--------------------------------------------------------------------------------

architecture BHV of EXECUTE is

  component REG_NEGEDGE_GEN is
    generic (N : natural := 32);
    port (
      CLK   : in  std_logic;
      nRST  : in  std_logic;
      EN    : in  std_logic;
      D     : in  std_logic_vector (N-1 downto 0);
      Q     : out std_logic_vector (N-1 downto 0)
    );
  end component REG_NEGEDGE_GEN;

  component TO_BE_EXE is
    port (
      OPCODE      : in DATA_PROC_OP_t;
      N,C,Z,V     : in std_logic;
      TO_BE_EXE   : out std_logic
    );
  end component TO_BE_EXE;

  component BARREL_SHIFTER is
    port (
      B_BUS_in    : in  DATA_BUS_t;
      B_BUS_out   : out DATA_BUS_t;
      C_FLAG_in   : in  std_logic;
      C_FLAG_out  : out std_logic;
      SH_AMOUNT   : in  SHIFT_BUS_t;
      SHIFT_OP    : in  SHIFT_OP_t;
      IMMEDIATE   : in  std_logic
    );
  end component;

  component ALU is
    port (
      -- DATA BUS
      A_DATA_in   : in  DATA_BUS_t;
      B_DATA_in   : in  DATA_BUS_t;
      R_DATA_out  : out DATA_BUS_t;

      -- COMMAND SIGNALS
      OPCODE      : in  std_logic_vector(3 downto 0);                             -- ARM data processing instruction opcode
      A_PASS      : in  std_logic;
      B_PASS      : in  std_logic;

      -- FLAG I/O
      C_FLAG_in   : in  std_logic;                                                --  Carry    Flag Input
      C_FLAG_out  : out std_logic;                                                --  Carry    Flag Output
      V_FLAG_out  : out std_logic;                                                --  Overflow Flag Output
      N_FLAG_out  : out std_logic;                                                --  Negative Flag Output
      Z_FLAG_out  : out std_logic;                                                --  Zero     Flag Output
      L_nA        : out std_logic
    );
  end component ALU;

  component HIGHSPEED_MULT is
    port (
      --  CLOCK, RESET, ENABLE SIGNALS
      nRST                : in  std_logic;
      CLK                 : in  std_logic;
      MULT_EN             : in  std_logic;

      --  CONTROL SIGNALS
      SIGNED_nUNSIGNED    : in  std_logic;
      CYCLE_COUNT         : in  std_logic_vector (1 downto 0);
      EARLY_FINISH        : out std_logic;
      HiLo_REG_SEL        : in  std_logic;

      --  INTERNAL REGISTERS
      W_EN_Rm             : in  std_logic;
      W_EN_Rs             : in  std_logic;
      W_EN_SUM            : in  std_logic;

      nRST_SUM            : in  std_logic;
      nRST_CARRY          : in  std_logic;

      --  INPUT DATA BUSSES
      W_DATA_1            : in  DATA_BUS_t;
      W_DATA_2            : in  DATA_BUS_t;

      --  OUTPUT DATA BUSSES
      R_DATA_SUM          : out DATA_BUS_t;
      R_DATA_CARRY        : out DATA_BUS_t
    );
  end component HIGHSPEED_MULT;

  signal A_s            : DATA_BUS_t;
  signal B_s            : DATA_BUS_t;
  signal ALU_OUTPUT_s   : DATA_BUS_t;
  signal R_DATA_SUM_s   : DATA_BUS_t;
  signal R_DATA_CARRY_s : DATA_BUS_t;
  signal SHIFT_OUT_s    : DATA_BUS_t;

  signal C_out_ALU, C_out_SHIFT: std_logic;

  signal SHIFT_AMOUNT_REG_Q, SHIFT_AMOUNT_s: std_logic_vector(5 downto 0);

  signal L_nA_s : std_logic;

  signal MDATA_ADDR_Q, MDATA_ADDR_D: DATA_BUS_t;

  signal nRST_SUM_MULT_s    : std_logic;
  signal nRST_CARRY_MULT_s  : std_logic;


begin

  --------------------
  -- TO BE EXECUTED --
  --------------------
  TO_BE_EXE_i: TO_BE_EXE
    port    map ( OPCODE    =>  COND_CODE,
                  N         =>  N_in,
                  C         =>  C_in,
                  Z         =>  Z_in,
                  V         =>  V_in,
                  TO_BE_EXE =>  TO_BE_EXECUTED
                );

  ---------
  -- ALU --
  ---------
  A_s <=    A             when  OP_A_MUX_SEL = '0' else
            R_DATA_SUM_s;

  B_s <=    SHIFT_OUT_S   when  OP_B_MUX_SEL = '0' else
            R_DATA_CARRY_s;

  C_out <=  C_out_ALU     when  L_nA_s = '0' else
            C_out_SHIFT;

  ALU_i:  ALU
    port    map ( A_DATA_in     =>  A_s,
                  B_DATA_in     =>  B_s,
                  R_DATA_OUT    =>  ALU_OUTPUT_s,
                  OPCODE        =>  ALU_OPCODE,
                  A_PASS        =>  A_PASS,
                  B_PASS        =>  B_PASS,
                  C_FLAG_in     =>  C_in,
                  C_FLAG_out    =>  C_out_ALU,
                  V_FLAG_out    =>  V_out,
                  N_FLAG_out    =>  N_out,
                  Z_FLAG_out    =>  Z_out,
                  L_nA          =>  L_nA_s
                );


  nRST_SUM_MULT_s   <= nRST_SUM_MULT_s and nRST;
  nRST_CARRY_MULT_s <= nRST_CARRY_MULT_s and nRST;

  ALU_OUTPUT <= ALU_OUTPUT_s;

  ---------
  -- MUL --
  ---------
  HIGHSPEED_MULT_i: HIGHSPEED_MULT
    port    map ( CLK                 =>  CLK,
                  nRST                =>  nRST,
                  MULT_EN             =>  EN_MULT,
                  SIGNED_nUNSIGNED    =>  SIGNED_nUNSIGNED_MULT,
                  CYCLE_COUNT         =>  "00",                   --TODO, add counter and control signal for counter
                  EARLY_FINISH        =>  EARLY_FINISH,
                  HiLo_REG_SEL        =>  HILO_REG_SRC_MULT,

                  W_EN_Rm             =>  WR_RS_MULT,
                  W_EN_Rs             =>  WR_RS_MULT,
                  W_EN_SUM            =>  WR_SUM_MULT,

                  nRST_SUM            =>  NRST_SUM_MULT_s,
                  nRST_CARRY          =>  NRST_CARRY_MULT_s,

                  W_DATA_1            =>  B,
                  W_DATA_2            =>  A,

                  R_DATA_SUM          =>  R_DATA_SUM_s,
                  R_DATA_CARRY        =>  R_DATA_CARRY_s
                );

  ----------------------
  -- SHIFT AMOUNT REG --
  ----------------------
  SHIFT_AMOUNT_REG: REG_NEGEDGE_GEN
    generic map ( N     =>  6)
    port    map ( CLK   =>  CLK,
                  nRST  =>  nRST,
                  EN    =>  '1',
                  D     =>  B(5 downto 0),
                  Q     =>  SHIFT_AMOUNT_REG_Q
                );

  -------------
  -- SHIFTER --
  -------------
  SHIFT_AMOUNT_s  <=  SHIFT_AMOUNT        when SHIFT_SRC_AMOUNT = '1' else
                      SHIFT_AMOUNT_REG_Q;

  BARREL_SHIFTER_i: BARREL_SHIFTER
    port    map ( B_BUS_in            =>  B,
                  B_BUS_out           =>  SHIFT_OUT_s,
                  C_FLAG_in           =>  C_in,
                  C_FLAG_out          =>  C_out_SHIFT,
                  SH_AMOUNT           =>  SHIFT_AMOUNT_s,
                  SHIFT_OP            =>  SHIFT_OPCODE,
                  IMMEDIATE           =>  SHIFT_IMM
        );

  ----------------
  -- MDATA_ADDR --
  ----------------
  MDATA_ADDR_D  <=  ALU_OUTPUT_s    when  MDATA_SRC_ADDR = "00"   else
                    A_s             when  MDATA_SRC_ADDR = "01"   else
                    MDATA_ADDR_Q + 4;

  MDATA_ADDR_REG: REG_NEGEDGE_GEN
    generic map ( N     =>  DATA_BUS_w)
    port    map ( CLK   =>  CLK,
                  nRST  =>  nRST,
                  EN    =>  '1',
                  D     =>  MDATA_ADDR_D,
                  Q     =>  MDATA_ADDR_Q
                );

  MDATA_ADDR    <=  MDATA_ADDR_Q; 
end architecture BHV;
