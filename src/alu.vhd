----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 09:44:25 AM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library work;
use work.pkg_processor.all;


entity ALU is
    Port ( OPCODE : in STD_LOGIC_VECTOR (3 downto 0);
           OPA : in STD_LOGIC_VECTOR (7 downto 0);
           OPB : in STD_LOGIC_VECTOR (7 downto 0);
           RES : out STD_LOGIC_VECTOR (7 downto 0);
           Status : out STD_LOGIC_VECTOR (7 downto 0));
end ALU;

architecture Behavioral of ALU is
  signal z : std_logic := '0';            -- Zero Flag
  signal c : std_logic := '0';            -- Carry Flag
  signal v : std_logic := '0';            -- Overflow Flag
  signal n : std_logic := '0';            -- negative flag
  signal s : std_logic := '0';            -- sign flag
  signal erg : std_logic_vector(7 downto 0);  -- Zwischenergebnis
begin
  -- purpose: Kern-ALU zur Berechnung des Datenausganges
  -- type   : combinational
  -- inputs : OPA, OPB, OPCODE
  -- outputs: erg
  kern_ALU: process (OPA, OPB, OPCODE)
  begin  -- process kern_ALU
    erg <= "00000000";                  -- verhindert Latches
    case OPCODE is
      when op_add => 
        erg <= std_logic_vector(unsigned(OPA) + unsigned(OPB));
      when op_sub =>
        erg <= std_logic_vector(unsigned(OPA) - unsigned(OPB));
      when op_or =>
        erg <= OPA or OPB;
      when op_and =>
        erg <= OPA and OPB;
      when op_dec =>
        erg <= std_logic_vector(unsigned(OPA) - 1);
      when op_inc =>
        erg <= std_logic_vector(unsigned(OPA) + 1);        
      when others => null;
    end case;
  end process kern_ALU;

  -- purpose: berechnet die Statusflags
  -- type   : combinational
  -- inputs : OPA, OPB, OPCODE, erg
  -- outputs: z, c, v, n
  Berechnung_SREG: process (OPA, OPB, OPCODE, erg)
  begin  -- process Berechnung_SREG
    z<=not (erg(7) or erg(6) or erg(5) or erg(4) or erg(3) or erg(2) or erg(1) or erg(0));
    n <= erg(7);

    c <= '0';                           -- um Latches zu verhindern
    v <= '0';
    
    case OPCODE is
      -- TODO vérifier les signaux
      -- ADD
      when op_add =>
        c<=(OPA(7) AND OPB(7)) OR (OPB(7) AND (not erg(7))) OR ((not erg(7)) AND OPA(7));
        v<=(OPA(7) AND OPB(7) AND (not erg(7))) OR ((not OPA(7)) and (not OPB(7)) and  erg(7));
        
      -- SUB
      when op_sub =>
        c<=(not OPA(7) and OPB(7)) or (OPB(7) and erg(7)) or (not OPA(7) and erg(7));
        v<=(OPA(7) and not OPB(7) and not erg(7)) or (not OPA(7) and OPB(7) and erg(7));

      -- OR
      when op_or =>
        c<='0';
        v<='0';

      when op_dec =>
        v <=(not OPA(7) and OPA(6) and OPA(5) and OPA(4) and OPA(3) and OPA(2) and OPA(1) and OPA(0));
      when op_inc =>
        v<=(OPA(7) and (not OPA(6)) and (not OPA(5)) and (not OPA(4)) and (not OPA(3)) and (not OPA(2)) and (not OPA(2)) and (not OPA(1)) and (not OPA(0)));

      -- alle anderen Operationen...

      when others => null;
    end case;
    
  end process Berechnung_SREG;  

  s <= v xor n;
  RES <= erg;
  Status <= '0' & '0' & '0' & s & v & n & z & c;
  
end Behavioral;
