library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.ARM_pack.all;
use WORK.MATH_FUNCTION_pack.all;

--------------------------------------------------------------------------------

entity HIGHSPEED_MULT is
  port (

    --  CLOCK, RESET, ENABLE SIGNALS
    nRST                : in  std_logic;
    CLK                 : in  std_logic;
    MULT_EN             : in  std_logic;

    --  CONTROL SIGNALS
    SIGNED_nUNSIGNED    : in  std_logic;
    CYCLE_COUNT         : in  std_logic_vector (1 downto 0);
    EARLY_FINISH        : out std_logic;
    HiLo_REG_SEL        : in  std_logic;

    --  INTERNAL REGISTERS 
    W_EN_Rm             : in  std_logic;
    W_EN_Rs             : in  std_logic;
    W_EN_SUM            : in  std_logic;

    nRST_SUM            : in  std_logic;
    nRST_CARRY          : in  std_logic;

    --  INPUT DATA BUSSES
    W_DATA_1            : in  DATA_BUS_t;
    W_DATA_2            : in  DATA_BUS_t;

    --  OUTPUT DATA BUSSES
    R_DATA_SUM          : out DATA_BUS_t;
    R_DATA_CARRY        : out DATA_BUS_t

  );
end entity HIGHSPEED_MULT;

--------------------------------------------------------------------------------

architecture STR of HIGHSPEED_MULT is

  ----------------------------------------------------------------------------
  --  COMPONENTS                                                            --
  ----------------------------------------------------------------------------

  component CSA_GEN is
    generic ( N : natural := 32 );
    port (
      A_DATA_in   : in  std_logic_vector (N-1 downto 0);
      B_DATA_in   : in  std_logic_vector (N-1 downto 0);
      C_DATA_in   : in  std_logic_vector (N-1 downto 0);
      S_DATA_out  : out std_logic_vector (N-1 downto 0);
      C_DATA_out  : out std_logic_vector (N-1 downto 0)
    );
  end component CSA_GEN;

  component REG_NEGEDGE_GEN is
    generic ( N : natural := 32 );
    port (
      CLK   : in  std_logic;
      nRST  : in  std_logic;
      EN    : in  std_logic;
      D     : in  std_logic_vector (N-1 downto 0);
      Q     : out std_logic_vector (N-1 downto 0)
    );
  end component REG_NEGEDGE_GEN;

  component LSR8_REG32 is
    port (
      nRST      : in  std_logic; 
      CLK       : in  std_logic;

      R_DATA    : out std_logic_vector (31 downto 0); 
      W_EN      : in  std_logic; 
      W_DATA    : in  std_logic_vector (31 downto 0);

      LSR_FILL  : in  std_logic;
      LSR_EN    : in  std_logic
    );
  end component LSR8_REG32;

  component D_FF is
    port (
      CLK   : in  std_logic;
      nRST  : in  std_logic;
      EN    : in  std_logic;
      D     : in  std_logic;
      Q     : out std_logic
    );
  end component D_FF;

  component MULT_DECODER is
    port (
      SIGN_SEL  : in  std_logic;
      C_in      : in  std_logic;
      Rs_BITS   : in  std_logic_vector(1 downto 0);
      C_out     : out std_logic;
      Rm_SEL    : out std_logic_vector(1 downto 0);
      SHIFT_SEL : out std_logic
    );
  end component MULT_DECODER;

  component MUX21_GEN is
    generic ( N : natural := 32 );
    port (
      A : in  std_logic_vector (N-1 downto 0);
      B : in  std_logic_vector (N-1 downto 0);
      S : in  std_logic;
      Y : out std_logic_vector (N-1 downto 0)
    );
  end component MUX21_GEN;

  component MUX41_GEN is
    generic ( N : natural := 32 );
    port (
      A : in  std_logic_vector (N-1 downto 0);
      B : in  std_logic_vector (N-1 downto 0);
      C : in  std_logic_vector (N-1 downto 0);
      D : in  std_logic_vector (N-1 downto 0);
      S : in  std_logic_vector (  1 downto 0);
      Y : out std_logic_vector (N-1 downto 0)
    );
  end component MUX41_GEN;

  component INVERTER_GEN is
    generic ( N : natural := 32 );
    port (
      A : in  std_logic_vector (N-1 downto 0);
      Y : out std_logic_vector (N-1 downto 0)
    );
  end component INVERTER_GEN;

  component Rmx3_GENERATOR_GEN is
    generic ( N : natural := 32 );
    port (
      Rm    : in  std_logic_vector (N-1 downto 0);
      Rmx3  : out std_logic_vector (N-1 downto 0)
    );
  end component Rmx3_GENERATOR_GEN;

  component SIGN_EXTENTION_GEN is
    generic ( N : natural := 32 );
    port (
      OP_TYPE   : in  std_logic;
      CYCLE     : in  std_logic_vector (    1 downto 0);
      Rm_MSB    : in  std_logic;
      CARRY_in  : in  std_logic_vector (N - 1 downto 0);
      CARRY_out : out std_logic_vector (N - 1 downto 0)
    );
  end component SIGN_EXTENTION_GEN;

  ----------------------------------------------------------------------------
  --  TYPES                                                                 --
  ----------------------------------------------------------------------------

  subtype DATA_EXT_BUS_t  is  std_logic_vector (33 downto 0);
  type    BUS_MATRIX_t    is  array (0 to 4) of DATA_BUSx2_t;
  type    CARRY_TEMP_t    is  array (0 to 3) of DATA_BUSx2_t;
  type    Rm_t            is  array (0 to 3) of DATA_EXT_BUS_t;
  type    STAGE_2BIT_t    is  array (0 to 3) of std_logic_vector ( 1 downto 0);
  type    STAGE_1BIT_t    is  array (0 to 3) of std_logic;
  type    LINE_VECTOR_t   is  array (0 to 4) of std_logic;

  ----------------------------------------------------------------------------
  --  CONSTANTS                                                             --
  ----------------------------------------------------------------------------

  constant  ZEROS       : DATA_EXT_BUS_t  :=  (others => '0');
  constant  ZEROSx2     : DATA_BUSx2_t    :=  (others => '0');
  constant  ONES        : DATA_BUS_t      :=  (others => '1');

  ----------------------------------------------------------------------------
  --  SIGNALS                                                               --
  ----------------------------------------------------------------------------

  signal  nRST_S        ,
          nRST_C        ,
          W_EN_S        ,
          W_EN_C        ,
          Rs_SH_EN      ,
          Rs_FILL       ,
			 W_EN_Rmx3		,
          EF_int        : std_logic;

  signal  Rs_out        : DATA_BUS_t;
  signal  Rs_BITS       : STAGE_2BIT_t;

  signal  Rm_SEL        : STAGE_2BIT_t;
  signal  Rm_SH_SEL     : STAGE_1BIT_t;
  signal  Rm_EXT        ,
          Rm_EXT_SH     ,
          Rm            : Rm_t;

  signal  Rm_EXT_in     ,
          Rm_EXT_out    ,
          Rm_EXT_x3_tmp ,
          Rm_EXT_x3     ,
          Rm_EXT_neg    : DATA_EXT_BUS_t;

  signal  W_DATA        ,
          SUM_in        ,
          SUM_out       ,
          SUM_align     ,
          CARRY_in      ,
          CARRY_out     ,
          CARRY_align   : DATA_BUSx2_t;

  signal  C             : LINE_VECTOR_t;
  signal  C_tmp         : STAGE_1BIT_t;
  signal  C_int         : CARRY_TEMP_t;

  signal  SUM           ,
          CARRY         : BUS_MATRIX_t;

begin

  ----------------------------------------------------------------------------
  --  SUM / CARRY REGISTER INSTANTIATION                                    --
  ----------------------------------------------------------------------------

  nRST_S    <=  nRST and nRST_SUM;
  nRST_C    <=  nRST and nRST_CARRY;
  W_EN_S    <=  MULT_EN or W_EN_SUM;
  W_EN_C    <=  MULT_EN;

  W_DATA    <=  W_DATA_2 & W_DATA_1;
  SUM_in    <=  W_DATA when W_EN_SUM = '1' else
                SUM  (4)(7 downto 0) & SUM  (4)(63 downto 8);
  CARRY_in  <=  CARRY(4)(7 downto 0) & CARRY(4)(63 downto 8);

  SUM_REG   : REG_NEGEDGE_GEN
    generic map ( N => 64 )
    port    map ( CLK   =>  CLK     ,
                  nRST  =>  nRST_S  ,
                  EN    =>  W_EN_S  ,
                  D     =>  SUM_in  ,
                  Q     =>  SUM_out );

  CARRY_REG : REG_NEGEDGE_GEN
    generic map ( N => 64 )
    port    map ( CLK   =>  CLK       ,
                  nRST  =>  nRST_C    ,
                  EN    =>  W_EN_C    ,
                  D     =>  CARRY_in  ,
                  Q     =>  CARRY_out );

  C_FF      : D_FF
    port    map ( CLK   =>  CLK     ,
                  nRST  =>  nRST    ,
                  EN    =>  MULT_EN ,
                  D     =>  C(4)    ,
                  Q     =>  C(0)    );


  ----------------------------------------------------------------------------
  --  Rm / Rs REGISTER INSTANTIATION                                        --
  ----------------------------------------------------------------------------

  Rm_EXT_in   <=  "11" & W_DATA_1 when  SIGNED_nUNSIGNED  = '1' and
                                        W_DATA_1 (31)     = '1' else
                  "00" & W_DATA_1;

  Rm_REG  : REG_NEGEDGE_GEN
    generic map ( N => 34 )
    port    map ( CLK   =>  CLK       ,
                  nRST  =>  nRST      ,
                  EN    =>  W_EN_Rm   ,
                  D     =>  Rm_EXT_in ,
                  Q     =>  Rm_EXT_out);

  Rs_SH_EN  <=  MULT_EN    and not EF_int;
  Rs_FILL   <=  Rs_out(31) and SIGNED_nUNSIGNED;	--TODO CHECK 32 -> 31

  Rs_REG  : LSR8_REG32
    port    map ( CLK       =>  CLK     ,
                  nRST      =>  nRST    ,
                  W_EN      =>  W_EN_Rs ,
                  W_DATA    =>  W_DATA_2,
                  R_DATA    =>  Rs_out  ,
                  LSR_FILL  =>  Rs_FILL ,
                  LSR_EN    =>  Rs_SH_EN);

  EF_int        <=  OR_REDUCE(Rs_out) or not AND_REDUCE(Rs_out);                --  Early termination signal generation
  EARLY_FINISH  <=  EF_int;


  ----------------------------------------------------------------------------
  --  Rm GENERATION                                                         --
  ----------------------------------------------------------------------------

  Rm_INV    : INVERTER_GEN
    generic map ( N => 34 )
    port    map ( Rm_EXT_out,
                  Rm_EXT_neg);

  Rm_x3_GEN : Rmx3_GENERATOR_GEN
    generic map ( N => 34 )
    port    map ( Rm_EXT_out    ,
                  Rm_EXT_x3_tmp );

  --  Using the partiacl carry reset signal (inverted) as write enable for the
  --  Rm x 3 register, since is active only during the second init cycle of the
  --  multiplier
  W_EN_Rmx3 <=  not nRST_CARRY;
  Rm_x3_REG : REG_NEGEDGE_GEN
    generic map ( N => 34 )
    port    map ( CLK   =>  CLK           ,
                  nRST  =>  nRST          ,
                  EN    =>  W_EN_Rmx3     ,
                  D     =>  Rm_EXT_x3_tmp ,
                  Q     =>  Rm_EXT_x3     );

  ----------------------------------------------------------------------------
  --  STAGE GENERATION                                                      --
  ----------------------------------------------------------------------------

  SUM(0)      <=  SUM_out;
  CARRY(0)    <=  CARRY_out;

  STAGE_n:  for I in 0 to 3 generate

    Rs_BITS(I)  <=  Rs_out((2 * I + 1) downto (2 * I));

    DECODER : MULT_DECODER
      port    map ( SIGN_SEL    =>  SIGNED_nUNSIGNED,
                    C_in        =>  C(I)            ,
                    Rs_BITS     =>  Rs_BITS(I)      ,
                    C_out       =>  C(I+1)          ,
                    Rm_SEL      =>  Rm_SEL(I)       ,
                    SHIFT_SEL   =>  Rm_SH_SEL(I)    );

    Rm_MUX  : MUX41_GEN
      generic map ( N => 34 )
      port    map ( A           =>  ZEROS     ,
                    B           =>  Rm_EXT_out,
                    C           =>  Rm_EXT_neg,
                    D           =>  Rm_EXT_x3 ,
                    S           =>  Rm_SEL(I) ,
                    Y           =>  Rm_EXT(I) );

    Rm_EXT_SH(I)  <=  Rm_EXT(I)(32 downto 0) & "0";

    Rm_SH   : MUX21_GEN
      generic map ( N => 34 )
      port    map ( A           =>  Rm_EXT   (I),
                    B           =>  Rm_EXT_SH(I),
                    S           =>  Rm_SH_SEL(I),
                    Y           =>  Rm       (I));

    CSA     : CSA_GEN
      generic map ( N => 34 )
      port    map ( A_DATA_in   =>  SUM  (I)  ((33 + 2*I) downto (2*I))     ,
                    B_DATA_in   =>  CARRY(I)  ((33 + 2*I) downto (2*I))     ,
                    C_DATA_in   =>  Rm   (I)                                ,
                    S_DATA_out  =>  SUM  (I+1)((33 + 2*I) downto (2*I))     ,
                    C_DATA_out  =>  C_int(I)  ((34 + 2*I) downto (2*I + 1)) );
    SUM  (I+1)(63 downto (34 + 2*I))  <=  SUM  (I)(63 downto (34 + 2*I));

    C_int(I)  (63 downto (35 + 2*I))  <=  CARRY(I)(63 downto (35 + 2*I));
    C_int(I)  (2*I downto 0)          <=  CARRY(I)(2*I downto 0);
    CARRY(I+1)(2*I)  <=  '0';
    CARRY(I+1)((33 + 2*I) downto (2*I + 1)) <=  C_int(I)((33 + 2*I) downto (2*I + 1));

    SIGN    : SIGN_EXTENTION_GEN
      generic map ( N => (30 - 2*I) )
      port    map ( OP_TYPE   =>  SIGNED_nUNSIGNED                ,
                    CYCLE     =>  CYCLE_COUNT                     ,
                    Rm_MSB    =>  Rm   (I)  (33)                  ,
                    CARRY_in  =>  C_int(I)  (63 downto (34 + 2*I)),
                    CARRY_out =>  CARRY(I+1)(63 downto (34 + 2*I)));

  end generate STAGE_n;

  --  LOWER BITS FORWARDING
  SUM  (2)(1 downto 0)  <=  SUM  (1)(1 downto 0);
  SUM  (3)(3 downto 0)  <=  SUM  (2)(3 downto 0);
  SUM  (4)(5 downto 0)  <=  SUM  (3)(5 downto 0);
  --CARRY(1)(0 downto 0)  <=  CARRY(0)(0 downto 0);
  CARRY(2)(1 downto 0)  <=  CARRY(1)(1 downto 0);
  CARRY(3)(3 downto 0)  <=  CARRY(2)(3 downto 0);
  CARRY(4)(5 downto 0)  <=  CARRY(3)(5 downto 0);


  ----------------------------------------------------------------------------
  --  OUTPUT DATA ALIGNMENT & PROPAGATION                                   --
  ----------------------------------------------------------------------------

  SUM_align     <=  SUM_in(55 downto 0) & SUM_in(63 downto 56) when CYCLE_COUNT = "00" else
                    SUM_in(47 downto 0) & SUM_in(63 downto 48) when CYCLE_COUNT = "01" else
                    SUM_in(39 downto 0) & SUM_in(63 downto 40) when CYCLE_COUNT = "10" else
                    SUM_in(31 downto 0) & SUM_in(63 downto 32) when CYCLE_COUNT = "11" else
                    (others => 'X');

  CARRY_align   <=  CARRY_in(55 downto 0) & CARRY_in(63 downto 57) & '0' when CYCLE_COUNT = "00" else
                    CARRY_in(47 downto 0) & CARRY_in(63 downto 49) & '0' when CYCLE_COUNT = "01" else
                    CARRY_in(39 downto 0) & CARRY_in(63 downto 41) & '0' when CYCLE_COUNT = "10" else
                    CARRY_in(31 downto 0) & CARRY_in(63 downto 33) & '0' when CYCLE_COUNT = "11" else
                    (others => 'X');

  R_DATA_SUM    <=  SUM_align(31 downto  0) when HiLo_REG_SEL = '0' else
                    SUM_align(63 downto 32) when HiLo_REG_SEL = '1' else
                    (others => 'X');
  
  R_DATA_CARRY  <=  CARRY_align(31 downto  0) when HiLo_REG_SEL = '0' else
                    CARRY_align(63 downto 32) when HiLo_REG_SEL = '1' else
                    (others => 'X');

end architecture STR;
