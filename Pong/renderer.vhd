library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity renderer is
    Port (
        x, y         : in  INTEGER range 0 to 639;
        video_on     : in  STD_LOGIC;
        paddleL_y    : in  INTEGER range 0 to 479;
        paddleR_y    : in  INTEGER range 0 to 479;
		  ball_x    : in  INTEGER range 0 to 639;
        ball_y    : in  INTEGER range 0 to 479;
		  
        Rout         : out STD_LOGIC_VECTOR(7 downto 0);
        Gout         : out STD_LOGIC_VECTOR(7 downto 0);
        Bout         : out STD_LOGIC_VECTOR(7 downto 0)
    );
end renderer;


architecture Behavioral of renderer is

    --------------------------------------------------------------------
    -- Paddle and border geometry
    --------------------------------------------------------------------
    constant PADDLE_X_LEFT  : integer := 30;
    constant PADDLE_X_RIGHT : integer := 600;
    constant PADDLE_H       : integer := 30;   -- +/- around center (total 60px)
    --constant WALL_THICKNESS : integer := 20;   -- top and bottom walls
	 constant BALL_SIZE 		 : integer := 10;
	 --signal BALL_X  : integer := 320;
	 --signal BALL_Y: integer := 240;

begin

    process(x, y, video_on, paddleL_y, paddleR_y, ball_x, ball_y)

    begin
        -- Default black when video_off
        if video_on = '0' then
            Rout <= (others => '0');
            Gout <= (others => '0');
            Bout <= (others => '0');

        else
            ----------------------------------------------------------------
            -- 1. Default background: green
            ----------------------------------------------------------------
            Rout <= (others => '0');
            Gout <= (others => '1');
            Bout <= (others => '0');

            -- top, bottom boundaries
            if (((y >= 20 and y <= 30) or (y >= 450 and y <= 460)) and ((x > 20) and (x < 620))) then
                Rout <= (others => '1');
                Gout <= (others => '1');
                Bout <= (others => '1');
            end if;
				
				-- left, right boundaries
				if ( ((x >= 20 and x <= 30) or (x > 610 and x < 620)) and ((y > 20 and y < 170) or (y > 310 and y < 460)) ) then
                Rout <= (others => '1');
                Gout <= (others => '1');
                Bout <= (others => '1');
            end if;
				
				-- black dividing line
				if ((x > 318 and x < 322) and
					 ((y > 40  and y < 80) or
					  (y > 130 and y < 170) or
					  (y > 220 and y < 260) or
					  (y > 310 and y < 350) or
					  (y > 400 and y < 440))) then


                Rout <= (others => '0');
                Gout <= (others => '0');
                Bout <= (others => '0');
            end if;

            ----------------------------------------------------------------
            -- 4. Left paddle (60px tall)
            ----------------------------------------------------------------
            if (x >= PADDLE_X_LEFT and x <= PADDLE_X_LEFT + 10) and
               (y >= paddleL_y - PADDLE_H and y <= paddleL_y + PADDLE_H) then
                Rout <= (others => '0');
                Gout <= (others => '0');
                Bout <= (others => '1');
            end if;

            ----------------------------------------------------------------
            -- 5. Right paddle
            ----------------------------------------------------------------
            if (x >= PADDLE_X_RIGHT and x <= PADDLE_X_RIGHT + 10) and
               (y >= paddleR_y - PADDLE_H and y <= paddleR_y + PADDLE_H) then
                Rout <= (others => '1');
                Gout <= (others => '0');
                Bout <= (others => '1');
            end if;
				
				-- Yellow ball (R + G = yellow)
				if (x >= ball_x - BALL_SIZE and x <= ball_x + BALL_SIZE) and
					(y >= ball_y - BALL_SIZE and y <= ball_y + BALL_SIZE) then
						if((ball_y > 170 and ball_y < 310) and (ball_x < 30 or ball_x > 610)) then
						 Rout <= (others => '1');  -- Red
						 Gout <= (others => '0');  -- Green
						 Bout <= (others => '0');  -- No blue = yellow
						else
						 Rout <= (others => '1');  -- Red
						 Gout <= (others => '1');  -- Green
						 Bout <= (others => '0');  -- No blue = yellow
						end if;
				end if;

        end if;
    end process;

end Behavioral;
