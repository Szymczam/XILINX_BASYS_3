----------------------------------------------------------------------------------
-- Marek
-- synchronous counter to "div_by",
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

----------------------------------------------------------------------------------

entity clk_div is
  generic(div_by : natural := 10	-- must be dividable by 2 !
	);      
  port(
	  clk_in  : in    std_logic;
      rst     : in    std_logic;
      clk_out : out   std_logic
	);
end entity clk_div;

----------------------------------------------------------------------------------

architecture counter of clk_div is
  constant count_top : natural := div_by / 2 - 1;
  constant bits      : natural := integer(ceil(log2(real(count_top + 1))));
  signal   cnt       : unsigned(bits - 1 downto 0);
  signal   tmp       : std_logic;
begin

----------------------------------------------------------------------------------

  process(clk_in, rst)
  begin
    if rst = '1' then
      clk_out <= '0';
      cnt     <= (others => '0');
    elsif rising_edge(clk_in) then
      if cnt = 0 then
        cnt     <= to_unsigned(count_top, bits);
        tmp     <= not tmp;
        clk_out <=  tmp;
      else
        cnt <= cnt - 1;
      end if;
    end if;
  end process;
  
 ----------------------------------------------------------------------------------
 
end architecture;