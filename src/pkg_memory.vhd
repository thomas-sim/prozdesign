library ieee;
use ieee.std_logic_1164.all;

package pkg_memory is

  constant addr_first_memory : std_logic_vector(15 downto 0) := x"0060";
  constant addr_last_memory : std_logic_vector(15 downto 0) := x"045F";
  constant id_memory : std_logic_vector(3 downto 0) := "0001"; 
end pkg_memory;
