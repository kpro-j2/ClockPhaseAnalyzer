library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xpm;
use xpm.vcomponents.all;

library mylib;
use mylib.defPhase.all;

entity PhaseDetector is
  generic(
    -- DEBUG --
    enDebug         : boolean := false
  );
  port
  (
    -- MIKUMARI port (system clock)
    linkUp    : in  std_logic;
    modClk    : in  std_logic;

    -- Phase reference (DDMT clock)
    clkDdmtd  : in  std_logic;
    ready     : in  std_logic;
    phaseRef  : in  std_logic_vector(kWidthPhase-1 downto 0);
    ddmtdSig  : out std_logic;
    
    -- Petected phase (system clock)
    validPhase: out std_logic;
    dataPhase : out std_logic_vector(kWidthPhase-1 downto 0);

    -- Clock and reset (system clock)
    clk       : in  std_logic;
    rst       : in  std_logic
  );
end PhaseDetector;

architecture RTL of PhaseDetector is
  -- ddmtd clock domain
  signal link_up_ddmtd  : std_logic;
  signal rst_ddmtd      : std_logic;
  signal phase_ddmtd   : std_logic_vector(kWidthPhase downto 0);
  
  -- system clock domain
  signal phase_sys     : std_logic_vector(kWidthPhase downto 0);
  
  -- debug --
  attribute mark_debug : boolean;
--  attribute mark_debug  of counter_ready  : signal is enDebug;
  
begin
  
  validPhase  <= phase_sys(kWidthPhase);
  dataPhase   <= phase_sys(kWidthPhase-1 downto 0);
  
  -- clock domain crossing (sys-->ddmtd)
  xpm_cdc_link_up : xpm_cdc_single
  port map (
    src_clk   => clk,
    dest_clk  => clkDdmtd,
    src_in    => linkUp,
    dest_out  => link_up_ddmtd
  );
  
  xpm_cdc_rst : xpm_cdc_single
  port map (
    src_clk   => clk,
    dest_clk  => clkDdmtd,
    src_in    => rst,
    dest_out  => rst_ddmtd
  );
  
  -- clock domain crossing (ddmtd-->sys)
  xpm_cdc_phase : xpm_cdc_array_single
  generic map (
    WIDTH     => kWidthPhase+1
  )
  port map (
    src_clk   => clkDdmtd,
    dest_clk  => clk,
    src_in    => phase_ddmtd,
    dest_out  => phase_sys
  );

  -- output port
  u_det : entity mylib.DdmtdDetector
    generic map (
      enDebug => enDebug
    )
    port map (
      linkUp    => link_up_ddmtd,
      modClk    => modClk,
      ready     => ready,
      phaseRef  => phaseRef,
      validPhase=> phase_ddmtd(kWidthPhase),
      dataPhase => phase_ddmtd(kWidthPhase-1 downto 0),
      ddmtdSig  => ddmtdSig,
      clk       => clkDdmtd,
      rst       => rst_ddmtd
    );

end RTL;
