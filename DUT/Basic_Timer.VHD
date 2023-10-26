LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE	work.MCU_aux_package.all;

entity BasicTimer is
    Port (  reset 		: in STD_LOGIC ; 
			clock 		: in STD_LOGIC; 
			data_bus	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			CS_BTCCR1	: IN 	STD_LOGIC;
			CS_BTCCR0	: IN 	STD_LOGIC;
			CS_BTCTL	: IN 	STD_LOGIC;
			MemWrite	: IN 	STD_LOGIC;
			Out_Signal	 : out STD_LOGIC;
			Set_BTIFG 	: buffer STD_LOGIC);         
end BasicTimer;

architecture Behavioral of BasicTimer is

COMPONENT DivMCLK is
    Port (
        clk_input : in  std_logic;
		clk_out_1 : out std_logic;
        clk_out_2 : out std_logic;
		clk_out_4 : out std_logic;
		clk_out_8: out std_logic
    );
	END COMPONENT; 
----------------------------------------------------------------- REGISTER SIGNAL -----------------------------------------------------------------
SIGNAL BTCCR0,BTCCR1			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL BTCTL						: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL EnBTCTL,EnBTCCR0,EnBTCCR1			: STD_LOGIC ;



	alias   BTIP  	: STD_LOGIC_VECTOR(2 downto 0 ) is BTCTL(2 downto 0);
	alias   BTSSEL  : STD_LOGIC_VECTOR(1 downto 0) is BTCTL(4 downto 3);
	alias   BTHOLD 	: STD_LOGIC is BTCTL(5);
	alias   BTOUTEN : STD_LOGIC is BTCTL(6);

	signal BTCNT : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";  

	alias   Q0 		: STD_LOGIC is BTCNT(0);
	alias   Q3 		: STD_LOGIC is BTCNT(3);
	alias   Q5 		: STD_LOGIC is BTCNT(5);
	alias   Q7 		: STD_LOGIC is BTCNT(7);
	alias   Q11 	: STD_LOGIC is BTCNT(11);
	alias   Q15 	: STD_LOGIC is BTCNT(15);
	alias   Q19 	: STD_LOGIC is BTCNT(19);
	alias   Q23 	: STD_LOGIC is BTCNT(23);
	alias   Q25 	: STD_LOGIC is BTCNT(25);	
	
	signal EN  : STD_LOGIC;
    signal BTCL0 : STD_LOGIC_VECTOR(31 downto 0); 
	signal BTR   : STD_LOGIC_VECTOR(31 downto 0);  	
    signal BTCL1 :  STD_LOGIC_VECTOR(31 downto 0); 
	signal pwm_out  :  STD_LOGIC:= '1';
	signal Set_BTIFG_s		: STD_LOGIC:='0';
	
	signal	Clk_chosen : STD_LOGIC; 
	signal	MCLK : STD_LOGIC; 
	signal	MCLK_2 : STD_LOGIC; 
	signal	MCLK_4 : STD_LOGIC; 
	signal	MCLK_8 : STD_LOGIC; 
	
	signal	Qi_State,D : STD_LOGIC:='0'; 
    
begin

-----------------------------------------------------------------BASIC TIMER REGISTERS -----------------------------------------------------------------

EnBTCTL <= (CS_BTCTL AND MemWrite) ;

BTCTL_REG: process(clock,reset,EnBTCTL)
			BEGIN
				if reset = '1' then 
					
					BTCTL <= (others => '0');
			
			
				elsif rising_edge(clock) then 
					if EnBTCTL = '1' then 
				
						BTCTL <= data_bus(7 DOWNTO 0);
					else 
						BTCTL <= BTCTL;
					end if;
				end if;

			end process;
			
			
			
EnBTCCR0 <= (CS_BTCCR0 AND MemWrite);

BTCCR0_REG: process(clock,reset,EnBTCCR0)
			BEGIN
				if reset = '1' then 
					
					BTCCR0 <= (others => '0');
			
			
				elsif rising_edge(clock) then 
					if EnBTCCR0 = '1' then 
				
						BTCCR0 <= data_bus;
					else 
						BTCCR0 <= BTCCR0;
					end if;
				end if;

			end process;


EnBTCCR1 <= (CS_BTCCR1 AND MemWrite);

BTCCR1_REG: process(clock,reset,EnBTCCR1)
			BEGIN
				if reset = '1' then 
					
					BTCCR1 <= (others => '0');
			
			
				elsif rising_edge(clock) then 
					if EnBTCCR1 = '1' then 
				
						BTCCR1 <= data_bus;
					else 
						BTCCR1 <= BTCCR1;
					end if;
				end if;

			end process;
			













	Clk_Div : DivMCLK port map(clk_input => clock, clk_out_1 => MCLK,
				 clk_out_2 => MCLK_2 , clk_out_4 => MCLK_4, clk_out_8 => MCLK_8);
	
	EN <= not BTHOLD;
	BTCL0 <= BTCCR0;
	BTCL1 <= BTCCR1;
	
 
  process(Clk_chosen, reset)
    begin
       if reset = '1' then
            BTR <= (others => '0');
            			
        elsif rising_edge(Clk_chosen) then
			if EN = '1'  and BTR /= BTCL0   then
				BTR <= BTR + 1;

			elsif EN = '1'  and BTR = BTCL0   then
				BTR <= (others => '0');
			else
				BTR <= BTR;
			end if;
		end if;
    end process;




	
	pwm_out <= '0' when BTR = BTCL1
				else '1' when BTR = X"00000000" else unaffected;
	Out_Signal <= pwm_out when BTOUTEN = '1' else '0';









  process(Clk_chosen, reset)
    begin
       if reset = '1' then
            BTCNT <= (others => '0');
            			
        elsif rising_edge(Clk_chosen) then
			if EN = '1' then
				BTCNT <= BTCNT + 1;

			else
				BTCNT <= BTCNT;
			end if;
		end if;
    end process;


    process (MCLK, MCLK_2, MCLK_4, MCLK_8, BTSSEL)
    begin
        -- Mux 4x1 select SMCLK divided by
        case BTSSEL is
            when "00" => Clk_chosen <= MCLK;
            when "01" => Clk_chosen <= MCLK_2;
            when "10" => Clk_chosen <= MCLK_4;
            when others => Clk_chosen <= MCLK_8;
        end case;
    end process;

	process (Q0, Q3, Q7, Q11, Q15, Q19, Q23, Q25, BTIP,clock)
	variable Set_BTIFG_v		:  STD_LOGIC;
	variable temp		:  STD_LOGIC;
    begin
	    --Mux 8x1 triger by BTCNT bit for interrupt
		temp := Set_BTIFG_s;
        case BTIP is
            when "000" => Set_BTIFG_s <= Q0;
            when "001" => Set_BTIFG_s <= Q3;
            when "010" => Set_BTIFG_s <= Q7;
            when "011" => Set_BTIFG_s <= Q11;
			when "100" => Set_BTIFG_s <= Q15;
            when "101" => Set_BTIFG_s <= Q19;
            when "110" => Set_BTIFG_s <= Q23;
            when others => Set_BTIFG_s <= Q25;
        end case;

    end process;
		

--Flip Flop one
	process(clock,Set_BTIFG_s)
		
		begin
		if rising_edge(Set_BTIFG_s) or falling_edge(Set_BTIFG_s) then 
			Set_BTIFG <= '1';
		else 
			Set_BTIFG <= '0';
		end if;

	end process;
	
	

	
	
	




end Behavioral;
