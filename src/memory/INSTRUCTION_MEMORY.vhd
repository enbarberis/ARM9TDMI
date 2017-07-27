library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use ieee.numeric_std.all;
use STD.textio.all;

library WORK;
use WORK.ARM_pack.all;

entity INSTRUCTION_MEMORY is
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
end entity;

architecture BHV of INSTRUCTION_MEMORY is

  constant INSTRUCTION_MEMORY_FILE : string := "memory/instruction_memory_file.asciihex";

  subtype BYTE_t is std_logic_vector(7 downto 0);
  type INSTRUCTION_MEM_t  is array (NWORDS-1 downto 0) of BYTE_t;
  type INSTRUCTION_FILE_t is file of ARM_INSTR_t;

  function instruction_memory_init (fileName : in string) return INSTRUCTION_MEM_t is

    file      instructionMemoryFile : text;
    variable  row                   : line;
    variable  tempIMEM              : INSTRUCTION_MEM_t;
    variable  i                     : integer := 0;

  begin

    file_open(instructionMemoryFile, fileName, read_mode);

    while (not endfile(instructionMemoryFile)) and (i < NWORDS) loop
      readline(instructionMemoryFile, row);
      hread(row, tempIMEM(i));
      i := i + 1;
    end loop;

    file_close(instructionMemoryFile);
    return tempIMEM;

  end function; -- instruction_memory_init

  signal INSTRUCTION_MEMORY : INSTRUCTION_MEM_t := instruction_memory_init(INSTRUCTION_MEMORY_FILE);

begin

  -- NOTE: For sake of simplicity, only the strictly required signals are
  --       handled.

  IABE <= '1'; -- The Instruction Address Bus is always enabled


  REQUEST_p : process (IA,InTRANS,InM)
    variable instruction_address : integer;
  begin
    if InMREQ = '0' then
      instruction_address := to_integer(unsigned(IA));
      -- Check that enough privileges to read the desried instruction
      -- Check alignes address
      if  (instruction_address < 128 and InTRANS = '0') or
          (instruction_address < 128 and InM = USR) or
          (IA(0) = '1')
      then
        ID <= (others => '0');
        IABORT <= '1';
      else
        ID <= INSTRUCTION_MEMORY(instruction_address+3) &
              INSTRUCTION_MEMORY(instruction_address+2) &
              INSTRUCTION_MEMORY(instruction_address+1) &
              INSTRUCTION_MEMORY(instruction_address+0);
        IABORT <= '0';
      end if;
    end if;
  end process; -- REQUEST_p

end architecture; -- BHV
