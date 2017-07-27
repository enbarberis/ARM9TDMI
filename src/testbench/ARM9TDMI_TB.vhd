library IEEE;
use IEEE.std_logic_1164.all;

library WORK;
use WORK.ARM_pack.all;

entity ARM9TDMI_TB is
end entity;

architecture BHE of ARM9TDMI_TB is

  component ARM9TDMI
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
  end component ARM9TDMI;



  component INSTRUCTION_MEMORY is
  generic (
    NWORDS : natural := 1024
  );
  port (
    IA        : in  ADDR_BUS_t;                     -- Instruction Address Bus. This is the processor instruction address bus
    InM       : in  CPSR_MODE_t;                    -- Instruction Mode. Current mode of processor (last 5 bits of CPSR)
    InMREQ    : in  std_logic;                      -- Not Instruction Memory Request. When Low request a memory access
    InTRANS   : in  std_logic;                      -- Not Memory Translate. 0 when user mode, 1 when privileged mode
    ISEQ      : in  std_logic;                      -- Instruction sequential address.
    ITBIT     : in  std_logic;                      -- Instruction thumb bit. 1 when thumb state, 0 when ARM state

    ID        : out ARM_INSTR_t;                    -- Instruction Data Bus
    IABE      : out std_logic;                      -- Instruction Address Bus Enable.
    IABORT    : out std_logic                       -- Instruction Abort. Set to 1 when the requested instruction memory access is not allowed.
  );
  end component;


  component DATA_MEMORY is
  generic (
    NBYTE : natural := 1024
  );
  port (
    CLK       : in  std_logic;

    DA        : in  ADDR_BUS_t;                     -- Data Address Bus.
    DABE      : out std_logic;                      -- Data Address Bus Enable.
    DABORT    : out  std_logic;                      -- Data Abort.
    DD        : in  DATA_BUS_t;                     -- Data Output Bus.
    DDBE      : out std_logic;                      -- Data Data Bus Enable.
    DDEN      : in  std_logic;                      -- Data Data Bus Output Enabled.
    DDIN      : out DATA_BUS_t;                     -- Data Input Bus.
    DLOCK     : in  std_logic;                      -- Data Lock.
    DMAS      : in  std_logic_vector ( 1 downto 0); -- Data Memory Access Size.
    DMORE     : in  std_logic;                      -- Data More.
    DnM       : in  CPSR_MODE_t;                    -- Data Mode.
    DnMREQ    : in  std_logic;                      -- Not Data Memory Request.
    DnRW      : in  std_logic;                      -- Output Data not Read, Write.
    DnTRANS   : in  std_logic;                      -- Data Not Memory Translate.
    DSEQ      : in  std_logic                       -- Data Sequential Address.
  );
  end component;



  --Instruction memory signals
  signal IA_s         :  ADDR_BUS_t;
  signal InM_s        :  CPSR_MODE_t;
  signal InMREQ_s     :  std_logic;
  signal InTRANS_s    :  std_logic;
  signal ISEQ_s       :  std_logic;
  signal ITBIT_s      :  std_logic;

  signal ID_s         :  ARM_INSTR_t;
  signal IABE_s       :  std_logic;
  signal IABORT_s     :  std_logic;


  --Data memory signals
  signal DA_s         :  ADDR_BUS_t;
  signal DABE_s       :  std_logic;
  signal DABORT_s     :  std_logic;
  signal DD_s         :  DATA_BUS_t;
  signal DDBE_s       :  std_logic;
  signal DDEN_s       :  std_logic;
  signal DDIN_s       :  DATA_BUS_t;
  signal DLOCK_s      :  std_logic;
  signal DMAS_s       :  std_logic_vector ( 1 downto 0);
  signal DMORE_s      :  std_logic;
  signal DnM_s        :  CPSR_MODE_t;
  signal DnMREQ_s     :  std_logic;
  signal DnRW_s       :  std_logic;
  signal DnTRANS_s    :  std_logic;
  signal DSEQ_s       :  std_logic;


  constant CLK_period : time := 1 ns;

  signal BIGEND_s     :  std_logic;
  signal ECLK_s       :  std_logic;
  signal nFIQ_s       :  std_logic;
  signal GCLK_s       :  std_logic;
  signal HIVECS_s     :  std_logic;
  signal nIRQ_s       :  std_logic;
  signal ISYNC_s      :  std_logic;
  signal nRESET_s     :  std_logic;
  signal nWAIT_s      :  std_logic;
  signal UNIEN_s      :  std_logic;



begin




 ARM_MY_LOVE: ARM9TDMI
  port map (

    --  INSTRUCTION MEMORY INTERFACE SIGNALS
    IA          =>  IA_s,
    IABE        =>  IABE_s,
    IABORT      =>  IABORT_s,
    ID          =>  ID_s,
    InM         =>  InM_s,
    InMREQ      =>  InMREQ_s,
    InTRANS     =>  InTRANS_s,
    ISEQ        =>  ISEQ_s,
    ITBIT       =>  ITBIT_s,

    --  DATA MEMORY INTERFACE SIGNALS
    DA          =>  DA_s,
    DABE        =>  DABE_s,
    DABORT      =>  DABORT_s,
    DD          =>  DD_s,
    DDBE        =>  DDBE_s,
    DDEN        =>  DDEN_s,
    DDIN        =>  DDIN_s,
    DLOCK       =>  DLOCK_s,
    DMAS        =>  DMAS_s,
    DMORE       =>  DMORE_s,
    DnM         =>  DnM_s,
    DnMREQ      =>  DnMREQ_s,
    DnRW        =>  DnRW_s,
    DnTRANS     =>  DnTRANS_s,
    DSEQ        =>  DSEQ_s,

    --  MISCELLANEOUS SIGNALS
    BIGEND      =>  BIGEND_s,
    ECLK        =>  ECLK_s,
    nFIQ        =>  nFIQ_s,
    GCLK        =>  GCLK_s,
    HIVECS      =>  HIVECS_s,
    nIRQ        =>  nIRQ_s,
    ISYNC       =>  ISYNC_s,
    nRESET      =>  nRESET_s,
    nWAIT       =>  nWAIT_s,
    UNIEN       =>  UNIEN_s
  );

  IM: INSTRUCTION_MEMORY
    generic map (
      NWORDS => 1024 )
    port map (
      IA        => IA_s,     -- Instruction Address Bus. This is the processor instruction address bus
      InM       => InM_s,       -- Instruction Mode. Current mode of processor (last 5 bits of CPSR)
      InMREQ    =>    InMREQ_s,    -- Not Instruction Memory Request. When Low request a memory access
      InTRANS    =>    InTRANS_s,   -- Not Memory Translate. 0 when user mode, 1 when privileged mode
      ISEQ       =>    ISEQ_s,      -- Instruction sequential address.
      ITBIT     =>     ITBIT_s,     -- Instruction thumb bit. 1 when thumb state, 0 when ARM state
                           
      ID        =>     ID_s,        -- Instruction Data Bus
      IABE      =>     IABE_s,      -- Instruction Address Bus Enable.
      IABORT    =>     IABORT_s    -- Instruction Abort. Set to 1 when the requested instruction memory access is not allowed.
    );


  DM: DATA_MEMORY
  port map  (
    CLK       => GCLK_s  ,   
                       
    DA        =>  DA_s,       -- Data Address Bus.
    DABE      =>  DABE_s,     -- Data Address Bus Enable.
    DABORT    =>  DABORT_s,   -- Data Abort.
    DD        =>  DD_s,       -- Data Output Bus.
    DDBE      =>  DDBE_s,     -- Data Data Bus Enable.
    DDEN      =>  DDEN_s,     -- Data Data Bus Output Enabled.
    DDIN      =>  DDIN_s,     -- Data Input Bus.
    DLOCK     =>  DLOCK_s,    -- Data Lock.
    DMAS      =>  DMAS_s,     -- Data Memory Access Size.
    DMORE     =>  DMORE_s,    -- Data More.
    DnM       =>  DnM_s,      -- Data Mode.
    DnMREQ    =>  DnMREQ_s,   -- Not Data Memory Request.
    DnRW      =>  DnRW_s,     -- Output Data not Read, Write.
    DnTRANS   =>  DnTRANS_s,  -- Data Not Memory Translate.
    DSEQ      =>  DSEQ_s     -- Data Sequential Address.
  );

CLK_process : process
 begin
    GCLK_s <= '0';
    wait for CLK_period/2;
    GCLK_s <= '1';
    wait for CLK_period/2;
  end process;

test: process
begin
    BIGEND_s      <= '0';
    nFIQ_s        <= '1';
    HIVECS_s      <= '0';
    nIRQ_s        <= '1';
    ISYNC_s       <= '0';
    UNIEN_s       <= '0';
    nWAIT_s       <= '1';
    nRESET_s <= '0';
    wait for 10*clk_period;
    nRESET_s <= '1';
    wait ;

end process;

end architecture BHE;

