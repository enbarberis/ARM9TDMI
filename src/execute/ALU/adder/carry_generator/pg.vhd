library ieee;
use ieee.std_logic_1164.all;


entity pg is
  port(
        A: in std_logic;
        B: in std_logic;
        P: out std_logic;
        G: out std_logic
      );
end entity pg;


architecture behavioral of pg is
begin

  P <= A xor B;
  G <= A and B;

end behavioral;


