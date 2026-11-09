library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity maq_esta is
    Port (
        clk               : in  STD_LOGIC;
        rst               : in  STD_LOGIC;
        pir_in            : in  STD_LOGIC; -- '1' hay presencia, '0' no hay
        proceso_fin 		  : in  STD_LOGIC; -- senal que indica si el bloque externo termina³
        rom_en            : out STD_LOGIC; -- Habilitador de lectura para ROM
        ram_en            : out STD_LOGIC; -- Habilitador de escritura para RAM 
        senal			     : out STD_LOGIC;  -- Aviso que la maquina de estados envi­a
		  tick_1s           : in  STD_LOGIC;
		  rom_addr          : out STD_LOGIC_VECTOR(3 downto 0) --Direccion aleatoria para la ROM (0 a 5)
    );
end maq_esta;

architecture contro of maq_esta is

   type state_type is (ST_ESPERA, ST_PROCESO);
   signal current_state, next_state : state_type;
	
	-- SeÃ±ales internas para el generador aleatorio (LFSR)
   signal registro_lfsr : std_logic_vector(7 downto 0) := "10101011";
   signal bit_retroceso : std_logic;
   signal indice_rom    : integer range 0 to 5 := 0;
   signal tick_prev, pir_prev : STD_LOGIC := '0';
   signal pulso_disparo    : STD_LOGIC;
	 
	begin
	

	-- Detector de flanco de subida para el tick de 1 segundo
   process(clk, rst)
   begin
       if rst = '1' then
			  pir_prev <= '0';
           tick_prev <= '0';
       elsif rising_edge(clk) then
           tick_prev <= tick_1s;
			  pir_prev  <= pir_in;
       end if;
   end process;
   
   -- pulso_1s valdrÃ¡ '1' durante EXACTAMENTE 1 ciclo de reloj cada 1 segundo
   pulso_disparo <= '1' when (pir_in = '1' and pir_prev = '0') or (pir_in = '1' and tick_1s = '1' and tick_prev = '0') else '0';
	bit_retroceso <= registro_lfsr(7) xor registro_lfsr(5) xor registro_lfsr(4) xor registro_lfsr(3);
	
	process(clk, rst)
    begin
        if rst = '1' then
            registro_lfsr <= "10101011";
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
                -- Limita el valor aleatorio estrictamente entre 0 y 5 (mensajes de tu ROM)
					 if to_integer(unsigned(registro_lfsr(2 downto 0))) > 5 then
							indice_rom <= 5;
					 else 
							indice_rom <= to_integer(unsigned(registro_lfsr(2 downto 0)));
					 end if;
            end if;
        end if;
    end process;
    
    rom_addr <= std_logic_vector(to_unsigned(indice_rom, 4));
	 
	 process(clk, rst)
		 begin
			  if rst = '1' then
					current_state <= ST_ESPERA;
			  elsif rising_edge(clk) then
					current_state <= next_state;
			  end if;
		 end process;
	
	process (current_state, pulso_disparo	, proceso_fin)
	begin
	
		next_state <= current_state;
		rom_en     <= '0';
		ram_en     <= '0';
		senal		  <= '0';
		
	case current_state is
	-- ESTADO 0: Espera de presencia del sensor
		when ST_ESPERA => 
			rom_en <= '0';
			
			if pulso_disparo = '1' then 
				next_state <= ST_PROCESO;
			else 
				next_state <= ST_ESPERA;
			end if;
		
	-- ESTADO 1: Bucle de ejecuciÃƒÂ³n coordinando las memorias externas
	
		when ST_PROCESO =>
			rom_en <= '1';
			ram_en <= '1';
			
			if proceso_fin = '1' then
				senal <= '1';
				next_state <= ST_ESPERA;
			else
				next_state <= ST_PROCESO;
			end if;	
			
			when others => 
			next_state <= ST_ESPERA;
		
		end case;
	end process;

end architecture;	
	