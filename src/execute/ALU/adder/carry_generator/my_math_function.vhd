package my_math_function is
 function my_log2(i: natural) return integer;
end my_math_function;

package body my_math_function is 
  function my_log2( i : natural) return integer is
    variable temp    : integer := i;
    variable ret_val : integer := 1; 
  begin
    temp := 1;
    while( 2*temp  < i ) loop
      temp := 2*temp;
      ret_val := ret_val + 1;
    end loop;
    return ret_val;
  end function my_log2;

end my_math_function;
