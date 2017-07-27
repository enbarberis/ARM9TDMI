library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library WORK;
use WORK.ARM_pack.all;

entity BYTE_WORD_REPLICATION is
  port (
    data_in     :  in   std_logic_vector(31 downto 0);
    Mdata_dim   :  in   std_logic_vector( 1 downto 0);
    data_out    :  out  std_logic_vector(31 downto 0)
  );
end entity;

architecture BHV of BYTE_WORD_REPLICATION is
begin

  data_out <= data_in(7 downto 0) & data_in(7 downto 0)
              & data_in(7 downto 0) & data_in(7 downto 0) when Mdata_dim = "00" else
              data_in(15 downto 0) & data_in(15 downto 0) when Mdata_dim = "01" else
              data_in;

end architecture; -- BHV
