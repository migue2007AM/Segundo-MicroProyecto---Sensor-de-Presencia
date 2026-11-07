library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity maq_esta is
    Port (
        clk               : in  STD_LOGIC;
        rst               : in  STD_LOGIC;
        pir_in            : in  STD_LOGIC; -- '1' hay presencia, '0' no hay
        proceso_fin : in  STD_LOGIC; 
        rom_en            : out STD_LOGIC;
        ram_en            : out STD_LOGIC; 
        señal_logica      : out STD_LOGIC   
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
   señal_logica   <= '0';
	
	