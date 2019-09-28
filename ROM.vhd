library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rom is
	port (address	:	in std_logic_vector(3 downto 0);
		  data		:	out std_logic_vector(31 downto 0));
end entity;

architecture RTL of rom is
begin

process(address)
    begin
      case address is
        when "0000" => data <= "10000101010100010101010101000001";
        when "0001" => data <= "01000101000000010101000000000000";
        when "0010" => data <= "01000101010100010101000101010110";
        when "0011" => data <= "01000101010100010000000101000101";
        when "0100" => data <= "01010101010100010101000101000101";
        when "0101" => data <= "01010101010100010101000101000101";
        when "0110" => data <= "00000000010100010101000101000000";
        when "0111" => data <= "01010101010100010101000101000101";
        when "1000" => data <= "01010101010100010101010101000101";
        when "1001" => data <= "01010000000000010101010101000101";
        when "1010" => data <= "11010101010100010000000000000001";
        when "1011" => data <= "01010101010101010101010101010101";
        when others => data <= "00000000000000000000000000000000";
    end case;
 end process;   
 
 end RTL;

