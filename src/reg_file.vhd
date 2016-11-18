----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 08:06:23 PM
-- Design Name: 
-- Module Name: Reg_File - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity Reg_File is
  port (clk         : in  std_logic;
        addr_opa    : in  std_logic_vector (4 downto 0);
        addr_opb    : in  std_logic_vector (4 downto 0);
        w_e_regfile : in  std_logic;
        data_opa    : out std_logic_vector (7 downto 0);
        data_opb    : out std_logic_vector (7 downto 0);
        data_in     : in  std_logic_vector (7 downto 0));
end Reg_File;

-- ACHTUNG!!! So einfach wird das mit dem Registerfile am Ende nicht.
-- hier muss noch einiges bzgl. Load/Store gemacht werden...


architecture Behavioral of Reg_File is
  type regs is array(31 downto 0) of std_logic_vector(7 downto 0);
  signal register_speicher : regs;
  signal sreg_speicher     : std_logic_vector(7 downto 0);
begin

  -- purpose: einfacher Schreibprozess für rudimentaeres Registerfile
  -- type   : sequential
  -- inputs : clk, addr_opa, w_e_regfile, data_res
  -- outputs: register_speicher
  registerfile : process (clk)
  begin  -- process registerfile
    if clk'event and clk = '1' then     -- rising clock edge
      if w_e_regfile = '1' then
        register_speicher(to_integer(unsigned(addr_opa))) <= data_in;
      end if;
    end if;
  end process registerfile;

  -- nebenlaeufiges Lesen der Registerspeicher
  data_opa <= register_speicher(to_integer(unsigned(addr_opa)));
  data_opb <= register_speicher(to_integer(unsigned(addr_opb)));

end Behavioral;
