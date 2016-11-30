----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:53:12 11/21/2016 
-- Design Name: 
-- Module Name:    IF_ID - Behavioral 
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

entity IF_ID is
    Port(
		pc_in: in Bus16 := ZERO_16;
		Instruction_in: in Bus16 := ZERO_16;
		
		pc_out: out Bus16 := ZERO_16;
		Instruction_out: out Bus16 := ZERO_16;
		
		clk: in std_logic;
		rst: in std_logic;
		IS_LW: in std_logic := V_FALSE;
		IS_JUMP: in std_logic := V_FALSE;
		WriteIn : in  std_logic := Write_EN);
end IF_ID;

architecture Behavioral of IF_ID is

begin
	process(rst, clk)
	begin
	if rst = RST_EN then		
		PC_out <= ZERO_16;
		Instruction_out <= ZERO_16;
	elsif (clk'event and clk = '0') then
			if (WriteIn = WRITE_EN) then
				PC_out <= PC_in;
				if(IS_LW = V_FALSE and IS_JUMP = V_FALSE) then	
					Instruction_out <= Instruction_in;
				else
					Instruction_out <= Instruction_NOP;	
				end if;
			end if;
	end if;
end process;



end Behavioral;

