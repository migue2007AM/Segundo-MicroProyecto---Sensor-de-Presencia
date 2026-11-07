	LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY divisor_frecuencia IS

    GENERIC (
        FININ : INTEGER := 50000000; 		-- Frecuencia del oscilador de la FPGA (50 MHz)
        FOUT  : INTEGER := 1         		-- Frecuencia deseada para el conteo (1 Hz)
    );

    PORT (
        clk_in  : IN STD_LOGIC;      		-- Entra el reloj rápido de 50 MHz de la FPGA
        reset   : IN STD_LOGIC;      		-- Reset del reloj, si se activa se vuelve a 0 el sistema
        clk_out : OUT STD_LOGIC      		-- Sale la señal dividida de 1 Hz
    );

END ENTITY;


ARCHITECTURE Behavioral OF divisor_frecuencia IS

    CONSTANT LIMITE : INTEGER := (FININ / (2 * FOUT)) - 1;      -- Esta linea lo que hace es calcular la escala sabiendo que se tiene como frecuencia de entrada 50MHz, entonces como se quiere 1Hz entonces se van a generar 50000000 flancos por lo que cada flanco (subida y bajada) tendria 25MHz o visto de forma numerica exacta 24999999

    SIGNAL contador : INTEGER RANGE 0 TO LIMITE := 0;           -- La funcion de esta señal es crear un rango de enteros con limite 'LIMITE', este conteo sera el valor de pulsos de cada flanco, como nos dio 24999999 entonces este contador se encarga de contar hasta ese limite
    SIGNAL clk_aux  : STD_LOGIC := '0';                         -- Esta señal nos sirve para establecer el valor de los flancos de reloj de nuestro reloj

BEGIN

    PROCESS(clk_in, reset)

    BEGIN

	 
	     -- La funcion de esta condicion es que si llega una señal de 1 al reset el divisor se reinicie 
        IF reset = '1' THEN   				 

            contador <= 0;      -- dejando al contador en cero
            clk_aux <= '0';     -- y se deja el flanco de reloj en 0        				 

				
		  -- Esta linea nos dice que si el reloj de la FPGA esta en un flanco de subida (rising_edge(clk)) entonces siga con los if de ese camino
        ELSIF rising_edge(clk_in) THEN     

		  
		      -- Aqui nos da otra condicion que es que si el contador llega al LIMITE que de por si es el valor final de un flanco entonces
            IF contador = LIMITE THEN      

                contador <= 0;              -- El contador se reinicia y
                clk_aux <= NOT clk_aux;     -- Se invierte el valor del flanco, esto que quiere decir, quiere decir que como nuestro reloj inicio con un flanco en 0 (flanco de bajada) entonces ahora se invertira a un flanco de subida    

            ELSE

                contador <= contador + 1;     -- Sino se cumple la condicion de arriba entonces seguira contando, con el fin de que en algun momento se tiene que cumplir la condicion de arriba

            END IF;

        END IF;

    END PROCESS;


    clk_out <= clk_aux;     -- Como clk_aux es una señal entonces se asigna a la salida del divisor, lo que resulta que cada flanco es 1Hz cumpliendo con exito la conversion de 50MHz a 1Hz

END Behavioral;