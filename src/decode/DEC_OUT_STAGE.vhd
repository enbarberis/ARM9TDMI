library IEEE;
use IEEE.std_logic_1164.all;

library WORK;
use WORK.ARM_pack.all;

entity DEC_OUT_STAGE  is
  port (
    CLK               : in  std_logic                   ;
    nRST              : in  std_logic                   ;
    STALL             : in  std_logic                   ;
    EN_RDA            : in  std_logic                   ;
    EN_RDB            : in  std_logic                   ;

    SPSR              : in  DATA_BUS_t                  ;
    CPSR              : in  DATA_BUS_t                  ;
    A_RDATA           : in  DATA_BUS_t                  ;
    B_RDATA           : in  DATA_BUS_t                  ;
    IMMEDIATE         : in  DATA_BUS_t                  ;
    ALU_OUT_EXE       : in  DATA_BUS_t                  ;
    ALU_OUT_MEM       : in  DATA_BUS_t                  ;
    DATA_MEM_OUT      : in  DATA_BUS_t                  ;


    A_DATA_SEL        : in  std_logic_vector(2 downto 0); --Mux selector of operand A
    B_DATA_SEL        : in  std_logic_vector(2 downto 0); --Mux selector of operand B
    A_OUT             : out DATA_BUS_t                  ;
    B_OUT             : out DATA_BUS_t                  
  );
end entity;


architecture BHV of DEC_OUT_STAGE is

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

  signal A_OUT_s  : DATA_BUS_t  ;
  signal B_OUT_s  : DATA_BUS_t  ;
  signal LD_A     : std_logic   ;
  signal LD_B     : std_logic   ;

begin

  LD_A <= EN_RDA;
  LD_B <= EN_RDB;


  A_OUT_REG: REG_NEGEDGE_GEN
    port map (
      CLK       =>  CLK     ,  
      nRST      =>  nRST    ,
      EN        =>  LD_A    ,
      D         =>  A_OUT_s ,
      Q         =>  A_OUT
    );


  B_OUT_REG: REG_NEGEDGE_GEN
    port map (
      CLK       =>  CLK     ,  
      nRST      =>  nRST    ,
      EN        =>  LD_B    ,
      D         =>  B_OUT_s ,
      Q         =>  B_OUT
    );


  process(A_DATA_SEL,A_RDATA, DATA_MEM_OUT, CPSR , SPSR, ALU_OUT_EXE, ALU_OUT_MEM)
  begin
    case A_DATA_SEL is

      when A_REG_FILE =>
        A_OUT_s <= A_RDATA;

      when A_DATA_MEM_OUT =>
        A_OUT_s <= DATA_MEM_OUT;

      when A_CPSR =>
        A_OUT_s <= CPSR;

      when A_SPSR =>
        A_OUT_s <= SPSR;

      when A_ALU_OUT =>
        A_OUT_s <= ALU_OUT_EXE;

      when A_ALU_OUT_SKEWED =>
        A_OUT_s <= ALU_OUT_MEM;

      when others =>
        A_OUT_s <= ( others => '-');

    end case;
  end process;

  process(B_DATA_SEL, B_RDATA, DATA_MEM_OUT, ALU_OUT_EXE, ALU_OUT_MEM, IMMEDIATE)
  begin
    case B_DATA_SEL is

      when B_REG_FILE =>
        B_OUT_s <= B_RDATA;

      when B_DATA_MEM_OUT =>
        B_OUT_s <= DATA_MEM_OUT;

      when B_IMMEDIATE =>
        B_OUT_s <= IMMEDIATE;

      when B_ALU_OUT =>
        B_OUT_s <= ALU_OUT_EXE;

      when B_ALU_OUT_SKEWED =>
        B_OUT_s <= ALU_OUT_MEM;

      when others =>
        B_OUT_s <= ( others => '-');

    end case;
  end process;




end architecture BHV;
