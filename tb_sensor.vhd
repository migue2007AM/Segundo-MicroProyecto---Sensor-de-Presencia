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

    -- Señales de observación
    signal led_clk    : STD_LOGIC;
    signal led_sensor : STD_LOGIC;
    signal hex_7seg1  : STD_LOGIC_VECTOR(6 downto 0);
    signal hex_7seg2  : STD_LOGIC_VECTOR(6 downto 0);
    signal hex_7seg3  : STD_LOGIC_VECTOR(6 downto 0);
    signal hex_7seg4  : STD_LOGIC_VECTOR(6 downto 0);

    -- Período del reloj principal (20 ns -> 50 MHz)
    constant CLK_PERIOD : time := 20 ns;
	 
	 Begin

	 -- Instanciación del Top-Level sobrescribiendo el divisor de frecuencia
    uut: ENTITY work.top_level_sensor
        PORT MAP (
            clk        => clk,
            reset      => reset,
            pin_GPIO   => pin_GPIO,
            led_clk    => led_clk,
            led_sensor => led_sensor,
            hex_7seg1  => hex_7seg1,
            hex_7seg2  => hex_7seg2,
            hex_7seg3  => hex_7seg3,
            hex_7seg4  => hex_7seg4
        );
		  
    -- Proceso generador de reloj de 50 MHz
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR CLK_PERIOD / 2;
        clk <= '1';
        WAIT FOR CLK_PERIOD / 2;
    END PROCESS;

    -- Proceso de estímulos rápidos para la simulación
    stim_proc: PROCESS
    BEGIN
        -- 1. Reset inicial del sistema
        reset <= '1';
        pin_GPIO <= '0';
        WAIT FOR 100 ns;
        
        -- Liberar el reset
        reset <= '0';
        WAIT FOR 200 ns;

        -- 2. Simular primera detección del sensor PIR (Pin en alto)
        pin_GPIO <= '1';
        WAIT FOR 200 ns; 
        pin_GPIO <= '0';
        
        -- Esperar a que la FSM y las memorias completen el ciclo
        WAIT FOR 600 ns;

        -- 3. Simular segunda detección del sensor PIR
        pin_GPIO <= '1';
        WAIT FOR 200 ns;
        pin_GPIO <= '0';
        
        WAIT FOR 600 ns;

        -- Fin de la prueba controlada
        WAIT;
    END PROCESS;

END ARCHITECTURE;