--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE	work.MCU_aux_package.all;

ENTITY  GPIO  IS
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
			
END GPIO;

ARCHITECTURE behavior OF GPIO IS




-----------------------------------------------------------------PORT_LEDR SIGNAL -----------------------------------------------------------------	
SIGNAL EnLEDR						: STD_LOGIC :='0';
SIGNAL LEDRtristate					: STD_LOGIC ;

-----------------------------------------------------------------PORT_HEX_0_1 SIGNAL -----------------------------------------------------------------	
SIGNAL En_HEX_0,En_HEX_1						: STD_LOGIC :='0';
SIGNAL HEX0tristate,HEX1tristate			: STD_LOGIC ;


-----------------------------------------------------------------PORT_HEX_2_3 SIGNAL -----------------------------------------------------------------	
SIGNAL En_HEX_2,En_HEX_3						: STD_LOGIC :='0';
SIGNAL HEX2tristate,HEX3tristate			: STD_LOGIC ;

-----------------------------------------------------------------PORT_HEX_2_3 SIGNAL -----------------------------------------------------------------	
SIGNAL En_HEX_4,En_HEX_5						: STD_LOGIC :='0';
SIGNAL HEX4tristate,HEX5tristate			: STD_LOGIC ;


-----------------------------------------------------------------PORT_SW SIGNAL -----------------------------------------------------------------	
SIGNAL PORT_SW_Data			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL SWtristate 			: STD_LOGIC ;
-----------------------------------------------------------------DECODER SIGNAL -----------------------------------------------------------------	
SIGNAL Data_seven_segment			: STD_LOGIC_VECTOR( 6 DOWNTO 0 );

SIGNAL zero					: STD_LOGIC_VECTOR( 31 DOWNTO 0 ):=X"00000000";
SIGNAL Data					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );





BEGIN


Data	<= Data_IN;
Data_OUT <= zero(31 DOWNTO 8) & PORT_SW_Data when CS_SW = '1' AND MemRead = '1' else zero when reset = '1';



GPIO_Write	<= MemRead  and CS_SW ;
GPIO_Read	<=  MemWrite and (CS_HEX_4_5 or CS_HEX_2_3  or CS_HEX_0_1  or CS_LEDR);











-----------------------------------------------------------------PORT_LEDR -----------------------------------------------------------------	
EnLEDR <= (CS_LEDR AND MemWrite) ;
LEDRtristate <= CS_LEDR AND MemRead ;



PORT_LEDR: process(reset,EnLEDR)
			variable PORT_DATA_INPUT	: 	STD_LOGIC_VECTOR(7 DOWNTO 0)  ;
			BEGIN

				if EnLEDR = '1' then 
					PORT_DATA_INPUT := Data(7 DOWNTO 0);
					PORT_LEDR_Data <= PORT_DATA_INPUT;
				else 
					PORT_DATA_INPUT := PORT_DATA_INPUT;
				end if;

			end process;
		
-----------------------------------------------------------------PORT_HEX_0_1 -----------------------------------------------------------------	



En_HEX_0 <= ((CS_HEX_0_1 AND (not(A0))) AND MemWrite)  ;
HEX0tristate <= (CS_HEX_0_1 AND (not(A0))) AND MemRead ;

En_HEX_1 <= (CS_HEX_0_1 AND A0) AND MemWrite  ;
HEX1tristate <= (CS_HEX_0_1 AND A0) AND  MemRead ;

PORT_HEX0: process(reset,En_HEX_0)
			variable PORT_DATA_INPUT	: 	STD_LOGIC_VECTOR(6 DOWNTO 0)  ;
			BEGIN	
				if reset = '1' then 
				
				PORT_HEX0_Data <= "0000000";	
				
				
				elsif En_HEX_0 = '1' then 
					PORT_DATA_INPUT := Data_seven_segment;
					PORT_HEX0_Data <= PORT_DATA_INPUT;
				else 
					PORT_DATA_INPUT := PORT_DATA_INPUT;
				end if;

			end process;
PORT_HEX1: process(reset,En_HEX_1)
			variable PORT_DATA_INPUT	: 	STD_LOGIC_VECTOR(6 DOWNTO 0);
			BEGIN
				if reset = '1' then 
				
				
					PORT_HEX1_Data <= "0000000";	
				
				
				elsif En_HEX_1 = '1' then 
					PORT_DATA_INPUT := Data_seven_segment;
					PORT_HEX1_Data <= PORT_DATA_INPUT;
				else 
					PORT_DATA_INPUT := PORT_DATA_INPUT;
				end if;

			end process;
			
-----------------------------------------------------------------PORT_HEX_2_3 -----------------------------------------------------------------	


En_HEX_2 <= (CS_HEX_2_3 AND (not(A0))) AND MemWrite  ;
HEX2tristate <= (CS_HEX_2_3 AND (not(A0))) AND  MemRead ;


En_HEX_3 <= (CS_HEX_2_3 AND A0) AND MemWrite  ;
HEX3tristate <= (CS_HEX_2_3 AND A0) AND  MemRead ;

PORT_HEX2: process(reset,En_HEX_2)
			variable PORT_DATA_INPUT	: 	STD_LOGIC_VECTOR(6 DOWNTO 0)  ;
			BEGIN
			
				if reset = '1' then 
				
				
					PORT_HEX2_Data <= "0000000";	
				
				
 
				elsif En_HEX_2 = '1' and En_HEX_3 = '0' then 
					PORT_DATA_INPUT := Data_seven_segment;
					PORT_HEX2_Data <= PORT_DATA_INPUT;
				else 
					PORT_DATA_INPUT := PORT_DATA_INPUT;
				end if;

			end process;
PORT_HEX3: process(reset,En_HEX_3)
			variable PORT_DATA_INPUT	: 	STD_LOGIC_VECTOR(6 DOWNTO 0);
			BEGIN
				if reset = '1' then 
				
				
					PORT_HEX3_Data <= "0000000";	
				
				
				elsif En_HEX_3 = '1' and En_HEX_2 = '0' then 
					PORT_DATA_INPUT := Data_seven_segment;
					PORT_HEX3_Data <= PORT_DATA_INPUT;
				else 
					PORT_DATA_INPUT := PORT_DATA_INPUT;
				end if;

			end process;

-----------------------------------------------------------------PORT_HEX_4_5 -----------------------------------------------------------------	


En_HEX_4 <= ((CS_HEX_4_5 AND (not(A0))) AND MemWrite)  ;
HEX4tristate <= (CS_HEX_4_5 AND (not(A0))) AND MemRead ;

En_HEX_5 <= (CS_HEX_4_5 AND A0) AND MemWrite  ;
HEX5tristate <= (CS_HEX_4_5 AND A0) AND  MemRead ;

PORT_HEX4: process(reset,En_HEX_4)
			variable PORT_DATA_INPUT	: 	STD_LOGIC_VECTOR(6 DOWNTO 0)  ;
			BEGIN
				if reset = '1' then 
				
				
					PORT_HEX4_Data <= "0000000";	
				
				
 
				elsif En_HEX_4 = '1' and En_HEX_5 = '0' then 
					PORT_DATA_INPUT := Data_seven_segment;
					PORT_HEX4_Data <= PORT_DATA_INPUT;
				else 
					PORT_DATA_INPUT := PORT_DATA_INPUT;
				end if;

			end process;
			
			
			
PORT_HEX5: process(reset,En_HEX_5)
			variable PORT_DATA_INPUT	: 	STD_LOGIC_VECTOR(6 DOWNTO 0);
			BEGIN
				if reset = '1' then 
					PORT_HEX5_Data <= "0000000";

				elsif En_HEX_5 = '1' and En_HEX_4 = '0' then 
					PORT_DATA_INPUT := Data_seven_segment;
					PORT_HEX5_Data <= PORT_DATA_INPUT;
				else 
					PORT_DATA_INPUT := PORT_DATA_INPUT;
				end if;

			end process;


				
				
-----------------------------------------------------------------PORT_SW -----------------------------------------------------------------	

PORT_SW_Data <= PORT_SW0_7 when SWtristate = '1' else (others => 'Z');
SWtristate <= '1' when CS_SW = '1' AND MemRead = '1' else '0';
				
				








-----------------------------------------------------------------SEVEVEN_SEGMENT_DECODER -----------------------------------------------------------------	

	

process (Data(3 DOWNTO 0))
  begin
  case Data(3 DOWNTO 0) is 
      when X"0" =>
        Data_seven_segment <=  "1000000" ;
      when X"1" =>
        Data_seven_segment <=  "1111001";
      when X"2"  =>
        Data_seven_segment <= "0100100";
      when X"3" =>
        Data_seven_segment <=  "0110000";
      when X"4" =>
        Data_seven_segment <=  "0011001";
      when X"5" =>
        Data_seven_segment <=  "0010010";
      when X"6" =>
        Data_seven_segment <=  "0000010";
      when X"7" =>
        Data_seven_segment <=  "1111000";
	  when X"8" =>
		Data_seven_segment <= "0000000";
	  when X"9"  =>
		Data_seven_segment <=  "0010000";
	  when X"A" =>
		Data_seven_segment <=  "0001000";
	  when X"B" =>
		Data_seven_segment <=  "0000011";
	  when X"C" =>
		Data_seven_segment <=  "0100001";
	  when X"D" =>
		Data_seven_segment <=  "1110000";
	  when X"E" =>
		Data_seven_segment <=  "0000110";	
	  when X"F" =>
		Data_seven_segment <= "0001110";
	 when others =>
		Data_seven_segment <= (others => '0');
    end case;
  end process;	







				
				
				
				
				

			  



--O_PORT_KEY3_1 : PORT_KEY3_1
--	PORT MAP (CS_5		=>	CS(5), 	
--             KEY1	    =>	KEY1,			 				  
--             KEY2	    => KEY2,
--             KEY3	    => KEY3,
--			  IFG		=>	IFG(5 DOWNTO 3),
--			  KEY1IFG	=> KEY1IFG, 
--             KEY2IFG	=>	KEY2IFG, 		
--             KEY3IFG	=>	KEY3IFG); 	




				 
				 
END behavior;