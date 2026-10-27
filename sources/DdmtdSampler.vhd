library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library mylib;
use mylib.defPhase.all;

entity DdmtdSampler is
  generic(
    -- Bit Value Media
    kDetTh          : integer := 8;   -- detector threshold
    -- DEBUG --
    enDebug         : boolean := false
  );
  port
  (
    -- Base clock signal
    sig       : in  std_logic;

    -- Output
    ddmtdSig  : out std_logic;
    leading   : out std_logic;

    -- Clock and reset (reference clock signal domain)
    clk       : in  std_logic;
    rst       : in  std_logic
  );
end DdmtdSampler;

architecture RTL of DdmtdSampler is
  constant kDetThWidth  : natural := clog2(kDetTh*2+1) + 1;
  
  -- ddmtd samper
  signal ddmtd_s1       : std_logic := '0';
  signal ddmtd_s2       : std_logic := '0';
  signal ddmtd_signal   : std_logic := '0';
  
  attribute ASYNC_REG : string;
  attribute SHREG_EXTRACT : string;

  attribute ASYNC_REG of ddmtd_s1     : signal is "TRUE";
  attribute ASYNC_REG of ddmtd_s2     : signal is "TRUE";
  attribute ASYNC_REG of ddmtd_signal : signal is "TRUE";

  attribute SHREG_EXTRACT of ddmtd_s1     : signal is "NO";
  attribute SHREG_EXTRACT of ddmtd_s2     : signal is "NO";
  attribute SHREG_EXTRACT of ddmtd_signal : signal is "NO";
  
  -- ddmtd leading
  type type_det_status is (IDLE,RISE,FALL);
  signal det_status : type_det_status := IDLE;
  signal count_threshold: std_logic_vector(kDetThWidth-1 downto 0) := std_logic_vector(to_unsigned(kDetTh, kDetThWidth));
  signal ddmtd_leading  : std_logic := '0';
  
  -- debug --
  attribute mark_debug : boolean;
  attribute mark_debug  of ddmtd_signal     : signal is enDebug;
  attribute mark_debug  of det_status       : signal is enDebug;
  attribute mark_debug  of count_threshold  : signal is enDebug;
  attribute mark_debug  of ddmtd_leading    : signal is enDebug;
  
begin

  ddmtdSig <= ddmtd_signal;
  leading <= ddmtd_leading;
  
  -- ddmtd sampler
  u_ddmtd_smapler_process : process(clk)
  begin
    if(clk'event and clk='1')then
      ddmtd_s1     <= sig;
      ddmtd_s2     <= ddmtd_s1;
      ddmtd_signal <= ddmtd_s2;
    end if;
  end process u_ddmtd_smapler_process;
  
  -- leading of base
  u_count_threshold_process : process(clk)
  begin
    if(clk'event and clk='1')then
      if(rst='1')then
        count_threshold <= std_logic_vector(to_unsigned(kDetTh, kDetThWidth));
      else
        if(ddmtd_signal='1' and (unsigned(count_threshold)<to_unsigned(kDetTh*2, kDetThWidth)))then
          count_threshold <= std_logic_vector(unsigned(count_threshold)+1); 
        elsif(ddmtd_signal='0' and (unsigned(count_threshold)>to_unsigned(0, kDetThWidth)))then
          count_threshold <= std_logic_vector(unsigned(count_threshold)-1); 
        end if;
      end if;
    end if;
  end process u_count_threshold_process;
  
  u_leading_base_process : process(clk)
  begin
    if(clk'event and clk='1')then
      if(rst='1')then
        det_status    <= IDLE;
        ddmtd_leading <= '0';
      else
        case det_status is
          when IDLE =>
            if(unsigned(count_threshold)>=to_unsigned(kDetTh*2, kDetThWidth))then
              det_status  <= FALL;
            elsif(unsigned(count_threshold)<=to_unsigned(0, kDetThWidth))then
              det_status  <= RISE;
            end if;
            ddmtd_leading <= '0';
          when RISE =>
            if(unsigned(count_threshold)=to_unsigned(kDetTh, kDetThWidth))then
              det_status  <= IDLE;
              ddmtd_leading <= '1';
            end if;
          when FALL =>
            if(unsigned(count_threshold)=to_unsigned(kDetTh, kDetThWidth))then
              det_status  <= IDLE;
            end if;
            ddmtd_leading <= '0';
          when others =>
            det_status      <= IDLE;
        end case;
      end if;
    end if;
  end process u_leading_base_process;

end RTL;
