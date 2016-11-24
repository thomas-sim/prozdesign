-------------------------------------------------------------------------------
-- Title      : Data Memory
-- Project    : 
-------------------------------------------------------------------------------
-- File       : data_memory.vhd
-- Author     : Thomas Simatic  <thomas@simatic.org>
-- Company    : 
-- Created    : 2016-11-21
-- Last update: 2016-11-24
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-11-21  1.0      thomas   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_memory.all;

entity data_memory is
  port(clk        : in  std_logic;
       reset : in std_logic;
       w_e_memory : in  std_logic_vector(3 downto 0);
       data_in    : in  std_logic_vector(7 downto 0);
       addr       : in std_logic_vector (9 downto 0);
       data_out   : out std_logic_vector (7 downto 0));
end data_memory;

architecture Behavioral of data_memory is
  type data_case is array(1023 downto 0) of std_logic_vector(7 downto 0);
  signal memory_speicher : data_case;
begin

  write_process : process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        memory_speicher <= (others => "00000000");
      else
        if w_e_memory = id_memory then
            memory_speicher(to_integer(unsigned(addr))) <= data_in;
        end if;
      end if;
    end if;
  end process write_process;

  data_out <= memory_speicher(to_integer(unsigned(addr)));

end Behavioral;

