library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity priority_encoder is
  port (
    decoded_value : in  std_logic_vector(15 downto 0);
    mask          : out std_logic_vector(15 downto 0);
    value         : out std_logic_vector( 3 downto 0)
  );
end entity;


architecture BHV of priority_encoder is
begin

  COMB_LOGIC: process(decoded_value)
  begin
    mask <= ( others => '0' );
    value <= ( others => '0');
    if ( decoded_value(0) = '1' ) then 
        mask(0) <= '1';
        value <= std_logic_vector(to_unsigned(0,4));
    elsif ( decoded_value(1) = '1' ) then 
        mask(1) <= '1';
        value <= std_logic_vector(to_unsigned(1,4));
    elsif ( decoded_value(2) = '1' ) then 
        mask(2) <= '1';
        value <= std_logic_vector(to_unsigned(2,4));
    elsif ( decoded_value(3) = '1' ) then 
        mask(3) <= '1';
        value <= std_logic_vector(to_unsigned(3,4));
    elsif ( decoded_value(4) = '1' ) then 
        mask(4) <= '1';
        value <= std_logic_vector(to_unsigned(4,4));
    elsif ( decoded_value(5) = '1' ) then 
        mask(5) <= '1';
        value <= std_logic_vector(to_unsigned(5,4));
    elsif ( decoded_value(6) = '1' ) then 
        mask(6) <= '1';
        value <= std_logic_vector(to_unsigned(6,4));
    elsif ( decoded_value(7) = '1' ) then 
        mask(7) <= '1';
        value <= std_logic_vector(to_unsigned(7,4));
    elsif ( decoded_value(8) = '1' ) then 
        mask(8) <= '1';
        value <= std_logic_vector(to_unsigned(8,4));
    elsif ( decoded_value(9) = '1' ) then 
        mask(9) <= '1';
        value <= std_logic_vector(to_unsigned(9,4));
    elsif ( decoded_value(10) = '1' ) then 
        mask(10) <= '1';
        value <= std_logic_vector(to_unsigned(10,4));
    elsif ( decoded_value(11) = '1' ) then 
        mask(11) <= '1';
        value <= std_logic_vector(to_unsigned(11,4));
    elsif ( decoded_value(12) = '1' ) then 
        mask(12) <= '1';
        value <= std_logic_vector(to_unsigned(12,4));
    elsif ( decoded_value(13) = '1' ) then 
        mask(13) <= '1';
        value <= std_logic_vector(to_unsigned(13,4));
    elsif ( decoded_value(14) = '1' ) then 
        mask(14) <= '1';
        value <= std_logic_vector(to_unsigned(14,4));
    elsif ( decoded_value(15) = '1' ) then 
        mask(15) <= '1';
        value <= std_logic_vector(to_unsigned(15,4));
    else
        mask <= ( others => '0' );
        value <= std_logic_vector(to_unsigned(0,4));
    end if;
  end process;

end architecture BHV;
