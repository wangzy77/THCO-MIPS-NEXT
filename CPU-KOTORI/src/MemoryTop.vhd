library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library WORK;
use WORK.util.ALL;

entity MemoryTop is
	Port(
		--clock 
		clk_50MHz : in std_logic;
        clk_11Mhz : in std_logic;
        clk_hand : in std_logic;
		rst : in std_logic;
        cpu_clk : out std_logic := '1';
        key_in : in Bus16;
		
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
end MemoryTop;

architecture Behavioral of MemoryTop is

component Divider is
port(clkin : in std_logic;
     clkout : out std_logic;
     key_in : in std_logic_vector(3 downto 0)
     );
end component;
	
	--state machine
	type State is (
		boot, instrRead, idel1, dataRW, idel2
	);
	
	--signal defination
	signal now_state : State := instrRead;
	signal instrBuffer : std_logic_vector(15 downto 0) := INSTRUCTION_NOP;
	signal dataBuffer : std_logic_vector(15 downto 0) := "0000000000000000";
	signal tempAddress : std_logic_vector(15 downto 0);
	signal BF01 : std_logic_vector(15 downto 0);
	signal flag_mem : std_logic;
	signal flag_serial : std_logic;
	signal memHolder : std_logic_vector(15 downto 0);
	signal serialHolder : std_logic_vector(7 downto 0);
    
    signal debug_ram1_databus : std_logic_vector(7 downto 0);
    signal mem_clk : std_logic := '1';
    signal debug_clk_from_div : std_logic := '1';
	
begin
	
	--memory part
	
	instrOutput <= instrBuffer;
	dataOutput <= dataBuffer;
	
	ram1_EN <= '1';
	ram1_OE <= READ_DIS;
	ram1_WE <= WRITE_DIS;
	
	ram2_EN <= '0';
	ram2_OE <= MemRead when (now_state = idel1 or now_state = dataRW or now_state = idel2) else READ_EN;
	ram2_WE <= MemWrite when now_state = dataRW else WRITE_DIS;
	
	memAddress <= "00" & tempAddress;
	with now_state select
		tempAddress <=
			instrAddress when boot | instrRead,
			dataAddress when dataRW | idel1 | idel2;
	
	with now_state select
		flag_mem <= 
			MemWrite when idel1 | dataRW,
			WRITE_DIS when others;
            
    with key_in(3 downto 0) select
    mem_clk <=
        clk_hand when "1111",
        clk_50MHz when "0000",
        clk_11Mhz when "0001",
        debug_clk_from_div when others;
	
	-- memHolder <= dataInput;
	
	ram2_Databus <= dataInput when flag_mem = WRITE_EN else "ZZZZZZZZZZZZZZZZ";

	
	--serial part
	
	BF01(0) <= serialTBRE and serialTSRE;
	BF01(1) <= serialDataReady;
	BF01(15 downto 2) <= "00000000000000";
	
	serialWRN <= MemWrite when (dataAddress = x"BF00" and now_state = dataRW) else WRITE_DIS;
	serialRDN <= MemRead when (dataAddress = x"BF00" and ( (now_state = idel1) or (now_state = dataRW) or (now_state = idel2) ) ) else READ_DIS;
	
	with now_state select
		flag_serial <= 
			MemWrite when idel1 | dataRW | idel2,
			WRITE_DIS when others;
	
	serialHolder <= dataInput(7 downto 0);
	
	ram1_Databus <= dataInput(7 downto 0) when (flag_serial = WRITE_EN) else "ZZZZZZZZ";
    debug_ram1_databus <= dataInput(7 downto 0) when (flag_serial = WRITE_EN) else "ZZZZZZZZ";
	
	process(mem_clk, rst)
	
	begin
		
		if (rst = RST_EN) then
			now_state <= boot;
		elsif (mem_clk'event and mem_clk = '0') then 
			case now_state is
				when boot =>
					now_state <= instrRead;
                    cpu_clk <= '0';
				when instrRead =>
					now_state <= idel1;
					instrBuffer <= ram2_Databus;
				when idel1 =>
					now_state <= dataRW;
                    cpu_clk <= '1';
				when dataRW =>
					now_state <= idel2;
					case dataAddress is
						when x"BF00" =>
							dataBuffer <= "00000000" & ram1_Databus;
						when x"BF01" =>
							dataBuffer <= BF01;
						when others =>
							dataBuffer <= ram2_Databus;
					end case;
				when others =>
					now_state <= instrRead;
                    cpu_clk <= '0';
			end case;
		end if;
	
	end process;
    
    
    Unit_Divider : Divider port map(
        clkin => clk_50MHz,
        clkout => debug_clk_from_div,
        key_in => key_in(3 downto 0));
	
end Behavioral;
	
	