----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:31:17 11/11/2016 
-- Design Name: 
-- Module Name:    util - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package util is

----------------------------------------------------------------------------------
-- 全局常量
constant RST_EN : std_logic := '0';
constant RST_DIS : std_logic := '1';

constant WRITE_EN : std_logic := '0';
constant WRITE_DIS : std_logic := '1';

constant READ_EN : std_logic := '0';
constant READ_DIS : std_logic := '1';

constant CHIP_EN : std_logic := '0';
constant CHIP_DIS : std_logic := '1';

-- constant JUMP_EN : std_logic := '0';
-- constant JUMP_DIS : std_logic := '1';

constant PAUSE_EN : std_logic := '0';
constant PAUSE_DIS : std_logic := '1';

--is_LW
--is_Jump
constant V_TRUE : std_logic := '1';
constant V_FALSE : std_logic := '0';

constant ZERO_4 : std_logic_vector(3 downto 0) := "0000";
constant ZERO_16 : std_logic_vector(15 downto 0) := "0000000000000000";
constant ZERO_18 : std_logic_vector(17 downto 0) := "000000000000000000";
constant ZZZZ_16 : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";

constant INSTRUCTION_NOP : std_logic_vector(15 downto 0) := "0000100000000000";

constant MAX_INS_FROM_FLASH : std_logic_vector(15 downto 0) := x"0200";


----------------------------------------------------------------------------------
-- 自定义 type
subtype Bus4 is std_logic_vector(3 downto 0);
subtype Bus16 is std_logic_vector(15 downto 0);
subtype Bus18 is std_logic_vector(17 downto 0);



type InsType is (
    -- 基本指令集
    ins_ADDIU, ins_ADDIU3, ins_ADDSP, ins_ADDU, ins_AND,
    ins_B, ins_BEQZ, ins_BNEZ, ins_BTEQZ, ins_CMP,
    ins_JR, ins_LI, ins_LW, ins_LW_SP, ins_MFIH,
    ins_MFPC, ins_MTIH, ins_MTSP, ins_NOP, ins_OR,
    ins_SLL, ins_SRA, ins_SUBU, ins_SW, ins_SW_SP,
    -- 扩展指令集
    ins_JRRA, ins_JALR, ins_ADDSP3, ins_MOVE, ins_SLT);
    
type RegType is (
    reg_R1, reg_R2, reg_R3, reg_R4, reg_R5, reg_R6, reg_R7, reg_R8,
    reg_T, reg_PC, reg_IH, reg_RA, reg_SP, reg_ERR);
    
    
-- sll 逻辑左移
-- srl 逻辑右移
-- sra 算数右移
-- rol 循环左移
type AluOP is (
    alu_PLUS, alu_MINUS,
    alu_AND, alu_OR, alu_NOT,
    alu_CMP,    -- x == y -> '0', x != y -> '1'
    alu_SLT,    -- x < y -> '1', x >= y -> '0'
    alu_SLL, alu_SRL, alu_SLA, alu_SRA,
    alu_NULL);
    
----------------------------------------------------------------------------------
--自定义结构    
type CtrlSig is
	record
		alu_op : AluOP;
        
        rreg1_type : RegType;
        rreg1_data : Bus16;
        rreg2_type : RegType;
        rreg2_data : Bus16;
        exted_imm : Bus16;

        is_wreg : std_logic;
        wreg_type : RegType;
	end record;
    
----------------------------------------------------------------------------------
--函数声明
function reg_addr_to_type(reg_addr : std_logic_vector(2 downto 0)) return RegType;
function get_cmd(
    alu_op : in AluOP;
    
    rreg1_type : in RegType;
    rreg1_data : in Bus16;
    rreg2_type : in RegType;
    rreg2_data : in Bus16;
    exted_imm : in Bus16;
    
    is_wreg : in std_logic;
    wreg_type : in RegType
	) return CtrlSig;

end util;

package body util is

function reg_addr_to_type(reg_addr : std_logic_vector(2 downto 0)) return RegType is
	variable reg_type : RegType;
	begin
        case reg_addr is
            when "000" => reg_type := reg_R1;
            when "001" => reg_type := reg_R2;
            when "010" => reg_type := reg_R3;
            when "011" => reg_type := reg_R4;
            when "100" => reg_type := reg_R5;
            when "101" => reg_type := reg_R6;
            when "110" => reg_type := reg_R7;
            when "111" => reg_type := reg_R8;
            when others => reg_type := reg_ERR;
        end case;
		return reg_type;
	end reg_addr_to_type;

function get_cmd(
    alu_op : in AluOP;
    
    rreg1_type : in RegType;
    rreg1_data : in Bus16;
    rreg2_type : in RegType;
    rreg2_data : in Bus16;
    exted_imm : in Bus16;
    
    is_wreg : in std_logic;
    wreg_type : in RegType
	) return CtrlSig is
		variable cmd : CtrlSig;
	begin
		cmd.alu_op := alu_op;
        
        cmd.rreg1_type := rreg1_type;
        cmd.rreg1_data := rreg1_data;
        cmd.rreg2_type := rreg2_type;
        cmd.rreg2_data := rreg2_data;
        cmd.exted_imm := exted_imm;
        
        cmd.is_wreg := is_wreg;
        cmd.wreg_type := wreg_type;
		
		return cmd;
	end get_cmd;
    
    

end util;










-- a <= sxt(std_logic_vector, width(DEX))
-- ext 零扩展