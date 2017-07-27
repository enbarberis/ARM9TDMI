library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use ieee.numeric_std.all;
use STD.textio.all;

library WORK;
use WORK.ARM_pack.all;

entity DATA_MEMORY is
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
end entity;

architecture BHV of DATA_MEMORY is

  constant DATA_MEMORY_FILE : string := "memory/data_memory_file.asciihex";

  subtype BYTE_t is std_logic_vector(7 downto 0);
  type DATA_MEM_t  is array (NBYTE-1 downto 0) of BYTE_t;

  function data_memory_init (fileName : in string) return DATA_MEM_t is

    file      dataMemoryFile : text;
    variable  row            : line;
    variable  tempDMEM       : DATA_MEM_t;
    variable  i              : integer := 0;

  begin

    file_open(dataMemoryFile, fileName, read_mode);

    while (not endfile(dataMemoryFile)) and (i < NBYTE) loop
      readline(dataMemoryFile, row);
      hread(row, tempDMEM(i));
      i := i + 1;
    end loop;

    file_close(dataMemoryFile);
    return tempDMEM;

  end function; -- data_memory_init

  signal DATA_MEMORY : DATA_MEM_t := data_memory_init(DATA_MEMORY_FILE);

begin

  -- NOTE: For sake of simplicity, only the strictly required signals are
  --       handled.

  DABE <= '1'; -- The Data Address Bus is always enabled
  DDBE <= '1'; -- The Data Data Bus is always enabled
  DABORT <= '0';
  READ_p : process(DnMREQ,DA,DnRW)
    variable data_address : natural;
  begin
    if DnMREQ = '0' then
      data_address := to_integer(unsigned(DA));
      if DnRW = '0' then
        -- Read Operation
        DDIN <= DATA_MEMORY(data_address+3) &
                DATA_MEMORY(data_address+2) &
                DATA_MEMORY(data_address+1) &
                DATA_MEMORY(data_address+0);
      else
        DDIN <= ( others => 'U' );
      end if;
    end if;
  end process;

  WRITE_p : process (CLK)
    variable data_address : integer;
  begin
    if CLK = '0' and CLK'event then
      if DnMREQ = '0' then
        data_address := to_integer(unsigned(DA));
        if DnRW = '1' then
          -- Write Operation
          DATA_MEMORY(data_address+0) <= DD(7 downto 0);
          DATA_MEMORY(data_address+1) <= DD(15 downto 8);
          DATA_MEMORY(data_address+2) <= DD(23 downto 16);
          DATA_MEMORY(data_address+3) <= DD(31 downto 24);
        end if;
      end if;
    end if;
  end process; -- REQUEST_p

end architecture; -- BHV
