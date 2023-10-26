				-- Top Level Structural Model for MCU 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.MCU_aux_package.all;
--use work.data_bus_pkg.all;
ENTITY MCU IS
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
END 	MCU;

ARCHITECTURE structure OF MCU IS


	
-----------------------------------------------------------------GLOBAL SIGNAL -----------------------------------------------------------------	



	
-----------------------------------------------------------------MIPS SIGNAL -----------------------------------------------------------------	
SIGNAL			ALU_result_out					: 	 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL			read_data_1_out					: 	 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL			read_data_2_out		: 	 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL			write_data_out	      			: 	 	 STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL 			Instruction_out					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );			
SIGNAL 			GIE_OUT					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
SIGNAL			Branch_out							: 		STD_LOGIC; 
SIGNAL			Zero_out,flag						: 	 	STD_LOGIC;	
SIGNAL			Memwrite_out,Memread_out	                 : 	 	STD_LOGIC;
SIGNAL			Regwrite_out	            : 	 	STD_LOGIC;

-----------------------------------------------------------------GPIO SIGNAL -----------------------------------------------------------------	
SIGNAL			PORT_LEDR_Data							: 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL			PORT_HEX0_Data							: 	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
SIGNAL			PORT_HEX1_Data							: 	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
SIGNAL			PORT_HEX2_Data							: 	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
SIGNAL			PORT_HEX3_Data							: 	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
SIGNAL			PORT_HEX4_Data							: 	STD_LOGIC_VECTOR( 6 DOWNTO 0 );
SIGNAL			PORT_HEX5_Data							: 	STD_LOGIC_VECTOR( 6 DOWNTO 0 );		
SIGNAL			PORT_SW_Data							:	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL			PORT1_tristate,GPIO_RW                  : 	 	STD_LOGIC;
SIGNAL			PORT2_tristate	                        : 	 	STD_LOGIC;
SIGNAL			PORT3_tristate	                        : 	 	STD_LOGIC;
SIGNAL			PORT4_tristate	                        : 	 	STD_LOGIC;
SIGNAL			PORT5_tristate	                        : 	 	STD_LOGIC;
SIGNAL			PORT6_tristate	                        : 	 	STD_LOGIC;
SIGNAL			PORT7_tristate,MIPStristate             : 	 	STD_LOGIC;							
SIGNAL			GPIO_Read,GPIO_Write					: 	 	STD_LOGIC;
SIGNAL			Data_OUT								: 	 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL			Data_IN_S								: 	 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL			MemRead	                        : 	 	STD_LOGIC;
SIGNAL			MemWrite                        : 	 	STD_LOGIC;
-----------------------------------------------------------------DATA_BUS SIGNAL -----------------------------------------------------------------	
SIGNAL			IOpin_DATABUS							: 		std_logic_vector(31 downto 0);
SIGNAL			Dout_DATABUS							: 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL			en_DATABUS								: 	STD_LOGIC;
SIGNAL			data_bus								: 	 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL			busRW,busDir_top		                            : 	 	STD_LOGIC;


-----------------------------------------------------------------ADDRESS_BUS SIGNAL -----------------------------------------------------------------	
SIGNAL			IOpin_ADRRESSBUS						: 		std_logic_vector(31 downto 0);
SIGNAL			Dout_ADRRESSBUS							: 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );		
SIGNAL			en_ADRRESSBUS							: 	STD_LOGIC;		
SIGNAL			Din_ADRRESSBUS_S						: 	 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );

-----------------------------------------------------------------CTL_BUS SIGNAL -----------------------------------------------------------------	
SIGNAL			IOpin_CTLBUS							: 		std_logic_vector(1 downto 0);			
SIGNAL			en_CTLBUS								: 	STD_LOGIC;
SIGNAL			Dout_CTLBUS							: 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );				
SIGNAL			AD_IN_BUS							: 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL			CTL_IN_BUS							: 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
SIGNAL			GPIO_memread_S				 		: 	 	STD_LOGIC;
SIGNAL			GPIO_memwrite_S				 		: 	 	STD_LOGIC;
SIGNAL			Din_CTLBUS_S							: 		STD_LOGIC_VECTOR( 1 DOWNTO 0 ); 	


-----------------------------------------------------------------INTERRUPT_CONTROLLER SIGNAL -----------------------------------------------------------------	
	
SIGNAL 	is_KEYIFG_1				:		STD_LOGIC;
SIGNAL 	is_KEYIFG_2				:		STD_LOGIC;
SIGNAL 	is_KEYIFG_3				:		STD_LOGIC;
SIGNAL 	INTR,INTA,Interrupt_Controller_WRITE					:		STD_LOGIC;
SIGNAL 	GIE						:		STD_LOGIC;
SIGNAL	Interrupt_Controller_DATA_OUT				:		STD_LOGIC_VECTOR( 31 DOWNTO 0 );


-----------------------------------------------------------------ADDRESS_DECODER SIGNAL -----------------------------------------------------------------	
SIGNAL	CS_LEDR					: STD_LOGIC;
SIGNAL	CS_HEX_0_1				: STD_LOGIC;
SIGNAL	CS_HEX_2_3				: STD_LOGIC;
SIGNAL	CS_HEX_4_5				: STD_LOGIC;
SIGNAL	CS_SW					: STD_LOGIC;
SIGNAL	CS_KEY					: STD_LOGIC;
SIGNAL	CS_BTCTL				: STD_LOGIC;
SIGNAL	CS_BTCNT				: STD_LOGIC;
SIGNAL	CS_BTCCR0				: STD_LOGIC;
SIGNAL	CS_BTCCR1				: STD_LOGIC;
SIGNAL	CS_IE					: STD_LOGIC;
SIGNAL	CS_IFG					: STD_LOGIC;
SIGNAL	CS_TYPE					: STD_LOGIC;
SIGNAL A0,A1,A2,A3,A4,A5,A6,A11			: STD_LOGIC ;

-----------------------------------------------------------------BASIC_TIMER SIGNAL -----------------------------------------------------------------


SIGNAL Out_Signal,Set_BTIFG			: STD_LOGIC ;












		
			
BEGIN	


PWM		<=		Out_Signal;







			
			
			


	


					-- copy important signals to output pins for easy 
					-- display in Simulator


   en_ADRRESSBUS <= '1' when reset = '0' else '0';
   en_CTLBUS	<= '1' when reset = '0' else '0';
   Dout_CTLBUS(0)	<= Memread_out when reset = '0' else '0';
   Dout_CTLBUS(1)	<= Memwrite_out when reset = '0' else '0';

LEDR		<=	PORT_LEDR_Data	   ;
HEX0        <=	PORT_HEX0_Data     ;
HEX1        <=	PORT_HEX1_Data     ;
HEX2        <=	PORT_HEX2_Data     ;
HEX3        <=	PORT_HEX3_Data     ;
HEX4        <=	PORT_HEX4_Data     ;
HEX5        <=	PORT_HEX5_Data     ;
PORT_SW_Data	<=	SW0_7	;

A0	<=	ALU_result_out(0);
A1	<=	ALU_result_out(1);
A2	<=	ALU_result_out(2);
A3	<=	ALU_result_out(3);
A4	<=	ALU_result_out(4);
A5	<=	ALU_result_out(5);
A11	<=	ALU_result_out(11);




is_KEYIFG_1		<=		KEY1;
is_KEYIFG_2		<=		KEY2;
is_KEYIFG_3		<=		KEY3;






busRW <= '1' ;
--PORT_SW_Data_OUT <= zero(31 downto 8)&X"01";									
					-- connect the 3 MCU components   
data_bus_inst :CommonDataBus  	port map(Interrupt_Controller_DATA_OUT=>Interrupt_Controller_DATA_OUT,Interrupt_Controller_WRITE=>Interrupt_Controller_WRITE,CPU_Data => write_data_out,CPU_Write=>MemWrite_out,GPIO_Data=>Data_OUT,GPIO_Write=>GPIO_Write, busData=> data_bus,busRW=>busRW,busDir=>busDir_top,IOPIN=>open,clock => clock);

AD_BUS:	ADRESS_BUS generic map(width => 32) 	port map(Dout => ALU_result_out, en => en_ADRRESSBUS ,Din => Din_ADRRESSBUS_S, IOpin => open,clock => clock);

CONTROL_BUS: CTL_BUS generic map(width => 2) 	port map(Dout => Dout_CTLBUS, en => en_CTLBUS ,Din => CTL_IN_BUS, IOpin => open,clock => clock);
--ONTROL_BUS: CommonDataBus 	port map(CPU_Data => Dout_CTLBUS, CPU_RW => en_CTLBUS ,GPIO_Data => Din_CTLBUS_S, GPIO_RW => open);
  IO : GPIO
	PORT MAP (	Data_IN			=>	data_bus			,
				Data_OUT		=>	Data_OUT		 ,
				PORT_SW0_7			=>	PORT_SW_Data			 ,
    	    	PORT_LEDR_Data	=>	PORT_LEDR_Data	  ,
				PORT_HEX0_Data	=>	PORT_HEX0_Data	  ,
				PORT_HEX1_Data	=>	PORT_HEX1_Data	  ,
				PORT_HEX2_Data	=>	PORT_HEX2_Data	  ,
				PORT_HEX3_Data	=>	PORT_HEX3_Data	  ,
				PORT_HEX4_Data	=>	PORT_HEX4_Data	 ,
				PORT_HEX5_Data	=>	PORT_HEX5_Data	  ,
				GPIO_Write		=>	GPIO_Write,
				GPIO_Read		=>	GPIO_Read,
				CS_LEDR			=>	CS_LEDR,		
				CS_HEX_0_1	    =>	CS_HEX_0_1,	
				CS_HEX_2_3	    =>	CS_HEX_2_3,	
				CS_HEX_4_5	    =>	CS_HEX_4_5,	
				CS_SW		    =>	CS_SW,		
				MemRead	 		=>	Dout_CTLBUS(0),	 
				MemWrite        =>	Dout_CTLBUS(1) ,
				A0				=>	A0,
				clock 			=> clock,
				ena				=> ena,
				reset 			=> reset);
				
				
				
  CPU : MIPS
	PORT MAP (	ALU_result_out		=>	ALU_result_out		,
				BUS_DATA			=>	data_bus,
				INTA				=>	INTA,
				INTR		    =>    INTR,
    	    	read_data_1_out	    =>	read_data_1_out	    ,
				read_data_2_out		    =>	read_data_2_out		    ,
				write_data_out		    =>	write_data_out		    ,
				Instruction_out	    =>	Instruction_out	    ,
				Branch_out		    =>	Branch_out	    ,
				Zero_out		    =>	Zero_out		    ,
				flag				=>	flag,
				GIE_OUT				=>	GIE_OUT,
				Memread_out			=>	Memread_out,
				Memwrite_out			=>	Memwrite_out,
				Regwrite_out				=>	Regwrite_out,
				clock 				=> clock,
				ena					=> ena,
				reset 				=> reset);

 
			   
	To_Interrupt_Controller : Interrupt_Controller
		port map (clock				=>	clock		,
                  is_BTIFG			=>	Set_BTIFG	,		
                  is_KEYIFG_1		=>	KEY1,
				  is_KEYIFG_2	    =>  KEY2,
				  is_KEYIFG_3	 	=>	KEY3,
				  data_bus			=>	data_bus,
					CS_IE			=>	CS_IE		,
					CS_IFG			=>	CS_IFG,
					GIE					=>	GIE_OUT(0),
					reset			=>	reset,
					MemWrite		=>	Dout_CTLBUS(1),
					MemRead	 		=>	Dout_CTLBUS(0),	 
					Interrupt_Controller_DATA_OUT	    =>    Interrupt_Controller_DATA_OUT	,
					Interrupt_Controller_WRITE	    =>    Interrupt_Controller_WRITE	,
					INTA			=>	INTA,
					INTR		    =>    INTR		);


TO_Decoder : Address_Decoder
	PORT MAP (	clock => clock,
				A0		=>	A0,	
                A1	    =>	A1,	
                A2	    =>	A2,	
                A3	    =>	A3,	
                A4	    =>	A4,	
                A5	    =>	A5,	
                A11     =>	A11,
				CS_LEDR		=>	CS_LEDR,		
				CS_HEX_0_1	=>	CS_HEX_0_1,	
				CS_HEX_2_3	=>	CS_HEX_2_3,	  
				CS_HEX_4_5	=>	CS_HEX_4_5,	  
				CS_SW		=>	CS_SW,		  
				CS_KEY		=>	CS_KEY,		  
				CS_BTCTL	=>	CS_BTCTL,	  
				CS_BTCNT	=>	CS_BTCNT,	  
				CS_BTCCR0	=>	CS_BTCCR0,	  
				CS_BTCCR1	=>	CS_BTCCR1,	  
				CS_IE		=>	CS_IE,		  	
                CS_IFG		=>	CS_IFG,		  
                CS_TYPE		=>	CS_TYPE);		  




			  
TO_BasicTimer : BasicTimer
	PORT MAP (reset 	   =>	reset, 		
              clock 	   =>	clock, 			 				  
              data_bus	   =>	data_bus,	
              CS_BTCCR1    =>	CS_BTCCR1,
			  CS_BTCCR0    =>	CS_BTCCR0,
              CS_BTCTL	   =>	CS_BTCTL,			
              MemWrite	   =>	Dout_CTLBUS(1),		
              Out_Signal   =>  	Out_Signal,
		      Set_BTIFG    =>  	Set_BTIFG );
			   
			   
	











	
				
				
END structure;

	