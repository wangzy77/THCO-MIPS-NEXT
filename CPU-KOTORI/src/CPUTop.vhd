----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:21:10 11/27/2016 
-- Design Name: 
-- Module Name:    CPUTop - Behavioral 
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

entity CPUTop is

Port(
    rst : in std_logic;
    pin_CLK_IN : in  STD_LOGIC;
    pin_RAM1_Addr : out  STD_LOGIC_VECTOR (17 downto 0) := ZERO_18;
    pin_RAM1_EN : out  STD_LOGIC;
    pin_RAM1_WE : out  STD_LOGIC;
    pin_RAM1_OE : out  STD_LOGIC;
    pin_RAM1_Data : inout  STD_LOGIC_VECTOR (15 downto 0);
    pin_RAM2_Addr : out  STD_LOGIC_VECTOR (17 downto 0);
    pin_RAM2_EN : out  STD_LOGIC;
    pin_RAM2_WE : out  STD_LOGIC;--0->使能
    pin_RAM2_OE : out  STD_LOGIC;
    pin_RAM2_Data : inout  STD_LOGIC_VECTOR (15 downto 0);
    pin_com_data_ready : in STD_LOGIC;
    pin_com_rdn : out STD_LOGIC;---0->使能
    pin_com_tbre : in STD_LOGIC;
    pin_com_tsre : in STD_LOGIC;
    pin_com_wrn : out STD_LOGIC;
    
    pin_debug_led : out std_logic_vector(15 downto 0);
    pin_debug_tube : out std_logic_vector(13 downto 0));
           
end CPUTop;

architecture Behavioral of CPUTop is
----------------------------------------------------------------------------------
--component
--IF
component IF_PC is
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
end component;

    --PC
component IF_ID is
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
end component;

--ID
component ComReg is
port(
    rst : in std_logic;
    clk : in std_logic;
    
    w_type : in regType;
    w_data : in std_logic_vector(15 downto 0);
    we : in std_logic;  --寄存器堆写使能信号
    
    r_addr_1 : in std_logic_vector(2 downto 0);
    re_1 : in std_logic;    --第一个读寄存器端口读使能信号
    r_data_1 : out std_logic_vector(15 downto 0);
    
    r_addr_2 : in std_logic_vector(2 downto 0);
    re_2 : in std_logic;
    r_data_2 : out std_logic_vector(15 downto 0));
end component;

component SpeReg is
port(
    clk : in STD_LOGIC;
    rst : in std_logic;

    wreg_type_i : in RegType := reg_ERR;
    wreg_data_i : in Bus16 := ZERO_16;
    
    T_value : out Bus16 := ZERO_16;
    RA_value : out Bus16 := ZERO_16;
    IH_value : out Bus16 := ZERO_16;
    SP_value : out Bus16 := ZERO_16);
end component;

component Controller is
port(
    inst_i : in Bus16;
    --IF_ID --inst_i--> RegFile --X, Y, special--> 
    reg_X_i, reg_Y_i,
    reg_PC_i, reg_IH_i, reg_RA_i, reg_SP_i, reg_T_i : in Bus16;
    
    ins_type_o : out InsType := ins_NOP;
    
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
    
    is_LW_o : out std_logic);
end component;

component ins_decoder is
port(
    ins : in std_logic_vector(15 downto 0);
    ins_type : out InsType);
end component;

component reg_selector is
port(
    reg_addr : in std_logic_vector(3 downto 0);
    reg_type : out RegType);
end component;

component ID_EXE is
port(
    clk : in std_logic;
    rst : in std_logic;
    --
    write_EN_i : in std_logic;
    
--from controller
    inst_i : in Bus16;
    inst_type_i : in InsType;
    alu_op_i : in AluOP;
    rreg1_type_i : in RegType;
    rreg1_data_i : in Bus16;
    rreg2_type_i : in RegType;
    rreg2_data_i : in Bus16;
    exted_imm_i : in Bus16;
    is_wreg_i : in std_logic;
    wreg_type_i : in RegType;
--from IF_ID
    pc_i : in Bus16;
--out
    inst_o : out Bus16;
    inst_type_o : out InsType;
    
    alu_op_o : out AluOP;
    
    rreg1_type_o : out RegType;
    rreg1_data_o : out Bus16;
    rreg2_type_o : out RegType;
    rreg2_data_o : out Bus16;
    
    exted_imm_o : out Bus16;
    is_wreg_o : out std_logic;
    wreg_type_o : out RegType;
    
    pc_o : out Bus16);
end component;

--EXE
component ALU is
port(
    in1 : in Bus16;
    in2 : in Bus16;
    op : in AluOP;
    
    res : out Bus16 := ZERO_16);
end component;

component BranchCtrl is
port(
    inst_i : in Bus16;
    ins_type_i : in InsType;
    pc_i : in Bus16;
    
    --from ALU
    alu_res_i : in Bus16;
    --from Forward
    flag_i : in Bus16;
    
    is_Jump : out std_logic := V_FALSE;
    pc_o : out Bus16 := ZERO_16);
end component;

component Forward is
port(
--本条指令的信息，从 ID_EXE 获得
    cur_ins_i : in Bus16;
    cur_ins_type_i : in InsType;
    
    --read 寄存器优先顺序：
    --R[x] > R[y] > 参与运算的特殊寄存器 > 作为 flag 的特殊寄存器
    cur_rreg1_type_i : in RegType;
    cur_rreg1_data_i : in Bus16;
    
    cur_rreg2_type_i : in RegType;
    cur_rreg2_data_i : in Bus16;
    
    cur_exted_imm_i : in Bus16;
       
--上条指令信息，从 EXE_MEM 获得
    l_ins_type_i : InsType;
    l_is_wreg_i : in std_logic;
    l_wreg_type_i : in RegType;
    l_wreg_data_i : in Bus16;
    
--上上条指令信息，从 MEM_WB 获得
    ll_ins_type_i : in InsType;
    ll_is_wreg_i : std_logic;
    ll_wreg_type_i : in RegType;
    ll_wreg_data_i : in Bus16;
    
    alu_A_fin_o : out Bus16;
    alu_B_fin_o : out Bus16;
    
    --用于 SW, SW_SP 指令，仅该指令的计算在赋
    --值号左边，且恰好赋值号右边只有一个变量
    --以及JALR 指令的
    single_value_fin_o : out Bus16; 
    
    flag_A_fin_o : out Bus16);
    --flag_B_fin_o : out Bus16);
end component;

component EXE_MEM is
port(
	instruction_i: in Bus16 := ZERO_16;
	instruction_type_in: in InsType := ins_NOP;
	alu_result_i: in Bus16 := ZERO_16;
	single_value_i: in Bus16 := ZERO_16;
	pc_value_i: in Bus16 := ZERO_16;
	wreg_type_i: in regType;
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
end component;

--MEM
component MemoryTop is
Port(
    --clock 
    clk : in std_logic;
    rst : in std_logic;
    cpu_clk : out std_logic;
    
    --addr1 for instruction
    instrAddress : in std_logic_vector(15 downto 0);
    instrOutput : out std_logic_vector(15 downto 0);
    
    --addr2 for data
    dataAddress : in std_logic_vector(15 downto 0);
    dataOutput : out std_logic_vector(15 downto 0);
    dataInput : in std_logic_vector(15 downto 0);
    
    --control signal
    MemRead : in std_logic;
    MemWrite : in std_logic;
    
    --ram1 disable not to disturb databus
    ram1_EN : out std_logic := '1';
    ram1_OE : out std_logic := '1';
    ram1_WE : out std_logic := '1';
    ram1_Databus : inout std_logic_vector(7 downto 0);
    
    --ram2 enable signal
    ram2_EN : out std_logic;
    ram2_OE : out std_logic;
    ram2_WE : out std_logic;
    ram2_Databus : inout std_logic_vector(15 downto 0);
    
    --serial for ram1
    serialDataReady : in std_logic;
    serialRDN : out std_logic;
    serialTBRE : in std_logic;
    serialTSRE : in std_logic;
    serialWRN : out std_logic;
    
    --memAddress for ram2
    memAddress : out std_logic_vector(17 downto 0));
end component;

component MEM_WB is
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
    WriteIn : in  STD_LOGIC);
end component;

--WB

----------------------------------------------------------------------------------

--debug_tube
component tube_encoder is
port(
    key:in std_logic_vector(3 downto 0);
    display:out std_logic_vector(6 downto 0));
end component;


----------------------------------------------------------------------------------
--signal
--IF_PC
    signal IF_PC_output_pc, IF_PC_output_pc_inc : Bus16;
--IF_ID
    signal IF_ID_pc_out : Bus16;
    signal IF_ID_Instruction_out : Bus16;
--ComReg
    signal ComReg_r_data_1, ComReg_r_data_2 : Bus16;
--SpeReg
    signal SpeReg_T_value, SpeReg_RA_value, SpeReg_IH_value,
           SpeReg_SP_value : Bus16;
--Controller
    signal Controller_ins_type_o : InsType;
    signal Controller_alu_op_o : AluOP;
    signal Controller_rreg1_type_o, Controller_rreg2_type_o : RegType;
    signal Controller_rreg1_data_o, Controller_rreg2_data_o : Bus16;
    signal Controller_exted_imm_o : Bus16;
    signal Controller_wreg_en_o, Controller_is_LW_o : std_logic;
    signal Controller_wreg_type_o : RegType;
--ID_EXE
    signal ID_EXE_inst_o : Bus16;
    signal ID_EXE_inst_type_o : InsType;
    signal ID_EXE_alu_op_o : AluOP;
    signal ID_EXE_rreg1_type_o, ID_EXE_rreg2_type_o : RegType;
    signal ID_EXE_rreg1_data_o, ID_EXE_rreg2_data_o : Bus16;
    signal ID_EXE_exted_imm_o : Bus16;
    signal ID_EXE_is_wreg_o : std_logic;
    signal ID_EXE_wreg_type_o : RegType;
    signal ID_EXE_pc_o : Bus16;
--ALU
    signal ALU_res : Bus16;
--BranchCtrl
    signal BranchCtrl_is_Jump : std_logic;
    signal BranchCtrl_pc_o : Bus16;
--Forward
    signal Forward_alu_A_fin_o, Forward_alu_B_fin_o,
           Forward_single_value_fin_o,
           Forward_flag_A_fin_o : Bus16;
--EXE_MEM
    signal EXE_MEM_instruction_o : Bus16;
    signal EXE_MEM_instruction_type_o : InsType;
    signal EXE_MEM_mem_address_o, EXE_MEM_pc_value_o,
           EXE_MEM_mem_data_o : Bus16;
    signal EXE_MEM_mem_read_o, EXE_MEM_mem_write_o : std_logic;
    signal EXE_MEM_wreg_type_o : RegType;
    signal EXE_MEM_wreg_en_o : std_logic;
--MemeryTop
    signal MemeryTop_instrOutput, MemeryTop_dataOutput : Bus16;
--MEM_WB
    signal MEM_WB_Wreg_type_out : RegType;
    signal MEM_WB_Wreg_data_out : Bus16;
    signal MEM_WB_Reg_write_or_not_out : std_logic;
    signal MEM_WB_inst_type_o : InsType;
----------------------------------------------------------------------------------
--clk
    signal cpu_clk : std_logic; --主频，12.5MHz
----------------------------------------------------------------------------------
--const signal
    constant const_write_en : std_logic := WRITE_EN;
    constant const_read_en : std_logic := READ_EN;
    


begin

----------------------------------------------------------------------------------
Unit_IF_PC : IF_PC port map(
    input_pc_inc => IF_PC_output_pc_inc,
    input_pc_change => BranchCtrl_pc_o,
    output_pc => IF_PC_output_pc,
    output_pc_inc => IF_PC_output_pc_inc,
    
    clk => cpu_clk,
    rst => rst,
    WriteIn => const_write_en,
    IS_LW => Controller_is_LW_o,
    IS_JUMP => BranchCtrl_is_Jump);
    
Unit_IF_ID : IF_ID port map(
    pc_in => IF_PC_output_pc_inc,
    Instruction_in => MemeryTop_instrOutput,
    
    pc_out => IF_ID_pc_out,
    Instruction_out => IF_ID_Instruction_out,
    
    clk => cpu_clk,
    rst => rst,
    IS_LW => Controller_is_LW_o,
    IS_JUMP => BranchCtrl_is_Jump,
    WriteIn => const_write_en);
    
Unit_ComReg : ComReg port map(
    rst => rst,
    clk => cpu_clk,
    
    w_type => MEM_WB_Wreg_type_out,
    w_data => MEM_WB_Wreg_data_out,
    we => MEM_WB_Reg_write_or_not_out,
    
    r_addr_1 => IF_ID_Instruction_out(10 downto 8),
    re_1 => const_read_en,
    r_data_1 => ComReg_r_data_1,
    
    r_addr_2 => IF_ID_Instruction_out(7 downto 5),
    re_2 => const_read_en,
    r_data_2 => ComReg_r_data_2);
    
Unit_SpeReg : SpeReg port map(
    clk => cpu_clk,
    rst => rst,
    
    wreg_type_i => MEM_WB_Wreg_type_out,
    wreg_data_i => MEM_WB_Wreg_data_out,
    
    T_value => SpeReg_T_value,
    RA_value => SpeReg_RA_value,
    IH_value => SpeReg_IH_value,
    SP_value => SpeReg_SP_value);
    
Unit_Controller : Controller port map(
    inst_i => IF_ID_Instruction_out,
    
    reg_X_i => ComReg_r_data_1,
    reg_Y_i => ComReg_r_data_2,
    reg_PC_i => IF_ID_pc_out,
    reg_IH_i => SpeReg_IH_value,
    reg_RA_i => SpeReg_RA_value,
    reg_SP_i => SpeReg_SP_value,
    reg_T_i => SpeReg_T_value,
    
    ins_type_o => Controller_ins_type_o,
    
    alu_op_o => Controller_alu_op_o,
    
    rreg1_type_o => Controller_rreg1_type_o,
    rreg1_data_o => Controller_rreg1_data_o,
    rreg2_type_o => Controller_rreg2_type_o,
    rreg2_data_o => Controller_rreg2_data_o,
    exted_imm_o => Controller_exted_imm_o,
    
    wreg_en_o => Controller_wreg_en_o,
    wreg_type_o => Controller_wreg_type_o,
    
    is_LW_o => Controller_is_LW_o);

Unit_ID_EXE : ID_EXE port map(
    clk => cpu_clk,
    rst => rst,
    
    write_EN_i => const_write_en,
    
    inst_i => IF_ID_Instruction_out,
    inst_type_i => Controller_ins_type_o,
    alu_op_i => Controller_alu_op_o,
    rreg1_type_i => Controller_rreg1_type_o,
    rreg1_data_i => Controller_rreg1_data_o,
    rreg2_type_i => Controller_rreg2_type_o,
    rreg2_data_i => Controller_rreg2_data_o,
    exted_imm_i => Controller_exted_imm_o,
    is_wreg_i => Controller_wreg_en_o,
    wreg_type_i => Controller_wreg_type_o,
    
    pc_i => IF_ID_pc_out,
    
    inst_o => ID_EXE_inst_o,
    inst_type_o => ID_EXE_inst_type_o,
    
    alu_op_o => ID_EXE_alu_op_o,
    
    rreg1_type_o => ID_EXE_rreg1_type_o,
    rreg1_data_o => ID_EXE_rreg1_data_o,
    rreg2_type_o => ID_EXE_rreg2_type_o,
    rreg2_data_o => ID_EXE_rreg2_data_o,
    
    exted_imm_o => ID_EXE_exted_imm_o,
    is_wreg_o => ID_EXE_is_wreg_o,
    wreg_type_o => ID_EXE_wreg_type_o,
    
    pc_o => ID_EXE_pc_o);

Unit_ALU : ALU port map(
    in1 => Forward_alu_A_fin_o,
    in2 => Forward_alu_B_fin_o,
    op => ID_EXE_alu_op_o,
    
    res => ALU_res);

Unit_BranchCtrl : BranchCtrl port map(
    inst_i => ID_EXE_inst_o,
    ins_type_i => ID_EXE_inst_type_o,
    pc_i => ID_EXE_pc_o,
    
    alu_res_i => ALU_res,
    flag_i => Forward_flag_A_fin_o,
    
    is_Jump => BranchCtrl_is_Jump,
    pc_o => BranchCtrl_pc_o);

Unit_Forward : Forward port map(
    cur_ins_i => ID_EXE_inst_o,
    cur_ins_type_i => ID_EXE_inst_type_o,
    
    cur_rreg1_type_i => ID_EXE_rreg1_type_o,
    cur_rreg1_data_i => ID_EXE_rreg1_data_o,
    
    cur_rreg2_type_i => ID_EXE_rreg2_type_o,
    cur_rreg2_data_i => ID_EXE_rreg2_data_o,
    
    cur_exted_imm_i => ID_EXE_exted_imm_o,
    
    l_ins_type_i => EXE_MEM_instruction_type_o,
    l_is_wreg_i => EXE_MEM_wreg_en_o,
    l_wreg_type_i => EXE_MEM_wreg_type_o,
    l_wreg_data_i => EXE_MEM_mem_address_o,
    
    ll_ins_type_i => MEM_WB_inst_type_o,
    ll_is_wreg_i => MEM_WB_Reg_write_or_not_out,
    ll_wreg_type_i => MEM_WB_Wreg_type_out,
    ll_wreg_data_i => MEM_WB_Wreg_data_out,
    
    alu_A_fin_o => Forward_alu_A_fin_o,
    alu_B_fin_o => Forward_alu_B_fin_o,
    
    single_value_fin_o => Forward_single_value_fin_o,
    
    flag_A_fin_o => Forward_flag_A_fin_o);
    --flag_B_fin_o => Forward_flag_B_fin_o);

Unit_EXE_MEM : EXE_MEM port map(
    instruction_i => ID_EXE_inst_o,
    instruction_type_in => ID_EXE_inst_type_o,
    alu_result_i => ALU_res,
    single_value_i => Forward_single_value_fin_o,
    pc_value_i => ID_EXE_pc_o,
    wreg_type_i => ID_EXE_wreg_type_o,
    WriteIn => const_write_en,
    wreg_en_i => ID_EXE_is_wreg_o,
    
    instruction_o => EXE_MEM_instruction_o,
    instruction_type_o => EXE_MEM_instruction_type_o,
    mem_address_o => EXE_MEM_mem_address_o,
    pc_value_o => EXE_MEM_pc_value_o,
    mem_data_o => EXE_MEM_mem_data_o,
    mem_read_o => EXE_MEM_mem_read_o,
    mem_write_o => EXE_MEM_mem_write_o,
    
    wreg_en_o => EXE_MEM_wreg_en_o,
    wreg_type_o => EXE_MEM_wreg_type_o,
    
    clk => cpu_clk,
    rst => rst);   
    
Unit_MemoryTop : MemoryTop port map(
    clk => pin_CLK_IN,
    rst => rst,
    cpu_clk => cpu_clk,
    
    instrAddress => IF_PC_output_pc,
    instrOutput => MemeryTop_instrOutput,
    
    dataAddress => EXE_MEM_mem_address_o,
    dataOutput => MemeryTop_dataOutput,
    dataInput => EXE_MEM_mem_data_o,
    
    MemRead => EXE_MEM_mem_read_o,
    MemWrite => EXE_MEM_mem_write_o,
    
    ram1_EN => pin_RAM1_EN,
    ram1_OE => pin_RAM1_OE,
    ram1_WE => pin_RAM1_WE,
    ram1_Databus => pin_RAM1_Data(7 downto 0),
    
    ram2_EN => pin_RAM2_EN,
    ram2_OE => pin_RAM2_OE,
    ram2_WE => pin_RAM2_WE,
    ram2_Databus => pin_RAM2_Data,
    
    serialDataReady => pin_com_data_ready,
    serialRDN => pin_com_rdn,
    serialTBRE => pin_com_tbre,
    serialTSRE => pin_com_tsre,
    serialWRN => pin_com_wrn,
    
    memAddress => pin_RAM2_Addr);
    
Unit_MEM_WB : MEM_WB port map(
    instruction_type_in => EXE_MEM_instruction_type_o,
    MEM_Data_in => MemeryTop_dataOutput,
    ALU_result_in => EXE_MEM_mem_address_o, --mem_address_o <= alu_result_i
    Wreg_type_in => EXE_MEM_wreg_type_o,
    PC_in => EXE_MEM_pc_value_o,
    Reg_write_or_not_in => EXE_MEM_wreg_en_o,
    
    Wreg_type_out => MEM_WB_Wreg_type_out,
    Wreg_data_out => MEM_WB_Wreg_data_out,
    Reg_write_or_not_out => MEM_WB_Reg_write_or_not_out,
    inst_type_o => MEM_WB_inst_type_o,
    
    clk => cpu_clk,
    rst => rst,
    WriteIn => const_write_en);
----------------------------------------------------------------------------------
pin_RAM1_Addr <= ZERO_18;
----------------------------------------------------------------------------------
--debug
    pin_debug_led(15 downto 2) <= MemeryTop_instrOutput(15 downto 2);
    pin_debug_led(1) <= pin_com_tbre;
    pin_debug_led(0) <= pin_com_tsre;
	 
Unit_tube_encoder_1 : tube_encoder port map(
    key => IF_PC_output_pc(7 downto 4),
	display => pin_debug_tube(13 downto 7));
	 
Unit_tube_encoder_2 : tube_encoder port map(
    key => IF_PC_output_pc(3 downto 0),
	display => pin_debug_tube(6 downto 0));

----------------------------------------------------------------------------------
end Behavioral;

