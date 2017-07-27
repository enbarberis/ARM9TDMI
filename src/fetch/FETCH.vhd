library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library WORK;
use WORK.ARM_pack.all;


entity FETCH is
  port (
    CLK   : in  std_logic;

    --Input from processor PINS
    nRESET            : in  std_logic;                      --Not Reset
    nIRQ              : in  std_logic;                      --Not Interrupt Request
    nFIQ              : in  std_logic;                      --Not Fast Interrupt request
    BIGEND            : in  std_logic;                      --Big-Endian configration
    HIVECS            : in  std_logic;                      --Speicify low or high exception address

    --Input from datpath
    ALU_OUTPUT        : in  DATA_BUS_t;                     --Needed for IA and NEXT CPSR
    SPSR              : in  std_logic_vector(7 downto 0);   --Least significant byte of SPSR

    --Input from control unit
    DEC_SRC_NXT_IA    : in  std_logic_vector(1 downto 0);   --Next Instruction address mux selector
    DEC_WR_IA         : in  std_logic;                      --Enable write of instruction address register
    DEC_SRC_NXT_CPSR  : in  std_logic_vector(1 downto 0);   --Next CPSR value mux selector
    DEC_WR_NXT_CPSR   : in  std_logic;                      --Enable write of NEXT CPSR
    DEC_WR_OPCODE     : in  std_logic;                      --Enable write of pipeline register Fetch->Decode
    EXCEPTION_ADDR    : in  std_logic_vector(2 downto 0);   --Needed by NEXT CPSR to generate correct cpu mode frm execption addr

    --Output for decode stage
    IA_INC            : out ADDR_BUS_t;                     --Instruction address + 4, equal to PC+8. Must be loaded by reg. file
    OPCODE            : out OPCODE_t;                       --Contains ID + nIRQ + nFIQ + DABORT + IABORT
    NEXT_CPSR_Q       : out std_logic_vector(7 downto 0);   --NEXT CPSR value, needed by CPSR to be loaded

    --Instruction memory interface
    IA                : out ADDR_BUS_t;                     -- Instruction Address Bus. This is the processor instruction address bus
    InM               : out CPSR_MODE_t;                    -- Instruction Mode. Current mode of processor (last 5 bits of CPSR)
    InMREQ            : out std_logic;                      -- Not Instruction Memory Request. When Low request a memory access
    InTRANS           : out std_logic;                      -- Not Memory Translate. 0 when user mode, 1 when privileged mode
    ISEQ              : out std_logic;                      -- Instruction sequential address.

    ID                : in  ARM_INSTR_t;                    -- Instruction Data Bus
    IABE              : in  std_logic;                      -- Instruction Address Bus Enable.
    IABORT            : in  std_logic;                      -- Instruction Abort. Set to 1 when memory access is not allowed.

    --Data memory interface
    DABORT    : in  std_logic;                              -- Data Abort.
    DDIN      : in  DATA_BUS_t                              -- Data Input Bus.
  );
end entity FETCH;


architecture BHV of FETCH is

  component REG_NEGEDGE_GEN is
    generic (N : natural);
    port (
      CLK   : in  std_logic;
      nRST  : in  std_logic;
      EN    : in  std_logic;
      D     : in  std_logic_vector (N-1 downto 0);
      Q     : out std_logic_vector (N-1 downto 0)
    );
  end component REG_NEGEDGE_GEN;

  component NEXT_CPSR is
    port (
      CLK             : in  std_logic;
      LD              : in  std_logic;
      nRST            : in  std_logic;
      EXCEPTION_ADDR  : in  std_logic_vector(2 downto 0);
      ALU_OUTPUT      : in  std_logic_vector(7 downto 0);
      SPSR            : in  std_logic_vector(7 downto 0);
      SEL             : in  std_logic_vector(1 downto 0);   --00 Execption addr, 01 ALU OUTPUT, 10 SPSR, 11 SPSR

      Q               : out std_logic_vector(7 downto 0)
    );
  end component NEXT_CPSR;

  component DFF  is
    port (
      D     : in  std_logic;
      Q     : out std_logic;
      clk   : in std_logic;
      nRst  : in std_logic
    );
  end component;


  --NEXT CPSR SIGNAL
  signal NEXT_CPSR_s            : std_logic_vector(7 downto 0);     --NEXT CPSR Value
  signal MODE                   : std_logic_vector(4 downto 0);     --NEXT CPSR Mode
  signal TBIT                   : std_logic;                        --NEXT CPSR thumb bit
  signal IBIT                   : std_logic;                        --NEXT CPSR interrupt bit
  signal FBIT                   : std_logic;                        --NEXT CPSR fast interrupt bit

  --OPCODE SIGNAL
  signal OPCODE_D               : OPCODE_t;                         --OPCODE regiuster input value
  signal ID_s                   : ARM_INSTR_t;                      --Instruction memory data output

  --IA SIGNAL
  signal IA_D                   : ADDR_BUS_t;                       --Instruction address input value
  signal IA_INC_s               : ADDR_BUS_t;                       --Current instruction address incremented
  signal IA_s                   : ADDR_BUS_t;                       --Current instruction address value

  --Memory interface signal
  signal InMREQ_s               : std_logic;                        --Memory request
  signal ISEQ_D                 : std_logic;                        --ISEQ skewing latch input

begin

  ---------------
  -- NEXT CPSR --
  ---------------
  NEXT_CPSR_i:  NEXT_CPSR
  port map  ( CLK               =>  CLK,
              LD                =>  DEC_WR_NXT_CPSR,
              nRST              =>  nRESET,
              EXCEPTION_ADDR    =>  EXCEPTION_ADDR,
              ALU_OUTPUT        =>  ALU_OUTPUT(7 downto 0),
              SPSR              =>  SPSR,
              SEL               =>  DEC_SRC_NXT_CPSR,
              Q                 =>  NEXT_CPSR_s
            );

  MODE <= NEXT_CPSR_s(4 downto 0);
  TBIT <= NEXT_CPSR_s(5);
  FBIT <= NEXT_CPSR_s(6);
  IBIT <= NEXT_CPSR_s(7);

  NEXT_CPSR_Q <= NEXT_CPSR_s;

  ------------
  -- OPCODE --
  ------------
  process (TBIT, IA_s, BIGEND, ID)
  begin
  if TBIT = '0' then
    if ( BIGEND = '0' ) then
      ID_s <= ID;
    else
      ID_s <= ID(7 downto 0) & ID(15 downto 8) & ID(23 downto 16) & ID(31 downto 24);
    end if;
  else
    if    IA_s(1) = '0' and BIGEND = '0' then
      ID_s <= x"0000" & ID(15 downto 0);

    elsif IA_s(1) = '0' and BIGEND = '1' then
      ID_s <= x"0000" & ID(31 downto 16);

    elsif IA_s(1) = '1' and BIGEND = '0' then
      ID_s <= x"0000" & ID(31 downto 16);

    else
      ID_s <= x"0000" & ID(15 downto 0);

    end if;
  end if;
  end process;

  OPCODE_D <= (nFIQ or FBIT) & (nIRQ or IBIT) & DABORT & IABORT & ID_s;

  OPCODE_i: REG_NEGEDGE_GEN
  generic map (N => OPCODE_w)
  port map  ( CLK     =>  CLK,
              nRST    =>  nRESET,
              EN      =>  DEC_WR_OPCODE,
              D       =>  OPCODE_D,
              Q       =>  OPCODE
            );

  --------
  -- IA --
  --------
  process (TBIT, IA_s)
  begin
  if TBIT = '0' then
    IA_INC_s <= IA_s + 4;
  else
    IA_INC_s <= IA_s + 2;
  end if;
  end process;
  IA_INC <= IA_INC_s;

  IA_MUX_PROC:  process(ALU_OUTPUT, DDIN, IA_INC_s, EXCEPTION_ADDR, DEC_SRC_NXT_IA, HIVECS)
  begin

    if    DEC_SRC_NXT_IA = "00" then
      IA_D <= IA_INC_s;

    elsif DEC_SRC_NXT_IA = "01" then
      if HIVECS = '0' then
        IA_D <= "000000000000000000000000000" & EXCEPTION_ADDR & "00";
      else
        IA_D <= "111111111111111100000000000" & EXCEPTION_ADDR & "00";
      end if;

    elsif DEC_SRC_NXT_IA = "10" then
        IA_D <= ALU_OUTPUT;

    else
        IA_D <= DDIN;

    end if;

  end process;


  IA_REG: REG_NEGEDGE_GEN
  generic map (N => ADDR_BUS_w)
  port map  ( CLK     =>  CLK,
              nRST    =>  nRESET,
              EN      =>  DEC_WR_IA,
              D       =>  IA_D,
              Q       =>  IA_s
            );

  IA <= IA_s;

  ----------------------
  -- MEMORY INTERFACE --
  ----------------------

  InM <= MODE;                --Take mode from NEXT CPSR
  InMREQ_s <= not DEC_WR_IA;  --Make memory request only when load new instruction address

  InMREQ_DFF: DFF
  port map  ( CLK     =>  CLK,
              nRST    =>  nRESET,
              D       =>  InMREQ_s,
              Q       =>  InMREQ
            );


  -- InTRANS generation from processor MODE
  process (MODE)
  begin
    if MODE = "10000" then
      InTRANS <= '0';
    else
      InTRANS <= '1';
    end if;
  end process;

  -- ISEQ generation from IA mux selector signal
  process (DEC_SRC_NXT_IA)
  begin
    if DEC_SRC_NXT_IA = "00" then
      ISEQ_D <= '1';
    else
      ISEQ_D <= '0';
    end if;
  end process;

  ISEQ_DFF: DFF
  port map  ( CLK     =>  CLK,
              nRST    =>  nRESET,
              D       =>  ISEQ_D,
              Q       =>  ISEQ
            );

end architecture BHV;
