library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.ARM_pack.all;

--------------------------------------------------------------------------------

entity TO_BE_EXE is
  port (
    OPCODE      : in DATA_PROC_OP_t;
    N,C,Z,V     : in std_logic;
    TO_BE_EXE   : out std_logic
  );
end entity TO_BE_EXE;

--------------------------------------------------------------------------------

architecture BHV of TO_BE_EXE is

begin

main:  process (OPCODE, N, C, Z, V)
  begin

    TO_BE_EXE <= '0';

    case OPCODE is
      when EQ     =>  if (Z = '1') then
                        TO_BE_EXE <= '1';
                      end if;

      when NE     =>  if (Z = '0') then
                        TO_BE_EXE <= '1';
                      end if;

      when CS_HS  =>  if (C = '1') then
                        TO_BE_EXE <= '1';
                      end if;

      when CC_LO  =>  if (C = '0') then
                        TO_BE_EXE <= '1';
                      end if;

      when MI     =>  if (N = '1') then
                        TO_BE_EXE <= '1';
                      end if;

      when PL     =>  if (N = '0') then
                        TO_BE_EXE <= '1';
                      end if;

      when VS     =>  if (V = '1') then
                        TO_BE_EXE <= '1';
                      end if;

      when VC     =>  if (V = '0') then
                        TO_BE_EXE <= '1';
                      end if;

      when HI     =>  if (C = '1' and Z = '0') then
                        TO_BE_EXE <= '1';
                      end if;

      when LS     =>  if (C = '0' or Z = '1') then
                        TO_BE_EXE <= '1';
                      end if;

      when GE     =>  if ( N = V ) then
                        TO_BE_EXE <= '1';
                      end if;

      when LT     =>  if ( N /= V) then
                        TO_BE_EXE <= '1';
                      end if;

      when GT     =>  if ( (Z = '0') and (N = V) ) then
                        TO_BE_EXE <= '1';
                      end if;

      when LE     =>  if ( (Z = '1') or (N /= V) ) then
                        TO_BE_EXE <= '1';
                      end if;

      when AL     =>  TO_BE_EXE <= '1';

      when others =>  TO_BE_EXE <= '0';

    end case;
  end process;

end architecture BHV;
