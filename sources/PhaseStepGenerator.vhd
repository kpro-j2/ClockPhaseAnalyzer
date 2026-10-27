library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xpm;
use xpm.vcomponents.all;

library mylib;
use mylib.defPhase.all;

entity PhaseStepGenerator is
  generic(
    -- Clock period
    kPeriodClockPs : positive := 8000;

    -- phase stage
    kStepPsStage   : positive := 78;
    kHysPsStage    : natural  := 10;
    
    -- DEBUG --
    enDebug       : boolean := false
  );
  port
  (
    -- Accumulator clear
    clear         : in  std_logic;
    
    -- Detected average phase input
    validAvgPhase : in  std_logic;
    dataAvgPhase  : in  std_logic_vector(kWidthPhaseAverage-1 downto 0);

    -- Detected accumulated phase shift
    plus          : out std_logic;
    minus         : out std_logic;

    -- Clock and reset
    clk           : in  std_logic;
    rst           : in  std_logic
  );
end PhaseStepGenerator;

architecture RTL of PhaseStepGenerator is
  signal reg_clear      : std_logic;
  signal reg_valid_phase: std_logic;
  
  signal phase_base     : signed(kWidthPhaseAverage+1 downto 0);

  signal acc_ready      : std_logic := '0';
  signal acc_phase      : signed(phase_base'range)  := (others=>'0');

  constant phase_base_range_1by2 : signed(phase_base'range) :=
    shift_left(to_signed(1, phase_base'length), kWidthFracPhaseAverage-1);
  constant phase_base_range      : signed(phase_base'range) :=
    shift_left(to_signed(1, phase_base'length), kWidthFracPhaseAverage);
  
  function ps_to_phase(ps : natural) return natural is
    constant kScale          : natural := 2**kWidthFracPhaseAverage;
    constant kScaleQuotient  : natural := kScale/kPeriodClockPs;
    constant kScaleRemainder : natural := kScale mod kPeriodClockPs;
  begin
    return ps*kScaleQuotient + (ps*kScaleRemainder + kPeriodClockPs/2)/kPeriodClockPs;
  end function;

  constant stage_range          : signed(phase_base'range) := to_signed(ps_to_phase(kStepPsStage), phase_base'length);
  constant stage_range_with_hys : signed(phase_base'range) := to_signed(ps_to_phase(kStepPsStage+kHysPsStage), phase_base'length);
  
  -- debug --
  attribute mark_debug : boolean;
  attribute mark_debug  of phase_base       : signal is enDebug;
  attribute mark_debug  of acc_ready        : signal is enDebug;
  attribute mark_debug  of acc_phase        : signal is enDebug;
  
  signal reg_phase_diff : signed(phase_base'range);
  signal reg_phase_acc  : signed(phase_base'range);

begin

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
    variable phase_acc  : signed(phase_base'range);
  begin
    if rising_edge(clk) then
      if (rst='1' or (clear='1' and reg_clear='0')) then
        acc_ready   <= '0';
        acc_phase   <= (others=>'0');
        plus        <='0';
        minus       <='0';
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
        if (phase_diff > phase_base_range_1by2) then
          phase_diff  := phase_diff - phase_base_range;
        elsif (phase_diff < -phase_base_range_1by2) then
          phase_diff  := phase_diff + phase_base_range;
        end if;
        phase_acc := acc_phase+phase_diff;
        -- check stage
        if (phase_acc >= stage_range_with_hys) then
          acc_phase <= phase_acc-stage_range;
          plus  <='1';
          minus <='0';
        elsif (phase_acc <= -stage_range_with_hys) then
          acc_phase <= phase_acc+stage_range;
          plus  <='0';
          minus <='1';
        else
          acc_phase <= phase_acc;
          plus  <='0';
          minus <='0';
        end if;
        reg_phase_diff <= phase_diff;
        reg_phase_acc  <= phase_acc;
      else
        plus  <='0';
        minus <='0';
      end if;
    end if;
  end process;
  
end RTL;
