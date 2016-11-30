----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:56:04 11/23/2016 
-- Design Name: 
-- Module Name:    reg_selector - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
library WORK;
use WORK.util.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg_selector is

port(
    reg_addr : in std_logic_vector(2 downto 0);
    reg_type : out RegType);

end reg_selector;

architecture Behavioral of reg_selector is

begin

with reg_addr select
    reg_type <= reg_R1 when "000",
                reg_R2 when "001",
                reg_R3 when "010",
                reg_R4 when "011",
                reg_R5 when "100",
                reg_R6 when "101",
                reg_R7 when "110",
                reg_R8 when "111",
                reg_ERR when others;


end Behavioral;

