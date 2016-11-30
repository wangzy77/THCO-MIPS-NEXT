----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:03:21 11/27/2016 
-- Design Name: 
-- Module Name:    ComReg - Behavioral 
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

entity ComReg is

port(
    rst : in std_logic;
    clk : in std_logic;
    
    w_type : in RegType;
    w_data : in std_logic_vector(15 downto 0);
    we : in std_logic;  --寄存器堆写使能信号
    
    r_addr_1 : in std_logic_vector(2 downto 0);
    re_1 : in std_logic;    --第一个读寄存器端口读使能信号
    r_data_1 : out std_logic_vector(15 downto 0);
    
    r_addr_2 : in std_logic_vector(2 downto 0);
    re_2 : in std_logic;
    r_data_2 : out std_logic_vector(15 downto 0));

end ComReg;

architecture Behavioral of ComReg is

signal R1, R2,R3, R4, R5, R6, R7, R8 : Bus16 := ZERO_16;

begin

with reg_addr_to_type(r_addr_1) select
    r_data_1 <= 
            R1 when reg_R1,
            R2 when reg_R2,
            R3 when reg_R3,
            R4 when reg_R4,
            R5 when reg_R5,
            R6 when reg_R6,
            R7 when reg_R7,
            R8 when reg_R8,
            ZERO_16 when others;
             
with reg_addr_to_type(r_addr_2) select
    r_data_2 <= 
            R1 when reg_R1,
            R2 when reg_R2,
            R3 when reg_R3,
            R4 when reg_R4,
            R5 when reg_R5,
            R6 when reg_R6,
            R7 when reg_R7,
            R8 when reg_R8,
            ZERO_16 when others;
             
process(rst, clk)
begin
    
if(rst = RST_EN) then
    R1 <= ZERO_16;
    R2 <= ZERO_16;
    R3 <= ZERO_16;
    R4 <= ZERO_16;
    R5 <= ZERO_16;
    R6 <= ZERO_16;
    R7 <= ZERO_16;
    R8 <= ZERO_16;
elsif(clk'event and clk = '1') then
    if((rst = RST_DIS) and (we = WRITE_EN)) then
        case w_type is
            when reg_R1 => R1 <= w_data;
            when reg_R2 => R2 <= w_data;
            when reg_R3 => R3 <= w_data;
            when reg_R4 => R4 <= w_data;
            when reg_R5 => R5 <= w_data;
            when reg_R6 => R6 <= w_data;
            when reg_R7 => R7 <= w_data;
            when reg_R8 => R8 <= w_data;
            when others => null;
        end case;
    end if;
end if;

end process;


end Behavioral;

