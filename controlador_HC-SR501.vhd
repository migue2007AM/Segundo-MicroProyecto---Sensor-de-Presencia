library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY pir_controler is
	port(clk : in STD_LOGIC;
		  reset : in STD_LOGIC;
		  pin_GPI0 : in STD_LOGIC;
		  
		  led_out : out STD_LOGIC;
		  presencia : out STD_LOGIC
		  );

END ENTITY;

ARCHITECTURE presencia of pir_controler is

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
  
  type estados is (IDLE, READ_SENSOR, WAIT);
  signal state, state_next;
  
  signal led_reg : STD_LOGIC := '0';
  signal tick : STD_LOGIC;
  
begin

	process(clk,reset)
	begin
		if reset = '0' then
			cnt <= 0;
			tick_i <= '0';
		elsif rising_edge(clk) then
			if cnt = (CNT_MAX_SLOW - 1) then
				cnt <= 0;
				tick_i <= '1';
			else
				cnt <= cnt + 1;
				tick_i <= '0';
			end if;
		end if;
	end process;
	
	tick <= tick_1
	
	process(clk, reset)
	begin
		if reset = '0' then
			state <= IDLE;
		elsif rising_edge(clk) then
			state <= state_next;
		end if;
	end process;
	
	process (state, tick)
	begin
	state_next <= state;
	
		case state is
			when IDLE =>
			
				if tick = '1' then
					state_next <= READ_SENSOR;
				end if;
				
			when READ_SENSOR =>
				state_next <= WAIT;
				
			when WAIT =>
				state_next <= IDLE;
				
			when others =>
				state_next <= IDLE;
		 end case;
   end process;
	
	


	
  