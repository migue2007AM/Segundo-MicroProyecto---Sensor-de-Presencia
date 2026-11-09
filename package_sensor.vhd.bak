LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

package package_sensor is

	COMPONENT rom_sync IS
		GENERIC (
		 DATA_WIDTH : positive := 8;
		 ADDR_WIDTH : positive := 4
		);
		  PORT (
			 clk      : in  std_logic;
			 addr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
			 data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
		  );
		  
	END COMPONENT;
	
	COMPONENT ram_sincrona IS
		PORT(
			DATA_WIDTH : positive := 8;
		ADDR_WIDTH : positive := 4;
		RDW_MODE   : string   := "READ_FIRST"
		);
	END COMPONENT;
	
	COMPONENT BCD_7SEG IS
		PORT(
			A: in STD_LOGIC_VECTOR(3 downto 0);       -- La entrada de 4 bits que el codigo convertira a 7 segmentos para poder plasmarlo en el display
			B: out STD_LOGIC_VECTOR(6 downto 0)
		  );
		 
	END COMPONENT;

	COMPONENT maq_esta IS
		PORT(
			clk               : in  STD_LOGIC;
			rst               : in  STD_LOGIC;
			pir_in            : in  STD_LOGIC; -- '1' hay presencia, '0' no hay
			proceso_fin 		  : in  STD_LOGIC; -- senal que indica si el bloque externo terminó
			rom_en            : out STD_LOGIC; -- Habilitador de lectura para ROM
			ram_en            : out STD_LOGIC; -- Habilitador de escritura para RAM 
			senal			     : out STD_LOGIC  -- Aviso que la máquina de estados envía
			);
	 END COMPONENT;
	 
	 COMPONENT divisor_frecuencia IS
		GENERIC(
			FININ : INTEGER := 50000000; 		-- Frecuencia del oscilador de la FPGA (50 MHz)
			FOUT  : INTEGER := 1         		-- Frecuencia deseada para el conteo (1 Hz)
			)
			
		PORT(
			clk_in  : IN STD_LOGIC;      		-- Entra el reloj rápido de 50 MHz de la FPGA
			reset   : IN STD_LOGIC;      		-- Reset del reloj, si se activa se vuelve a 0 el sistema
			clk_out : OUT STD_LOGIC      		-- Sale la señal dividida de 1 Hz
			);
			
		END COMPONENT;
		
END package;