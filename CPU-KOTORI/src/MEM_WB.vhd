----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:06:41 11/22/2016 
-- Design Name: 
-- Module Name:    MEM_WB - Behavioral 
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

entity MEM_WB is
    Port(
		instruction_type_in: in InsType := ins_NOP;
		MEM_Data_in: in Bus16 := ZERO_16;
		ALU_result_in: in Bus16 := ZERO_16;
		Wreg_type_in: in RegType;
		PC_in: in Bus16 := ZERO_16;
		Reg_write_or_not_in: in std_logic := WRITE_DIS;
		
		Wreg_type_out: out RegType;
		Wreg_data_out: out Bus16 := ZERO_16;
		Reg_write_or_not_out: out std_logic := WRITE_DIS;
        inst_type_o : out InsType := ins_NOP;
        
		clk: in std_logic;
		rst: in std_logic;
		WriteIn : in  STD_LOGIC
	);
end MEM_WB;

architecture Behavioral of MEM_WB is

begin
	process(rst, clk)
	begin
	if rst = RST_EN then		
		Wreg_type_out <= reg_ERR;
		Wreg_data_out <= ZERO_16;
		Reg_write_or_not_out <= WRITE_DIS;
        inst_type_o <= ins_NOP;
	elsif (clk'event and clk = '0') then
			if (WriteIn = WRITE_EN) then
				Wreg_type_out <= Wreg_type_in;
				case instruction_type_in is
                    when ins_LW | ins_LW_SP =>
                        Wreg_data_out <= MEM_Data_in;
                    when ins_ADDIU| ins_MOVE | ins_SLT| ins_ADDIU3 | ins_ADDSP |
                         ins_ADDSP3| ins_ADDU | ins_AND | ins_CMP | ins_LI | ins_MFIH |
                         ins_MTSP | ins_OR | ins_SLL | ins_SRA | ins_SUBU =>
						Wreg_data_out <= ALU_result_in;
					when ins_MFPC =>
                        Wreg_data_out <= PC_in; 
                    when ins_JALR =>
					    Wreg_data_out <= PC_in + 2;
                    when others =>
						Wreg_data_out <= ZERO_16 ;
                end case;
				Reg_write_or_not_out <= Reg_write_or_not_in;
                inst_type_o <= instruction_type_in;
			end if;
	end if;
	end process;



end Behavioral;
