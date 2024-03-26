library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Decoder is
    Port (
		  Clk : in  STD_LOGIC;
          Row : in  STD_LOGIC_VECTOR (3 downto 0);
		  Col : out  STD_LOGIC_VECTOR (3 downto 0);
          DecodeOut : out  STD_LOGIC_VECTOR (3 downto 0); 
		  DigitRead : out std_logic	);
end Decoder;

architecture Behavioral of Decoder is

signal sclk :STD_LOGIC_VECTOR(19 downto 0);	
signal detectDigit : std_logic := '0';
begin
	process(Clk)
		begin 
		if rising_edge(Clk) then
			if detectDigit = '1' then 
				detectDigit <= '0';
			end if;
			-- 1ms
			if sclk = "00011000011010100000" then 
				--C1
				Col<= "0111";
				sclk <= sclk+1;
			-- check row pins
			elsif sclk = "00011000011010101000" then	
				--R1
				if Row = "0111" then
					DecodeOut <= "0001";	--1	 
					detectDigit <= '1';
				--R2
				elsif Row = "1011" then
					DecodeOut <= "0100"; --4 
					detectDigit <= '1';
				--R3
				elsif Row = "1101" then
					DecodeOut <= "0111"; --7
					detectDigit <= '1';
				--R4
				elsif Row = "1110" then
					DecodeOut <= "0000"; --0 
					detectDigit <= '1';
				end if;
				sclk <= sclk+1;
			-- 2ms
			elsif sclk = "00110000110101000000" then	
				--C2
				Col<= "1011";
				sclk <= sclk+1;
			-- check row pins
			elsif sclk = "00110000110101001000" then	
				--R1
				if Row = "0111" then		
					DecodeOut <= "0010"; --2
					detectDigit <= '1';
				--R2
				elsif Row = "1011" then
					DecodeOut <= "0101"; --5
					detectDigit <= '1';
				--R3
				elsif Row = "1101" then
					DecodeOut <= "1000"; --8
					detectDigit <= '1';
				--R4
				elsif Row = "1110" then
					DecodeOut <= "1111"; --F
					detectDigit <= '1';
				end if;
				sclk <= sclk+1;	
			--3ms
			elsif sclk = "01001001001111100000" then 
				--C3
				Col<= "1101";
				sclk <= sclk+1;
			-- check row pins
			elsif sclk = "01001001001111101000" then 
				--R1
				if Row = "0111" then
					DecodeOut <= "0011"; --3
					detectDigit <= '1';
				--R2
				elsif Row = "1011" then
					DecodeOut <= "0110"; --6
					detectDigit <= '1';
				--R3
				elsif Row = "1101" then
					DecodeOut <= "1001"; --9
					detectDigit <= '1';
				--R4
				elsif Row = "1110" then
					DecodeOut <= "1110"; --E
					detectDigit <= '1';
				end if;
				sclk <= sclk+1;
			--4ms
			elsif sclk = "01100001101010000000" then 			
				--C4
				Col<= "1110";
				sclk <= sclk+1;
			-- check row pins
			elsif sclk = "01100001101010001000" then 
				--R1
				if Row = "0111" then
					DecodeOut <= "1010"; --A
					detectDigit <= '1';
				--R2
				elsif Row = "1011" then
					DecodeOut <= "1011"; --B
					detectDigit <= '1';
				--R3
				elsif Row = "1101" then
					DecodeOut <= "1100"; --C
					detectDigit <= '1';
				--R4
				elsif Row = "1110" then
					DecodeOut <= "1101"; --D
					detectDigit <= '1';
				end if;
				sclk <= "00000000000000000000";	
			else
				sclk <= sclk+1;	
			end if;
		end if;
	end process;
		
	DigitRead <= detectDigit;	
						 
end Behavioral;

