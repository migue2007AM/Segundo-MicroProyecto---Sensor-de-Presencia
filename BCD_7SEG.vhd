library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BCD_7SEG is
	port(A: in STD_LOGIC_VECTOR(3 downto 0);       -- La entrada de 4 bits que el codigo convertira a 7 segmentos para poder plasmarlo en el display
		  B: out STD_LOGIC_VECTOR(6 downto 0));     -- Esta es la salida que se conecta al display 7 Segmentos, como son 7 Segmentos se coloca de tipo vector de 6 a 0 (podria ser más comodo de 0 a 6 para comodidad de asignacion de pines pero no cambia el funcionamiento del codigo)
end entity;

architecture arqdeco of BCD_7SEG is
	begin
		process(A)
			begin
			-- A cada entrada binaria del 0 al 9 se le asigna su correspondiente valor en 7 Segmentos (Como los displays de la FPGA son de catodo comun entonces es 0 para iluminar LED, 1 para apagar LED, además de recordar que cada segmentos es abcdefg pero como la salida esta de 6 a 0 los pines se asignan al revez 'gfedcba')
			case A is
		   when "0000" => B <= "0000001";
			when "0001" => B <= "1001111";
			when "0010" => B <= "0010010";
			when "0011" => B <= "0000110";
			when "0100" => B <= "1001100";
			when "0101" => B <= "0100100";
			when "0110" => B <= "0100000";
			when "0111" => B <= "0001110";
			when "1000" => B <= "0000000";
			when "1001" => B <= "0000100";
			when others => B <= "1111111";
			end case;
		end process;
end arqdeco;