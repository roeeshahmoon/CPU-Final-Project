LIBRARY ieee;
USE ieee.std_logic_1164.all;

package MCU_aux_package is
-----------------------------------------------------------------




component MCU IS
	PORT( reset, clock,ena				: IN 	STD_LOGIC; 
	SW0_7				: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	KEY1				: IN	STD_LOGIC;
	KEY2				: IN	STD_LOGIC;
	KEY3				: IN	STD_LOGIC;
	LEDR				: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 ):="00000000";
	HEX0				: OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 ):="0000000";
	HEX1				: OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 ):="0000000";
	HEX2				: OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 ):="0000000";
	HEX3				: OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 ):="0000000";
	HEX4				: OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 ):="0000000";
	HEX5				: OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 ):="0000000";		
	PWM	     			: OUT	STD_LOGIC);	
END component;







component MIPS is
	PORT( reset, clock,flag,ena,INTR					: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
		PC								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		BUS_DATA						:IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		GIE_OUT							: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Branch_out, Zero_out, Memwrite_out, Memread_out,
		Regwrite_out, INTA					: OUT 	STD_LOGIC );
	
end component;
-----------------------------------------------------------------



COMPONENT  GPIO  IS
	PORT(	reset, clock,ena    : IN STD_LOGIC;
			Data_IN				: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Data_OUT			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			PORT_SW0_7			: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_LEDR_Data		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PORT_HEX0_Data		: OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
			PORT_HEX1_Data		: OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
			PORT_HEX2_Data		: OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
			PORT_HEX3_Data		: OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
			PORT_HEX4_Data		: OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
			PORT_HEX5_Data		: OUT	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
			PORT1_tristate		: OUT	STD_LOGIC;
			PORT2_tristate		: OUT	STD_LOGIC;
			PORT3_tristate		: OUT	STD_LOGIC;
			PORT4_tristate		: OUT	STD_LOGIC;
			PORT5_tristate		: OUT	STD_LOGIC;
			PORT6_tristate		: OUT	STD_LOGIC;
			CS_LEDR				: IN	STD_LOGIC;
			CS_HEX_0_1			: IN	STD_LOGIC;
			CS_HEX_2_3			: IN	STD_LOGIC;
			CS_HEX_4_5			: IN	STD_LOGIC;
			CS_SW				: IN	STD_LOGIC;
			A0					: IN	STD_LOGIC;
			MemRead				: IN	STD_LOGIC;
			MemWrite			: IN	STD_LOGIC;
			GPIO_Read   		: OUT  STD_LOGIC; 
			GPIO_Write  		: OUT  STD_LOGIC; 
			PORT7_tristate		: OUT	STD_LOGIC);		
END COMPONENT;	



COMPONENT CommonDataBus is
    Port (clock 	: in STD_LOGIC;
        CPU_Data    : in STD_LOGIC_VECTOR(31 downto 0);
        CPU_Write   : in STD_LOGIC:='1';
        GPIO_Data   : in STD_LOGIC_VECTOR(31 downto 0);
        GPIO_Write  : in STD_LOGIC;
		Interrupt_Controller_DATA_OUT		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Interrupt_Controller_WRITE				: IN	STD_LOGIC;
        IOPIN     	: inout STD_LOGIC_VECTOR(31 downto 0);
		busData  	: out STD_LOGIC_VECTOR(31 downto 0);
        busDir      : out STD_LOGIC;
        busRW       : in STD_LOGIC);
end COMPONENT;

COMPONENT ADRESS_BUS is
	generic( width: integer:=32 );
	port(   clock 	: in STD_LOGIC;
			Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 	std_logic_vector(width-1 downto 0)
	);
end COMPONENT;

COMPONENT CTL_BUS is
	generic( width: integer:=2 );
	port(   clock 	: in STD_LOGIC;
			Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 	std_logic_vector(width-1 downto 0));
end COMPONENT;


COMPONENT  Address_Decoder  IS
	PORT(	clock 			: in STD_LOGIC;
			A0					: IN 	STD_LOGIC;
	        A1	                : IN 	STD_LOGIC;
	        A2	                : IN 	STD_LOGIC;
	        A3	                : IN 	STD_LOGIC;
	        A4	                : IN 	STD_LOGIC;
	        A5	                : IN 	STD_LOGIC;
	        A11                 : IN 	STD_LOGIC;
			CS_LEDR				: OUT	STD_LOGIC;
			CS_HEX_0_1			: OUT   STD_LOGIC;
			CS_HEX_2_3	        : OUT   STD_LOGIC;
			CS_HEX_4_5	        : OUT   STD_LOGIC;
			CS_SW		        : OUT   STD_LOGIC;
			CS_KEY		        : OUT   STD_LOGIC;
			CS_BTCTL	        : OUT   STD_LOGIC;
			CS_BTCNT	        : OUT   STD_LOGIC;
			CS_BTCCR0	        : OUT   STD_LOGIC;
			CS_BTCCR1	        : OUT   STD_LOGIC;
			CS_IE		        : OUT   STD_LOGIC;
            CS_IFG		        : OUT   STD_LOGIC;
            CS_TYPE		        : OUT   STD_LOGIC);
			

END COMPONENT;






COMPONENT  Interrupt_Controller  IS
	PORT(	clock			: IN 	STD_LOGIC;	
			reset			: IN 	STD_LOGIC;	
			data_bus		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Interrupt_Controller_DATA_OUT		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Interrupt_Controller_WRITE				: OUT 	STD_LOGIC;
			is_BTIFG		: IN 	STD_LOGIC;		
			is_KEYIFG_1		: IN 	STD_LOGIC;		
			is_KEYIFG_2		: IN 	STD_LOGIC;		
			is_KEYIFG_3		: IN 	STD_LOGIC;
			GIE				: IN 	STD_LOGIC;
			CS_IE		    : IN   STD_LOGIC;
			CS_IFG		    : IN   STD_LOGIC;
			MemWrite		: IN   STD_LOGIC;
			MemRead			: IN   STD_LOGIC;
			INTA			: IN 	STD_LOGIC;
			INTR			: OUT	STD_LOGIC);			
				
			
END COMPONENT ;



COMPONENT BasicTimer is
    Port (  reset 		: in STD_LOGIC ; 
			clock 		: in STD_LOGIC; 
			data_bus	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			CS_BTCCR1	: IN 	STD_LOGIC;
			CS_BTCCR0	: IN 	STD_LOGIC;
			CS_BTCTL	: IN 	STD_LOGIC;
			MemWrite	: IN 	STD_LOGIC;
			Out_Signal	 : out STD_LOGIC;
			Set_BTIFG 	: out STD_LOGIC);           
end COMPONENT;









--------------------------------------------------------------  
end MCU_aux_package;