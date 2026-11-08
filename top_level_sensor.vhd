LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.package_sensor.ALL;

ENTITY top_level_sensor is 
	port(
		clk	: in STD_LOGIC;
		reset : in STD_LOGIC;
		pin_GPIO : IN STD_LOGIC;
		
		led_sensor: out STD_LOGIC;
		hex_7seg1 : out STD_LOGIC_VECTOR(6 downto 0);
		hex_7seg2 : out STD_LOGIC_VECTOR(6 downto 0);
		hex_7seg3 : out STD_LOGIC_VECTOR(6 downto 0);
		hex_7seg4 : out STD_LOGIC_VECTOR(6 downto 0)
		);
		
architecture logica of top_level_sensor is

	signal cable_presencia : STD_LOGIC;
	signal cable_bandera_fsm : STD_LOGIC;
	signal cable_bus_rom : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
	signal cable_bus_ram : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
	signal cable_direccion : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
	signal mostrar_disp  : STD_LOGIC;

begin 

		U1_CONTROLADOR_PIR : controlador_HCSR501
			port map(
				clk => clk,
				reset => reset
				pin_GPIO => pin_GPIO
				led_out => led_sensor
				presencia => cable_presencia
			);
			
		U2_UNIDAD_DE_CONTROL_FSM : maq_esta
			port map(
				 clk => clk
				 rst => reset
				 pir_in => cable_presencia
				 proceso_fin => cable_bandera_fsm
				 rom_en => cable_bus_rom
				 ram_en => cable_bus_ram
				 senal => )
				 
		U3_MEMORIA_ROM : rom_sync
			generic map(
					DATA_WIDTH => 8,
					ADDR_WIDTH => 4
					)
					
			port map(
					clk => clk,
					addr => cable_direccion,
					data_out => cable_bus_rom
					);
					
		U4_MEMORIA_RAM : ram_sincrona
			generic map(
					DATA_WIDTH => 8,
					ADDR_WIDTH => 4,
					RDW_MODE => "READ_FIRST"
					)
					
			PORT MAP(
					clk => clk,
					rd_en => reset,
					wr_en => cable_bandera_fsm,
					addr => cable_direccion,
					data_in => cable_bus_rom,
					data_out => cable_bus_ram
					);
					
		process(mostrar_disp, cable_bus_ram)
			begin
				if mostrar_disp = '1' then
					hex_7seg1 <= hex_7seg(cable_bus_ram(3 downto 0));
					hex_7seg2 <= hex_7seg(cable_bus_ram(7 downto 4));
					hex_7seg3 <= hex_7seg(cable_bus_ram(11 downto 8));
					hex_7seg4 <= hex_7seg(cable_bus_ram(15 downto 12));
				else
					hex_7seg1 <= "1111111";
					hex_7seg2 <= "1111111";
					hex_7seg3 <= "1111111";
					hex_7seg4 <= "1111111";
				end if;
		end process;
end architecture;