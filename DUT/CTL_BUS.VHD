library ieee;
use ieee.std_logic_1164.all;
USE	work.MCU_aux_package.all;
-----------------------------------------------------------------
entity CTL_BUS is
	generic( width: integer:=2 );
	port(   clock 				: in STD_LOGIC;
			Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 	std_logic_vector(width-1 downto 0)
	);
end CTL_BUS;

architecture comb of CTL_BUS is
begin 

	Din  <= IOpin;
	IOpin <= Dout when(en='1') else (others => 'Z');
	
	

	
end comb;
