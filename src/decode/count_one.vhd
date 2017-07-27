library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


--------------------------------------------------------------------------------

entity count_one is
  port (
    decoded_value : in  std_logic_vector(15 downto 0);
    value         : out std_logic_vector( 3 downto 0)
  );
end entity ;

--------------------------------------------------------------------------------

architecture BHV of count_one is
begin
  
  COMB_LOGIC: process(decoded_value)
    variable count : integer range 0 to 15 := 0;
  begin
    count := 0;
    for i in 0 to 15 loop
      if ( decoded_value(i) = '1' ) then
        count := count + 1;
      end if;
    end loop;
    value <= std_logic_vector(to_unsigned(count,4));
  end process;

end architecture BHV;
