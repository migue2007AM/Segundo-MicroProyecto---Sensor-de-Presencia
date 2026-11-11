library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity maq_esta is
    Port (
        clk         : in  STD_LOGIC; 						 -- reloj de la FPGA
        rst         : in  STD_LOGIC; 						 -- reset: '1' resetea '1' no resetea
        pir_in      : in  STD_LOGIC; 						 -- '1' hay presencia, '0' no hay
        proceso_fin : in  STD_LOGIC; 						 -- senal que indica si el bloque externo termino
        tick_1s     : in  STD_LOGIC; 						 -- reloj de 1hz (llega la salida de divisor_frecuencia)
		  
		  rom_en      : out STD_LOGIC; 						 -- Habilitador de lectura para ROM
        ram_en      : out STD_LOGIC; 						 -- Habilitador de escritura para RAM 
        senal       : out STD_LOGIC; 						 -- Aviso que la maquina de estados envia
        rom_addr    : out STD_LOGIC_VECTOR(3 downto 0) -- direccion de memoria que se va a leer en la rom
    );
end maq_esta;

architecture contro of maq_esta is

    type state_type is (ST_ESPERA, ST_PROCESO);
    signal current_state, next_state : state_type;
    
    -- Señales internas para el generador aleatorio (LFSR)
    signal registro_lfsr  : std_logic_vector(7 downto 0) := "10101011";     -- Es una memoria de 8 bits que guarda patrones aleatorios que cambian a grandes velocidades
    signal bit_retroceso  : std_logic;                       					 -- Esta señal mediante un proceso matematico combina valores de registro_lfsr para que se intente tener algo aleatorio
    signal indice_rom     : integer range 0 to 15 := 0;							 -- Funciona como traductor de registro_lfsr para que la rom lo entienda
    signal tick_prev, pir_prev : STD_LOGIC := '0';									 -- La funcionalidad de estas señales es comparar el antes o el despues en dependencia de las condiciones en las que se use más adelante
    signal pulso_disparo  : STD_LOGIC;     											 -- Señal encargada de guiar a la maquina de estados para que realice las determinadas acciones
    
    signal cont_constante : integer range 0 to 3 := 0;     						 -- Contador para verificar que la presencia sea CONSTANTE antes de repetir disparos
     
begin

    -- Detector de flanco de subida y validación de presencia constante
    process(clk, rst)
    begin
        if rst = '1' then
            pir_prev       <= '0';
            tick_prev      <= '0';
            cont_constante <= 0;
        elsif rising_edge(clk) then
            
				-- Se guarda el instante antes del reloj de 1hz y la señal de presencia del sensor
				tick_prev <= tick_1s;     
            pir_prev  <= pir_in;
            
				
            if pir_in = '0' then
                cont_constante <= 0; -- Se reinicia si desaparece la presencia
            elsif (tick_1s = '1' and tick_prev = '0') then
                
					 -- Si antes de eso se detecta un flanco de subida (elsif de arriba) se pasa a este if que lo que hace es que si esta condicional se sigue cumpliendo, al llegar al limite de 2 el circuito va tomar la presencia como constante entonces aqui se cumple el requerimiento de que si es constante muestre codigos hexadecimales diferentes (cosa que se complementa más adelante)
					 if cont_constante < 2 then
                    cont_constante <= cont_constante + 1;
                end if;
            end if;
        end if;
    end process;
   
    -- pulso_disparo = 1 cuando se detecta una presencia general o cuando detecta una presencia que se mantiene
    pulso_disparo <= '1' when (pir_in = '1' and pir_prev = '0') or 
                              (pir_in = '1' and tick_1s = '1' and tick_prev = '0' and cont_constante = 2) 
                     else '0';
	 
	 -- Proceso matematico que se encarga de la pseudoaleatoriedad, esta basada en grafos donde garantiza que se recorrera 255 combinaciones binarias antes de que se repita
    bit_retroceso <= registro_lfsr(7) xor registro_lfsr(5) xor registro_lfsr(4) xor registro_lfsr(3);
    
    process(clk, rst)
    begin
        if rst = '1' then
            registro_lfsr <= "10101011";   -- En el caso de que se active el reset el registro_lfsr tomara ese valor de nuevo inicio
        
		  -- En el caso de que reset no este activo lo que hace este bloque es tomar los 7 bits de registro_lfsr e ir quitando el de más a la izquierda y llenando el espacio que se deja con el valor de bit_retroceso, creando nuevos registros
		  elsif rising_edge(clk) then
            registro_lfsr <= registro_lfsr(6 downto 0) & bit_retroceso;
        end if;
    end process;
         
    process(clk, rst)
    begin
        if rst = '1' then
            indice_rom <= 0;
        elsif rising_edge(clk) then
            if pulso_disparo = '1' and current_state = ST_ESPERA then
                -- Toma los 3 bits del LFSR (valores de 0 a 7, que coinciden con los 8 datos de rom_sync)
                indice_rom <= to_integer(unsigned(registro_lfsr(3 downto 0)));
            end if;
        end if;
    end process;
    
    rom_addr <= std_logic_vector(to_unsigned(indice_rom, 4));  -- Traduce el integer de indice rom a un vector de 4 bits
    
	 -- Idea general de la maquina de estados donde si rst = '0', en los flancos de subida, se tomara la decision de que el estado siguiente sera el actual
    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= ST_ESPERA;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
    
    -- Maquina de estados que no depende de clk sino de pulso_disparo y proceso_fin
	 process (current_state, pulso_disparo, proceso_fin)
    begin
        next_state <= current_state;
        rom_en     <= '0';
        ram_en     <= '0';
        senal      <= '0';
        
        case current_state is
            
				-- Si pulso_disparo = '1' avanza al siguiente estado, sino seguira en el mismo estado
				when ST_ESPERA => 
                if pulso_disparo = '1' then 
                    next_state <= ST_PROCESO;
                else 
                    next_state <= ST_ESPERA;
                end if;
            
            when ST_PROCESO =>
                
					 -- Directamente se dejan listas la rom y la ram para el proceso siguiente
					 rom_en <= '1';
                ram_en <= '1';
                
                -- Si proceso_fin = '1' se tomara como que el proceso de lectura y escritura de la RAM y la ROM ya termino por lo que se envia a senal el '1' para que mande el mensaje y se devuelve al estado inical
					 if proceso_fin = '1' then
                    senal      <= '1';
                    next_state <= ST_ESPERA;
                
					 -- sino seguira en el estado actual esperando a que termine el proceso
					 else
                    next_state <= ST_PROCESO;
                end if;    
                
            when others => 
                next_state <= ST_ESPERA; 
        end case;
    end process;

end architecture;