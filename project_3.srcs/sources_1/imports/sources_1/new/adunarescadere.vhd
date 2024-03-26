library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity adunarescadere is
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
end adunarescadere;

architecture adunarescadere of adunarescadere is

signal Xreg : std_logic_vector(31 downto 0) := (others => '0'); --incarcare op1
signal Yreg : std_logic_vector(31 downto 0)	:= (others => '0'); --incarcare op2

--control unit iesiri
signal DifExp : std_logic_vector(7 downto 0);
signal FinalExp : std_logic := '0';
signal MantisaAliniata : std_logic_vector(25 downto 0) := (others => '0');
signal DepasireMantisa : std_logic := '0';
signal LoadOperanzi : std_logic := '0';
signal MuxExtendMantisa1 : std_logic := '0';
signal MuxExtendMantisa2 : std_logic := '0';
signal CEMantisaAliniata : std_logic := '0';
signal LoadMantisaAliniata : std_logic := '0';
signal CEMantisa2 : std_logic := '0';
signal signFinal: std_logic := '0';

--mantise extinse pt garda si rotunjire
signal Mantisa1Ext : std_logic_vector(25 downto 0) := (others => '0'); 
signal Mantisa2Ext : std_logic_vector(25 downto 0)	:= (others => '0');	
signal Mantisa2ExtReg : std_logic_vector(25 downto 0)	:= (others => '0');

signal ExponentFinal : std_logic_vector(7 downto 0) := (others => '0');
signal MantisaFinala : std_logic_vector(25 downto 0) := (others => '0');
signal RezultatZero : std_logic;

signal CERealiniere : std_logic := '0';
signal MantisaRealiniata : std_logic_vector(25 downto 0) := (others => '0'); 
signal ExponentRealiniat : std_logic_vector(7 downto 0) := (others => '0');
signal DepasireSuperioara: std_logic;-- :='0';

signal CENormalizare : std_logic := '0';
signal LoadNormalizare : std_logic := '0';
signal NormalBit : std_logic := '0';
signal DepasireInferioara : std_logic := '0';
signal MantisaNormalizata: std_logic_vector(25 downto 0) := (others => '0');
signal ExponentNormalizat: std_logic_vector(7 downto 0) := (others => '0');

signal CERotunjire: std_logic := '0';
signal MantisaRotunjita : std_logic_vector(22 downto 0) := (others => '0');

signal AluResult : std_logic_vector(31 downto 0);
signal SelectieRezultat : std_logic_vector(2 downto 0);
signal Sign : std_logic := '0';

signal ResultReg : std_logic_vector(31 downto 0) := (others => '0');
signal CERezultat: std_logic := '0';

signal NaNx : std_logic := '0';
signal NaNy : std_logic := '0';
signal NaN  : std_logic := '0';
signal resultTemp: std_logic_vector(31 downto 0) := (others => '0');
begin
	x_reg:entity WORK.registru
	generic map(
		n => 32
	)
	port map(
		D => X,
		Clk => Clk,
		Rst => Rst,
		CE => LoadOperanzi,
		Q => Xreg
	);
	y_reg:entity WORK.registru 
	generic map(
		n => 32
	)
	port map(
		D => Y,
		Clk => Clk,
		Rst => Rst,
		CE => LoadOperanzi,
		Q => Yreg
	); 
	
	nanxy:process(Xreg,Yreg) 
	variable x : std_logic := '0';
	variable y : std_logic := '0';
	begin  
		x := '0';
		y := '0';
		for i in 0 to 22 loop
			x := x or Xreg(i); --compara x cu fiecare bit din mantisa lui x 
			y := y or Yreg(i);   --daca cel putin un bit e 1 variabila x ramane 1 si mantisa indeplineste conditia pentru ca numarul sa fie NaN
		end loop;
		NaNx <= x;
		NaNy <= y;
	end process;  --daca exponentul unui numar e FF si mantisa are cel putin un bit de 1 atunci numarul e NaN
	nanf:process(NaNx,NaNy,Xreg(30 downto 23),Yreg(30 downto 23))
	begin		
		if Xreg(30 downto 23) = x"FF" and NaNx = '1' then --daca exponentul e FF si mantisa a indeplinit deja conditia (de a avea cel putin un bit de 1)
			NaN <= '1'; -- => numarul x e NaN
		elsif Yreg(30 downto 23) = x"FF" and NaNy = '1' then
			NaN <= '1';
		else NaN <= '0';
		end if;
	end process;
	
	comparatorexp : entity WORK.compareexp
	port map(
		Exp1 => Xreg(30 downto 23),
		Exp2 => Yreg(30 downto 23),
		FinalExp => FinalExp
	);
	
	scadereexp : entity WORK.scadereexp
	port map(
		Exp1 => Xreg(30 downto 23),
		Exp2 => Yreg(30 downto 23),
		AluOp => FinalExp, --se trimite flagul FinalExp la AluOp ca sa se stabileasca vum se face scaderea exponentilor
		DifExp => DifExp
	);
	
	selectmantisaalign : entity WORK.mux21extend
	generic map(
		n => 23
	)
	port map(
		I1 => Xreg(22 downto 0),
		I2 => Yreg(22 downto 0),
		Sel => MuxExtendMantisa1,
		O => Mantisa1Ext --selecteaza mantisa numarului cu exponentul mai mic
	);
	selectmantisa2 : entity WORK.mux21extend
	generic map(
		n => 23
	)
	port map(
		I1 => Xreg(22 downto 0),
		I2 => Yreg(22 downto 0),
		Sel => MuxExtendMantisa2,
		O => Mantisa2Ext  --selecteaza a 2 a mantisa
	);
	mantisa2ext_reg:entity WORK.registru 
	generic map(
		n => 26
	)
	port map(
		D => Mantisa2Ext,
		Clk => Clk,
		Rst => Rst,
		CE => CEMantisa2,
		Q => Mantisa2ExtReg  --retine mantisa numarului cu  exponentul mai mare
	); 
	
	alignmantise_reg : entity WORK.aliniereaantise
	generic map(
		n => 26
	)
	port map(
		Clk => Clk,
		Rst => Rst,
		CE => CEMantisaAliniata,
		Load => LoadMantisaAliniata,
		SRI => '0',
		D => Mantisa1Ext,
		Q => MantisaAliniata   --aliniaza mantisa selectata(shifteaza )
	);
	
	alumantise_alu : entity WORK.operatiimantise
	generic map(
		n => 26
	)
	port map(
	   sign1 => X(31),
	   sign2 =>Y(31),
		Mantisa1 => MantisaAliniata,
		Mantisa2 => Mantisa2ExtReg,
		AluOp => Operation,
		MantisaFinala => MantisaFinala,
		DepasireMantisa => DepasireMantisa, --bit carry
		RezultatZero => RezultatZero
	); 
	Sign <= '1' when Xreg(30 downto 23) < Yreg(30 downto 23) else '0'; --comparare exponenti
	
	realign : entity WORK.realinieremantise
	port map(
		Clk => Clk,
		CE => CERealiniere,
		Realiniere => DepasireMantisa,  --daca se depaseste mantisa se va face realiniere
		Rst => Rst,
		Exponent => ExponentFinal,
		Mantisa => MantisaFinala,
		ExponentRealiniat => ExponentRealiniat,  --exponentul este incrementat
		MantisaRealiniata => MantisaRealiniata, 
		DepasireSuperioara => DepasireSuperioara
	);
	
	
	expfinal : entity WORK.mux21
	generic map(
		n => 8
	)
	port map(
		I1 => Xreg(30 downto 23),
		I2 => Yreg(30 downto 23),
		Sel => FinalExp,
		O => ExponentFinal
	);	
	
	
	normalize : entity WORK.normalizare
	port map(
		Clk => Clk,
		Rst => Rst,
		Load => LoadNormalizare,
		CE => CENormalizare,
		Mantisa => MantisaRealiniata,
		Exponent => ExponentRealiniat,
		MantisaNormalizata => MantisaNormalizata,
		ExponentNormalizat => ExponentNormalizat,
		NormalBit => NormalBit,
		DepasireInferioara => DepasireInferioara
	);	
	
	round : entity WORK.rotunjire
	port map(
		Clk => Clk,
		Rst => Rst,
		CE => CERotunjire,
		MantisaNormalizata => MantisaNormalizata,
		MantisaRotunjita => MantisaRotunjita
	);
	
 process(X, Y, Operation)
    begin
        if Operation = '0' then --adunare
            if X(31) = '0' and Y(31) = '0' then 
                signFinal <= '0';
            elsif X(31) = '1' and Y(31) = '0' then  -- -a+b
                if X(30 downto 0) >= Y(30 downto 0) then
                    signFinal <= '1';
                else
                    signFinal <= '0';
                end if;
            elsif X(31) = '0' and Y(31) = '1' then
                if X(30 downto 0) >= Y(30 downto 0) then
                    signFinal <= '0';
                else
                    signFinal <= '1';
                end if;
            elsif X(31) = '1' and Y(31) = '1' then
                signFinal <= '1';
            end if;
        elsif Operation = '1' then
            if X(31) = '0' and Y(31) = '0' then
                if X(30 downto 0) >= Y(30 downto 0) then
                    signFinal <= '0';
                else
                    signFinal <= '1';
                end if;
            elsif X(31) = '1' and Y(31) = '0' then  -- -a - b
                            signFinal <= '1';
            elsif X(31) = '0' and Y(31) = '1' then 
                signFinal <= '0';
            elsif X(31) = '1' and Y(31) = '1' then --   -a - - b= -a+b
                if X(30 downto 0) >= Y(30 downto 0) then 
                    signFinal <= '1';
                else
                    signFinal <= '0';
                end if;
            end if;
        end if;
    end process;
	
	AluResult <= signFinal & ExponentNormalizat & MantisaRotunjita;
	
	with SelectieRezultat select ResultReg <= x"00000000" when "000",
	x"FF800000" when "001", --dep inf
	x"7F800000" when "010", --depasire sup
	x"7F810000" when "011",		
	AluResult when others;
	
	finalresult : entity WORK.registru
	generic map(
		n => 32
	)
	port map(
		D => ResultReg,
		Clk => Clk,
		Rst => Rst,
		CE => CERezultat,
		Q => Result
	);
	
	DepasireSup <= DepasireSuperioara;
	DepasireInf <= DepasireInferioara;
	
	control : entity WORK.controlunit
	port map(
		Start => Start,
		Clk => Clk,
		Rst => Rst,
		Operation => Operation,
		DifExp => DifExp,
		FinalExp => FinalExp,
		MantisaAliniata => MantisaAliniata,
		DepasireMantisa => DepasireMantisa,
		NormalBit => NormalBit,
		RezultatZero => RezultatZero,
		DepasireInferioara => DepasireInferioara,
		DepasireSuperioara => DepasireSuperioara,
		NaN => NaN,
		LoadOperanzi => LoadOperanzi,
		MuxExtendMantisa1 => MuxExtendMantisa1,
		MuxExtendMantisa2 => MuxExtendMantisa2,
		CEMantisaAliniata => CEMantisaAliniata,
		LoadMantisaAliniata => LoadMantisaAliniata, 
		CEMantisa2 => CEMantisa2,
		CERealiniere => CERealiniere,
		CENormalizare => CENormalizare,
		LoadNormalizare => LoadNormalizare,	
		CERotunjire => CERotunjire,	
		SelectieRezultat => SelectieRezultat,
		CERezultat => CERezultat,
		Ready => Ready
	);
	
	DepasireSup <= '0' when (conv_integer(X(30 downto 23)) + conv_integer(Y(30 downto 23)) > 127 and signFinal = '0') else '0';
    DepasireInf <= '1' when (conv_integer(X(30 downto 23)) + conv_integer(Y(30 downto 23)) < 0 and signFinal = '1') else '0';
		
end adunarescadere;