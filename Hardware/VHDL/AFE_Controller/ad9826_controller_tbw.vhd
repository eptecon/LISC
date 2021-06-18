--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:38:26 02/07/2018
-- Design Name:   
-- Module Name:   ad9826_control_tbw.vhd
-- Project Name:  AD9826_control
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: AD9826_control
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY AD9826_control_tbw IS
END AD9826_control_tbw;
 
ARCHITECTURE behavior OF AD9826_control_tbw IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT AD9826_control
    PORT(
         CLOCK : IN  std_logic;
         DATAR : OUT  std_logic_vector(15 downto 0);
         CDSCLK1 : OUT  std_logic;
         CDSCLK2 : OUT  std_logic;
         ADCCLK : OUT  std_logic;
         NOE : OUT  std_logic;
         ADCDATA : IN  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLOCK : std_logic := '0';
   signal ADCDATA : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal DATAR : std_logic_vector(15 downto 0);
   signal CDSCLK1 : std_logic;
   signal CDSCLK2 : std_logic;
   signal ADCCLK : std_logic;
   signal NOE : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: AD9826_control PORT MAP (
          CLOCK => CLOCK,
          DATAR => DATAR,
          CDSCLK1 => CDSCLK1,
          CDSCLK2 => CDSCLK2,
          ADCCLK => ADCCLK,
          NOE => NOE,
          ADCDATA => ADCDATA
        );
 
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant <clock>_period := 1ns;
 
   <clock>_process :process
   begin
		<clock> <= '0';
		wait for <clock>_period/2;
		<clock> <= '1';
		wait for <clock>_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
      wait for 100ms;	

      wait for <clock>_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
