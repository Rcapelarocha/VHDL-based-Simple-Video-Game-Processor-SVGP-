library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_core is
    Port (
        clk        : in  STD_LOGIC;                     -- 50 MHz input clock
        DAC_CLK    : out STD_LOGIC;                     -- 25 MHz VGA pixel clock
        H, V       : out STD_LOGIC;                     -- sync signals
        video_on   : out STD_LOGIC;                     -- high when pixel is visible
        x, y       : out INTEGER range 0 to 639         -- current pixel coordinates
    );
end vga_core;

architecture Behavioral of vga_core is
    signal pix_clk : STD_LOGIC := '0';
    signal h_count : INTEGER range 0 to 799 := 0;
    signal v_count : INTEGER range 0 to 524 := 0;
begin
    --------------------------------------------------------------------
    -- Clock Divider: 50 MHz → 25 MHz
    --------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            pix_clk <= not pix_clk;
        end if;
    end process;

    DAC_CLK <= pix_clk;

    --------------------------------------------------------------------
    -- Horizontal & Vertical Counters
    --------------------------------------------------------------------
    process(pix_clk)
    begin
        if rising_edge(pix_clk) then
            if h_count = 799 then
                h_count <= 0;
                if v_count = 524 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- HSYNC, VSYNC, and Visible Area (video_on)
    --------------------------------------------------------------------
    H <= '0' when (h_count >= 656 and h_count < 752) else '1';
    V <= '0' when (v_count >= 490 and v_count < 492) else '1';
    video_on <= '1' when (h_count < 640 and v_count < 480) else '0';

    x <= h_count;
    y <= v_count;

end Behavioral;
