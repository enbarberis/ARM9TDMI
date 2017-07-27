library ieee;
use ieee.std_logic_1164.all;


entity general_g is
  port(
        G_ik: in std_logic;
        P_ik: in std_logic;
        G_k_1_j: in std_logic;
        G_ij: out std_logic
      );
end entity general_g;


architecture behavioral of general_g is
begin

  G_ij <= G_ik or (G_k_1_j and P_ik);

end behavioral;


