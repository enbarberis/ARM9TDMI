library IEEE;
use IEEE.std_logic_1164.all;

library WORK;
use WORK.ARM_pack.all;

--------------------------------------------------------------------------------

entity CSA_GEN is
  generic ( N : natural := 32 );
  port (
    A_DATA_in   : in  std_logic_vector (N-1 downto 0);
    B_DATA_in   : in  std_logic_vector (N-1 downto 0);
    C_DATA_in   : in  std_logic_vector (N-1 downto 0);
    C_DATA_out  : out std_logic_vector (N-1 downto 0);
    S_DATA_out  : out std_logic_vector (N-1 downto 0)
  );
end entity CSA_GEN;

--------------------------------------------------------------------------------

architecture BHV of CSA_GEN is
begin

  S_DATA_out <= A_DATA_in xor B_DATA_in xor C_DATA_in;
  C_DATA_out <= (A_DATA_in and B_DATA_in) or
                (A_DATA_in and C_DATA_in) or
                (B_DATA_in and C_DATA_in);

end architecture BHV;