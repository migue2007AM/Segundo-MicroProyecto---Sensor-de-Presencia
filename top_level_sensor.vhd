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
		
		bcd_7seg1 : out STD_LOGIC_VECTOR(6 downto 0);
		bcd_7seg2 : out STD_LOGIC_VECTOR(6 downto 0);
		bcd_7seg3 : out STD_LOGIC_VECTOR(6 downto 0);
		bcd_7seg4 : out STD_LOGIC_VECTOR(6 downto 0)
		);
		
architecture logica of top_level_sensor is

	SIGNAL cable_pir_event    : STD_LOGIC        // Transporta el pulso de 1 ciclo del sensor a la FSM
   SIGNAL cable_bandera_fsm  : STD_LOGIC        // Transporta la orden de escritura (Enable) de la FSM a la RAM
   SIGNAL cable_bus_rom      : BUS_DATOS  // Transporta el código hexadecimal desde la ROM a la RAM
   SIGNAL cable_bus_ram      : BUS_DATOS  // Transporta el código guardado desde la RAM al display
   SIGNAL cable_direccion    : BUS_DIR    // Transporta el puntero actual de la RAM hacia la ROM