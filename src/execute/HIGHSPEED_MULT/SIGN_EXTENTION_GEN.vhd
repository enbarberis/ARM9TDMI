library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.ARM_pack.all;
use WORK.MATH_FUNCTION_pack.all;

--------------------------------------------------------------------------------

entity SIGN_EXTENTION_GEN is
  generic ( N : natural := 32 );
  port (
    OP_TYPE   : in  std_logic;
    CYCLE     : in  std_logic_vector (    1 downto 0);
    Rm_MSB    : in  std_logic;
    CARRY_in  : in  std_logic_vector (N - 1 downto 0);
    CARRY_out : out std_logic_vector (N - 1 downto 0)
  );
end entity SIGN_EXTENTION_GEN;

--------------------------------------------------------------------------------

architecture BHV of SIGN_EXTENTION_GEN is
begin

  SIGN_p: process(OP_TYPE, CYCLE, Rm_MSB, CARRY_in)
  begin

    if (OP_TYPE = '1') then

      --  SIGNED MULTIPLICATION
      if (Rm_MSB = '1' and CARRY_in(1) = '0') then
        case CYCLE is
          when "00"   =>  CARRY_out <=  not CARRY_in;
          when "01"   =>  CARRY_out <=      CARRY_in(N -  1 downto N -  8) &
                                        not CARRY_in(N -  9 downto      0);
          when "10"   =>  CARRY_out <=      CARRY_in(N -  1 downto N - 16) &
                                        not CARRY_in(N - 17 downto      0);
          when "11"   =>  CARRY_out <=      CARRY_in(N -  1 downto N - 24) &
                                        not CARRY_in(N - 25 downto      0);
          when others =>  CARRY_out <=  (others => 'X');
        end case;
      elsif (Rm_MSB = '0' and CARRY_in(1) = '1') then
        CARRY_out <=  CARRY_in(N - 1 downto 1) & '1';
      elsif (Rm_MSB = '1' and CARRY_in(1) = '1') then
        CARRY_out <=  CARRY_in;
      elsif (Rm_MSB = '0' and CARRY_in(1) = '0') then
        CARRY_out <=  CARRY_in;
      end if;

    elsif (OP_TYPE = '0') then

      --  UNSIGNED MULTIPLICATION
      CARRY_out <=  CARRY_in;

    end if;

  end process SIGN_p;

end architecture BHV;