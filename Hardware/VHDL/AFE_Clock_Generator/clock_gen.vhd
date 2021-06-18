----------------------------------------------------------------------------------
-- Company: eptecon 
-- Engineer: E. Prizkau
-- 
-- Create Date:    09:57:37 11/23/2018 
-- Design Name:    Line Image Sensor Controller (LISC) 	
-- Module Name:    clock_generator - Behavioral 
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


entity clock_generator is
    generic(teiler : integer := 24;					-- maximale Auslesezeit der Zeile (für ILX554:2MHz) 
				teiler1: integer := 2;					---bestimmt die Periode des ISR_CLK (1: 0,5µs, 2: 1µs, 4: 2µs, 8: 4µs)---
				min_clk_start_delay: integer := 6;  -- feste 3µs für alle ISR_CLK Perioden (lt. ILX554 Datenblatt)----
				min_rog_start_delay:	integer := 10; -- feste 5µs für alle ISR_CLK Perioden (lt. ILX554 Datenblatt)----
				integration_delay: integer := 20;		-- variable Integrationsvezögerung: min. 0, max. 65535... ---
				min_clk_stop_delay: integer := 6; -- feste 3µs für alle ISR_CLK Perioden (lt. ILX554 Datenblatt)----
				pixel_readout_factor: integer := 200; ---2090/ISR_CLK (2090 Pixel Auslesezyklen)---
				min_eos_delay: integer := 6 -- feste 3µs für alle ISR_CLK Perioden (guard time)---
				);
	Port(   
		CLOCK   :   in std_logic;   --main clock
      RESET	  :   in std_logic;   --external reset

        ---Readout Controls---
      START   :   in std_logic;
      READY   :   out std_logic;
      ISR_CLK :   out std_logic;
		ROG	  :	out std_logic	
	);
end clock_generator;

architecture Behavioral of clock_generator is

	signal sig_counter_pos	:	natural range 0 to (teiler-1); -- positive edges counter 
	signal sig_counter_neg	:	natural range 0 to (teiler-1); -- negative edges counter 
	
	signal sig_isr_cnt_neg	:	natural range 0 to (teiler1-1);	-- 
	
	signal sig_readout_counter	:	natural range 0 to 65536;   --
	signal sig_int_counter	:	natural range 0 to 65536;   --
	
	signal sig_readout_cnt_reset	:	std_logic;  --
	signal sig_int_cnt_reset	:	std_logic;  --
    
	signal sig_start	:	 std_logic; --
	signal sig_start1	:	 std_logic; --
	signal sig_start2	:	 std_logic; --
	signal sig_start_hilf	:	 std_logic; --
	
	signal sig_ready	:	 std_logic; --
	signal sig_isr_clk  :   std_logic;  --
	signal sig_isr_clk_out  :   std_logic;  --
	signal sig_rog  :   std_logic;  --
	
	signal sig_isr_clk_start  :   std_logic;  --
	
	signal sig_hilf1	:   bit;
	signal sig_hilf2	:   bit;
	signal sig_hilf3	:   std_logic;  
	--signal sig_hilf4	:   std_logic;  
	signal sig_hilf5	:   bit;
	 
----------------------------------------------------------------------------------

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
	
	CNT_ISR_CLK_NEG : process(sig_isr_clk, RESET)
	begin
		if RESET = '1' then
			sig_isr_cnt_neg <= 0;
		elsif falling_edge(sig_isr_clk) then
			if sig_isr_cnt_neg < (teiler1-1) then
				sig_isr_cnt_neg <= sig_isr_cnt_neg + 1;
			else
				sig_isr_cnt_neg <= 0;
			end if;
		end if;	
	end process;
	
----------------------------------------------------------------------------------

	sig_hilf1 <= '1' when(sig_counter_pos < ((teiler-0)/2)) else '0';		
	sig_hilf2 <= '1' when(sig_counter_neg < ((teiler-1)/2)) else '0';
	sig_isr_clk <= '1' when((sig_hilf1 = '1') or (sig_hilf2 = '1')) else '0';
	
	sig_hilf3 <= '1' when(sig_isr_cnt_neg < (teiler1-0)/2) else '0';
	sig_isr_clk_out <= sig_isr_clk when(teiler1 = 1) else sig_hilf3;
	
	ISR_CLK <= sig_isr_clk_start when(sig_hilf5 = '0') else sig_isr_clk_out;  ----------------------image sensor readout clock (ISR_CLK)
	
----------------------------------------------------------------------------------
	
	READOUT_TIMER : process(CLOCK, sig_isr_clk, RESET)		-- 
		begin
		
		if RESET = '1' then
			sig_isr_clk_start <= '0';	
			sig_readout_cnt_reset <= '1';
			sig_int_cnt_reset <= '1';
			sig_rog <= '1';	
			sig_ready <= '0';	
			sig_hilf5 <= '0';
			sig_start <= '1';
			
		else	
			
			if falling_edge(sig_isr_clk) then					---- 
				if sig_start = '1' then
					sig_isr_clk_start <= '1';
					sig_readout_cnt_reset <= '0';
					sig_int_cnt_reset <= '1';
				end if;
				if sig_readout_counter = ((min_clk_start_delay)-1) then
					sig_rog <= '0';
					sig_start <= '0';
				end if;
				if sig_readout_counter = (((min_clk_start_delay)+(min_rog_start_delay))-1) then
					sig_rog <= '1';
				end if;
				if sig_readout_counter = (((min_clk_start_delay)+(min_rog_start_delay)+(min_clk_stop_delay))-1) then  --hier wird noch ein zus. delay für ISR_CLK < 1MHz erzeugt (max. 1,5µs), ->wg. synchronisation auf sig_cisr_clock
					sig_hilf5 <= '1';
				end if;
				if sig_readout_counter = (((min_clk_start_delay)+(min_rog_start_delay)+(min_clk_stop_delay)+(pixel_readout_factor*teiler1)+((teiler1-1)/2))-1) then
					sig_ready <= '1';
					sig_hilf5 <= '0';
					sig_isr_clk_start <= '0';
				end if;
				if sig_readout_counter = (((min_clk_start_delay)+(min_rog_start_delay)+(min_clk_stop_delay)+(pixel_readout_factor*teiler1)+((teiler1-1)/2)+(min_eos_delay))-1) then
					sig_ready <= '0';
					sig_readout_cnt_reset <= '1';
					sig_int_cnt_reset <= '0';
				end if;
				if sig_int_counter = (integration_delay-1) then
					sig_start <= '1';
				end if;
			end if;			
			
		end if;
		
	end process;
	
----------------------------------------------------------------------------------

	ROG <= sig_rog;
	READY <= sig_ready;
	
----------------------------------------------------------------------------------

	SYNC : process(sig_isr_clk, RESET)
	begin
		if RESET ='1' then
			sig_start1 <= '0';
			sig_start2 <= '0';
		elsif falling_edge(sig_isr_clk) then
			sig_start1 <= START;
			sig_start2 <= sig_start1;
			sig_start_hilf <= sig_start1 and not sig_start2;
		end if;
	end process;

----------------------------------------------------------------------------------

	--sig_start <= sig_start_hilf;

----------------------------------------------------------------------------------

    READOUT_COUNTER : process(sig_isr_clk, sig_readout_cnt_reset)
    begin
		if sig_readout_cnt_reset = '1' then
			sig_readout_counter <= 0;
		elsif falling_edge(sig_isr_clk) then	--count falling  edge of isr_clk
			sig_readout_counter <= sig_readout_counter + 1;	--
		end if;
    end process;

----------------------------------------------------------------------------------

    INTEGRATION_COUNTER : process(sig_isr_clk, sig_int_cnt_reset)
    begin
		if sig_int_cnt_reset = '1' then
			sig_int_counter <= 0;
		elsif falling_edge(sig_isr_clk) then	--count falling  edge of isr_clk
			sig_int_counter <= sig_int_counter + 1;	--
		end if;
    end process;	
	
----------------------------------------------------------------------------------
  

end Behavioral;




