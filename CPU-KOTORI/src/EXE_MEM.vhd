----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:22:36 11/27/2016 
-- Design Name: 
-- Module Name:    EXE_MEM - Behavioral 
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

entity EXE_MEM is
port
(
	instruction_i: in Bus16 := ZERO_16;
	instruction_type_in: in InsType := ins_NOP;
	alu_result_i: in Bus16 := ZERO_16;
	single_value_i: in Bus16 := ZERO_16;
	pc_value_i: in Bus16 := ZERO_16;
	wreg_type_i: in RegType;
	WriteIn: in std_logic := WRITE_DIS;
    wreg_en_i : in std_logic;
	
	instruction_o: out Bus16 := ZERO_16;
	instruction_type_o: out InsType;
	mem_address_o: out Bus16:= ZERO_16;
	pc_value_o: out Bus16 := ZERO_16;
	mem_data_o: out Bus16 := ZERO_16;
	mem_read_o: out std_logic;
	mem_write_o: out std_logic;
    
    wreg_en_o : out std_logic;
	wreg_type_o: out RegType;
	
	clk: in std_logic;
	rst: in std_logic);
end EXE_MEM;

architecture Behavioral of EXE_MEM is


begin
process (rst, clk)
	begin
		if (rst = RST_EN) then 
				instruction_o <= ZERO_16;
				instruction_type_o <= ins_NOP;
				mem_address_o <= ZERO_16;
				mem_data_o <= ZERO_16;
				mem_read_o <= READ_DIS;
				mem_write_o <= READ_DIS;
				wreg_type_o <= reg_ERR;
                wreg_en_o <= WRITE_DIS;

		elsif (clk'event and clk = '0') then
			if (WriteIn = WRITE_EN) then
				instruction_o <= instruction_i;
				instruction_type_o <= instruction_type_in;
				mem_address_o <= alu_result_i;
				pc_value_o <= pc_value_i;
				mem_data_o <= single_value_i;
				wreg_type_o <= wreg_type_i;
                wreg_en_o <= wreg_en_i;
				if((instruction_type_in = ins_SW) or (instruction_type_in = ins_SW_SP)) then
					mem_write_o <= WRITE_EN;
					mem_read_o <= READ_DIS;
				elsif((instruction_type_in = ins_LW) or (instruction_type_in = ins_LW_SP)) then
					mem_write_o <= WRITE_DIS;
					mem_read_o <= READ_EN;
				else
					mem_write_o <= WRITE_DIS;
					mem_read_o <= READ_DIS;
				end if;
			end if;
		end if;
	end process;

end Behavioral;

