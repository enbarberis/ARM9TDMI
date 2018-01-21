library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
--use IEEE.numeric_std.all;
use WORK.ARM_pack.all;
use WORK.CU_pack.all;
use WORK.DECODE_pack.all;

entity control_unit is
  port (
    clk                     : in  std_logic;
    nRst                    : in  std_logic;
    irq                     : in  std_logic;
    fiq                     : in  std_logic;
    prefetch_abort          : in  std_logic;
    data_abort              : in  std_logic;
    instruction             : in  std_logic_vector(31 downto 0);
    to_be_exe               : in  std_logic;
    end_mul                 : in  std_logic;
    stall                   : in  std_logic;
---------------------------------------------------------------------
--                      REGISTER_FILE
---------------------------------------------------------------------
    addr_rdA                : out std_logic_vector(3 downto 0);
    addr_rdB                : out std_logic_vector(3 downto 0);
    addr_rdC                : out std_logic_vector(3 downto 0);
    addr_wrA                : out std_logic_vector(3 downto 0);
    addr_wrB                : out std_logic_vector(3 downto 0);
    en_wrA                  : out std_logic;
    en_wrB                  : out std_logic;
    en_rdA                  : out std_logic;
    en_rdB                  : out std_logic;
    en_rdC                  : out std_logic;
  --usr_wrB                 : out std_logic;
---------------------------------------------------------------------
--                      FORWARDING UNIT
---------------------------------------------------------------------
    exe_addr_wrA            : out std_logic_vector(3 downto 0);
    mem_addr_wrA            : out std_logic_vector(3 downto 0);
    exe_en_wrA              : out std_logic;
    mem_en_wrA              : out std_logic;
    exe_addr_wrB            : out std_logic_vector(3 downto 0);
    mem_addr_wrB            : out std_logic_vector(3 downto 0);
    exe_en_wrB              : out std_logic;
    mem_en_wrB              : out std_logic;
    en_rdPSR                : out std_logic;
    CPSR_nSPSR              : out std_logic;
    imm_inst                : out std_logic;
    immediate_value         : out std_logic_vector(31 downto 0);
---------------------------------------------------------------------
--                      BARREL SHIFTER
---------------------------------------------------------------------
    shift_amount            : out SHIFT_BUS_t;
    shifter_opcode          : out std_logic_vector(1 downto 0);
    src_shift_amnt          : out std_logic;
    shift_imm               : out std_logic;
---------------------------------------------------------------------
--                      MEMORY SYSTEM
---------------------------------------------------------------------
    Mdata_src_addr          : out std_logic_vector(1 downto 0);
    Mdata_src_addr_nxt      : out std_logic_vector(1 downto 0);
    Mdata_src_out           : out std_logic;
    Mdata_dim               : out std_logic_vector(1 downto 0);
    Mdata_sign              : out std_logic;
    Mdata_en                : out std_logic;
    Mdata_en_nxt            : out std_logic;
    Mdata_rd_nWr            : out std_logic;
---------------------------------------------------------------------
--                      BYTE WORD REPLICATION
---------------------------------------------------------------------
    str_Mdata_dim           : out std_logic_vector(1 downto 0);
---------------------------------------------------------------------
--                      BYTE ROT SIGN EXTENSION
---------------------------------------------------------------------
    ld_Mdata_dim            : out std_logic_vector(1 downto 0);
    ld_Mdata_sign           : out std_logic;
---------------------------------------------------------------------
--                      TO_BE_EXE UNIT
---------------------------------------------------------------------
    alu_opcode              : out std_logic_vector(3 downto 0);
    cond_code               : out std_logic_vector(3 downto 0);
---------------------------------------------------------------------
--                      SPSR
---------------------------------------------------------------------
    src_nxt_SPSR            : out std_logic;
    wr_SPSR_high            : out std_logic;
    wr_SPSR_low             : out std_logic;
---------------------------------------------------------------------
--                      CPSR
---------------------------------------------------------------------
    wr_high_cpsr            : out std_logic;
    src_high_CPSR           : out std_logic_vector(1 downto 0);
    wr_low_cpsr             : out std_logic;
---------------------------------------------------------------------
--                      NXT_CPSR
---------------------------------------------------------------------
    src_nxt_CPSR            : out std_logic_vector(1 downto 0);
    wr_nxt_cpsr             : out std_logic;
---------------------------------------------------------------------
--                      MULT
---------------------------------------------------------------------
    en_mult                 : out std_logic;
    signed_nUnsigned_mult   : out std_logic;
    HiLo_reg_src_mult       : out std_logic;
    wr_Rm_mult              : out std_logic;
    wr_Rs_mult              : out std_logic;
    wr_sum_mult             : out std_logic;
    nRst_sum_mult           : out std_logic;
    nRst_carry_mult         : out std_logic;
    addition_mult           : out std_logic;
---------------------------------------------------------------------
--                      LOAD FOR IA AND FETCH/DEC REG. PIPE
---------------------------------------------------------------------
    wr_IA                   : out std_logic;
    wr_IR                   : out std_logic;
    src_nxt_IA              : out std_logic_vector(1 downto 0);
    vt_addr                 : out std_logic_vector(2 downto 0)
  );
end entity ;

--------------------------------------------------------------------------------

architecture STRUCTURAL of control_unit is

  component CU_FSM is
    port (
--------------------------------------------------------------------------------
      nRST                        : in  std_logic                     ;
      CLK                         : in  std_logic                     ;
--------------------------------------------------------------------------------
      pc_dest_or_mul_32           : in  std_logic                     ;
      state_update                : in  std_logic                     ;
      end_mul                     : in  std_logic                     ;
      decode_next_state           : in  CU_STATE_t                    ;
      to_be_exe                   : in  std_logic                     ;
      stall                       : in  std_logic                     ;
      zero_multiple_reg           : in  std_logic                     ;
--------------------------------------------------------------------------------
      dec_wr_IR                   : out std_logic                     ;
      dec_wr_IA                   : out std_logic                     ;
      who_is_in_charge            : out std_logic                     ;
--------------------------------------------------------------------------------
      dec_en_rdA                  : out std_logic                     ;
      dec_en_rdB                  : out std_logic                     ;
      dec_addr_wrA                : out std_logic_vector(3 downto 0)  ;
      dec_addr_wrB                : out std_logic_vector(3 downto 0)  ;
      dec_en_wrB                  : out std_logic                     ;
      dec_en_wrA                  : out std_logic                     ;
      dec_en_rdPSR                : out std_logic                     ;
      dec_CPSR_nSPSR              : out std_logic                     ;
      dec_addr_rdC                : out std_logic_vector(3 downto 0)  ;
      dec_en_rdC                  : out std_logic                     ;
      dec_imm_inst                : out std_logic                     ;
      dec_immediate_value         : out std_logic_vector(31 downto 0) ;
      dec_shift_amount            : out SHIFT_BUS_t                   ;
      dec_shifter_opcode          : out std_logic_vector(1 downto 0)  ;
      dec_src_shift_amnt          : out std_logic                     ;
      dec_shift_imm               : out std_logic                     ;
      dec_Mdata_src_addr          : out std_logic_vector(1 downto 0)  ;
      dec_Mdata_dim               : out std_logic_vector(1 downto 0)  ;
      dec_Mdata_src_out           : out std_logic                     ;
      dec_Mdata_sign              : out std_logic                     ;
      dec_Mdata_en                : out std_logic                     ;
      dec_Mdata_rd_nWr            : out std_logic                     ;
      dec_alu_opcode              : out std_logic_vector(3 downto 0)  ;
      dec_cond_code               : out std_logic_vector(3 downto 0)  ;
      dec_src_nxt_SPSR            : out std_logic                     ;
      dec_wr_SPSR_high            : out std_logic                     ;
      dec_wr_SPSR_low             : out std_logic                     ;
      dec_wr_high_CPSR            : out std_logic                     ;
      dec_wr_low_CPSR             : out std_logic                     ;
      dec_wr_nxt_cpsr             : out std_logic                     ;
      dec_src_nxt_CPSR            : out std_logic_vector(1 downto 0)  ;
      dec_en_mult                 : out std_logic                     ;
      dec_signed_nUnsigned_mult   : out std_logic                     ;
      dec_HiLo_reg_src_mult       : out std_logic                     ;
      dec_wr_Rm_mult              : out std_logic                     ;
      dec_wr_Rs_mult              : out std_logic                     ;
      dec_wr_sum_mult             : out std_logic                     ;
      dec_nRst_sum_mult           : out std_logic                     ;
      dec_nRst_carry_mult         : out std_logic                     ;
      dec_vt_addr                 : out std_logic_vector(2 downto 0)  ;
      dec_src_nxt_IA              : out std_logic_vector(1 downto 0)  ;
      dec_addition_mult           : out std_logic                     ;
      dec_src_high_CPSR           : out std_logic_vector(1 downto 0)
    );
  end component CU_FSM;


  component decode_table is
    port (
      irq                         : in  std_logic                     ;
      fiq                         : in  std_logic                     ;
      prefetch_abort              : in  std_logic                     ;
      data_abort                  : in  std_logic                     ;
      nRst                        : in  std_logic                     ;
      instruction                 : in  std_logic_vector(31 downto 0) ;
--------------------------------------------------------------------------------
      zero_flag                   : in  std_logic                     ;
      number_of_registers         : in  std_logic_vector(3 downto 0)  ;
      number_of_registers_dec     : in  std_logic_vector(3 downto 0)  ;
      next_reg_addr               : in  std_logic_vector(3 downto 0)  ;
--------------------------------------------------------------------------------
      int_op_nxt_reg_logic        : out std_logic                     ;
      en_nxt_reg_logic            : out std_logic                     ;
      ld_reg_bitmap               : out std_logic                     ;
      dec_nxt_state               : out CU_STATE_t                    ;
      ld_pc_dest_or_mul_32        : out std_logic                     ;
      pc_dest_or_mul_32           : out std_logic                     ;
      ld_state_update             : out std_logic                     ;
      state_update                : out std_logic                     ;
--------------------------------------------------------------------------------
      dec_addr_rdA                : out std_logic_vector(3 downto 0)  ;
      dec_en_rdA                  : out std_logic                     ;
      dec_addr_rdB                : out std_logic_vector(3 downto 0)  ;
      dec_en_rdB                  : out std_logic                     ;
      dec_addr_wrA                : out std_logic_vector(3 downto 0)  ;
      dec_addr_wrB                : out std_logic_vector(3 downto 0)  ;
      dec_en_wrB                  : out std_logic                     ;
      dec_en_wrA                  : out std_logic                     ;
      dec_en_rdPSR                : out std_logic                     ;
      dec_CPSR_nSPSR              : out std_logic                     ;
      dec_addr_rdC                : out std_logic_vector(3 downto 0)  ;
      dec_en_rdC                  : out std_logic                     ;
      dec_imm_inst                : out std_logic                     ;
      dec_immediate_value         : out std_logic_vector(31 downto 0) ;
      dec_shift_amount            : out SHIFT_BUS_t;
      dec_shifter_opcode          : out std_logic_vector(1 downto 0)  ;
      dec_src_shift_amnt          : out std_logic                     ;
      dec_shift_imm               : out std_logic                     ;
      dec_Mdata_src_addr          : out std_logic_vector(1 downto 0)  ;
      dec_Mdata_dim               : out std_logic_vector(1 downto 0)  ;
      dec_Mdata_src_out           : out std_logic                     ;
      dec_Mdata_sign              : out std_logic                     ;
      dec_Mdata_en                : out std_logic                     ;
      dec_Mdata_rd_nWr            : out std_logic                     ;
      dec_alu_opcode              : out std_logic_vector(3 downto 0)  ;
      dec_cond_code               : out std_logic_vector(3 downto 0)  ;
      dec_src_nxt_SPSR            : out std_logic                     ;
      dec_wr_SPSR_high            : out std_logic                     ;
      dec_wr_SPSR_low             : out std_logic                     ;
      dec_wr_high_CPSR            : out std_logic                     ;
      dec_wr_low_CPSR             : out std_logic                     ;
      dec_wr_nxt_cpsr             : out std_logic                     ;
      dec_src_nxt_CPSR            : out std_logic_vector(1 downto 0)  ;
      dec_en_mult                 : out std_logic                     ;
      dec_signed_nUnsigned_mult   : out std_logic                     ;
      dec_HiLo_reg_src_mult       : out std_logic                     ;
      dec_wr_Rm_mult              : out std_logic                     ;
      dec_wr_Rs_mult              : out std_logic                     ;
      dec_wr_sum_mult             : out std_logic                     ;
      dec_nRst_sum_mult           : out std_logic                     ;
      dec_nRst_carry_mult         : out std_logic                     ;
      dec_vt_addr                 : out std_logic_vector(2 downto 0)  ;
      dec_src_nxt_IA              : out std_logic_vector(1 downto 0)  ;
      dec_addition_mult           : out std_logic                     ;
      dec_src_high_CPSR           : out std_logic_vector(1 downto 0)
    );
  end component decode_table;



  component D_FF is
    port (
      CLK   : in  std_logic;
      nRST  : in  std_logic;
      EN    : in  std_logic;
      D     : in  std_logic;
      Q     : out std_logic
    );
  end component D_FF;

  component DFF  is
    port (
      D     : in  std_logic;
      Q     : out std_logic;
      clk   : in std_logic;
      nRst  : in std_logic
    );
  end component DFF;

  component LOAD_REG_NEGEDGE_GEN is
    generic (N : natural := 32);
    port (
      CLK   : in  std_logic;
      nRST  : in  std_logic;
      LD    : in  std_logic;
      D     : in  std_logic_vector (N-1 downto 0);
      Q     : out std_logic_vector (N-1 downto 0)
    );
  end component LOAD_REG_NEGEDGE_GEN;

  component REG_NEGEDGE_GEN_ACTIVE is
    generic (N : natural := 32);
    port (
      CLK   : in  std_logic;
      nRST  : in  std_logic;
      D     : in  std_logic_vector (N-1 downto 0);
      Q     : out std_logic_vector (N-1 downto 0)
    );
  end component;

  component address_encoder is
    port (
      clk                 : in  std_logic;
      nRst                : in  std_logic;
      ext_register_list   : in  std_logic_vector(15 downto 0);
      int_op              : in  std_logic;
      enable              : in  std_logic;
      zero_flag           : out std_logic;
      next_reg_addr       : out std_logic_vector(3 downto 0)
    );
  end component address_encoder;

  component count_one is
    port (
      decoded_value : in  std_logic_vector(15 downto 0);
      value         : out std_logic_vector( 3 downto 0)
    );
  end component count_one;


-------------------------------------------------------------------------------
--                     SIGNAL CU FSM
-------------------------------------------------------------------------------

  signal  dec_wr_IR_f                  : std_logic                     ;
  signal  dec_wr_IA_f                  : std_logic                     ;
  signal  who_is_in_charge             : std_logic                     ;
  signal  dec_en_rdA_f                 : std_logic                     ;
  signal  dec_en_rdB_f                 : std_logic                     ;
  signal  dec_addr_wrA_f               : std_logic_vector(3 downto 0)  ;
  signal  dec_addr_wrB_f               : std_logic_vector(3 downto 0)  ;
  signal  dec_en_wrB_f                 : std_logic                     ;
  signal  dec_en_wrA_f                 : std_logic                     ;
  signal  dec_en_rdPSR_f               : std_logic                     ;
  signal  dec_CPSR_nSPSR_f             : std_logic                     ;
  signal  dec_addr_rdC_f               : std_logic_vector(3 downto 0)  ;
  signal  dec_en_rdC_f                 : std_logic                     ;
  signal  dec_imm_inst_f               : std_logic                     ;
  signal  dec_immediate_value_f        : std_logic_vector(31 downto 0) ;
  signal  dec_shift_amount_f           : SHIFT_BUS_t                   ;
  signal  dec_shifter_opcode_f         : std_logic_vector(1 downto 0)  ;
  signal  dec_src_shift_amnt_f         : std_logic                     ;
  signal  dec_shift_imm_f              : std_logic                     ;
  signal  dec_Mdata_src_addr_f         : std_logic_vector(1 downto 0)  ;
  signal  dec_Mdata_dim_f              : std_logic_vector(1 downto 0)  ;
  signal  dec_Mdata_src_out_f          : std_logic                     ;
  signal  dec_Mdata_sign_f             : std_logic                     ;
  signal  dec_Mdata_en_f               : std_logic                     ;
  signal  dec_Mdata_rd_nWr_f           : std_logic                     ;
  signal  dec_alu_opcode_f             : std_logic_vector(3 downto 0)  ;
  signal  dec_cond_code_f              : std_logic_vector(3 downto 0)  ;
  signal  dec_src_nxt_SPSR_f           : std_logic                     ;
  signal  dec_wr_SPSR_high_f           : std_logic                     ;
  signal  dec_wr_SPSR_low_f            : std_logic                     ;
  signal  dec_wr_high_CPSR_f           : std_logic                     ;
  signal  dec_wr_low_CPSR_f            : std_logic                     ;
  signal  dec_wr_nxt_cpsr_f            : std_logic                     ;
  signal  dec_src_nxt_CPSR_f           : std_logic_vector(1 downto 0)  ;
  signal  dec_en_mult_f                : std_logic                     ;
  signal  dec_signed_nUnsigned_mult_f  : std_logic                     ;
  signal  dec_HiLo_reg_src_mult_f      : std_logic                     ;
  signal  dec_wr_Rm_mult_f             : std_logic                     ;
  signal  dec_wr_Rs_mult_f             : std_logic                     ;
  signal  dec_wr_sum_mult_f            : std_logic                     ;
  signal  dec_nRst_sum_mult_f          : std_logic                     ;
  signal  dec_nRst_carry_mult_f        : std_logic                     ;
  signal  dec_vt_addr_f                : std_logic_vector(2 downto 0)  ;
  signal  dec_src_nxt_IA_f             : std_logic_vector(1 downto 0)  ;
  signal  dec_addition_mult_f          : std_logic                     ;
  signal  dec_src_high_CPSR_f          : std_logic_vector(1 downto 0)  ;

-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
--                     SIGNAL DECODE TABLE
-------------------------------------------------------------------------------
  signal  dec_addr_rdA_t              : std_logic_vector(3 downto 0)  ;
  signal  dec_en_rdA_t                : std_logic                     ;
  signal  dec_addr_rdB_t              : std_logic_vector(3 downto 0)  ;
  signal  dec_en_rdB_t                : std_logic                     ;
  signal  dec_addr_wrA_t              : std_logic_vector(3 downto 0)  ;
  signal  dec_addr_wrB_t              : std_logic_vector(3 downto 0)  ;
  signal  dec_en_wrB_t                : std_logic                     ;
  signal  dec_en_wrA_t                : std_logic                     ;
  signal  dec_en_rdPSR_t              : std_logic                     ;
  signal  dec_CPSR_nSPSR_t            : std_logic                     ;
  signal  dec_addr_rdC_t              : std_logic_vector(3 downto 0)  ;
  signal  dec_en_rdC_t                : std_logic                     ;
  signal  dec_imm_inst_t              : std_logic                     ;
  signal  dec_immediate_value_t       : std_logic_vector(31 downto 0) ;
  signal  dec_shift_amount_t          : SHIFT_BUS_t                   ;
  signal  dec_shifter_opcode_t        : std_logic_vector(1 downto 0)  ;
  signal  dec_src_shift_amnt_t        : std_logic                     ;
  signal  dec_shift_imm_t             : std_logic                     ;
  signal  dec_Mdata_src_addr_t        : std_logic_vector(1 downto 0)  ;
  signal  dec_Mdata_dim_t             : std_logic_vector(1 downto 0)  ;
  signal  dec_Mdata_src_out_t         : std_logic                     ;
  signal  dec_Mdata_sign_t            : std_logic                     ;
  signal  dec_Mdata_en_t              : std_logic                     ;
  signal  dec_Mdata_rd_nWr_t          : std_logic                     ;
  signal  dec_alu_opcode_t            : std_logic_vector(3 downto 0)  ;
  signal  dec_cond_code_t             : std_logic_vector(3 downto 0)  ;
  signal  dec_src_nxt_SPSR_t          : std_logic                     ;
  signal  dec_wr_SPSR_high_t          : std_logic                     ;
  signal  dec_wr_SPSR_low_t           : std_logic                     ;
  signal  dec_wr_high_CPSR_t          : std_logic                     ;
  signal  dec_wr_low_CPSR_t           : std_logic                     ;
  signal  dec_wr_nxt_cpsr_t           : std_logic                     ;
  signal  dec_src_nxt_CPSR_t          : std_logic_vector(1 downto 0)  ;
  signal  dec_en_mult_t               : std_logic                     ;
  signal  dec_signed_nUnsigned_mult_t : std_logic                     ;
  signal  dec_HiLo_reg_src_mult_t     : std_logic                     ;
  signal  dec_wr_Rm_mult_t            : std_logic                     ;
  signal  dec_wr_Rs_mult_t            : std_logic                     ;
  signal  dec_wr_sum_mult_t           : std_logic                     ;
  signal  dec_nRst_sum_mult_t         : std_logic                     ;
  signal  dec_nRst_carry_mult_t       : std_logic                     ;
  signal  dec_vt_addr_t               : std_logic_vector(2 downto 0)  ;
  signal  dec_src_nxt_IA_t            : std_logic_vector(1 downto 0)  ;
  signal  dec_addition_mult_t         : std_logic                     ;
  signal  dec_src_high_CPSR_t         : std_logic_vector(1 downto 0)  ;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--                     OTHER INPUT FOR UNITS INSIDE CU
-------------------------------------------------------------------------------
  signal  zero_flag_nxt_reg_logic     :  std_logic                    ;
  signal  addr_nxt_reg_logic          :  std_logic_vector(3 downto 0) ;
  signal  stored_reg_bitmap           :  std_logic_vector(15 downto 0);
  signal  number_of_registers         :  std_logic_vector( 3 downto 0);
  signal  number_of_registers_dec     :  std_logic_vector( 3 downto 0);
-------------------------------------------------------------------------------
  signal  dec_nxt_state               :  CU_state_t                   ;
  signal  ld_reg_bitmap               :  std_logic                    ;
  signal  int_op_nxt_reg_logic        :  std_logic                    ;
  signal  en_nxt_reg_logic            :  std_logic                    ;
  signal  ld_pc_Dest_or_mul_32        :  std_logic                    ;
  signal  ld_state_update             :  std_logic                    ;
  signal  pc_dest_or_mul_32           :  std_logic                    ;
  signal  state_update                :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  pc_dest_or_mul_32_Q         :  std_logic                    ;
  signal  state_update_Q              :  std_logic                    ;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--                          SIGNAL TO GO OUTSIDE
-------------------------------------------------------------------------------
  signal  dec_addr_rdA                :  std_logic_vector(3 downto 0) ;
  signal  dec_en_rdA                  :  std_logic                    ;
  signal  dec_addr_rdB                :  std_logic_vector(3 downto 0) ;
  signal  dec_en_rdB                  :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_addr_wrA                :  std_logic_vector(3 downto 0) ;
  signal  exe_addr_wrA_Q              :  std_logic_vector(3 downto 0) ;
  signal  mem_addr_wrA_Q              :  std_logic_vector(3 downto 0) ;
  signal  wb_addr_wrA                 :  std_logic_vector(3 downto 0) ;
-------------------------------------------------------------------------------
  signal  dec_addr_wrB                :  std_logic_vector(3 downto 0) ;
  signal  exe_addr_wrB_Q              :  std_logic_vector(3 downto 0) ;
  signal  mem_addr_wrB_Q              :  std_logic_vector(3 downto 0) ;
  signal  wb_addr_wrB                 :  std_logic_vector(3 downto 0) ;
-------------------------------------------------------------------------------
  signal  dec_en_wrB                  :  std_logic                    ;
  signal  exe_en_wrB_s                :  std_logic                    ;
  signal  exe_en_wrB_Q                :  std_logic                    ;
  signal  mem_en_wrB_Q                :  std_logic                    ;
  signal  wb_en_wrB                   :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_en_wrA                  :  std_logic                    ;
  signal  exe_en_wrA_s                :  std_logic                    ;
  signal  exe_en_wrA_Q                :  std_logic                    ;
  signal  mem_en_wrA_Q                :  std_logic                    ;
  signal  wb_en_wrA                   :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_en_rdPSR                :  std_logic                    ;
  signal  dec_CPSR_nSPSR              :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_addr_rdC                :  std_logic_vector(3 downto 0) ;
  signal  exe_addr_rdC                :  std_logic_vector(3 downto 0) ;
  signal  mem_addr_rdC                :  std_logic_vector(3 downto 0) ;
  signal  dec_en_rdC                  :  std_logic                    ;
  signal  exe_en_rdC_s                :  std_logic                    ;
  signal  exe_en_rdC                  :  std_logic                    ;
  signal  mem_en_rdC                  :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_imm_inst                :  std_logic                    ;
  signal  dec_immediate_value         :  std_logic_vector(31 downto 0);
-------------------------------------------------------------------------------
  signal  dec_shift_amount            :  SHIFT_BUS_t                  ;
  signal  exe_shift_amount            :  SHIFT_BUS_t                   ;
  signal  dec_shifter_opcode          :  std_logic_vector(1 downto 0) ;
  signal  exe_shifter_opcode          :  std_logic_vector(1 downto 0) ;
  signal  dec_src_shift_amnt          :  std_logic                    ;
  signal  exe_src_shift_amnt          :  std_logic                    ;
  signal  dec_shift_imm               :  std_logic                    ;
  signal  exe_shift_imm               :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_Mdata_src_addr          :  std_logic_vector(1 downto 0) ;
  signal  exe_Mdata_src_addr          :  std_logic_vector(1 downto 0) ;
-------------------------------------------------------------------------------
  signal  dec_Mdata_dim               :  std_logic_vector(1 downto 0) ;
  signal  exe_Mdata_dim               :  std_logic_vector(1 downto 0) ;
  signal  mem_Mdata_dim               :  std_logic_vector(1 downto 0) ;
  signal  wb_Mdata_dim                :  std_logic_vector(1 downto 0) ;
-------------------------------------------------------------------------------
  signal  dec_Mdata_src_out           :  std_logic                    ;
  signal  exe_Mdata_src_out           :  std_logic                    ;
  signal  mem_Mdata_src_out           :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_Mdata_sign              :  std_logic                    ;
  signal  exe_Mdata_sign              :  std_logic                    ;
  signal  mem_Mdata_sign              :  std_logic                    ;
  signal  wb_Mdata_sign               :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_Mdata_en                :  std_logic                    ;
  signal  exe_Mdata_en_s              :  std_logic                    ;
  signal  exe_Mdata_en                :  std_logic                    ;
  signal  mem_Mdata_en                :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_Mdata_rd_nWr            :  std_logic                    ;
  signal  exe_Mdata_rd_nWr            :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_alu_opcode              :  std_logic_vector(3 downto 0) ;
  signal  exe_alu_opcode              :  std_logic_vector(3 downto 0) ;
  signal  dec_cond_code               :  std_logic_vector(3 downto 0) ;
  signal  exe_cond_code               :  std_logic_vector(3 downto 0) ;
-------------------------------------------------------------------------------
  signal  dec_src_nxt_SPSR            :  std_logic                    ;
  signal  exe_src_nxt_SPSR            :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_wr_SPSR_high            :  std_logic                    ;
  signal  exe_wr_SPSR_high_s          :  std_logic                    ;
  signal  exe_wr_SPSR_high            :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_wr_SPSR_low             :  std_logic                    ;
  signal  exe_wr_SPSR_low_s           :  std_logic                    ;
  signal  exe_wr_SPSR_low             :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_wr_high_CPSR            :  std_logic                    ;
  signal  exe_wr_high_CPSR_s          :  std_logic                    ;
  signal  exe_wr_high_CPSR            :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_wr_low_CPSR             :  std_logic                    ;
  signal  exe_wr_low_CPSR_s           :  std_logic                    ;
  signal  exe_wr_low_CPSR             :  std_logic                    ;
  signal  mem_wr_low_CPSR             :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_wr_nxt_cpsr             :  std_logic                    ;
  signal  exe_wr_nxt_CPSR_s           :  std_logic                    ;
  signal  exe_wr_nxt_CPSR             :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_src_nxt_CPSR            :  std_logic_vector(1 downto 0) ;
  signal  exe_src_nxt_CPSR            :  std_logic_vector(1 downto 0) ;
-------------------------------------------------------------------------------
  signal  dec_en_mult                 :  std_logic                    ;
  signal  dec_signed_nUnsigned_mult   :  std_logic                    ;
  signal  dec_HiLo_reg_src_mult       :  std_logic                    ;
  signal  dec_wr_Rm_mult              :  std_logic                    ;
  signal  dec_wr_Rs_mult              :  std_logic                    ;
  signal  dec_wr_sum_mult             :  std_logic                    ;
  signal  dec_nRst_sum_mult           :  std_logic                    ;
  signal  dec_nRst_carry_mult         :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_vt_addr                 :  std_logic_vector(2 downto 0) ;
  signal  exe_vt_addr                 :  std_logic_vector(2 downto 0) ;
-------------------------------------------------------------------------------
  signal  dec_src_nxt_IA              :  std_logic_vector(1 downto 0) ;
  signal  exe_src_nxt_IA_s            :  std_logic_vector(1 downto 0) ;
  signal  exe_src_nxt_IA              :  std_logic_vector(1 downto 0) ;
-------------------------------------------------------------------------------
  signal  dec_addition_mult           :  std_logic                    ;
  signal  exe_addition_mult           :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_wr_IA                   :  std_logic                    ;
  signal  dec_wr_IR                   :  std_logic                    ;
-------------------------------------------------------------------------------
  signal  dec_src_high_CPSR           :  std_logic_vector(1 downto 0) ;
  signal  exe_src_high_CPSR           :  std_logic_vector(1 downto 0) ;
-------------------------------------------------------------------------------
begin

  PC_MUL_32_DFF: D_FF
      port map(
        CLK                 =>  clk,
        nRST                =>  nRst,
        EN                  =>  ld_pc_dest_or_mul_32,
        D                   =>  pc_dest_or_mul_32,
        Q                   =>  pc_dest_or_mul_32_Q
      );

  ST_UPD_DFF:  D_FF
      port map(
        CLK                 =>  clk,
        nRST                =>  nRst,
        EN                  =>  ld_state_update,
        D                   =>  state_update,
        Q                   =>  state_update_Q
      );

  MULTIPLE_NXT_REG_LOGIC: address_encoder
      port map (
        clk                 =>  clk,
        nRst                =>  nRst,
        ext_register_list   =>  instruction(15 downto 0),
        int_op              =>  int_op_nxt_reg_logic,
        enable              =>  en_nxt_reg_logic,
        zero_flag           =>  zero_flag_nxt_reg_logic,
        next_reg_addr       =>  addr_nxt_reg_logic
      );


  LST_BITMAP: LOAD_REG_NEGEDGE_GEN
      generic map (N => 16)
      port map (
        CLK                 =>  clk,
        nRST                =>  nRst,
        LD                  =>  ld_reg_bitmap,
        D                   =>  instruction(15 downto 0),
        Q                   =>  stored_reg_bitmap
      );

  CHO: count_one
      port map (
      decoded_value         =>  stored_reg_bitmap,
      value                 =>  number_of_registers
    );

  CONSTANT_SUM: process(number_of_registers)
  begin
    number_of_registers_dec <= number_of_registers - '1';
  end process;
--------------------------------------------------------------------------------
  DT: decode_table
    port map(
      irq                         =>  irq                        ,
      fiq                         =>  fiq                        ,
      prefetch_abort              =>  prefetch_abort             ,
      data_abort                  =>  data_abort                 ,
      nRst                        =>  nRst                       ,
      instruction                 =>  instruction                ,
      zero_flag                   =>  zero_flag_nxt_reg_logic    ,
      number_of_registers         =>  number_of_registers        ,
      number_of_registers_dec     =>  number_of_registers_dec    ,
      next_reg_addr               =>  addr_nxt_reg_logic         ,
      int_op_nxt_reg_logic        =>  int_op_nxt_reg_logic       ,
      en_nxt_reg_logic            =>  en_nxt_reg_logic           ,
      ld_reg_bitmap               =>  ld_reg_bitmap              ,
      dec_nxt_state               =>  dec_nxt_state              ,
      ld_pc_dest_or_mul_32        =>  ld_pc_dest_or_mul_32       ,
      pc_dest_or_mul_32           =>  pc_dest_or_mul_32          ,
      ld_state_update             =>  ld_state_update            ,
      state_update                =>  state_update               ,
      dec_addr_rdA                => dec_addr_rdA_t              ,
      dec_en_rdA                  => dec_en_rdA_t                ,
      dec_addr_rdB                => dec_addr_rdB_t              ,
      dec_en_rdB                  => dec_en_rdB_t                ,
      dec_addr_wrA                => dec_addr_wrA_t              ,
      dec_addr_wrB                => dec_addr_wrB_t              ,
      dec_en_wrB                  => dec_en_wrB_t                ,
      dec_en_wrA                  => dec_en_wrA_t                ,
      dec_en_rdPSR                => dec_en_rdPSR_t              ,
      dec_CPSR_nSPSR              => dec_CPSR_nSPSR_t            ,
      dec_addr_rdC                => dec_addr_rdC_t              ,
      dec_en_rdC                  => dec_en_rdC_t                ,
      dec_imm_inst                => dec_imm_inst_t              ,
      dec_immediate_value         => dec_immediate_value_t       ,
      dec_shift_amount            => dec_shift_amount_t          ,
      dec_shifter_opcode          => dec_shifter_opcode_t        ,
      dec_src_shift_amnt          => dec_src_shift_amnt_t        ,
      dec_shift_imm               => dec_shift_imm_t             ,
      dec_Mdata_src_addr          => dec_Mdata_src_addr_t        ,
      dec_Mdata_dim               => dec_Mdata_dim_t             ,
      dec_Mdata_src_out           => dec_Mdata_src_out_t         ,
      dec_Mdata_sign              => dec_Mdata_sign_t            ,
      dec_Mdata_en                => dec_Mdata_en_t              ,
      dec_Mdata_rd_nWr            => dec_Mdata_rd_nWr_t          ,
      dec_alu_opcode              => dec_alu_opcode_t            ,
      dec_cond_code               => dec_cond_code_t             ,
      dec_src_nxt_SPSR            => dec_src_nxt_SPSR_t          ,
      dec_wr_SPSR_high            => dec_wr_SPSR_high_t          ,
      dec_wr_SPSR_low             => dec_wr_SPSR_low_t           ,
      dec_wr_high_CPSR            => dec_wr_high_CPSR_t          ,
      dec_wr_low_CPSR             => dec_wr_low_CPSR_t           ,
      dec_wr_nxt_cpsr             => dec_wr_nxt_cpsr_t           ,
      dec_src_nxt_CPSR            => dec_src_nxt_CPSR_t          ,
      dec_en_mult                 => dec_en_mult_t               ,
      dec_signed_nUnsigned_mult   => dec_signed_nUnsigned_mult_t ,
      dec_HiLo_reg_src_mult       => dec_HiLo_reg_src_mult_t     ,
      dec_wr_Rm_mult              => dec_wr_Rm_mult_t            ,
      dec_wr_Rs_mult              => dec_wr_Rs_mult_t            ,
      dec_wr_sum_mult             => dec_wr_sum_mult_t           ,
      dec_nRst_sum_mult           => dec_nRst_sum_mult_t         ,
      dec_nRst_carry_mult         => dec_nRst_carry_mult_t       ,
      dec_vt_addr                 => dec_vt_addr_t               ,
      dec_src_nxt_IA              => dec_src_nxt_IA_t            ,
      dec_addition_mult           => dec_addition_mult_t         ,
      dec_src_high_CPSR           => dec_src_high_CPSR_t
    );

  FSM:CU_FSM
    port map(
      nRST                        =>  nRst                        ,
      CLK                         =>  clk                         ,
      pc_dest_or_mul_32           =>  pc_dest_or_mul_32_Q         ,
      state_update                =>  state_update_Q              ,
      end_mul                     =>  end_mul                     ,
      decode_next_state           =>  dec_nxt_state               ,
      to_be_exe                   =>  to_be_exe                   ,
      stall                       =>  stall                       ,
      zero_multiple_reg           =>  zero_flag_nxt_reg_logic     ,
      dec_wr_IR                   => dec_wr_IR_f                  ,
      dec_wr_IA                   => dec_wr_IA_f                  ,
      who_is_in_charge            => who_is_in_charge             ,
      dec_en_rdA                  => dec_en_rdA_f                 ,
      dec_en_rdB                  => dec_en_rdB_f                 ,
      dec_addr_wrA                => dec_addr_wrA_f               ,
      dec_addr_wrB                => dec_addr_wrB_f               ,
      dec_en_wrB                  => dec_en_wrB_f                 ,
      dec_en_wrA                  => dec_en_wrA_f                 ,
      dec_en_rdPSR                => dec_en_rdPSR_f               ,
      dec_CPSR_nSPSR              => dec_CPSR_nSPSR_f             ,
      dec_addr_rdC                => dec_addr_rdC_f               ,
      dec_en_rdC                  => dec_en_rdC_f                 ,
      dec_imm_inst                => dec_imm_inst_f               ,
      dec_immediate_value         => dec_immediate_value_f        ,
      dec_shift_amount            => dec_shift_amount_f           ,
      dec_shifter_opcode          => dec_shifter_opcode_f         ,
      dec_src_shift_amnt          => dec_src_shift_amnt_f         ,
      dec_shift_imm               => dec_shift_imm_f              ,
      dec_Mdata_src_addr          => dec_Mdata_src_addr_f         ,
      dec_Mdata_dim               => dec_Mdata_dim_f              ,
      dec_Mdata_src_out           => dec_Mdata_src_out_f          ,
      dec_Mdata_sign              => dec_Mdata_sign_f             ,
      dec_Mdata_en                => dec_Mdata_en_f               ,
      dec_Mdata_rd_nWr            => dec_Mdata_rd_nWr_f           ,
      dec_alu_opcode              => dec_alu_opcode_f             ,
      dec_cond_code               => dec_cond_code_f              ,
      dec_src_nxt_SPSR            => dec_src_nxt_SPSR_f           ,
      dec_wr_SPSR_high            => dec_wr_SPSR_high_f           ,
      dec_wr_SPSR_low             => dec_wr_SPSR_low_f            ,
      dec_wr_high_CPSR            => dec_wr_high_CPSR_f           ,
      dec_wr_low_CPSR             => dec_wr_low_CPSR_f            ,
      dec_wr_nxt_cpsr             => dec_wr_nxt_cpsr_f            ,
      dec_src_nxt_CPSR            => dec_src_nxt_CPSR_f           ,
      dec_en_mult                 => dec_en_mult_f                ,
      dec_signed_nUnsigned_mult   => dec_signed_nUnsigned_mult_f  ,
      dec_HiLo_reg_src_mult       => dec_HiLo_reg_src_mult_f      ,
      dec_wr_Rm_mult              => dec_wr_Rm_mult_f             ,
      dec_wr_Rs_mult              => dec_wr_Rs_mult_f             ,
      dec_wr_sum_mult             => dec_wr_sum_mult_f            ,
      dec_nRst_sum_mult           => dec_nRst_sum_mult_f          ,
      dec_nRst_carry_mult         => dec_nRst_carry_mult_f        ,
      dec_vt_addr                 => dec_vt_addr_f                ,
      dec_src_nxt_IA              => dec_src_nxt_IA_f             ,
      dec_addition_mult           => dec_addition_mult_f          ,
      dec_src_high_CPSR           => dec_src_high_CPSR_f
    );

--------------------------------------------------------------------------------

  dec_addr_rdA                <=  dec_addr_rdA_t                    ;


  dec_en_rdA                  <=  dec_en_rdA_t --( dec_en_rdA_t and not(stall) )
                                  when who_is_in_charge = '0' else
                                  dec_en_rdA_f                      ;
  dec_addr_rdB                <=  dec_addr_rdB_t                    ;

  dec_en_rdB                  <=  dec_en_rdB_t --( dec_en_rdB_t and not(stall) )
                                  when who_is_in_charge = '0' else
                                  dec_en_rdB_f                      ;

  dec_addr_wrA                <=  dec_addr_wrA_t
                                  when who_is_in_charge = '0' else
                                  dec_addr_wrA_f                    ;

  dec_addr_wrB                <=  dec_addr_wrB_t
                                  when who_is_in_charge = '0' else
                                  dec_addr_wrB_f                    ;

  dec_en_wrB                  <=  dec_en_wrB_t
                                  when who_is_in_charge = '0' else
                                  dec_en_wrB_f                      ;

  dec_en_wrA                  <=  dec_en_wrA_t
                                  when who_is_in_charge = '0' else
                                  dec_en_wrA_f                      ;

  dec_en_rdPSR                <=  dec_en_rdPSR_t
                                  when who_is_in_charge = '0' else
                                  dec_en_rdPSR_f                    ;

  dec_CPSR_nSPSR              <=  dec_CPSR_nSPSR_t
                                  when who_is_in_charge = '0' else
                                  dec_CPSR_nSPSR_f                  ;

  dec_addr_rdC                <=  dec_addr_rdC_t
                                  when who_is_in_charge = '0' else
                                  dec_addr_rdC_f                    ;

  dec_en_rdC                  <=  dec_en_rdC_t
                                  when who_is_in_charge = '0' else
                                  dec_en_rdC_f                      ;

  dec_imm_inst                <=  dec_imm_inst_t
                                  when who_is_in_charge = '0' else
                                  dec_imm_inst_f                    ;

  dec_immediate_value         <=  dec_immediate_value_t
                                  when who_is_in_charge = '0' else
                                  dec_immediate_value_f             ;

  dec_shift_amount            <=  dec_shift_amount_t
                                  when who_is_in_charge = '0' else
                                  dec_shift_amount_f                ;

  dec_shifter_opcode          <=  dec_shifter_opcode_t
                                  when who_is_in_charge = '0' else
                                  dec_shifter_opcode_f              ;

  dec_src_shift_amnt          <=  dec_src_shift_amnt_t
                                  when who_is_in_charge = '0' else
                                  dec_src_shift_amnt_f              ;

  dec_shift_imm               <=  dec_shift_imm_t
                                  when who_is_in_charge = '0' else
                                  dec_shift_imm_f                   ;

  dec_Mdata_src_addr          <=  dec_Mdata_src_addr_t
                                  when who_is_in_charge = '0' else
                                  dec_Mdata_src_addr_f              ;

  dec_Mdata_dim               <=  dec_Mdata_dim_t
                                  when who_is_in_charge = '0' else
                                  dec_Mdata_dim_f                   ;

  dec_Mdata_src_out           <=  dec_Mdata_src_out_t
                                  when who_is_in_charge = '0' else
                                  dec_Mdata_src_out_f               ;

  dec_Mdata_sign              <=  dec_Mdata_sign_t
                                  when who_is_in_charge = '0' else
                                  dec_Mdata_sign_f                  ;

  dec_Mdata_en                <=  dec_Mdata_en_t
                                  when who_is_in_charge = '0' else
                                  dec_Mdata_en_f                    ;

  dec_Mdata_rd_nWr            <=  dec_Mdata_rd_nWr_t
                                  when who_is_in_charge = '0' else
                                  dec_Mdata_rd_nWr_f                ;

  dec_alu_opcode              <=  dec_alu_opcode_t
                                  when who_is_in_charge = '0' else
                                  dec_alu_opcode_f                  ;

  dec_cond_code               <=  ( dec_cond_code_t or (STALL & STALL & STALL & STALL) )
                                  when who_is_in_charge = '0' else
                                  dec_cond_code_f                   ;

  dec_src_nxt_SPSR            <=  dec_src_nxt_SPSR_t
                                  when who_is_in_charge = '0' else
                                  dec_src_nxt_SPSR_f                ;

  dec_wr_SPSR_high            <=  dec_wr_SPSR_high_t
                                  when who_is_in_charge = '0' else
                                  dec_wr_SPSR_high_f                ;

  dec_wr_SPSR_low             <=  dec_wr_SPSR_low_t
                                  when who_is_in_charge = '0' else
                                  dec_wr_SPSR_low_f                 ;

  dec_wr_high_CPSR            <=  dec_wr_high_CPSR_t
                                  when who_is_in_charge = '0' else
                                  dec_wr_high_CPSR_f                ;

  dec_wr_low_CPSR             <=  dec_wr_low_CPSR_t
                                  when who_is_in_charge = '0' else
                                  dec_wr_low_CPSR_f                 ;

  dec_wr_nxt_cpsr             <=  dec_wr_nxt_cpsr_t
                                  when who_is_in_charge = '0' else
                                  dec_wr_nxt_cpsr_f                 ;

  dec_src_nxt_CPSR            <=  dec_src_nxt_CPSR_t
                                  when who_is_in_charge = '0' else
                                  dec_src_nxt_CPSR_f                ;

  dec_en_mult                 <=  dec_en_mult_t
                                  when who_is_in_charge = '0' else
                                  dec_en_mult_f                     ;

  dec_signed_nUnsigned_mult   <=  dec_signed_nUnsigned_mult_t
                                  when who_is_in_charge = '0' else
                                  dec_signed_nUnsigned_mult_f       ;

  dec_HiLo_reg_src_mult       <=  dec_HiLo_reg_src_mult_t
                                  when who_is_in_charge = '0' else
                                  dec_HiLo_reg_src_mult_f           ;

  dec_wr_Rm_mult              <=  dec_wr_Rm_mult_t
                                  when who_is_in_charge = '0' else
                                  dec_wr_Rm_mult_f                  ;

  dec_wr_Rs_mult              <=  dec_wr_Rs_mult_t
                                  when who_is_in_charge = '0' else
                                  dec_wr_Rs_mult_f                  ;

  dec_wr_sum_mult             <=  dec_wr_sum_mult_t
                                  when who_is_in_charge = '0' else
                                  dec_wr_sum_mult_f                 ;

  dec_nRst_sum_mult           <=  dec_nRst_sum_mult_t
                                  when who_is_in_charge = '0' else
                                  dec_nRst_sum_mult_f               ;

  dec_nRst_carry_mult         <=  dec_nRst_carry_mult_t
                                  when who_is_in_charge = '0' else
                                  dec_nRst_carry_mult_f             ;

  dec_vt_addr                 <=  dec_vt_addr_t
                                  when who_is_in_charge = '0' else
                                  dec_vt_addr_f                     ;

  dec_src_nxt_IA              <=  dec_src_nxt_IA_t
                                  when who_is_in_charge = '0' else
                                  dec_src_nxt_IA_f                  ;

  dec_addition_mult           <=  dec_addition_mult_t
                                  when who_is_in_charge = '0' else
                                  dec_addition_mult_f               ;

  dec_src_high_CPSR           <=  dec_src_high_CPSR_t
                                  when who_is_in_charge = '0' else
                                  dec_src_high_CPSR_f               ;

--------------------------------------------------------------------------------
  dec_wr_IA                   <=  not(stall)
                                  when who_is_in_charge = '0' else
                                  dec_wr_IA_f;
  dec_wr_IR                   <=  not(stall)
                                  when who_is_in_charge = '0' else
                                  dec_wr_IR_f;

--------------------------------------------------------------------------------
--                        MEMORY SIGNALS
--------------------------------------------------------------------------------
  DFF0: DFF
        port map (
          D     => dec_Mdata_en,
          Q     => exe_Mdata_en_s,
          clk   => clk,
          nRst  => nRst
        );


  exe_Mdata_en <= exe_Mdata_en_s and to_be_exe;
  DFF1: DFF
        port map (
          D     => exe_Mdata_en,
          Q     => mem_Mdata_en,
          clk   => clk,
          nRst  => nRst
        );

  DFF2: DFF
        port map (
          D     => dec_Mdata_rd_nWr,
          Q     => exe_Mdata_rd_nWr,
          clk   => clk,
          nRst  => nRst
        );

  DFF4: DFF
        port map (
          D     => dec_Mdata_src_out,
          Q     => exe_Mdata_src_out,
          clk   => clk,
          nRst  => nRst
        );

  DFF5: DFF
        port map (
          D     => exe_Mdata_src_out,
          Q     => mem_Mdata_src_out,
          clk   => clk,
          nRst  => nRst
        );

  DFF6: REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_Mdata_src_addr'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => dec_Mdata_src_addr,
          Q     => exe_Mdata_src_addr
        );


  DFF7: REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_Mdata_dim'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => dec_Mdata_dim,
          Q     => exe_Mdata_dim
        );

  DFF8: REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_Mdata_dim'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => exe_Mdata_dim,
          Q     => mem_Mdata_dim
        );

  DFF9: REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_Mdata_dim'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => mem_Mdata_dim,
          Q     => wb_Mdata_dim
        );

  DFF10: DFF
        port map (
          D     => dec_Mdata_sign,
          Q     => exe_Mdata_sign,
          clk   => clk,
          nRst  => nRst
        );

  DFF11:DFF
        port map (
          D     => exe_Mdata_sign,
          Q     => mem_Mdata_sign,
          clk   => clk,
          nRst  => nRst
        );

  DFF12:DFF
        port map (
          D     => mem_Mdata_sign,
          Q     => wb_Mdata_sign,
          clk   => clk,
          nRst  => nRst
        );

--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
--                        FETCH SIGNALS
--------------------------------------------------------------------------------
  DFF13:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_vt_addr'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => dec_vt_addr,
          Q     => exe_vt_addr
        );


  DFF14:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_src_nxt_IA'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => dec_src_nxt_IA,
          Q     => exe_src_nxt_IA_s
        );
  exe_src_nxt_IA <= exe_src_nxt_IA_s and (to_be_exe & to_be_exe);


--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                        REGISTER FILE SIGNALS
--------------------------------------------------------------------------------


  DFF16:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_addr_wrA'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => dec_addr_wrA,
          Q     => exe_addr_wrA_Q
        );

  DFF17:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_addr_wrA'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => exe_addr_wrA_Q,
          Q     => mem_addr_wrA_Q
        );

  DFF18:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_addr_wrA'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => mem_addr_wrA_Q,
          Q     => wb_addr_wrA
        );


  DFF19:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_addr_wrB'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => dec_addr_wrB,
          Q     => exe_addr_wrB_Q
        );

  DFF20:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_addr_wrB'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => exe_addr_wrB_Q,
          Q     => mem_addr_wrB_Q
        );

  DFF21:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_addr_wrB'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => mem_addr_wrB_Q,
          Q     =>  wb_addr_wrB
        );


  DFF22:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_addr_rdC'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => dec_addr_rdC,
          Q     => exe_addr_rdC
        );

  DFF23:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_addr_rdC'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => exe_addr_rdC,
          Q     => mem_addr_rdC
        );


  DFF24:DFF
        port map (
          D     => dec_en_wrA,
          Q     => exe_en_wrA_s,
          clk   => clk,
          nRst  => nRst
        );

  exe_en_wrA_Q <= exe_en_wrA_s and to_be_exe;
  DFF25:DFF
        port map (
          D     => exe_en_wrA_Q,
          Q     => mem_en_wrA_Q,
          clk   => clk,
          nRst  => nRst
        );

  DFF26:DFF
        port map (
          D     => mem_en_wrA_Q,
          Q     =>  wb_en_wrA,
          clk   => clk,
          nRst  => nRst
        );

  DFF27:DFF
        port map (
          D     => dec_en_wrB,
          Q     => exe_en_wrB_s,
          clk   => clk,
          nRst  => nRst
        );

  exe_en_wrB_Q <= exe_en_wrB_s and to_be_exe;
  DFF28:DFF
        port map (
          D     => exe_en_wrB_Q,
          Q     => mem_en_wrB_Q,
          clk   => clk,
          nRst  => nRst
        );

  DFF29:DFF
        port map (
          D     => mem_en_wrB_Q,
          Q     =>  wb_en_wrB,
          clk   => clk,
          nRst  => nRst
        );

  DFF99:DFF
        port map (
          D     => dec_en_rdC,
          Q     => exe_en_rdC_s,
          clk   => clk,
          nRst  => nRst
        );

  exe_en_rdC <= exe_en_rdC_s and to_be_exe;
   DFF98:DFF
        port map (
          D     => exe_en_rdC,
          Q     => mem_en_rdC,
          clk   => clk,
          nRst  => nRst
        );
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                        EXE STAGE SIGNALS
--------------------------------------------------------------------------------
  DFF30:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_alu_opcode'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => dec_alu_opcode,
          Q     => exe_alu_opcode
        );

  DFF31:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_cond_code'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => dec_cond_code,
          Q     => exe_cond_code
        );

  DFF32:DFF
        port map (
          D     => dec_src_shift_amnt,
          Q     => exe_src_shift_amnt,
          clk   => clk,
          nRst  => nRst
        );


  DFF33:DFF
        port map (
          D     => dec_shift_imm,
          Q     => exe_shift_imm,
          clk   => clk,
          nRst  => nRst
        );


  DFF34:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_shift_amount'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => dec_shift_amount,
          Q     => exe_shift_amount
        );


  DFF35:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_shifter_opcode'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => dec_shifter_opcode,
          Q     => exe_shifter_opcode
        );





--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                    PROCESSOR STATUS SIGNALS
--
--------------------------------------------------------------------------------

  DFF37:DFF
        port map (
          D     => dec_wr_nxt_CPSR,
          Q     => exe_wr_nxt_CPSR_s,
          clk   => clk,
          nRst  => nRst
        );
  exe_wr_nxt_CPSR <= exe_wr_nxt_CPSR_s and to_be_exe;

  DFF38:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_src_nxt_CPSR'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => dec_src_nxt_CPSR,
          Q     => exe_src_nxt_CPSR
        );

  DFF39:DFF
        port map (
          D     => exe_wr_low_CPSR,
          Q     => mem_wr_low_CPSR,
          clk   => clk,
          nRst  => nRst
        );

  DFF40:DFF
        port map (
          D     => dec_wr_low_CPSR,
          Q     => exe_wr_low_CPSR_s,
          clk   => clk,
          nRst  => nRst
        );
  exe_wr_low_CPSR <= exe_wr_low_CPSR_s and to_be_exe;

  DFF41:DFF
        port map (
          D     => dec_wr_high_CPSR,
          Q     => exe_wr_high_CPSR_s,
          clk   => clk,
          nRst  => nRst
        );
  exe_wr_high_CPSR <= exe_wr_high_CPSR_s and to_be_exe;



  DFF42:DFF
        port map (
          D     => dec_wr_SPSR_low,
          Q     => exe_wr_SPSR_low_s,
          clk   => clk,
          nRst  => nRst
        );

  DFF43:DFF
        port map (
          D     => dec_wr_SPSR_high,
          Q     => exe_wr_SPSR_high_s,
          clk   => clk,
          nRst  => nRst
        );

  exe_wr_SPSR_high <= exe_wr_SPSR_high_s and to_be_exe;
  exe_wr_SPSR_low <= exe_wr_SPSR_low_s and to_be_exe;


  DFF44:DFF
        port map (
          D     => dec_src_nxt_SPSR,
          Q     => exe_src_nxt_SPSR,
          clk   => clk,
          nRst  => nRst
        );

  DFF45:DFF
        port map (
          D     => dec_addition_mult,
          Q     => exe_addition_mult,
          clk   => clk,
          nRst  => nRst
        );

  DFF46:REG_NEGEDGE_GEN_ACTIVE
        generic map (N => dec_src_high_CPSR'length)
        port map (
          CLK   => clk,
          nRST  => nRst,
          D     => dec_src_high_CPSR,
          Q     => exe_src_high_CPSR
        );

---------------------------------------------------------------------
    addr_rdA                <=  dec_addr_rdA              ;
    addr_rdB                <=  dec_addr_rdB              ;
    addr_rdC                <=  mem_addr_rdC              ;
    addr_wrA                <=  wb_addr_wrA               ;
    addr_wrB                <=  wb_addr_wrB               ;
    en_wrA                  <=  wb_en_wrA                 ;
    en_wrB                  <=  wb_en_wrB                 ;
    en_rdA                  <=  dec_en_rdA                ;
    en_rdB                  <=  dec_en_rdB                ;
    en_rdC                  <=  mem_en_rdC                ;
---------------------------------------------------------------------
--                      FORWARDING UNIT
---------------------------------------------------------------------
    exe_addr_wrA            <=  exe_addr_wrA_Q            ;
    mem_addr_wrA            <=  mem_addr_wrA_Q            ;
    exe_en_wrA              <=  exe_en_wrA_Q              ;
    mem_en_wrA              <=  mem_en_wrA_Q              ;
    exe_addr_wrB            <=  exe_addr_wrB_Q            ;
    mem_addr_wrB            <=  mem_addr_wrB_Q            ;
    exe_en_wrB              <=  exe_en_wrB_Q              ;
    mem_en_wrB              <=  mem_en_wrB_Q              ;
    en_rdPSR                <=  dec_en_rdPSR              ;
    CPSR_nSPSR              <=  dec_CPSR_nSPSR            ;
    imm_inst                <=  dec_imm_inst              ;
    immediate_value         <=  dec_immediate_value       ;
---------------------------------------------------------------------
--                      BARREL SHIFTER
---------------------------------------------------------------------
    shift_amount            <=  exe_shift_amount          ;
    shifter_opcode          <=  exe_shifter_opcode        ;
    src_shift_amnt          <=  exe_src_shift_amnt        ;
    shift_imm               <=  exe_shift_imm             ;
---------------------------------------------------------------------
--                      MEMORY SYSTEM
---------------------------------------------------------------------
    Mdata_src_addr          <=  exe_Mdata_src_addr        ;
    Mdata_src_addr_nxt      <=  dec_Mdata_src_addr        ;
    Mdata_src_out           <=  mem_Mdata_src_out         ;
    Mdata_dim               <=  exe_Mdata_dim             ;
    Mdata_sign              <=  exe_Mdata_sign            ;
    Mdata_en                <=  exe_Mdata_en              ;
    Mdata_en_nxt            <=  dec_Mdata_en              ;
    Mdata_rd_nWr            <=  exe_Mdata_rd_nWr          ;
---------------------------------------------------------------------
--                      BYTE WORD REPLICATION
---------------------------------------------------------------------
    str_Mdata_dim           <=  mem_Mdata_dim             ;
---------------------------------------------------------------------
--                      BYTE ROT SIGN EXTENSION
---------------------------------------------------------------------
    ld_Mdata_dim            <=  wb_Mdata_dim              ;
    ld_Mdata_sign           <=  wb_Mdata_sign             ;
---------------------------------------------------------------------
--                      TO_BE_EXE UNIT
---------------------------------------------------------------------
    alu_opcode              <=  exe_alu_opcode            ;
    cond_code               <=  exe_cond_code             ;
---------------------------------------------------------------------
--                      SPSR
---------------------------------------------------------------------
    src_nxt_SPSR            <=  exe_src_nxt_SPSR          ;
    wr_SPSR_high            <=  exe_wr_SPSR_high          ;
    wr_SPSR_low             <=  exe_wr_SPSR_low           ;
---------------------------------------------------------------------
--                      CPSR
---------------------------------------------------------------------
    wr_high_cpsr            <=  exe_wr_high_cpsr          ;
    src_high_CPSR           <=  exe_src_high_cpsr         ;
    wr_low_cpsr             <=  mem_wr_low_cpsr           ;
---------------------------------------------------------------------
--                      NXT_CPSR
---------------------------------------------------------------------
    src_nxt_CPSR            <=  exe_src_nxt_CPSR          ;
    wr_nxt_cpsr             <=  exe_wr_nxt_CPSR           ;
---------------------------------------------------------------------
--                      MULT
---------------------------------------------------------------------
    en_mult                 <=  dec_en_mult               ;
    signed_nUnsigned_mult   <=  dec_signed_nUnsigned_mult ;
    HiLo_reg_src_mult       <=  dec_HiLo_reg_src_mult     ;
    wr_Rm_mult              <=  dec_wr_Rm_mult            ;
    wr_Rs_mult              <=  dec_wr_Rs_mult            ;
    wr_sum_mult             <=  dec_wr_sum_mult           ;
    nRst_sum_mult           <=  dec_nRst_sum_mult         ;
    nRst_carry_mult         <=  dec_nRst_carry_mult       ;
    addition_mult           <=  exe_addition_mult         ;
---------------------------------------------------------------------
--                      LOAD FOR IA AND FETCH/DEC REG. PIPE
---------------------------------------------------------------------
    wr_IA                   <=  dec_wr_IA                 ;
    wr_IR                   <=  dec_wr_IR                 ;
    src_nxt_IA              <=  exe_src_nxt_IA            ;
    vt_addr                 <=  exe_vt_addr               ;
---------------------------------------------------------------------
end architecture STRUCTURAL;
