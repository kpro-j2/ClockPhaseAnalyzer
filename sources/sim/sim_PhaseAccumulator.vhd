library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library mylib;
use mylib.defPhase.all;

entity sim_PhaseAccumulator is
end entity;

architecture tb of sim_PhaseAccumulator is

  -- DUT I/O
  signal clear         : std_logic := '0';
  signal validAvgPhase : std_logic := '0';
  signal dataAvgPhase  : std_logic_vector(kWidthPhaseAverage-1 downto 0) := (others=>'0');

  signal ready         : std_logic;
  signal phaseShift    : signed(kWidthPhaseAccumulator-1 downto 0);

  signal clk           : std_logic := '0';
  signal rst           : std_logic := '1';

  constant CLK_PERIOD  : time := 8 ns; -- 125 MHz

  -- Convert a phase in ns to the normalized clock-period representation.
  function phase_to_dataAvgPhase(phase_ns : real) return std_logic_vector is
    constant kPeriodClockNs : real := 8.0;
    variable scaled         : integer;
  begin
    scaled := integer(
      (phase_ns/kPeriodClockNs) * real(2.0**kWidthFracPhaseAverage)
    );
    return std_logic_vector(to_unsigned(scaled,dataAvgPhase'length));
  end function;

begin

  -- clock
  clk <= not clk after CLK_PERIOD/2;

  uut : entity mylib.PhaseAccumulator
    generic map(
      enDebug => false
    )
    port map(
      clear         => clear,
      validAvgPhase => validAvgPhase,
      dataAvgPhase  => dataAvgPhase,
      ready         => ready,
      phaseShift    => phaseShift,
      clk           => clk,
      rst           => rst
    );

    stim : process
    variable ps_int : integer;
  begin
    -- reset
    rst <= '1';
    clear <= '0';
    validAvgPhase <= '0';
    dataAvgPhase <= (others=>'0');

    wait for 5*CLK_PERIOD;
    wait until rising_edge(clk);
    rst <= '0';

    wait for 3*CLK_PERIOD;

    report "============================================================";
    report "Small-step test with ONE wrap across boundary";
    report "P=510, shift=16";
    report "Case A (before clear): 508 -> 509 -> 0 -> 1  (expect wrap at 509->0 gives +1)";
    report "Case B (after  clear): 1 -> 0 -> 509 -> 508 (expect wrap at 0->509 gives -1)";
    report "============================================================";

    ------------------------------------------------------------------
    -- Case A: 508 -> 509 -> 0 -> 1
    -- expected diffs: +1, +1(wrap), +1
    ------------------------------------------------------------------

    -- Sample #1 init at 508 (acc_ready was 0, diff forced 0)
    report "---- Case A: init phase=508 (diff forced 0) ----";
    dataAvgPhase  <= phase_to_dataAvgPhase(7.8);
    validAvgPhase <= '1';
    wait until rising_edge(clk);
    validAvgPhase <= '0';
    wait for 2*CLK_PERIOD;
    ps_int := to_integer(phaseShift);
    report "phaseShift=" & integer'image(ps_int) & " (after init)";

    -- Sample #2: 509 (small +1)
    report "---- Case A: phase=509 (expect +1<<16 accumulated) ----";
    dataAvgPhase  <= phase_to_dataAvgPhase(7.9);
    validAvgPhase <= '1';
    wait until rising_edge(clk);
    validAvgPhase <= '0';
    wait for 2*CLK_PERIOD;
    ps_int := to_integer(phaseShift);
    report "phaseShift=" & integer'image(ps_int);

    -- Sample #3: 0 (cross boundary 509->0, expect wrap => +1 not -509)
    report "---- Case A: phase=0 (CROSS 509->0, expect wrap => +1<<16) ----";
    dataAvgPhase  <= phase_to_dataAvgPhase(0.0);
    validAvgPhase <= '1';
    wait until rising_edge(clk);
    validAvgPhase <= '0';
    wait for 2*CLK_PERIOD;
    ps_int := to_integer(phaseShift);
    report "phaseShift=" & integer'image(ps_int);

    -- Sample #4: 1 (small +1)
    report "---- Case A: phase=1 (expect +1<<16) ----";
    dataAvgPhase  <= phase_to_dataAvgPhase(0.1);
    validAvgPhase <= '1';
    wait until rising_edge(clk);
    validAvgPhase <= '0';
    wait for 2*CLK_PERIOD;
    ps_int := to_integer(phaseShift);
    report "phaseShift=" & integer'image(ps_int);

    ------------------------------------------------------------------
    -- Clear accumulator (edge-detected)
    ------------------------------------------------------------------
    report "---- Clear accumulator ----";
    clear <= '0';
    wait until rising_edge(clk);
    clear <= '1';
    wait until rising_edge(clk);
    clear <= '0';
    wait for 2*CLK_PERIOD;
    ps_int := to_integer(phaseShift);
    report "After clear: phaseShift=" & integer'image(ps_int) & " ready=" & std_logic'image(ready);

    ------------------------------------------------------------------
    -- Case B: 1 -> 0 -> 509 -> 508
    -- expected diffs: -1, -1(wrap at 0->509), -1
    ------------------------------------------------------------------

    -- Sample #5 init at 1 (diff forced 0)
    report "---- Case B: init phase=1 (diff forced 0) ----";
    dataAvgPhase  <= phase_to_dataAvgPhase(0.2);
    validAvgPhase <= '1';
    wait until rising_edge(clk);
    validAvgPhase <= '0';
    wait for 2*CLK_PERIOD;
    ps_int := to_integer(phaseShift);
    report "phaseShift=" & integer'image(ps_int) & " (after init)";

    -- Sample #6: 0 (small -1)
    report "---- Case B: phase=0 (expect -1<<16 accumulated) ----";
    dataAvgPhase  <= phase_to_dataAvgPhase(0.1);
    validAvgPhase <= '1';
    wait until rising_edge(clk);
    validAvgPhase <= '0';
    wait for 2*CLK_PERIOD;
    ps_int := to_integer(phaseShift);
    report "phaseShift=" & integer'image(ps_int);

    -- Sample #7: 509 (cross boundary 0->509, expect wrap => -1 not +509)
    report "---- Case B: phase=509 (CROSS 0->509, expect wrap => -1<<16) ----";
    dataAvgPhase  <= phase_to_dataAvgPhase(7.9);
    validAvgPhase <= '1';
    wait until rising_edge(clk);
    validAvgPhase <= '0';
    wait for 2*CLK_PERIOD;
    ps_int := to_integer(phaseShift);
    report "phaseShift=" & integer'image(ps_int);

    -- Sample #8: 508 (small -1)
    report "---- Case B: phase=508 (expect -1<<16) ----";
    dataAvgPhase  <= phase_to_dataAvgPhase(7.8);
    validAvgPhase <= '1';
    wait until rising_edge(clk);
    validAvgPhase <= '0';
    wait for 2*CLK_PERIOD;
    ps_int := to_integer(phaseShift);
    report "phaseShift=" & integer'image(ps_int);

    report "Simulation finished." severity note;
    wait;
  end process;


end architecture;

