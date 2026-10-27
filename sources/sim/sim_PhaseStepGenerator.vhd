library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mylib;
use mylib.defPhase.all;

entity sim_PhaseStepGenerator is
end entity;

architecture behavior of sim_PhaseStepGenerator is
  -- DUT generics (match your defaults)
  constant kPeriodClockPs : integer := 8000;
  constant kStepPsStage : integer := 78;
  constant kHysPsStage  : integer := 10;

  signal clk           : std_logic := '0';
  signal rst           : std_logic := '0';
  signal clear         : std_logic := '0';

  signal validAvgPhase : std_logic := '0';
  signal dataAvgPhase  : std_logic_vector(kWidthPhaseAverage-1 downto 0) := (others => '0');

  signal plus          : std_logic;
  signal minus         : std_logic;
  
  function converter(pstime : natural)
  return std_logic_vector is
    constant kScale          : natural := 2**kWidthFracPhaseAverage;
    constant kScaleQuotient  : natural := kScale/kPeriodClockPs;
    constant kScaleRemainder : natural := kScale mod kPeriodClockPs;
    variable scaled          : natural;
  begin
    scaled := pstime*kScaleQuotient +
              (pstime*kScaleRemainder + kPeriodClockPs/2)/kPeriodClockPs;
    return std_logic_vector(to_unsigned(scaled, kWidthPhaseAverage));
  end function;
  
begin
  -- clock 100 MHz (8 ns)
  clk <= not clk after 4 ns;

  -- DUT
  uut: entity mylib.PhaseStepGenerator
    generic map(
      -- 如果你的 PhaseStepGenerator generic 宣告有 "constant"，請先改掉
      kPeriodClockPs => kPeriodClockPs,
      kStepPsStage   => kStepPsStage,
      kHysPsStage    => kHysPsStage,
      enDebug        => false
    )
    port map(
      clear         => clear,
      validAvgPhase => validAvgPhase,
      dataAvgPhase  => dataAvgPhase,
      plus          => plus,
      minus         => minus,
      clk           => clk,
      rst           => rst
    );

  -- in
  u_in_process : process
  begin
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000000"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000001"&"0000000000000000";
  
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000010"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000011"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000100"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000101"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000110"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000111"&"0000000000000000";

    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000001000"&"0000000000000000";

    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000001001"&"0000000000000000";

    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000001000"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000111"&"0000000000000000";
  
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000110"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000101"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000100"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000011"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000010"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000001"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "000000000"&"0000000000000000";

    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111111"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111110"&"0000000000000000";

    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111101"&"0000000000000000";

    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111100"&"0000000000000000";

    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111011"&"0000000000000000";

    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111010"&"0000000000000000";

    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111001"&"0000000000000000";

    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111000"&"0000000000000000";

    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111001"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111010"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111011"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111100"&"0000000000000000";
        wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111101"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111110"&"0000000000000000";
    
    wait until rising_edge(clk);
    validAvgPhase<='0';
    wait until rising_edge(clk);
    validAvgPhase<='1';
    dataAvgPhase <= "111111111"&"0000000000000000";
  end process;

end architecture;
