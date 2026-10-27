library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xpm;
use xpm.vcomponents.all;

library mylib;
use mylib.defPhase.all;

entity PhaseAverage is
  generic(
    -- DEBUG --
    enDebug         : boolean := false
  );
  port
  (
    -- MIKUMARI port
    linkUp        : in  std_logic;
    
    -- Detected phase
    validPhase    : in  std_logic;
    dataPhase     : in  std_logic_vector(kWidthPhase-1 downto 0);
    
    -- Detected average phase
    validAvgPhase : out std_logic;
    dataAvgPhase  : out std_logic_vector(kWidthPhaseAverage-1 downto 0);

    -- Clock and reset
    clk           : in  std_logic;
    rst           : in  std_logic
  );
end PhaseAverage;

architecture RTL of PhaseAverage is
  signal reg_valid      : std_logic;

  signal reg_phase_valid: std_logic;
  signal reg_phase_data : signed(clog2(kPeriodPhase)+1 downto 0);

  signal acc_count      : unsigned(clog2(kNumDetPhaseAverage)-1 downto 0) := (others=>'0');
  signal reg_acc_count  : unsigned(acc_count'range);
  signal acc_phase      : signed(clog2(kPeriodPhase)+1+clog2(kNumDetPhaseAverage) downto 0);
  signal acc_base       : signed(clog2(kPeriodPhase)+1 downto 0);

  signal out_avg_valid  : std_logic := '0';
  signal out_avg_data   : std_logic_vector(kWidthPhaseAverage-1 downto 0);

  function center(input : signed;
                  ref   : signed)
  return signed is
    variable diff   : signed(ref'range);
    variable output : signed(ref'range);
  begin
    -- diff
    diff := input - ref;
    -- output
    if (diff > to_signed(kPeriodPhase/2, ref'length)) then
        output := input - to_signed(kPeriodPhase, ref'length);
    elsif (diff < to_signed(-kPeriodPhase/2, ref'length)) then
        output := input + to_signed(kPeriodPhase, ref'length);
    else
        output := input;
    end if;
    -- reutrn
    return output;
  end function;
  
  -- debug --
  attribute mark_debug : boolean;
  attribute mark_debug  of reg_phase_valid  : signal is enDebug;
  attribute mark_debug  of reg_phase_data   : signal is enDebug;
  attribute mark_debug  of acc_count        : signal is enDebug;
  attribute mark_debug  of reg_acc_count    : signal is enDebug;
  attribute mark_debug  of acc_phase        : signal is enDebug;
  attribute mark_debug  of acc_base         : signal is enDebug;

begin

  validAvgPhase <= out_avg_valid;
  dataAvgPhase  <= out_avg_data;

  -- reg
  u_reg_process : process(clk)
  begin
    if rising_edge(clk) then
      reg_valid     <= validPhase;
      reg_acc_count <= acc_count;
    end if;
  end process;
  
  -- input phase value
  u_phase_process : process(clk)
  begin
    if rising_edge(clk) then
      if (rst='1' or linkUp='0') then
        reg_phase_valid <= '0';
      elsif (validPhase='1' and reg_valid='0') then
        if (unsigned(dataPhase) < shift_left(to_unsigned(1, dataPhase'length), clog2(kPeriodPhase)) ) then
          reg_phase_valid <= '1';
          reg_phase_data  <= resize(signed(dataPhase),reg_phase_data'length);
        else
          reg_phase_valid <= '0';
        end if;
      else
        reg_phase_valid <= '0';
      end if;
    end if;
  end process;
  
  -- acc
  u_acc_process : process(clk)
    variable  in_data : unsigned(acc_phase'range);
  begin
    if rising_edge(clk) then
      if (rst='1' or linkUp='0') then
        acc_count <= (others=>'0');
      elsif (reg_phase_valid='1') then
        if (acc_count = to_unsigned(0,acc_count'length)) then
          acc_count     <= acc_count+1;
          acc_phase     <= resize(reg_phase_data,acc_phase'length);
          acc_base      <= reg_phase_data;
        elsif (acc_count = to_unsigned(kNumDetPhaseAverage-1,acc_count'length)) then
          acc_count     <= (others=>'0');
          acc_phase     <= acc_phase + resize(center(reg_phase_data,acc_base),acc_phase'length);
        else
          acc_count     <= acc_count+1;
          acc_phase     <= acc_phase + resize(center(reg_phase_data,acc_base),acc_phase'length);
        end if;
      else
      end if;
    end if;
  end process;
  
  -- out
  u_out_process : process(clk)
  begin
    if rising_edge(clk) then
      if (rst='1' or linkUp='0') then
        out_avg_valid <= '0';
      elsif (reg_acc_count=to_unsigned(kNumDetPhaseAverage-1,acc_count'length) and acc_count/=reg_acc_count) then
        out_avg_valid <= '1';
        out_avg_data  <= std_logic_vector(acc_phase(kWidthPhaseAverage-1 downto 0));
      else
        out_avg_valid <= '0';
      end if;
    end if;
  end process;

end RTL;
