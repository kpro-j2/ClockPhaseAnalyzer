library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package defPhase is
    
    function clog2(n : natural) return natural;
    
    -- phase
    constant kPeriodPhase       : integer := 510; -- period of phase (unit: clock)
    constant kWidthPhase        : integer := 16;  -- width of phase (note: kWidthPhase>(kPeriodPhase^0.5) )
    
    -- leading identify
    constant kDetThDdmtdSignal  : integer := 32;  -- detector threshold of ddmtd signal
    
    -- Phase average in clock-period units
    constant kWidthFracPhaseAverage : integer := 25;  -- fractional bits per clock period
    constant kNumDetPhaseAverage    : integer := ((2**kWidthFracPhaseAverage) + kPeriodPhase/2) / kPeriodPhase;
    constant kWidthPhaseAverage     : integer := kWidthFracPhaseAverage;
    
    -- phase accumulator
    constant kWidthPhaseAccumulator : integer := kWidthPhaseAverage + 7; 

end package defPhase;
-- ----------------------------------------------------------------------------------
-- Package body
-- ----------------------------------------------------------------------------------
package body defPhase is

  function clog2(n : natural) return natural is
    variable i : natural := 0;
    variable v : natural := n - 1;
  begin
    while v > 0 loop
      i := i + 1;
      v := v / 2;
    end loop;
    return i;
  end function;
  
end package body defPhase;
