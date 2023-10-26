library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE	work.MCU_aux_package.all;
entity CommonDataBus is
    Port (clock 	: in STD_LOGIC;
        CPU_Data    : in STD_LOGIC_VECTOR(31 downto 0);
        CPU_Write   : in STD_LOGIC:='1';
        GPIO_Data   : in STD_LOGIC_VECTOR(31 downto 0);
        GPIO_Write  : in STD_LOGIC;
		Interrupt_Controller_DATA_OUT   : in STD_LOGIC_VECTOR(31 downto 0);
        Interrupt_Controller_WRITE		: in STD_LOGIC;	
        IOPIN     	: inout STD_LOGIC_VECTOR(31 downto 0);
		busData  	: out STD_LOGIC_VECTOR(31 downto 0);
        busDir      : out STD_LOGIC;
        busRW       : in STD_LOGIC
    );
end CommonDataBus;

architecture Behavioral of CommonDataBus is
    

begin

	busData <= IOPIN;
	IOpin <= CPU_Data when(CPU_Write='1')   else Interrupt_Controller_DATA_OUT when(Interrupt_Controller_WRITE='1') else GPIO_Data when(GPIO_Write = '1' AND Interrupt_Controller_WRITE = '0')  else (others => 'Z');


end Behavioral;
