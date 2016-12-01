----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:40:26 11/21/2016 
-- Design Name: 
-- Module Name:    PC - Behavioral 
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

entity IF_PC is
	Port(
		input_pc_inc : in  Bus16 := ZERO_16;
		input_pc_change: in Bus16 := ZERO_16;
		output_pc : out  Bus16 := ZERO_16;
		output_pc_inc: out Bus16 := ZERO_16;
		
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		WriteIn : in  STD_LOGIC := WRITE_EN;
		IS_LW: in STD_LOGIC := V_FALSE;
		IS_JUMP: in STD_LOGIC := V_FALSE);
end IF_PC;

architecture Behavioral of IF_PC is
begin
	process (rst, clk)
        variable var_now_pc : Bus16;
	begin
		if (rst = RST_EN) then 
			output_pc <= ZERO_16;
            output_pc_inc <= ZERO_16;

		elsif (clk'event and clk = '0') then
			if (WriteIn = WRITE_EN and IS_LW = V_FALSE) then
				if(IS_JUMP = V_TRUE) then
					var_now_pc := input_pc_change;
				else
					var_now_pc := input_pc_inc;
				end if;
				output_pc <= var_now_pc;
				output_pc_inc <= (var_now_pc + 1);
			end if;
		end if;
	end process;
end Behavioral;