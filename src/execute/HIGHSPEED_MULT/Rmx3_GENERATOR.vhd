library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library WORK;
use WORK.ARM_pack.all;

--------------------------------------------------------------------------------

entity Rmx3_GENERATOR_GEN is
  generic ( N : natural := 32 );
  port (
    Rm    : in  std_logic_vector (N-1 downto 0);
    Rmx3  : out std_logic_vector (N-1 downto 0)
  );
end entity Rmx3_GENERATOR_GEN;

--------------------------------------------------------------------------------

architecture BHV of Rmx3_GENERATOR_GEN is

  signal  SUM : std_logic_vector (N downto 0);

begin

  SUM   <=  Rm + (Rm & '0');
  Rmx3  <=  SUM (N-1 downto 0);

end architecture BHV;