-------------------------------------------------------------------------------
-- Title      : decoder
-- Project    : 
-------------------------------------------------------------------------------
-- File       : decoder.vhd
-- Author     : Burkart Voss  <bvoss@Troubadix>
-- Company    : 
-- Created    : 2015-06-23
-- Last update: 2016-11-24
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-06-23  1.0      bvoss   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.pkg_processor.all;

-------------------------------------------------------------------------------

entity decoder is
  port (
    Instr              : in  std_logic_vector(15 downto 0);  -- Eingang vom Programmspeicher
    sreg               : in  std_logic_vector(7 downto 0);  -- sreg
    addr_opa           : out std_logic_vector(4 downto 0);  -- Adresse von 1. Operand
    addr_opb           : out std_logic_vector(4 downto 0);  -- Adresse von 2. Operand
    OPCODE             : out std_logic_vector(3 downto 0);  -- Opcode für ALU
    w_e_decoder_memory : out std_logic;
    w_e_regfile        : out std_logic;  -- write enable for Registerfile
    w_e_SREG           : out std_logic_vector(7 downto 0);  -- einzeln Write_enables für SREG - Bits
    offset_pc          : out std_logic_vector(11 downto 0);  -- the offset of the pc

    -- hier kommen noch die ganzen Steuersignale der Multiplexer...
    regfile_datain_selector : out std_logic_vector(1 downto 0);  -- Selecteingang für Mux vor RF
    alu_sel_immediate       : out std_logic  -- selecteingang für mux vor ALU

    );
end decoder;

architecture Behavioral of decoder is

begin  -- Behavioral

  -- purpose: Decodierprozess
  -- type   : combinational
  -- inputs : Instr
  -- outputs: addr_opa, addr_opb, OPCODE, w_e_regfile, w_e_SREG, ...
  dec_mux : process (Instr)
    variable index_branches : integer := 0;
  begin  -- process dec_mux


    -- ACHTUNG!!!
    -- So einfach wie hier unten ist das Ganze nicht! Es soll nur den Anfang erleichtern!
    -- Etwas muss man hier schon nachdenken und sich die Operationen genau ansehen...

    -- Vorzuweisung der Signale, um Latches zu verhindern
    addr_opa                <= "00000";
    addr_opb                <= "00000";
    OPCODE                  <= op_NOP;
    w_e_regfile             <= '0';
    w_e_SREG                <= "00000000";
    regfile_datain_selector <= regfile_data_in_alu;
    alu_sel_immediate       <= '0';
    offset_pc               <= "000000000000";
    w_e_decoder_memory      <= '0';

    index_branches := to_integer(unsigned(Instr(2 downto 0)));

    case Instr(15 downto 10) is  -- instructions that are coded on the first 6 bytes
      -- NOP doesn't need to be implemented : it's the default behaviour
      -- ADD
      when "000011" =>
        addr_opa    <= Instr(8 downto 4);
        addr_opb    <= Instr(9) & Instr (3 downto 0);
        OPCODE      <= op_add;
        w_e_regfile <= '1';
        w_e_SREG    <= "00111111";
      -- CP : basically SUB but without register write enable
      when "000101" =>
        addr_opa <= Instr(8 downto 4);
        addr_opb <= Instr(9) & Instr (3 downto 0);
        OPCODE   <= op_sub;
        w_e_SREG <= "00111111";
      -- SUB
      when "000110" =>
        addr_opa    <= Instr(8 downto 4);
        addr_opb    <= Instr(9) & Instr (3 downto 0);
        OPCODE      <= op_sub;
        w_e_regfile <= '1';
        w_e_SREG    <= "00111111";
      -- OR
      when "001010" =>
        addr_opa    <= Instr(8 downto 4);
        addr_opb    <= Instr(9) & Instr (3 downto 0);
        OPCODE      <= op_or;
        w_e_regfile <= '1';
        w_e_SREG    <= "00011110";
      -- AND
      when "001000" =>
        addr_opa    <= Instr(8 downto 4);
        addr_opb    <= Instr(9) & Instr (3 downto 0);
        OPCODE      <= op_and;
        w_e_regfile <= '1';
        w_e_SREG    <= "00011110";
      -- XOR
      when "001001" =>
        addr_opa    <= Instr(8 downto 4);
        addr_opb    <= Instr(9) & Instr (3 downto 0);
        OPCODE      <= op_xor;
        w_e_regfile <= '1';
        w_e_SREG    <= "00011110";
      -- MOV
      when "001011" =>
        addr_opa    <= Instr(8 downto 4);
        addr_opb    <= Instr(9) & Instr (3 downto 0);
        w_e_regfile <= '1';
        regfile_datain_selector <= regfile_data_in_datab;
      -- BRBS
      when "111100" =>
        if sreg(to_integer(unsigned(Instr(2 downto 0)))) = '1' then
          offset_pc <= std_logic_vector(resize(signed(Instr(9 downto 3)), offset_pc'length));
        end if;
      -- BRBC
      when "111101" =>
        if sreg(to_integer(unsigned(Instr(2 downto 0)))) = '0' then
          offset_pc <= std_logic_vector(resize(signed(Instr(9 downto 3)), offset_pc'length));
        end if;
      when others =>
        case Instr(15 downto 12) is  -- instructions that are coded on the first
          -- 4 bytes
          -- LDI
          when "1110" =>
            addr_opa                <= '1' & Instr(7 downto 4);
            w_e_regfile             <= '1';
            w_e_SREG                <= "00000000";
            regfile_datain_selector <= regfile_data_in_instruction;
          -- SUBI
          when "0101" =>
            addr_opa          <= '1' & Instr(7 downto 4);
            OPCODE            <= op_sub;
            w_e_regfile       <= '1';
            w_e_SREG          <= "00111111";
            alu_sel_immediate <= '1';
          -- ORI
          when "0110" =>
            addr_opa          <= '1' & Instr(7 downto 4);
            OPCODE            <= op_or;
            w_e_regfile       <= '1';
            w_e_SREG          <= "00011110";
            alu_sel_immediate <= '1';
          -- ANDI
          when "0111" =>
            addr_opa          <= '1' & Instr(7 downto 4);
            OPCODE            <= op_and;
            w_e_regfile       <= '1';
            w_e_SREG          <= "00011110";
            alu_sel_immediate <= '1';
          -- RJMP
          when "1100" =>
            offset_pc <= Instr(11 downto 0);
          -- RCALL
          when "1101"=>
            null;
          when others =>
            case Instr(15 downto 9) is  -- instructions that are coded on the
              -- first 7 bytes
              -- DEC and INC
              -- todo com, asr
              when "1001010" =>
                case Instr(3 downto 0) is
                  when "1010" =>        -- DEC
                    addr_opa    <= Instr(8 downto 4);
                    OPCODE      <= op_dec;
                    w_e_regfile <= '1';
                    w_e_SREG    <= "00011110";
                  when "0011" =>        -- INC
                    addr_opa    <= Instr(8 downto 4);
                    OPCODE      <= op_inc;
                    w_e_regfile <= '1';
                    w_e_SREG    <= "00011110";
                  when "0110" =>        -- LSR
                    addr_opa    <= Instr(8 downto 4);
                    OPCODE      <= op_lsr;
                    w_e_regfile <= '1';
                    w_e_SREG    <= "00011111";
                  when others =>
                    null;               -- Ici, com asr 
                end case;
              -- LD Z
              when "1000000" =>
                addr_opa                <= Instr(8 downto 4);
                regfile_datain_selector <= regfile_data_in_memory;
                w_e_regfile             <= '1';
              -- ST Z
              when "1000001" =>
                addr_opa           <= Instr(8 downto 4);
                w_e_decoder_memory <= '1';
              when others =>
                null;
            end case;
        end case;
    end case;
  end process dec_mux;

end Behavioral;
