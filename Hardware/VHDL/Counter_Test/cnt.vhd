						----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:08:16 02/16/2018 
-- Design Name: 
-- Module Name:    cnt - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cnt is
    Port ( CLOCK : in  STD_LOGIC;
           DIRECTION : in  STD_LOGIC;
           COUNT_OUT : out  STD_LOGIC_VECTOR (3 downto 0));
end cnt;

architecture Behavioral of cnt is
signal count_int : std_logic_vector (3 downto 0) := "0000";

begin
process (CLOCK) 
begin
   if CLOCK='1' and CLOCK'event then
      if DIRECTION='1' then   
         count_int <= count_int + 1;
      else
         count_int <= count_int - 1;
      end if;
   end if;
end process;
COUNT_OUT <= count_int;
end Behavioral;

