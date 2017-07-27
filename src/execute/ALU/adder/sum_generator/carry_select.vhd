library ieee;
use ieee.std_logic_1164.all;

entity CARRY_SELECT is
  generic(
          N: natural := 4
         );
  port(
        A: in std_logic_vector(N-1 downto 0);
        B: in std_logic_vector(N-1 downto 0);
        Ci: in std_logic;
        S: out std_logic_vector(N-1 downto 0);
        Co: out std_logic
      );
end CARRY_SELECT;

architecture STRUCTURAL of CARRY_SELECT is

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
  signal cout0, cout1: std_logic_vector(0 downto 0);  --std_logic_vector needed by mux port
  signal Co_s: std_logic_vector(0 downto 0);          --needed to convert

begin

  RCA_0:  RCA_GENERIC
          generic map (N => N)
          port map (A=>A, B=>B, Ci=>'0', S=>sum0, Co=>cout0(0));

  RCA_1:  RCA_GENERIC
          generic map (N => N)
          port map (A=>A, B=>B, Ci=>'1', S=>sum1, Co=>cout1(0));

  MUX_S:  MUX21_GENERIC
          generic map (N => N)
          port map (A=>sum1, B=>sum0, SEL=>Ci, Y=>S);

  MUX_C:  MUX21_GENERIC
          generic map (N => 1)
          port map (A=>cout1, B=>cout0, SEL=>Ci, Y=>Co_s);

  Co <= Co_s(0);

end STRUCTURAL;

configuration CFG_CARRY_SELECT_STRUCTURAL of CARRY_SELECT is
  for STRUCTURAL
    for all : RCA_GENERIC
      use configuration WORK.CFG_RCA_GENERIC_STRUCTURAL;
    end for;
    for all : MUX21_GENERIC
      use configuration WORK.CFG_MUX21_GENERIC_BEHAVIORAL_1;
    end for;
  end for;
end CFG_CARRY_SELECT_STRUCTURAL;
