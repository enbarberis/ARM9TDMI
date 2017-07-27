LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY FETCH_TESTBENCH IS
END FETCH_TESTBENCH;
 
ARCHITECTURE behavior OF FETCH_TESTBENCH IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT FETCH
    PORT(
         CLK : IN  std_logic;
         nRESET : IN  std_logic;
         nIRQ : IN  std_logic;
         nFIQ : IN  std_logic;
         BIGEND : IN  std_logic;
         HIVECS : IN  std_logic;
         ALU_OUTPUT : IN  std_logic_vector(31 downto 0);
         SPSR : IN  std_logic_vector(7 downto 0);
         DEC_SRC_NXT_IA : IN  std_logic_vector(1 downto 0);
         DEC_WR_IA : IN  std_logic;
         DEC_SRC_NXT_CPSR : IN  std_logic_vector(1 downto 0);
         DEC_WR_NXT_CPSR : IN  std_logic;
         DEC_WR_OPCODE : IN  std_logic;
         EXCEPTION_ADDR : IN  std_logic_vector(2 downto 0);
         IA_INC : OUT  std_logic_vector(31 downto 0);
         OPCODE : OUT  std_logic_vector(35 downto 0);
         NEXT_CPSR_Q : OUT  std_logic_vector(7 downto 0);
         IA : OUT  std_logic_vector(31 downto 0);
         InM : OUT  std_logic_vector(4 downto 0);
         InMREQ : OUT  std_logic;
         InTRANS : OUT  std_logic;
         ISEQ : OUT  std_logic;
         ID : IN  std_logic_vector(31 downto 0);
         IABE : IN  std_logic;
         IABORT : IN  std_logic;
         DABORT : IN  std_logic;
         DD : IN  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal nRESET : std_logic := '0';
   signal nIRQ : std_logic := '0';
   signal nFIQ : std_logic := '0';
   signal BIGEND : std_logic := '0';
   signal HIVECS : std_logic := '0';
   signal ALU_OUTPUT : std_logic_vector(31 downto 0) := (others => '0');
   signal SPSR : std_logic_vector(7 downto 0) := (others => '0');
   signal DEC_SRC_NXT_IA : std_logic_vector(1 downto 0) := (others => '0');
   signal DEC_WR_IA : std_logic := '0';
   signal DEC_SRC_NXT_CPSR : std_logic_vector(1 downto 0) := (others => '0');
   signal DEC_WR_NXT_CPSR : std_logic := '0';
   signal DEC_WR_OPCODE : std_logic := '0';
   signal EXCEPTION_ADDR : std_logic_vector(2 downto 0) := (others => '0');
   signal ID : std_logic_vector(31 downto 0) := (others => '0');
   signal IABE : std_logic := '0';
   signal IABORT : std_logic := '0';
   signal DABORT : std_logic := '0';
   signal DD : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal IA_INC : std_logic_vector(31 downto 0);
   signal OPCODE : std_logic_vector(35 downto 0);
   signal NEXT_CPSR_Q : std_logic_vector(7 downto 0);
   signal IA : std_logic_vector(31 downto 0);
   signal InM : std_logic_vector(4 downto 0);
   signal InMREQ : std_logic;
   signal InTRANS : std_logic;
   signal ISEQ : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FETCH PORT MAP (
          CLK => CLK,
          nRESET => nRESET,
          nIRQ => nIRQ,
          nFIQ => nFIQ,
          BIGEND => BIGEND,
          HIVECS => HIVECS,
          ALU_OUTPUT => ALU_OUTPUT,
          SPSR => SPSR,
          DEC_SRC_NXT_IA => DEC_SRC_NXT_IA,
          DEC_WR_IA => DEC_WR_IA,
          DEC_SRC_NXT_CPSR => DEC_SRC_NXT_CPSR,
          DEC_WR_NXT_CPSR => DEC_WR_NXT_CPSR,
          DEC_WR_OPCODE => DEC_WR_OPCODE,
          EXCEPTION_ADDR => EXCEPTION_ADDR,
          IA_INC => IA_INC,
          OPCODE => OPCODE,
          NEXT_CPSR_Q => NEXT_CPSR_Q,
          IA => IA,
          InM => InM,
          InMREQ => InMREQ,
          InTRANS => InTRANS,
          ISEQ => ISEQ,
          ID => ID,
          IABE => IABE,
          IABORT => IABORT,
          DABORT => DABORT,
          DD => DD
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
		nRESET <= '0';
      -- hold reset state for 100 ns.
      wait for (5*CLK_period + CLK_period/2);	

		nRESET <= '1';
		DD <= x"01234567";
		ID <= x"76543210";
		DEC_WR_OPCODE <= '1';
		DEC_WR_IA <= '1';
		EXCEPTION_ADDR <= "100";
		ALU_OUTPUT <= x"00000123";
		
      wait for CLK_period*10;
		DEC_SRC_NXT_IA <= "11";
		wait for CLK_period;
		DEC_SRC_NXT_IA <= "01";
		wait for CLK_period;
		HIVECS <= '1';
		wait for CLK_period;
		DEC_SRC_NXT_IA <= "10";
		wait for CLK_period;
		DEC_SRC_NXT_IA <= "00";
		

      -- insert stimulus here 

      wait;
   end process;

END;
