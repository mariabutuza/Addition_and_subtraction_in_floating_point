library ieee;
use ieee.std_logic_1164.all;

entity AliniereMantise is
	generic (n: integer);
	port(
	Clk: in std_logic;					   
	Rst: in std_logic;
	CE: in std_logic;
	Load: in std_logic;
	SRI: in std_logic;
	D : in std_logic_vector(n-1 downto 0 );
	Q : out std_logic_vector(n-1 downto 0)
	);
end AliniereMantise;
architecture AliniereMantise of AliniereMantise is
signal Qtemp : std_logic_vector(n-1 downto 0) := (others =>'0');
begin
	process(Clk)
	begin
		if rising_edge(Clk) then
			if Rst = '1' then 
				Qtemp <= (others => '0');
			elsif CE = '1' then
				if Load = '1' then 
					Qtemp <= D;
				else
					Qtemp <= SRI & Qtemp(n-1 downto 1); --shiftare cu un bit
				end if;
			end if;
		end if;
	end process;
	Q <= Qtemp;
end AliniereMantise;
