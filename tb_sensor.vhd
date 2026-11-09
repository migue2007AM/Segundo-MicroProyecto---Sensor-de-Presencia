LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.package_sensor.ALL;

ENTITY tb_sensor is
END ENTITY;

	ARCHITECTURE sim OF tb_sensor is

    -- Señales de estímulo
    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '1';
    signal pin_GPIO : STD_LOGIC := '0';

    
