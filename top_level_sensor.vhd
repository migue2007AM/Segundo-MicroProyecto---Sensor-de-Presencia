LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.package_sensor.ALL;

ENTITY top_level_sensor is 
	port(
		clk	: in STD_LOGIC;			 -- Reloj de la FPGA (50MHz)
		reset : in STD_LOGIC;
		pin_GPIO : IN STD_LOGIC;
		
		led_clk   : out STD_LOGIC;
		led_sensor: out STD_LOGIC;     -- Led para verificar que el sistema si detecto la presencia por medio del sensor
		
		-- Salidas de la conversion de hexadecimales a 7 segmentos en direccion a los displays de la FPGA
		hex_7seg1 : out STD_LOGIC_VECTOR(6 downto 0);
		hex_7seg2 : out STD_LOGIC_VECTOR(6 downto 0);
		hex_7seg3 : out STD_LOGIC_VECTOR(6 downto 0);
		hex_7seg4 : out STD_LOGIC_VECTOR(6 downto 0)
		);
end entity;

architecture logica of top_level_sensor is

	signal cable_presencia : STD_LOGIC;   -- Señal encargada de conectar la señal "limpia" del sensor hacia la maquina de estados
	signal cable_bandera_fsm : STD_LOGIC;
	
	-- Por estas dos señales viajaran los codigos hexadecimales
	signal cable_bus_rom : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
	signal cable_bus_ram : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
	
	signal cable_direccion : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0); -- Guia que le dice a las memorias que posicion leer/escribir
	signal tick_1s_sig  : STD_LOGIC;
	signal cable_proceso_fin : STD_LOGIC;
	signal cable_senal : STD_LOGIC;
	signal retardo_escritura : STD_LOGIC_VECTOR(1 downto 0) := "00";
	signal cable_wr_en_limpio : STD_LOGIC;

begin 

		U5_DIVISOR_FRECUENCIA : divisor_frecuencia
			generic map(
						FININ => 50000000,
						
						FOUT => 1
						)
			PORT MAP(
					clk_in => clk,
					reset => reset,
					
					clk_out => tick_1s_sig
					);

		U1_CONTROLADOR_PIR : controlador_HCSR501
			port map(
				clk => clk,
				reset => reset,
				pin_GPIO => pin_GPIO,
				
				presencia => cable_presencia
			);
			
		U2_UNIDAD_DE_CONTROL_FSM : maq_esta
			port map(
				 clk => clk,
				 rst => reset,
				 pir_in => cable_presencia,
				 proceso_fin => cable_proceso_fin,
				 
				 rom_en => open,
				 ram_en => cable_bandera_fsm,
				 senal => cable_senal,
				 tick_1s => tick_1s_sig,
				 rom_addr => cable_direccion
				 );
				 
		U3_MEMORIA_ROM : rom_sync
			generic map(
					DATA_WIDTH => 16,
					ADDR_WIDTH => 4
					)
					
			port map(
					clk => clk,
					addr => cable_direccion,
					
					data_out => cable_bus_rom
					);
					
		U4_MEMORIA_RAM : ram_sincrona
			generic map(
				DATA_WIDTH => 16,
				ADDR_WIDTH => 4,
				RDW_MODE   => "WRITE_FIRST" -- Actualiza la salida inmediatamente al escribir
								)
			PORT MAP(
					clk => clk,
					rd_en => '1',
					wr_en => cable_wr_en_limpio,
					addr => cable_direccion,
					data_in => cable_bus_rom,
					
					data_out => cable_bus_ram
					);
		
		-- Este proceso lo que hace es que une el bit 0 del vector retardo_escritura con el valor de cable_bandera_fsm de ese momento, lo que sirve para darle un tiempo a la rom y a la ram para que hagan su trabajo de forma ordenada 
		process(clk)
		begin
			if rising_edge(clk) then
				retardo_escritura <= retardo_escritura(0) & cable_bandera_fsm;
			end if;
		end process;
		
		-- Esta señal nos sirve para habilitar de forma limpia a la RAM ya que si retardo_escritura es igual a 01 significa la rom ya leyo la orden, ahora es luz verde para que la ram siga con la parte de su trabajo (leer/escribir)
		cable_wr_en_limpio <= '1' when retardo_escritura(0) = '1' and retardo_escritura(1) = '0' else '0';
		
		-- Cuando el bit 1 del vector retardo_escritura vale 1 significa que su vector completo esta en "11", esto da a entender que el proceso de lectura/escritura de la rom y la ram ya termino
		cable_proceso_fin <= retardo_escritura(1);
			
	
		-- Este proceso simplemente usa la funcion hex_7seg del package para mostrar en los displays de la FPGA 
		process(cable_presencia, cable_bus_ram)
			begin
				
				-- Si hay presencia lo que se hace es tomar de la RAM actual los 16 bits y partilos en grupos de 4 para poder mostrar esos codigos hexadecimales)
				if cable_presencia = '1' then
					hex_7seg1 <= hex_7seg(cable_bus_ram(3 downto 0));
					hex_7seg2 <= hex_7seg(cable_bus_ram(7 downto 4));
					hex_7seg3 <= hex_7seg(cable_bus_ram(11 downto 8));
					hex_7seg4 <= hex_7seg(cable_bus_ram(15 downto 12));
				
				-- Sino los displays se mantendran apagados
				else
					hex_7seg1 <= "1111111";
					hex_7seg2 <= "1111111";
					hex_7seg3 <= "1111111";
					hex_7seg4 <= "1111111";
				end if;
		end process;
		led_sensor <= pin_GPIO;  -- led para ver que si esta llegando la señal de presencia del sensor
		led_clk <= tick_1s_sig;	 -- led que muestrar la frecuencia de 1hz
		
end logica;