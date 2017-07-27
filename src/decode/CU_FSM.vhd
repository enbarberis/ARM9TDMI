library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.CU_pack.all;
use WORK.DECODE_pack.all;
use WORK.ARM_pack.all;


entity CU_FSM is
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
end entity CU_FSM;

--------------------------------------------------------------------------------

architecture BHV of CU_FSM is

  signal current_state: CU_STATE_t;
  signal next_state:    CU_STATE_t;

  signal pc_dest: std_logic;
  signal mul_32: std_logic;

begin

  pc_dest <= pc_dest_or_mul_32;
  mul_32 <= pc_dest_or_mul_32;

  STATE_REG: process(clk, nRst)
  begin
    if ( nRst = '0' ) then
      current_state <= RESET_STATE;
    elsif ( clk = '0' and clk'event ) then
      current_state <= next_state;
    end if;
  end process;  -- STATE_REG

  NEXT_STATE_COMB_LOGIC: process( current_state, decode_next_state, to_be_exe, stall, pc_dest, state_update, end_mul, zero_multiple_reg, mul_32  )
  begin
    case current_state is
      when RESET_STATE =>
        next_state <= JUMP_RESET;
      when JUMP_RESET =>
        next_state <= FETCH_FILL;
      when FETCH_FILL =>
        next_state <= DISPATCHER;
      when DISPATCHER =>
        if ( stall = '1' ) then
          next_state <= DISPATCHER;
        else
          next_state <= decode_next_state;
        end if; -- stall
      when STM_1_CORR_ADD =>
        if ( to_be_exe = '1' ) then
          next_state <= DISPATCHER;
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when STM_1_CORR_SUB =>
        if ( to_be_exe = '1' ) then
          next_state <= DISPATCHER;
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when SWAP_STR =>
        if ( to_be_exe = '1' ) then
          next_state <= DISPATCHER;
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when LINK_BRANCH =>
        if ( to_be_exe = '1' ) then
          next_state <= FETCH_FILL;
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when JUMP =>
        if ( to_be_exe = '1' ) then
          next_state <= FETCH_FILL;
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when LDM_1_CORR_ADD =>
        if ( to_be_exe = '1' ) then
          if ( PC_DEST = '0' ) then
            next_state <= DISPATCHER;
          else
            if ( STATE_UPDATE = '0' ) then
              next_state <= PC_LD_MEM;
            else
              next_state <= PC_LD_SPSR;
            end if; -- state update
          end if; -- pc destination
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when LDM_1_CORR_SUB =>
        if ( to_be_exe = '1' ) then
          if ( PC_DEST = '0' ) then
            next_state <= DISPATCHER;
          else
            if ( STATE_UPDATE = '0' ) then
              next_state <= PC_LD_MEM;
            else
              next_state <= PC_LD_SPSR;
            end if; -- state update
          end if; -- pc destination
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when LDM_N_CORR_ADD =>
        if ( to_be_exe = '1' ) then
          if ( zero_multiple_reg = '0' ) then
            if ( PC_DEST = '0' ) then
              next_state <= DISPATCHER;
            else
              if ( STATE_UPDATE = '0' ) then
                next_state <= PC_LD_MEM;
              else
                next_state <= PC_LD_SPSR;
              end if; -- state update
            end if; -- pc destination
          else
            next_state <= LDM_N_WAIT;
          end if; -- num multiple reg
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when LDM_N_CORR_SUB =>
        if ( to_be_exe = '1' ) then
          if ( zero_multiple_reg = '0' ) then
            if ( PC_DEST = '0' ) then
              next_state <= DISPATCHER;
            else
              if ( STATE_UPDATE = '0' ) then
                next_state <= PC_LD_MEM;
              else
                next_state <= PC_LD_SPSR;
              end if; -- state update
            end if; -- pc destination
          else
            next_state <= LDM_N_WAIT;
          end if; -- num multiple reg
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when LDM_N_WAIT =>
        if ( zero_multiple_reg = '0' ) then
          if ( PC_DEST = '0' ) then
            next_state <= DISPATCHER;
          else
            if ( STATE_UPDATE = '0' ) then
              next_state <= PC_LD_MEM;
            else
              next_state <= PC_LD_SPSR;
            end if; -- state update
          end if; -- pc destination
        else
          next_state <= LDM_N_WAIT;
        end if; -- num multiple reg
      when PC_LD_SPSR =>
        next_state <= PC_LD_WB;
      when PC_LD_EXE =>
        if ( to_be_exe = '1' ) then
          next_state <= PC_LD_MEM;
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when PC_LD_MEM =>
        next_state <= PC_LD_WB;
      when PC_LD_WB =>
        next_state <= FETCH_FILL;
      when STM_N_CORR_ADD =>
        if ( to_be_exe = '1' ) then
          if ( zero_multiple_reg = '0' ) then
              next_state <= DISPATCHER;
          else
            next_state <= STM_N_WAIT;
          end if; -- num multiple reg
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when STM_N_CORR_SUB =>
        if ( to_be_exe = '1' ) then
          if ( zero_multiple_reg = '0' ) then
              next_state <= DISPATCHER;
          else
            next_state <= STM_N_WAIT;
          end if; -- num multiple reg
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when STM_N_WAIT =>
        if ( zero_multiple_reg = '0' ) then
          next_state <= DISPATCHER;
        else
          next_state <= STM_N_WAIT;
        end if; -- num multiple reg
      when MUL_WIP =>
        if ( to_be_exe = '1' ) then
          if ( end_mul = '1' ) then
            next_state <= MUL_SUM_LOW;
          else
            next_State <= MUL_WIP;
          end if; -- end mul
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when MUL_SUM_LOW =>
        if ( mul_32 = '1' ) then
          next_state <= DISPATCHER;
        else
          next_state <= MUL_SUM_HIGH;
        end if; -- mul 32 bit
      when MUL_SUM_HIGH =>
        next_state <= DISPATCHER;
      when MODE_UPDATE_EXE =>
        if ( to_be_exe = '1' ) then
          next_state <= MODE_UPDATE_NXT;
        else
          if ( stall = '1' ) then
            next_state <= DISPATCHER;
          else
            next_state <= decode_next_state;
          end if; --stall
        end if; -- to be exec
      when MODE_UPDATE_NXT =>
        next_state <= DISPATCHER;
      when ERROR_STATE => -- only for DEBUG
        next_state <= ERROR_STATE;
      when others =>
        next_state <= ERROR_STATE;
    end case;
  end process;



  OUT_COMB_LOGIC: process( current_state )
  begin
    case current_state is
      when FETCH_FILL =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;

      when DISPATCHER =>
        dec_wr_IR                 <=  '0'               ;
        dec_wr_IA                 <=  '0'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '0'               ;
        dec_nRst_carry_mult       <=  '0'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "--"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;

      when JUMP_RESET =>
        dec_wr_IR                 <=  '0'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when RESET_STATE =>
        dec_wr_IR                 <=  '0'               ;
        dec_wr_IA                 <=  '0'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  "1110"            ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '1'               ;
        dec_wr_nxt_cpsr           <=  '1'               ;
        dec_src_nxt_CPSR          <=  "00"                ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  "000"             ;
        dec_src_nxt_IA            <=  "01"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when SWAP_STR =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when LINK_BRANCH =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '1'               ;
        dec_addr_wrA              <=  R14               ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '1'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '1'               ;
        dec_immediate_value       <=  x"00000004"       ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  SLL_OP            ;
        dec_src_shift_amnt        <=  SHIFT_AMNT_FROM_IMM ;
        dec_shift_imm             <=  '1'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  "0010"            ;
        dec_cond_code             <=  "1110"            ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when JUMP =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when LDM_1_CORR_SUB =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when LDM_N_CORR_SUB =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when LDM_1_CORR_ADD =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when LDM_N_CORR_ADD =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when LDM_N_WAIT =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when PC_LD_SPSR =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when PC_LD_EXE =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when PC_LD_MEM =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when PC_LD_WB =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when STM_1_CORR_SUB =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;

      when STM_1_CORR_ADD =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when STM_N_CORR_SUB =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when STM_N_CORR_ADD =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when STM_N_WAIT =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;

      when MUL_WIP =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;

      when MUL_SUM_LOW =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;

      when MUL_SUM_HIGH =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;

      when MODE_UPDATE_EXE =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when MODE_UPDATE_NXT =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when ERROR_STATE => -- only for DEBUG
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
      
      when others =>
        dec_wr_IR                 <=  '1'               ;
        dec_wr_IA                 <=  '1'               ;
        dec_en_rdA                <=  '0'               ;
        dec_en_rdB                <=  '0'               ;
        dec_addr_wrA              <=  ( others => '0' ) ;
        dec_addr_wrB              <=  ( others => '0' ) ;
        dec_en_wrB                <=  '0'               ;
        dec_en_wrA                <=  '0'               ;
        dec_en_rdPSR              <=  '0'               ;
        dec_CPSR_nSPSR            <=  '0'               ;
        dec_addr_rdC              <=  ( others => '0' ) ;
        dec_en_rdC                <=  '0'               ;
        dec_imm_inst              <=  '0'               ;
        dec_immediate_value       <=  ( others => '0' ) ;
        dec_shift_amount          <=  ( others => '0' ) ;
        dec_shifter_opcode        <=  ( others => '0' ) ;
        dec_src_shift_amnt        <=  '0'               ;
        dec_shift_imm             <=  '0'               ;
        dec_Mdata_src_addr        <=  ( others => '0' ) ;
        dec_Mdata_dim             <=  ( others => '0' ) ;
        dec_Mdata_src_out         <=  '0'               ;
        dec_Mdata_sign            <=  '0'               ;
        dec_Mdata_en              <=  '0'               ;
        dec_Mdata_rd_nWr          <=  '0'               ;
        dec_alu_opcode            <=  ( others => '0' ) ;
        dec_cond_code             <=  ( others => '1' ) ;
        dec_src_nxt_SPSR          <=  '0'               ;
        dec_wr_SPSR_high          <=  '0'               ;
        dec_wr_SPSR_low           <=  '0'               ;
        dec_wr_high_CPSR          <=  '0'               ;
        dec_wr_low_CPSR           <=  '0'               ;
        dec_wr_nxt_cpsr           <=  '0'               ;
        dec_src_nxt_CPSR          <=  ( others => '0' ) ;
        dec_en_mult               <=  '0'               ;
        dec_signed_nUnsigned_mult <=  '0'               ;
        dec_HiLo_reg_src_mult     <=  '0'               ;
        dec_wr_Rm_mult            <=  '0'               ;
        dec_wr_Rs_mult            <=  '0'               ;
        dec_wr_sum_mult           <=  '0'               ;
        dec_nRst_sum_mult         <=  '1'               ;
        dec_nRst_carry_mult       <=  '1'               ;
        dec_vt_addr               <=  ( others => '0' ) ;
        dec_src_nxt_IA            <=  "00"              ;
        dec_addition_mult         <=  '0'               ;
        dec_src_high_CPSR         <=  ( others => '0' ) ;
    end case;
  end process;



  WHO_RULES: process(current_state, to_be_exe)
  begin
    case current_state is
      when  DISPATCHER =>
        who_is_in_charge <= '0';
      when  FETCH_FILL | RESET_STATE | JUMP_RESET =>
        who_is_in_charge <= '1';
      when others =>
        if ( to_be_exe = '1' ) then
          who_is_in_charge <= '1';
        else
          who_is_in_charge <= '0';
        end if;
    end case;
  end process;






end architecture BHV;
