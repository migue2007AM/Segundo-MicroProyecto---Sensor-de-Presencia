library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY controlador_HCSR501 is
	port(clk : in STD_LOGIC;
		  reset : in STD_LOGIC;
		  pin_GPIO : in STD_LOGIC;
		  
--		  led_out : out STD_LOGIC;
		  presencia : out STD_LOGIC
		  );
	
END ENTITY;

ARCHITECTURE rtl of controlador_HCSR501 is

	constant F_CLK_HZ : integer := 50000000;
	constant FRECUENCIA_SENSOR : integer := 10;
	
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
  
  --signal sync_1, sync_2 : std_logic := '0';
  
  --constant TIEMPO_ANTIRREBOTE : integer := 5_000_000; -- 100 ms de estabilidad requerida
  --signal cnt_debounce    : integer range 0 to TIEMPO_ANTIRREBOTE := 0;
  --signal pir_estable     : std_logic := '0';     -- Esta es la señal limpia que usará todo el sistema
  
begin

	process(clk, reset)
	begin 
		if reset = '1' then
			cnt <= 0;
			tick_i <= '0';
		elsif rising_edge(clk) then
			if cnt = (cnt_max - 1) then
				cnt_max <= 0;
				tick_i <= '1';
			else
				cnt <= cnt + 1;
				tick_i <= '0';
			end if;
		end if;
	end process;
	
	tick <= tick_i;

--	process(clk_50, reset_n)
--	begin
--		 if reset_n = '0' then
--			sync_1 <= '0';
--			sync_2 <= '0';
--		 elsif rising_edge(clk_50) then
--			sync_1 <= pin_GPI0;
--			sync_2 <= sync_1;
--		 end if;
--	end process;
	
--	process(clk_50, reset_n)
--	  begin
--		 if reset_n = '0' then
--			cnt_debounce <= 0;
--			pir_estable  <= '0';
--		 elsif rising_edge(clk_50) then
--			if sync_2 = '1' then
--			  if cnt_debounce = DEBOUNCE_TIME then
--				 pir_estable <= '1'; -- Se mantiene estable en 1 después de 100ms
--			  else
--				 cnt_debounce <= cnt_debounce + 1;
--			  end if;
--			else
--			  cnt_debounce <= 0;    -- Cualquier micro-corte a 0 reinicia la cuenta
--			  pir_estable  <= '0';
--			end if;
--		 end if;		
--  end process;

--	process(clk_50, reset_n)
--  begin
--    if reset_n = '0' then
--      cnt_div  <= 0;
--      tick_led <= '0';
--    elsif rising_edge(clk_50) then
--      if pir_estable = '1' then  
--        if cnt_div = FREQ_DIV then
--          cnt_div  <= 0;
--          tick_led <= not tick_led;
--        else
--          cnt_div <= cnt_div + 1;
--        end if;
--      else
--        cnt_div  <= 0;
--        tick_led <= '0';
--      end if;
--    end if;
--  end process;
  
--  led_out <= tick_led;
	
	process(clk, reset)
	begin
		if reset = '0' then
			state <= IDLE;
		elsif rising_edge(clk) then
			state <= state_next;
		end if;
	end process;
	
	process(state, tick)
	begin
	state_next <= state;
	
		case state is
			when IDLE =>
			
				if tick = '1' and pin_GPIO = '1' then
					state_next <= READ_SENSOR;
				end if;
				
			when READ_SENSOR =>
				state_next <= WAIT_ST;
				
			when WAIT_ST =>
				
				if pin_GPIO = '0' then
					state_next <= IDLE;
				end if;
			when others =>
				state_next <= IDLE;
		 end case;
   end process;
	
	process(clk, reset)
	begin
		if reset = '1' then
			led_reg <= '0';
		elsif rising_edge(clk) then
			if state = READ_SENSOR then
				led_reg <= pin_GPIO;
			else 
				led_reg <= led_reg;
			end if;
	   end if;
	end process;
	
--	led_out <= led_reg;
	presencia <= led_reg;
	
end architecture;
  