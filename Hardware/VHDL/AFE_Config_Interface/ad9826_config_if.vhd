----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:49:02 02/07/2018 
-- Design Name: 
-- Module Name:    ad9826_if - Behavioral 
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ad9826_if is
	--Universal Port 
	Port(CLOCK:in std_logic;--24MHz 
		  RESET: in std_logic;
		  
		  
		 --Serial Inerface 
		 SDATA:out std_logic; 
		  SCLK:out std_logic; 
		 SLOAD:out std_logic); 


end ad9826_if;

architecture Behavioral of ad9826_if is
	signal sig_state:std_logic;--0 set 1 operate 
	signal sig_spi_tmp:std_logic_vector(15 downto 0);--reg for serial out 
	signal sig_spi_data:std_logic_vector(15 downto 0);--prepare data for SPI_TMP 
	signal sig_spi_clk:std_logic;--sclk 
	signal sig_spi_load:std_logic;--sload 
	signal sig_spi_num:std_logic_vector(3 downto 0);
	

begin
  		 --AFE Config Inerface 
  P_SCLK:process(CLOCK, RESET)--produce sclk 
  variable CNT:std_logic_vector(3 downto 0); 
  begin 
	if RESET = '1' then
		sig_spi_clk<='0';
		CNT := "0000";
	elsif falling_edge(CLOCK) then
		if sig_state='1' then	  
	    if CNT="1011" THEN --  12-1=11 
		  CNT:="0000"; 
		  sig_spi_clk<=not sig_spi_clk; 
	    else 
		  CNT:=CNT+1; 
	    end if; 
	   end if; 
	end if;
  end process P_SCLK; 
  
  SCLK<=sig_spi_clk;-- WHEN SPI_LOAD='0' ELSE '0'; 
  
  P_SLOAD:process(sig_spi_clk, RESET)--produce sload 
  variable CNT:std_logic_vector(3 downto 0); 
  begin
  if RESET = '1' then
	sig_spi_load<='0';
	CNT := "0000";
  elsif falling_edge(sig_spi_clk) then 
	  if sig_spi_load='1' then 
		sig_spi_load<='0'; 
	  else 
		if CNT="0000" THEN 
		  sig_spi_load<='1'; 
		end if; 
	    CNT:=CNT+1; 
	  end if;  
  end if;
  end process P_SLOAD; 
  
  SLOAD<=sig_spi_load; 
  sig_spi_data(15)<='0'; 
  sig_spi_data(11 downto 9)<="000"; 
  
  P_LDATA:process(sig_spi_load, RESET)--LOAD DATA for next cycle 
  begin 
  if RESET = '1' then
		sig_state <= '1';
		sig_spi_num(3 downto 0) <= "0000";
  elsif rising_edge(sig_spi_load) then 
		sig_spi_data(14 downto 12)<=sig_spi_num(2 DOWNTO 0); 
      sig_spi_num<=sig_spi_num+1; 
			if sig_spi_num="1000" then 
				sig_state<='0'; 
			end if; 
  end if;	 
  end process P_LDATA; 
  
  with sig_spi_num select 
     sig_spi_data(8 downto 0)<=	"000100000" when "0001", 
											"011000000" when "0010", 
											"000000000" when "0011", 
											"000000000" when "0100", 
											"000000000" when "0101", 
											"000000000" when "0110", 
											"000000000" when "0111", 
											"000000000" when others; 

  P_SDATA:process(sig_spi_clk, RESET)--SET DATA 
  BEGIN 
  if RESET = '1' then
	sig_spi_tmp(15 downto 0)<="0000000000000000";
  elsif falling_edge(sig_spi_clk) then
      if sig_spi_load='1' then 
			sig_spi_tmp<=sig_spi_data; 
      else 
			sig_spi_tmp(15 downto 1)<=sig_spi_tmp(14 downto 0); 
      end if;  
  end if;
  end process P_SDATA; 
  
  SDATA<=sig_spi_tmp(15); 
  
--------------------------------------------------------------------------------------------------  
  


end Behavioral;

