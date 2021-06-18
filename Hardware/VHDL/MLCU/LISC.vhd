----------------------------------------------------------------------------------
-- Company: eptecon
-- Engineer: E. Prizkau
-- 
-- Create Date:    09:57:37 11/23/2018 
-- Design Name:    Line Image Sensor Controller (LISC)  	
-- Module Name:    All In One - Behavioral 
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

entity ISRD is
	generic(teiler : integer := 24;
			  teiler2: integer := 2098;
			  teiler1: integer := 1;					---bestimmt die Periode des ISR_CLK (1: 0,5µs, 2: 1µs, 4: 2µs, 8: 4µs)---
				min_clk_start_delay: integer := 6;  -- feste 3µs für alle ISR_CLK Perioden (lt. ILX554 Datenblatt)----
				min_rog_start_delay:	integer := 10; -- feste 5µs für alle ISR_CLK Perioden (lt. ILX554 Datenblatt)----
				integration_delay: integer := 20;		-- variable Integrationsvezögerung: min. 0, max. 65535... ---
				min_clk_stop_delay: integer := 6; -- feste 3µs für alle ISR_CLK Perioden (lt. ILX554 Datenblatt)----
				pixel_readout_factor: integer := 2090; ---2090/ISR_CLK (2090 Pixel Auslesezyklen)---
				min_eos_delay: integer := 6 -- feste 3µs für alle ISR_CLK Perioden (guard time)---
			  );

	Port(   
		CLOCK   :   in std_logic;   --main clock
      RESET	:   in std_logic;   --external reset
		-------------------------------------------------------------------------------
        ---Measurement Controls (µC-IF)---
      START   :   in std_logic;
		DATA_READY   :   out std_logic;
      
		PIXCLK :   out std_logic; 
		HSYNC	  :	out std_logic;	
		VSYNC	  :	out std_logic;

        ---ADC Controls---
      CDSCLK2 :   out std_logic;
      CDSCLK1 :   out std_logic;
      ADCCLK  :   out std_logic;

        ---ADC data in---
      ADCDATA :   in std_logic_vector(7 DOWNTO 0); 

        ---ADC data out---
      DATA_R	:   out std_logic_vector(7 downto 0); --pixel data Red
      --DATA_G : out std_logic_vector(15 downto 0); --pixel data Green
      --DATA_B : out std_logic_vector(15 downto 0); --pixel data Blue
		-------------------------------------------------------------------------------
	  
		 --Serial Inerface 
		 SDATA:out std_logic; 
		  SCLK:out std_logic; 
		 SLOAD:out std_logic;
		------------------------------------------------------------------------------- 
		     ---Readout Controls---
      --START   :   in std_logic;
      --READY   :   out std_logic;
      ISR_CLK :   out std_logic;
		ROG	  :	out std_logic	
	);
end ISRD;

architecture Behavioral of ISRD is
 -------signal sig_isr_clk  :   std_logic;  --temporary clk

   signal sig_cdsclk1  :   std_logic;  --cdsclk1
   signal sig_cdsclk2  :   std_logic;  --cdsclk2
   signal sig_adcclk   :   std_logic;  --adcclk

   signal sig_counter	:	natural range 0 to (teiler-1);   --
	signal sig_meas_cnt_neg  : natural range 0 to (teiler2-1);
	signal sig_meas_cnt_pos  : natural range 0 to (teiler2-1);
    
	signal sig_counter_pos	:	natural range 0 to (teiler-1); -- positive edges counter for readout clock
	signal sig_counter_neg	:	natural range 0 to (teiler-1); -- negative edges counter for readout clock
	 
	signal sig_counter_reset	:	std_logic;  --
	signal sig_meas_cnt_rst_neg	:	std_logic;  --
	signal sig_meas_cnt_rst_pos	:	std_logic;  --
    
   signal sig_data_hi	:	std_logic; --
   signal sig_data_lo	:	std_logic; --
   signal sig_reset	:   std_logic; --
	 
	--signal sig_hilf1	:   bit;
	--signal sig_hilf2	:   bit;
	
   signal sig_data_r_high	:   std_logic_vector(7 downto 0);   --data high byte
   signal sig_data_r_low   :   std_logic_vector(7 downto 0);   --data low byte
	 
	signal sig_data_ready   :   std_logic;  --data ready
	signal sig_ready   :   std_logic;
	
	--signal sig_start1   :   std_logic;
	--signal sig_start2   :   std_logic;
	--signal sig_start_hilf  :   std_logic;
	
	signal sig_trigger :   std_logic;
	signal sig_trig1   :   std_logic;
	signal sig_trig2   :   std_logic;
	signal sig_trig3   :   std_logic;
	signal sig_trig4   :   std_logic;
	
	signal sig_state:std_logic;--0 set 1 operate 
	signal sig_spi_tmp:std_logic_vector(15 downto 0);--reg for serial out 
	signal sig_spi_data:std_logic_vector(15 downto 0);--prepare data for SPI_TMP 
	signal sig_spi_clk:std_logic;--sclk 
	signal sig_spi_load:std_logic;--sload 
	signal sig_spi_num:std_logic_vector(3 downto 0);-- 
	
	signal sig_isr_cnt_neg	:	natural range 0 to (teiler1-1);	-- 
	
	signal sig_readout_counter	:	natural range 0 to 65536;   --
	signal sig_int_counter	:	natural range 0 to 65536;   --
	
	signal sig_readout_cnt_reset	:	std_logic;  --
	signal sig_int_cnt_reset	:	std_logic;  --
    
	signal sig_start	:	 std_logic; --
	signal sig_start1	:	 std_logic; --
	signal sig_start2	:	 std_logic; --
	signal sig_start_hilf	:	 std_logic; --
	
	-----signal sig_ready	:	 std_logic; --
	signal sig_isr_clk  :   std_logic;  --
	signal sig_isr_clk_out  :   std_logic;  --
	signal sig_rog  :   std_logic;  --
	
	signal sig_isr_clk_start  :   std_logic;  --
	
	signal sig_hilf1	:   bit;
	signal sig_hilf2	:   bit;
	signal sig_hilf3	:   std_logic;  
	signal sig_hilf4	:   std_logic;  
	signal sig_hilf5	:   bit;
	
	signal sig_hilf11	:   std_logic;
	signal sig_hilf6	:   std_logic;
	
	signal sig_trig :   std_logic;
	
	signal sig_readout_cnt_neg_rst : std_logic;
	
	signal sig_start_meas : std_logic;
	
	signal sig_meas_ready : std_logic;
	
	signal sig_hsync : std_logic;
	signal sig_vsync : std_logic;
	signal sig_pixclk : std_logic;
	

----------------------------------------------------------------------------------

begin

----------------------------------------------------------------------------------
        -- ISR Clock
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
	
	sig_hilf3 <= '1' when(sig_isr_cnt_neg < (teiler1-0)/2) else '0';
	sig_isr_clk_out <= sig_isr_clk when(teiler1 = 1) else sig_hilf3;
	
	
	
	ISR_CLK <= sig_isr_clk_start when(sig_hilf5 = '0') else sig_isr_clk_out;  ----------------------image sensor readout clock (ISR_CLK)
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

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
        -- AFE Clock Generator
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
			sig_hilf11 <= '0';
			--sig_start <= '1';
			--sig_meas_cnt_rst_neg <= '1';
					
		else	
			
			if falling_edge(sig_isr_clk) then					---- 
				if sig_start = '1' then
					sig_isr_clk_start <= '1';
					sig_readout_cnt_reset <= '0';
					sig_int_cnt_reset <= '1';
					
				end if;
				if sig_readout_counter = ((min_clk_start_delay)-1) then
					sig_rog <= '0';
					--sig_start <= '0';
				end if;
				if sig_readout_counter = (((min_clk_start_delay)+(min_rog_start_delay))-1) then
					sig_rog <= '1';
				end if;
				if sig_readout_counter = (((min_clk_start_delay)+(min_rog_start_delay)+(min_clk_stop_delay)-1)-1) then  --hier wird noch ein zus. delay für ISR_CLK < 1MHz erzeugt (max. 1,5µs), ->wg. synchronisation auf sig_cisr_clock
					sig_hilf11 <= '1';
					--sig_meas_cnt_rst_neg <= '1';
				end if;
				if sig_readout_counter = (((min_clk_start_delay)+(min_rog_start_delay)+(min_clk_stop_delay))-1) then  --hier wird noch ein zus. delay für ISR_CLK < 1MHz erzeugt (max. 1,5µs), ->wg. synchronisation auf sig_cisr_clock
					sig_hilf5 <= '1';
					sig_hilf11 <= '0';
					--sig_meas_cnt_rst_neg <= '1';
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
					--sig_start <= '1';
					
				end if;
			end if;			
			
		end if;
		
	end process;
	
----------------------------------------------------------------------------------

	ROG <= sig_rog;
	
----------------------------------------------------------------------------------

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

----------------------------------------------------------------------------------
        -- AFE Controller
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
			
			sig_pixclk <= '0';
		
		else
		
			if sig_reset = '0' then
				sig_counter_reset <= '0';
			end if;
			
			if sig_counter = (((teiler)/2)-1) then --12
				sig_cdsclk1 <= '1';
				sig_pixclk <= '0';
			end if;
			
			if sig_counter = ((((teiler)/2)+2)-1) then --14
					--sig_pixclk <= '1';
			end if;
			
			if sig_counter = ((((teiler)/2)+4)-1) then --16
				sig_cdsclk1 <= '0';
				
			end if;
          
			if sig_counter = (((teiler)-2)-1) then --22
				sig_cdsclk2 <= '1';
			end if;
			
			--if sig_counter = (((teiler)-4)-1) then --20
					--sig_pixclk <= '0';
			--end if;
         			
			if sig_counter = (((teiler)/6)-1) then --4
				sig_cdsclk2 <= '0';
			end if;
          
			if sig_counter = ((teiler)-1) then --24
				sig_adcclk <= '1';	
				sig_pixclk <= '1';
			end if;
          
			if sig_counter = ((((teiler)/2)-2)-1) then --10
				sig_adcclk <= '0';
				
			end if;
          
			if sig_counter = ((((teiler)/2)-4)-1) then --8
				sig_data_hi <= '1';
				--sig_pixclk <= '0';
				
			else
				sig_data_hi <= '0';
			end if;
			           
			if sig_counter = ((((teiler)/2)-2)-1) then --10
				sig_data_lo <= '1';
			else
				sig_data_lo <= '0';
			end if;
			
			if sig_counter = (((teiler)/12)-1) then --2
				sig_data_ready <= '1';
				--sig_pixclk <= '1';
			end if;
			
			if sig_counter = (((teiler)/6)-1) then --4
				sig_data_ready <= '0';
				
			end if;
			
			if sig_counter = ((teiler)-1) then --24
				sig_counter_reset <= '1';
			end if;
		
		end if;	
		
	 end process;
	 
----------------------------------------------------------------------------------
	 
	CDSCLK1 <= sig_cdsclk1 when(sig_trig1 = '1') else '0';
   CDSCLK2 <= sig_cdsclk2 when(sig_trig2 = '1') else '0';
   ADCCLK <= sig_adcclk when(sig_trig3 = '1') else '0'; 
	DATA_READY <= sig_data_ready when(sig_trig4 = '1') else '0';

----------------------------------------------------------------------------------
	 
----------------------------------------------------------------------------------

    --DATA : process(CLOCK, RESET)
    --begin
		--if RESET = '1' then
			--sig_data_r_high <= (others => '0');
			--sig_data_r_low <= (others => '0');
		--elsif rising_edge(CLOCK) then
			--if sig_data_lo = '1' then
				--sig_data_r_low <= ADCDATA;
			--end if;
			--if sig_data_hi = '1' then
				--sig_data_r_high <= ADCDATA;
			--end if;
		--end if;
    --end process;

----------------------------------------------------------------------------------

   --DATA_R(15 downto 8) <= sig_data_r_high;
   --DATA_R(7 downto 0)  <= sig_data_r_low when(sig_data_lo = '1') else sig_data_r_high when(sig_data_hi = '1') else (others => '0');
	DATA_R <= ADCDATA;
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
	 
COUNTER_RESET : process(CLOCK, RESET)
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

----------------------------------------------------------------------------------

	--SYNC_EXT : process(CLOCK, RESET)
	--begin
		--if RESET ='1' then
			--sig_start1 <= '0';
			--sig_start2 <= '0';
		--elsif falling_edge(CLOCK) then
			--sig_start1 <= START;
			--sig_start2 <= sig_start1;
			--sig_start_hilf <= sig_start1 and not sig_start2;
		--end if;
	--end process;

----------------------------------------------------------------------------------
        -- Digital Camera Interface
----------------------------------------------------------------------------------

SYNC_INT : process(CLOCK, RESET)
	begin
		if RESET ='1' then
			sig_start1 <= '0';
			sig_start2 <= '0';
			sig_start_hilf <= '0';
			
			sig_meas_cnt_rst_neg <= '1';
			sig_meas_cnt_rst_pos <= '1';
			
			sig_trigger <= '0';
			
			sig_trig1 <= '0';
			sig_trig2 <= '0';
			sig_trig3 <= '0';
			sig_trig4 <= '0';
			
			sig_meas_ready <= '0';
			
			sig_hsync <= '1';
			sig_vsync <= '1';
			
		elsif falling_edge(CLOCK) then
			sig_start1 <= START;
			sig_start2 <= sig_start1;
			sig_start_hilf <= sig_start1 and not sig_start2;
			
			if sig_start_meas = '1' then
				sig_trigger <= '1';
			end if;
			
			if sig_hilf11 ='1' and sig_trigger = '1' then
				--sig_trigger <= '0';
				sig_meas_cnt_rst_neg <= '0';
				sig_meas_cnt_rst_pos <= '0';
				--sig_trig2 <= '1';
			end if;
			
			if sig_meas_cnt_neg = 1 then
				sig_trig1 <= '1';
				sig_trig3 <= '1';
			end if;
			if sig_meas_cnt_pos = 2 then
				sig_trig2 <= '1';
			end if;
			if sig_meas_cnt_neg = 5 then
				sig_trig4 <= '1';
			end if;
			
			if sig_meas_cnt_neg = 5 then--37 then
				sig_hsync <= '0';
				sig_vsync <= '0';
			end if;
			
			if sig_meas_cnt_neg = teiler2-7 then
				sig_trig1 <= '0';
			end if;
			if sig_meas_cnt_pos = teiler2-6 then
				sig_trig2 <= '0';
			end if;
			if sig_meas_cnt_pos = teiler2-3 then
				sig_trig3 <= '0';
				sig_trig4 <= '0';
				sig_meas_ready <= '1';
				
			end if;
				
			if sig_meas_cnt_neg = teiler2-3 then
				sig_meas_cnt_rst_neg <= '1';
			end if;
			
			if sig_meas_cnt_neg = teiler2-3 then--15 then
				sig_hsync <= '1';
				sig_vsync <= '1';
			end if;
			
			if sig_meas_cnt_pos = teiler2-3 then
				sig_meas_cnt_rst_pos <= '1';
				sig_meas_ready <= '0';	
				sig_trigger <= '0';
			end if;
		end if;
	end process;	 

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

MEAS_CNT_NEG : process(sig_isr_clk, RESET)
	begin
		if sig_meas_cnt_rst_neg = '1' then
			sig_meas_cnt_neg <= 0;	
			--sig_trig1 <= '0';	
		elsif falling_edge(sig_isr_clk) then
				sig_meas_cnt_neg <= sig_meas_cnt_neg + 1;
				--sig_trig1 <= not sig_trig1;
		end if;
	end process;

----------------------------------------------------------------------------------

MEAS_CNT_POS : process(sig_isr_clk, RESET)
	begin
		if sig_meas_cnt_rst_pos = '1' then
			sig_meas_cnt_pos <= 0;		
		elsif rising_edge(sig_isr_clk) then
				sig_meas_cnt_pos <= sig_meas_cnt_pos + 1;
		end if;
	end process;

----------------------------------------------------------------------------------

VSYNC <= sig_vsync;
HSYNC <= sig_hsync;

PIXCLK <= sig_pixclk;-- when(sig_vsync = '0') else '0';

----------------------------------------------------------------------------------
  		 --AFE Config Inerface 
----------------------------------------------------------------------------------         
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
		sig_hilf4 <= '0';--sig_ad_config<='0';
		sig_spi_num(3 downto 0) <= "0000";
  elsif rising_edge(sig_spi_load) then 
		sig_spi_data(14 downto 12)<=sig_spi_num(2 DOWNTO 0); 
      sig_spi_num<=sig_spi_num+1; 
			if sig_spi_num="1000" then 
				sig_hilf4 <= '1'; --sig_ad_config<='1';
			end if; 
  end if;	 
  end process P_LDATA; 
  
  with sig_spi_num select 
     sig_spi_data(8 downto 0)<=	"011010001" when "0001", 
											"011000000" when "0010", 
											"000101010" when "0011", 
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
 

--------------------------------------------------------------------------------------------------  
        -- Main Logic Control Unit 
--------------------------------------------------------------------------------------------------  
 
 CONTROLLER : process(CLOCK, RESET)
	type state_type is (IDLE, WAIT_FOR_MEASUREMENT, MEASUREMENT);
	variable var_state : state_type;
	begin
		if RESET ='1' then
			sig_state <= '0';
			sig_start <= '0';
			--sig_trig <= '0';
			--sig_hilf11 <= '0';
			sig_start_meas <= '0';
			var_state := IDLE;
			
			--sig_meas_cnt_rst_neg <= '1';
			--sig_meas_cnt_rst_pos <= '1';
			
		elsif falling_edge(CLOCK) then
			
			case(var_state) is
				
				when IDLE =>
					sig_state <= '1';
			
					if sig_hilf4 = '1' then
						sig_state <= '0';
						var_state := WAIT_FOR_MEASUREMENT;
					end if;
					
				when WAIT_FOR_MEASUREMENT =>
					sig_start <= '1';
					--sig_trig <= '0';
					sig_start_meas <= '0';
							
					if sig_hilf6 = '1' then
						sig_start <= '0';
						--sig_trig <= '0';
						--if sig_trigger = '1' then
							--sig_meas_cnt_rst_neg <= '0';
							--sig_meas_cnt_rst_pos <= '0';
					end if;	
					
					if sig_start_hilf ='1' then
							var_state := MEASUREMENT;
							--sig_hilf11 <= '1';				
					end if;
								
				when MEASUREMENT =>
					sig_start <= '1';
					
					--if sig_start_hilf ='1' then
					 sig_start_meas <= '1';
					--end if;
					
					if sig_hilf6 = '1' then
						sig_start <= '0';
						--sig_trig <= '0';
						--if sig_trigger = '1' then
							--sig_meas_cnt_rst_neg <= '0';
							--sig_meas_cnt_rst_pos <= '0';
					end if;
					
					if sig_meas_ready = '1' then
						var_state := WAIT_FOR_MEASUREMENT;
						--sig_trig <= '0';
						--sig_hilf11 <= '0';
					end if;
									
					
			end case;		
			
		end if;
	end process; 



----------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------- 

end Behavioral;

