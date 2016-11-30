----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:17:07 11/26/2016 
-- Design Name: 
-- Module Name:    Controller - Behavioral 
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

entity Controller is

port(
    inst_i : in Bus16;
    --IF_ID --inst_i--> RegFile --X, Y, special--> 
    reg_X_i, reg_Y_i,
    reg_PC_i, reg_IH_i, reg_RA_i, reg_SP_i, reg_T_i : in Bus16;
    
----------------------------------------------------------------------------------
    ins_type_o : out InsType := ins_NOP;
    

----------------------------------------------------------------------------------
--ctrl signals    
    alu_op_o : out AluOP := alu_NULL;
    
    --R[x] > R[y] > 参与运算的特殊寄存器 > 作为 flag 的特殊寄存器
    rreg1_type_o : out RegType := reg_ERR;
    rreg1_data_o : out Bus16 := ZERO_16;
    rreg2_type_o : out RegType := reg_ERR;
    rreg2_data_o : out Bus16 := ZERO_16;
    exted_imm_o : out Bus16 := ZERO_16;
    
    wreg_en_o : out std_logic := WRITE_DIS;
    wreg_type_o : out RegType := reg_ERR;
----------------------------------------------------------------------------------
    is_LW_o : out std_logic);


end Controller;

architecture Behavioral of Controller is
----------------------------------------------------------------------------------
--component
component reg_selector is
    port(
        reg_addr : in std_logic_vector(2 downto 0);
        reg_type : out RegType);
end component;

component ins_decoder is
    port(
        ins : in std_logic_vector(15 downto 0);
        ins_type : out InsType);
end component;
----------------------------------------------------------------------------------
--signal
signal ins_type_s : InsType;
signal reg_X_type, reg_Y_type, reg_Z_type : RegType;
----------------------------------------------------------------------------------
begin

Unit_InsDecoder : ins_decoder port map(
    ins => inst_i,
    ins_type => ins_type_s);
ins_type_o <= ins_type_s;

Unit_reg_X_type : reg_selector port map(
    reg_addr => inst_i(10 downto 8),
    reg_type => reg_X_type);
    
Unit_reg_Y_type : reg_selector port map(
    reg_addr => inst_i(7 downto 5),
    reg_type => reg_Y_type);
    
Unit_reg_Z_type : reg_selector port map(
    reg_addr => inst_i(4 downto 2),
    reg_type => reg_Z_type);


process(inst_i, ins_type_s, reg_X_type, reg_Y_type, reg_Z_type,
        reg_X_i, reg_Y_i,
        reg_PC_i, reg_IH_i, reg_RA_i, reg_SP_i, reg_T_i)

variable cmd : CtrlSig;
variable var_is_LW : std_logic;

begin

    --initial
    cmd := get_cmd(
        alu_NULL,
        
        reg_ERR,
        ZERO_16,
        reg_ERR,
        ZERO_16,
        ZERO_16,
        
        WRITE_DIS,
        reg_ERR);

    var_is_LW := V_FALSE;
    case ins_type_s is
        when ins_ADDIU =>
            cmd := get_cmd(
                alu_PLUS,
                
                reg_X_type,
                reg_X_i,
                reg_ERR,
                ZERO_16,
                sxt(inst_i(7 downto 0), 16),
                
                WRITE_EN,
                reg_X_type);
        when ins_ADDIU3 =>
            cmd := get_cmd(
                alu_PLUS,
                
                reg_X_type,
                reg_X_i,
                reg_ERR,
                ZERO_16,
                sxt(inst_i(3 downto 0), 16),
                
                WRITE_EN,
                reg_Y_type);
        when ins_ADDSP3 =>
            cmd := get_cmd(
                alu_PLUS,
                
                reg_SP,
                reg_SP_i,
                reg_ERR,
                ZERO_16,
                sxt(inst_i(7 downto 0), 16),
                
                WRITE_EN,
                reg_X_type);
        when ins_ADDSP =>
            cmd := get_cmd(
                alu_PLUS,
                
                reg_SP,
                reg_SP_i,
                reg_ERR,
                ZERO_16,
                sxt(inst_i(7 downto 0), 16),
                
                WRITE_EN,
                reg_SP);
        when ins_ADDU =>
            cmd := get_cmd(
                alu_PLUS,
                
                reg_X_type,
                reg_X_i,
                reg_Y_type,
                reg_Y_i,
                ZERO_16,
                
                WRITE_EN,
                reg_Z_type);
        when ins_AND =>
            cmd := get_cmd(
                alu_AND,
                
                reg_X_type,
                reg_X_i,
                reg_Y_type,
                reg_Y_i,
                ZERO_16,
                
                WRITE_EN,
                reg_X_type);
        when ins_B =>
            cmd := get_cmd(
                alu_PLUS,
                
                reg_PC,
                reg_PC_i,
                reg_ERR,
                ZERO_16,
                sxt(inst_i(10 downto 0), 16),
                
                WRITE_DIS,
                reg_ERR);
        when ins_BEQZ =>
            cmd := get_cmd(
                alu_PLUS,
                
                reg_X_type,
                reg_X_i,
                reg_PC,
                reg_PC_i,
                sxt(inst_i(7 downto 0), 16),
                
                WRITE_DIS,
                reg_ERR);
        when ins_BNEZ =>
            cmd := get_cmd(
                alu_PLUS,
                
                reg_X_type,
                reg_X_i,
                reg_PC,
                reg_PC_i,
                sxt(inst_i(7 downto 0), 16),
                
                WRITE_DIS,
                reg_ERR);
        when ins_BTEQZ =>
            cmd := get_cmd(
                alu_PLUS,
                
                reg_PC,
                reg_PC_i,
                reg_T,
                reg_T_i,
                sxt(inst_i(7 downto 0), 16),
                
                WRITE_DIS,
                reg_ERR);
        when ins_CMP =>
            --ALU 输出直接赋值给 T 寄存器
            cmd := get_cmd(
                alu_CMP,
                
                reg_X_type,
                reg_X_i,
                reg_Y_type,
                reg_Y_i,
                ZERO_16,
                
                WRITE_EN,
                reg_T);
        when ins_JALR =>
            cmd := get_cmd(
                alu_NULL,
                
                reg_X_type,
                reg_X_i,
                reg_ERR,
                ZERO_16,
                ZERO_16,
                
                WRITE_EN,
                reg_RA);
        when ins_JR =>
            cmd := get_cmd(
                alu_NULL,
                
                reg_X_type,
                reg_X_i,
                reg_ERR,
                ZERO_16,
                ZERO_16,
                
                WRITE_DIS,
                reg_ERR);
        when ins_JRRA =>
            cmd := get_cmd(
                alu_NULL,
                
                reg_RA,
                reg_RA_i,
                reg_ERR,
                ZERO_16,
                ZERO_16,
                
                WRITE_DIS,
                reg_ERR);
        when ins_LI => 
            cmd := get_cmd(
                alu_NULL,
                
                reg_ERR,
                ZERO_16,
                reg_ERR,
                ZERO_16,
                ext(inst_i(7 downto 0), 16),
                
                WRITE_EN,
                reg_X_type);
        when ins_LW =>
            cmd := get_cmd(
                alu_PLUS,
                
                reg_X_type,
                reg_X_i,
                reg_ERR,
                ZERO_16,
                sxt(inst_i(4 downto 0), 16),
                
                WRITE_EN,
                reg_Y_type);
                
            var_is_LW := V_TRUE;
        when ins_LW_SP =>
            cmd := get_cmd(
                alu_PLUS,
                
                reg_SP,
                reg_SP_i,
                reg_ERR,
                ZERO_16,
                sxt(inst_i(7 downto 0), 16),
                
                WRITE_EN,
                reg_X_type);
                
            var_is_LW := V_TRUE;
        when ins_MFIH =>
            cmd := get_cmd(
                alu_NULL,
                
                reg_IH,
                reg_IH_i,
                reg_ERR,
                ZERO_16,
                ZERO_16,
                
                WRITE_EN,
                reg_X_type);
        when ins_MFPC =>
            cmd := get_cmd(
                alu_NULL,
                
                reg_PC,
                reg_PC_i,
                reg_ERR,
                ZERO_16,
                ZERO_16,
                
                WRITE_EN,
                reg_X_type);
        when ins_MOVE =>
            cmd := get_cmd(
                alu_NULL,
                
                reg_Y_type,
                reg_Y_i,
                reg_ERR,
                ZERO_16,
                ZERO_16,
                
                WRITE_EN,
                reg_X_type);
        when ins_MTIH =>
            cmd := get_cmd(
                alu_NULL,
                
                reg_X_type,
                reg_X_i,
                reg_ERR,
                ZERO_16,
                ZERO_16,
                
                WRITE_EN,
                reg_IH);
        when ins_MTSP =>
            cmd := get_cmd(
                alu_NULL,
                
                reg_Y_type,
                reg_Y_i,
                reg_ERR,
                ZERO_16,
                ZERO_16,
                
                WRITE_EN,
                reg_SP);
        when ins_NOP => null;
        when ins_OR =>
            cmd := get_cmd(
                alu_OR,
                
                reg_X_type,
                reg_X_i,
                reg_Y_type,
                reg_Y_i,
                ZERO_16,
                
                WRITE_EN,
                reg_X_type);
        when ins_SLL =>
            cmd := get_cmd(
                alu_SLL,
                
                reg_Y_type,
                reg_Y_i,
                reg_ERR,
                ZERO_16,
                ext(inst_i(4 downto 2), 16),
                
                WRITE_EN,
                reg_X_type);
        when ins_SLT =>
            --ALU 输出直接赋值给 T 寄存器
            cmd := get_cmd(
                alu_SLT,
                
                reg_X_type,
                reg_X_i,
                reg_Y_type,
                reg_Y_i,
                ZERO_16,
                
                WRITE_EN,
                reg_T);
        when ins_SRA =>
            cmd := get_cmd(
                alu_SRA,
                
                reg_Y_type,
                reg_Y_i,
                reg_ERR,
                ZERO_16,
                ext(inst_i(4 downto 2), 16),
                
                WRITE_EN,
                reg_X_type);
        when ins_SUBU =>
            cmd := get_cmd(
                alu_MINUS,
                
                reg_X_type,
                reg_X_i,
                reg_Y_type,
                reg_Y_i,
                ZERO_16,
                
                WRITE_EN,
                reg_Z_type);
        when ins_SW =>
            cmd := get_cmd(
                alu_PLUS,
                
                reg_X_type,
                reg_X_i,
                reg_Y_type,
                reg_Y_i,
                sxt(inst_i(4 downto 0), 16),
                
                WRITE_DIS,
                reg_ERR);
        when ins_SW_SP =>
            cmd := get_cmd(
                alu_PLUS,
                
                reg_X_type,
                reg_X_i,
                reg_SP,
                reg_SP_i,
                sxt(inst_i(7 downto 0), 16),
                
                WRITE_DIS,
                reg_ERR);
        when others => null;
    end case;
    alu_op_o <= cmd.alu_op;
    
    rreg1_type_o <= cmd.rreg1_type;
    rreg1_data_o <= cmd.rreg1_data;
    rreg2_type_o <= cmd.rreg2_type;
    rreg2_data_o <= cmd.rreg2_data;
    exted_imm_o <= cmd.exted_imm;
    
    wreg_en_o <= cmd.is_wreg;
    wreg_type_o <= cmd.wreg_type;
    
    --插入 NOP 指令
    is_LW_o <= var_is_LW;

end process;


end Behavioral;

