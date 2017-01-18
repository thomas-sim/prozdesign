----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 08:45:28 PM
-- Design Name: 
-- Module Name: toplevel - Behavioral
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
use IEEE.numeric_std.all;
use work.pkg_processor.all;
use work.pkg_instrmem.all;
use work.pkg_memory.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity toplevel is
  port (
    -- global ports
    clk : in std_logic;

    -- buttons PIND
    btnEnter : in std_logic;
    btnR     : in std_logic;
    btnU     : in std_logic;
    btnD     : in std_logic;
    btnL     : in std_logic;

    -- PINC & PINB (switchs)
    sw         : in  std_logic_vector(15 downto 0);
    -- PORT C & PORT B (led)
    led        : out std_logic_vector(15 downto 0);
    -- seven segment display
    seg        : out std_logic_vector(7 downto 0);
    seg_enable : out std_logic_vector(3 downto 0)
    );
end toplevel;

architecture Behavioral of toplevel is
  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------

  signal reset : std_logic;

  -- outputs of "Program_Counter_1"
  signal Addr : std_logic_vector (8 downto 0);

  -- outputs of "prog_mem_1"
  signal Instr : std_logic_vector (15 downto 0);

  -- outputs of "decoder_1"
  signal addr_opa           : std_logic_vector(4 downto 0);
  signal addr_opb           : std_logic_vector(4 downto 0);
  signal OPCODE             : std_logic_vector(3 downto 0);
  signal w_e_regfile        : std_logic;
  signal w_e_decoder_memory : std_logic;
  signal w_e_SREG       : std_logic_vector(7 downto 0);
  signal offset_pc          : std_logic_vector(11 downto 0);

  signal regfile_datain_selector : std_logic_vector(1 downto 0);
  signal alu_sel_immediate       : std_logic;

  -- outputs of Regfile
  signal data_opa : std_logic_vector (7 downto 0);
  signal data_opb : std_logic_vector (7 downto 0);
  signal sreg     : std_logic_vector(7 downto 0);
  signal index_z  : std_logic_vector(15 downto 0);

  -- output of ALU
  signal data_res   : std_logic_vector(7 downto 0);
  signal status_alu : std_logic_vector(7 downto 0);

  -- outputs of decoder_memory
  signal w_e_memory             : std_logic_vector(3 downto 0);
  signal addr_memory            : std_logic_vector(9 downto 0);
  signal memory_output_selector : std_logic_vector(3 downto 0);

  -- outputs of data memory
  signal memory_data_out : std_logic_vector(7 downto 0);
  signal memory_output   : std_logic_vector(7 downto 0);

  -- auxiliary signals
  signal PM_data        : std_logic_vector(7 downto 0);  -- used for wiring immediate data
  signal input_alu_opb  : std_logic_vector(7 downto 0);  -- output of
                                        -- alu_sel_immediate multiplexer
  signal input_data_reg : std_logic_vector(7 downto 0);  -- output of input reg
                                                         -- multiplexer
  -- input ports
  signal output_pind    : std_logic_vector(7 downto 0);
  signal output_pinc    : std_logic_vector(7 downto 0);
  signal output_pinb    : std_logic_vector(7 downto 0);

  -- output ports
  signal portc : std_logic_vector(7 downto 0);
  signal portb : std_logic_vector(7 downto 0);

  -- segments
  signal seg0       : std_logic_vector(7 downto 0);
  signal seg1       : std_logic_vector(7 downto 0);
  signal seg2       : std_logic_vector(7 downto 0);
  signal seg3       : std_logic_vector(7 downto 0);
  signal local_seg_enable : std_logic_vector(7 downto 0);


  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component Program_Counter
    port (
      reset     : in  std_logic;
      clk       : in  std_logic;
      offset_pc : in  std_logic_vector (11 downto 0);
      Addr      : out std_logic_vector (8 downto 0));
  end component;

  component prog_mem
    port (
      Addr  : in  std_logic_vector (8 downto 0);
      Instr : out std_logic_vector (15 downto 0));
  end component;

  component data_memory is
    port (
      clk        : in  std_logic;
      reset      : in  std_logic;
      w_e_memory : in  std_logic_vector(3 downto 0);
      data_in    : in  std_logic_vector(7 downto 0);
      addr       : in  std_logic_vector (9 downto 0);
      data_out   : out std_logic_vector (7 downto 0));
  end component data_memory;

  component decoder_memory is
    port (
      index_z                : in  std_logic_vector(15 downto 0);
      w_e_decoder_memory     : in  std_logic;
      w_e_memory             : out std_logic_vector(3 downto 0);
      memory_output_selector : out std_logic_vector (3 downto 0);
      addr_memory            : out std_logic_vector(9 downto 0));
  end component decoder_memory;

  component ports is
    generic (
      id_port : std_logic_vector(3 downto 0));
    port (
      clk        : in  std_logic;
      reset      : in  std_logic;
      data_out   : out std_logic_vector (7 downto 0);
      w_e_memory : in  std_logic_vector(3 downto 0);
      data_in    : in  std_logic_vector(7 downto 0));
  end component ports;

  component decoder is
    port (
      Instr                   : in  std_logic_vector(15 downto 0);
      sreg                    : in  std_logic_vector(7 downto 0);
      addr_opa                : out std_logic_vector(4 downto 0);
      addr_opb                : out std_logic_vector(4 downto 0);
      OPCODE                  : out std_logic_vector(3 downto 0);
      w_e_decoder_memory      : out std_logic;
      w_e_regfile             : out std_logic;
      w_e_SREG                : out std_logic_vector(7 downto 0);
      offset_pc               : out std_logic_vector(11 downto 0);
      regfile_datain_selector : out std_logic_vector(1 downto 0);
      alu_sel_immediate       : out std_logic);
  end component decoder;

  component Reg_File is
    port (
      clk         : in  std_logic;
      reset       : in  std_logic;
      addr_opa    : in  std_logic_vector (4 downto 0);
      addr_opb    : in  std_logic_vector (4 downto 0);
      w_e_regfile : in  std_logic;
      data_opa    : out std_logic_vector (7 downto 0);
      data_opb    : out std_logic_vector (7 downto 0);
      index_z     : out std_logic_vector (15 downto 0);
      data_in     : in  std_logic_vector (7 downto 0));
  end component Reg_File;

  component ALU
    port (
      OPCODE : in  std_logic_vector (3 downto 0);
      OPA    : in  std_logic_vector (7 downto 0);
      OPB    : in  std_logic_vector (7 downto 0);
      RES    : out std_logic_vector (7 downto 0);
      Status : out std_logic_vector (7 downto 0));
  end component;

begin

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

  -- instance "Program_Counter_1"
  Program_Counter_1 : Program_Counter
    port map (
      reset     => reset,
      offset_pc => offset_pc,
      clk       => clk,
      Addr      => Addr);

  -- instance "prog_mem_1"
  prog_mem_1 : prog_mem
    port map (
      Addr  => Addr,
      Instr => Instr);

  -- instance "decoder_1"
  decoder_1 : decoder
    port map (
      Instr                   => Instr,
      sreg                    => sreg,
      addr_opa                => addr_opa,
      addr_opb                => addr_opb,
      OPCODE                  => OPCODE,
      offset_pc               => offset_pc,
      w_e_regfile             => w_e_regfile,
      w_e_decoder_memory      => w_e_decoder_memory,
      w_e_SREG                => w_e_SREG,
      alu_sel_immediate       => alu_sel_immediate,
      regfile_datain_selector => regfile_datain_selector);

  -- instance "Reg_File_1"

  Reg_File_1 : Reg_File
    port map (
      clk         => clk,
      reset       => reset,
      addr_opa    => addr_opa,
      addr_opb    => addr_opb,
      w_e_regfile => w_e_regfile,
      data_opa    => data_opa,
      data_opb    => data_opb,
      index_z     => index_z,
      data_in     => input_data_reg);

  -- instance "ALU_1"
  ALU_1 : ALU
    port map (
      OPCODE => OPCODE,
      OPA    => data_opa,
      OPB    => input_alu_opb,
      RES    => data_res,
      Status => status_alu);

  -- instance "decoder_memory_1"
  decoder_memory_1 : decoder_memory
    port map (
      index_z                => index_z,
      w_e_decoder_memory     => w_e_decoder_memory,
      memory_output_selector => memory_output_selector,
      w_e_memory             => w_e_memory,
      addr_memory            => addr_memory);

  -- instance "data_memory_1"
  data_memory_1 : data_memory
    port map (
      clk        => clk,
      reset      => reset,
      w_e_memory => w_e_memory,
      data_in    => data_opa,
      addr       => addr_memory,
      data_out   => memory_data_out);

  -- instances of port
  inst_portc : ports
    generic map (
      id_port => id_portc)
    port map (
      clk        => clk,
      reset      => reset,
      data_out   => portc,
      w_e_memory => w_e_memory,
      data_in    => data_opa);

  inst_portb : ports
    generic map (
      id_port => id_portb)
    port map (
      clk        => clk,
      reset      => reset,
      data_out   => portb,
      w_e_memory => w_e_memory,
      data_in    => data_opa);

  inst_seg0 : ports
    generic map (
      id_port => id_seg0)
    port map (
      clk        => clk,
      reset      => reset,
      data_out   => seg0,
      w_e_memory => w_e_memory,
      data_in    => data_opa);

  inst_seg1 : ports
    generic map (
      id_port => id_seg1)
    port map (
      clk        => clk,
      reset      => reset,
      data_out   => seg0,
      w_e_memory => w_e_memory,
      data_in    => data_opa);

  inst_seg2 : ports
    generic map (
      id_port => id_seg2)
    port map (
      clk        => clk,
      reset      => reset,
      data_out   => seg2,
      w_e_memory => w_e_memory,
      data_in    => data_opa);

  inst_seg3 : ports
    generic map (
      id_port => id_seg3)
    port map (
      clk        => clk,
      reset      => reset,
      data_out   => seg3,
      w_e_memory => w_e_memory,
      data_in    => data_opa);

  inst_seg_enable : ports
    generic map (
      id_port => id_seg_enable)
    port map (
      clk        => clk,
      reset      => reset,
      data_out   => local_seg_enable,
      w_e_memory => w_e_memory,
      data_in    => data_opa);

  -- port in definitions
  output_pind      <= "000" & btnR & btnU & btnD & btnL & btnEnter;
  output_pinc      <= sw(15 downto 8);
  output_pinb      <= sw(7 downto 0);
  -- port out definitions
  led(15 downto 8) <= portc;
  led(7 downto 0)  <= portb;

  -- TODO ici mettre la définition des segments avec l'aide du code de Mario

  PM_Data <= Instr(11 downto 8)&Instr(3 downto 0);
  reset   <= btnR and btnU and btnD and btnL and btnEnter;


  -- multiplexor for ALU data OPB in parameter
  input_alu_opb <= data_opb when alu_sel_immediate = '0'
                   else PM_Data;
  -- multiplexor for the entrance data of the register file
  -- todo changer cette merde
  input_data_reg <= PM_Data when regfile_datain_selector = regfile_data_in_instruction
                    else data_res      when regfile_datain_selector = regfile_data_in_alu
                    else data_opb      when regfile_datain_selector = regfile_data_in_datab
                    else memory_output when regfile_datain_selector = regfile_data_in_memory;

  -- memory output multiplexor
  memory_output_mux : process (memory_output_selector, memory_data_out,
                               portc, portb,
                               output_pind, output_pinc, output_pinb)
  begin
    case memory_output_selector is
      when id_memory =>
        memory_output <= memory_data_out;
      when id_pind =>
        memory_output <= output_pind;
      when id_pinc =>
        memory_output <= output_pinc;
      when id_pinb =>
        memory_output <= output_pinb;
      when id_portc =>
        memory_output <= portc;
      when id_portb =>
        memory_output <= portb;
      when others =>
        memory_output <= "00000000";
    end case;
  end process memory_output_mux;

  -- sreg updating process
  sreg_process : process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        sreg <= "00000000";
      else
        sreg <= (not(w_e_SREG) and sreg) or (w_e_SREG and status_alu);
      end if;
    end if;
  end process sreg_process;

  -- seven segment utility
  set_segs:process(clk)
    variable segen_local : std_logic_vector(3 downto 0) := "0001";
    
  begin
    if clk'event and clk = '1' then
      -- shifting segen_local to the left
      for i in 3 downto 1 loop
        segen_local(i) := segen_local(i-1);
      end loop;
      segen_local(0) := '0';
      if segen_local = "0000" then
        segen_local := "0001";
      end if;
      
      seg_enable <= not segen_local;

      --case segen_local is
      --  when "0001" => segcont_reg <= seg0;
      --  when "0010" => segcont_reg <= seg1;
      --  when "0100" => segcont_reg <= seg2;
      --  when "1000" => segcont_reg <= seg3;
      --  when others => segcont_reg <= (others => '0');
      --end case;
      
      case segen_local is
        when "0001" => seg <= not seg0;
        when "0010" => seg <= not seg1;
        when "0100" => seg <= not seg2;
        when "1000" => seg <= not seg3;
        when others => seg <= (others => '0');
      end case;

    -- segcont <= not segcont_reg;
    end if;
  end process;


end Behavioral;
