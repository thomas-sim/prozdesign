library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_memory.all;

entity decoder_memory is
  
  port (
    index_z : in std_logic_vector(15 downto 0);
    w_e_decoder_memory : in std_logic;

    memory_output_selector : out std_logic_vector (3 downto 0);
    w_e_memory : out std_logic_vector(3 downto 0);
    addr_memory : out std_logic_vector(9 downto 0)
    );

end entity decoder_memory;

architecture Behavioral of decoder_memory is
begin
  dec_memory_mux : process (index_z, w_e_decoder_memory)
    variable id_port : std_logic_vector(3 downto 0) := "0000";
  begin
    w_e_memory <= "0000";
    addr_memory <= "0000000000";
    -- id_port     := "0000";

    case index_z is
      when addr_pind =>
        id_port := id_pind;
      when addr_pinc =>
        id_port := id_pinc;
      when addr_pinb =>
        id_port := id_pinb;
      when addr_portc =>
        id_port := id_portc;
      when addr_portb =>
        id_port := id_portb;
      when addr_seg0 =>
        id_port := id_seg0;
      when addr_seg1 =>
        id_port := id_seg1;
      when addr_seg2 =>
        id_port := id_seg2;
      when addr_seg3 =>
        id_port := id_seg3;
      when others =>
        if unsigned(index_z) >= unsigned(addr_first_memory)
          and unsigned(index_z) <= unsigned(addr_last_memory) then

          addr_memory <= std_logic_vector(resize(unsigned(index_z) - unsigned(addr_first_memory),
                                                 addr_memory'length));

          id_port := id_memory;
        end if;
    end case;
    

    memory_output_selector <= id_port;

    if w_e_decoder_memory = '1' then
      w_e_memory <= id_port;
    end if;

  end process dec_memory_mux;
end Behavioral;
  
