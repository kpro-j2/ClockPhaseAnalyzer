library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library mylib;
use mylib.defPhase.all;

entity DdmtdDetector is
  generic(
    -- DEBUG --
    enDebug         : boolean := false
  );
  port
  (
    -- MIKUMARI port (DDMTD clock)
    linkUp    : in  std_logic;
    modClk    : in  std_logic;

    -- Phase reference (DDMT clock)
    ready     : in  std_logic;
    phaseRef  : in  std_logic_vector(kWidthPhase-1 downto 0);
    ddmtdSig  : out std_logic;
    
    -- Detected phase (DDMT clock)
    validPhase: out std_logic;
    dataPhase : out std_logic_vector(kWidthPhase-1 downto 0);

    -- Clock and reset (DDMT clock)
    clk       : in  std_logic;
    rst       : in  std_logic
  );
end DdmtdDetector;

architecture RTL of DdmtdDetector is
  signal leading        : std_logic;
  signal reg_leading    : std_logic;
  
  signal phase_valid    : std_logic := '0';
  signal phase_data     : std_logic_vector(kWidthPhase-1 downto 0);
  
  -- debug --
  attribute mark_debug : boolean;
--  attribute mark_debug  of counter_ready  : signal is enDebug;
  
begin

  validPhase  <= phase_valid;
  dataPhase   <= phase_data;

  -- ddmtd sampler
  u_ddmtd_sampler : entity mylib.DdmtdSampler
    generic map (
      kDetTh  => kDetThDdmtdSignal,
      enDEBUG => enDebug
    )
    port map (
      sig      => modClk,
      leading  => leading,
      ddmtdSig => ddmtdSig,
      clk      => clk,
      rst      => rst
    );
  
  -- reg
  u_reg_process : process(clk)
  begin
    if(clk'event and clk='1')then
      reg_leading <= leading;
    end if;
  end process;
  
  -- counter
  u_counter_process : process(clk)
  begin
    if(clk'event and clk='1')then
      if(rst='1') then
        phase_valid <= '0';
      elsif(leading='1' and reg_leading='0' and linkUp='1' and ready='1') then
        phase_valid <= '1';
        phase_data  <= phaseRef;
      else
        phase_valid <= '0';
      end if;
    end if;
  end process;

end RTL;
