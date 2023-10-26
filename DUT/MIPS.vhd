				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE	work.MCU_aux_package.all;
ENTITY MIPS IS

	PORT( reset, clock,flag,ena,INTR					: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
		PC								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		BUS_DATA						:IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		GIE_OUT							: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Branch_out, Zero_out, Memwrite_out, Memread_out,
		Regwrite_out,INTA					: OUT 	STD_LOGIC );
END 	MIPS;

ARCHITECTURE structure OF MIPS IS

	COMPONENT Ifetch
   	     PORT(	Instruction			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        		PC_plus_4_out 		: OUT  	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        		Add_result 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        		BEQ 				: IN 	STD_LOGIC;
				BNEQ 				: IN 	STD_LOGIC;
				Jump				: IN 	STD_LOGIC;
        		Zero 				: IN 	STD_LOGIC;
				NEXT_PC_INT 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        		PC_out 				: OUT 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
				INTA_IN	 			: IN 	STD_LOGIC;
        		clock,reset 		: IN 	STD_LOGIC;
				flag 				: IN 	STD_LOGIC				);
	END COMPONENT; 

	COMPONENT Idecode
	  PORT(	read_data_1	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_result	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			RegWrite 	: IN 	STD_LOGIC;
			MemtoReg 	: IN 	STD_LOGIC;
			RegDst 		: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			PC_plus_4	: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			PC_out 	: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			INTR	 	: IN 	STD_LOGIC;
			INTA_IN	 	: IN 	STD_LOGIC;
			Sign_extend : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			GIE			 : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			clock,reset	: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT control
   PORT( 	
	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	JR_bits		: IN 	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	INTR	 	: IN 	STD_LOGIC;
	INTA_IN	 	: OUT 	STD_LOGIC;
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
	END COMPONENT;

	COMPONENT  Execute
   	     PORT(	Read_data_1 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
                Read_data_2 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Sign_Extend 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Function_opcode		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
				OPCODE				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
               	ALUOp 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
               	ALUSrc 				: IN 	STD_LOGIC;
               	Zero 				: OUT	STD_LOGIC;
               	ALU_Result 			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
               	Add_Result 			: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
               	PC_plus_4 			: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
               	clock, reset,flag		: IN 	STD_LOGIC );
	END COMPONENT;


	COMPONENT dmemory
	PORT(	read_data_OUT 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			NEXT_PC_INT 		: OUT 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( 11 DOWNTO 0 );
			DATA_BUS 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			INTA_IN			 	: IN 	STD_LOGIC;
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
	END COMPONENT;

					-- declare signals used to connect VHDL components
	SIGNAL PC_plus_4 		: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Add_result 		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL ALU_result 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL GIE		 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL ALUSrc 			: STD_LOGIC;
	SIGNAL BEQ 				: STD_LOGIC;
	SIGNAL BNEQ 			: STD_LOGIC;
	SIGNAL Jump 			: STD_LOGIC;
	SIGNAL RegDst 			: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Regwrite 		: STD_LOGIC;
	SIGNAL Zero 			: STD_LOGIC;
	SIGNAL MemWrite 		: STD_LOGIC;
	SIGNAL DATA_BUS_IN 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL MemtoReg 		: STD_LOGIC;
	SIGNAL MemRead 			: STD_LOGIC;
	SIGNAL ALUop 			: STD_LOGIC_VECTOR(  1 DOWNTO 0 );
	SIGNAL Instruction		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL INTA_IN 			: STD_LOGIC;
	SIGNAL	NEXT_PC_INT,PC_out		: STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN
					-- copy important signals to output pins for easy 
					-- display in Simulator
   Instruction_out 	<= Instruction;
   ALU_result_out 	<= ALU_result;
   read_data_1_out 	<= read_data_1;
   read_data_2_out 	<= read_data_2;
   write_data_out  	<= read_data WHEN Memread = '1' and ALU_Result(11) = '0' else read_data_2 when  MemWrite = '1' ELSE ALU_result;
   Branch_out 		<= BEQ OR BNEQ;
   Zero_out 		<= Zero;
   RegWrite_out 	<= RegWrite;
   MemWrite_out 	<= MemWrite;	
   Memread_out		<=	Memread;
  DATA_BUS_IN			<=	BUS_DATA;
  GIE_OUT		<=	GIE;
  INTA		<=	INTA_IN;
  PC 		<=	PC_out;
					-- connect the 5 MIPS components   
  IFE : Ifetch
	PORT MAP (	Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				Add_result 		=> Add_result,
				BEQ 			=> BEQ,
				BNEQ 			=> BNEQ,
				Jump 			=> Jump,
				Zero 			=> Zero,
				INTA_IN			=>	INTA_IN,
				PC_out 			=> PC_out,   
				NEXT_PC_INT		=>	NEXT_PC_INT,		
				clock 			=> clock,  
				reset 			=> reset, 
				flag 			=> flag);

   ID : Idecode
   	PORT MAP (	read_data_1 	=> read_data_1,
        		read_data_2 	=> read_data_2,
        		Instruction 	=> Instruction,
        		read_data 		=> read_data,
				ALU_result 		=> ALU_result,
				RegWrite 		=> RegWrite,
				MemtoReg 		=> MemtoReg,
				INTR			=>	INTR,
				PC_plus_4		=>	PC_plus_4,
				GIE				=>	GIE,
				RegDst 			=> RegDst,
				INTA_IN			=>	INTA_IN,
				PC_out 			=> PC_out,
				Sign_extend 	=> Sign_extend,
        		clock 			=> clock,  
				reset 			=> reset );


   CTL:   control
	PORT MAP ( 	Opcode 			=> Instruction( 31 DOWNTO 26 ),
				JR_bits			=> Instruction( 5 DOWNTO 3 ),
				RegDst 			=> RegDst,
				ALUSrc 			=> ALUSrc,
				MemtoReg 		=> MemtoReg,
				RegWrite 		=> RegWrite,
				MemRead 		=> MemRead,
				MemWrite 		=> MemWrite,
				INTR			=>	INTR,
				BEQ 			=> BEQ,
				BNEQ 			=> BNEQ,
				INTA_IN			=>	INTA_IN,
				Jump 			=> Jump,
				ALUop 			=> ALUop,
                clock 			=> clock,
				reset 			=> reset );

   EXE:  Execute
   	PORT MAP (	Read_data_1 	=> read_data_1,
             	Read_data_2 	=> read_data_2,
				Sign_extend 	=> Sign_extend,
                Function_opcode	=> Instruction( 5 DOWNTO 0 ),
				OPCODE			=> Instruction( 31 DOWNTO 26 ),
				ALUOp 			=> ALUop,
				ALUSrc 			=> ALUSrc,
				Zero 			=> Zero,
                ALU_Result		=> ALU_Result,
				Add_Result 		=> Add_Result,
				PC_plus_4		=> PC_plus_4,
                Clock			=> clock,
				Reset			=> reset,
				flag 			=> flag		);

   MEM:  dmemory
	PORT MAP (	read_data_OUT 		=> read_data,
				address 		=> ALU_Result (11 DOWNTO 0),--jump memory address by 4
				write_data 		=> read_data_2,
				MemRead 		=> MemRead, 
				Memwrite 		=> MemWrite,
				INTA_IN			=>	INTA_IN,
				DATA_BUS		=>	DATA_BUS_IN,
				NEXT_PC_INT		=>	NEXT_PC_INT,
                clock 			=> clock,  
				reset 			=> reset );
END structure;

