library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mylib;
use mylib.defPhase.all;

entity sim_PhaseAverage is
end entity;

architecture behavior of sim_PhaseAverage is
  signal clk        : std_logic := '0';
  signal rst        : std_logic := '0';
  signal link_up    : std_logic := '1';
  signal in_valid   : std_logic := '0';
  signal in_data    : std_logic_vector(kWidthPhase-1 downto 0):=(others=>'0');
  signal out_valid  : std_logic;
  signal out_data   : std_logic_vector(kWidthPhaseAverage-1 downto 0);

  constant clk_period       : time := 8   ns;
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
  
  -- in
  u_in_process : process
  begin
    wait until rising_edge(clk);
    in_valid<='0';
    wait until rising_edge(clk);
    in_valid<='1';
    in_data <= std_logic_vector(to_unsigned(102,in_data'length));
    
    wait until rising_edge(clk);
    in_valid<='0';
    wait until rising_edge(clk);
    in_valid<='1';
    in_data <= std_logic_vector(to_unsigned(101,in_data'length));
  
    wait until rising_edge(clk);
    in_valid<='0';
    wait until rising_edge(clk);
    in_valid<='1';
    in_data <= std_logic_vector(to_unsigned(99,in_data'length));
    
    wait until rising_edge(clk);
    in_valid<='0';
    wait until rising_edge(clk);
    in_valid<='1';
    in_data <= std_logic_vector(to_unsigned(98,in_data'length));
    
    wait until rising_edge(clk);
    in_valid<='0';
    
    wait until rising_edge(rst);
  end process;

  -- phase average
  uut : entity mylib.PhaseAverage
    generic map (
      enDEBUG => true
    )
    port map (
      linkUp        => link_up,
      
      validPhase    => in_valid,
      dataPhase     => in_data,
      
      validAvgPhase => out_valid,
      dataAvgPhase  => out_data,
      
      clk           => clk,
      rst           => rst
    );

end architecture;

