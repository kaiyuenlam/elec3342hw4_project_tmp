----------------------------------------------------------------------------------
-- Company: Computer Architecture and System Research (CASR), HKU, Hong Kong
-- Engineer: Jiajun Wu, Mo Song
-- 
-- Create Date: 09/09/2022 06:20:56 PM
-- Design Name: system top with a signal generator module
-- Module Name: sys_top - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity sim_top is
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
end sim_top;

architecture Behavioral of sim_top is
    component symb_det is
        Port (  clk         : in STD_LOGIC; -- input clock 96kHz
                clr         : in STD_LOGIC; -- input synchronized reset
                adc_data    : in STD_LOGIC_VECTOR(11 DOWNTO 0); -- input 12-bit ADC data
                symbol_valid: out STD_LOGIC;
                symbol_out  : out STD_LOGIC_VECTOR(2 DOWNTO 0) -- output 3-bit detection symbol
                );
    end component symb_det;
    component mcdecoder is
        port (
                din     : IN std_logic_vector(2 downto 0);
                valid   : IN std_logic;
                clr     : IN std_logic;
                clk     : IN std_logic;
                dout    : OUT std_logic_vector(7 downto 0);
                dvalid  : OUT std_logic;
                error   : OUT std_logic);
    end component mcdecoder;
    component myuart is
        Port ( 
            din : in STD_LOGIC_VECTOR (7 downto 0);
            busy: out STD_LOGIC;
            wen : in STD_LOGIC;
            sout : out STD_LOGIC;
            clr : in STD_LOGIC;
            clk : in STD_LOGIC);
    end component myuart;
    
    component dpop is
    Port ( clk : in STD_LOGIC;
           clr : in STD_LOGIC;
           fifo_empty : in STD_LOGIC;
           fifo_rd_en : out STD_LOGIC;
           fifo_wr_en : out STD_LOGIC;
           fifo_dout : in STD_LOGIC_VECTOR(7 DOWNTO 0);
           tx_wen : out STD_LOGIC;
           tx_busy : in STD_LOGIC);
    end component dpop;
    
    component fifo is
    Port (  rst : IN STD_LOGIC;
            wr_clk : IN STD_LOGIC;
            rd_clk : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC);
    end component fifo;
    
    signal symbol_valid     : STD_LOGIC;
    signal symbol_out       : STD_LOGIC_VECTOR(2 DOWNTO 0); -- output 3-bit detection symbol 
    signal dout             : STD_LOGIC_VECTOR(7 downto 0);
    signal dvalid          : STD_LOGIC;
    signal error            : STD_LOGIC;
    signal tx_busy          : STD_LOGIC;
    signal tx_wen           : STD_LOGIC;
    signal fifo_wr_clk      : STD_LOGIC;
    signal fifo_dout        : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal fifo_full        : STD_LOGIC;
    signal fifo_empty       : STD_LOGIC;
    signal fifo_rd_en       : STD_LOGIC;
    signal fifo_wr_en       : STD_LOGIC;
    signal fifo_force_wr    : STD_LOGIC;
begin

--For debug
sd_symbol_valid <= symbol_valid;
sd_symbol_out <= symbol_out;
md_dout <= dout;
md_dvalid <= dvalid;
md_error <= error;
fifo_emp <= fifo_empty;


led_busy <= tx_busy;
fifo_wr_clk <= not clk;
fifo_wr_en <= dvalid or fifo_force_wr;

    fifo_inst: fifo port map (
        rst     => clr, 
        wr_clk  => fifo_wr_clk, 
        rd_clk  => clk, 
        din     => dout, 
        wr_en   => fifo_wr_en,
        rd_en   => fifo_rd_en, 
        dout    => fifo_dout, 
        full    => fifo_full, 
        empty   => fifo_empty
    );
    
    dpop_inst: dpop port map (
        clk         => clk,
        clr         => clr,
        fifo_empty  => fifo_empty, 
        fifo_rd_en  => fifo_rd_en,
        fifo_wr_en  => fifo_force_wr,
        fifo_dout   => fifo_dout,
        tx_wen      => tx_wen, 
        tx_busy     => tx_busy
    );

    symb_det_inst: symb_det port map (
        clk         => clk, 
        clr         => clr, 
        adc_data    => adc_data, 
        symbol_valid=> symbol_valid, 
        symbol_out  => symbol_out
    );

    mcdecoder_inst: mcdecoder port map (
        din     => symbol_out, 
        valid   => symbol_valid, 
        clr     => clr, 
        clk     => clk, 
        dout    => dout, 
        dvalid  => dvalid,
        error   => error
    );

    myuart_inst: myuart port map (
        din     => fifo_dout,
        busy    => tx_busy,
        wen     => tx_wen,
        sout    => sout,
        clr     => clr,
        clk     => clk
    );

end Behavioral;
