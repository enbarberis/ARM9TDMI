library IEEE;
use IEEE.std_logic_1164.all;

library WORK;
use WORK.ARM_pack.all;

entity LOGIC_UNIT is
  port (

    -- DATA BUS
    A_DATA_in   : in  DATA_BUS_t;
    B_DATA_in   : in  DATA_BUS_t;
    R_DATA_out  : out DATA_BUS_t;

    -- COMMAND SIGNALS
    OP_SELECT   : in  std_logic_vector (3 downto 0)

  );
end entity LOGIC_UNIT;

architecture BHV of LOGIC_UNIT is

  signal  A_DATA_neg  : DATA_BUS_t;
  signal  B_DATA_neg  : DATA_BUS_t;

  signal  L0_temp     : DATA_BUS_t;
  signal  L1_temp     : DATA_BUS_t;
  signal  L2_temp     : DATA_BUS_t;
  signal  L3_temp     : DATA_BUS_t;

  signal  S0_ext      : DATA_BUS_t;
  signal  S1_ext      : DATA_BUS_t;
  signal  S2_ext      : DATA_BUS_t;
  signal  S3_ext      : DATA_BUS_t;

begin

  A_DATA_neg  <=  not A_DATA_in;
  B_DATA_neg  <=  not B_DATA_in;

  S0_ext      <=  (others => OP_SELECT(3));
  S1_ext      <=  (others => OP_SELECT(2));
  S2_ext      <=  (others => OP_SELECT(1));
  S3_ext      <=  (others => OP_SELECT(0));

  L0_temp     <=  not((A_DATA_neg and B_DATA_neg) and S0_ext);                  -- MAY BE ELIMINATED: NEVER USED
  L1_temp     <=  not((A_DATA_neg and B_DATA_in ) and S1_ext);
  L2_temp     <=  not((A_DATA_in  and B_DATA_neg) and S2_ext);
  L3_temp     <=  not((A_DATA_in  and B_DATA_in ) and S3_ext);

  R_DATA_out  <=  not((L0_temp and L1_temp) and (L2_temp and L3_temp));
--R_DATA_out  <=  not(L1_temp and L2_temp and L3_temp);

end architecture BHV;
