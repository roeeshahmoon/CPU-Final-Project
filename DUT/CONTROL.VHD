		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 	
	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	JR_bits		: IN 	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	INTR	 	: IN 	STD_LOGIC;
	INTA_IN	 	: buffer 	STD_LOGIC;
	RegDst 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	ALUSrc 		: OUT 	STD_LOGIC;
	MemtoReg 	: OUT 	STD_LOGIC;
	RegWrite 	: OUT 	STD_LOGIC;
	MemRead 	: OUT 	STD_LOGIC;
	MemWrite 	: OUT 	STD_LOGIC;
	BEQ 		: OUT 	STD_LOGIC;
	BNEQ 		: OUT 	STD_LOGIC;
	Jump		: OUT 	STD_LOGIC;
	ALUop 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, Lw, Sw, Beq_sig, I_format, J, Bneq_sig	: STD_LOGIC;

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  ((Opcode = "011100") OR (Opcode = "000000")) AND INTA_IN = '0' ELSE '0';
	Lw          <=  '1'  WHEN  Opcode = "100011" AND INTA_IN = '0'  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011" AND INTA_IN = '0' ELSE '0';
   	Beq_sig         <=  '1'  WHEN  Opcode = "000100" AND INTA_IN = '0' ELSE '0';
	Bneq_sig         <=  '1'  WHEN  Opcode = "000101" AND INTA_IN = '0'  ELSE '0';
	J  	        <=  '1'  WHEN  (Opcode = "000010" OR Opcode = "000011") AND INTA_IN = '0' ELSE '0';
	I_format	<=	'1'  WHEN ( Opcode = "001000" OR Opcode = "001100" OR Opcode = "001101" OR Opcode = "001110" OR Opcode = "001111" OR Opcode = "001010") AND INTA_IN = '0' else '0';
  	RegDst    	<= "00" when  R_format = '1' AND INTA_IN = '0' else "10" when J = '1' AND INTA_IN = '0' else "01";
 	ALUSrc  	<=  Lw OR Sw OR I_format ;
	MemtoReg 	<=  Lw;
  	RegWrite 	<=  ((((R_format OR Lw) OR I_format)) OR ((J ) AND (Opcode(0)))) AND (not(INTR)) ;
  	MemRead 	<=  Lw;
   	MemWrite 	<=  Sw; 
 	BEQ      <=  Beq_sig;
	BNEQ	<= Bneq_sig;
	Jump      	<=  J OR ((R_format) AND ((not(JR_bits(2))) AND (not(JR_bits(1)) AND JR_bits(0)))); --whwn JR_bits = "001" AND R_format we need jump register
	ALUOp( 1 ) 	<=  R_format OR I_format;
	ALUOp( 0 ) 	<=  Beq_sig OR I_format OR Bneq_sig; 
	process(clock,INTR)
	BEGIN
	if rising_edge(clock) then
		if INTR = '1' then 
			INTA_IN <= '1' ;
		ELSE
			INTA_IN <= '0' ;
		end if;
	end if;
	end process;

   END behavior;


