----------------------------------------------------------------------------------
-- Company: eptecon 
-- Engineer: E. Prizkau
-- 
-- Create Date:    09:57:37 11/23/2018 
-- Design Name:    Line Image Sensor Controller (LISC)  	
-- Module Name:    ad9826_readout - Behavioral 
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


entity AD9826_readout is
    generic(teiler : integer := 24;
				teiler1 : integer := 24);
	Port(   
		CLOCK   :   in std_logic;   --main clock
      RESET	:   in std_logic;   --external reset

        ---Measurement Controls---
        --START   :   in std_logic;
      READY   :   out std_logic;
      ISR_CLK :   out std_logic; --BE CAREFUL! OUT -> CHANGE TO IN!

        ---ADC Controls---
      CDSCLK2 :   out std_logic;
      CDSCLK1 :   out std_logic;
      ADCCLK  :   out std_logic;

        ---ADC data in---
      ADCDATA :   in std_logic_vector(7 DOWNTO 0); 

        ---ADC data out---
      DATA_R	:   out std_logic_vector(15 downto 0) --pixel data Red
      --DATA_G : out std_logic_vector(15 downto 0); --pixel data Green
      --DATA_B : out std_logic_vector(15 downto 0); --pixel data Blue
	);
end AD9826_readout;

architecture Behavioral of AD9826_readout is

   signal sig_isr_clk  :   std_logic;  --temporary clk

   signal sig_cdsclk1  :   std_logic;  --cdsclk1
   signal sig_cdsclk2  :   std_logic;  --cdsclk2
   signal sig_adcclk   :   std_logic;  --adcclk

   signal sig_counter	:	natural range 0 to (teiler-1);   --
    
	signal sig_counter_pos	:	natural range 0 to (teiler-1); -- positive edges counter for readout clock
	signal sig_counter_neg	:	natural range 0 to (teiler-1); -- negative edges counter for readout clock
	 
	signal sig_counter_reset	:	std_logic;  --
    
   signal sig_data_hi	:	std_logic; --
   signal sig_data_lo	:	std_logic; --
   signal sig_reset	:   std_logic; --
	 
	signal sig_hilf1	:   bit;
	signal sig_hilf2	:   bit;
	
   signal sig_data_r_high	:   std_logic_vector(7 downto 0);   --data high byte
   signal sig_data_r_low   :   std_logic_vector(7 downto 0);   --data low byte
	 
	signal sig_data_ready   :   std_logic;  --data ready

----------------------------------------------------------------------------------
begin

COUNTER_CONTROLLER : process(CLOCK, RESET)
    begin 
	 if RESET = '1' then
		sig_reset <= '1';
	 elsif rising_edge(CLOCK) then
		if sig_isr_clk = '0' then
			sig_reset <= '0';
		else
			sig_reset <= '1';
		end if;
	end if;		
end process;

----------------------------------------------------------------------------------
    	 
	ADC_CONTROL_TIMER : process(CLOCK, RESET, sig_reset, sig_counter)
    begin 
		if RESET = '1' then
			sig_counter_reset <= '1';
			sig_cdsclk1 <= '0';
			sig_cdsclk2 <= '0';
			sig_adcclk <= '0';
			sig_data_hi <= '0';
			sig_data_lo <= '0';
			sig_data_ready <= '0';
		
		else
		
		--elsif rising_edge(CLOCK) then
		
			if sig_reset = '0' then
				sig_counter_reset <= '0';
			end if;
			
			if sig_counter = (((teiler)/2)-1) then
				sig_cdsclk1 <= '1';
			end if;
			
			if sig_counter = ((((teiler)/2)+4)-1) then
				sig_cdsclk1 <= '0';
			end if;
          
			if sig_counter = (((teiler)-2)-1) then
				sig_cdsclk2 <= '1';
			end if;
         			
			if sig_counter = (((teiler)/6)-1) then
				sig_cdsclk2 <= '0';
			end if;
          
			if sig_counter = ((teiler)-1) then
				sig_adcclk <= '1';	
			end if;
          
			if sig_counter = ((((teiler)/2)-2)-1) then
				sig_adcclk <= '0';
			end if;
          
			if sig_counter = ((((teiler)/2)-4)-1) then
				sig_data_hi <= '1';
			else
				sig_data_hi <= '0';
			end if;
			           
			if sig_counter = ((((teiler)/2)-2)-1) then
				sig_data_lo <= '1';
			else
				sig_data_lo <= '0';
			end if;
			
			if sig_counter = (((teiler)/12)-1) then
				sig_data_ready <= '1';
			end if;
			
			if sig_counter = (((teiler)/6)-1) then
				sig_data_ready <= '0';
			end if;
			
			if sig_counter = ((teiler)-1) then
				sig_counter_reset <= '1';
			end if;
		
		end if;	
		
	 end process;
	 
----------------------------------------------------------------------------------
	 
	CDSCLK1 <= sig_cdsclk1;
   CDSCLK2 <= sig_cdsclk2;
   ADCCLK <= sig_adcclk; 
	READY <= sig_data_ready;

----------------------------------------------------------------------------------
	 
	CNT_POS : process(CLOCK, RESET)		--positive edges counter and negative edges counter should become an own package at the end
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
	 
	CNT_NEG : process(CLOCK, RESET)
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

    DATA : process(CLOCK, RESET)
    begin
		if RESET = '1' then
			sig_data_r_high <= (others => '0');
			sig_data_r_low <= (others => '0');
		elsif rising_edge(CLOCK) then
			if sig_data_lo = '1' then
				sig_data_r_low <= ADCDATA;
			end if;
			if sig_data_hi = '1' then
				sig_data_r_high <= ADCDATA;
			end if;
		end if;
    end process;

----------------------------------------------------------------------------------

   DATA_R(15 downto 8) <= sig_data_r_high;
   DATA_R(7 downto 0)  <= sig_data_r_low;

----------------------------------------------------------------------------------

CONTROL_COUNTER : process(CLOCK, sig_counter_reset)
    begin
		if sig_counter_reset = '1' then
			sig_counter <= 0;
		elsif rising_edge(CLOCK) then	--count falling  edge of clk
			sig_counter <= sig_counter + 1;	--
		end if;
    end process;

----------------------------------------------------------------------------------
  
 
end Behavioral;




