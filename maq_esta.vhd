library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity maq_esta is
    Port (
        clk               : in  STD_LOGIC;
        rst               : in  STD_LOGIC;
        pir_in            : in  STD_LOGIC; 
        proceso_fin : in  STD_LOGIC; 
        rom_en            : out STD_LOGIC;
        ram_we            : out STD_LOGIC; 
        addr_inc          : out STD_LOGIC   
    );
end maq_esta;

architecture contro of maq_esta is

    type state_type is (ST_ESPERA, ST_PROCESO);
    signal current_state, next_state : state_type;
	 
	begin

