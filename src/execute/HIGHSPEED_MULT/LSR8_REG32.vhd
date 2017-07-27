library IEEE;
use IEEE.std_logic_1164.all;

--------------------------------------------------------------------------------

entity LSR8_REG32 is
  port (
    nRST      : in  std_logic; 
    CLK       : in  std_logic;

    R_DATA    : out std_logic_vector (31 downto 0); 
    W_EN      : in  std_logic; 
    W_DATA    : in  std_logic_vector (31 downto 0);

    LSR_FILL  : in  std_logic;
    LSR_EN    : in  std_logic
  );
end entity LSR8_REG32;

--------------------------------------------------------------------------------

architecture BHV of LSR8_REG32 is

  signal  DATA_int  : std_logic_vector (31 downto 0);
  signal  FILLER    : std_logic_vector ( 7 downto 0);

begin

  FILLER  <=  (others => LSR_FILL);

  MAIN_p : process (nRST, CLK)
  begin

    if (nRST = '0') then

      DATA_int  <=  (others => '0');

    elsif (nRST = '1' and CLK = '1' and CLK'event) then

      if (W_EN = '1') then
        DATA_int  <=  W_DATA;
      elsif (LSR_EN = '1') then
        DATA_int  <=  FILLER & DATA_int (31 downto 8);
      else
        DATA_int  <=  DATA_int;
      end if;

    end if;

  end process MAIN_p;

  R_DATA  <=  DATA_int;

end architecture BHV;