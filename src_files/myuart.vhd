----------------------------------------------------------------------------------
-- Company: Computer Architecture and System Research (CASR), HKU, Hong Kong
-- Engineer:
-- 
-- Create Date: 09/09/2022 06:20:56 PM
-- Design Name: system top
-- Module Name: uart
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity myuart is
    Port ( 
           din : in STD_LOGIC_VECTOR (7 downto 0);
           busy: out STD_LOGIC;
           wen : in STD_LOGIC;
           sout : out STD_LOGIC;
           clr : in STD_LOGIC;
           clk : in STD_LOGIC);
end myuart;

architecture rtl of myuart is
    signal baud_clk_cnt : unsigned(3 downto 0) := "1001";
    
    signal buff : std_logic_vector(7 downto 0);
    signal tx_seq : unsigned(3 downto 0);
    signal tx_en : std_logic;
begin
    uart_proc : process(clk, clr, tx_en, wen)
    begin
        if clr = '1' then
            tx_en <= '0';
        end if;
        
        if tx_en = '0' then
            busy <= '0';
            sout <= '1';
            if wen = '1' then
                buff <= din;
                tx_seq <= "0000";
                tx_en <= '1';
            end if;
        else
            if rising_edge(clk) then
                if baud_clk_cnt < 9 then
                    baud_clk_cnt <= baud_clk_cnt + 1;
                else
                    if tx_seq = 0 then
                        busy <= '1';
                        sout <= '0';
                    elsif tx_seq = 1 then
                        sout <= buff(0);
                    elsif tx_seq = 2 then
                        sout <= buff(1);
                    elsif tx_seq = 3 then
                        sout <= buff(2);
                    elsif tx_seq = 4 then
                        sout <= buff(3);
                    elsif tx_seq = 5 then
                        sout <= buff(4);
                    elsif tx_seq = 6 then
                        sout <= buff(5);
                    elsif tx_seq = 7 then
                        sout <= buff(6);
                    elsif tx_seq = 8 then
                        sout <= buff(7);
                    elsif tx_seq = 9 then
                        sout <= '1';
                    elsif tx_seq = 10 then
                        tx_en <= '0';
                    end if;
                    tx_seq <= tx_seq + 1;
                    baud_clk_cnt <= "0000";
                end if;
            end if;
        end if;
    end process;
end rtl;
