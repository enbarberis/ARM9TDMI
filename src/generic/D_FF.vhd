library IEEE;
use IEEE.std_logic_1164.all;


entity D_FF is
  port (
    CLK   : in  std_logic;
    nRST  : in  std_logic;
    EN    : in  std_logic;
    D     : in  std_logic;
    Q     : out std_logic
  );
end entity D_FF;


architecture BHV of D_FF is

    SIGNAL S     : std_logic;
begin
  
  process (CLK, nRST)
  begin

    if (nRST = '0') then
      S <= '0';
    elsif (CLK = '0' and CLK'event) then
    	if  (EN = '1') then
      	S <= D;
	    else
	      S <= S;
    	end if;
    end if;

  end process;
	
  Q <= S;

end architecture BHV;
