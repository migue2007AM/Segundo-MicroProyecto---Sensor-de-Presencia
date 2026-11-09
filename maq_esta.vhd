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
		  --tick_1s           : in  STD_LOGIC;
		  rom_addr          : out STD_LOGIC_VECTOR(3 downto 0) --Direccion aleatoria para la ROM (0 a 5)
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
   --signal tick_1s_prev : STD_LOGIC := '0';
   --signal pulso_1s     : STD_LOGIC;
	 
	begin
	 -- 1. LÃ³gica del LFSR (Corre constantemente a toda velocidad con el reloj de la FPGA)
	bit_retroceso <= registro_lfsr(7) xor registro_lfsr(5) xor registro_lfsr(4) xor registro_lfsr(3);

	-- Detector de flanco de subida para el tick de 1 segundo
   --process(clk, rst)
   --begin
       --if rst = '1' then
       --    tick_1s_prev <= '0';
       --elsif rising_edge(clk) then
       --    tick_1s_prev <= tick_1s;
       --end if;
   --end process;
   
   -- pulso_1s valdrÃ¡ '1' durante EXACTAMENTE 1 ciclo de reloj cada 1 segundo
   --pulso_1s <= '1' when (tick_1s = '1' and tick_1s_prev = '0') else '0';
	
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
					current_state <= ST_ESPERA;
			  elsif rising_edge(clk) then
					current_state <= next_state;
			  end if;
		 end process;
		 
		process(clk, rst)
		begin
        if rst = '1' then
            indice_rom <= 0;
        elsif rising_edge(clk) then
            if current_state = ST_PROCESO or (current_state = ST_ESPERA and pir_in = '1') then
					 -- and tick_1s = '1'
                -- Limita el valor aleatorio estrictamente entre 0 y 5 (mensajes de tu ROM)
                --indice_rom <= to_integer(unsigned(registro_lfsr)) mod 6;
					 if to_integer(unsigned(registro_lfsr(2 downto 0))) > 5 then
							indice_rom <= 5;
					 else 
							indice_rom <= to_integer(unsigned(registro_lfsr(2 downto 0)));
					 end if;
            --elsif current_state = ST_ESPERA then
            --    indice_rom <= 0; -- Se reinicia al esperar
            end if;
        end if;
    end process;
    
    rom_addr <= std_logic_vector(to_unsigned(indice_rom, 4));
	
	process (current_state, pir_in, proceso_fin)
	begin
	
		next_state <= current_state;
		rom_en     <= '0';
		ram_en     <= '0';
		senal		  <= '0';
		
	case current_state is
	-- ESTADO 0: Espera de presencia del sensor
		when ST_ESPERA => 
			rom_en <= '0';
			ram_en <= '0';
			
			if pir_in = '1' then 
				--ram_en <= '1';
				next_state <= ST_PROCESO;
			else 
				--ram_en <= '0';
				next_state <= ST_ESPERA;
			end if;
		
	-- ESTADO 1: Bucle de ejecuciÃƒÂ³n coordinando las memorias externas
	
		when ST_PROCESO =>
			rom_en <= '1';
			--ram_en <= '1';
			
			if pir_in = '1' then
				ram_en <= '1';
				next_state <= ST_PROCESO;
			else
				ram_en <= '0';
				next_state <= ST_ESPERA;
			end if;	
			
			--if pir_in = '0' then
				--senal <= '1';
				--next_state <= ST_ESPERA;
			--else 
				--next_state <= ST_PROCESO;
			--end if;

			--if (proceso_fin = '1') and (pir_in = '0') then
				--senal <= '1';
				--next_state <= ST_ESPERA;
			
			--elsif (proceso_fin = '1') and (pir_in= '1') then 
				--senal <= '1';	
				--next_state <= ST_PROCESO;
			
			--else 
				--next_state <= ST_PROCESO;
			--end if;
			
			when others => 
			next_state <= ST_ESPERA;
		
		end case;
	end process;

end architecture;	
	