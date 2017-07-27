library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.ARM_pack.all;

entity REGBANK_3R2W is

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

end entity; -- REGBANK_3R2W


architecture BHV of REGBANK_3R2W is

  -- PC is STD_REGS (15)

  signal STD_REGS : STD_REGS_t;                                                 -- USR/SYS Registers
  signal FIQ_REGS : FIQ_REGS_t;                                                 -- FIQ Registers
  signal IRQ_REGS : IRQ_REGS_t;                                                 -- IRQ Registers
  signal SVC_REGS : SVC_REGS_t;                                                 -- SVC Registers
  signal ABT_REGS : ABT_REGS_t;                                                 -- ABT Registers
  signal UND_REGS : UND_REGS_t;                                                 -- UND Registers

  signal FIQ_SPSR : DATA_BUS_t;                                                 -- FIQ Saved Program Status Register
  signal IRQ_SPSR : DATA_BUS_t;                                                 -- IRQ Saved Program Status Register
  signal SVC_SPSR : DATA_BUS_t;                                                 -- SVC Saved Program Status Register
  signal ABT_SPSR : DATA_BUS_t;                                                 -- ABT Saved Program Status Register
  signal UND_SPSR : DATA_BUS_t;                                                 -- UND Saved Program Status Register

  signal CPSR_REG : DATA_BUS_t;                                                 -- Current Program Status Register
  alias  EXE_MODE : std_logic_vector(CPSR_MODE_r) is CPSR_REG(CPSR_MODE_r);     -- Execution Mode (CPSR)

  signal CUR_REGS : STD_REGS_t;                                                 -- Currently available registers

  signal RADDR1_i, RADDR2_i, RADDR3_i, WADDR1_i, WADDR2_i : natural;

begin

  WADDR1_i      <= to_integer(unsigned(WADDR1));
  WADDR2_i      <= to_integer(unsigned(WADDR2));
  RADDR1_i      <= to_integer(unsigned(RADDR1));
  RADDR2_i      <= to_integer(unsigned(RADDR2));
  RADDR3_i      <= to_integer(unsigned(RADDR3));

  RDATA1        <= CUR_REGS(RADDR1_i);
  RDATA2        <= CUR_REGS(RADDR2_i);
  RDATA3        <= CUR_REGS(RADDR3_i);

  REG_OUT_LO  : for i in 0 to 7 generate
    CUR_REGS(i) <= STD_REGS(i);
  end generate; -- REG_OUT_LO

  REG_OUT     : for i in 8 to 12 generate
    CUR_REGS(i) <=  STD_REGS(i) when EXE_MODE = USR or  USR_MODE = '1' else
                    STD_REGS(i) when EXE_MODE = SYS and USR_MODE = '0' else
                    FIQ_REGS(i) when EXE_MODE = FIQ and USR_MODE = '0' else
                    STD_REGS(i) when EXE_MODE = IRQ and USR_MODE = '0' else
                    STD_REGS(i) when EXE_MODE = SVC and USR_MODE = '0' else
                    STD_REGS(i) when EXE_MODE = ABT and USR_MODE = '0' else
                    STD_REGS(i) when EXE_MODE = UND and USR_MODE = '0' else
                    x"0BADC0DE";
  end generate; -- REG_OUT

  REG_OUT_HI  : for i in 13 to 14 generate
    CUR_REGS(i) <=  STD_REGS(i) when EXE_MODE = USR or  USR_MODE = '1' else
                    STD_REGS(i) when EXE_MODE = SYS and USR_MODE = '0' else
                    FIQ_REGS(i) when EXE_MODE = FIQ and USR_MODE = '0' else
                    IRQ_REGS(i) when EXE_MODE = IRQ and USR_MODE = '0' else
                    SVC_REGS(i) when EXE_MODE = SVC and USR_MODE = '0' else
                    ABT_REGS(i) when EXE_MODE = ABT and USR_MODE = '0' else
                    UND_REGS(i) when EXE_MODE = UND and USR_MODE = '0' else
                    x"0BADC0DE";
  end generate; -- REG_OUT_HI

  CUR_REGS(15)  <=  STD_REGS(15);

  SPSR_OUT      <=  FIQ_SPSR    when EXE_MODE = FIQ else
                    IRQ_SPSR    when EXE_MODE = IRQ else
                    SVC_SPSR    when EXE_MODE = SVC else
                    ABT_SPSR    when EXE_MODE = ABT else
                    UND_SPSR    when EXE_MODE = UND else
                    x"0BADC0DE";

  PC_OUT        <=  CUR_REGS(15);
  CPSR_OUT      <=  CPSR_REG;

  ----------------------------------------------------------------------------

  REG_WRITE_p : process (CLK, nRST)
  begin

    if (nRST = '0') then

      STD_REGS  <=  (others => (others => '0'));
      FIQ_REGS  <=  (others => (others => '0'));
      IRQ_REGS  <=  (others => (others => '0'));
      SVC_REGS  <=  (others => (others => '0'));
      ABT_REGS  <=  (others => (others => '0'));
      UND_REGS  <=  (others => (others => '0'));
      CPSR_REG  <=  x"000000" & "110" & USR;
      FIQ_SPSR  <=  (others => '0');
      IRQ_SPSR  <=  (others => '0');
      SVC_SPSR  <=  (others => '0');
      ABT_SPSR  <=  (others => '0');
      UND_SPSR  <=  (others => '0');

    elsif (CLK = '1' and CLK'event) then

      if (WEN1 = '1') then
        if (WADDR1_i < 8 or WADDR1_i = 15) then
          STD_REGS(WADDR1_i) <= WDATA1;
        elsif (WADDR1_i < 13) then
          case (EXE_MODE) is
            when USR    => STD_REGS(WADDR1_i) <= WDATA1;
            when SYS    => STD_REGS(WADDR1_i) <= WDATA1;
            when FIQ    => FIQ_REGS(WADDR1_i) <= WDATA1;
            when IRQ    => STD_REGS(WADDR2_i) <= WDATA1;
            when SVC    => STD_REGS(WADDR2_i) <= WDATA1;
            when ABT    => STD_REGS(WADDR2_i) <= WDATA1;
            when UND    => STD_REGS(WADDR2_i) <= WDATA1;
            when others => STD_REGS(       0) <= WDATA1;  -- Debug
          end case;
        else -- WADDR1_i < 15
          case (EXE_MODE) is
            when USR    => STD_REGS(WADDR1_i) <= WDATA1;
            when SYS    => STD_REGS(WADDR1_i) <= WDATA1;
            when FIQ    => FIQ_REGS(WADDR1_i) <= WDATA1;
            when IRQ    => IRQ_REGS(WADDR1_i) <= WDATA1;
            when SVC    => SVC_REGS(WADDR1_i) <= WDATA1;
            when ABT    => ABT_REGS(WADDR1_i) <= WDATA1;
            when UND    => UND_REGS(WADDR1_i) <= WDATA1;
            when others => STD_REGS(       0) <= WDATA1;  -- Debug
          end case;
        end if;
      end if;

      if (WEN2 = '1') then
        if (WADDR2_i < 8 or WADDR2_i = 15) then
          STD_REGS(WADDR2_i) <= WDATA2;
        elsif (WADDR2_i < 13) then
          case (EXE_MODE) is
            when USR    => STD_REGS(WADDR2_i) <= WDATA2;
            when SYS    => STD_REGS(WADDR2_i) <= WDATA2;
            when FIQ    => FIQ_REGS(WADDR2_i) <= WDATA2;
            when IRQ    => STD_REGS(WADDR2_i) <= WDATA2;
            when SVC    => STD_REGS(WADDR2_i) <= WDATA2;
            when ABT    => STD_REGS(WADDR2_i) <= WDATA2;
            when UND    => STD_REGS(WADDR2_i) <= WDATA2;
            when others => STD_REGS(       0) <= WDATA2;  -- Debug
          end case;
        else -- WADDR2_i < 15
          case (EXE_MODE) is
            when USR    => STD_REGS(WADDR2_i) <= WDATA2;
            when SYS    => STD_REGS(WADDR2_i) <= WDATA2;
            when FIQ    => FIQ_REGS(WADDR2_i) <= WDATA2;
            when IRQ    => IRQ_REGS(WADDR2_i) <= WDATA2;
            when SVC    => SVC_REGS(WADDR2_i) <= WDATA2;
            when ABT    => ABT_REGS(WADDR2_i) <= WDATA2;
            when UND    => UND_REGS(WADDR2_i) <= WDATA2;
            when others => STD_REGS(       0) <= WDATA2;  -- Debug
          end case;
        end if;
      end if;

      -- CPSR WRITE ------------------------------------------------------

      if (CPSR_FM(3) = '1') then
        CPSR_REG(31 downto 24) <= CPSR_IN(31 downto 24);
      end if;

      if (CPSR_FM(2) = '1') then
        CPSR_REG(23 downto 16) <= CPSR_IN(23 downto 16);
      end if;

      if (CPSR_FM(1) = '1') then
        CPSR_REG(15 downto  8) <= CPSR_IN(15 downto  8);
      end if;

      if (CPSR_FM(0) = '1') then
        CPSR_REG( 7 downto  0) <= CPSR_IN( 7 downto  0);
      end if;

      if (THUMB_SET = '1') then
        CPSR_REG(CPSR_FLAG_TMB) <= '1';
      elsif (THUMB_RST = '1') then
        CPSR_REG(CPSR_FLAG_TMB) <= '0';
      end if;

      if (IRQ_SET = '1') then
        CPSR_REG(CPSR_FLAG_I) <= '1';
      elsif (IRQ_RST = '1') then
        CPSR_REG(CPSR_FLAG_I) <= '0';
      end if;

      if (FIQ_SET = '1') then
        CPSR_REG(CPSR_FLAG_F) <= '1';
      elsif (FIQ_RST = '1') then
        CPSR_REG(CPSR_FLAG_F) <= '0';
      end if;


      -- SPSR WRITE ------------------------------------------------------

      if (SPSR_FM(3) = '1') then
        case (EXE_MODE) is
          when FIQ    => FIQ_SPSR(31 downto 24) <= SPSR_IN(31 downto 24);
          when IRQ    => IRQ_SPSR(31 downto 24) <= SPSR_IN(31 downto 24);
          when SVC    => SVC_SPSR(31 downto 24) <= SPSR_IN(31 downto 24);
          when ABT    => ABT_SPSR(31 downto 24) <= SPSR_IN(31 downto 24);
          when UND    => UND_SPSR(31 downto 24) <= SPSR_IN(31 downto 24);
          when others => CPSR_REG(31 downto 24) <= SPSR_IN(31 downto 24); -- Debug
        end case;
      end if;

      if (SPSR_FM(2) = '1') then
        case (EXE_MODE) is
          when FIQ    => FIQ_SPSR(23 downto 16) <= SPSR_IN(23 downto 16);
          when IRQ    => IRQ_SPSR(23 downto 16) <= SPSR_IN(23 downto 16);
          when SVC    => SVC_SPSR(23 downto 16) <= SPSR_IN(23 downto 16);
          when ABT    => ABT_SPSR(23 downto 16) <= SPSR_IN(23 downto 16);
          when UND    => UND_SPSR(23 downto 16) <= SPSR_IN(23 downto 16);
          when others => CPSR_REG(23 downto 16) <= SPSR_IN(23 downto 16); -- Debug
        end case;
      end if;

      if (SPSR_FM(1) = '1') then
        case (EXE_MODE) is
          when FIQ    => FIQ_SPSR(15 downto  8) <= SPSR_IN(15 downto  8);
          when IRQ    => IRQ_SPSR(15 downto  8) <= SPSR_IN(15 downto  8);
          when SVC    => SVC_SPSR(15 downto  8) <= SPSR_IN(15 downto  8);
          when ABT    => ABT_SPSR(15 downto  8) <= SPSR_IN(15 downto  8);
          when UND    => UND_SPSR(15 downto  8) <= SPSR_IN(15 downto  8);
          when others => CPSR_REG(15 downto  8) <= SPSR_IN(15 downto  8); -- Debug
        end case;
      end if;

      if (SPSR_FM(0) = '1') then
        case (EXE_MODE) is
          when FIQ    => FIQ_SPSR( 7 downto  0) <= SPSR_IN( 7 downto  0);
          when IRQ    => IRQ_SPSR( 7 downto  0) <= SPSR_IN( 7 downto  0);
          when SVC    => SVC_SPSR( 7 downto  0) <= SPSR_IN( 7 downto  0);
          when ABT    => ABT_SPSR( 7 downto  0) <= SPSR_IN( 7 downto  0);
          when UND    => UND_SPSR( 7 downto  0) <= SPSR_IN( 7 downto  0);
          when others => CPSR_REG( 7 downto  0) <= SPSR_IN( 7 downto  0); -- Debug
        end case;
      end if;


      if (PC_WE = '1') then
        STD_REGS(15) <= PC_IN;
      end if;

    end if;

  end process; -- REG_WRITE_p

end architecture; -- BHV
