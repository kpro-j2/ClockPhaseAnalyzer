library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xpm;
use xpm.vcomponents.all;

library mylib;
use mylib.defPhase.all;

entity PhaseReference is
  generic(
    -- DEBUG --
    enDebug         : boolean := false
  );
  port
  (
    -- Phase reference (DDMTD clock)
    clkDdmtd  : out std_logic;
    ready     : out std_logic;
    phaseRef  : out std_logic_vector(kWidthPhase-1 downto 0);
    ddmtdSig  : out std_logic;

    -- Clock and reset (system clock)
    clk       : in  std_logic;
    rst       : in  std_logic
  );
end PhaseReference;

architecture RTL of PhaseReference is
  signal clk_ddmtd  : std_logic;
  signal lock_ddmtd : std_logic;
  
  signal rst_ddmtd  : std_logic;
  signal rst_from_sys_ddmtd : std_logic;
  
  component mmcm_ddmtd
  port(
    -- Clock out ports
    clk_out1  : out std_logic;
    -- Status and control signals
    reset     : in  std_logic;
    locked    : out std_logic;
    clk_in1   : in  std_logic
  );
  end component;

  -- debug --
  attribute mark_debug : boolean;
--  attribute mark_debug  of counter_ready  : signal is enDebug;
  
begin

  clkDdmtd  <= clk_ddmtd;
  
  xpm_cdc_rst : xpm_cdc_single
  port map (
    src_clk   => clk,
    dest_clk  => clk_ddmtd,
    src_in    => rst,
    dest_out  => rst_from_sys_ddmtd
  );
  
  -- DDMTD Reference
  u_ddmtd_reference : entity mylib.DdmtdReference
    generic map (
      enDebug => enDebug
    )
    port map (
      baseClk   => clk,
      ready     => ready,
      phaseRef  => phaseRef,
      ddmtdSig  => ddmtdSig,
      clk       => clk_ddmtd,
      rst       => rst_ddmtd
    );

  -- MMCM clock source
  u_clk_ddmtd_inst : mmcm_ddmtd
  port map(
    -- Clock out ports
      clk_out1  => clk_ddmtd,
    -- Status and control signals
      reset     => '0',
      locked    => lock_ddmtd,
      clk_in1   => clk
  );

  rst_ddmtd <= rst_from_sys_ddmtd or (not lock_ddmtd);

end RTL;
