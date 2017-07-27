library IEEE;
use IEEE.std_logic_1164.all;


entity MUX21_GEN is
  generic (N : natural := 32);
  port (
    A : in  std_logic_vector (N-1 downto 0);
    B : in  std_logic_vector (N-1 downto 0);
    S : in  std_logic;
    Y : out std_logic_vector (N-1 downto 0)
  );
end entity MUX21_GEN;


architecture BHV of MUX21_GEN is

  constant Z : std_logic_vector (N-1 downto 0) := (others => 'Z');

begin

  with S select
    Y <=  A when '0',
          B when '1',
          Z when others;

end architecture ; -- BHV