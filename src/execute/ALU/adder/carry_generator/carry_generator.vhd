library ieee;
use ieee.std_logic_1164.all;
use WORK.my_math_function.all;


entity carry_generator is
  generic(
          N: natural := 32
         );
  port(
        A: in std_logic_vector(N-1 downto 0);
        B: in std_logic_vector(N-1 downto 0);
        Ci: in std_logic;
        Co: out std_logic_vector(N/4-1 downto 0)
      );
end entity carry_generator;


architecture structural of carry_generator is

  component pg is
    port(
          A: in std_logic;
          B: in std_logic;
          P: out std_logic;
          G: out std_logic
        );
  end component pg;

  component general_g is
    port(
          G_ik: in std_logic;
          P_ik: in std_logic;
          G_k_1_j: in std_logic;
          G_ij: out std_logic
        );
  end component general_g;

  component general_pg is
    port(
          G_ik: in std_logic;
          P_ik: in std_logic;
          G_k_1_j: in std_logic;
          P_k_1_j: in std_logic;
          P_ij: out std_logic;
          G_ij: out std_logic
        );
  end component general_pg;

  type MATRIX is array(N downto 1) of std_logic_vector(N downto 1);
  signal p_mat_s: MATRIX;
  signal g_mat_s: MATRIX;
  signal first_p,first_g: std_logic;
  constant ceil_log2_N: integer := my_log2(N); 
begin

  PG_GEN: for i in 0 to N-1 generate
    FIRST_PG_AND_G: if i = 0 generate
      U0: pg
          port map(
            A => A(0),
            B => B(0),
            P => first_p,
            G => first_g
          );
      G10: general_g
           port map(
           G_ik => first_g,
           P_ik => first_p,
           G_k_1_j => Ci,
           G_ij => g_mat_s(1)(1)
           );
    end generate FIRST_PG_AND_G;
    PGII: if i > 0 generate
      UI: pg
          port map(
            A => A(i),
            B => B(i),
            P => p_mat_s(i+1)(i+1),
            G => g_mat_s(i+1)(i+1)
          );
    end generate PGII;
  end generate PG_GEN;

  POW_2_EXPLORATION: for i in 1 to ceil_log2_N generate
    F_S_LAYERS: if i <= 2 generate
      F_S_DIAG_EXPLORATION: for k in 0 to (N - (2**i)) generate
        F_S_GEN_CASE: if k = 0 generate
          G_PO2: general_g
                 port map(
                   g_mat_s(2**i)((2**(i-1)) + 1),
                   p_mat_s(2**i)((2**(i-1)) + 1),
                   g_mat_s(2**(i-1))(1),
                   g_mat_s(2**i)(1)
                 );
        end generate F_S_GEN_CASE;
        F_S_PG_CASE: if ((k > 0) and (k mod (2**i) = 0)) generate
          PG_1: general_pg
                port map(
                  G_ij => g_mat_s((2**i) + k)(1+k),
                  P_ij => p_mat_s((2**i) + k)(1+k),
                  G_k_1_j => g_mat_s((2**(i-1)) + k)(1+k),
                  P_k_1_j => p_mat_s((2**(i-1)) + k)(1+k),
                  G_ik => g_mat_s((2**i) + k)((2**(i-1)) + k + 1),
                  P_ik => p_mat_s((2**i) + k)((2**(i-1)) + k + 1)
                );
        end generate F_S_PG_CASE;
      end generate F_S_DIAG_EXPLORATION;
    end generate F_S_LAYERS;
    FIN: if i >= 3 generate 
      OTHER_LAYERS: for j in 0 to ((2**(i-3)) - 1) generate
        OTHER_DIAG_EXPLORATION: for k in 0 to (N - ((2**i) - 4*j)) generate
          OTHER_GEN_CASE: if k = 0 generate
            OTHER_G_PO2: general_g
                  port map(
                    G_ij => g_mat_s((2**i) - 4*j)(1),
                    G_ik => g_mat_s((2**i) - 4*j)((2**(i-1)) + 1),
                    P_ik => p_mat_s((2**i) - 4*j)((2**(i-1)) + 1),
                    G_k_1_j => g_mat_s(2**(i-1))(1)
                  );
          end generate OTHER_GEN_CASE;
          OTHER_PG_CASE: if ((k > 0) and (k mod (2**i) = 0)) generate
            OTHER_PG: general_pg
                  port map(
                    G_ij => g_mat_s((2**i) - 4*j + k)(1+k),
                    P_ij => p_mat_s((2**i) - 4*j + k)(1+k),
                    G_k_1_j => g_mat_s((2**(i-1)) + k)(1+k),
                    P_k_1_j => p_mat_s((2**(i-1)) + k)(1+k),
                    G_ik => g_mat_s((2**i) - 4*j + k)((2**(i-1)) + k + 1),
                    P_ik => p_mat_s((2**i) - 4*j + k)((2**(i-1)) + k + 1)
                  );
          end generate OTHER_PG_CASE;
        end generate OTHER_DIAG_EXPLORATION;
      end generate OTHER_LAYERS;
    end generate FIN;
  end generate POW_2_EXPLORATION;

  EXT_CONNECTION: for i in 1 to N/4 generate
    Co(i-1) <= g_mat_s(4*i)(1);
  end generate EXT_CONNECTION;

end structural;


