LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY DATA_MEMORY_TESTBENCH IS
END DATA_MEMORY_TESTBENCH;
 
ARCHITECTURE behavior OF DATA_MEMORY_TESTBENCH IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DATA_MEMORY
    PORT(
         CLK : IN std_logic;
         DA : IN  std_logic_vector(31 downto 0);
         DABE : OUT  std_logic;
         DABORT : IN  std_logic;
         DD : IN  std_logic_vector(31 downto 0);
         DDBE : OUT  std_logic;
         DDEN : IN  std_logic;
         DDIN : OUT  std_logic_vector(31 downto 0);
         DLOCK : IN  std_logic;
         DMAS : IN  std_logic_vector(1 downto 0);
         DMORE : IN  std_logic;
         DnM : IN  std_logic_vector(4 downto 0);
         DnMREQ : IN  std_logic;
         DnRW : IN  std_logic;
         DnTRANS : IN  std_logic;
         DSEQ : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic;
   signal DA : std_logic_vector(31 downto 0) := (others => '0');
   signal DABORT : std_logic := '0';
   signal DD : std_logic_vector(31 downto 0) := (others => '0');
   signal DDEN : std_logic := '0';
   signal DLOCK : std_logic := '0';
   signal DMAS : std_logic_vector(1 downto 0) := (others => '0');
   signal DMORE : std_logic := '0';
   signal DnM : std_logic_vector(4 downto 0) := (others => '0');
   signal DnMREQ : std_logic := '0';
   signal DnRW : std_logic := '0';
   signal DnTRANS : std_logic := '0';
   signal DSEQ : std_logic := '0';

 	--Outputs
   signal DABE : std_logic;
   signal DDBE : std_logic;
   signal DDIN : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN

  clk_process: process 
  begin
    CLK <= '0';
    wait for clk_period/2;
    CLK <= '1';
    wait for clk_period/2;
  end process;

 
	-- Instantiate the Unit Under Test (UUT)
   uut: DATA_MEMORY PORT MAP (
          CLK => CLK,
          DA => DA,
          DABE => DABE,
          DABORT => DABORT,
          DD => DD,
          DDBE => DDBE,
          DDEN => DDEN,
          DDIN => DDIN,
          DLOCK => DLOCK,
          DMAS => DMAS,
          DMORE => DMORE,
          DnM => DnM,
          DnMREQ => DnMREQ,
          DnRW => DnRW,
          DnTRANS => DnTRANS,
          DSEQ => DSEQ
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
		DA <= "00000000000000000000000000000000";
		wait for CLK_period;
		
		DA <= "00000000000000000000000000000100";
		wait for CLK_period;
		
		DA <= "00000000000000000000000000001000";
		wait for CLK_period;
		
		DA <= "00000000000000000000000000001100";
		wait for CLK_period; 
		
		DnRW <= '1';
		DD <= x"01234567";
		
		DA <= "00000000000000000000000000000000";
		wait for CLK_period;
		
		DA <= "00000000000000000000000000000100";
		wait for CLK_period;
		
		DA <= "00000000000000000000000000001000";
		wait for CLK_period;
		
		DA <= "00000000000000000000000000001100";
		wait for CLK_period; 
		
		DnRW <= '0';
		
		DA <= "00000000000000000000000000000000";
		wait for CLK_period;
		
		DA <= "00000000000000000000000000000100";
		wait for CLK_period;
		
		DA <= "00000000000000000000000000001000";
		wait for CLK_period;
		
		DA <= "00000000000000000000000000001100";
		wait for CLK_period; 

      wait;
   end process;

END;
