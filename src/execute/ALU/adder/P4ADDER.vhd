library IEEE;
use IEEE.std_logic_1164.all;

entity P4ADDER is
  generic(
         N: natural := 32
  );
  port(
      A: in std_logic_vector(N-1 downto 0);
      B: in std_logic_vector(N-1 downto 0);
      Ci: in std_logic;
      Co: out std_logic;
      S: out std_logic_vector(N-1 downto 0)
  );

end P4ADDER;


architecture structural of P4ADDER is


  component CARRY_GENERATOR is
    generic(
            N: natural := 32
          );
    port(
          A: in std_logic_vector(N-1 downto 0);
          B: in std_logic_vector(N-1 downto 0);
          Ci: in std_logic;
          Co: out std_logic_vector(N/4-1 downto 0)
      );
  end component carry_generator;

  component SUM_GENERATOR is
    generic(
            N_BITS: natural := 32;
            N_BLOCKS: natural := 8
          );
    port(
          A: in std_logic_vector(N_BITS-1 downto 0);
          B: in std_logic_vector(N_BITS-1 downto 0);
          Ci: in std_logic_vector(N_BLOCKS downto 0); -- N_BLOCKS beacuse also C0
          S: out std_logic_vector(N_BITS-1 downto 0);
          Co: out std_logic
        );
  end component SUM_GENERATOR;

  constant N_near_4: natural := N-(N mod 4);
  signal carry_tree_out_s: std_logic_vector(N_near_4/4-1 downto 0);
  signal carry_total_s: std_logic_vector(N/4 downto 0);

begin


  CARRY_TREE: carry_generator
              generic map(
                N => N_near_4
              )
              port map(
                A => A(N_near_4 - 1 downto 0),
                B => B(N_near_4 - 1 downto 0),
                Ci => Ci,
                Co => carry_tree_out_s
              );

  P4_CARRY_SELECT: sum_generator
                   generic map(
                     N_BITS => N,
                     N_BLOCKS => N/4
                   )
                   port map(
                     A => A,
                     B => B,
                     Ci => carry_total_s,
                     S => S,
                     Co => Co
                   );

  carry_total_s <= carry_tree_out_s & Ci;

end structural;

configuration CFG_P4ADDER_STRUCTURAL of p4adder is
  for structural
    for all: sum_generator
      use configuration WORK.CFG_SUM_GENERATOR_STRUCTURAL;
    end for;
  end for;
end CFG_P4ADDER_STRUCTURAL;
