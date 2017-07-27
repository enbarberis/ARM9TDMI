LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY INSTRUCTION_MEMORY_TESTBENCH IS
END INSTRUCTION_MEMORY_TESTBENCH;
 
ARCHITECTURE behavior OF INSTRUCTION_MEMORY_TESTBENCH IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT INSTRUCTION_MEMORY
    PORT(
         IA : IN  std_logic_vector(31 downto 0);
         InM : IN  std_logic_vector(4 downto 0);
         InMREQ : IN  std_logic;
         InTRANS : IN  std_logic;
         ISEQ : IN  std_logic;
         ITBIT : IN  std_logic;
         
         ID : OUT  std_logic_vector(31 downto 0);
         IABE : OUT  std_logic;
         IABORT : OUT  std_logic
        );
    END COMPONENT;
    
 
   --Inputs
   signal IA : std_logic_vector(31 downto 0) := (others => '0');
   signal InM : std_logic_vector(4 downto 0) := (others => '0');
   signal InMREQ : std_logic := '0';
   signal InTRANS : std_logic := '0';
   signal ISEQ : std_logic := '0';
   signal ITBIT : std_logic := '0';

 	--Outputs
   signal ID : std_logic_vector(31 downto 0);
   signal IABE : std_logic;
   signal IABORT : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: INSTRUCTION_MEMORY PORT MAP (
          IA => IA,
          InM => InM,
          InMREQ => InMREQ,
          InTRANS => InTRANS,
          ISEQ => ISEQ,
          ITBIT => ITBIT,
          ID => ID,
          IABE => IABE,
          IABORT => IABORT
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      IA <= "00000000000000000000000000000001";
		wait for CLK_period;
		
		IA <= "00000000000000000000000000000010";
		wait for CLK_period;
		
		IA <= "00000000000000000000000000000000";
		InTRANS <= '1';
		wait for CLK_period;
		
		IA <= "00000000000000000000000000000100";
		wait for CLK_period;
		
		IA <= "00000000000000000000000000001000";
		wait for CLK_period;
		
		IA <= "00000000000000000000000000001100";
		wait for CLK_period;

      wait;
   end process;

END;
