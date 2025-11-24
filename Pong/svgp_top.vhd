library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity svgp_top is
    Port (
        clk      : in  STD_LOGIC;                       -- 50 MHz board clock
        SW0      : in  STD_LOGIC;                       -- left paddle up
        SW1      : in  STD_LOGIC;                       -- left paddle down
        SW2      : in  STD_LOGIC;                       -- right paddle up
        SW3      : in  STD_LOGIC;                       -- right paddle down
        H        : out STD_LOGIC;                       -- VGA sync
        V        : out STD_LOGIC;
        DAC_CLK  : out STD_LOGIC;                       -- 25 MHz pixel clock
        Rout     : out STD_LOGIC_VECTOR(7 downto 0);    -- RGB
        Gout     : out STD_LOGIC_VECTOR(7 downto 0);
        Bout     : out STD_LOGIC_VECTOR(7 downto 0)
    );
end svgp_top;


architecture Behavioral of svgp_top is

    --------------------------------------------------------------------
    -- Internal VGA signals
    --------------------------------------------------------------------
    signal pix_clk   : STD_LOGIC;
    signal x, y      : INTEGER range 0 to 639 := 0;
    signal video_on  : STD_LOGIC;

    signal H_int, V_int : STD_LOGIC;
    signal Rout_int, Gout_int, Bout_int : STD_LOGIC_VECTOR(7 downto 0);

    --------------------------------------------------------------------
    -- Paddle signals from game engine
    --------------------------------------------------------------------
    signal paddleL_y, paddleR_y : INTEGER range 0 to 479;
	 
	 -- ball signals
	 signal ball_x                   : INTEGER range 0 to 639;
    signal ball_y                   :  INTEGER range 0 to 479;

    --------------------------------------------------------------------
    -- ChipScope internal signals
    --------------------------------------------------------------------
    signal debug_bus : STD_LOGIC_VECTOR(15 downto 0);
    signal CONTROL0  : STD_LOGIC_VECTOR(35 downto 0);

    signal x_vec, y_vec : STD_LOGIC_VECTOR(9 downto 0);

    --------------------------------------------------------------------
    -- Components
    --------------------------------------------------------------------
    component icon
        port ( CONTROL0 : out STD_LOGIC_VECTOR(35 downto 0) );
    end component;

    component ila
        port (
            CONTROL : in  STD_LOGIC_VECTOR(35 downto 0);
            CLK     : in  STD_LOGIC;
            TRIG0   : in  STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

begin

    --------------------------------------------------------------------
    -- VGA core instance
    --------------------------------------------------------------------
    VGA_CORE_INST : entity work.vga_core
        port map (
            clk       => clk,
            DAC_CLK   => pix_clk,
            H         => H_int,
            V         => V_int,
            video_on  => video_on,
            x         => x,
            y         => y
        );

    DAC_CLK <= pix_clk;
    H <= H_int;
    V <= V_int;

    --------------------------------------------------------------------
    -- Game engine (paddle movement logic)
    --------------------------------------------------------------------
    GAME_ENGINE_INST : entity work.game_engine
        port map (
            DAC_CLK     => pix_clk,
            SW0         => SW0,
            SW1         => SW1,
            SW2         => SW2,
            SW3         => SW3,
            paddleL_y   => paddleL_y,
            paddleR_y   => paddleR_y,
				ball_x   => ball_x,
            ball_y   => ball_y
        );

    --------------------------------------------------------------------
    -- Renderer (static scene + paddles)
    --------------------------------------------------------------------
    RENDERER_INST : entity work.renderer
        port map (
            x          => x,
            y          => y,
            video_on   => video_on,
            paddleL_y  => paddleL_y,
            paddleR_y  => paddleR_y,
				ball_x  => ball_x,
            ball_y  => ball_y,
            Rout       => Rout_int,
            Gout       => Gout_int,
            Bout       => Bout_int
        );

    Rout <= Rout_int;
    Gout <= Gout_int;
    Bout <= Bout_int;


    --------------------------------------------------------------------
    -- ChipScope ICON + ILA
    --------------------------------------------------------------------
    ICON_INST : icon
        port map ( CONTROL0 => CONTROL0 );

    ILA_INST : ila
        port map (
            CONTROL  => CONTROL0,
            CLK      => pix_clk,
            TRIG0    => debug_bus
        );


    --------------------------------------------------------------------
    -- Debug bus wiring (x,y,H,V + colors)
    --------------------------------------------------------------------
    x_vec <= std_logic_vector(to_unsigned(x, 10));
    y_vec <= std_logic_vector(to_unsigned(y, 10));

	debug_bus <=
    video_on &          -- bit 15
    H_int &             -- bit 14
    V_int &             -- bit 13
    x_vec(3 downto 0) & -- bits 12..9
    y_vec(3 downto 0) & -- bits 8..5
    Rout_int(1 downto 0) & -- bits 4..3
    Bout_int(1 downto 0) & -- bits 2..1
    CLK;                


end Behavioral;
