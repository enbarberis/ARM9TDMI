library ieee;
use ieee.std_logic_1164.all;

--Equal to a carry_select but doesn't generate carry out
entity CARRY_SELECT_REDUCED is
  generic(
          N: natural := 4
         );
  port(
        A: in std_logic_vector(N-1 downto 0);
        B: in std_logic_vector(N-1 downto 0);
        Ci: in std_logic;
        S:  out std_logic_vector(N-1 downto 0)
      );
end CARRY_SELECT_REDUCED;

architecture STRUCTURAL of CARRY_SELECT_REDUCED is

  component MUX21_GENERIC is
    generic(
            N : natural := 2
           );
    port(
          A: in std_logic_vector(N-1 downto 0);
          B: in std_logic_vector(N-1 downto 0);
          SEL: in std_logic;
          Y: out std_logic_vector(N-1 downto 0)
        );
  end component;

  component RCA_GENERIC is
    generic(
            N: natural := 8
          );
    port(
          A: in std_logic_vector(N-1 downto 0);
          B: in std_logic_vector(N-1 downto 0);
          Ci: in std_logic;
          S: out std_logic_vector(N-1 downto 0);
          Co: out std_logic
        );
  end component;

  signal sum0, sum1: std_logic_vector(N-1 downto 0);

begin

  RCA_0:  RCA_GENERIC
          generic map (N => N)
          port map (A=>A, B=>B, Ci=>'0', S=>sum0);

  RCA_1:  RCA_GENERIC
          generic map (N => N)
          port map (A=>A, B=>B, Ci=>'1', S=>sum1);

  MUX:    MUX21_GENERIC
          generic map (N => N)
          port map (A=>sum1, B=>sum0, SEL=>Ci, Y=>S);

end STRUCTURAL;

configuration CFG_CARRY_SELECT_REDUCED_STRUCTURAL of CARRY_SELECT_REDUCED is
  for STRUCTURAL
    for all : RCA_GENERIC
      use configuration WORK.CFG_RCA_GENERIC_STRUCTURAL;
    end for;
    for all : MUX21_GENERIC
      use configuration WORK.CFG_MUX21_GENERIC_BEHAVIORAL_1;
    end for;
  end for;
end CFG_CARRY_SELECT_REDUCED_STRUCTURAL;
