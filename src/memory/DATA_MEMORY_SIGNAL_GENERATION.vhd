library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library WORK;
use WORK.ARM_pack.all;

entity DATA_MEMORY_SIGNAL_GENERATION is
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
end entity;

architecture BHV of DATA_MEMORY_SIGNAL_GENERATION is

  signal DDEN_s, DLOCK_s, DSEQ_s, DMORE_s, DnMREQ_s, DnRW_s, DnTRANS_s : std_logic;
  signal DMAS_s : std_logic_vector(1 downto 0);
  signal DnM_s  : std_logic_vector(4 downto 0);

begin
  
  DDEN_s    <=  '1' when
                ( Mdata_en = '1' and Mdata_rd_nWr = '0') else
                '0';

  DLOCK_s   <=  '1' when
                ((Mdata_en = '1' and Mdata_rd_nWr = '1' and en_rdC = '1') or
                (Mdata_en = '1' and Mdata_rd_nWr = '0' and en_rdC = '0')) else
                '0';

  DMAS_s    <=  Mdata_dim;

  DSEQ_s    <=  '1' when (Mdata_en = '1' and Mdata_src_addr = "10") else  -- Address+4
                '0';

  DMORE_s   <=  '1' when (dec_Mdata_en = '1' and dec_Mdata_src_addr = "10" ) else
                '0';

  DnM_s     <=  CPSR_mode;

  DnMREQ_s  <=  not(Mdata_en);

  DnRW_s    <=  not(Mdata_rd_nWr);

  DnTRANS_s <=  '0' when CPSR_mode = "10000" else
                '1';

  process(clk,nRst)
  begin
    if ( nRst = '0' ) then
      DDEN        <=  '0'; 
      DLOCK       <=  '0';
      DMAS        <=  "00";
      DMORE       <=  '0';
      DSEQ        <=  '0';
      DnM         <=  "00000";
      DnMREQ      <=  '0';
      DnRW        <=  '0';
      DnTRANS     <=  '0';
    elsif ( clk = '0' and clk'event ) then
      DDEN        <=   DDEN_s   ;
      DLOCK       <=   DLOCK_s  ;
      DMAS        <=   DMAS_s   ;
      DMORE       <=   DMORE_s  ;
      DSEQ        <=   DSEQ_s   ;
      DnM         <=   DnM_s    ;
      DnMREQ      <=   DnMREQ_s ;
      DnRW        <=   DnRW_s   ;
      DnTRANS     <=   DnTRANS_s;
    end if;
  end process;

end architecture; -- BHV
