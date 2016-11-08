library ieee;
use ieee.std_logic_1164.all;
-- ---------------------------------------------------------------------------------
-- Memory initialisation package
-- ---------------------------------------------------------------------------------
package pkg_instrmem is

	type t_instrMem   is array(0 to 512-1) of std_logic_vector(15 downto 0);
	constant PROGMEM : t_instrMem := (
		"1001010000010011",
		"1001010000010011",
		"1001010000100011",
		"0000110000010010",
		"0001100000010010",
		
		others => (others => '0')
	);

end package pkg_instrmem;
