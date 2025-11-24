library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_engine is
  port(
    DAC_CLK                  : in  STD_LOGIC;
    SW0, SW1, SW2, SW3       : in  STD_LOGIC;
    paddleL_y, paddleR_y     : out INTEGER range 0 to 479;
    ball_x                   : out INTEGER range 0 to 639;
    ball_y                   : out INTEGER range 0 to 479
  );
end game_engine;

architecture Behavioral of game_engine is

  -- Paddle limits
  constant Y_MIN     : integer := 35;
  constant Y_MAX     : integer := 445;
  constant X_MIN     : integer := 35;
  constant X_MAX     : integer := 605;
  constant PADDLE_H  : integer := 30;
  constant SPEED     : integer := 3;
  --constant SPEED_X 	: integer := 2;
  --constant SPEED_Y 	: integer := 2;
  constant BALL_SIZE : integer := 5;

  -- Internal paddle position
  signal l_y : integer range 0 to 479 := 200;
  signal r_y : integer range 0 to 479 := 200;
  
  -- Internal ball position
  signal b_x : integer range 0 to 639 := 200;
  signal b_y : integer range 0 to 479 := 200;
  
  --ball velocity
  signal speed_x : integer:= 2;
  signal speed_y : integer:= 2;

  -- Slow tick (~100 Hz)
  signal div  : unsigned(17 downto 0) := (others => '0');
  signal tick : std_logic := '0';
  
  -- goal scored variable
  signal goal_scored : std_logic := '0';

begin

  --------------------------------------------------------------
  -- Clock divider for slow paddle movement
  --------------------------------------------------------------
  process(DAC_CLK)
  begin
    if rising_edge(DAC_CLK) then
      div <= div + 1;
    end if;
  end process;

  tick <= '1' when div = 0 else '0';

  --------------------------------------------------------------
  -- Paddle movement
  --------------------------------------------------------------
  process(DAC_CLK)
  begin
    if rising_edge(DAC_CLK) then
      if tick = '1' then

        -- Left paddle
        if SW0='0' and l_y > (Y_MIN + PADDLE_H) then
          l_y <= l_y - SPEED;
        elsif SW0='1' and l_y < (Y_MAX - PADDLE_H) then
          l_y <= l_y + SPEED;
        end if;

        -- Right paddle
        if SW2='0' and r_y > (Y_MIN + PADDLE_H) then
          r_y <= r_y - SPEED;
        elsif SW2='1' and r_y < (Y_MAX - PADDLE_H) then
          r_y <= r_y + SPEED;
        end if;
			
		  ---------------------------------------------------
        -- BALL COLLISION: TOP / BOTTOM
        ---------------------------------------------------
		  if b_y <= (Y_MIN + BALL_SIZE) then
          speed_y <= abs(speed_y);      -- bounce downward
        elsif b_y >= (Y_MAX - BALL_SIZE) then
          speed_y <= -abs(speed_y);     -- bounce upward
        end if;


        ---------------------------------------------------
        -- BALL COLLISION: LEFT / RIGHT WALLS
        ---------------------------------------------------
        if b_x <= (X_MIN + BALL_SIZE) and (b_y >= 310 or b_y <= 170) then
          speed_x <= abs(speed_x);      -- move right
        elsif b_x >= (X_MAX - BALL_SIZE) and (b_y >= 310 or b_y <= 170) then
          speed_x <= -abs(speed_x);     -- move left
		  elsif b_x <= ((X_MIN-30) + BALL_SIZE) and (b_y <= 310 and b_y >= 170) then
				goal_scored <= '1';
		  elsif b_x >= ((X_MAX+30) - BALL_SIZE) and (b_y <= 310 and b_y >= 170) then
				goal_scored <= '1';
		  else
				goal_scored <= '0';
        end if;


        ---------------------------------------------------
        -- BALL COLLISION: LEFT PADDLE
        ---------------------------------------------------
        if (b_x <= (X_MIN + 10 + BALL_SIZE)) and
           (b_y >= l_y - PADDLE_H) and
           (b_y <= l_y + PADDLE_H) then
             speed_x <= abs(speed_x);   -- force right
        end if;


        ---------------------------------------------------
        -- BALL COLLISION: RIGHT PADDLE
        ---------------------------------------------------
        if (b_x >= (X_MAX - 10 - BALL_SIZE)) and
           (b_y >= r_y - PADDLE_H) and
           (b_y <= r_y + PADDLE_H) then
             speed_x <= -abs(speed_x);  -- force left
        end if;
		  
		  ---------------------------------------------------
			-- UPDATE BALL POSITION 
			---------------------------------------------------
			b_x <= b_x + speed_x;
			b_y <= b_y + speed_y;
			
			-- update position after a goal
			if goal_scored = '1' then
			--set red
			--delay
				b_x <= 320;
				b_y <= 240;
				goal_scored <= '0';
			end if;


      end if;
    end if;
  end process;

  --------------------------------------------------------------
  -- Outputs
  --------------------------------------------------------------
  paddleL_y <= l_y;
  paddleR_y <= r_y;
  
  ball_x <= b_x;   -- center X
  ball_y <= b_y;   -- center Y

end Behavioral;
