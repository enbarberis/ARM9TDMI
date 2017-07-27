library ieee;
use ieee.std_logic_1164.all;

entity SUM_GENERATOR is
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
end SUM_GENERATOR;

architecture STRUCTURAL of SUM_GENERATOR is

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

  component CARRY_SELECT_REDUCED is
    generic(
            N: natural := 4
          );
    port(
          A: in std_logic_vector(N-1 downto 0);
          B: in std_logic_vector(N-1 downto 0);
          Ci: in std_logic;
          S:  out std_logic_vector(N-1 downto 0)
        );
  end component;

  component CARRY_SELECT is
    generic(
            N: natural := 4
          );
    port(
          A: in std_logic_vector(N-1 downto 0);
          B: in std_logic_vector(N-1 downto 0);
          Ci: in std_logic;
          S:  out std_logic_vector(N-1 downto 0);
          Co: out std_logic
        );
  end component;

  constant BLOCK_SIZE: natural := N_BITS/N_BLOCKS;
  constant EXTRA_BITS: natural := N_BITS mod N_BLOCKS;

begin

  --N_BLOCKS + 1 iterations to manage in the last cycle
  --the presence of extra bits
  CS_GEN: for i in 0 to N_BLOCKS generate

    --Instead of generating a carry select for the first block
    --a rca is used to reduce the total area
    FIRST_BLOCK: if i = 0 generate
      CS_0:   RCA_GENERIC
              generic map (N => BLOCK_SIZE)
              port map (A => A(BLOCK_SIZE-1 downto 0),
                        B => B(BLOCK_SIZE-1 downto 0),
                        Ci => Ci(0),
                        S => S(BLOCK_SIZE-1 downto 0)
                      );
    end generate FIRST_BLOCK;

    I_BLOCK: if i>0 and i<N_BLOCKS generate
      CS_I: CARRY_SELECT_REDUCED
            generic map (N => BLOCK_SIZE)
            port map (A => A( ((i+1)*BLOCK_SIZE-1) downto (i*BLOCK_SIZE) ),
                      B => B( ((i+1)*BLOCK_SIZE-1) downto (i*BLOCK_SIZE) ),
                      Ci => Ci(i),
                      S => S( ((i+1)*BLOCK_SIZE-1) downto (i*BLOCK_SIZE) )
                     );
    end generate I_BLOCK;

    LAST_BLOCK: if i = N_BLOCKS generate

      NO_FINAL_CS: if EXTRA_BITS = 0 generate
        Co <= Ci(N_BLOCKS);
      end generate NO_FINAL_CS;

      FINAL_CS: if EXTRA_BITS > 0 generate
        CS_N:  CARRY_SELECT
                generic map (N => EXTRA_BITS)
                port map (A => A(N_BITS-1 downto N_BITS-EXTRA_BITS),
                          B => B(N_BITS-1 downto N_BITS-EXTRA_BITS),
                          Ci => Ci(N_BLOCKS),
                          S => S(N_BITS-1 downto N_BITS-EXTRA_BITS),
                          Co => Co
                        );
      end generate FINAL_CS;

    end generate LAST_BLOCK;

  end generate CS_GEN;

end STRUCTURAL;


configuration CFG_SUM_GENERATOR_STRUCTURAL of SUM_GENERATOR is
  for STRUCTURAL
    for CS_GEN
      for FIRST_BLOCK
        for all: RCA_GENERIC
          use configuration WORK.CFG_RCA_GENERIC_STRUCTURAL;
        end for;
      end for;
      for I_BLOCK
        for all : CARRY_SELECT_REDUCED
          use configuration WORK.CFG_CARRY_SELECT_REDUCED_STRUCTURAL;
        end for;
      end for;
      for LAST_BLOCK
        for FINAL_CS
          for all : CARRY_SELECT
            use configuration WORK.CFG_CARRY_SELECT_STRUCTURAL;
          end for;
        end for;
      end for;
    end for;
  end for;
end CFG_SUM_GENERATOR_STRUCTURAL;
