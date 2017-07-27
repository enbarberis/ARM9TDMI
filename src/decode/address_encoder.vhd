library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_misc.all;

--------------------------------------------------------------------------------

entity address_encoder is
  port (
    clk                 : in  std_logic;
    nRst                : in  std_logic;
    ext_register_list   : in  std_logic_vector(15 downto 0);
    int_op              : in  std_logic;
    enable              : in  std_logic;
    zero_flag           : out std_logic;
    next_reg_addr       : out std_logic_vector(3 downto 0)
  );
end entity ;

--------------------------------------------------------------------------------

architecture BHV of address_encoder is

  component priority_encoder is
    port (
      decoded_value : in  std_logic_vector(15 downto 0);
      mask          : out std_logic_vector(15 downto 0);
      value         : out std_logic_vector( 3 downto 0)
    );
  end component priority_encoder;

  signal str_register_list: std_logic_vector(15 downto 0);
  signal mask_s: std_logic_vector(15 downto 0);
  signal nxt_reg_list_s: std_logic_vector(15 downto 0);
  signal int_register_list: std_logic_vector(15 downto 0);
begin

  process(clk,nRst)
  begin
    if ( nRst = '0' ) then
      str_register_list <= ( others => '0' );
    elsif ( clk = '1' and clk'event ) then
      if ( enable = '1' or int_op = '1' ) then
        str_register_list <= nxt_reg_list_s;
      end if;
    end if;
  end process;


  int_register_list <=  ext_register_list when int_op = '0' else
                        str_register_list;

  PRIOR_ENC:  priority_encoder
              port map (
                decoded_value => int_register_list,
                mask          => mask_s,
                value         => next_reg_addr);

  nxt_reg_list_s <= int_register_list xor mask_s;
  zero_flag <= nor_reduce(nxt_reg_list_s);

end architecture BHV;
