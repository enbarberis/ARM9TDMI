library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.ARM_pack.all;
use WORK.SHIFT_FUNCTION_pack.all;

entity BARREL_SHIFTER is
  port (
    B_BUS_in    : in  DATA_BUS_t;
    B_BUS_out   : out DATA_BUS_t;
    C_FLAG_in   : in  std_logic;
    C_FLAG_out  : out std_logic;
    SH_AMOUNT   : in  SHIFT_BUS_t;
    SHIFT_OP    : in  SHIFT_OP_t;
    IMMEDIATE   : in  std_logic
  );
end entity;

architecture BHV of BARREL_SHIFTER is

begin

  MAIN : process(B_BUS_in, C_FLAG_in, SH_AMOUNT, SHIFT_OP, IMMEDIATE)

    variable  nSHIFT_AMOUNT : natural := 0;

  begin

    nSHIFT_AMOUNT := to_integer(unsigned(SH_AMOUNT));
    
    case (SHIFT_OP) is

      when SLL_OP =>
        if nSHIFT_AMOUNT = 0 then
          B_BUS_out   <=  B_BUS_in;
          C_FLAG_out  <=  C_FLAG_in;
        elsif nSHIFT_AMOUNT < 33 then
          B_BUS_out   <=  Logical_Shift_Left(B_BUS_in, SH_AMOUNT);
          C_FLAG_out  <=  B_BUS_in(32 - nSHIFT_AMOUNT);
        else
          B_BUS_out   <=  (others => '0');
          C_FLAG_out  <=  '0';
        end if;

      when SLR_OP =>
        if nSHIFT_AMOUNT = 0 then
          if IMMEDIATE = '1' then
            B_BUS_out   <=  (others => '0');
            C_FLAG_out  <=  B_BUS_in(31);
          else
            B_BUS_out   <=  B_BUS_in;
            C_FLAG_out  <=  C_FLAG_in;
          end if;
        elsif nSHIFT_AMOUNT < 33 then
          B_BUS_out   <=  Logical_Shift_Right(B_BUS_in, SH_AMOUNT);
          C_FLAG_out  <=  B_BUS_in(nSHIFT_AMOUNT - 1);
        else
          B_BUS_out   <=  (others => '0');
          C_FLAG_out  <=  '0';
        end if;

      when SAR_OP =>
        if nSHIFT_AMOUNT = 0 then
          if IMMEDIATE = '1' then
            B_BUS_out   <=  (others => B_BUS_in(31));
            C_FLAG_out  <=  B_BUS_in(31);
          else
            B_BUS_out   <=  B_BUS_in;
            C_FLAG_out  <=  C_FLAG_in;
          end if;
        elsif nSHIFT_AMOUNT < 32 then
          B_BUS_out   <=  Arithmetic_Shift_Right(B_BUS_in, SH_AMOUNT);
          C_FLAG_out  <=  B_BUS_in(nSHIFT_AMOUNT - 1);
        else
          B_BUS_out   <=  (others => B_BUS_in(31));
          C_FLAG_out  <=  B_BUS_in(31);
        end if;

      when ROR_OP =>
        if nSHIFT_AMOUNT = 0 then
          if IMMEDIATE = '1' then
            -- Perform an Extended Rotate with Carry
            B_BUS_out   <=  C_FLAG_in & B_BUS_in(31 downto 1);
            C_FLAG_out  <=  B_BUS_in(0);
          else
            B_BUS_out   <=  B_BUS_in;
            C_FLAG_out  <=  C_FLAG_in;
          end if;
        elsif (nSHIFT_AMOUNT mod 32) = 0 then
          B_BUS_out   <=  B_BUS_in;
          C_FLAG_out  <=  B_BUS_in(31);
        else
          B_BUS_out   <=  Rotate_Right(B_BUS_in, SH_AMOUNT);
          C_FLAG_out  <=  B_BUS_in((nSHIFT_AMOUNT mod 32) - 1);
        end if;

      when others =>

    end case;

  end process;

end architecture;
