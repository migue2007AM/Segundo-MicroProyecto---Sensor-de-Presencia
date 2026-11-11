library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY controlador_HCSR501 is
	port(clk       : in STD_LOGIC;     -- Frecuencia de la FPGA
		  reset     : in STD_LOGIC;     -- Reset '1' activo, '0' inactivo
		  pin_GPIO  : in STD_LOGIC;     -- Entrada de señal que envia el sensor al detectar movimiento
		  
		  presencia : out STD_LOGIC     -- Salida que da luz verde a la maquina de estados cuando se detecta movimiento
		  );
	
END ENTITY;

ARCHITECTURE rtl of controlador_HCSR501 is

	constant F_CLK_HZ : integer := 250000;          -- Frecuencia de base (se bajo de 50MHz por razones de optimizacion)     
	constant FRECUENCIA_SENSOR : integer := 10;     -- Frecuencia a la que el sensor va a trabajar (10Hz)
	
   function cycles_for(freq_hz : integer) return integer is
    variable c : integer;
	  begin
		 if freq_hz < 1 then
			c := 1;                                        -- Evita división por cero
		 else
			c := F_CLK_HZ / freq_hz;                       -- Número de ciclos por periodo
			if c < 1 then
			  c := 1;                                      -- Piso mínimo
			end if;
		 end if;
		 return c;
   end function;
  
  constant CNT_MAX_SLOW : integer := cycles_for(FRECUENCIA_SENSOR); -- Cuenta para modo lento
  constant CNT_MAX_FAST : integer := cycles_for(F_CLK_HZ); -- Cuenta para modo rápido
  
  signal cnt       : integer range 0 to integer'high;   -- Contador de ciclos
  signal tick_i    : std_logic := '0';                   -- Señal interna de tick
  signal cnt_max   : integer := CNT_MAX_SLOW;            -- Selección dinámica del límite
  
  type estados is (IDLE, READ_SENSOR, WAIT_ST);
  signal state, state_next : estados := IDLE;
  
  signal led_reg : STD_LOGIC := '0';
  signal tick : STD_LOGIC;
  
  signal sinc_1 : STD_LOGIC := '0';
  signal sinc_2 : STD_LOGIC := '0';
  
begin

	-- Proceso Sincronizador (Anti-Metaestabilidad)
	process(clk, reset)
	begin
		if reset = '1' then
			sinc_1 <= '0';
			sinc_2 <= '0';
		
		-- Esto alinea la señal que viene del sensor con el clk ya que la señal del pin_GPIO es asincrona y como clk es sincrona con este bloque se consigue una sincronizacion entre las dos señales
		elsif rising_edge(clk) then
			sinc_1 <= pin_GPIO;
			sinc_2 <= sinc_1;
		end if;
	end process;
	
	-- Este es el divisor de frecuencia del sensor
	process(clk, reset)
	begin 
		if reset = '1' then
			cnt <= 0;
			tick_i <= '0';
		
		-- Aqui es donde se genera el tick cuando se ha llegado a la frecuencia que se le puso al sensor - 1
		elsif rising_edge(clk) then
			if cnt = (cnt_max - 1) then
				cnt <= 0;
				tick_i <= '1';
			else
				cnt <= cnt + 1;
				tick_i <= '0';
			end if;
		end if;
	end process;
	
	tick <= tick_i;  -- El tick que se genera sea '0' o '1' se manda al tick general que se maneja en todo el sistema
	
	-- Aqui simplemente es un proceso que da la orden de que se pase a un estado siguiente mientras reset no sea '1'
	process(clk, reset)
	begin
		if reset = '1' then
			state <= IDLE;
		elsif rising_edge(clk) then
			state <= state_next;
		end if;
	end process;
	
	-- Maquina de estados de 3 estaods (IDLE (Reposo), READ_SENSOR (Lectura del sensor), WAIT_ST (Espera))
	process(state, tick, sinc_2)
	begin
	state_next <= state;
	
		case state is
			
			-- Permanecera en este estado mientras no detecte movimiento
			when IDLE => 
			
				-- Si detecta el movimiento ya pasa al siguiente estado (READ_SENSOR)
				if sinc_2 = '1' then
					state_next <= READ_SENSOR;
				end if;
				
			-- En el estado READ_SENSOR va directamente a WAIT_ST, aunque parezca redundante este estado ayuda a que el circuito no sea tan sensible a los ruidos
			when READ_SENSOR =>
				state_next <= WAIT_ST;
				
			when WAIT_ST =>
				
				-- Si el sensor deja de detectar movimiento (sinc_2 = '0') y el temporizador del divisor del sensor lance un pulso (tick = '1') entonces volvera a reposo (IDLE)
				if sinc_2 = '0' and tick = '1' then
					state_next <= IDLE;
				end if;
			when others =>
				state_next <= IDLE;     -- En otros casos el estado siguiente sera reposo (IDLE)
		 end case;
   end process;
	
	-- Este proceso es para el led que se enciende en '1' si le llega señal de presencia y '0' si no
	process(clk, reset)
	begin
		if reset = '1' then
			led_reg <= '0';
		elsif rising_edge(clk) then
			
			-- Si el estado actual es READ_SENSOR (o sea que llego una señal), el led tomara el valor de entrada de la señal de movimiento del sensor
			if state = READ_SENSOR then
				led_reg <= pin_GPIO;
			
			-- Si esta en reposo (IDLE) el led no se encendera
			elsif state = IDLE then
				led_reg <= '0';
			else 
				led_reg <= led_reg;    -- en otro caso el led tendra su valor anterior
			end if;
	   end if;
	end process;
	
	presencia <= led_reg;     -- el valor que tenga led_reg ira a presencia que sera el que ira al circuito y tambien el que estara en el led
	
end architecture;