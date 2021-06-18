---------------------------------------------------------------------------------
-- Company: eptecon 
-- Engineer: E. Prizkau 
-- 
-- Create Date:    17:16:32 02/13/2018 
-- Design Name:    Line Image Sensor Controller (LISC)  
-- Module Name:    isr_clock - Behavioral 
-- Project Name:   Image Sensor Readout Elecronics	
-- Target Devices: XL95144 CPLD
-- Tool versions:  
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity isr_clock is
	generic(teiler : integer := 48					-- einstellbare Auslesezeit 
				);
	Port(   
		---Inputs---
		CLOCK   :   in std_logic;   --main clock (48MHz)
      RESET	  :   in std_logic;   --external reset
		--set_clk_puls_time :   in std_logic_vector(1 downto 0); --reserved for future use in config mode

      ---Outputs---
      ISR_CLK :   out std_logic
		);
end isr_clock;

architecture Behavioral of isr_clock is
	signal sig_counter_pos	:	natural range 0 to (teiler-1); -- positive edges counter 
	signal sig_counter_neg	:	natural range 0 to (teiler-1); -- negative edges counter

	signal sig_hilf1	:   bit;
	signal sig_hilf2	:   bit;	
	
	signal sig_isr_clk  :   std_logic;  

begin
----------------------------------------------------------------------------------
	 
	CNT_POS : process(CLOCK, RESET)		-- positive edges counter
    begin
		if RESET = '1' then
			sig_counter_pos <= 0;
		elsif rising_edge(CLOCK) then
			if sig_counter_pos < (teiler-1) then
				sig_counter_pos <= sig_counter_pos + 1;   
			else
				sig_counter_pos <= 0;	
			end if;
		end if;
    end process;
	 
	CNT_NEG : process(CLOCK, RESET)		-- negative edges counter
    begin
		if RESET = '1' then
			sig_counter_neg <= 0;
		elsif falling_edge(CLOCK) then
			if sig_counter_neg < (teiler-1) then
				sig_counter_neg <= sig_counter_neg + 1;   
			else
				sig_counter_neg <= 0;	
			end if;
		end if;
    end process;

----------------------------------------------------------------------------------

	sig_hilf1 <= '1' when(sig_counter_pos < ((teiler-0)/2)) else '0';		
	sig_hilf2 <= '1' when(sig_counter_neg < ((teiler-1)/2)) else '0';
	sig_isr_clk <= '1' when((sig_hilf1 = '1') or (sig_hilf2 = '1')) else '0';
	
	ISR_CLK <= sig_isr_clk;
	
----------------------------------------------------------------------------------

end Behavioral;

