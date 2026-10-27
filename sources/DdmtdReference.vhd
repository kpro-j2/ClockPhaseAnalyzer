library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library mylib;
use mylib.defPhase.all;

entity DdmtdReference is
  generic(
    -- DEBUG --
    enDebug         : boolean := false
  );
  port
  (
    -- Base clock
    baseClk   : in  std_logic;

    -- Phase reference (DDMTD clock)
    ready     : out std_logic;
    phaseRef  : out std_logic_vector(kWidthPhase-1 downto 0);
    ddmtdSig  : out std_logic;

    -- Clock and reset (DDMTD clock)
    clk       : in  std_logic;
    rst       : in  std_logic
  );
end DdmtdReference;

architecture RTL of DdmtdReference is
  signal leading        : std_logic;
  signal reg_leading    : std_logic;
  
  signal counter_ready  : std_logic := '0';
  signal counter        : std_logic_vector(kWidthPhase-1 downto 0);
  
  -- debug --
  attribute mark_debug : boolean;
  attribute mark_debug  of counter_ready  : signal is enDebug;
  attribute mark_debug  of counter        : signal is enDebug;
  
begin

  ready     <= counter_ready;
  phaseRef  <= counter;
  
  -- ddmtd sampler
  u_ddmtd_sampler : entity mylib.DdmtdSampler
    generic map (
      kDetTh  => kDetThDdmtdSignal,
      enDEBUG => enDebug
    )
    port map (
      sig      => baseClk,
      ddmtdSig => ddmtdSig,
      leading  => leading,
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
        counter_ready <= '0';
      elsif(leading='1' and reg_leading='0') then
        counter_ready <= '1';
        counter       <= (others=>'0');
      else
        counter <= std_logic_vector(unsigned(counter)+1);
      end if;
    end if;
  end process;

end RTL;
