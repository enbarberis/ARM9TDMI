library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;

library WORK;
use WORK.ARM_pack.all;

--------------------------------------------------------------------------------

entity ALU is
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
end entity ALU;

--------------------------------------------------------------------------------

architecture STR of ALU is

  component LOGIC_UNIT is
    port (

      -- DATA BUS
      A_DATA_in   : in  DATA_BUS_t;
      B_DATA_in   : in  DATA_BUS_t;
      R_DATA_out  : out DATA_BUS_t;

      -- COMMAND SIGNALS
      OP_SELECT   : in  std_logic_vector (3 downto 0)

    );
  end component LOGIC_UNIT;

  component P4ADDER is
    generic(
          N: natural := 32
    );
    port(
        A: in std_logic_vector(N-1 downto 0);
        B: in std_logic_vector(N-1 downto 0);
        Ci: in std_logic;
        Co: out std_logic;
        S: out std_logic_vector(N-1 downto 0)
    );

  end component;

  signal  C_in,                                                                 --  Carry in to the adder
          C_out,                                                                --  32nd carry signal of the adder
          --L_nA,                                                                 --  '1' -> Logic op./'0' -> Arith. op.
          CARRY_OP,                                                             --  Tell if operation need external Carry
          A_INVERT,                                                             --  Invert A operand
          B_INVERT  : std_logic;                                                --  Invert B operand

  signal  A_i,                                                                  --  A Bus (Op1) DATA
          B_i,                                                                  --  B Bus (Op2) DATA
          L_out,                                                                --  Logic Unit Output
          S_out     : DATA_BUS_t;                                               --  Adder Output

  signal  LOGIC_OP  : std_logic_vector(3 downto 0);                             --  Logic unit operation (selector values)
  signal  L_nA_s    : std_logic;

  signal  A_PASS_s  : std_logic;
  signal  B_PASS_s  : std_logic;


begin

  --L_nA, A_INVERT, B_INVERT, CIN, OP_SELECT
  --opcode_to_alu_signal: process (OPCODE, C_FLAG_in) : C_FLAG_in is not used inside the process
  opcode_to_alu_signal: process (OPCODE)
  begin
    A_PASS_s <= '0';
    B_PASS_s <= '0';
    case OPCODE is

      --AND
      when "0000"   =>  L_nA_s      <= '1';
                        CARRY_OP    <= '0';
                        A_INVERT    <= '0';
                        B_INVERT    <= '0';
                        LOGIC_OP    <= "0001";    -- S3

      --XOR
      when "0001"   =>  L_nA_s      <= '1';
                        CARRY_OP    <= '0';
                        A_INVERT    <= '0';
                        B_INVERT    <= '0';
                        LOGIC_OP    <= "0110";    -- S1 S2

      --SUB
      when "0010"   =>  L_nA_s      <= '0';
                        CARRY_OP    <= '0';
                        A_INVERT    <= '0';
                        B_INVERT    <= '1';
                        LOGIC_OP    <= "----";

      --RSB
      when "0011"   =>  L_nA_s      <= '0';
                        CARRY_OP    <= '0';
                        A_INVERT    <= '1';
                        B_INVERT    <= '0';
                        LOGIC_OP    <= "----";

      --ADD
      when "0100"   =>  L_nA_s      <= '0';
                        CARRY_OP    <= '0';
                        A_INVERT    <= '0';
                        B_INVERT    <= '0';
                        LOGIC_OP    <= "----";

      --ADC
      when "0101"   =>  L_nA_s      <= '0';
                        CARRY_OP    <= '1';
                        A_INVERT    <= '0';
                        B_INVERT    <= '0';
                        LOGIC_OP    <= "----";

      --SBC
      when "0110"   =>  L_nA_s      <= '0';
                        CARRY_OP    <= '1';
                        A_INVERT    <= '0';
                        B_INVERT    <= '1';
                        LOGIC_OP    <= "----";


      --RSC
      when "0111"   =>  L_nA_s      <= '0';
                        CARRY_OP    <= '1';
                        A_INVERT    <= '1';
                        B_INVERT    <= '0';
                        LOGIC_OP    <= "----";

      --TST
      when "1000"   =>  L_nA_s      <= '1';
                        CARRY_OP    <= '0';
                        A_INVERT    <= '0';
                        B_INVERT    <= '0';
                        LOGIC_OP    <= "0001";
      --TEQ
      when "1001"   =>  L_nA_s      <= '1';
                        CARRY_OP    <= '0';
                        A_INVERT    <= '0';
                        B_INVERT    <= '0';
                        LOGIC_OP    <= "0111";

      --CMP
      when "1010"   =>  L_nA_s      <= '0';
                        CARRY_OP    <= '0';
                        A_INVERT    <= '0';
                        B_INVERT    <= '1';
                        LOGIC_OP    <= "----";
      --CMN
      when "1011"   =>  L_nA_s      <= '0';
                        CARRY_OP    <= '1';
                        A_INVERT    <= '0';
                        B_INVERT    <= '0';
                        LOGIC_OP    <= "----";

      --ORR
      when "1100"   =>  L_nA_s      <= '1';
                        CARRY_OP    <= '0';
                        A_INVERT    <= '0';
                        B_INVERT    <= '0';
                        LOGIC_OP    <= "0111";

      --MOV (= OR)
      when "1101"   =>  L_nA_s      <= '1';
                        CARRY_OP    <= '0';
                        B_PASS_s    <= '1';
                        A_INVERT    <= '0';
                        B_INVERT    <= '0';
                        LOGIC_OP    <= "0111";

      --BIC
      when "1110"   =>  L_nA_s      <= '1';
                        CARRY_OP    <= '0';
                        A_INVERT    <= '0';
                        B_INVERT    <= '1';
                        LOGIC_OP    <= "0001";

      --MVN
      when "1111"   =>  L_nA_s      <= '1';
                        CARRY_OP    <= '0';
                        B_PASS_s    <= '1';
                        A_INVERT    <= '0';
                        B_INVERT    <= '1';
                        LOGIC_OP    <= "0111";

      when others =>    null;

    end case;
  end process;

  L_nA <= L_nA_s;

  --Generate negated inputs
  A_i <=  not A_DATA_in when A_INVERT = '1' else
              A_DATA_in when A_INVERT = '0';
  B_i <=  not B_DATA_in when B_INVERT = '1' else
              B_DATA_in when B_INVERT = '0';

  C_in        <=  (C_FLAG_in and CARRY_OP) xor (A_INVERT or B_INVERT);          --  Evaluates the carry input value for the adder


  C_FLAG_out  <=  C_out;
  N_FLAG_out  <=  S_out(31);
  Z_FLAG_out  <=  nor_reduce(S_out);
  V_FLAG_out  <=  C_out xor ( A_i(31) xor B_i(31) xor S_out(31));


  R_DATA_out  <=  L_out when L_nA_s = '1'   and A_PASS_s = '0' and B_PASS_s = '0' else
                  S_out when L_nA_s = '0'   and A_PASS_s = '0' and B_PASS_s = '0' else
                  A_i   when A_PASS_s = '1' and B_PASS_s = '0' else
                  B_i;

  LU  : LOGIC_UNIT
    port    map (A_i, B_i, L_out, LOGIC_OP);

  ADD : P4ADDER
    generic map (N => 32)
    port    map (A_i, B_i, C_in, C_out, S_out);

end architecture STR;
