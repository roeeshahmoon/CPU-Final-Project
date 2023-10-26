LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity DivMCLK is
    Port (
        clk_input : in  std_logic;
		clk_out_1 : out std_logic;
        clk_out_2 : out std_logic;
		clk_out_4 : out std_logic;
		clk_out_8: out std_logic
    );
end DivMCLK;

architecture Behavioral of DivMCLK is
    signal clk_out_8_signal : std_logic := '0';
    signal clk_out_4_signal, clk_in_4_signal : std_logic := '0';
    signal clk_out_2_signal, clk_in_2_signal : std_logic := '0';
	signal Q,D,F : std_logic := '0';

begin
--Flip Flop one
	process(clk_input)
		begin
		if rising_edge(clk_input) then
			Q <= not(Q);
		end if;
	clk_out_2_signal <= Q;
	clk_in_2_signal <= Q;
	clk_out_1 <= clk_input;
	end process;
	clk_out_2 <= clk_out_2_signal;

--Flip Flop two
	process(clk_in_2_signal)
		begin
		if rising_edge(clk_in_2_signal) then
			D <= not(D);
		end if;
	clk_out_4_signal <= D;
	clk_in_4_signal <= D;
	end process;
	clk_out_4 <= clk_out_4_signal;
	
--Flip Flop three
	process(clk_in_4_signal)
		begin
		if rising_edge(clk_in_4_signal) then
			F <= not(F);
		end if;
	clk_out_8_signal <= F;
	end process;
	clk_out_8 <= clk_out_8_signal;
	
	
end Behavioral;
