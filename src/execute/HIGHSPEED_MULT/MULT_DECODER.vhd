library IEEE;
use IEEE.std_logic_1164.all;

--------------------------------------------------------------------------------

entity MULT_DECODER is
  port (
    SIGN_SEL  : in  std_logic;                                                  --  Input from Multiplier Control Unit
                                                                                --  Selects wheter it is a signed or unsigned multiplication

    C_in      : in  std_logic;
    Rs_BITS   : in  std_logic_vector(1 downto 0);

    C_out     : out std_logic;
    Rm_SEL    : out std_logic_vector(1 downto 0);
    SHIFT_SEL : out std_logic
  );
end entity MULT_DECODER;

--------------------------------------------------------------------------------

architecture BHV of MULT_DECODER is
begin

  DECODE_p: process (SIGN_SEL, C_in, Rs_BITS)
  begin

    if (SIGN_SEL = '1') then

      --------------------------------------------------------------------
      --  SIGNED MULTIPLICATION                                         --
      --------------------------------------------------------------------

      if (C_in = '0') then

        case Rs_BITS is
          when  "00"  =>          --  Add 0
            Rm_SEL    <=  "00";
            SHIFT_SEL <=  '0';
          when  "01"  =>          --  Add Rm
            Rm_SEL    <=  "01";
            SHIFT_SEL <=  '0';
          when  "10"  =>          --  Add -Rm * 2
            Rm_SEL    <=  "10";
            SHIFT_SEL <=  '1';
          when  "11"  =>          --  Add -Rm
            Rm_SEL    <=  "10";
            SHIFT_SEL <=  '0';
          when others =>
            Rm_SEL    <=  "XX";
            SHIFT_SEL <=  'X';
        end case;

      elsif (C_in = '1') then

        case Rs_BITS is
          when  "00"  =>          --  Add Rm
            Rm_SEL    <=  "01";
            SHIFT_SEL <=  '0';
          when  "01"  =>          --  Add Rm * 2
            Rm_SEL    <=  "01";
            SHIFT_SEL <=  '1';
          when  "10"  =>          --  Add -Rm
            Rm_SEL    <=  "10";
            SHIFT_SEL <=  '0';
          when  "11"  =>          --  Add 0
            Rm_SEL    <=  "00";
            SHIFT_SEL <=  '0';
          when others =>
            Rm_SEL    <=  "XX";
            SHIFT_SEL <=  'X';
        end case;

      end if;

      case Rs_BITS is
        when  "00"  =>  C_out <= '0';
        when  "01"  =>  C_out <= '0';
        when  "10"  =>  C_out <= '1';
        when  "11"  =>  C_out <= '1';
        when others =>  C_out <= 'X';
      end case;

    elsif SIGN_SEL = '0' then

      --------------------------------------------------------------------
      --  UNSIGNED MULTIPLICATION                                       --
      --------------------------------------------------------------------

      case Rs_BITS is
        when  "00"  =>          --  Add 0
          Rm_SEL    <=  "00";
          SHIFT_SEL <=  '0';
        when  "01"  =>          --  Add Rm
          Rm_SEL    <=  "01";
          SHIFT_SEL <=  '0';
        when  "10"  =>          --  Add Rm * 2
          Rm_SEL    <=  "01";
          SHIFT_SEL <=  '1';
        when  "11"  =>          --  Add Rm * 3
          Rm_SEL    <=  "11";
          SHIFT_SEL <=  '0';
        when others =>
          Rm_SEL    <=  "XX";
          SHIFT_SEL <=  'X';
      end case;

      C_out     <=  '0';

    end if;

  end process DECODE_p;

end architecture BHV;