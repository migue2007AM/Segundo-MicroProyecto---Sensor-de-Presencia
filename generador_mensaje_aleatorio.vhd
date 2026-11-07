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
		
	 -- Realimentación matemática para crear la secuencia pseudoaleatoria
    bit_retroceso <= registro_lfsr(7) xor registro_lfsr(5) xor registro_lfsr(4) xor registro_lfsr(3);

    -- Proceso 1: El LFSR corre constantemente a toda velocidad con el reloj de la FPGA
    process(clk, rst)
    begin
        if rst = '1' then
            registro_lfsr <= "10101011"; -- Semilla inicial segura
        elsif rising_edge(clk) then
            registro_lfsr <= registro_lfsr(6 downto 0) & bit_retroceso;
        end if;
    end process;

    -- Proceso 2: Cambia la dirección de la ROM (del 0 al 5) únicamente cuando 
    -- la máquina de estados lo permite y pasa exactamente 1 segundo.
    process(clk, rst)
    begin
        if rst = '1' then
            indice_rom <= 0;
        elsif rising_edge(clk) then
            if rom_en = '1' and tick_1s = '1' then
                -- Restringimos el valor para que solo apunte a las direcciones válidas de la ROM (0, 1, 2, 3, 4, 5)
                indice_rom <= to_integer(unsigned(registro_lfsr)) mod 6;
            end if;
        end if;
    end process;

    -- Convertimos el número entero a vector lógico para entregárselo a la ROM
    rom_addr <= std_logic_vector(to_unsigned(indice_rom, ADDR_WIDTH));

end architecture

