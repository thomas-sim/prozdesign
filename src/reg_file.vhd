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
        reset       : in  std_logic;
        addr_opa    : in  std_logic_vector (4 downto 0);
        addr_opb    : in  std_logic_vector (4 downto 0);
        w_e_regfile : in  std_logic;
        data_opa    : out std_logic_vector (7 downto 0);
        data_opb    : out std_logic_vector (7 downto 0);
        index_z     : out std_logic_vector (15 downto 0);
        data_in     : in  std_logic_vector (7 downto 0));
end Reg_File;

-- ACHTUNG!!! So einfach wird das mit dem Registerfile am Ende nicht.
-- hier muss noch einiges bzgl. Load/Store gemacht werden...


architecture Behavioral of Reg_File is
  type regs is array(29 downto 0) of std_logic_vector(7 downto 0);
  type index is array(1 downto 0) of std_logic_vector(7 downto 0);

  signal register_speicher    : regs                         := (others => (others => '0'));
  signal en_register_speicher : std_logic;
  signal sreg_speicher        : std_logic_vector(7 downto 0) := (others => '0');
  signal addr_register        : std_logic_vector(4 downto 0);

  signal index_z_speicher    : index := (others => (others => '0'));
  signal en_index_z_speicher : std_logic;

begin

  en_register_speicher <= '1' when to_integer(unsigned(addr_opa)) < 30 else
                          '0';
  
  en_index_z_speicher <= '1' when to_integer(unsigned(addr_opa)) >= 30 else
                          '0';

  addr_register <= addr_opa when to_integer(unsigned(addr_opa)) < 30 else
                   std_logic_vector(unsigned(addr_opa) - 30);
  
  registerfile : process (clk)
  begin  -- process registerfile
    if clk'event and clk = '1' then     -- rising clock edge
      if en_register_speicher = '1' then
        if w_e_regfile = '1' then
          register_speicher(to_integer(unsigned(addr_register))) <= data_in;
        end if;
      end if;
    end if;
  end process registerfile;

  index_z_process : process (clk)
  begin  -- process registerfile
    if clk'event and clk = '1' then     -- rising clock edge
      if en_index_z_speicher = '1' then
        if w_e_regfile = '1' then
          index_z_speicher(to_integer(unsigned(addr_register))) <= data_in;
        end if;
      end if;
    end if;
  end process index_z_process;

  -- nebenlaeufiges Lesen der Registerspeicher
  data_opa <= register_speicher(to_integer(unsigned(addr_opa))) when to_integer(unsigned(addr_opa)) < 30 else
              index_z_speicher(to_integer(unsigned(addr_opa)) - 30);
  data_opb <= register_speicher(to_integer(unsigned(addr_opb))) when to_integer(unsigned(addr_opb)) < 30 else
              index_z_speicher(to_integer(unsigned(addr_opb)) - 30);
  index_z  <= index_z_speicher(1) & index_z_speicher(0);

end Behavioral;
