library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity generador_mensaje_aleatorio is
    Generic (
        ADDR_WIDTH : positive := 4
    );
    Port (
        clk        : in  STD_LOGIC;                    
        rst        : in  STD_LOGIC;                   
        tick_1s    : in  STD_LOGIC;                    -- Pulso de 1 segundo que viene del divisor
        rom_en     : in  STD_LOGIC;                    -- Señal de la Máquina de Estados que autoriza leer
        rom_addr   : out STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0) -- Dirección de salida hacia la ROM (0 a 5)
    );
end entity;

		architecture comportamiento of generador_mensaje_aleatorio is
			 -- Registro de desplazamiento (LFSR) que cambia de valor millones de veces por segundo
			 signal registro_lfsr : std_logic_vector(7 downto 0) := "10101011"; 
			 signal bit_retroceso : std_logic;
			 signal indice_rom    : integer range 0 to 5 := 0;
		begin
		
		

