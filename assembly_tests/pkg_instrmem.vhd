library ieee;
use ieee.std_logic_1164.all;
-- ---------------------------------------------------------------------------------
-- Memory initialisation package
-- ---------------------------------------------------------------------------------
package pkg_instrmem is

	type t_instrMem   is array(0 to 512-1) of std_logic_vector(15 downto 0);
	constant PROGMEM : t_instrMem := (
		"1110000000000000",
		"1110000000010000",
		"1001010100000011",
		"1001010100000011",
		"1001010100010011",
		"0000111100000001",
		"0001101100000001",
		
		others => (others => '0')
	);

end package pkg_instrmem;
