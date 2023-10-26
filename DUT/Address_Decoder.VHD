--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE	work.MCU_aux_package.all;

ENTITY  Address_Decoder  IS
	PORT(	clock 				: in STD_LOGIC;
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
			
			
END Address_Decoder;

ARCHITECTURE behavior OF Address_Decoder IS


BEGIN





CS_LEDR			<= A11 AND (not(A2)) AND (not(A3)) AND (not(A4)) AND (not(A5)) ; --check select PORT_LEDR
CS_HEX_0_1		<= A11 AND A2 AND (not(A3)) AND (not(A4)) AND (not(A5));--check select PORT_HEX0/1
CS_HEX_2_3		<= A11 AND (not(A2)) AND A3 AND (not(A4)) AND (not(A5));--check select PORT_HEX2/3
CS_HEX_4_5		<= A11 AND A2 AND A3 AND (not(A4)) AND (not(A5)) ;--check select PORT_HEX4/5
CS_SW			<= A11 AND (not(A2)) AND (not(A3)) AND A4 AND (not(A5)) ;--check select PORT_SW
CS_KEY			<= A11 AND ((A2)) AND (not(A3)) AND A4 AND (not(A5)) ;--check select PORT_KEY
CS_BTCTL		<= A11 AND ((A2)) AND ((A3)) AND A4 AND (not(A5));--check select BTCTL
CS_BTCNT		<= A11 AND (not(A2)) AND (not(A3)) AND (not(A4)) AND (not(A1)) AND (not(A0)) AND A5;--check select BTCNT
CS_BTCCR0		<= A11 AND ((A2)) AND (not(A3)) AND (not(A4)) AND (not(A1)) AND (not(A0)) AND A5;--check select BTCCR0
CS_BTCCR1		<= A11 AND (not(A2)) AND ((A3)) AND (not(A4)) AND (not(A1)) AND (not(A0)) AND A5;--check select BTCCR1
CS_IE			<= A11 AND ((A2)) AND ((A3)) AND (not(A4)) AND (not(A1)) AND (not(A0)) AND A5;--check select IE
CS_IFG			<= A11 AND ((A2)) AND ((A3)) AND (not(A4)) AND (not(A1)) AND ((A0)) AND A5;--check select IFG				
CS_TYPE			<= A11 AND ((A2)) AND ((A3)) AND (not(A4)) AND ((A1)) AND (not(A0)) AND A5;--check select TYPE

				
END behavior;
	