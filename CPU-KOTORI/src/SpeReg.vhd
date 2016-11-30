----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:12:39 11/27/2016 
-- Design Name: 
-- Module Name:    SpeReg - Behavioral 
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

entity SpeReg is

port(
    clk : in STD_LOGIC;
    rst : in std_logic;

    wreg_type_i : in RegType := reg_ERR;
    wreg_data_i : in Bus16 := ZERO_16;
    
    T_value : out Bus16 := ZERO_16;
    RA_value : out Bus16 := ZERO_16;
    IH_value : out Bus16 := ZERO_16;
    SP_value : out Bus16 := ZERO_16
);

end SpeReg;

architecture Behavioral of SpeReg is

begin

process(rst, clk)
begin

if(rst = RST_EN) then
    T_value <= ZERO_16;
    IH_value <= ZERO_16;
    RA_value <= ZERO_16;
    SP_value <= ZERO_16;
elsif(clk'event and clk = '1') then
    case(wreg_type_i) is
        when reg_T => T_value <= wreg_data_i;
        when reg_IH => IH_value <= wreg_data_i;
        when reg_RA => RA_value <= wreg_data_i;
        when reg_SP => SP_value <= wreg_data_i;
        when others => null;
    end case;
end if;
    
end process;
    
end Behavioral;

