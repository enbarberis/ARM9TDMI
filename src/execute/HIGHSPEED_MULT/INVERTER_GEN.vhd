library IEEE;
use IEEE.std_logic_1164.all;

--------------------------------------------------------------------------------

entity INVERTER_GEN is
  generic (N : natural := 32);
  port (
    A : in  std_logic_vector(N-1 downto 0);
    Y : out std_logic_vector(N-1 downto 0)
  );
end entity INVERTER_GEN;

--------------------------------------------------------------------------------

architecture BHV of INVERTER_GEN is

  signal S : std_logic_vector(N-1 downto 0);

begin

  S(0) <= '0';
  Y(0) <= A(0);

  GATE_GENERATE : for I in 1 to N-1 generate

    S(i)  <=  A(i-1)   or S(i-1);
    Y(i)  <=  A(i)    xor S(i);

  end generate GATE_GENERATE;

end architecture BHV;