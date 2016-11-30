--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:43:37 11/28/2016
-- Design Name:   
-- Module Name:   C:/_Dev/HDLProj/THCO-MIPS-CPU-NEXT/CPU-KOTORI/src/testbench_CPUTop.vhd
-- Project Name:  THCO-MIPS-CPU-NEXT
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: CPUTop
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library WORK;
use WORK.util.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testbench_CPUTop IS
END testbench_CPUTop;
 
ARCHITECTURE behavior OF testbench_CPUTop IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CPUTop
    PORT(
         rst : IN  std_logic;
         pin_CLK_IN : IN  std_logic;
         pin_RAM1_Addr : OUT  std_logic_vector(17 downto 0);
         pin_RAM1_EN : OUT  std_logic;
         pin_RAM1_WE : OUT  std_logic;
         pin_RAM1_OE : OUT  std_logic;
         pin_RAM1_Data : INOUT  std_logic_vector(15 downto 0);
         pin_RAM2_Addr : OUT  std_logic_vector(17 downto 0);
         pin_RAM2_EN : OUT  std_logic;
         pin_RAM2_WE : OUT  std_logic;
         pin_RAM2_OE : OUT  std_logic;
         pin_RAM2_Data : INOUT  std_logic_vector(15 downto 0);
         pin_com_data_ready : IN  std_logic;
         pin_com_rdn : OUT  std_logic;
         pin_com_tbre : IN  std_logic;
         pin_com_tsre : IN  std_logic;
         pin_com_wrn : OUT  std_logic
        );
    END COMPONENT;
    
    component cpu_ram
    port(
        addr_i : in Bus16;
        ram1_data_io : inout Bus16;
        ram2_data_io : inout Bus16;
        
        --读写内存 <==> ram2
        --读写串口 <==> ram1
        
        ram2_r_en_i, ram2_w_en_i : in std_logic;
        com_r_en_i, com_w_en_i : in std_logic);
    end component;
    

   --Inputs
   signal rst : std_logic := RST_DIS;
   signal pin_CLK_IN : std_logic := '0';
   signal pin_com_data_ready : std_logic := '1';
   signal pin_com_tbre : std_logic := '1';
   signal pin_com_tsre : std_logic := '1';

	--BiDirs
   signal pin_RAM1_Data : std_logic_vector(15 downto 0);
   signal pin_RAM2_Data : std_logic_vector(15 downto 0);

 	--Outputs
   signal pin_RAM1_Addr : std_logic_vector(17 downto 0);
   signal pin_RAM1_EN : std_logic;
   signal pin_RAM1_WE : std_logic;
   signal pin_RAM1_OE : std_logic;
   signal pin_RAM2_Addr : std_logic_vector(17 downto 0);
   signal pin_RAM2_EN : std_logic;
   signal pin_RAM2_WE : std_logic;
   signal pin_RAM2_OE : std_logic;
   signal pin_com_rdn : std_logic;
   signal pin_com_wrn : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant CLK_period : time := 20 ns;
   constant cpu_CLK_period : time := 80 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CPUTop PORT MAP (
          rst => rst,
          pin_CLK_IN => pin_CLK_IN,
          pin_RAM1_Addr => pin_RAM1_Addr,
          pin_RAM1_EN => pin_RAM1_EN,
          pin_RAM1_WE => pin_RAM1_WE,
          pin_RAM1_OE => pin_RAM1_OE,
          pin_RAM1_Data => pin_RAM1_Data,
          pin_RAM2_Addr => pin_RAM2_Addr,
          pin_RAM2_EN => pin_RAM2_EN,
          pin_RAM2_WE => pin_RAM2_WE,
          pin_RAM2_OE => pin_RAM2_OE,
          pin_RAM2_Data => pin_RAM2_Data,
          pin_com_data_ready => pin_com_data_ready,
          pin_com_rdn => pin_com_rdn,
          pin_com_tbre => pin_com_tbre,
          pin_com_tsre => pin_com_tsre,
          pin_com_wrn => pin_com_wrn
        );

   -- Clock process definitions
   pin_CLK_IN_process :process
   begin
		pin_CLK_IN <= '0';
		wait for CLK_period/2;
		pin_CLK_IN <= '1';
		wait for CLK_period/2;
   end process;
 

-- Stimulus process

Unit_ram : cpu_ram port map(
    addr_i => pin_RAM2_Addr(15 downto 0),
    ram1_data_io => pin_RAM1_Data,
    ram2_data_io => pin_RAM2_Data,
    
    ram2_r_en_i => pin_RAM2_OE,
    ram2_w_en_i => pin_RAM2_WE,
    
    com_r_en_i => pin_com_rdn,
    com_w_en_i => pin_com_wrn);
    

END;











