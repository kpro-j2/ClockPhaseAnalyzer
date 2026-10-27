library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mylib;

entity sim_DdmtdSampler is
end entity;

architecture behavior of sim_DdmtdSampler is
  signal clk        : std_logic := '0';
  signal clk_ddmtd  : std_logic := '0';
  signal rst        : std_logic := '0';

  signal ddmtd_leading  : std_logic := '0';

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
  uut : entity mylib.DdmtdSampler
    generic map (
      kDetTh  => 8,
      enDEBUG => true
    )
    port map (
      sig      => clk,
      leading  => ddmtd_leading,
      clk      => clk_ddmtd,
      rst      => rst
    );

end architecture;

