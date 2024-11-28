----------------------------------------------------------------------------------
-- Company: Computer Architecture and System Research (CASR), HKU, Hong Kong
-- Engineer: Mo Song
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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity mcdecoder is
    port (
        din     : IN std_logic_vector(2 downto 0);
        valid   : IN std_logic;
        clr     : IN std_logic;
        clk     : IN std_logic;
        dout    : OUT std_logic_vector(7 downto 0);
        dvalid  : OUT std_logic;
        error   : OUT std_logic);
end mcdecoder;

architecture Behavioral of mcdecoder is
    type state_type is (St_RESET, St_ERROR, St_BOS2, St_BOS3, St_BOS4, St_EOS2, St_EOS3, St_EOS4, St_LISTENING1, St_LISTENING2, St_VALID);
    signal state, next_state : state_type := St_RESET;
    signal half_decode : std_logic_vector(2 downto 0);
begin
    sync_process: process (clk, clr)
    begin
        if clr = '1' then
            state <= St_RESET;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    state_logic: process (state, din, valid)
    begin
        next_state <= state;
        case (state) is
        
        -- 0707
            when St_RESET =>
                dvalid <= '0';
                error <= '0';
                if valid = '1' then
                    if din = "000" then
                        next_state <= St_BOS2;
                    else
                        next_state <= St_ERROR;
                    end if;
                end if;
                
            when St_BOS2 =>
                dvalid <= '0';
                error <= '0';
                if valid = '1' then
                    if din = "111" then
                        next_state <= St_BOS3;
                    else
                        next_state <= St_ERROR;
                    end if;
                end if;
                
            when St_BOS3 =>
                dvalid <= '0';
                error <= '0';
                if valid = '1' then
                    if din = "000" then
                        next_state <= St_BOS4;
                    else
                        next_state <= St_ERROR;
                    end if;
                end if;
                
            when St_BOS4 =>
                dvalid <= '0';
                error <= '0';
                if valid = '1' then
                    if din = "111" then
                        next_state <= St_LISTENING1;
                    else
                        next_state <= St_ERROR;
                    end if;
                end if;
                
        -- Transmitting
            when St_LISTENING1 =>
                dvalid <= '0';
                error <= '0';
                if valid = '1' then
                    if din = "000" then
                        next_state <= St_ERROR;
                    elsif din = "111" then
                        next_state <= St_EOS2;
                    else
                        half_decode <= din;
                        next_state <= St_LISTENING2;
                    end if;
                end if;
                
            when St_LISTENING2 =>
                dvalid <= '0';
                error <= '0';
                if valid = '1' then
                    if din = "001" then    -- H1
                        if half_decode = "010" then  -- V2
                            dout <= "01000001";     -- A
                            next_state <= St_VALID;
                        elsif half_decode = "011" then  -- V3
                            dout <= "01000011";     -- C
                            next_state <= St_VALID;
                        elsif half_decode = "100" then  -- V4
                            dout <= "01000101";     -- E
                            next_state <= St_VALID;
                        elsif half_decode = "101" then  -- V5
                            dout <= "01001001";     -- I
                            next_state <= St_VALID;
                        elsif half_decode = "110" then  -- V6
                            dout <= "01001101";     -- M
                            next_state <= St_VALID;
                        else
                            next_state <= St_ERROR;
                            dvalid <= '0';
                        end if;
                    elsif din = "010" then  -- H2
                        if half_decode = "001" then    -- V1
                            dout <= "01000010";     -- B
                            next_state <= St_VALID;
                        elsif half_decode = "011" then  -- V3
                            dout <= "01000110";     -- F
                            next_state <= St_VALID;
                        elsif half_decode = "100" then  -- V4
                            dout <= "01001010";     -- J
                            next_state <= St_VALID;
                        elsif half_decode = "101" then  -- V5
                            dout <= "01001110";     -- N
                            next_state <= St_VALID;
                        elsif half_decode = "110" then  -- V6
                            dout <= "01010011";     -- S
                            next_state <= St_VALID;
                        else
                            next_state <= St_ERROR;
                            dvalid <= '0';
                        end if;
                    elsif din = "011" then  -- H3
                        if half_decode = "001" then    -- V1
                            dout <= "01000100";     -- D
                            next_state <= St_VALID;
                        elsif half_decode = "010" then  -- V2
                            dout <= "01000111";     -- G
                            next_state <= St_VALID;
                        elsif half_decode = "100" then  -- V4
                            dout <= "01001111";     -- O
                            next_state <= St_VALID;
                        elsif half_decode = "101" then  -- V5
                            dout <= "01010100";     -- T
                            next_state <= St_VALID;
                        elsif half_decode = "110" then  -- V6
                            dout <= "01010111";     -- W
                            next_state <= St_VALID;
                        else
                            next_state <= St_ERROR;
                            dvalid <= '0';
                        end if;
                    elsif din = "100" then  -- H4
                        if half_decode = "001" then    -- V1
                            dout <= "01001000";     -- H
                            next_state <= St_VALID;
                        elsif half_decode = "010" then  -- V2
                            dout <= "01001011";     -- K
                            next_state <= St_VALID;
                        elsif half_decode = "011" then  -- V3
                            dout <= "01010000";     -- P
                            next_state <= St_VALID;
                        elsif half_decode = "101" then  -- V5
                            dout <= "01011000";     -- X
                            next_state <= St_VALID;
                        elsif half_decode = "110" then  -- V6
                            dout <= "00100001";     -- !
                            next_state <= St_VALID;
                        else
                            next_state <= St_ERROR;
                            dvalid <= '0';
                        end if;
                    elsif din = "101" then  -- H5
                        if half_decode = "001" then    -- V1
                            dout <= "01001100";     -- L
                            next_state <= St_VALID;
                        elsif half_decode = "010" then  -- V2
                            dout <= "01010001";     -- Q
                            next_state <= St_VALID;
                        elsif half_decode = "011" then  -- V3
                            dout <= "01010101";     -- U
                            next_state <= St_VALID;
                        elsif half_decode = "100" then  -- V4
                            dout <= "01011001";     -- Y
                            next_state <= St_VALID;
                        elsif half_decode = "110" then  -- V6
                            dout <= "00100000";     -- SPACE
                            next_state <= St_VALID;
                        else
                            next_state <= St_ERROR;
                            dvalid <= '0';
                        end if;
                    elsif din = "110" then  -- H6
                        if half_decode = "001" then    -- V1
                            dout <= "01010010";     -- R
                            next_state <= St_VALID;
                        elsif half_decode = "010" then  -- V2
                            dout <= "01010110";     -- V
                            next_state <= St_VALID;
                        elsif half_decode = "011" then  -- V3
                            dout <= "01011010";     -- Z
                            next_state <= St_VALID;
                        elsif half_decode = "100" then  -- V4
                            dout <= "00101110";     -- .
                            next_state <= St_VALID;
                        elsif half_decode = "101" then  -- V5
                            dout <= "00111111";     -- ?
                            next_state <= St_VALID;
                        else
                            next_state <= St_ERROR;
                            dvalid <= '0';
                        end if;
                    else
                        next_state <= St_ERROR;
                    end if;
                end if;
                
            when St_VALID =>
                dvalid <= '1';
                error <= '0';
                next_state <= St_LISTENING1;
                
        -- 7070
            when St_EOS2 =>
                dvalid <= '0';
                error <= '0';
                if valid = '1' then
                    if din = "000" then
                        next_state <= St_EOS3;
                    else
                        next_state <= St_ERROR;
                    end if;
                end if;
                
            when St_EOS3 =>
                dvalid <= '0';
                error <= '0';
                if valid = '1' then
                    if din = "111" then
                        next_state <= St_EOS4;
                    else
                        next_state <= St_ERROR;
                    end if;
                end if;
                
            when St_EOS4 =>
                dvalid <= '0';
                error <= '0';
                if valid = '1' then
                    if din = "000" then
                        next_state <= St_RESET;
                    else
                        next_state <= St_ERROR;
                    end if;
                end if;
                
        -- Error
            when St_ERROR =>
                dvalid <= '0';
                error <= '1';
                dout <= "00000000";
                next_state <= St_RESET;
        end case;
    end process;

end Behavioral;

