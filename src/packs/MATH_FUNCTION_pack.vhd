package MATH_FUNCTION_pack is

  function  max   (X, Y : natural) return natural;
  function  min   (X, Y : natural) return natural;
  function  log2  (X    : natural) return natural;
  function  div   (X, Y : natural) return natural;

end MATH_FUNCTION_pack;


package body MATH_FUNCTION_pack is

  ----------------------------------------------------------------------------
  --  MATH FUNCTIONS                                                        --
  ----------------------------------------------------------------------------

  function  max   (X, Y : natural) return natural is
  begin
    if (X > Y) then
      return X;
    else
      return Y;
    end if;
  end function max;

  function  min   (X, Y : natural) return natural is
  begin
    if (X < Y) then
      return X;
    else
      return Y;
    end if;
  end function min;

  function  log2  (X : natural) return natural is
    variable  I, J : natural := 0;
  begin
    I := 0;
    J := 1;
    while (J < X) loop
      J := J * 2;
      I := I + 1;
    end loop;
    return  I;
  end function log2;

  function  div   (X, Y : natural) return natural is
    variable  I, J : natural := 0;
  begin
    I := 0;
    J := 0;
    --  Division: ceil(X / Y)
    while (J < X) loop
      J := J + Y;
      I := I + 1;
    end loop;
    return  I;
  end function div;

end MATH_FUNCTION_pack;
