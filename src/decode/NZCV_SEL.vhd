library IEEE;
use IEEE.std_logic_1164.all;

library WORK;
use WORK.ARM_pack.all;

entity NZCV_SEL is
  port (
    N_EXE     : in  std_logic                   ;
    C_EXE     : in  std_logic                   ;
    Z_EXE     : in  std_logic                   ;
    V_EXE     : in  std_logic                   ;
    PREV_Z    : in  std_logic                   ;
    LONG_MUL  : in  std_logic                   ;
    NZCV_EXE  : out std_logic_vector(3 downto 0)
  );
end entity;


architecture BHV of NZCV_SEL is


begin

  NZCV_EXE(3) <=  N_EXE;
  NZCV_EXE(2) <=  Z_EXE when LONG_MUL = '0' else
              Z_EXE and PREV_Z;
  NZCV_EXE(1) <=  C_EXE;
  NZCV_EXE(0) <=  V_EXE;

end architecture BHV;
