-------------------------------------------------------------------------------
-- Title      : Data Memory
-- Project    : 
-------------------------------------------------------------------------------
-- File       : data_memory.vhd
-- Author     : Thomas Simatic  <thomas@simatic.org>
-- Company    : 
-- Created    : 2016-11-21
-- Last update: 2017-01-19
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
       w_e_memory : in  std_logic_vector(3 downto 0);
       data_in    : in  std_logic_vector(7 downto 0);
       addr       : in std_logic_vector (9 downto 0);
       data_out   : out std_logic_vector (7 downto 0));
end data_memory;

architecture Behavioral of data_memory is

  signal w_e : std_logic;
  constant en : std_logic := '1';

  component blockram is
    port (
      clk      : in  STD_LOGIC;
      data_in  : in  STD_LOGIC_VECTOR (7 downto 0);
      addr     : in  STD_LOGIC_VECTOR (9 downto 0);
      w_e      : in  std_logic;
      en       : in  std_logic;
      data_out : out STD_LOGIC_VECTOR (7 downto 0));
  end component blockram;

begin
  blockram_1: entity work.blockram
    port map (
      clk      => clk,
      data_in  => data_in,
      addr     => addr,
      w_e      => w_e,
      en       => en,
      data_out => data_out);

  w_e <= '1' when w_e_memory = id_memory else '0';

end Behavioral;

