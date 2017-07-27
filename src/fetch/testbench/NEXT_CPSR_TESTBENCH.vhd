--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY NEXT_CPSR_TESTBENCH IS
END NEXT_CPSR_TESTBENCH;
 
ARCHITECTURE behavior OF NEXT_CPSR_TESTBENCH IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT NEXT_CPSR
    PORT(
         CLK : IN  std_logic;
         LD : IN  std_logic;
         nRST : IN  std_logic;
         EXCEPTION_ADDR : IN  std_logic_vector(2 downto 0);
         ALU_OUTPUT : IN  std_logic_vector(7 downto 0);
         SPSR : IN  std_logic_vector(7 downto 0);
         SEL : IN  std_logic_vector(1 downto 0);
         Q : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal LD : std_logic := '0';
   signal nRST : std_logic := '0';
   signal EXCEPTION_ADDR : std_logic_vector(2 downto 0) := (others => '0');
   signal ALU_OUTPUT : std_logic_vector(7 downto 0) := (others => '0');
   signal SPSR : std_logic_vector(7 downto 0) := (others => '0');
   signal SEL : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal Q : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: NEXT_CPSR PORT MAP (
          CLK => CLK,
          LD => LD,
          nRST => nRST,
          EXCEPTION_ADDR => EXCEPTION_ADDR,
          ALU_OUTPUT => ALU_OUTPUT,
          SPSR => SPSR,
          SEL => SEL,
          Q => Q
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		nRST <= '0';
      wait for CLK_period*10;
		nRST <= '1';
      
		LD <= '1';
		SEL <= "00";
		EXCEPTION_ADDR <= "000";
		wait for CLK_period;
		EXCEPTION_ADDR <= "001";
		wait for CLK_period;
		EXCEPTION_ADDR <= "010";
		wait for CLK_period;
		EXCEPTION_ADDR <= "011";
		wait for CLK_period;
		EXCEPTION_ADDR <= "100";
		wait for CLK_period;
		EXCEPTION_ADDR <= "101";
		wait for CLK_period;
		EXCEPTION_ADDR <= "110";
		wait for CLK_period;
		EXCEPTION_ADDR <= "111";
		wait for CLK_period;
		
		SPSR <= x"AB";
		SEL <= "10";
		wait for CLK_period;
		
		ALU_OUTPUT <= x"BA";
		SEL <= "01";
		wait for CLK_period;
		

      wait;
   end process;

END;
