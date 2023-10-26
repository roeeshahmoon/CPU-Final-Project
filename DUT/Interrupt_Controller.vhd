--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE	work.MCU_aux_package.all;

ENTITY  Interrupt_Controller  IS
	PORT(	clock			: IN 	STD_LOGIC;	
			reset			: IN 	STD_LOGIC;	
			data_bus		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Interrupt_Controller_DATA_OUT		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Interrupt_Controller_WRITE				: OUT 	STD_LOGIC:='0';
			is_BTIFG		: IN 	STD_LOGIC;		
			is_KEYIFG_1		: IN 	STD_LOGIC;		
			is_KEYIFG_2		: IN 	STD_LOGIC;		
			is_KEYIFG_3		: IN 	STD_LOGIC;
			GIE				: IN 	STD_LOGIC:='1';
			CS_IE		    : IN   STD_LOGIC;
			CS_IFG		    : IN   STD_LOGIC;
			MemWrite		: IN   STD_LOGIC;
			MemRead			: IN   STD_LOGIC;
			INTA			: IN 	STD_LOGIC;
			INTR			: OUT	STD_LOGIC);			
			
END Interrupt_Controller ;

ARCHITECTURE behavior OF Interrupt_Controller  IS


SIGNAL	IFG_SIGNAL,TYPE_VAR_S			: STD_LOGIC_VECTOR( 7 DOWNTO 0 ):=X"00";

-----------------------------------------------------------------IE SIGNAL -----------------------------------------------------------------
SIGNAL EnIE						: STD_LOGIC ;
SIGNAL IE						: STD_LOGIC_VECTOR( 7 DOWNTO 0 );

-----------------------------------------------------------------TYPE SIGNAL -----------------------------------------------------------------
SIGNAL TYPE_REG						: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL zero						: STD_LOGIC_VECTOR( 31 DOWNTO 0 ):=X"00000000";

-----------------------------------------------------------------IFG SIGNAL -----------------------------------------------------------------

SIGNAL EnIFG						: STD_LOGIC ;
SIGNAL IFG							: STD_LOGIC_VECTOR( 7 DOWNTO 0 ):=X"00";


-----------------------------------------------------------------BASIC_TIMER SIGNAL -----------------------------------------------------------------
SIGNAL irq_bt,eint_bt,iclr_rq_bt		: STD_LOGIC:='0' ;


-----------------------------------------------------------------KEY1 SIGNAL -----------------------------------------------------------------
SIGNAL irq_key_1,eint_key_1,iclr_rq_key_1		: STD_LOGIC:='0';

-----------------------------------------------------------------KEY2 SIGNAL -----------------------------------------------------------------
SIGNAL irq_key_2,eint_key_2,iclr_rq_key_2		: STD_LOGIC:='0' ;


-----------------------------------------------------------------KEY3 SIGNAL -----------------------------------------------------------------
SIGNAL irq_key_3,eint_key_3,iclr_rq_key_3		: STD_LOGIC:='0' ;









alias   BTIFG  	: STD_LOGIC is IFG(2);
alias   KEY1IFG  	: STD_LOGIC is IFG(3);
alias  	KEY2IFG  	: STD_LOGIC is IFG(4);
alias   KEY3IFG  	: STD_LOGIC is IFG(5);

BEGIN
eint_bt <= IE(2);
eint_key_1 <= IE(3);
eint_key_2 <= IE(4);
eint_key_3 <= IE(5);





Interrupt_Controller_WRITE <= INTA OR  (CS_IFG AND MemRead);



Interrupt_Controller_DATA_OUT <= zero(31 DOWNTO 8)&TYPE_VAR_S when INTA = '1' else	X"000000" & IFG when CS_IFG = '1' and MemRead = '1' else (others => '0');




PROCESS(is_BTIFG,iclr_rq_bt)
	BEGIN
	if iclr_rq_bt = '0' then 
		if rising_edge(is_BTIFG) then 
			irq_bt  <= '1' ;
		else 
			irq_bt <= irq_bt;
		end if;
	elsif iclr_rq_bt = '1' then 
		irq_bt  <= '0';
	end if;


end PROCESS;







process(is_KEYIFG_1,iclr_rq_key_1)
	BEGIN

	if  falling_edge(is_KEYIFG_1)  then 
		irq_key_1 <= '1';
	elsif  iclr_rq_key_1 = '1' then 	
		irq_key_1 <= '0' ;
	
	end if;


end process;


process(is_KEYIFG_2,iclr_rq_key_2)
	BEGIN
	
	if iclr_rq_key_2 = '0' then 
		if falling_edge(is_KEYIFG_2) then 
			irq_key_2 <= '1' ;
		else 	
			irq_key_2	<=	irq_key_2;
		end if;
	elsif iclr_rq_key_2 = '1' then 
		irq_key_2 <= '0';
	end if;


end process;



process(is_KEYIFG_3,iclr_rq_key_3)
	BEGIN

	if iclr_rq_key_3 = '0' then 
		if falling_edge(is_KEYIFG_3) then 
			irq_key_3 <= '1' ;
		else
			irq_key_3	<=	irq_key_3;
		end if;
	elsif iclr_rq_key_3 = '1' then 
		irq_key_3 <= '0';
	end if;

end process;



-----------------------------------------------------------------IE REGISTER -----------------------------------------------------------------
EnIE <= (CS_IE AND MemWrite) ;




IE_REG: process(clock,reset,EnIE)
			BEGIN
				if reset = '1' then 
					
					IE <= (others => '0');
			
			
				elsif rising_edge(clock) then 
					if EnIE = '1' then 
				
						IE <= data_bus(7 DOWNTO 0);
					else 
						IE <= IE;
					end if;
				end if;

			end process;





-----------------------------------------------------------------IFG REGISTER -----------------------------------------------------------------

EnIFG <= (CS_IFG AND MemWrite);

IFG_REG: process(clock,reset,EnIFG,is_BTIFG,iclr_rq_bt,is_KEYIFG_1,iclr_rq_key_1)
			BEGIN
			if reset = '1' then 
				
				IFG <= (others => '0');
		
		
			 
			elsif EnIFG = '1'  then 
		
				IFG <= 		data_bus(7 DOWNTO 0);
				iclr_rq_key_1 <=  not(KEY1IFG);
				
			else 
				BTIFG <= irq_bt AND eint_bt;
				KEY1IFG <= irq_key_1 AND eint_key_1;
				iclr_rq_key_1 <=  not(KEY1IFG);
				KEY2IFG <= irq_key_2 AND eint_key_2;
				KEY3IFG <= irq_key_3 AND eint_key_3;
				
				
			end if;
				--IFG <= IFG;
				
				
				iclr_rq_bt <= (INTA) and BTIFG;
				

				iclr_rq_key_1 <=  not(KEY1IFG);


				iclr_rq_key_2 <= (not(BTIFG)) and (not(KEY1IFG)) and KEY2IFG;
				

				iclr_rq_key_3 <=  (not(BTIFG)) and (not(KEY1IFG)) and (not(KEY2IFG)) and KEY3IFG;
				
		

			end process;














TYPE_Register: PROCESS(Clock)
						  variable TYPE_VAR	:	STD_LOGIC_VECTOR(7 DOWNTO 0):= X"00";					
							BEGIN
								if rising_edge(clock) then 	
									
									TYPE_VAR_S(7 downto 4) <=	X"1";							
																							
									TYPE_VAR_S(1 downto 0) <=	"00";                           
																							

									TYPE_VAR_S(2) <= (KEY1IFG or KEY3IFG) and ((BTIFG nor KEY2IFG));


									TYPE_VAR_S(3) <= (KEY2IFG or KEY3IFG) and ((BTIFG nor KEY1IFG));
									TYPE_REG <= TYPE_VAR_S;	
								else 	
								
									TYPE_REG <= TYPE_REG;	
								end if;
							END PROCESS;






















INTR <= (KEY1IFG or BTIFG or KEY2IFG or KEY3IFG) AND GIE;


END behavior;

	