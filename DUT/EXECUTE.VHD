--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;


ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			OPCODE			: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALUOp 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			ALUSrc 			: IN 	STD_LOGIC;
			Zero 			: OUT	STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			clock, reset,flag	: IN 	STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL Ainput, Binput 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Branch_Add,Jump_Add 	: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL ALU_ctl				: STD_LOGIC_VECTOR( 3 DOWNTO 0 );
BEGIN
	Ainput <= Read_data_1;
						-- ALU input mux
	Binput <= Read_data_2 
		WHEN (( ALUSrc = '0' ) AND (not(((ALUOp  = "10") AND ((Function_opcode = "000000") OR ((OPCODE = "000000") AND (Function_opcode = "000010"))))))) ELSE  Sign_extend( 31 DOWNTO 0 );
						-- Generate ALU control bits
	ALU_ctl( 0 ) <= (((((Function_opcode( 0 )) OR (Function_opcode( 4 )) OR ((Function_opcode( 2 ) AND Function_opcode( 1 ))) OR ((Function_opcode( 5 ) AND Function_opcode( 3 )))) OR (Function_opcode( 5 ) AND Function_opcode( 0 ) AND (NOT(Function_opcode( 2 ))))) AND ((not(OPCODE(4))) AND (ALUOp(1 )) AND (not(ALUOp(0))))) OR (((OPCODE(1) XOR OPCODE(0)) OR (OPCODE(0) AND OPCODE(1)))  AND ((ALUOp(1)) AND (ALUOp(0))))) OR ((OPCODE(4)) AND (ALUOp(1 )) AND (not(ALUOp(0)))) ;
	ALU_ctl( 1 ) <= ((((NOT(Function_opcode( 2 ))) AND Function_opcode( 5 )) OR ((Function_opcode( 2 )) AND (Function_opcode( 1 )))) AND ((ALUOp(1 )) AND (not(ALUOp(0))))) OR (NOT(ALUOp(1)))  OR ((((not((OPCODE(2) XOR OPCODE(1)))) OR OPCODE(1))) AND ((ALUOp(1)) AND (ALUOp(0)))) OR ((NOT(ALUOp(1))) AND (NOT(ALUOp(0))) AND (not((OPCODE(4))) AND (ALUOp(1 )) AND (not(ALUOp(0)))))  ;
	ALU_ctl( 2 ) <= ( (((Function_opcode( 5 ) XOR Function_opcode( 4 )) XOR (not(Function_opcode( 1 )))) AND not(Function_opcode(2)))  AND (ALUOp(1 ) AND not(ALUOp(0)))) OR (ALUOp( 0 ) AND (not(ALUOp( 1 )))) OR ((OPCODE(4)) AND (ALUOp(1 )) AND (not(ALUOp(0)))) OR ((OPCODE(3) AND OPCODE(2) AND OPCODE(1) AND OPCODE(0)) AND (ALUOp(1) AND ALUOp(0)));
	ALU_ctl( 3 ) <= ((((Function_opcode( 1 ) AND (NOT(Function_opcode( 5 ))) AND (not(OPCODE(4)))) OR ((Function_opcode( 5 ) AND Function_opcode( 0 ) AND (NOT(Function_opcode( 2 ))))))  AND (ALUOp(1 ) AND not(ALUOp(0)))) OR ((OPCODE(0) AND OPCODE(1)) AND (ALUOp(0) AND ALUOp(1))))  ;
						-- Generate Zero Flag
	Zero <= '1' 
		WHEN ALU_output_mux( 31 DOWNTO 0 ) = X"00000000" 
		ELSE '0';    
						-- Select ALU output        
	ALU_result <= X"0000000" & B"000"  & ALU_output_mux( 31 ) 
		WHEN  ALU_ctl = "0111" 
		ELSE  	ALU_output_mux( 31 DOWNTO 0 );
						-- Adder to compute Branch Address
	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend( 7 DOWNTO 0 )   ;
	-- Adder to compute Jump Address
	Jump_Add	<=  Ainput( 7 DOWNTO 0 ) when ALUOp( 1 ) = '1' else Sign_extend( 7 DOWNTO 0 )  ;
	Add_result 	<= Branch_Add when ALUOp( 0 ) = '1' else Jump_Add ;

PROCESS ( ALU_ctl, Ainput, Binput )
	variable shift_amount : integer ;
	variable zeros		:  STD_LOGIC_VECTOR(15 DOWNTO 0);
	variable MUL		:  STD_LOGIC_VECTOR(63 DOWNTO 0);
	BEGIN
	shift_amount := conv_integer(unsigned(Binput(10 DOWNTO 6)));
	zeros := (others => '0') ;
	MUL := (Ainput * Binput);

					-- Select ALU operation
 	CASE ALU_ctl IS
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "0000" 	=>	ALU_output_mux 	<= Ainput AND Binput; 
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "0001" 	=>	ALU_output_mux 	<= Ainput OR Binput;
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "0010" 	=>	ALU_output_mux 	<= Ainput + Binput;
						-- ALU performs ALUresult = A_input XOR B_input
 	 	WHEN "0011" 	=>	ALU_output_mux <= Ainput XOR Binput;
						-- ALU performs ALUresult = A_input SHL B_input
 	 	WHEN "0100" 	=>	ALU_output_mux <= TO_STDLOGICVECTOR(TO_BITVECTOR(Ainput) SLL shift_amount );
						-- ALU performs ALUresult = A_input * B_input
 	 	WHEN "0101" 	=>	ALU_output_mux 	<= MUL(31 DOWNTO 0);
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "0110" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs SLT OR SLTI
  	 	WHEN "0111" 	=>	ALU_output_mux 	<= Ainput - Binput ;
						-- ALU performs ALUresult = SHR
 	 	WHEN "1000" 	=>	ALU_output_mux 	<= TO_STDLOGICVECTOR(TO_BITVECTOR(Ainput) SRL shift_amount );
								-- ALU performs ALUresult = lui
 	 	WHEN "1111" 	=>	ALU_output_mux 	<= Binput(15 DOWNTO 0) & zeros;
								-- ALU performs ALUresult = ADDU
 	 	WHEN "1011" 	=>	ALU_output_mux 	<= unsigned(Ainput) + unsigned(Binput);

 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
END behavior;

