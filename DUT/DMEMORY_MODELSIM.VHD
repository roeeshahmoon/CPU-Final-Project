						--  Dmemory module (implements the data
						--  memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY dmemory IS
	PORT(	read_data_OUT 		: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			NEXT_PC_INT 		: OUT 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( 11 DOWNTO 0 );
			DATA_BUS 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			INTA_IN			 	: IN 	STD_LOGIC;
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
END dmemory;

ARCHITECTURE behavior OF dmemory IS
SIGNAL write_clock,write_ena : STD_LOGIC;
SIGNAL read_data : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL adrress_final : STD_LOGIC_VECTOR( 11 DOWNTO 0 );
BEGIN
adrress_final <= DATA_BUS(11 DOWNTO 0) when INTA_IN = '1' else address ;
read_data_OUT <= DATA_BUS when address(11) = '1' and MemRead = '1'  else read_data;
write_ena <= memwrite AND not(address(11)) ;
NEXT_PC_INT		 <= "00" & read_data(9 DOWNTO 2);
	data_memory : altsyncram
	GENERIC MAP  (
		operation_mode => "SINGLE_PORT",
		width_a => 32,
		widthad_a => 8,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\Users\Noam\Desktop\project07_08\tests\DTCM.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		wren_a => write_ena,
		clock0 => write_clock,
		address_a => adrress_final(9 DOWNTO 2),
		data_a => write_data,
		q_a => read_data	);
-- Load memory address register with write clock
		write_clock <= NOT clock;
END behavior;

