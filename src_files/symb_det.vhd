----------------------------------------------------------------------------------
-- Company: Computer Architecture and System Research (CASR), HKU, Hong Kong
-- Engineer: Jiajun Wu
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity symb_det is
    Port (  clk: in STD_LOGIC; -- input clock 96kHz
            clr: in STD_LOGIC; -- input synchronized reset
            adc_data: in STD_LOGIC_VECTOR(11 DOWNTO 0); -- input 12-bit ADC data
            symbol_valid: out STD_LOGIC;
            symbol_out: out STD_LOGIC_VECTOR(2 DOWNTO 0) -- output 3-bit detection symbol
            );
end symb_det;

architecture Behavioral of symb_det is
    signal det_clk : unsigned(15 downto 0) := x"1770";
    signal det_trig, det_en, cnt_en : std_logic := '0';
    signal  last_adc : std_logic_vector(11 downto 0) := (others => '0');
    signal sym_cnt , latest_sym_cnt: unsigned(7 downto 0) := (others => '0');
    signal det_delay : unsigned(11 downto 0) := (others => '0');
begin
    det_delay_proc : process(det_delay, clk)
    begin
        if rising_edge(clk) then
            if det_delay < 1500 then
                det_en <= '0';
                det_delay <= det_delay + 1;
            else
                det_en <= '1';
            end if;
        end if;
    end process;
    
    det_clk_proc : process(det_clk, clk)
    begin
        if rising_edge(clk) and (det_en = '1') then
            if det_clk < 6000 then
                det_trig <= '0';
                det_clk <= det_clk + 1;
            else
                det_trig <= '1';
                det_clk <= (others => '0');
            end if;
        end if;
    end process;
    
    det_proc : process(det_trig, clr, latest_sym_cnt, det_en)
    begin
        if clr = '1' then
            symbol_out <= (others => '0');
            symbol_valid <= '0';
        elsif rising_edge(det_trig) then
            symbol_valid <= '1';
            
            if (latest_sym_cnt >= 40) and (latest_sym_cnt < 50) then
                symbol_out <= "000";
            elsif (latest_sym_cnt >= 50) and (latest_sym_cnt < 60) then
                symbol_out <= "001";
            elsif (latest_sym_cnt >= 63) and (latest_sym_cnt < 73) then
                symbol_out <= "010";
            elsif (latest_sym_cnt >= 76) and (latest_sym_cnt < 86) then
                symbol_out <= "011";
            elsif (latest_sym_cnt >= 92) and (latest_sym_cnt < 102) then
                symbol_out <= "100";
            elsif (latest_sym_cnt >= 117) and (latest_sym_cnt < 127) then
                symbol_out <= "101";
            elsif (latest_sym_cnt >= 140) and (latest_sym_cnt < 150) then
                symbol_out <= "110";
            elsif (latest_sym_cnt >= 178) and (latest_sym_cnt < 188) then
                symbol_out <= "111";
            end if;
        else
            symbol_valid <= '0';
        end if;
    end process;
    
    sam_proc : process(clk, last_adc, adc_data)
    begin
        if rising_edge(clk) then
            if (last_adc > x"7FF") and (adc_data <= x"7FF") then
                if sym_cnt /= x"00" then
                    latest_sym_cnt <= sym_cnt;
                end if;
                cnt_en <= not cnt_en;
            end if;
            last_adc <= adc_data;
        end if;
    end process;
    
    sym_cnt_proc : process(clk, cnt_en)
    begin
        if rising_edge(clk) then
            if cnt_en = '1' then
                sym_cnt <= sym_cnt + 1;
            else
                sym_cnt <= (others => '0');
            end if;
        end if;
    end process;
end Behavioral;
