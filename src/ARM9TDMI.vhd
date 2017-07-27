library IEEE;
use IEEE.std_logic_1164.all;

library WORK;
use WORK.ARM_pack.all;

--------------------------------------------------------------------------------
--  ENTITY                                                                    --
--------------------------------------------------------------------------------
entity ARM9TDMI is
  port (
    ------------------------------------------------------------------------
    --  INSTRUCTION MEMORY INTERFACE SIGNALS                              --
    ------------------------------------------------------------------------
    IA          : out ADDR_BUS_t;                                               -- Output Instruction Address Bus.
    IABE        : in  std_logic;                                                -- Instruction Address Bus Enable.
    IABORT      : in  std_logic;                                                -- Instruction Abort.
    ID          : in  ARM_INSTR_t;                                              -- Instruction Data Bus.
    InM         : out CPSR_MODE_t;                                              -- Instruction Mode.
    InMREQ      : out std_logic;                                                -- Not Instruction Memory Request.
    InTRANS     : out std_logic;                                                -- Not Memory Translate.
    ISEQ        : out std_logic;                                                -- Instruction Sequential Address.
    ITBIT       : out std_logic;                                                -- Instruction Thumb Bit.

    ------------------------------------------------------------------------
    --  DATA MEMORY INTERFACE SIGNALS                                     --
    ------------------------------------------------------------------------
    DA          : out ADDR_BUS_t;                                               -- Data Address Bus.
    DABE        : in  std_logic;                                                -- Data Address Bus Enable.
    DABORT      : in  std_logic;                                                -- Data Abort.
    DD          : out DATA_BUS_t;                                               -- Data Output Bus.
    DDBE        : in  std_logic;                                                -- Data Data Bus Enable.
    DDEN        : out std_logic;                                                -- Data Data Bus Output Enabled.
    DDIN        : in  DATA_BUS_t;                                               -- Data Input Bus.
    DLOCK       : out std_logic;                                                -- Data Lock.
    DMAS        : out std_logic_vector ( 1 downto 0);                           -- Data Memory Access Size.
    DMORE       : out std_logic;                                                -- Data More.
    DnM         : out CPSR_MODE_t;                                              -- Data Mode.
    DnMREQ      : out std_logic;                                                -- Not Data Memory Request.
    DnRW        : out std_logic;                                                -- Output Data not Read, Write.
    DnTRANS     : out std_logic;                                                -- Data Not Memory Translate.
    DSEQ        : out std_logic;                                                -- Data Sequential Address.

    ------------------------------------------------------------------------
    --  COPROCESSOR INTERFACE SIGNALS                                     --
    ------------------------------------------------------------------------
    -- CHSD        : in  std_logic_vector ( 1 downto 0);                           -- Input Coprocessor Handshake Decode.
    -- CHSE        : in  std_logic_vector ( 1 downto 0);                           -- Input Coprocessor Handshake Execute.
    -- LATECANCEL  : out std_logic;                                                -- Output Coprocessor Late Cancel.
    -- PASS        : out std_logic;                                                -- Coprocessor PASS.

    ------------------------------------------------------------------------
    --  JTAG AND TAP CONTROLLER SIGNALS                                   --
    ------------------------------------------------------------------------
    -- DRIVEOUTBS  : out std_logic;                                                -- Boundary Scan Cell Enable.
    -- ECAPCLKBS   : out std_logic;                                                -- Extest Capture Clock for Boundary Scan.
    -- ICAPCLKBS   : out std_logic;                                                -- Intest Capture Clock.
    -- IR          : out std_logic_vector ( 3 downto 0);                           -- Tap Controller Instruction Register.
    -- PCLKBS      : out std_logic;                                                -- Boundary Scan Update Clock.
    -- RSTCLKBS    : out std_logic;                                                -- Boundary Scan Reset Clock.
    -- SCREG       : out std_logic_vector ( 4 downto 0);                           -- Scan Chain Register.
    -- SDIN        : out std_logic;                                                -- Boundary Scan Serial Input Data.
    -- SDOUTBS     : in  std_logic;                                                -- Boundary Scan Serial Output Data.
    -- SHCLK1BS    : out std_logic;                                                -- Boundary Scan Shift Clock Phase 1.
    -- SHCLK2BS    : out std_logic;                                                -- Boundary Scan Shift Clock Phase 2.
    -- TAPID       : in  std_logic_vector (31 downto 0);                           -- TAP Identification.
    -- TAPSM       : out std_logic_vector ( 3 downto 0);                           -- TAP Controller State Machine.
    -- TCK         : in  std_logic;                                                -- The JTAG clock (the test clock).
    -- TCK1        : out std_logic;                                                -- TCK, Phase 1.
    -- TCK2        : out std_logic;                                                -- TCK, Phase 2.
    -- TDI         : in  std_logic;                                                -- Test Data Input, the JTAG serial input.
    -- TDO         : out std_logic;                                                -- Test Data Output, the JTAG serial output.
    -- nTDOEN      : out std_logic;                                                -- Not TDO Enable.
    -- TMS         : in  std_logic;                                                -- Test Mode Select.
    -- nTRST       : in  std_logic;                                                -- Not Test Reset

    ------------------------------------------------------------------------
    --  DEBUG SIGNALS                                                     --
    ------------------------------------------------------------------------
    -- COMMRX      : out std_logic;                                                -- Communications Channel Receive.
    -- COMMTX      : out std_logic;                                                -- Communications Channel Transmit.
    -- DBGACK      : out std_logic;                                                -- Debug Acknowledge.
    -- DBGEN       : in  std_logic;                                                -- Debug Enable.
    -- DBGRQI      : out std_logic;                                                -- Internal Debug Request.
    -- DEWPT       : in  std_logic;                                                -- Data Watchpoint.
    -- EDBGRQ      : in  std_logic;                                                -- External Debug Request.
    -- EXTERN0     : in  std_logic;                                                -- External Input 0.
    -- EXTERN1     : in  std_logic;                                                -- External Input 1.
    -- IEBKPT      : in  std_logic;                                                -- Instruction Breakpoint.
    -- INSTREXEC   : out std_logic;                                                -- Instruction Executed.
    -- RANGEOUT0   : out std_logic;                                                -- EmbeddedICE Rangeout 0.
    -- RANGEOUT1   : out std_logic;                                                -- EmbeddedICE Rangeout 1.
    -- TBE         : in  std_logic;                                                -- Test Bus Enable.

    ------------------------------------------------------------------------
    --  MISCELLANEOUS SIGNALS                                             --
    ------------------------------------------------------------------------
    BIGEND      : in  std_logic;                                                -- Big-Endian Configuration.
    ECLK        : out std_logic;                                                -- External Clock.
    nFIQ        : in  std_logic;                                                -- Not Fast Interrupt request.
    GCLK        : in  std_logic;                                                -- Clock.
    HIVECS      : in  std_logic;                                                -- High Vectors Configuration.
    nIRQ        : in  std_logic;                                                -- Not Interrupt Request.
    ISYNC       : in  std_logic;                                                -- Synchronous Interrupts.
    nRESET      : in  std_logic;                                                -- Not Reset.
    nWAIT       : in  std_logic;                                                -- Not Wait.
    UNIEN       : in  std_logic                                                 -- Unidirectional Bus Enable.
  );
end entity ARM9TDMI;

--------------------------------------------------------------------------------
--  ARCHITECTURE                                                              --
--------------------------------------------------------------------------------
architecture STR of ARM9TDMI is

  component DFF  is
    port (
      D     : in  std_logic;
      Q     : out std_logic;
      clk   : in std_logic;
      nRst  : in std_logic
    );
  end component;

  component REG_NEGEDGE_GEN is
    generic (N : natural := 32);
    port (
      CLK   : in  std_logic;
      nRST  : in  std_logic;
      EN    : in  std_logic;
      D     : in  std_logic_vector (N-1 downto 0);
      Q     : out std_logic_vector (N-1 downto 0)
    );
  end component REG_NEGEDGE_GEN;

  component FETCH is
    port (
      CLK   : in  std_logic;

      --Input from processor PINS
      nRESET            : in  std_logic;                      --Not Reset
      nIRQ              : in  std_logic;                      --Not Interrupt Request
      nFIQ              : in  std_logic;                      --Not Fast Interrupt request
      BIGEND            : in  std_logic;                      --Big-Endian configration
      HIVECS            : in  std_logic;                      --Speicify low or high exception address

      --Input from datpath
      ALU_OUTPUT        : in  DATA_BUS_t;                     --Needed for IA and NEXT CPSR
      SPSR              : in  std_logic_vector(7 downto 0);   --Least significant byte of SPSR

      --Input from control unit
      DEC_SRC_NXT_IA    : in  std_logic_vector(1 downto 0);   --Next Instruction address mux selector
      DEC_WR_IA         : in  std_logic;                      --Enable write of instruction address register
      DEC_SRC_NXT_CPSR  : in  std_logic_vector(1 downto 0);   --Next CPSR value mux selector
      DEC_WR_NXT_CPSR   : in  std_logic;                      --Enable write of NEXT CPSR
      DEC_WR_OPCODE     : in  std_logic;                      --Enable write of pipeline register Fetch->Decode
      EXCEPTION_ADDR    : in  std_logic_vector(2 downto 0);   --Needed by NEXT CPSR to generate correct cpu mode frm execption addr

      --Output for decode stage
      IA_INC            : out ADDR_BUS_t;                     --Instruction address + 4, equal to PC+8. Must be loaded by reg. file
      OPCODE            : out OPCODE_t;                       --Contains ID + nIRQ + nFIQ + DABORT + IABORT
      NEXT_CPSR_Q       : out std_logic_vector(7 downto 0);   --NEXT CPSR value, needed by CPSR to be loaded

      --Instruction memory interface
      IA                : out ADDR_BUS_t;                     -- Instruction Address Bus. This is the processor instruction address bus
      InM               : out CPSR_MODE_t;                    -- Instruction Mode. Current mode of processor (last 5 bits of CPSR)
      InMREQ            : out std_logic;                      -- Not Instruction Memory Request. When Low request a memory access
      InTRANS           : out std_logic;                      -- Not Memory Translate. 0 when user mode, 1 when privileged mode
      ISEQ              : out std_logic;                      -- Instruction sequential address.

      ID                : in  ARM_INSTR_t;                    -- Instruction Data Bus
      IABE              : in  std_logic;                      -- Instruction Address Bus Enable.
      IABORT            : in  std_logic;                      -- Instruction Abort. Set to 1 when memory access is not allowed.

      --Data memory interface
      DABORT    : in  std_logic;                              -- Data Abort.
      DDIN      : in  DATA_BUS_t                              -- Data Output Bus.
    );
  end component FETCH;

  component UPDATE_FLAG is
    port (
      N_EXE         : in  std_logic                   ;
      C_EXE         : in  std_logic                   ;
      Z_EXE         : in  std_logic                   ;
      V_EXE         : in  std_logic                   ;
      PREV_Z        : in  std_logic                   ;
      LONG_MUL      : in  std_logic                   ;
      SPSR_flag     : in  std_logic_vector(3 downto 0);
      ALU_OUT_flag  : in  std_logic_vector(3 downto 0);
      SRC_FLAG      : in  std_logic_vector(1 downto 0);
      NZCV_nxt      : out std_logic_vector(3 downto 0)
    );
  end component UPDATE_FLAG;

  component REGBANK_3R2W is
    port (
      CLK       : in  std_logic;
      nRST      : in  std_logic;

      WEN1      : in  std_logic;                                                  -- Write Enable 1
      WEN2      : in  std_logic;                                                  -- Write Enable 2

      RADDR1    : in  REG_ADDR_t;                                                 -- Read Address 1 -> A Bus
      RADDR2    : in  REG_ADDR_t;                                                 -- Read Address 2 -> B Bus
      RADDR3    : in  REG_ADDR_t;                                                 -- Read Address 3 -> C Bus
      WADDR1    : in  REG_ADDR_t;                                                 -- Write Address 1
      WADDR2    : in  REG_ADDR_t;                                                 -- Write Address 2

      RDATA1    : out DATA_BUS_t;                                                 -- Read Data 1
      RDATA2    : out DATA_BUS_t;                                                 -- Read Data 2
      RDATA3    : out DATA_BUS_t;                                                 -- Read Data 3
      WDATA1    : in  DATA_BUS_t;                                                 -- Write Data 1
      WDATA2    : in  DATA_BUS_t;                                                 -- Write Data 2

      USR_MODE  : in  std_logic;                                                  -- Force user mode access to registers

      CPSR_FM   : in  std_logic_vector (3 downto 0);                              -- CPSR Field Mask Write Enable
      SPSR_FM   : in  std_logic_vector (3 downto 0);                              -- SPSR Field Mask Write Enable
      CPSR_IN   : in  DATA_BUS_t;                                                 -- CPSR Input Port
      SPSR_IN   : in  DATA_BUS_t;                                                 -- SPSR Input Port
      CPSR_OUT  : out DATA_BUS_t;                                                 -- CPSR Output Port
      SPSR_OUT  : out DATA_BUS_t;                                                 -- SPSR Output Port

      THUMB_SET : in  std_logic;                                                  -- Thumb State Set
      THUMB_RST : in  std_logic;                                                  -- Thumb State Reset
      IRQ_SET   : in  std_logic;                                                  -- IRQ Enable
      IRQ_RST   : in  std_logic;                                                  -- IRQ Disable
      FIQ_SET   : in  std_logic;                                                  -- FIQ Enable
      FIQ_RST   : in  std_logic;                                                  -- FIQ Disable

      PC_WE     : in  std_logic;                                                  -- PC Write Enable
      PC_IN     : in  DATA_BUS_t;                                                 -- PC Input Port
      PC_OUT    : out DATA_BUS_t                                                  -- PC Output Port
    );
  end component REGBANK_3R2W; -- REGBANK_3R2W

  component FORWARDING_UNIT is
    port (

      DEC_ADDR_rdA      : in  REG_ADDR_t;                     --Read address of read port A
      DEC_ADDR_rdB      : in  REG_ADDR_t;                     --Read address of read port B
      DEC_EN_rdA        : in  std_logic;                      --1 if on decode read port A is read
      DEC_EN_rdB        : in  std_logic;                      --1 if on decode read port B is read

      EXE_ADDR_wrA      : in  REG_ADDR_t;                     --Address of register that instruction in execute stage will write on port A
      MEM_ADDR_wrA      : in  REG_ADDR_t;                     --Address of register that instruction in memory  stage will write on port A
      EXE_EN_wrA        : in  std_logic;                      --1 if the instruction in the exe stage WILL write on port A
      MEM_EN_wrA        : in  std_logic;                      --1 if the instruction in the mem stage WILL write on port A

      EXE_ADDR_wrB      : in  REG_ADDR_t;                     --Address of register that instruction in execute stage will write on port B
      MEM_ADDR_wrB      : in  REG_ADDR_t;                     --Address of register that instruction in memory  stage will write on port B
      EXE_EN_wrB        : in  std_logic;                      --1 if the instruction in the exe stage WILL write on port B
      MEM_EN_wrB        : in  std_logic;                      --1 if the instruction in the mem stage WILL write on port B

      IMM_INST          : in  std_logic;                      --Tell if the instruction require an immediate operand
      EN_rdPSR          : in  std_logic;                      --Tell if the instruction will read CPSR or SPSR
      CPSR_nSPSR        : in  std_logic;                      --Tell which PSR will be read among CPSR and SPSR
      MDATA_DIM         : in  std_logic_vector(1 downto 0);   --Tell memory access size. If not 32 an additional stall is needed


      A_DATA_SEL        : out std_logic_vector(2 downto 0);   --Mux selector of operand A
      B_DATA_SEL        : out std_logic_vector(2 downto 0);   --Mux selector of operand B
      STALL             : out std_logic                       --Tell if forwarding is not possible and stall is needed

    );
  end component FORWARDING_UNIT;

  component control_unit is
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
  end component ;


  component DEC_OUT_STAGE  is
    port (
      CLK               : in  std_logic                   ;
      nRST              : in  std_logic                   ;
      STALL             : in  std_logic                   ;
      EN_RDA            : in  std_logic                   ;
      EN_RDB            : in  std_logic                   ;

      SPSR              : in  DATA_BUS_t                  ;
      CPSR              : in  DATA_BUS_t                  ;
      A_RDATA           : in  DATA_BUS_t                  ;
      B_RDATA           : in  DATA_BUS_t                  ;
      IMMEDIATE         : in  DATA_BUS_t                  ;
      ALU_OUT_EXE       : in  DATA_BUS_t                  ;
      ALU_OUT_MEM       : in  DATA_BUS_t                  ;
      DATA_MEM_OUT      : in  DATA_BUS_t                  ;


      A_DATA_SEL        : in  std_logic_vector(2 downto 0); --Mux selector of operand A
      B_DATA_SEL        : in  std_logic_vector(2 downto 0); --Mux selector of operand B
      A_OUT             : out DATA_BUS_t                  ;
      B_OUT             : out DATA_BUS_t
    );
  end component;


  component DATA_MEMORY_SIGNAL_GENERATION is
    port (
      clk               : in  std_logic                   ;
      nRst              : in  std_logic                   ;
      Mdata_en          : in  std_logic                   ;
      dec_Mdata_en      : in  std_logic                   ;
      en_rdC            : in  std_logic                   ;
      Mdata_rd_nWr      : in  std_logic                   ;
      Mdata_src_addr    : in  std_logic_vector(1 downto 0);
      dec_Mdata_src_addr: in  std_logic_vector(1 downto 0);
      Mdata_dim         : in  std_logic_vector(1 downto 0);
      CPSR_mode         : in  std_logic_vector(4 downto 0);

      DDEN              : out std_logic                   ;
      DLOCK             : out std_logic                   ;
      DMAS              : out std_logic_vector(1 downto 0);
      DMORE             : out std_logic                   ;
      DSEQ              : out std_logic                   ;
      DnM               : out std_logic_vector(4 downto 0);
      DnMREQ            : out std_logic                   ;
      DnRW              : out std_logic                   ;
      DnTRANS           : out std_logic
    );
  end component DATA_MEMORY_SIGNAL_GENERATION;

  component BYTE_WORD_REPLICATION is
    port (
      data_in     :  in   std_logic_vector(31 downto 0);
      Mdata_dim   :  in   std_logic_vector( 1 downto 0);
      data_out    :  out  std_logic_vector(31 downto 0)
    );
  end component BYTE_WORD_REPLICATION;

  component BYTE_ROT_SIGN_EXT is
    port (
      data_in     :  in   std_logic_vector(31 downto 0);
      Mdata_dim   :  in   std_logic_vector( 1 downto 0);
      Mdata_sign  :  in   std_logic                    ;
      data_out    :  out  std_logic_vector(31 downto 0)
    );
  end component;

  component EXECUTE is
    port (
      CLK                         : in  std_logic;
      nRST                        : in  std_logic;

      --ALU
      A                           : in  DATA_BUS_t;
      B                           : in  DATA_BUS_t;
      ALU_OPCODE                  : in  std_logic_vector(3 downto 0);
      COND_CODE                   : in  DATA_PROC_OP_t;
      MDATA_SRC_ADDR              : in  std_logic_vector(1 downto 0);
      N_in                        : in  std_logic;
      C_in                        : in  std_logic;
      Z_in                        : in  std_logic;
      V_in                        : in  std_logic;
      A_PASS                      : in  std_logic;
      B_PASS                      : in  std_logic;
      OP_A_MUX_SEL                : in  std_logic;
      OP_B_MUX_SEL                : in  std_logic;

      --MUL
      EN_MULT                     : in  std_logic;
      SIGNED_NUNSIGNED_MULT       : in  std_logic;
      HILO_REG_SRC_MULT           : in  std_logic;
      WR_RM_MULT                  : in  std_logic;
      WR_RS_MULT                  : in  std_logic;
      WR_SUM_MULT                 : in  std_logic;
      NRST_SUM_MULT               : in  std_logic;
      NRST_CARRY_MULT             : in  std_logic;

      --SHIFT
      SHIFT_AMOUNT                : in  SHIFT_BUS_t;                  --Immediate shift amount (not from register)
      SHIFT_OPCODE                : in  std_logic_vector(1 downto 0);
      SHIFT_SRC_AMOUNT            : in  std_logic;
      SHIFT_IMM                   : in  std_logic;

      --OUTPUT
      MDATA_ADDR                  : out DATA_BUS_t;
      ALU_OUTPUT                  : out DATA_BUS_t;
      TO_BE_EXECUTED              : out std_logic;
      N_out                       : out std_logic;
      C_out                       : out std_logic;
      Z_out                       : out std_logic;
      V_out                       : out std_logic;
      EARLY_FINISH                : out std_logic

    );
  end component EXECUTE;





  signal  ICLK                      :  std_logic                      ;

  --signal  SPSR_int                  :  std_logic_vector(7 downto 0)   ;
  signal  DEC_SRC_NXT_IA_int        :  std_logic_vector(1 downto 0)   ;
  signal  DEC_WR_IA_int             :  std_logic                      ;
  signal  DEC_SRC_NXT_CPSR_int      :  std_logic_vector(1 downto 0)   ;
  signal  DEC_WR_NXT_CPSR_int       :  std_logic                      ;
  signal  DEC_WR_OPCODE_int         :  std_logic                      ;
  signal  EXCEPTION_ADDR_int        :  std_logic_vector(2 downto 0)   ;
  signal  DEC_PC_int                :  std_logic_vector(31 downto 0)   ;
  signal  DEC_INPUT_int             :  OPCODE_t                       ;
  signal  NXT_CPSR_Q_int            :  std_logic_vector(7 downto 0)   ;

  signal  ALU_OUTPUT_MEM_int        :  DATA_BUS_t                     ;
  signal  ALU_OUTPUT_WB_int         :  DATA_BUS_t                     ;

  signal  A_DATA_SEL_int            :  std_logic_vector(2 downto 0);
  signal  B_DATA_SEL_int            :  std_logic_vector(2 downto 0);

  signal  A_int                     :  DATA_BUS_t                     ;
  signal  B_int                     :  DATA_BUS_t                     ;
  signal  ALU_OPCODE_int            :  std_logic_vector(3 downto 0)   ;
  signal  COND_CODE_int             :  DATA_PROC_OP_t                 ;
  --signal  MDATA_SRC_ADDR_int        :  std_logic_vector(1 downto 0)   ;
  --signal  N_in_int                  :  std_logic                      ;
  --signal  C_in_int                  :  std_logic                      ;
  --signal  Z_in_int                  :  std_logic                      ;
  --signal  V_in_int                  :  std_logic                      ;
  --signal  A_PASS_int                :  std_logic                      ;
  --signal  B_PASS_int                :  std_logic                      ;
  --signal  OP_A_MUX_SEL_int          :  std_logic                      ;
  --signal  OP_B_MUX_SEL_int          :  std_logic                      ;
  signal  EN_MULT_int               :  std_logic                      ;
  signal  SIGNED_NUNSIGNED_MULT_int :  std_logic                      ;
  signal  HILO_REG_SRC_MULT_int     :  std_logic                      ;
  signal  WR_RM_MULT_int            :  std_logic                      ;
  signal  WR_RS_MULT_int            :  std_logic                      ;
  signal  WR_SUM_MULT_int           :  std_logic                      ;
  signal  nRST_SUM_MULT_int         :  std_logic                      ;
  signal  nRST_CARRY_MULT_int       :  std_logic                      ;
  --signal  MDATA_ADDR_int            :  DATA_BUS_t                     ;
  signal  ALU_OUTPUT_int            :  DATA_BUS_t                     ;
  signal  TO_BE_EXECUTED_int        :  std_logic                      ;
  signal  N_out_int                 :  std_logic                      ;
  signal  C_out_int                 :  std_logic                      ;
  signal  Z_out_int                 :  std_logic                      ;
  signal  V_out_int                 :  std_logic                      ;
  signal  EARLY_FINISH_int          :  std_logic                      ;

  --MUL signal
  signal  ADDITION_MULT_int         :  std_logic;

  --SHIFTER internal signals
  signal  SHIFT_AMOUNT_int          :  SHIFT_BUS_t                    ;
  signal  SHIFT_OPCODE_int          :  std_logic_vector(1 downto 0)   ;
  signal  SHIFT_SRC_AMOUNT_int      :  std_logic                      ;
  signal  SHIFT_IMM_int             :  std_logic                      ;

  --REGISTER FILE internal signals
  signal  EN_WRA_int                :  std_logic                      ;
  signal  EN_WRB_int                :  std_logic                      ;
  signal  EN_RDA_int                :  std_logic;
  signal  EN_RDB_int                :  std_logic;
  signal  EN_RDC_int                :  std_logic;

  signal  ADDR_rdA_int              :  REG_ADDR_t                     ;
  signal  ADDR_rdB_int              :  REG_ADDR_t                     ;
  signal  ADDR_rdC_int              :  REG_ADDR_t                     ;
  signal  ADDR_wrA_int              :  REG_ADDR_t                     ;
  signal  ADDR_wrB_int              :  REG_ADDR_t                     ;
  signal  DATA_rdA_int              :  DATA_BUS_t                     ;
  signal  DATA_rdB_int              :  DATA_BUS_t                     ;
  signal  DATA_rdC_int              :  DATA_BUS_t                     ;
  signal  STR_Mdata_dim_int         :  std_logic_vector(1 downto 0)   ;
  signal  LD_MDATA_DIM_int          :  std_logic_vector(1 downto 0)   ;
  signal  LD_MDATA_SIGN_int         :  std_logic;

  --FORWARDING UNIT internal signals
  signal  EXE_ADDR_wrA_int          :  REG_ADDR_t;
  signal  EXE_ADDR_wrB_int          :  REG_ADDR_t;
  signal  MEM_ADDR_wrA_int          :  REG_ADDR_t;
  signal  MEM_ADDR_wrB_int          :  REG_ADDR_t;
  --signal  DEC_EN_rdA_int            :  std_logic;
  --signal  DEC_EN_rdB_int            :  std_logic;
  signal  EXE_EN_wrA_int            :  std_logic;
  signal  MEM_EN_wrA_int            :  std_logic;
  signal  EXE_EN_wrB_int            :  std_logic;
  signal  MEM_EN_wrB_int            :  std_logic;
  signal  EN_rdPSR_int              :  std_logic;
  signal  CPSR_nSPSR_int            :  std_logic;
  signal  IMM_INST_int              :  std_logic;

  signal  IMMEDIATE_VALUE_int       :  std_logic_vector(31 downto 0);

  signal  DDIN_WB_processed_int     :  DATA_BUS_t                     ;
  signal  DDIN_WB_int               :  DATA_BUS_t                     ;
  signal  DD_int                    :  DATA_BUS_t                     ;

  signal  END_MUL_int               :  std_logic;

  signal  EXE_MDATA_EN_int          :  std_logic                      ;
  signal  EXE_MDATA_DIM_int         :  std_logic_vector(1 downto 0)   ;
  signal  EXE_MDATA_RD_nWR_int      :  std_logic                      ;
  signal  EXE_MDATA_SRC_ADDR_int    :  std_logic_vector(1 downto 0)   ;

  signal  DEC_MDATA_SRC_ADDR_int    :  std_logic_vector(1 downto 0)   ;
  signal  DEC_MDATA_EN_int          :  std_logic                      ;

  signal  CPSR_out_int              :  std_logic_vector(31 downto 0)  ;
  signal  SPSR_out_int              :  std_logic_vector(31 downto 0)  ;
  signal  CPSR_NXT_int              :  std_logic_vector(31 downto 0)  ;
  signal  SPSR_NXT_int              :  std_logic_vector(31 downto 0)  ;
  signal  SRC_NXT_SPSR_int          :  std_logic;
  signal  SPSR_FM_int               :  std_logic_vector(3 downto 0);
  signal  CPSR_FM_int               :  std_logic_vector(3 downto 0);
  signal  WR_SPSR_HIGH_int          :  std_logic;
  signal  WR_SPSR_LOW_int           :  std_logic;
  signal  WR_CPSR_HIGH_int          :  std_logic;
  signal  WR_CPSR_LOW_int           :  std_logic;
  signal  SRC_HIGH_CPSR_int         :  std_logic_vector(1 downto 0);

  signal  MDATA_SRC_OUT_int         :  std_logic                      ;

  signal  TMP_CPSR_Q_int            :  std_logic_vector(31 downto 0)  ;

  signal  PC_OUT_int                :  DATA_BUS_t                     ;

  signal  NZCV_NXT_int              :  std_logic_vector(3 downto 0)   ;

  signal  PC_WE_int                 :  std_logic                      ;
  --signal  UNUSED_USR_WRB_int        :  std_logic                      ;

  signal  DD_DELAYED_int            : DATA_BUS_t;

  signal  STALL_int                 :  std_logic;

  signal  EN_RDA_STAGE_int          :  std_logic                      ; 
  signal  EN_RDB_STAGE_int          :  std_logic                      ;


begin

  ICLK  <=  GCLK or (not(nWAIT));
  ECLK  <=  ICLK;

  --Select memory output skewed or not for the SWAP operation
  DD    <=  DD_int  when MDATA_SRC_OUT_int = '0' else
            DD_DELAYED_int;

  --Since when a instrction is fetched for sure PC will be written generate
  --a skewed signal of DEC_WR_OPCODE that will be PC load signal
  PC_WR_DFF: DFF
    port map(
      D                           =>  DEC_WR_OPCODE_int         ,
      Q                           =>  PC_WE_int                 ,
      clk                         =>  ICLK                      ,
      nRst                        =>  nRESET
    );


  TMP_CPSR: REG_NEGEDGE_GEN
    port map (
      CLK                         =>  ICLK                      ,
      nRST                        =>  nRESET                    ,
      EN                          =>  DEC_WR_NXT_CPSR_int       ,
      D                           =>  CPSR_OUT_int              ,
      Q                           =>  TMP_CPSR_Q_int
    );

  --Register need to delay data memory output for swap
  DELAYED_RC_DATA: REG_NEGEDGE_GEN
    port map (
      CLK                         =>  ICLK                      ,
      nRST                        =>  nRESET                      ,
      EN                          =>  EN_rdC_int                ,
      D                           =>  DD_int                    ,
      Q                           =>  DD_DELAYED_int
    );

  --Exe result register
  ALU_OUT_MEM: REG_NEGEDGE_GEN
    port map (
      CLK                         =>  ICLK                      ,
      nRST                        =>  nRESET                      ,
      EN                          =>  '1'                       ,
      D                           =>  ALU_OUTPUT_int            ,
      Q                           =>  ALU_OUTPUT_MEM_int
    );

  -- Forwarding register form exe to wb stages
  ALU_OUT_WB: REG_NEGEDGE_GEN
    port map (
      CLK                         =>  ICLK                      ,
      nRST                        =>  nRESET                      ,
      EN                          =>  '1'                       ,
      D                           =>  ALU_OUTPUT_MEM_int        ,
      Q                           =>  ALU_OUTPUT_WB_int
    );

  --Data out memory = Data in memory for processor register
  DDIN_WB: REG_NEGEDGE_GEN
    port map (
      CLK                         =>  ICLK                      ,
      nRST                        =>  nRESET                      ,
      EN                          =>  '1'                       ,
      D                           =>  DDIN                      ,
      Q                           =>  DDIN_WB_int
    );

  --Byte rotation / sign extension of data memory output
  BRSE: BYTE_ROT_SIGN_EXT
    port map (
      data_in                     =>  DDIN_WB_int               ,
      Mdata_dim                   =>  LD_MDATA_DIM_int          ,
      Mdata_sign                  =>  LD_MDATA_SIGN_int         ,
      data_out                    =>  DDIN_WB_processed_int
    );

  --Data input memory word replicaiton
  BWR: BYTE_WORD_REPLICATION
    port map (
      data_in                     =>  DATA_rdC_int              ,
      Mdata_dim                   =>  STR_MDATA_DIM_int         ,
      data_out                    =>  DD_int
    );

  DMSG: DATA_MEMORY_SIGNAL_GENERATION
    port map (
      clk                         =>  ICLK                      ,
      nRst                        =>  nRESET                    ,
      Mdata_en                    =>  EXE_MDATA_EN_int          ,
      dec_Mdata_en                =>  DEC_MDATA_EN_int          ,
      en_rdC                      =>  EN_rdC_int                ,
      Mdata_rd_nWr                =>  EXE_MDATA_RD_nWR_int      ,
      Mdata_src_addr              =>  EXE_MDATA_SRC_ADDR_int    ,
      dec_Mdata_src_addr          =>  DEC_MDATA_SRC_ADDR_int    ,
      Mdata_dim                   =>  EXE_MDATA_DIM_int         ,
      CPSR_mode                   =>  CPSR_out_int(4 downto 0)  ,

      DDEN                        =>  DDEN                      ,
      DLOCK                       =>  DLOCK                     ,
      DMAS                        =>  DMAS                      ,
      DMORE                       =>  DMORE                     ,
      DSEQ                        =>  DSEQ                      ,
      DnM                         =>  DnM                       ,
      DnMREQ                      =>  DnMREQ                    ,
      DnRW                        =>  DnRW                      ,
      DnTRANS                     =>  DnTRANS
    );

  ITBIT <= NXT_CPSR_Q_int(5);
  FETCH_STAGE: FETCH
    port map(
      CLK                         =>  ICLK                      ,
      nRESET                      =>  nRESET                    ,
      nIRQ                        =>  nIRQ                      ,
      nFIQ                        =>  nFIQ                      ,
      BIGEND                      =>  BIGEND                    ,
      HIVECS                      =>  HIVECS                    ,
      ALU_OUTPUT                  =>  ALU_OUTPUT_int            ,
      SPSR                        =>  SPSR_OUT_int(7 downto 0)  ,
      DEC_SRC_NXT_IA              =>  DEC_SRC_NXT_IA_int        ,
      DEC_WR_IA                   =>  DEC_WR_IA_int             ,
      DEC_SRC_NXT_CPSR            =>  DEC_SRC_NXT_CPSR_int      ,
      DEC_WR_NXT_CPSR             =>  DEC_WR_NXT_CPSR_int       ,
      DEC_WR_OPCODE               =>  DEC_WR_OPCODE_int         ,
      EXCEPTION_ADDR              =>  EXCEPTION_ADDR_int        ,
      IA_INC                      =>  DEC_PC_int                ,
      OPCODE                      =>  DEC_INPUT_int             ,
      NEXT_CPSR_Q                 =>  NXT_CPSR_Q_int            ,
      IA                          =>  IA                        ,
      InM                         =>  InM                       ,
      InMREQ                      =>  InMREQ                    ,
      InTRANS                     =>  InTRANS                   ,
      ISEQ                        =>  ISEQ                      ,
      ID                          =>  ID                        ,
      IABE                        =>  IABE                      ,
      IABORT                      =>  IABORT                    ,
      DABORT                      =>  DABORT                    ,
      DDIN                        =>  DDIN_WB_int
    );

  EXE_STAGE: EXECUTE
    port map(
      CLK                         =>  ICLK                      ,
      nRST                        =>  nRESET                    ,
      A                           =>  A_int                     ,
      B                           =>  B_int                     ,
      ALU_OPCODE                  =>  ALU_OPCODE_int            ,
      COND_CODE                   =>  COND_CODE_int             ,
      MDATA_SRC_ADDR              =>  EXE_MDATA_SRC_ADDR_int    ,
      N_in                        =>  CPSR_OUT_int(31)          ,
      C_in                        =>  CPSR_OUT_int(29)          ,
      Z_in                        =>  CPSR_OUT_int(30)          ,
      V_in                        =>  CPSR_OUT_int(28)          ,
      A_PASS                      =>  '0'                       ,
      B_PASS                      =>  '0'                       ,
      OP_A_MUX_SEL                =>  ADDITION_MULT_int         ,
      OP_B_MUX_SEL                =>  ADDITION_MULT_int         ,
      EN_MULT                     =>  EN_MULT_int               ,
      SIGNED_NUNSIGNED_MULT       =>  SIGNED_nUNSIGNED_MULT_int ,
      HILO_REG_SRC_MULT           =>  HILO_REG_SRC_MULT_int     ,
      WR_RM_MULT                  =>  WR_RM_MULT_int            ,
      WR_RS_MULT                  =>  WR_RS_MULT_int            ,
      WR_SUM_MULT                 =>  WR_SUM_MULT_int           ,
      NRST_SUM_MULT               =>  nRST_SUM_MULT_int         ,
      NRST_CARRY_MULT             =>  nRST_CARRY_MULT_int       ,
      SHIFT_AMOUNT                =>  SHIFT_AMOUNT_int          ,
      SHIFT_OPCODE                =>  SHIFT_OPCODE_int          ,
      SHIFT_SRC_AMOUNT            =>  SHIFT_SRC_AMOUNT_int      ,
      SHIFT_IMM                   =>  SHIFT_IMM_int             ,
      MDATA_ADDR                  =>  DA                        ,
      ALU_OUTPUT                  =>  ALU_OUTPUT_int            ,
      TO_BE_EXECUTED              =>  TO_BE_EXECUTED_int        ,
      N_out                       =>  N_out_int                 ,
      C_out                       =>  C_out_int                 ,
      Z_out                       =>  Z_out_int                 ,
      V_out                       =>  V_out_int                 ,
      EARLY_FINISH                =>  EARLY_FINISH_int
    );


  --Generate mask for CPSR and SPSR
  CPSR_NXT_int <=  NZCV_NXT_int & x"0" & x"0000" & NXT_CPSR_Q_int;
  SPSR_NXT_int <=  TMP_CPSR_Q_int when SRC_NXT_SPSR_int = '0' else
                   ALU_OUTPUT_int;

  --Masks: 1 = write enable for that byte
  SPSR_FM_int  <=  WR_SPSR_HIGH_int & '0' & '0' & WR_SPSR_LOW_int;
  CPSR_FM_int  <=  WR_CPSR_HIGH_int & '0' & '0' & WR_CPSR_LOW_int;

  RF: REGBANK_3R2W
    port map (
      CLK                         =>  ICLK                              ,
      nRST                        =>  nRESET                            ,

      WEN1                        =>  EN_WRA_int                        ,
      WEN2                        =>  EN_WRB_int                        ,

      RADDR1                      =>  ADDR_rdA_int                      ,
      RADDR2                      =>  ADDR_rdB_int                      ,
      RADDR3                      =>  ADDR_rdA_int                      ,
      WADDR1                      =>  ADDR_wrA_int                      ,
      WADDR2                      =>  ADDR_wrB_int                      ,

      RDATA1                      =>  DATA_rdA_int                      ,
      RDATA2                      =>  DATA_rdB_int                      ,
      RDATA3                      =>  DATA_rdC_int                      ,
      WDATA1                      =>  ALU_OUTPUT_WB_int                 ,
      WDATA2                      =>  DDIN_WB_processed_int             ,
                                  -- TODO: The USR mode should be forced
                                  --       only for READ port C and WRITE
                                  --       port A. Maybe it is enough the
                                  --       write port A.
      USR_MODE                    =>  '0'                               ,


      CPSR_FM                     =>  CPSR_FM_int                       ,
      SPSR_FM                     =>  SPSR_FM_int                       ,
      CPSR_IN                     =>  CPSR_NXT_int                      ,
      SPSR_IN                     =>  SPSR_NXT_int                      ,
      CPSR_OUT                    =>  CPSR_OUT_int                      ,
      SPSR_OUT                    =>  SPSR_OUT_int                      ,

      THUMB_SET                   =>  '0'                               ,
      THUMB_RST                   =>  '0'                               ,
      IRQ_SET                     =>  '0'                               ,
      IRQ_RST                     =>  '0'                               ,
      FIQ_SET                     =>  '0'                               ,
      FIQ_RST                     =>  '0'                               ,

      PC_WE                       =>  PC_WE_int                         ,
      PC_IN                       =>  DEC_PC_int                        ,
      PC_OUT                      =>  PC_OUT_int
    );


  END_MUL_INT <= EARLY_FINISH_int; 

  CU: control_unit
    port map (
      clk                         =>  ICLK,
      nRst                        =>  nRESET,
      fiq                         =>  DEC_INPUT_int(35),
      irq                         =>  DEC_INPUT_int(34),
      data_abort                  =>  DEC_INPUT_int(33),
      prefetch_abort              =>  DEC_INPUT_int(32),
      instruction                 =>  DEC_INPUT_int(31 downto 0),
      to_be_exe                   =>  TO_BE_EXECUTED_int,
      end_mul                     =>  END_MUL_int,
      stall                       =>  STALL_int,

      --REGISTER FILE
      addr_rdA                    =>  ADDR_rdA_int,
      addr_rdB                    =>  ADDR_rdB_int,
      addr_rdC                    =>  ADDR_rdC_int,
      addr_wrA                    =>  ADDR_wrA_int,
      addr_wrB                    =>  ADDR_wrB_int,
      en_wrA                      =>  EN_wrA_int,
      en_wrB                      =>  EN_wrB_int,
      en_rdA                      =>  EN_rdA_int,
      en_rdB                      =>  EN_rdB_int,
      en_rdC                      =>  EN_rdC_int,
    --usr_wrB                     =>

      --FORWARDING UNIT
      exe_addr_wrA                =>  EXE_ADDR_wrA_int,
      mem_addr_wrA                =>  MEM_ADDR_wrA_int,
      exe_en_wrA                  =>  EXE_EN_wrA_int,
      mem_en_wrA                  =>  MEM_EN_wrA_int,
      exe_addr_wrB                =>  EXE_ADDR_wrB_int,
      mem_addr_wrB                =>  MEM_ADDR_wrB_int,
      exe_en_wrB                  =>  EXE_EN_wrB_int,
      mem_en_wrB                  =>  MEM_EN_wrB_int,
      en_rdPSR                    =>  EN_rdPSR_int,
      CPSR_nSPSR                  =>  CPSR_nSPSR_int,
      imm_inst                    =>  IMM_INST_int,
      immediate_value             =>  IMMEDIATE_VALUE_int,
      --SHIFTER
      shift_amount                =>  SHIFT_AMOUNT_int,
      shifter_opcode              =>  SHIFT_OPCODE_int,
      src_shift_amnt              =>  SHIFT_SRC_AMOUNT_int,
      shift_imm                   =>  SHIFT_IMM_int,

      --MEMORY SYSTEM
      Mdata_src_addr              =>  EXE_MDATA_SRC_ADDR_int,
      Mdata_src_addr_nxt          =>  DEC_MDATA_SRC_ADDR_int,
      Mdata_src_out               =>  MDATA_SRC_OUT_int,
      Mdata_dim                   =>  EXE_MDATA_DIM_int,
      Mdata_en                    =>  EXE_MDATA_EN_int,
      Mdata_en_nxt                =>  DEC_MDATA_EN_int,
      Mdata_rd_nWr                =>  EXE_MDATA_RD_nWR_int,

      --BYTE WORD REPLICATION
      str_Mdata_dim               =>  STR_MDATA_DIM_int,

      --BYTE ROT SIGN EXTENSION
      ld_Mdata_dim                =>  LD_MDATA_DIM_int,
      ld_Mdata_sign               =>  LD_MDATA_SIGN_int,

      --TO_BE_EXE UNIT
      alu_opcode                  =>  ALU_OPCODE_int,
      cond_code                   =>  COND_CODE_int,

      --SPSR
      src_nxt_SPSR                =>  SRC_NXT_SPSR_int,
      wr_SPSR_high                =>  WR_SPSR_HIGH_int,
      wr_SPSR_low                 =>  WR_SPSR_LOW_int,

      --CPSR
      wr_high_cpsr                =>  WR_CPSR_HIGH_int,
      src_high_CPSR               =>  SRC_HIGH_CPSR_int,
      wr_low_cpsr                 =>  WR_CPSR_LOW_int,

      --NEXT CPSR
      src_nxt_CPSR                =>  DEC_SRC_NXT_CPSR_int,
      wr_nxt_cpsr                 =>  DEC_WR_NXT_CPSR_int,

      -- MULTIPLIER
      en_mult                     =>  EN_MULT_int,
      signed_nUnsigned_mult       =>  SIGNED_nUNSIGNED_MULT_int,
      HiLo_reg_src_mult           =>  HILO_REG_SRC_MULT_int,
      wr_Rm_mult                  =>  WR_RM_MULT_int,
      wr_Rs_mult                  =>  WR_RS_MULT_int,
      wr_sum_mult                 =>  WR_SUM_MULT_int,
      nRst_sum_mult               =>  nRST_SUM_MULT_int,
      nRst_carry_mult             =>  nRST_CARRY_MULT_int,
      addition_mult               =>  ADDITION_MULT_int, 
  ---------------------------------------------------------------------
  --                      LOAD FOR IA AND FETCH/DEC REG. PIPE
  ---------------------------------------------------------------------
      wr_IA                       =>  DEC_WR_IA_int,
      wr_IR                       =>  DEC_WR_OPCODE_int,
      src_nxt_IA                  =>  DEC_SRC_NXT_IA_int,
      vt_addr                     =>  EXCEPTION_ADDR_int
    );
  
    EN_RDA_STAGE_int  <=  EN_rdA_int  or  EN_rdPSR_int;
    EN_RDB_STAGE_int  <=  EN_rdB_int  or  IMM_INST_int;
  DOS: DEC_OUT_STAGE
    port map (
      CLK                         =>  ICLK                              ,
      nRST                        =>  nRESET                            ,
      STALL                       =>  STALL_int                         ,
      EN_RDA                      =>  EN_RDA_STAGE_int                  ,
      EN_RDB                      =>  EN_RDB_STAGE_int                  ,
      SPSR                        =>  SPSR_OUT_int                      ,
      CPSR                        =>  CPSR_OUT_int                      ,
      A_RDATA                     =>  DATA_rdA_int                      ,
      B_RDATA                     =>  DATA_rdB_int                      ,
      IMMEDIATE                   =>  IMMEDIATE_VALUE_int               ,
      ALU_OUT_EXE                 =>  ALU_OUTPUT_int                    ,
      ALU_OUT_MEM                 =>  ALU_OUTPUT_MEM_int                ,
      DATA_MEM_OUT                =>  DDIN                              ,
      A_DATA_SEL                  =>  A_DATA_SEL_int                    ,
      B_DATA_SEL                  =>  B_DATA_SEL_int                    ,
      A_OUT                       =>  A_int                             ,
      B_OUT                       =>  B_int
    );

  FU: FORWARDING_UNIT
    port map (
      DEC_ADDR_rdA                =>  ADDR_rdA_int,
      DEC_ADDR_rdB                =>  ADDR_rdB_int,
      DEC_EN_rdA                  =>  EN_rdA_int,
      DEC_EN_rdB                  =>  EN_rdB_int,
      EXE_ADDR_wrA                =>  EXE_ADDR_wrA_int,
      MEM_ADDR_wrA                =>  MEM_ADDR_wrA_int,
      EXE_EN_wrA                  =>  EXE_EN_wrA_int,
      MEM_EN_wrA                  =>  MEM_EN_wrA_int,
      EXE_ADDR_wrB                =>  EXE_ADDR_wrB_int,
      MEM_ADDR_wrB                =>  MEM_ADDR_wrB_int,
      EXE_EN_wrB                  =>  EXE_EN_wrB_int,
      MEM_EN_wrB                  =>  MEM_EN_wrB_int,
      IMM_INST                    =>  IMM_inst_int,
      EN_rdPSR                    =>  EN_rdPSR_int,
      CPSR_nSPSR                  =>  CPSR_nSPSR_int,
      MDATA_DIM                   =>  STR_MDATA_DIM_int,
      A_DATA_SEL                  =>  A_DATA_SEL_int,
      B_DATA_SEL                  =>  B_DATA_SEL_int,
      STALL                       =>  STALL_int
    );

  UF: UPDATE_FLAG
    port map (
      N_EXE                     =>  N_OUT_int                          ,
      C_EXE                     =>  C_OUT_int                          ,
      Z_EXE                     =>  Z_OUT_int                          ,
      V_EXE                     =>  V_OUT_int                          ,
      PREV_Z                    =>  CPSR_OUT_int(30)                   ,
      LONG_MUL                  =>  HILO_REG_SRC_MULT_int              ,
      SPSR_flag                 =>  SPSR_OUT_int(31 downto 28)         ,
      ALU_OUT_flag              =>  ALU_OUTPUT_int(31 downto 28)       ,
      SRC_FLAG                  =>  SRC_HIGH_CPSR_int                  ,
      NZCV_nxt                  =>  NZCV_NXT_int
    );
end architecture STR;
