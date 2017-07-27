library IEEE;
use IEEE.std_logic_1164.all;  --libreria IEEE con definizione tipi standard logic

entity MUX21_GENERIC is
  generic(
          N : natural := 2
         );
  port(
        A: in std_logic_vector(N-1 downto 0);
        B: in std_logic_vector(N-1 downto 0);
        SEL: in std_logic;
        Y: out std_logic_vector(N-1 downto 0)
      );
end MUX21_GENERIC;


architecture BEHAVIORAL_1 of MUX21_GENERIC is
begin
  GA: for i in 0 to N-1 generate
    Y(i) <= (A(i) and SEL) or (B(i) and not(SEL)); -- processo implicito
  end generate;
end BEHAVIORAL_1;


architecture BEHAVIORAL_2 of MUX21_GENERIC is
begin
  Y <= A when SEL='1' else B;
end BEHAVIORAL_2;


architecture BEHAVIORAL_3 of MUX21_GENERIC is
begin
  pmux: process(A,B,Sel)
  begin
    if SEL='1' then
      Y <= A;
    else
      Y <= B;
    end if;
  end process;
end BEHAVIORAL_3;


architecture STRUCTURAL of MUX21_GENERIC is

  signal Y1: std_logic_vector(N-1 downto 0);
  signal Y2: std_logic_vector(N-1 downto 0);
  signal SB: std_logic;

  component ND2
    port(
          A: in std_logic;
          B: in std_logic;
          Y: out std_logic
        );
  end component;

  component IV
  port(
        A: in std_logic;
        Y: out std_logic
      );
  end component;

begin

  UIV : IV
  port map (SEL, SB);

  GAFND: for i in 0 to N-1 generate
    UND1: ND2 port map (A(i), SEL, Y1(i));
  end generate;

  GASND: for i in 0 to N-1 generate
    UND2: ND2 port map (B(i), SB, Y2(i));
  end generate;

  GATND: for i in 0 to N-1 generate
    UND3: ND2 port map (Y1(i), Y2(i), Y(i));
  end generate;

end STRUCTURAL;


configuration CFG_MUX21_GENERIC_BEHAVIORAL_1 of MUX21_GENERIC is
  for BEHAVIORAL_1
  end for;
end CFG_MUX21_GENERIC_BEHAVIORAL_1;

configuration CFG_MUX21_GENERIC_BEHAVIORAL_2 of MUX21_GENERIC is
  for BEHAVIORAL_2
  end for;
end CFG_MUX21_GENERIC_BEHAVIORAL_2;

configuration CFG_MUX21_GENERIC_BEHAVIORAL_3 of MUX21_GENERIC is
  for BEHAVIORAL_3
  end for;
end CFG_MUX21_GENERIC_BEHAVIORAL_3;

configuration CFG_MUX21_GENERIC_STRUCTURAL of MUX21_GENERIC is
  for STRUCTURAL

    for all : IV
      use configuration WORK.CFG_IV_BEHAVIORAL;
    end for;

    for GAFND
      for all : ND2
        use configuration WORK.CFG_ND2_ARCH1;
      end for;
    end for;

    for GASND
      for all : ND2
        use configuration WORK.CFG_ND2_ARCH1;
      end for;
    end for;

    for GATND
      for all : ND2
        use configuration WORK.CFG_ND2_ARCH1;
      end for;
    end for;

  end for;
end CFG_MUX21_GENERIC_STRUCTURAL;
