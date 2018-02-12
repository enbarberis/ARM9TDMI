library IEEE;
use IEEE.std_logic_1164.all;


entity REG_NEGEDGE_GEN is
  generic (N : natural := 32);
  port (
    CLK   : in  std_logic;
    nRST  : in  std_logic;
    EN    : in  std_logic;
    D     : in  std_logic_vector (N-1 downto 0);
    Q     : out std_logic_vector (N-1 downto 0)
  );
end entity REG_NEGEDGE_GEN;


architecture BHV of REG_NEGEDGE_GEN is

  signal  S : std_logic_vector  (N-1 downto 0);

begin

  process (CLK, nRST)
  begin

    if (nRST = '0') then
      S <= (others => '0');
    elsif (CLK = '0' and CLK'event)  then
    	if (EN = '1') then
      		S <= D;
    	else
      		S <= S;
    	end if;
    end if;

  end process;

  Q <= S;

end architecture BHV;
