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
    cpu_clk : out std_logic := '0';
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
    memAddress : out std_logic_vector(17 downto 0);
    
    -- port for flash
    flash_byte : out std_logic;
    flash_vpen : out std_logic;
    flash_ce : out std_logic;
    flash_oe : out std_logic;
    flash_we : out std_logic;
    flash_rp : out std_logic;
    flash_addr : out std_logic_vector(22 downto 1);
    flash_data : inout std_logic_vector(15 downto 0);
    
    debug_led_state :out std_logic_vector(3 downto 0);
    
    --connection with keyboard
    -- char
    keyboard_data : in std_logic_vector(7 downto 0);
    keyboard_dataready : in std_logic;
    keyboard_wrn : out std_logic;
    
    --connection with vga
    VGA_addr : out std_logic_vector(10 downto 0);
    VGA_write : out std_LOGIC_vector(0 downto 0);
    VGA_char : out std_logic_vector(7 downto 0)
);
end MemoryTop;

architecture Behavioral of MemoryTop is
----------------------------------------------------------------------------------
-- component
component Divider is
port(
    clkin : in std_logic;
    clkout : out std_logic;
    key_in : in std_logic_vector(3 downto 0));
end component;

component flash_io is
port(
    -- 字模式下为22-1，字节模式为22-0
    addr: in std_logic_vector(22 downto 1);
    datain: in std_logic_vector(15 downto 0);
    dataout: out std_logic_vector(15 downto 0);
    
    clk: in std_logic;
    reset: in std_logic;
    
    -- hard port connecting flash chip
    flash_byte : out std_logic;
    flash_vpen : out std_logic;
    flash_ce : out std_logic;
    flash_oe : out std_logic;
    flash_we : out std_logic;
    flash_rp : out std_logic;
    flash_addr : out std_logic_vector(22 downto 1);
    flash_data : inout std_logic_vector(15 downto 0);
    
    -- signal to vhdl entity
    ctl_read : in  std_logic;
    ctl_write : in  std_logic;
    ctl_erase : in std_logic);
end component;

component mychar_to_ascii is
port(
    mychar_i : in std_logic_vector(7 downto 0);
    ascii_o : out std_logic_vector(7 downto 0));
end component;

----------------------------------------------------------------------------------
	
	--state machine
	type State is (
        -- boot CM
        boot, boot_flash, boot_ram1, boot_ram2, boot_ready,
        -- cpu CM
		instrRead, idel1, dataRW, idel2);
	
	--signal defination
	signal now_state : State := boot;
	signal instrBuffer : std_logic_vector(15 downto 0) := INSTRUCTION_NOP;
	signal dataBuffer : std_logic_vector(15 downto 0) := "0000000000000000";
	signal tempAddress : std_logic_vector(15 downto 0);
	signal BF01, BF03 : std_logic_vector(15 downto 0);
	signal flag_mem : std_logic;
	signal flag_serial : std_logic;
	signal memHolder : std_logic_vector(15 downto 0);
	signal serialHolder : std_logic_vector(7 downto 0);
    
    signal mem_clk : std_logic := '1';
    signal debug_clk_from_div : std_logic := '1';
    
--------------------------------------------------
-- signal for flash
	signal flash_ctl_read, flash_ctl_write, flash_ctl_erase : std_logic;
	signal flash_addr_input : std_logic_vector(22 downto 1);
	signal flash_data_input : std_logic_vector(15 downto 0);
	signal flash_data_output : std_logic_vector(15 downto 0);
	-- use for sleep to wait for data actually
	signal flash_addr_count: std_logic_vector(7 downto 0);
	signal flash_pc : std_logic_vector(15 downto 0) := x"FFFF";
	signal flash_hold_data : STD_LOGIC_VECTOR(15 downto 0);
    
--------------------------------------------------
-- signal for keyboard
    signal char2ascii : std_LOGIC_vector(7 downto 0);


----------------------------------------------------------------------------------	
begin

--debug
    with now_state select
        debug_led_state <=
            "0000" when boot,
            "0001" when boot_flash,
            "0010" when boot_ram1,
            "0011" when boot_ram2,
            "0100" when boot_ready,
            
            "1000" when instrRead,
            "1001" when idel1,
            "1010" when dataRW,
            "1011" when idel2,
            
            "1111" when others;
   
--------------------------------------------------
-- cpu_clk
    with now_state select
        cpu_clk <=
            '0' when idel1 | instrRead,
            '1' when others;
   
--------------------------------------------------
	--memory part
	
	instrOutput <= instrBuffer;
	dataOutput <= dataBuffer;
	
	ram1_EN <= '1';
	ram1_OE <= READ_DIS;
	ram1_WE <= WRITE_DIS;
	
	ram2_EN <= '0';
    
    with now_state select
        ram2_OE <= 
            MemRead when idel1 | dataRW | idel2,
            READ_DIS when boot_flash | boot_ram1 | boot_ram2,
            READ_EN when others;
	-- ram2_OE <= MemRead when (now_state = idel1 or now_state = dataRW or now_state = idel2) else READ_EN;
	
    ram2_WE <= 
        WRITE_DIS when (dataAddress = x"BF00" and now_state = dataRW) else
        MemWrite when now_state = dataRW else 
        WRITE_EN when (now_state = boot_ram2) else
        WRITE_DIS;
	
	memAddress <= "00" & tempAddress;
	with now_state select
		tempAddress <=
			instrAddress when boot_ready | instrRead,
			dataAddress when dataRW | idel1 | idel2,
            flash_pc when boot_flash | boot_ram1 | boot_ram2,
            x"0000" when others;
	
	with now_state select
		flag_mem <= 
			MemWrite when idel1 | dataRW,
            WRITE_EN when boot_ram1 | boot_ram2,
			WRITE_DIS when others;
            
    with key_in(3 downto 0) select
        mem_clk <=
            clk_hand when "1111",
            clk_50MHz when "0000",
            clk_11Mhz when "0010",
            debug_clk_from_div when others;
	
	-- memHolder <= dataInput;
	
	ram2_Databus <= 
        flash_hold_data when (now_state = boot_flash or now_state = boot_ram1 or now_state = boot_ram2)
        else 
        dataInput when (flag_mem = WRITE_EN)
        else "ZZZZZZZZZZZZZZZZ";

--------------------------------------------------
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

--------------------------------------------------
-- flash part
    -- design: will never write or erase flash
	flash_ctl_write <= WRITE_DIS;
	flash_ctl_erase <= WRITE_DIS;
	
	-- when boot_flash then drop down ctl_read to read data from flash
	with now_state select
		flash_ctl_read <= 
			READ_EN when boot_flash,
			READ_DIS when others;
            
--------------------------------------------------
-- keyboard part
    keyboard_wrn <=
        (not MemRead) when ((dataAddress = x"BF02") and (now_state = idel2))
        else '0';
    BF03(0) <= keyboard_dataready;
    BF03(15 downto 1) <= "000000000000000";
    
--------------------------------------------------
-- VGA
    VGA_addr <= dataAddress(10 downto 0);
    VGA_char <= dataInput(7 downto 0);
    VGA_write <=
        "1" when ((MemWrite = '0') and (now_state = dataRW) and (dataAddress(15 downto 12) = x"F"))
        else "0";
    
--------------------------------------------------
-- main control
	
	process(mem_clk, rst)
	
	begin
		
		if (rst = RST_EN) then
			now_state <= boot;
		elsif (mem_clk'event and mem_clk = '0') then 
			case now_state is
            
                -- boot from flash
				when boot =>
                    flash_addr_count <= x"00";
					now_state <= boot_ready;    --boot_flash;
                when boot_flash =>
                    case flash_addr_count is
                        when x"00" =>
                            flash_addr_input <= flash_pc + 1;
                            flash_pc <= flash_pc + 1;
                            flash_addr_count <= flash_addr_count + 1;
                        when x"FF" =>
                            flash_hold_data <= flash_data_output;
                            flash_addr_count <= x"00";
                            now_state <= boot_ram1;
                        when others =>
                            flash_addr_count <= flash_addr_count + 1;
                    end case;
                when boot_ram1 =>
                    now_state <= boot_ram2;
                when boot_ram2 =>
                    if(flash_pc < MAX_INS_FROM_FLASH) then
                        now_state <= boot_flash;
                    else
                        now_state <= boot_ready;
                    end if;
                when boot_ready => 
                    now_state <= instrRead;
                    -- cpu_clk <= '0';
                
                    

                -- cpu circle
				when instrRead =>
					now_state <= idel1;
					instrBuffer <= ram2_Databus;
				when idel1 =>
					now_state <= dataRW;
                    -- cpu_clk <= '1';
				when dataRW =>
					now_state <= idel2;
					case dataAddress is
						when x"BF00" =>
							dataBuffer <= "00000000" & ram1_Databus;
						when x"BF01" =>
							dataBuffer <= BF01;
                        when x"BF02" =>
                            dataBuffer <= ZERO_8 & keyboard_data;
                        when x"BF03" =>
                            dataBuffer <= BF03;
						when others =>
							dataBuffer <= ram2_Databus;
					end case;
				when others =>
					now_state <= instrRead;
                    -- cpu_clk <= '0';
			end case;
		end if;
	
	end process;
----------------------------------------------------------------------------------
-- component
Unit_Divider : Divider port map(
    clkin => clk_50MHz,
    clkout => debug_clk_from_div,
    key_in => key_in(3 downto 0));
    
Unit_flash_io : flash_io port map(
    addr => flash_addr_input,
    datain => flash_data_input,
    dataout => flash_data_output,
    
    clk => mem_clk,
    reset => rst,
    
    -- hard port
    flash_byte => flash_byte,
    flash_vpen => flash_vpen,
    flash_ce => flash_ce,
    flash_oe => flash_oe,
    flash_we => flash_we,
    flash_rp => flash_rp,
    flash_addr => flash_addr,
    flash_data => flash_data,

    -- signal to vhdl entity
    ctl_read => flash_ctl_read,
    ctl_write => flash_ctl_write,
    ctl_erase => flash_ctl_erase);
    
Unit_mychar_to_ascii : mychar_to_ascii port map(
    mychar_i => keyboard_data,
    ascii_o => char2ascii);
	
end Behavioral;
	
	