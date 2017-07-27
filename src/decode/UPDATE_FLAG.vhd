library IEEE;
use IEEE.std_logic_1164.all;

library WORK;
use WORK.ARM_pack.all;

entity UPDATE_FLAG is
  port (
    N_EXE         : in  std_logic                   ;
    C_EXE         : in  std_logic                   ;
    Z_EXE         : in  std_logic                   ;
    V_EXE         : in  std_logic                   ;
    PREV_Z        : in  std_logic                   ;
    LONG_MUL      : in  std_logic                   ;
    SPSR_flag     : in  std_logic_vector(3 downto 0);
    ALU_OUT_flag  : in  std_logic_vector(3 downto 0);
    SRC_FLAG      : in  std_logic_vector(1 downto 0);

    NZCV_nxt      : out std_logic_vector(3 downto 0)
  );
end entity;


architecture BHV of UPDATE_FLAG is

  component NZCV_SEL is
    port (
      N_EXE     : in  std_logic                   ;
      C_EXE     : in  std_logic                   ;
      Z_EXE     : in  std_logic                   ;
      V_EXE     : in  std_logic                   ;
      PREV_Z    : in  std_logic                   ;
      LONG_MUL  : in  std_logic                   ;
      NZCV_EXE  : out std_logic_vector(3 downto 0)
    );
  end component NZCV_SEL;

  signal NZCV_EXE_s  : std_logic_vector(3 downto 0);

begin

  FLAG_EXE: NZCV_SEL
    port map (
      N_EXE     => N_EXE      ,
      C_EXE     => C_EXE      ,
      Z_EXE     => Z_EXE      ,
      V_EXE     => V_EXE      ,
      PREV_Z    => PREV_Z     ,
      LONG_MUL  => LONG_MUL   ,
      NZCV_EXE  => NZCV_EXE_s
    );

  process(NZCV_EXE_s,SPSR_flag,ALU_OUT_flag,SRC_FLAG)
  begin
    case SRC_FLAG is
      when "00" =>
        NZCV_nxt <= NZCV_EXE_s;
      when "01" =>
        NZCV_nxt <= SPSR_flag;
      when others =>
        NZCV_nxt <= ALU_OUT_flag;
    end case;
  end process;


end architecture BHV;
