----------------------------------------------------------------------------------
-- Company: Computer Architecture and System Research (CASR), HKU, Hong Kong
-- Engineer: Jiajun Wu, Mo Song
-- 
-- Create Date: 09/09/2022 06:20:56 PM
-- Design Name: system top
-- Module Name: top - Behavioral
-- Project Name: Music Decoder
-- Target Devices: Xilinx Basys3
-- Tool Versions: Vivado 2022.1
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

use STD.textio.all;
use ieee.std_logic_textio.all;

entity sim_top_tb is
--  Port ( );
end sim_top_tb;

architecture Behavioral of sim_top_tb is
    component sim_top is
        Port (  
            clk         : in STD_LOGIC; -- input clock 96kHz
            clr         : in STD_LOGIC; -- input synchronized reset
            adc_data    : in STD_LOGIC_VECTOR(11 DOWNTO 0);
            sout        : out STD_LOGIC;
            led_busy    : out STD_LOGIC;
      -- For dubug
            sd_symbol_valid   : out STD_LOGIC;
            sd_symbol_out   : out STD_LOGIC_VECTOR(2 DOWNTO 0);
            md_dout    : OUT std_logic_vector(7 downto 0);
            md_dvalid  : OUT std_logic;
            md_error   : OUT std_logic;
            fifo_emp   : OUT std_logic
        );
    end component sim_top;

    file file_VECTORS   : text;

    constant clkPeriod  : time := 10 ns;
    constant ADC_WIDTH  : integer := 12;
    constant SAMPLE_LEN : integer := 168000;
    
    signal clk          : std_logic;
    signal clr          : std_logic;
    signal adc_data     : std_logic_vector(11 downto 0);
    signal sample_cnt   : integer := 0;
    signal sout         : std_logic;
    signal led_busy     : std_logic;
    -- For dubug
    signal sd_symbol_valid   : STD_LOGIC;
    signal sd_symbol_out   : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal md_dout    : std_logic_vector(7 downto 0);
    signal md_dvalid  : std_logic;
    signal md_error   : std_logic;
    signal fifo_empty : STD_LOGIC;

    -- sine wave signal
    type wave_array is array (0 to SAMPLE_LEN-1) of std_logic_vector (ADC_WIDTH-1 downto 0);
    signal input_wave: wave_array;
begin

    sim_top_inst: sim_top port map(
        clk         => clk,
        clr         => clr,
        adc_data    => adc_data,
        sout        => sout,
        led_busy    => led_busy,
        --For dubug
        sd_symbol_valid   =>  sd_symbol_valid,
        sd_symbol_out     =>  sd_symbol_out,
        md_dout           =>  md_dout,
        md_dvalid         =>  md_dvalid,
        md_error          =>  md_error,
        fifo_emp          =>  fifo_empty
    );

    proc_init_array: process
        -- variable input_wave_temp: wave_array;
        variable wave_amp   : std_logic_vector(ADC_WIDTH-1 downto 0);
        variable line_index : integer := 0;
        variable v_ILINE    : line;
    begin
        
        file_open(file_VECTORS, "info_wave.txt", read_mode);
        for i in 0 to (SAMPLE_LEN-1) loop
            readline(file_VECTORS, v_ILINE);
            read(v_ILINE, wave_amp);
            input_wave(i) <= wave_amp;
        end loop;
        wait;
    end process proc_init_array;

    -- clock process
    proc_clk: process
    begin
        clk <= '0';
        wait for clkPeriod/2;
        clk <= '1';
        wait for clkPeriod/2;
    end process proc_clk;

    proc_clr: process
    begin
        clr <= '1', '0' after clkPeriod;
        wait;
    end process proc_clr;

    proc_adc_data: process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                adc_data <= (others=>'0');
            else
                adc_data <= input_wave(sample_cnt);
            end if;
        end if;
    end process proc_adc_data;

    proc_sample_cnt: process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                sample_cnt <= 0;
            elsif (sample_cnt = SAMPLE_LEN - 1) then 
                sample_cnt <= 0;
            else 
                sample_cnt <= sample_cnt + 1;
            end if;
        end if;
    end process proc_sample_cnt;

end Behavioral;
