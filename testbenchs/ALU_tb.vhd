-------------------------------------------------------------------------------
-- Title      : Testbench for design "ALU"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ALU_tb.vhd
-- Author     : Burkart Voss  <bvoss@Troubadix>
-- Company    : 
-- Created    : 2015-06-23
-- Last update: 2016-11-05
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-06-23  1.0      bvoss	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.pkg_processor.all;

-------------------------------------------------------------------------------

entity ALU_tb is

end ALU_tb;

-------------------------------------------------------------------------------

architecture testbench of ALU_tb is

  component ALU
    port (
      OPCODE : in  STD_LOGIC_VECTOR (3 downto 0);
      OPA    : in  STD_LOGIC_VECTOR (7 downto 0);
      OPB    : in  STD_LOGIC_VECTOR (7 downto 0);
      RES    : out STD_LOGIC_VECTOR (7 downto 0);
      Status : out STD_LOGIC_VECTOR (7 downto 0));
  end component;

  -- component ports
  signal OPCODE : STD_LOGIC_VECTOR (3 downto 0);
  signal OPA    : STD_LOGIC_VECTOR (7 downto 0);
  signal OPB    : STD_LOGIC_VECTOR (7 downto 0);
  signal RES    : STD_LOGIC_VECTOR (7 downto 0);
  signal Status : STD_LOGIC_VECTOR (7 downto 0);

  -- clock
  signal Clk : std_logic := '1';

begin  -- testbench

  -- component instantiation
  DUT: ALU
    port map (
      OPCODE => OPCODE,
      OPA    => OPA,
      OPB    => OPB,
      RES    => RES,
      Status => Status);


  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    OPCODE <= op_add;   -- Add
    OPA <= "00000100";
    OPB <= "00000011";
    wait for 100ns;
    OPCODE <= op_sub;   -- Sub
    wait for 100ns;
    OPCODE <= op_or;   -- OR
    wait for 100ns;
    OPCODE <= op_and;
    wait for 100ns;
    OPCODE <= op_dec;
    wait for 100ns;
    OPCODE <= op_inc;
    wait for 100ns;
    
  end process WaveGen_Proc;

  

end testbench;

-------------------------------------------------------------------------------

configuration ALU_tb_testbench_cfg of ALU_tb is
  for testbench
  end for;
end ALU_tb_testbench_cfg;

-------------------------------------------------------------------------------
