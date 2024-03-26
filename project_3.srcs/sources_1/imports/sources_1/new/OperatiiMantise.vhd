library ieee;
use ieee.std_logic_1164.all;   
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity OperatiiMantise is
	generic ( n : integer);
	port(
	sign1: in std_logic;
	sign2: in std_logic;
	Mantisa1 : in std_logic_vector(n-1 downto 0);
	Mantisa2 : in std_logic_vector(n-1 downto 0);
	AluOp	 : in std_logic;
	MantisaFinala : out std_logic_vector(n-1 downto 0);
	DepasireMantisa: out std_logic;
	RezultatZero : out std_logic
	);
end OperatiiMantise;					   

architecture OperatiiMantise of OperatiiMantise is
signal TempMantisa : std_logic_vector(n downto 0) := (others => '0');
 signal MantisaAligned : std_logic_vector(n downto 0);

begin

process (AluOp, Mantisa1, Mantisa2)
begin
if AluOp = '0' then
    if sign1 = '1' and sign2 = '0' then  --bit pentru carry/borrow
            TempMantisa <= ('0' & Mantisa2) - ('0' & Mantisa1); -- -A+B= B-A
    elsif sign1 = '0' and sign2 = '1' then
            TempMantisa <= ('0' & Mantisa2) - ('0' & Mantisa1); -- A+-B= -(B-A)
    elsif sign1 = '1' and sign2 = '1' then
            TempMantisa <=  ('0' & Mantisa2) + ('0' & Mantisa1); --  -A+-B = -(B+A)
    else
            TempMantisa <=  ('0' & Mantisa1) + ('0' & Mantisa2);    -- -A-B= -(A+B)
    end if;
else
    if sign1 = '1' and sign2 = '0' then
            TempMantisa <= ('0' & Mantisa2) + ('0' & Mantisa1);  -- -A-+B= -(B+A)
    elsif sign1 = '0' and sign2 = '1' then
            TempMantisa <= ('0' & Mantisa2) + ('0' & Mantisa1);  -- A--B= B+A
    elsif sign1 = '1' and sign2 = '1' then
            TempMantisa <=  ('0' & Mantisa2) - ('0' & Mantisa1);  -- -A--B= B-A
    else
            TempMantisa <=  ('0' & Mantisa2) - ('0' & Mantisa1);  -- B-A
    end if;
end if;
end process;

MantisaFinala <= TempMantisa(n-1 downto 0); --mantisa fara bitul de carry
DepasireMantisa <= TempMantisa(n); --bitul de carry

RezultatZero <= AluOp when (Mantisa1 = Mantisa2) else '0';

end OperatiiMantise;
