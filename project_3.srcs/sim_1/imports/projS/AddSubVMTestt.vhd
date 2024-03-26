library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity AddSubVMTest is
end entity;

architecture tb_arch of AddSubVMTest is
  signal clk, rst, start, operation : std_logic := '0';
  signal x, y, result : std_logic_vector(31 downto 0) := (others => '0');
  signal dep_sup, dep_inf, ready : std_logic;
  constant clock_period : time := 10 ns; 
  component addsubVM is
  	port(
	X : in std_logic_vector(31 downto 0);
	Y : in std_logic_vector(31 downto 0);
	Clk : in std_logic;
	Rst : in std_logic;
	Start: in std_logic;
	
	Operation : in std_logic;
	
	Result: out std_logic_vector(31 downto 0);
	
	DepasireSup: out std_logic;
	DepasireInf: out std_logic;
	
	Ready : out std_logic
	);
  end component;
begin

addsubvmcomp: addsubVM port map(x, y, clk, rst, start, operation, result, dep_sup, dep_inf, ready);
process
   begin
		clk <= '0';
		wait for clock_period/2;
		clk <= '1';
		wait for clock_period/2;
   end process;
   start <= '1';
   rst <= '0';
process
 begin
 --    + 
 
--   operation <= '0';
--   x <= X"40540000"; -- 3.3125
--   y <= X"403c0000"; -- 2.9375
----   raspuns =  40c80000
--   wait for 150 ns;

--   operation <= '0';
--   x <= X"c0540000"; -- -3.3125
--   y <= X"403c0000"; -- 2.9375
----   raspuns =  bec00000
--   wait for 150 ns;

--   operation <= '0';
--   x <= X"40540000"; -- 3.3125
--   y <= X"c03c0000"; -- -2.9375
-- --  raspuns =  3ec00000
--   wait for 150 ns;

--   operation <= '0';
--   x <= X"c0540000"; -- -3.3125
--   y <= X"c03c0000"; -- -2.9375
----   raspuns =  c0c80000
--   wait for 150 ns;

--    - 
 
--   operation <= '1';
--   x <= X"40540000"; -- 3.3125
--   y <= X"403c0000"; -- 2.9375
--  -- raspuns =  3ec00000
--   wait for 150 ns;

--   operation <= '1';
--   x <= X"c0540000"; -- -3.3125
--   y <= X"403c0000"; -- 2.9375
----   raspuns =  c0c80000
--   wait for 150 ns;

 operation <= '1';
   x <= X"40540000"; -- 3.3125
   y <= X"c03c0000"; -- -2.9375
--raspuns =  40c80000
   wait for 150 ns;

--   operation <= '1';
--   x <= X"c0540000"; -- -3.3125
--   y <= X"c03c0000"; -- -2.9375
-- --  raspuns =  bec00000
--   wait for 150 ns;
   


--   operation <= '0';
--   x <= X"7f000000"; 
--   y <= X"7f000000"; 
--   wait for 150 ns; --overflow
   end process;
end architecture;
