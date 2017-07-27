library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library WORK;
use WORK.ARM_pack.all;

entity BYTE_ROT_SIGN_EXT is
  port (
    data_in     :  in   std_logic_vector(31 downto 0);
    Mdata_dim   :  in   std_logic_vector( 1 downto 0);
    Mdata_sign  :  in   std_logic                    ;
    data_out    :  out  std_logic_vector(31 downto 0)
  );
end entity;

architecture BHV of BYTE_ROT_SIGN_EXT is

  signal intermediate_data, mask : std_logic_vector(31 downto 0);  
 
begin

  gen_proc: process(Mdata_dim,data_in) 
  begin
    case Mdata_dim is
      when "00" =>
        intermediate_data <=  std_logic_vector(resize(unsigned(data_in(7 downto 0)),32));
        mask              <=  (31 downto 8 => data_in(7)) & x"00";
      when "01" =>
        intermediate_data <=  std_logic_vector(resize(unsigned(data_in(15 downto 0)),32));
        mask              <=  (31 downto 16 => data_in(15)) & x"0000";
      when others =>
        intermediate_data <=  data_in;
        mask              <=  ( others => '0');
    end case;
  end process;

  sel_proc: process(intermediate_data, mask, Mdata_sign)
  begin
        if Mdata_sign = '0' then
         data_out          <=  intermediate_data;
        else
          data_out          <=  intermediate_data or mask;
        end if;
  end process;



end architecture; -- BHV
