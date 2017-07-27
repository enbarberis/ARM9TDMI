library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.DECODE_pack.all;
use WORK.ARM_pack.all;
use WORK.CU_pack.all;
--------------------------------------------------------------------------------

entity decode_table is
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
end entity ;

--------------------------------------------------------------------------------

architecture BHV of decode_table is
begin

  COMB_LOGIC: process(nRst,data_abort,irq,fiq,instruction,zero_flag)
  begin
    if ( data_abort = '1' ) then
      int_op_nxt_reg_logic          <=  '0';
      en_nxt_reg_logic              <=  '0';
      ld_reg_bitmap                 <=  '0';
      dec_nxt_state                 <=  ERROR_STATE;
      ld_pc_dest_or_mul_32          <=  '0';
      pc_dest_or_mul_32             <=  '0';
      ld_state_update               <=  '0';
      state_update                  <=  '0';
      dec_addr_rdA                  <=  ( others => '0' );
      dec_en_rdA                    <=  '0';
      dec_addr_rdB                  <=  ( others => '0' );
      dec_en_rdB                    <=  '0';
      dec_addr_wrA                  <=  ( others => '0' );
      dec_addr_wrB                  <=  ( others => '0' );
      dec_en_wrB                    <=  '0';
      dec_en_wrA                    <=  '0';
      dec_en_rdPSR                  <=  '0';
      dec_CPSR_nSPSR                <=  '0';
      dec_addr_rdC                  <=  ( others => '0' );
      dec_en_rdC                    <=  '0';
      dec_imm_inst                  <=  '0';
      dec_immediate_value           <=  ( others => '0' );
      dec_shift_amount              <=  ( others => '0' );
      dec_shifter_opcode            <=  ( others => '0' );
      dec_src_shift_amnt            <=  '0';
      dec_shift_imm                 <=  '0';
      dec_Mdata_src_addr            <=  ( others => '0' );
      dec_Mdata_dim                 <=  ( others => '0' );
      dec_Mdata_src_out             <=  '0';
      dec_Mdata_sign                <=  '0';
      dec_Mdata_en                  <=  '0';
      dec_Mdata_rd_nWr              <=  '0';
      dec_alu_opcode                <=  ( others => '0' );
      dec_cond_code                 <=  ( others => '0' );
      dec_src_nxt_SPSR              <=  '0';
      dec_wr_SPSR_high              <=  '0';
      dec_wr_SPSR_low               <=  '0';
      dec_wr_high_CPSR              <=  '0';
      dec_wr_low_CPSR               <=  '0';
      dec_wr_nxt_cpsr               <=  '0';
      dec_src_nxt_CPSR              <=  ( others => '0' );
      dec_en_mult                   <=  '0';
      dec_signed_nUnsigned_mult     <=  '0';
      dec_HiLo_reg_src_mult         <=  '0';
      dec_wr_Rm_mult                <=  '0';
      dec_wr_Rs_mult                <=  '0';
      dec_wr_sum_mult               <=  '0';
      dec_nRst_sum_mult             <=  '0';
      dec_nRst_carry_mult           <=  '0';
      dec_vt_addr                   <=  ( others => '0' );
      dec_src_nxt_IA                <=  ( others => '0' );
      dec_addition_mult             <=  '0';
      dec_src_high_CPSR             <=  ( others => '0' );
    
    elsif ( fiq = '0' ) then
      int_op_nxt_reg_logic          <=  '0';
      en_nxt_reg_logic              <=  '0';
      ld_reg_bitmap                 <=  '0';
      dec_nxt_state                 <=  ERROR_STATE;
      ld_pc_dest_or_mul_32          <=  '0';
      pc_dest_or_mul_32             <=  '0';
      ld_state_update               <=  '0';
      state_update                  <=  '0';
      dec_addr_rdA                  <=  ( others => '0' );
      dec_en_rdA                    <=  '0';
      dec_addr_rdB                  <=  ( others => '0' );
      dec_en_rdB                    <=  '0';
      dec_addr_wrA                  <=  ( others => '0' );
      dec_addr_wrB                  <=  ( others => '0' );
      dec_en_wrB                    <=  '0';
      dec_en_wrA                    <=  '0';
      dec_en_rdPSR                  <=  '0';
      dec_CPSR_nSPSR                <=  '0';
      dec_addr_rdC                  <=  ( others => '0' );
      dec_en_rdC                    <=  '0';
      dec_imm_inst                  <=  '0';
      dec_immediate_value           <=  ( others => '0' );
      dec_shift_amount              <=  ( others => '0' );
      dec_shifter_opcode            <=  ( others => '0' );
      dec_src_shift_amnt            <=  '0';
      dec_shift_imm                 <=  '0';
      dec_Mdata_src_addr            <=  ( others => '0' );
      dec_Mdata_dim                 <=  ( others => '0' );
      dec_Mdata_src_out             <=  '0';
      dec_Mdata_sign                <=  '0';
      dec_Mdata_en                  <=  '0';
      dec_Mdata_rd_nWr              <=  '0';
      dec_alu_opcode                <=  ( others => '0' );
      dec_cond_code                 <=  ( others => '0' );
      dec_src_nxt_SPSR              <=  '0';
      dec_wr_SPSR_high              <=  '0';
      dec_wr_SPSR_low               <=  '0';
      dec_wr_high_CPSR              <=  '0';
      dec_wr_low_CPSR               <=  '0';
      dec_wr_nxt_cpsr               <=  '0';
      dec_src_nxt_CPSR              <=  ( others => '0' );
      dec_en_mult                   <=  '0';
      dec_signed_nUnsigned_mult     <=  '0';
      dec_HiLo_reg_src_mult         <=  '0';
      dec_wr_Rm_mult                <=  '0';
      dec_wr_Rs_mult                <=  '0';
      dec_wr_sum_mult               <=  '0';
      dec_nRst_sum_mult             <=  '0';
      dec_nRst_carry_mult           <=  '0';
      dec_vt_addr                   <=  ( others => '0' );
      dec_src_nxt_IA                <=  ( others => '0' );
      dec_addition_mult             <=  '0';
      dec_src_high_CPSR             <=  ( others => '0' );

    elsif ( irq = '0' ) then
      int_op_nxt_reg_logic          <=  '0';
      en_nxt_reg_logic              <=  '0';
      ld_reg_bitmap                 <=  '0';
      dec_nxt_state                 <=  ERROR_STATE;
      ld_pc_dest_or_mul_32          <=  '0';
      pc_dest_or_mul_32             <=  '0';
      ld_state_update               <=  '0';
      state_update                  <=  '0';
      dec_addr_rdA                  <=  ( others => '0' );
      dec_en_rdA                    <=  '0';
      dec_addr_rdB                  <=  ( others => '0' );
      dec_en_rdB                    <=  '0';
      dec_addr_wrA                  <=  ( others => '0' );
      dec_addr_wrB                  <=  ( others => '0' );
      dec_en_wrB                    <=  '0';
      dec_en_wrA                    <=  '0';
      dec_en_rdPSR                  <=  '0';
      dec_CPSR_nSPSR                <=  '0';
      dec_addr_rdC                  <=  ( others => '0' );
      dec_en_rdC                    <=  '0';
      dec_imm_inst                  <=  '0';
      dec_immediate_value           <=  ( others => '0' );
      dec_shift_amount              <=  ( others => '0' );
      dec_shifter_opcode            <=  ( others => '0' );
      dec_src_shift_amnt            <=  '0';
      dec_shift_imm                 <=  '0';
      dec_Mdata_src_addr            <=  ( others => '0' );
      dec_Mdata_dim                 <=  ( others => '0' );
      dec_Mdata_src_out             <=  '0';
      dec_Mdata_sign                <=  '0';
      dec_Mdata_en                  <=  '0';
      dec_Mdata_rd_nWr              <=  '0';
      dec_alu_opcode                <=  ( others => '0' );
      dec_cond_code                 <=  ( others => '0' );
      dec_src_nxt_SPSR              <=  '0';
      dec_wr_SPSR_high              <=  '0';
      dec_wr_SPSR_low               <=  '0';
      dec_wr_high_CPSR              <=  '0';
      dec_wr_low_CPSR               <=  '0';
      dec_wr_nxt_cpsr               <=  '0';
      dec_src_nxt_CPSR              <=  ( others => '0' );
      dec_en_mult                   <=  '0';
      dec_signed_nUnsigned_mult     <=  '0';
      dec_HiLo_reg_src_mult         <=  '0';
      dec_wr_Rm_mult                <=  '0';
      dec_wr_Rs_mult                <=  '0';
      dec_wr_sum_mult               <=  '0';
      dec_nRst_sum_mult             <=  '0';
      dec_nRst_carry_mult           <=  '0';
      dec_vt_addr                   <=  ( others => '0' );
      dec_src_nxt_IA                <=  ( others => '0' );
      dec_addition_mult             <=  '0';
      dec_src_high_CPSR             <=  ( others => '0' );
    elsif ( prefetch_abort = '1' ) then
      int_op_nxt_reg_logic          <=  '0';
      en_nxt_reg_logic              <=  '0';
      ld_reg_bitmap                 <=  '0';
      dec_nxt_state                 <=  ERROR_STATE;
      ld_pc_dest_or_mul_32          <=  '0';
      pc_dest_or_mul_32             <=  '0';
      ld_state_update               <=  '0';
      state_update                  <=  '0';
      dec_addr_rdA                  <=  ( others => '0' );
      dec_en_rdA                    <=  '0';
      dec_addr_rdB                  <=  ( others => '0' );
      dec_en_rdB                    <=  '0';
      dec_addr_wrA                  <=  ( others => '0' );
      dec_addr_wrB                  <=  ( others => '0' );
      dec_en_wrB                    <=  '0';
      dec_en_wrA                    <=  '0';
      dec_en_rdPSR                  <=  '0';
      dec_CPSR_nSPSR                <=  '0';
      dec_addr_rdC                  <=  ( others => '0' );
      dec_en_rdC                    <=  '0';
      dec_imm_inst                  <=  '0';
      dec_immediate_value           <=  ( others => '0' );
      dec_shift_amount              <=  ( others => '0' );
      dec_shifter_opcode            <=  ( others => '0' );
      dec_src_shift_amnt            <=  '0';
      dec_shift_imm                 <=  '0';
      dec_Mdata_src_addr            <=  ( others => '0' );
      dec_Mdata_dim                 <=  ( others => '0' );
      dec_Mdata_src_out             <=  '0';
      dec_Mdata_sign                <=  '0';
      dec_Mdata_en                  <=  '0';
      dec_Mdata_rd_nWr              <=  '0';
      dec_alu_opcode                <=  ( others => '0' );
      dec_cond_code                 <=  ( others => '0' );
      dec_src_nxt_SPSR              <=  '0';
      dec_wr_SPSR_high              <=  '0';
      dec_wr_SPSR_low               <=  '0';
      dec_wr_high_CPSR              <=  '0';
      dec_wr_low_CPSR               <=  '0';
      dec_wr_nxt_cpsr               <=  '0';
      dec_src_nxt_CPSR              <=  ( others => '0' );
      dec_en_mult                   <=  '0';
      dec_signed_nUnsigned_mult     <=  '0';
      dec_HiLo_reg_src_mult         <=  '0';
      dec_wr_Rm_mult                <=  '0';
      dec_wr_Rs_mult                <=  '0';
      dec_wr_sum_mult               <=  '0';
      dec_nRst_sum_mult             <=  '0';
      dec_nRst_carry_mult           <=  '0';
      dec_vt_addr                   <=  ( others => '0' );
      dec_src_nxt_IA                <=  ( others => '0' );
      dec_addition_mult             <=  '0';
      dec_src_high_CPSR             <=  ( others => '0' );
    else  -- NO exception
--------------------------------------------------------------------------
--    DATA PROCESSING
--------------------------------------------------------------------------
      if (
        instruction(27 downto 26) = "00" and
        ( (instruction(25) = '1') or
          ( instruction(25) = '0' and instruction(4) = '0') or
          ( instruction(25) = '0' and instruction(4) = '1' and instruction(7) = '0' ) 
        )
      ) then

        --new
        int_op_nxt_reg_logic        <=  '0';
        en_nxt_reg_logic            <=  '0';
        ld_reg_bitmap               <=  '0';
        ld_pc_dest_or_mul_32        <=  '0';
        pc_dest_or_mul_32           <=  '0';
        ld_state_update             <=  '0';
        state_update                <=  '0';
        dec_addition_mult           <=  '0';

        dec_alu_opcode              <=  instruction(ALU_OPCODE_END downto ALU_OPCODE_SRT);
        dec_cond_code               <=  instruction(CC_END downto CC_SRT);
        dec_addr_wrA                <=  instruction(Rd_END downto Rd_SRT);
        dec_addr_wrB                <=  ( others => '0');
        dec_en_wrB                  <=  '0';
        dec_addr_rdC                <=  ( others => '0');
        dec_en_rdC                  <=  '0';
        if ( instruction(ALU_OPCODE_END downto ALU_OPCODE_SRT) = "1101" or    
             instruction(ALU_OPCODE_END downto ALU_OPCODE_SRT) = "1101" ) then
          dec_en_rdA                <=  '0';
        else
          dec_en_rdA                <=  '1';
        end if;
        dec_addr_rdA                <=  instruction(Rn_END downto Rn_SRT);
        dec_vt_addr                 <=  ( others => '0');
        dec_Mdata_src_addr          <=  ( others => '0');
        dec_Mdata_src_out           <=  '0'             ;
        dec_Mdata_dim               <=  ( others => '0');
        dec_Mdata_sign              <=  '0';
        dec_Mdata_en                <=  '0';
        dec_Mdata_rd_nWr            <=  '0';
        dec_CPSR_nSPSR              <=  '0';
        dec_en_rdPSR                <=  '0';
        dec_src_nxt_SPSR            <=  '0';
        dec_wr_SPSR_low             <=  '0';
        dec_wr_SPSR_high            <=  '0';
        dec_en_mult                 <=  '0';
        dec_signed_nUnsigned_mult   <=  '0';
        dec_HiLo_reg_src_mult       <=  '0';
        dec_wr_Rm_mult              <=  '0';
        dec_wr_Rs_mult              <=  '0';
        dec_wr_sum_mult             <=  '0';
        dec_nRst_sum_mult           <=  '1';
        dec_nRst_carry_mult         <=  '1';
        if ( instruction(25) = '1' ) then
          dec_addr_rdB              <=  ( others => '0');
          dec_en_rdB                <=  '0';
          dec_imm_inst              <=  '1';
          dec_immediate_value       <=  std_logic_vector(resize(unsigned(instruction(IMMED_8_END downto IMMED_8_SRT)),dec_immediate_value'length));
          dec_shift_amount          <=  std_logic_vector(resize(unsigned(instruction(ROT_IMM_END downto ROT_IMM_SRT)),dec_shift_amount'length));
          dec_shifter_opcode        <=  ROR_OP;
          dec_src_shift_amnt        <=  SHIFT_AMNT_FROM_IMM; -- IMMEDIATE_SHIFT
          dec_shift_imm             <=  '0';
        elsif ( instruction(4) = '0' ) then
          dec_addr_rdB              <=  instruction(Rm_END downto Rm_SRT);
          dec_en_rdB                <=  '1';
          dec_imm_inst              <=  '0';
          dec_immediate_value       <=  ( others => '0');
          dec_shift_amount          <=  std_logic_vector(resize(unsigned(instruction(SHIFT_IMM_END downto SHIFT_IMM_SRT)),dec_shift_amount'length));
          dec_shifter_opcode        <=
                                instruction(SHIFT_OPCODE_END downto SHIFT_OPCODE_SRT);
          dec_src_shift_amnt        <=  SHIFT_AMNT_FROM_IMM; --IMMEDIATE_SHIFT;
          dec_shift_imm             <=  '1';
        else -- case of register shift
          dec_addr_rdB              <=  instruction(Rm_END downto Rm_SRT);
          dec_en_rdB                <=  '1';
          dec_imm_inst              <=  '0';
          dec_immediate_value       <=  ( others => '0');
          dec_shift_amount          <=  std_logic_vector(resize(unsigned(instruction(SHIFT_IMM_END downto SHIFT_IMM_SRT)),dec_shift_amount'length));
          dec_shifter_opcode        <=
                                instruction(SHIFT_OPCODE_END downto SHIFT_OPCODE_SRT);
          dec_src_shift_amnt        <=  '0'; --IMMEDIATE_SHIFT;
          dec_shift_imm             <=  '1';
        end if; -- 3 format of a DATA PROCESSING
        if ( instruction(15 downto 12) = "1111" ) then
          dec_src_nxt_IA            <=  IA_FROM_ALU;
          dec_en_wrA                <=  '0';
          if ( instruction(S) = '1' ) then
            dec_wr_nxt_cpsr         <=  '1';
            dec_wr_low_CPSR         <=  '0';
            dec_src_nxt_CPSR        <=  nxt_CPSR_SPSR_SEL;
          else
            dec_wr_low_CPSR         <=  '0';
            dec_wr_nxt_cpsr         <=  '0';
            dec_src_nxt_CPSR        <=  (others => '0');
          end if; -- S bit
          dec_nxt_state             <=  JUMP;
        else
          if ( instruction(S) = '1' ) then
            dec_wr_high_CPSR        <= '1';
            dec_src_high_CPSR       <= FLAG_FROM_EXE;
          else
            dec_wr_high_CPSR        <= '0';
            dec_src_high_CPSR       <= ( others => '0');
          end if;
          dec_en_wrA                <=  '1';
          dec_wr_nxt_cpsr           <=  '0';
          dec_src_nxt_CPSR          <=  ( others => '0');
          dec_src_nxt_IA            <=  PC_SEQ;
          dec_nxt_state             <=  DISPATCHER;
        end if; -- Rd = R15
--------------------------------------------------------------------------
--    LOAD/STORE SINGLE WORD OR UNSIGNED BYTE 
--------------------------------------------------------------------------
      elsif (
        instruction(27 downto 26) = "01" and
        ( instruction(25) = '0' or
          (instruction(25) = '1' and instruction(4) = '0' )
        )
      ) then

        --new
        int_op_nxt_reg_logic        <=  '0';
        en_nxt_reg_logic            <=  '0';
        ld_reg_bitmap               <=  '0';
        ld_pc_dest_or_mul_32        <=  '0';
        pc_dest_or_mul_32           <=  '0';
        ld_state_update             <=  '0';
        state_update                <=  '0';
        dec_addition_mult           <=  '0';

        if ( instruction(U) = '1' ) then 
          dec_alu_opcode            <= ALU_ADD;
        else
          dec_alu_opcode            <= ALU_SUB;
        end if; -- U bit
        dec_cond_code               <=  instruction(CC_END downto CC_SRT);
        dec_addr_wrA                <=  instruction(Rn_END downto Rn_SRT);
        if ( instruction(P) = '0' ) then
          dec_en_wrA                <=  '1';
          dec_Mdata_src_addr        <=  A_BYPASS;
        else
          dec_Mdata_src_addr        <=  ALU_OUT;
          if ( instruction(W) = '1' ) then
            dec_en_wrA              <=  '1';
          else
            dec_en_wrA              <=  '0';
          end if;
        end if;
        dec_Mdata_sign              <=  UNSIGNED_ACCESS;
        if ( instruction(B) = '1' ) then
          dec_Mdata_dim             <=  BYTE;
        else
          dec_Mdata_dim             <=  WORD;
        end if;

        dec_addr_wrB                <=  instruction(Rd_END downto Rd_SRT);
        dec_addr_rdC                <=  instruction(Rd_END downto Rd_SRT);
        dec_en_rdC                  <=  not(instruction(L));
        dec_en_rdA                  <=  '1';
        dec_addr_rdA                <=  instruction(Rn_END downto Rn_SRT);
        dec_vt_addr                 <=  ( others => '0');
        dec_wr_nxt_cpsr             <=  '0';
        dec_src_nxt_CPSR            <=  ( others => '0');
        dec_Mdata_src_out           <=  NORMAL_RC;
        dec_Mdata_en                <=  '1';
        dec_Mdata_rd_nWr            <=  instruction(L);

        dec_wr_nxt_cpsr             <=  '0';
        dec_src_nxt_CPSR            <=  (others => '0');
        dec_src_nxt_SPSR            <=  '0';
        dec_wr_SPSR_low             <=  '0';
        dec_wr_SPSR_high            <=  '0';

        dec_en_mult                 <=  '0';
        dec_signed_nUnsigned_mult   <=  '0';
        dec_HiLo_reg_src_mult       <=  '0';
        dec_wr_Rm_mult              <=  '0';
        dec_wr_Rs_mult              <=  '0';
        dec_wr_sum_mult             <=  '0';
        dec_nRst_sum_mult           <=  '1';
        dec_nRst_carry_mult         <=  '1';

        if ( instruction(25) = '0' ) then
          dec_addr_rdB              <=  ( others => '0');
          dec_en_rdB                <=  '0';
          dec_imm_inst              <=  '1';
          dec_immediate_value       <=
                                  std_logic_vector(resize(unsigned(instruction(OFFSET_12_END downto OFFSET_12_SRT)),dec_immediate_value'length));
          dec_shift_amount          <=  ( others => '0');
          dec_shifter_opcode        <=  ROR_OP;
          dec_src_shift_amnt        <=  SHIFT_AMNT_FROM_IMM;
          dec_shift_imm             <=  '0';
        else
          dec_addr_rdB              <=  instruction(Rm_END downto Rm_SRT);
          dec_en_rdB                <=  '1';
          dec_imm_inst              <=  '0';
          dec_immediate_value       <=  ( others => '0');
          dec_shift_amount          <=  
                                  std_logic_vector(resize(unsigned(instruction(SHIFT_IMM_END downto SHIFT_IMM_SRT)),dec_shift_amount'length));
          dec_shifter_opcode        <=
                                  instruction(SHIFT_OPCODE_END downto SHIFT_OPCODE_SRT);
          dec_src_shift_amnt        <=  SHIFT_AMNT_FROM_IMM;
          dec_shift_imm             <=  '1';
        end if; -- 2 format of a DATA PROCESSING

        if ( instruction(15 downto 12) = "1111" ) then
          dec_src_nxt_IA            <=  ( others => '0');
          dec_en_wrB                <=  '0';
          dec_nxt_state             <=  PC_LD_EXE;
        else
          dec_en_wrB                <=  instruction(L);
          dec_src_nxt_IA            <=  PC_SEQ;
          dec_nxt_state             <=  DISPATCHER;
        end if; -- Rd = 15
      elsif (
        instruction(27 downto 25) = "000" and
        instruction(7) = '1' and
        instruction(4) = '1')
       then
--------------------------------------------------------------------------
--    LOAD SINGLE WORD OR UNSIGNED BYTE
--------------------------------------------------------------------------

        --new
        int_op_nxt_reg_logic        <=  '0';
        en_nxt_reg_logic            <=  '0';
        ld_reg_bitmap               <=  '0';
        ld_pc_dest_or_mul_32        <=  '0';
        pc_dest_or_mul_32           <=  '0';
        ld_state_update             <=  '0';
        state_update                <=  '0';
        dec_addition_mult               <=  '0';

        if ( instruction(U) = '1' ) then
          dec_alu_opcode            <= ALU_ADD;
        else
          dec_alu_opcode            <= ALU_SUB;
        end if; -- U bit
        dec_cond_code               <=  instruction(CC_END downto CC_SRT);
        dec_addr_wrA                <=  instruction(Rn_END downto Rn_SRT);
        if ( instruction(P) = '0' ) then
          dec_en_wrA                <=  '1';
          dec_Mdata_src_addr        <=  A_BYPASS;
        else
          dec_Mdata_src_addr        <=  ALU_OUT;
          if ( instruction(W) = '1' ) then
            dec_en_wrA              <=  '1';
          else
            dec_en_wrA              <=  '0';
          end if;
        end if;

        case instruction(SH_END downto SH_SRT) is
          when "00" =>
            dec_Mdata_sign          <=  '0';
            dec_Mdata_dim           <=  ( others => '0'); 
          when "01" =>
            dec_Mdata_sign          <=  UNSIGNED_ACCESS;
            dec_Mdata_dim           <=  HALF_WORD;
          when "10" =>
            dec_Mdata_sign          <=  SIGNED_ACCESS;
            dec_Mdata_dim           <=  BYTE;
          when "11" =>
            dec_Mdata_sign          <=  SIGNED_ACCESS;
            dec_Mdata_dim           <=  HALF_WORD;
          when others =>
            dec_Mdata_sign          <=  UNSIGNED_ACCESS;
            dec_Mdata_dim           <=  WORD;
        end case;

        dec_addr_wrB                <=  instruction(Rd_END downto Rd_SRT);
        dec_en_wrB                  <=  instruction(L);

        dec_src_nxt_IA              <=  PC_SEQ;

        dec_addr_rdC                <=  instruction(Rd_END downto Rd_SRT);
        dec_en_rdC                  <=  not(instruction(L));

        dec_en_rdA                  <=  '1';
        dec_addr_rdA                <=  instruction(Rn_END downto Rn_SRT);

        dec_vt_addr                 <=  ( others => '0');

        dec_wr_nxt_cpsr             <=  '0';
        dec_src_nxt_CPSR            <=  ( others => '0');

        dec_Mdata_src_out           <=  NORMAL_RC;

        dec_Mdata_en                <=  '1';
        dec_Mdata_rd_nWr            <=  instruction(L);

        dec_wr_nxt_cpsr             <=  '0';
        dec_src_nxt_CPSR            <=  (others => '0');
        dec_src_nxt_SPSR            <=  '0';
        dec_wr_SPSR_low             <=  '0';
        dec_wr_SPSR_high            <=  '0';

        dec_en_mult                 <=  '0';
        dec_signed_nUnsigned_mult   <=  '0';
        dec_HiLo_reg_src_mult       <=  '0';
        dec_wr_Rm_mult              <=  '0';
        dec_wr_Rs_mult              <=  '0';
        dec_wr_sum_mult             <=  '0';
        dec_nRst_sum_mult           <=  '1';
        dec_nRst_carry_mult         <=  '1';

        dec_shift_amount            <=  ( others => '0');
        dec_shifter_opcode          <=  ROR_OP;
        dec_src_shift_amnt          <=  SHIFT_AMNT_FROM_IMM;
        dec_shift_imm               <=  '0';

        if ( instruction(B) = '1' ) then
          dec_addr_rdB              <=  ( others => '0');
          dec_en_rdB                <=  '0';
          dec_imm_inst              <=  '1';
          dec_immediate_value       <=
          x"000000" & instruction(OFFSET_H_END downto OFFSET_H_SRT) &
          instruction(OFFSET_L_END downto OFFSET_L_SRT); 
        else
          dec_addr_rdB              <=  instruction(Rm_END downto Rm_SRT);
          dec_en_rdB                <=  '1';
          dec_imm_inst              <=  '0';
          dec_immediate_value       <=  ( others => '0');
        end if; -- 2 format of a DATA TRANSFER
        dec_nxt_state               <=  DISPATCHER;
--------------------------------------------------------------------------
--    MULTIPLE LOAD OR STORE
--------------------------------------------------------------------------
      elsif ( instruction(27 downto 25) = "100" ) then
        --new
        int_op_nxt_reg_logic        <=  '0';
        en_nxt_reg_logic            <=  '1';
        ld_reg_bitmap               <=  '1';
        ld_pc_dest_or_mul_32        <=  '1';
        pc_dest_or_mul_32           <=  instruction(15);
        ld_state_update             <=  '1';
        state_update                <=  instruction(22);
        dec_addition_mult               <=  '0';

        case instruction(24 downto 23) is
--              PU
          when "00" =>
            if ( zero_flag = '1' ) then
              if ( instruction(L) = '1' ) then
                dec_nxt_state         <=  LDM_1_CORR_SUB;
              else
                dec_nxt_state         <=  STM_1_CORR_SUB;
              end if;
            else
              if ( instruction(L) = '1' ) then
                dec_nxt_state         <=  LDM_N_CORR_SUB;
              else
                dec_nxt_state         <=  STM_N_CORR_SUB;
              end if;
            end if;
            dec_alu_opcode          <=  ALU_SUB;
            dec_immediate_value     <=  std_logic_vector(resize(unsigned(number_of_registers_dec),dec_immediate_value'length));
          when "01" =>
            if ( zero_flag = '1' ) then
              if ( instruction(L) = '1' ) then
                dec_nxt_state         <=  LDM_1_CORR_ADD;
              else
                dec_nxt_state         <=  STM_1_CORR_ADD;
              end if;
            else
              if ( instruction(L) = '1' ) then
                dec_nxt_state         <=  LDM_N_CORR_ADD;
              else
                dec_nxt_state         <=  STM_N_CORR_ADD;
              end if;
            end if;
            dec_alu_opcode          <=  ALU_ADD;
            dec_immediate_value     <=  ( others => '0' );
          when "10" =>
            if ( zero_flag = '1' ) then
              if ( instruction(L) = '1' ) then
                dec_nxt_state         <=  LDM_1_CORR_SUB;
              else
                dec_nxt_state         <=  STM_1_CORR_SUB;
              end if;
            else
              if ( instruction(L) = '1' ) then
                dec_nxt_state         <=  LDM_N_CORR_SUB;
              else
                dec_nxt_state         <=  STM_N_CORR_SUB;
              end if;
            end if;
            dec_alu_opcode          <=  ALU_SUB;
            dec_immediate_value     <=  std_logic_vector(resize(unsigned(number_of_registers),dec_immediate_value'length));
          when "11" =>
            if ( zero_flag = '1' ) then
              dec_nxt_state         <=  LDM_1_CORR_ADD;
            else
              dec_nxt_state         <=  LDM_N_CORR_ADD;
            end if;
            dec_alu_opcode          <=  ALU_ADD;
            dec_immediate_value     <=  ( others => '0' );
            dec_immediate_value(0)  <=  '1';
          when others =>
            dec_nxt_state           <=  ERROR_STATE;
            dec_alu_opcode          <=  ( others => '0');
            dec_immediate_value     <=  ( others => '0' );
        end case;

        dec_cond_code               <=  instruction(CC_END downto CC_SRT);
        dec_addr_wrA                <=  instruction(Rn_END downto Rn_SRT);
        dec_en_wrA                  <=  '0';

        dec_Mdata_src_addr          <=  ALU_OUT;
        dec_Mdata_sign              <=  UNSIGNED_ACCESS;
        dec_Mdata_dim               <=  WORD;

        dec_addr_wrB                <=  next_reg_addr;
        dec_addr_rdC                <=  next_reg_addr;
        dec_en_rdC                  <=  not(instruction(L));

        dec_en_rdA                  <=  '1';
        dec_addr_rdA                <=  instruction(Rn_END downto Rn_SRT);

        dec_vt_addr                 <=  ( others => '0');

        dec_wr_nxt_cpsr             <=  '0';
        dec_src_nxt_CPSR            <=  ( others => '0');

        dec_Mdata_src_out           <=  NORMAL_RC;

        dec_Mdata_en                <=  '1';
        dec_Mdata_rd_nWr            <=  instruction(L);

        dec_wr_nxt_cpsr             <=  '0';
        dec_src_nxt_CPSR            <=  ( others => '0');

        dec_src_nxt_SPSR            <=  '0';
        dec_wr_SPSR_low             <=  '0';
        dec_wr_SPSR_high             <=  '0';

        dec_en_mult                 <=  '0';
        dec_signed_nUnsigned_mult   <=  '0';
        dec_HiLo_reg_src_mult       <=  '0';
        dec_wr_Rm_mult              <=  '0';
        dec_wr_Rs_mult              <=  '0';
        dec_wr_sum_mult             <=  '0';
        dec_nRst_sum_mult           <=  '1';
        dec_nRst_carry_mult         <=  '1';

        dec_addr_rdB                <=  ( others => '0');
        dec_en_rdB                  <=  '0';
        dec_imm_inst                <=  '1';
        dec_shift_amount            <=
                                  std_logic_vector(to_unsigned(2,dec_shift_amount'length));
        dec_shifter_opcode          <=  SLL_OP;
        dec_src_shift_amnt          <=  IMMEDIATE_SHIFT;
        dec_shift_imm               <=  '0';

        dec_src_nxt_IA              <=  ( others => '0');
        if ( zero_flag = '1' and instruction(15) = '1' ) then
          dec_en_wrB                <=  '0';
        else
          dec_en_wrB                <=  '1';
        end if;
      elsif (
        instruction(27 downto 25) = "101"
      ) then
        int_op_nxt_reg_logic          <=  '0';
        en_nxt_reg_logic              <=  '0';
        ld_reg_bitmap                 <=  '0';
        if ( instruction(24) = '1' ) then -- LINK
          dec_nxt_state               <=  LINK_BRANCH;
        else
          dec_nxt_state               <=  JUMP;
        end if;
        ld_pc_dest_or_mul_32          <=  '0';
        pc_dest_or_mul_32             <=  '0';
        ld_state_update               <=  '0';
        state_update                  <=  '0';
        dec_addr_rdA                  <=  "1111";
        dec_en_rdA                    <=  '1';
        dec_addr_rdB                  <=  ( others => '0' );
        dec_en_rdB                    <=  '0';
        dec_addr_wrA                  <=  ( others => '0' );
        dec_addr_wrB                  <=  ( others => '0' );
        dec_en_wrB                    <=  '0';
        dec_en_wrA                    <=  '0';
        dec_en_rdPSR                  <=  '0';
        dec_CPSR_nSPSR                <=  '0';
        dec_addr_rdC                  <=  ( others => '0' );
        dec_en_rdC                    <=  '0';
        dec_imm_inst                  <=  '1';
        dec_immediate_value           <=  std_logic_vector(resize(signed(instruction(23 downto 0)),dec_immediate_value'length));
        dec_shift_amount              <=  "000010";
        dec_shifter_opcode            <=  SLL_OP;
        dec_src_shift_amnt            <=  SHIFT_AMNT_FROM_IMM;
        dec_shift_imm                 <=  '1';
        dec_Mdata_src_addr            <=  ( others => '0' );
        dec_Mdata_dim                 <=  ( others => '0' );
        dec_Mdata_src_out             <=  '0';
        dec_Mdata_sign                <=  '0';
        dec_Mdata_en                  <=  '0';
        dec_Mdata_rd_nWr              <=  '0';
        dec_alu_opcode                <=  "0100";
        dec_cond_code                 <=  instruction(CC_END downto CC_SRT);
        dec_src_nxt_SPSR              <=  '0';
        dec_wr_SPSR_high              <=  '0';
        dec_wr_SPSR_low               <=  '0';
        dec_wr_high_CPSR              <=  '0';
        dec_wr_low_CPSR               <=  '0';
        dec_wr_nxt_cpsr               <=  '0';
        dec_src_nxt_CPSR              <=  ( others => '0' );
        dec_en_mult                   <=  '0';
        dec_signed_nUnsigned_mult     <=  '0';
        dec_HiLo_reg_src_mult         <=  '0';
        dec_wr_Rm_mult                <=  '0';
        dec_wr_Rs_mult                <=  '0';
        dec_wr_sum_mult               <=  '0';
        dec_nRst_sum_mult             <=  '1';
        dec_nRst_carry_mult           <=  '1';
        dec_vt_addr                   <=  ( others => '0' );
        dec_src_nxt_IA                <=  IA_FROM_ALU;
        dec_addition_mult             <=  '0';
        dec_src_high_CPSR             <=  ( others => '0' );
      else
        int_op_nxt_reg_logic          <=  '0';
        en_nxt_reg_logic              <=  '0';
        ld_reg_bitmap                 <=  '0';
        dec_nxt_state                 <=  ERROR_STATE;
        ld_pc_dest_or_mul_32          <=  '0';
        pc_dest_or_mul_32             <=  '0';
        ld_state_update               <=  '0';
        state_update                  <=  '0';
        dec_addr_rdA                  <=  ( others => '0' );
        dec_en_rdA                    <=  '0';
        dec_addr_rdB                  <=  ( others => '0' );
        dec_en_rdB                    <=  '0';
        dec_addr_wrA                  <=  ( others => '0' );
        dec_addr_wrB                  <=  ( others => '0' );
        dec_en_wrB                    <=  '0';
        dec_en_wrA                    <=  '0';
        dec_en_rdPSR                  <=  '0';
        dec_CPSR_nSPSR                <=  '0';
        dec_addr_rdC                  <=  ( others => '0' );
        dec_en_rdC                    <=  '0';
        dec_imm_inst                  <=  '0';
        dec_immediate_value           <=  ( others => '0' );
        dec_shift_amount              <=  ( others => '0' );
        dec_shifter_opcode            <=  ( others => '0' );
        dec_src_shift_amnt            <=  '0';
        dec_shift_imm                 <=  '0';
        dec_Mdata_src_addr            <=  ( others => '0' );
        dec_Mdata_dim                 <=  ( others => '0' );
        dec_Mdata_src_out             <=  '0';
        dec_Mdata_sign                <=  '0';
        dec_Mdata_en                  <=  '0';
        dec_Mdata_rd_nWr              <=  '0';
        dec_alu_opcode                <=  ( others => '0' );
        dec_cond_code                 <=  ( others => '0' );
        dec_src_nxt_SPSR              <=  '0';
        dec_wr_SPSR_high              <=  '0';
        dec_wr_SPSR_low               <=  '0';
        dec_wr_high_CPSR              <=  '0';
        dec_wr_low_CPSR               <=  '0';
        dec_wr_nxt_cpsr               <=  '0';
        dec_src_nxt_CPSR              <=  ( others => '0' );
        dec_en_mult                   <=  '0';
        dec_signed_nUnsigned_mult     <=  '0';
        dec_HiLo_reg_src_mult         <=  '0';
        dec_wr_Rm_mult                <=  '0';
        dec_wr_Rs_mult                <=  '0';
        dec_wr_sum_mult               <=  '0';
        dec_nRst_sum_mult             <=  '0';
        dec_nRst_carry_mult           <=  '0';
        dec_vt_addr                   <=  ( others => '0' );
        dec_src_nxt_IA                <=  ( others => '0' );
        dec_addition_mult             <=  '0';
        dec_src_high_CPSR             <=  ( others => '0' );
      end if; --INSTRUCTION
    end if; -- primary if
  end process;

end architecture BHV;
