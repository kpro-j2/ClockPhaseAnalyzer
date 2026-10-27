library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xpm;
use xpm.vcomponents.all;

library mylib;
use mylib.defPhase.all;

entity PhaseAccumulator is
  generic(
    -- DEBUG --
    enDebug         : boolean := false
  );
  port
  (
    -- Accumulator clear
    clear         : in  std_logic;
    
    -- Detected average phase input
    validAvgPhase : in  std_logic;
    dataAvgPhase  : in  std_logic_vector(kWidthPhaseAverage-1 downto 0);

    -- Detected accumulated phase shift
    ready         : out std_logic;
    phaseShift    : out signed(kWidthPhaseAccumulator-1 downto 0);

    -- Clock and reset
    clk           : in  std_logic;
    rst           : in  std_logic
  );
end PhaseAccumulator;

architecture RTL of PhaseAccumulator is
  signal reg_clear      : std_logic;
  signal reg_valid_phase: std_logic;
  
  signal phase_base     : signed(kWidthPhaseAverage+1 downto 0);

  signal acc_ready      : std_logic := '0';
  signal acc_phase      : signed(phaseShift'range)  := (others=>'0');

  constant phase_base_range_1by2 : signed(phase_base'range) := shift_left(to_signed(1, phase_base'length), kWidthFracPhaseAverage-1);
  constant phase_base_range      : signed(phase_base'range) := shift_left(to_signed(1, phase_base'length), kWidthFracPhaseAverage);
  
  -- debug --
  attribute mark_debug : boolean;
  attribute mark_debug  of reg_clear        : signal is enDebug;
  attribute mark_debug  of reg_valid_phase  : signal is enDebug;
  attribute mark_debug  of phase_base       : signal is enDebug;
  attribute mark_debug  of acc_ready        : signal is enDebug;
  attribute mark_debug  of acc_phase        : signal is enDebug;

begin

  ready       <= acc_ready;
  phaseShift  <= acc_phase;

  -- reg
  u_reg_process : process(clk)
  begin
    if rising_edge(clk) then
      reg_valid_phase <= validAvgPhase;
      reg_clear       <= clear;
    end if;
  end process;
  
  -- acc
  u_acc_process : process(clk)
    variable phase_diff : signed(phase_base'range);
  begin
    if rising_edge(clk) then
      if (rst='1' or (clear='1' and reg_clear='0')) then
        acc_ready   <= '0';
        acc_phase   <= (others=>'0');
      elsif (validAvgPhase='1' and reg_valid_phase='0') then
        acc_ready   <= '1';
        phase_base  <= signed("00" & dataAvgPhase);
        -- calculate phase_diff
        if (acc_ready='0') then
          phase_diff  := (others=>'0'); 
        else
          phase_diff  := signed("00" & dataAvgPhase) - phase_base; 
        end if;
        -- modulate phase_diff
        if (phase_diff >= phase_base_range_1by2) then
          phase_diff  := phase_diff - phase_base_range;
        elsif (phase_diff < -phase_base_range_1by2) then
          phase_diff  := phase_diff + phase_base_range;
        end if;
        acc_phase   <= acc_phase+resize(phase_diff,acc_phase'length);
      end if;
    end if;
  end process;
  
end RTL;
