library IEEE;
use IEEE.std_logic_1164.all;


entity MUX41_GEN is
  generic (N : natural := 32);
  port (
    A : in  std_logic_vector (N-1 downto 0);
    B : in  std_logic_vector (N-1 downto 0);
    C : in  std_logic_vector (N-1 downto 0);
    D : in  std_logic_vector (N-1 downto 0);
    S : in  std_logic_vector (  1 downto 0);
    Y : out std_logic_vector (N-1 downto 0)
  );
end entity MUX41_GEN;


architecture BHV of MUX41_GEN is

  constant Z : std_logic_vector (N-1 downto 0) := (others => 'Z');

begin

  with S select
    Y <=  A when "00",
          B when "01",
          C when "10",
          D when "11",
          Z when others;

end architecture BHV;