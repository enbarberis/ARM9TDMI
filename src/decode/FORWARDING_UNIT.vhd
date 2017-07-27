library IEEE;
use IEEE.std_logic_1164.all;

library WORK;
use WORK.ARM_pack.all;

entity FORWARDING_UNIT  is
  port (

    DEC_ADDR_rdA      : in  REG_ADDR_t;                     --Read address of read port A
    DEC_ADDR_rdB      : in  REG_ADDR_t;                     --Read address of read port B
    DEC_EN_rdA        : in  std_logic;                      --1 if on decode read port A is read
    DEC_EN_rdB        : in  std_logic;                      --1 if on decode read port B is read

    EXE_ADDR_wrA      : in  REG_ADDR_t;                     --Address of register that instruction in execute stage will write on port A
    MEM_ADDR_wrA      : in  REG_ADDR_t;                     --Address of register that instruction in memory  stage will write on port A
    EXE_EN_wrA        : in  std_logic;                      --1 if the instruction in the exe stage WILL write on port A
    MEM_EN_wrA        : in  std_logic;                      --1 if the instruction in the mem stage WILL write on port A

    EXE_ADDR_wrB      : in  REG_ADDR_t;                     --Address of register that instruction in execute stage will write on port B
    MEM_ADDR_wrB      : in  REG_ADDR_t;                     --Address of register that instruction in memory  stage will write on port B
    EXE_EN_wrB        : in  std_logic;                      --1 if the instruction in the exe stage WILL write on port B
    MEM_EN_wrB        : in  std_logic;                      --1 if the instruction in the mem stage WILL write on port B

    IMM_INST          : in  std_logic;                      --Tell if the instruction require an immediate operand
    EN_rdPSR          : in  std_logic;                      --Tell if the instruction will read CPSR or SPSR
    CPSR_nSPSR        : in  std_logic;                      --Tell which PSR will be read among CPSR and SPSR
    MDATA_DIM         : in  std_logic_vector(1 downto 0);   --Tell memory access size. If not 32 an additional stall is needed


    A_DATA_SEL        : out std_logic_vector(2 downto 0);   --Mux selector of operand A
    B_DATA_SEL        : out std_logic_vector(2 downto 0);   --Mux selector of operand B
    STALL             : out std_logic                       --Tell if forwarding is not possible and stall is needed

  );
end entity;


architecture BHV of FORWARDING_UNIT is

begin

  main: process ( DEC_ADDR_rdA,
                  DEC_ADDR_rdB,
                  EXE_ADDR_wrA,
                  MEM_ADDR_wrA,
                  EXE_EN_wrA,
                  MEM_EN_wrA,
                  EXE_ADDR_wrB,
                  MEM_ADDR_wrB,
                  EXE_EN_wrB,
                  MEM_EN_wrB,
                  IMM_INST,
                  EN_rdPSR,
                  CPSR_nSPSR,
                  MDATA_DIM)
  begin

    STALL <= '0';
    ----------------
    -- A_DATA_SEL --
    ----------------
    if EN_rdPSR = '1' then
      if CPSR_nSPSR = '1' then
        A_DATA_SEL <= A_CPSR;
      else
        A_DATA_SEL <= A_SPSR;
      end if;

    --If read on port A a register that will be written by the instruction in the exe stage
    elsif EXE_ADDR_wrA = DEC_ADDR_rdA and EXE_EN_wrA = '1' and DEC_EN_rdA = '1' then
      A_DATA_SEL <= A_ALU_OUT;

    --If read on port A a register that will be written by the memory
    elsif EXE_ADDR_wrB = DEC_ADDR_rdA and EXE_EN_wrB = '1' and DEC_EN_rdA = '1'  then
      A_DATA_SEL <= "---";
      STALL <= '1';

    --If read on port A a register that is currently bypassed in the MEM stage
    elsif MEM_ADDR_wrA = DEC_ADDR_rdA and MEM_EN_wrA = '1' and DEC_EN_rdA = '1' then
      A_DATA_SEL <= A_ALU_OUT_SKEWED;

    --If read on part A a register that the memory will write
    elsif MEM_ADDR_wrB = DEC_ADDR_rdA and MEM_EN_wrB = '1' and DEC_EN_rdA = '1' then
      if MDATA_DIM = "10" then
        A_DATA_SEL <= A_DATA_MEM_OUT;
      else
        --Stall if sign extension is needed (avoid critical path)
        A_DATA_SEL <= "---";
        STALL <= '1';
      end if;

    --In any other case (read from reg file or simply don't read from port A) select reg file output
    else
      A_DATA_SEL <= A_REG_FILE;

    end if;

    ----------------
    -- B_DATA_SEL --
    ----------------
    if IMM_INST = '1' then
      B_DATA_SEL <= B_IMMEDIATE;

    --If read on port B a register that will be written by the current instruction in the exe
    elsif EXE_ADDR_wrA = DEC_ADDR_rdB and EXE_EN_wrA = '1' and DEC_EN_rdB = '1' then
      B_DATA_SEL <= B_ALU_OUT;

    --If read on port B a register that is currently bypassed in the MEM stage
    elsif MEM_ADDR_wrA = DEC_ADDR_rdB and MEM_EN_wrA = '1' and DEC_EN_rdB = '1' then
      B_DATA_SEL <= B_ALU_OUT_SKEWED;

    --If read on port B a register that will be written by the memory
    elsif EXE_ADDR_wrB = DEC_ADDR_rdB and EXE_EN_wrB = '1' and DEC_EN_rdB = '1' then
      B_DATA_SEL <= "---";
      STALL <= '1';

    --If read on part B a register that the memory will write
    elsif MEM_ADDR_wrB = DEC_ADDR_rdB and MEM_EN_wrB = '1' and DEC_EN_rdB = '1' then
      if MDATA_DIM = "10" then
        B_DATA_SEL <= B_DATA_MEM_OUT;
      else
        B_DATA_SEL <= "---";
        STALL <= '1';
      end if;

    --In any other case (read from reg file or simply don't read from port B) select reg file output
    else
      B_DATA_SEL <= B_REG_FILE;

    end if;

  end process;

end architecture BHV;
