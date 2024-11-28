----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.11.2024 07:47:56
-- Design Name: 
-- Module Name: fifo - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fifo is
    Generic (
        FIFO_DEPTH : integer := 16; -- Depth of the FIFO
        DATA_WIDTH : integer := 8  -- Width of the data
    );
    Port (
        rst     : in  STD_LOGIC; -- Reset signal
        wr_clk  : in  STD_LOGIC; -- Write clock
        rd_clk  : in  STD_LOGIC; -- Read clock
        din     : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- Data input
        wr_en   : in  STD_LOGIC; -- Write enable
        rd_en   : in  STD_LOGIC; -- Read enable
        dout    : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- Data output
        full    : out STD_LOGIC; -- FIFO full flag
        empty   : out STD_LOGIC  -- FIFO empty flag
    );
end fifo;

architecture Behavioral of fifo is

    -- FIFO memory declaration
    type fifo_array is array (0 to FIFO_DEPTH-1) of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal fifo_mem : fifo_array := (others => (others => '0'));

    -- Write and read pointers
    signal wr_ptr : integer range 0 to FIFO_DEPTH-1 := 0;
    signal rd_ptr : integer range 0 to FIFO_DEPTH-1 := 0;

    -- Write and read counters
    signal wr_count : integer range 0 to FIFO_DEPTH := 0;
    signal rd_count : integer range 0 to FIFO_DEPTH := 0;

begin

    -- Write Process
    process(wr_clk, rst)
    begin
        if rst = '1' then
            wr_ptr <= 0;
            wr_count <= 0;
        elsif rising_edge(wr_clk) then
            if wr_en = '1' and wr_count < FIFO_DEPTH then
                fifo_mem(wr_ptr) <= din;  -- Write data to FIFO
                wr_ptr <= (wr_ptr + 1) mod FIFO_DEPTH; -- Increment write pointer
                wr_count <= wr_count + 1; -- Increment write count
            end if;
        end if;
    end process;

    -- Read Process
    process(rd_clk, rst)
    begin
        if rst = '1' then
            rd_ptr <= 0;
            rd_count <= 0;
            dout <= (others => '0'); -- Clear output on reset
        elsif rising_edge(rd_clk) then
            if rd_en = '1' and rd_count < wr_count then
                dout <= fifo_mem(rd_ptr); -- Read data from FIFO
                rd_ptr <= (rd_ptr + 1) mod FIFO_DEPTH; -- Increment read pointer
                rd_count <= rd_count + 1; -- Increment read count
            end if;
        end if;
    end process;

    -- Full flag logic
    full <= '1' when (wr_count - rd_count) = FIFO_DEPTH else '0';

    -- Empty flag logic
    empty <= '1' when wr_count = rd_count else '0';

end Behavioral;
