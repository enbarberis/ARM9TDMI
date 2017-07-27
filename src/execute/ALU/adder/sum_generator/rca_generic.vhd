library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity RCA_GENERIC is
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
end RCA_GENERIC;

architecture STRUCTURAL of RCA_GENERIC is

  signal STMP : std_logic_vector(N-1 downto 0);
  signal CTMP : std_logic_vector(N downto 0);

  component FA
  port(
        A: in std_logic;
        B: in std_logic;
        Ci: in std_logic;
        S: out std_logic;
        Co: out std_logic
      );
  end component;

begin

  CTMP(0) <= Ci;
  S <= STMP;
  Co <= CTMP(N);

  ADDER1: for I in 0 to N-1 generate
    FAI : FA
    Port Map (A(I), B(I), CTMP(I), STMP(I), CTMP(I+1));
  end generate;

end STRUCTURAL;


architecture BEHAVIORAL of RCA_GENERIC is
begin

  process(A,B,Ci)
    -- Use variable in order to avoid extra FA during synthesis
    variable STMP: std_logic_vector(N downto 0);
  begin
    STMP := ('0' & A ) + ('0' & B) + Ci;
    S <= STMP(N-1 downto 0);  -- The sum are the lowest significant bits of the internal signals
    Co <= STMP(N);            -- The carry is the MSB of the internal signal
  end process;
end BEHAVIORAL;

configuration CFG_RCA_GENERIC_STRUCTURAL of RCA_GENERIC is
  for STRUCTURAL
    for ADDER1
      for all : FA
        use configuration WORK.CFG_FA_BEHAVIORAL;
      end for;
    end for;
  end for;
end CFG_RCA_GENERIC_STRUCTURAL;

configuration CFG_RCA_GENERIC_BEHAVIORAL of RCA_GENERIC is
  for BEHAVIORAL
  end for;
end CFG_RCA_GENERIC_BEHAVIORAL;
