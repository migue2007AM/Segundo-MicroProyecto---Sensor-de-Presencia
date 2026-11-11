library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_sincrona is
  generic (
    DATA_WIDTH : positive := 16;           -- Fija el tamaño de cada dato en 16 bits
    ADDR_WIDTH : positive := 4;            -- 4 posiciones de memoria
    RDW_MODE   : string   := "READ_FIRST"  -- "READ_FIRST" | "WRITE_FIRST" | "NO_CHANGE"
  );
  port (
    clk      : in  std_logic;
    rd_en    : in  std_logic := '1';
    wr_en    : in  std_logic;
    addr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);     -- Direccion que se busca en la memoria
    data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);     -- datos de entrada
    
	 data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)      -- entrega de datos guardados
  );
end entity;

architecture rtl of ram_sincrona is
  type ram_type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);  -- Creacion de la matriz de memoria (16 filas de 16 cables)
  signal mem      : ram_type;
  signal q_reg    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal addr_i   : integer range 0 to 2**ADDR_WIDTH-1;

  attribute ramstyle : string;
  attribute ramstyle of mem : signal is "M9K";      -- Obliga a Quartus usar la memoria fisica dentro del chip de la FPGA
begin
  addr_i <= to_integer(unsigned(addr));

  process(clk)
  begin
    if rising_edge(clk) then
      if wr_en = '1' then
        mem(addr_i) <= data_in;           -- Agarra el dato de entrada y lo guarda en el lugar indicado en la memoria
        
		  -- Si esta en modo escribir primero, guarda el dato de entrada al mismo tiempo que saca el dato viejo
		  if RDW_MODE = "WRITE_FIRST" then
          q_reg <= data_in;
        
		  -- Si esta en modo leer primero, primero saca el dato viejo y despues guarda el dato nuevo 
		  elsif RDW_MODE = "READ_FIRST" then
          q_reg <= mem(addr_i);
        else
          null; -- NO_CHANGE
        end if;
      else
        
		  -- Si en vez de la orden de escritura esta activada la orden de lectura simplemente copia el contenido del espacio de la ram indicado y se manda a la salida
		  if rd_en = '1' then
          q_reg <= mem(addr_i);
        end if;
      end if;
    end if;
  end process;

  data_out <= q_reg;
end architecture;