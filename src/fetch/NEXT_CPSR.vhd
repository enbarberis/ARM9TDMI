library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library WORK;
use WORK.ARM_pack.all;


entity NEXT_CPSR is
  port (
    CLK             : in  std_logic;
    LD              : in  std_logic;
    nRST            : in  std_logic;
    EXCEPTION_ADDR  : in  std_logic_vector(2 downto 0);
    ALU_OUTPUT      : in  std_logic_vector(7 downto 0);
    SPSR            : in  std_logic_vector(7 downto 0);
    SEL             : in  std_logic_vector(1 downto 0);   --00 Execption addr, 01 ALU OUTPUT, 10 SPSR, 11 SPSR

    Q               : out std_logic_vector(7 downto 0)
  );
end entity NEXT_CPSR;


architecture BHV of NEXT_CPSR is

  signal D        :     std_logic_vector (7 downto 0);  -- Next CPSR register input
  signal Q_s      :     std_logic_vector (7 downto 0);  -- Next CPSR register output

begin

  Q <= Q_s;

  D_proc:     process(EXCEPTION_ADDR, ALU_OUTPUT, SPSR, SEL)

    variable MODE   : std_logic_vector (4 downto 0);  -- Mode to be loaded
    variable F_bit  : std_logic;                      -- Fast interrupt bit

  begin

    if    SEL = "00" then

      case EXCEPTION_ADDR is
        when "000" => MODE := SYS; --reset
        when "001" => MODE := UND;  --undefined instruction
        when "010" => MODE := SVC;  --software interrupt
        when "011" => MODE := ABT;  --prefetch abort
        when "100" => MODE := ABT;  --data abort
        when "110" => MODE := IRQ;  --IRQ interrupt
        when "111" => MODE := FIQ;  -- IFQ interrupt
        when others => MODE := USR; --When other address USR mode for security reason
      end case;


      if EXCEPTION_ADDR = "111" then
        F_bit := '1';
      else
        F_bit := '0';
      end if;


      D <= '1' & F_BIT & '0' & MODE;  --Disable IRQ, Disable IFQ if enter IFQ, ARM mode

    elsif SEL = "01" then
      D <= ALU_OUTPUT;

    elsif SEL = "10" then
      D <= SPSR;

    else
      D <= SPSR;

    end if;
  end process;


  reg_proc:   process (CLK, nRST)
  begin
    if nRST = '0' then
      Q_s <= (others => '0');
    else
      if CLK = '0' and CLK'EVENT then
        if LD = '1' then
          Q_s <= D;
        end if;
      end if;
    end if;
  end process;


end architecture BHV;
