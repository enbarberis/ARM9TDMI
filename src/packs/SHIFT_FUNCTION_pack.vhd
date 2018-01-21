library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

library WORK;
use WORK.ARM_pack.all;

package SHIFT_FUNCTION_pack is

  function Logical_Shift_Left     (DATA_IN  : DATA_BUS_t;
                                   SHIFT    : SHIFT_BUS_t)
                                   return     DATA_BUS_t;

  function Logical_Shift_Right    (DATA_IN  : DATA_BUS_t;
                                   SHIFT    : SHIFT_BUS_t)
                                   return     DATA_BUS_t;

  function Arithmetic_Shift_Right (DATA_IN  : DATA_BUS_t;
                                   SHIFT    : SHIFT_BUS_t)
                                   return     DATA_BUS_t;

  function Rotate_Right           (DATA_IN  : DATA_BUS_t;
                                   SHIFT    : SHIFT_BUS_t)
                                   return     DATA_BUS_t;



end SHIFT_FUNCTION_pack;

package body SHIFT_FUNCTION_pack is

  -- Logic Shift Left --------------------------------------------------------
  function Logical_Shift_Left (DATA_IN : DATA_BUS_t; SHIFT : SHIFT_BUS_t)
  return DATA_BUS_t is

    variable nSHIFT   : integer range 0 to 32;
    variable DATA_OUT : DATA_BUS_t  := DATA_IN;

  begin

    nSHIFT   := to_integer(unsigned(SHIFT));
    Shift_Left : for i in 1 to nSHIFT loop
      DATA_OUT := DATA_OUT(30 downto 0) & '0';
    end loop;

    return DATA_OUT;

  end function Logical_Shift_Left;

  -- Logic Shift Right -------------------------------------------------------
  function Logical_Shift_Right (DATA_IN : DATA_BUS_t; SHIFT : SHIFT_BUS_t)
  return DATA_BUS_t is

    variable nSHIFT   : integer range 0 to 32;
    variable DATA_OUT : DATA_BUS_t  := DATA_IN;

  begin

    nSHIFT   := to_integer(unsigned(SHIFT));
    Shift_Right : for i in 1 to nSHIFT loop
      DATA_OUT := '0' & DATA_OUT(31 downto 1);
    end loop;

    return DATA_OUT;

  end function Logical_Shift_Right;

  -- Arithmetic Shift Right --------------------------------------------------
  function Arithmetic_Shift_Right (DATA_IN : DATA_BUS_t; SHIFT : SHIFT_BUS_t)
  return DATA_BUS_t is

    variable nSHIFT   : integer range 0 to 32;
    variable DATA_OUT : DATA_BUS_t  := DATA_IN;

  begin

    nSHIFT   := to_integer(unsigned(SHIFT));
    A_Shift_Right : for i in 1 to nSHIFT loop
      DATA_OUT := DATA_OUT(31) & DATA_OUT(31 downto 1);
    end loop;

    return DATA_OUT;

  end function Arithmetic_Shift_Right;

  -- Rotate Right ------------------------------------------------------------
  function Rotate_Right (DATA_IN : DATA_BUS_t; SHIFT : SHIFT_BUS_t)
  return DATA_BUS_t is

    variable nSHIFT   : integer range 0 to 32;
    variable DATA_OUT : DATA_BUS_t  := DATA_IN;

  begin

    nSHIFT   := to_integer(unsigned(SHIFT)) mod 32;
    Rotate : for i in 1 to nSHIFT loop
      DATA_OUT := DATA_OUT(0) & DATA_OUT(31 downto 1);
    end loop;

    return DATA_OUT;

  end function Rotate_Right;


end SHIFT_FUNCTION_pack;
