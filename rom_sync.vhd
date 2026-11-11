library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_sync is
  generic (
    DATA_WIDTH : positive := 16;
    ADDR_WIDTH : positive := 4
  );
  port (
    clk      : in  std_logic;
    addr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    
	 data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity;

architecture rtl of rom_sync is
  type rom_type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  
  -- Funciona para guardar de forma permanente los datos en la rom
  constant mem : rom_type := (
    0 => x"AA55", 1 => x"F00F", 2 => x"1234", 3 => x"ABCD",
    4 => x"FFFF", 5 => x"0000", 6 => x"F0F0", 7 => x"FE23",
	 8 => x"AA50", 9 => x"6A10", 10 => x"2610", 11 => x"0505",
	 12 => x"5555", 13 => x"AD26", 14 => x"C05A", 15 => x"E1DA"
    --others => (others => '0')
  );
  signal q_reg : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal addr_i: integer range 0 to 2**ADDR_WIDTH-1;

  attribute romstyle : string;
  attribute romstyle of mem : constant is "M9K";    -- Obliga a Quartus a usar la memoria fisica del chip de la FPGA
begin
  addr_i <= to_integer(unsigned(addr));
  
  -- En este proceso simplemente hace la accion de leer la direccion que se le da y dar en la salida el contenido que hay en esa direccion 
  process(clk)
  begin
    if rising_edge(clk) then
      q_reg <= mem(addr_i);
    end if;
  end process;

  data_out <= q_reg;
end architecture;