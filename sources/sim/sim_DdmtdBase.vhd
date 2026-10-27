library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mylib;
use mylib.defPhase.all;

entity sim_DdmtdBase is
end entity;

architecture behavior of sim_DdmtdBase is
  signal clk        : std_logic := '0';
  signal clk_ddmtd  : std_logic := '0';
  signal rst        : std_logic := '0';

  signal ready      : std_logic;
  signal phase_base : std_logic_vector(kWidthPhase-1 downto 0);

  constant clk_period       : time := 8   ns;
  constant clk_ddmtd_period : time := 8.1 ns;
begin
  -- Clock generation
  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;
    end loop;
  end process;

  clk_ddmtd_process : process
  begin
    while true loop
      clk_ddmtd <= '0';
      wait for clk_ddmtd_period / 2;
      clk_ddmtd <= '1';
      wait for clk_ddmtd_period / 2;
    end loop;
  end process;

  -- DUT (Device Under Test)
  uut : entity mylib.DdmtdReference
    generic map (
      enDEBUG => true
    )
    port map (
      baseClk   => clk,
      ready     => ready,
      phaseRef  => phase_base,
      clk       => clk_ddmtd,
      rst       => rst
    );

end architecture;

