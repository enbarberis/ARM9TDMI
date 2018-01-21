library IEEE;
use IEEE.std_logic_1164.all;

entity DFF  is
  port (
    D     : in  std_logic;
    Q     : out std_logic;
    clk   : in std_logic;
    nRst  : in std_logic
  );
end entity;


architecture BHV of DFF is
  signal int_mem: std_logic;
begin

  MEM_PROC: process(clk, nRst)
  begin
    if ( nRst = '0' ) then
      int_mem <= '0';
    elsif ( clk = '0' and clk'event ) then
      int_mem <= D;
    --else
      --int_mem <= int_mem;
    end if;
  end process;

  Q <= int_mem;

end architecture BHV;
