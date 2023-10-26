		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE	work.MIPS_aux_package.all;

ENTITY Debugg_Unit IS
   PORT( 	
	clock 			: IN 	STD_LOGIC;
	reset,ena 			: IN 	STD_LOGIC;
	PC_out 			: IN	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	BPADD 			: IN	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	IF_Flush		: IN 	STD_LOGIC;
	Clear_ID_EX_CTL	: IN 	STD_LOGIC;
	STtrigger		: OUT	STD_LOGIC;
	CLKCNT	 		: OUT	STD_LOGIC_VECTOR( 15 DOWNTO 0 );	
	STCNT	 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );	
	FHCNT	 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 ));
END Debugg_Unit;

ARCHITECTURE behavior OF Debugg_Unit IS


BEGIN

STtrigger <= '1' when BPADD = PC_out AND reset = '0' AND ena = '1' else '0';
		



Cycle_Counter_Register: PROCESS(Clock,reset,ena)
						  variable Clock_counter	:	STD_LOGIC_VECTOR(15 DOWNTO 0):= X"0000";					
							BEGIN
								if rising_edge(clock) then 
									if reset = '1' then 
										Clock_counter := X"0000";
										CLKCNT <= X"0000";
									elsif ena = '1' then
										Clock_counter := Clock_counter + 1;
										CLKCNT <= Clock_counter;
									end if;
									
								end if;
							END PROCESS;
							
						  
Stall_Counter_Register: PROCESS(Clock,reset,ena)
						  variable Stall_counter	:	STD_LOGIC_VECTOR(7 DOWNTO 0):= X"00";					
							BEGIN
								if rising_edge(clock) then 
									if reset = '1' then 
										Stall_counter := X"00";
										
									elsif Clear_ID_EX_CTL = '1' AND ena = '1' then  
										Stall_counter := Stall_counter + 1;
									else 	
										Stall_counter := Stall_counter;
									end if;
									STCNT <= Stall_counter;
								end if;
							END PROCESS;
Flush_Counter_Register: PROCESS(Clock,reset,ena)
						  variable Flush_counter	:	STD_LOGIC_VECTOR(7 DOWNTO 0):= X"00";					
							BEGIN
								if rising_edge(clock) then 
									if reset = '1' then 
										Flush_counter := X"00";
										
									elsif IF_Flush = '1' and ena = '1' then  
										Flush_counter := Flush_counter + 1;
									else 	
										Flush_counter := Flush_counter;
									end if;
									FHCNT <= Flush_counter;
								end if;
							END PROCESS;	
	
	
END behavior;


