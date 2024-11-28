----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.11.2024 07:16:20
-- Design Name: Lam Kai Yuen Kelvin
-- Module Name: dpop - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dpop is
    Port ( clk : in STD_LOGIC;
           clr : in STD_LOGIC;
           fifo_empty : in STD_LOGIC;
           fifo_rd_en : out STD_LOGIC;
           fifo_wr_en : out STD_LOGIC;
           fifo_dout : in STD_LOGIC_VECTOR(7 DOWNTO 0);
           tx_wen : out STD_LOGIC;
           tx_busy : in STD_LOGIC);
end dpop;

architecture Behavioral of dpop is
    type state_type is (IDLE, RD_CHK, RETRY, SEND);
    signal state, next_state : state_type := IDLE;
    signal rerd : STD_LOGIC := '0';
begin
--tx_wen <= not fifo_empty and not tx_busy;
--fifo_rd_en <= not fifo_empty and not tx_busy;
    sync_process: process (clk, clr)
    begin
        if clr = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;
    
    state_logic: process (state, fifo_empty, tx_busy, fifo_dout)
    begin
        next_state <= state;
        case (state) is
            when IDLE =>
                fifo_rd_en <= '0';
                fifo_wr_en <= '0';
                tx_wen <= '0';
                if fifo_empty = '0' and tx_busy = '0' then
                    next_state <= RD_CHK;
                end if;
            
            when RD_CHK =>
                fifo_rd_en <= '1';
                fifo_wr_en <= '0';
                tx_wen <= '0';
                if rerd = '0' then
                    next_state <= RETRY;
                else
                    next_state <= SEND;
                end if;
            
            when SEND =>
                rerd <= '0';
                fifo_rd_en <= '0';
                fifo_wr_en <= '0';
                tx_wen <= '1';
                next_state <= IDLE;
            
            when RETRY =>
                rerd <= '1';
                fifo_rd_en <= '0';
                fifo_wr_en <= '1';
                tx_wen <= '0';
                next_state <= IDLE;
            
        end case;
    end process;
end Behavioral;

