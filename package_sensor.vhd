LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

package package_sensor is
	constant DATA_WIDTH : positive := 16;
	constant ADDR_WIDTH : positive := 4;
	
	function hex_7seg(hex : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR;
	
	COMPONENT rom_sync IS
		GENERIC (
		 DATA_WIDTH : positive := 16;
		 ADDR_WIDTH : positive := 4
		);
		  PORT (
			 clk      : in  std_logic;
			 addr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
			 data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
		  );
		  
	END COMPONENT;
	
	COMPONENT ram_sincrona IS
		GENERIC(
			DATA_WIDTH : positive := 16;
			 ADDR_WIDTH : positive := 4;
			 RDW_MODE   : string   := "READ_FIRST"  -- "READ_FIRST" | "WRITE_FIRST" | "NO_CHANGE"
			 );
		
		PORT(
			clk      : in  std_logic;
			 rd_en    : in  std_logic := '1';
			 wr_en    : in  std_logic;
			 addr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
			 data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			 data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
		);
	END COMPONENT;

	COMPONENT maq_esta IS
		PORT(
			clk               : in  STD_LOGIC;
			rst               : in  STD_LOGIC;
			pir_in            : in  STD_LOGIC; -- '1' hay presencia, '0' no hay
			proceso_fin 		  : in  STD_LOGIC; -- senal que indica si el bloque externo terminÃ³
			rom_en            : out STD_LOGIC; -- Habilitador de lectura para ROM
			ram_en            : out STD_LOGIC; -- Habilitador de escritura para RAM 
			senal			     : out STD_LOGIC;  -- Aviso que la mÃ¡quina de estados envÃ­a
			tick_1s           : in  STD_LOGIC;
			rom_addr          : out STD_LOGIC_VECTOR(3 downto 0) --DirecciÃ³n aleatoria para la ROM (0 a 5)
			);
	 END COMPONENT;
	 
	 COMPONENT divisor_frecuencia IS
		GENERIC(
			FININ : INTEGER := 50000000; 		-- Frecuencia del oscilador de la FPGA (50 MHz)
			FOUT  : INTEGER := 1         		-- Frecuencia deseada para el conteo (1 Hz)
			);
			
		PORT(
			clk_in  : IN STD_LOGIC;      		-- Entra el reloj rápido de 50 MHz de la FPGA
			reset   : IN STD_LOGIC;      		-- Reset del reloj, si se activa se vuelve a 0 el sistema
			clk_out : OUT STD_LOGIC      		-- Sale la señal dividida de 1 Hz
			);
			
		END COMPONENT;
		
	 COMPONENT controlador_HCSR501 IS
		 PORT(
			clk : in STD_LOGIC;
			reset : in STD_LOGIC;
			pin_GPIO : in STD_LOGIC;
		  
--			led_out : out STD_LOGIC;
			presencia : out STD_LOGIC);
			
		END COMPONENT;
		
END package_sensor;

package body package_sensor IS
	
	function hex_7seg(hex : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
		variable B : STD_LOGIC_VECTOR(6 downto 0);
	begin
		case hex is
			when x"0" => B := "1000000"; 
			when x"1" => B := "1111001";
			when x"2" => B := "0100100";
			when x"3" => B := "0110000";
			when x"4" => B := "0011001";
			when x"5" => B := "0010010";
			when x"6" => B := "0000010";
			when x"7" => B := "1111000";
			when x"8" => B := "0000000";
			when x"9" => B := "0010000";
			when x"A" => B := "0001000";
			when x"B" => B := "0000011";
			when x"C" => B := "1000110";
			when x"D" => B := "0100001";
			when x"E" => B := "0000110";
			when x"F" => B := "0001110";
			when others => B := "1111111";
		end case;
		return B;
  end function;
end package body;
	