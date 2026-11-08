library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity maq_esta is
    Port (
        clk               : in  STD_LOGIC;
        rst               : in  STD_LOGIC;
        pir_in            : in  STD_LOGIC; -- '1' hay presencia, '0' no hay
        proceso_fin 		  : in  STD_LOGIC; -- senal que indica si el bloque externo terminó
        rom_en            : out STD_LOGIC; -- Habilitador de lectura para ROM
        ram_en            : out STD_LOGIC; -- Habilitador de escritura para RAM 
        senal			     : out STD_LOGIC;  -- Aviso que la máquina de estados envía
		  tick_1s           : in  STD_LOGIC;
		  rom_addr          : out STD_LOGIC_VECTOR(3 downto 0) --Dirección aleatoria para la ROM (0 a 5)
    );
end maq_esta;

architecture contro of maq_esta is

   type state_type is (ST_ESPERA, ST_PROCESO);
   signal current_state, next_state : state_type;
	 
	begin

		 process(clk, rst)
		 begin
			  if rst = '1' then
					current_state <= ST_ESPERA;
			  elsif rising_edge(clk) then
					current_state <= next_state;
			  end if;
		 end process;
	
	process (current_state, pir_in, proceso_fin)
	begin
	
		next_state <= current_state;
		rom_en     <= '0';
		ram_en     <= '0';
		senal		  <= '0';
		
	case current_state is
	-- ESTADO 0: Espera de presencia del sensor
		when ST_ESPERA => 
			if pir_in = '1' then 
				next_state <= ST_PROCESO;
			else 
				next_state <= ST_ESPERA;
			end if;
		
	-- ESTADO 1: Bucle de ejecución coordinando las memorias externas
	
		when ST_PROCESO =>
			rom_en <= '1';
			ram_en <= '1';

			if (proceso_fin = '1') and (pir_in = '0') then
				senal <= '1';
				next_state <= ST_ESPERA;
			
			elsif (proceso_fin = '1') and (pir_in= '1') then 
				senal <= '1';
				next_state <= ST_PROCESO;
			
			else 
				next_state <= ST_PROCESO;
			end if;
			
			when others => 
			next_state <= ST_ESPERA;
		
		end case;
	end process;

end architecture;

	
			
			
	
	