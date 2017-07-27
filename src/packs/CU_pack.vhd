library IEEE;
use IEEE.std_logic_1164.all;

library WORK;

package CU_pack is

  constant ALWAYS_EXECUTED: std_logic_vector(3 downto 0) := "1110";
  constant NEVER_EXECUTED : std_logic_vector(3 downto 0) := "1111";
  constant ADD            : std_logic_vector(3 downto 0) := "0100";
  constant SUT            : std_logic_vector(3 downto 0) := "0010";
  constant IMM            : std_logic := '0';
  constant SEQ_ACCESS     : std_logic_vector(1 downto 0) := "00";
  constant IA_FROM_MEMORY : std_logic_vector(1 downto 0) := "11";
  --  EXECUTE BUS SELECTION TYPES
  type      CU_STATE_t    is (DISPATCHER      ,
                              FETCH_FILL      ,
                              RESET_STATE     ,
                              LINK_BRANCH     ,
                              JUMP            ,
                              JUMP_RESET      ,
                              LDM_1_CORR_SUB  ,
                              LDM_N_CORR_SUB  ,
                              LDM_1_CORR_ADD  ,
                              LDM_N_CORR_ADD  ,
                              LDM_N_WAIT      ,
                              PC_LD_SPSR      ,
                              PC_LD_EXE       ,
                              PC_LD_MEM       ,
                              PC_LD_WB        ,
                              STM_1_CORR_SUB  ,
                              STM_1_CORR_ADD  ,
                              STM_N_CORR_SUB  ,
                              STM_N_CORR_ADD  ,
                              STM_N_WAIT      ,
                              SWAP_STR        ,
                              MUL_WIP         ,
                              MUL_SUM_LOW     ,
                              MUL_SUM_HIGH    ,
                              MODE_UPDATE_EXE ,
                              MODE_UPDATE_NXT ,
                              ERROR_STATE     );

end package CU_pack;
