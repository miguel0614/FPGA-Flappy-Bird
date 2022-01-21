----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11/09/2021 03:08:02 PM
-- Design Name:
-- Module Name: FrameHandler - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_unsigned.all;

library work;
use work.GameFunctions.all;
use work.GameConstants.all;

library UNISIM;
use UNISIM.VComponents.all;
entity FrameHandler is
	port (
		clk                                        : in std_logic;
		reset_btn                                  : in std_logic;
		btn                                        : in std_logic;
		cs, sdin, sclk, d_cn, resn, vccen, pmoden  : out std_logic;
		score_d1, score_d2 : inout unsigned(3 downto 0);
		in_game : out std_logic
	);
end FrameHandler;

architecture Behavioral of FrameHandler is
	
	type state_type is (MENU, INGAME, GAMEOVER);
	type clouds_array is array (0 to 7) of integer range 0 to SCREEN_WIDTH * 2;
	type pipes_array is array (0 to 2) of integer range 0 to SCREEN_WIDTH * 2;

	signal state : state_type := MENU;
	signal clouds_x                            : clouds_array := (CLOUD_RADIUS, CLOUD_RADIUS * 2, DISTANCE_BETWEEN_CLOUDS + CLOUD_RADIUS, DISTANCE_BETWEEN_CLOUDS + CLOUD_RADIUS * 2, 
		2 * DISTANCE_BETWEEN_CLOUDS + CLOUD_RADIUS, 2 * DISTANCE_BETWEEN_CLOUDS + CLOUD_RADIUS * 2, 3 * DISTANCE_BETWEEN_CLOUDS + CLOUD_RADIUS, 3 * DISTANCE_BETWEEN_CLOUDS + CLOUD_RADIUS * 2
	);
	signal pipes_x : pipes_array := (SCREEN_WIDTH - PIPE_WIDTH, SCREEN_WIDTH + SCREEN_WIDTH/4, SCREEN_WIDTH + SCREEN_WIDTH/2 + PIPE_WIDTH);

	signal collision_detected : std_logic := '0';

	signal count : integer range 0 to 74250000 := 0;
	signal advance_frame : std_logic := '0';

	signal bird_y : integer range 0 to SCREEN_HEIGHT := SCREEN_HEIGHT/2;
	signal mouth_y : integer range 0 to SCREEN_HEIGHT := SCREEN_HEIGHT/2;
	signal eye_y : integer range 0 to SCREEN_HEIGHT := SCREEN_HEIGHT/2 - EYE_RADIUS * 2;
	
	signal pixel_color : std_logic_vector(15 downto 0) := (others => '0');
    signal rgb_color : std_logic_vector(15 downto 0) := (others => '1');

	signal frame_begin, sending_pixels, sample_pixel : std_logic;
	signal pixel_index : std_logic_vector(12 downto 0);

	signal x_coord : std_logic_vector(6 downto 0);
	signal y_coord : std_logic_vector(5 downto 0);

	component pmodoledrgb_controller is
		port (
			clk, reset   : in std_logic;
			pixel_data   : in std_logic_vector(15 downto 0);
			frame_begin, sending_pixels, sample_pixel : out std_logic;
			pixel_index  : out std_logic_vector(12 downto 0);
			cs, sdin, sclk, d_cn, resn, vccen, pmoden : out std_logic
		);
	end component;

	component coordinate_decoder is
		port (
			clk, sending_pixels, sample_pixel  : in std_logic;
			x                                  : out std_logic_vector(6 downto 0);
			y                                  : out std_logic_vector(5 downto 0)
		);
	end component;
begin
	oled_display : pmodoledrgb_controller
	port map(
		clk             => clk, 
		reset           => reset_btn, 
		pixel_data      => rgb_color, 
		frame_begin     => frame_begin, 
		sending_pixels  => sending_pixels, 
		sample_pixel    => sample_pixel, 
		pixel_index     => pixel_index, 
		cs              => cs, 
		sdin            => sdin, 
		sclk            => sclk, 
		d_cn            => d_cn, 
		resn            => resn, 
		vccen           => vccen, 
		pmoden          => pmoden
	);

	coordinates : coordinate_decoder
	port map(
		clk             => clk, 
		sending_pixels  => sending_pixels, 
		sample_pixel    => sample_pixel, 
		x               => x_coord, 
		y               => y_coord
	);

	slow_clk_proc : process (clk)
	begin
		if rising_edge(clk) then
			if count = CLK_REFRESH_RATE then
				advance_frame <= '1';
				count <= 0;
			else
				if (count = 0 and to_integer(unsigned(x_coord)) = 0 and to_integer(unsigned(y_coord)) = 0) or count /= 0 then
					count <= count + 1;
				end if;
				advance_frame <= '0';
			end if;
		end if;
	end process;
	
	state_proc : process (clk)
		variable end_screen_count : integer := 0;
	begin
		if rising_edge(clk) then
			case(state) is
				when MENU => 
					if btn = '1' and advance_frame = '1' then
						state <= INGAME;
					end if;
				when INGAME => 
					if collision_detected = '1' then
						state <= GAMEOVER;
					end if;
				when GAMEOVER => 
					if end_screen_count >= REFRESH_RATE and btn = '1' then
						state <= MENU;
						end_screen_count := 0;
					else
						if advance_frame = '1' then
							end_screen_count := end_screen_count + 1;
						end if;
					end if;
			end case;
		end if;
	end process;

	-----------------------
	-- Object Drawing Precedence
	-- Eye
	-- Mouth
	-- Bird
	-- Pipe
	-- Ground
	-- Cloud
	-- Sky
	-----------------------
	draw_game_proc : process (x_coord, y_coord, state)
		variable x : integer := 0;
		variable y : integer := 0;
	begin
		x := to_integer(unsigned(x_coord));
		y := to_integer(unsigned(y_coord));
 
		if x >= 0 and x <= SCREEN_WIDTH and y >= 0 and y <= SCREEN_HEIGHT then
			if circ_boundry_check(y, eye_y, x, EYE_X, EYE_RADIUS_SQUARED) then -- Check distance between coord and eye
				pixel_color <= EYE_COLOR;
 
				if circ_boundry_check(y, eye_y, x, EYE_X, IRIS_RADIUS_SQUARED) then -- Check distance between coord and eye
					pixel_color <= IRIS_COLOR;
				end if;
 
				if circ_border_check(y, eye_y, x, EYE_X, EYE_RADIUS_SQUARED, EYE_BORDER_RADIUS) then
					pixel_color <= BORDER_COLOR;
				end if;
 
			elsif rect_boundry_check(x, MOUTH_X, MOUTH_X + MOUTH_WIDTH, y, mouth_y, mouth_y + MOUTH_HEIGHT) then -- Check if within mouth boundry
				pixel_color <= MOUTH_COLOR;
				if rect_border_check(x, MOUTH_X, MOUTH_X + MOUTH_WIDTH, y, mouth_y, mouth_y + MOUTH_HEIGHT) then
					pixel_color <= BORDER_COLOR;
				end if;
 
			elsif circ_boundry_check(y, bird_y, x, BIRD_X, BIRD_RADIUS_SQUARED) then -- Check distance between coord and bird body
				pixel_color <= BIRD_COLOR;
				if circ_border_check(y, bird_y, x, BIRD_X, BIRD_RADIUS_SQUARED, BIRD_BORDER_RADIUS) then
					pixel_color <= BORDER_COLOR;
				end if;
 
			elsif rect_boundry_check(x, pipes_x(0), pipes_x(0) + PIPE_WIDTH, y, 0, TOP_PIPE_1_HEIGHT) or
				rect_boundry_check(x, pipes_x(1), pipes_x(1) + PIPE_WIDTH, y, 0, TOP_PIPE_2_HEIGHT) or
				rect_boundry_check(x, pipes_x(0), pipes_x(0) + PIPE_WIDTH, y, BOTTOM_PIPE_1_HEIGHT, SCREEN_HEIGHT) or
				rect_boundry_check(x, pipes_x(1), pipes_x(1) + PIPE_WIDTH, y, BOTTOM_PIPE_2_HEIGHT, SCREEN_HEIGHT) or
				rect_boundry_check(x, pipes_x(2), pipes_x(2) + PIPE_WIDTH, y, 0, TOP_PIPE_3_HEIGHT) or
				rect_boundry_check(x, pipes_x(2), pipes_x(2) + PIPE_WIDTH, y, BOTTOM_PIPE_3_HEIGHT, SCREEN_HEIGHT) then -- Check if within pipe boundry
				pixel_color <= PIPE_COLOR;
				if rect_border_check(x, pipes_x(0), pipes_x(0) + PIPE_WIDTH, y, 0, TOP_PIPE_1_HEIGHT) or
				 rect_border_check(x, pipes_x(0), pipes_x(0) + PIPE_WIDTH, y, BOTTOM_PIPE_1_HEIGHT, SCREEN_HEIGHT) or
				 rect_border_check(x, pipes_x(1), pipes_x(1) + PIPE_WIDTH, y, 0, TOP_PIPE_2_HEIGHT) or
				 rect_border_check(x, pipes_x(1), pipes_x(1) + PIPE_WIDTH, y, BOTTOM_PIPE_2_HEIGHT, SCREEN_HEIGHT)or
				 rect_border_check(x, pipes_x(2), pipes_x(2) + PIPE_WIDTH, y, 0, TOP_PIPE_3_HEIGHT) or
				 rect_border_check(x, pipes_x(2), pipes_x(2) + PIPE_WIDTH, y, BOTTOM_PIPE_3_HEIGHT, SCREEN_HEIGHT) then
					pixel_color <= BORDER_COLOR;
				end if;
 
				elsif y >= GROUND_HEIGHT and y <= SCREEN_HEIGHT then -- Check if within ground boundry
					pixel_color <= GROUND_COLOR;
					if y = GROUND_HEIGHT then
						pixel_color <= BORDER_COLOR;
					end if;
 
				elsif circ_boundry_check(y, CLOUD_EVEN_Y, x, clouds_x(0), CLOUD_RADIUS_SQUARED) or
					circ_boundry_check(y, CLOUD_EVEN_Y, x, clouds_x(1), CLOUD_RADIUS_SQUARED)or
					circ_boundry_check(y, CLOUD_EVEN_Y, x, clouds_x(4), CLOUD_RADIUS_SQUARED) or
					circ_boundry_check(y, CLOUD_EVEN_Y, x, clouds_x(5), CLOUD_RADIUS_SQUARED) or
					circ_boundry_check(y, CLOUD_ODD_Y, x, clouds_x(2), CLOUD_RADIUS_SQUARED) or
					circ_boundry_check(y, CLOUD_ODD_Y, x, clouds_x(3), CLOUD_RADIUS_SQUARED)or
					circ_boundry_check(y, CLOUD_ODD_Y, x, clouds_x(6), CLOUD_RADIUS_SQUARED) or
					circ_boundry_check(y, CLOUD_ODD_Y, x, clouds_x(7), CLOUD_RADIUS_SQUARED) then -- Check distance between coord and clouds
					pixel_color <= CLOUD_COLOR;
					if (circ_border_check(y, CLOUD_EVEN_Y, x, clouds_x(0), CLOUD_RADIUS_SQUARED, CLOUD_BORDER_RADIUS) and not circ_boundry_check(y, CLOUD_EVEN_Y, x, clouds_x(1), CLOUD_RADIUS_SQUARED)) or
					 (circ_border_check(y, CLOUD_EVEN_Y, x, clouds_x(1), CLOUD_RADIUS_SQUARED, CLOUD_BORDER_RADIUS) and not circ_boundry_check(y, CLOUD_EVEN_Y, x, clouds_x(0), CLOUD_RADIUS_SQUARED)) or
					 (circ_border_check(y, CLOUD_EVEN_Y, x, clouds_x(4), CLOUD_RADIUS_SQUARED, CLOUD_BORDER_RADIUS) and not circ_boundry_check(y, CLOUD_EVEN_Y, x, clouds_x(5), CLOUD_RADIUS_SQUARED)) or
					 (circ_border_check(y, CLOUD_EVEN_Y, x, clouds_x(5), CLOUD_RADIUS_SQUARED, CLOUD_BORDER_RADIUS) and not circ_boundry_check(y, CLOUD_EVEN_Y, x, clouds_x(4), CLOUD_RADIUS_SQUARED)) or
					 (circ_border_check(y, CLOUD_ODD_Y, x, clouds_x(2), CLOUD_RADIUS_SQUARED, CLOUD_BORDER_RADIUS) and not circ_boundry_check(y, CLOUD_ODD_Y, x, clouds_x(3), CLOUD_RADIUS_SQUARED)) or
					 (circ_border_check(y, CLOUD_ODD_Y, x, clouds_x(3), CLOUD_RADIUS_SQUARED, CLOUD_BORDER_RADIUS) and not circ_boundry_check(y, CLOUD_ODD_Y, x, clouds_x(2), CLOUD_RADIUS_SQUARED)) or
					 (circ_border_check(y, CLOUD_ODD_Y, x, clouds_x(6), CLOUD_RADIUS_SQUARED, CLOUD_BORDER_RADIUS) and not circ_boundry_check(y, CLOUD_ODD_Y, x, clouds_x(7), CLOUD_RADIUS_SQUARED)) or
					 (circ_border_check(y, CLOUD_ODD_Y, x, clouds_x(7), CLOUD_RADIUS_SQUARED, CLOUD_BORDER_RADIUS) and not circ_boundry_check(y, CLOUD_ODD_Y, x, clouds_x(6), CLOUD_RADIUS_SQUARED))
					 then
					 pixel_color <= BORDER_COLOR;
					 end if;
 
				 else -- If nothing else, then sky
					 pixel_color <= SKY_COLOR;
				 end if;
			 end if;
		 end process;

		 game_proc : process (clk)
		 begin
			 if rising_edge(clk) then
					if advance_frame = '1' then
						case(state) is
							when MENU => 
								clouds_x <= (CLOUD_RADIUS, CLOUD_RADIUS * 2, DISTANCE_BETWEEN_CLOUDS + CLOUD_RADIUS, DISTANCE_BETWEEN_CLOUDS + CLOUD_RADIUS * 2, 
									2 * DISTANCE_BETWEEN_CLOUDS + CLOUD_RADIUS, 2 * DISTANCE_BETWEEN_CLOUDS + CLOUD_RADIUS * 2, 
									3 * DISTANCE_BETWEEN_CLOUDS + CLOUD_RADIUS, 3 * DISTANCE_BETWEEN_CLOUDS + CLOUD_RADIUS * 2);
									pipes_x <= (SCREEN_WIDTH - PIPE_WIDTH, SCREEN_WIDTH + SCREEN_WIDTH/4, SCREEN_WIDTH + SCREEN_WIDTH/2 + PIPE_WIDTH);
									collision_detected <= '0';
									
									score_d1 <= (others => '0');
									score_d2 <= (others => '0');
 
									bird_y <= SCREEN_HEIGHT/2;
									mouth_y <= SCREEN_HEIGHT/2;
									eye_y <= SCREEN_HEIGHT/2 - EYE_RADIUS * 2;
 
							when INGAME => 
								if btn = '1' and bird_y - BIRD_RADIUS - JUMP_HEIGHT >= 0 then -- RISE/FALL BIRD
									bird_y <= bird_y - JUMP_HEIGHT;
									eye_y <= eye_y - JUMP_HEIGHT;
									mouth_y <= mouth_y - JUMP_HEIGHT;
								else
									bird_y <= bird_y + FALL_HEIGHT;
									eye_y <= eye_y + FALL_HEIGHT;
									mouth_y <= mouth_y + FALL_HEIGHT;
								end if;
 
								for I in pipes_x'LOW to pipes_x'HIGH loop -- SCROLL PIPES
									if pipes_x(I) >= SCROLL_WIDTH then
										pipes_x(I) <= pipes_x(I) - SCROLL_WIDTH;
									else
										pipes_x(I) <= SCREEN_WIDTH + pipes_x(I) - SCROLL_WIDTH;
									end if;
								end loop;
 
								for I in clouds_x'LOW to clouds_x'HIGH loop -- SCROLL CLOUDS
									if clouds_x(I) >= SCROLL_WIDTH then
										clouds_x(I) <= clouds_x(I) - SCROLL_WIDTH;
									else
										clouds_x(I) <= SCREEN_WIDTH + clouds_x(I) - SCROLL_WIDTH;
									end if;
								end loop;
 
								if (bird_y + BIRD_RADIUS) >= SCREEN_HEIGHT or
							 rect_boundry_check(BIRD_X + BIRD_RADIUS, pipes_x(0), pipes_x(0) + PIPE_WIDTH, bird_y - BIRD_RADIUS, 0, TOP_PIPE_1_HEIGHT) or
							 rect_boundry_check(BIRD_X + BIRD_RADIUS, pipes_x(1), pipes_x(1) + PIPE_WIDTH, bird_y - BIRD_RADIUS, 0, TOP_PIPE_2_HEIGHT) or
							 rect_boundry_check(BIRD_X + BIRD_RADIUS, pipes_x(0), pipes_x(0) + PIPE_WIDTH, bird_y + BIRD_RADIUS, BOTTOM_PIPE_1_HEIGHT, SCREEN_HEIGHT) or
							 rect_boundry_check(BIRD_X + BIRD_RADIUS, pipes_x(1), pipes_x(1) + PIPE_WIDTH, bird_y + BIRD_RADIUS, BOTTOM_PIPE_2_HEIGHT, SCREEN_HEIGHT) or
							 rect_boundry_check(BIRD_X - BIRD_RADIUS, pipes_x(0), pipes_x(0) + PIPE_WIDTH, bird_y - BIRD_RADIUS, 0, TOP_PIPE_1_HEIGHT) or
							 rect_boundry_check(BIRD_X - BIRD_RADIUS, pipes_x(1), pipes_x(1) + PIPE_WIDTH, bird_y - BIRD_RADIUS, 0, TOP_PIPE_2_HEIGHT) or
							 rect_boundry_check(BIRD_X - BIRD_RADIUS, pipes_x(0), pipes_x(0) + PIPE_WIDTH, bird_y + BIRD_RADIUS, BOTTOM_PIPE_1_HEIGHT, SCREEN_HEIGHT) or
							 rect_boundry_check(BIRD_X - BIRD_RADIUS, pipes_x(1), pipes_x(1) + PIPE_WIDTH, bird_y + BIRD_RADIUS, BOTTOM_PIPE_2_HEIGHT, SCREEN_HEIGHT) or
							 rect_boundry_check(BIRD_X + BIRD_RADIUS, pipes_x(2), pipes_x(2) + PIPE_WIDTH, bird_y - BIRD_RADIUS, 0, TOP_PIPE_3_HEIGHT) or
							 rect_boundry_check(BIRD_X + BIRD_RADIUS, pipes_x(2), pipes_x(2) + PIPE_WIDTH, bird_y + BIRD_RADIUS, BOTTOM_PIPE_3_HEIGHT, SCREEN_HEIGHT) or
							 rect_boundry_check(BIRD_X - BIRD_RADIUS, pipes_x(2), pipes_x(2) + PIPE_WIDTH, bird_y - BIRD_RADIUS, 0, TOP_PIPE_3_HEIGHT) or
							 rect_boundry_check(BIRD_X - BIRD_RADIUS, pipes_x(2), pipes_x(2) + PIPE_WIDTH, bird_y + BIRD_RADIUS, BOTTOM_PIPE_3_HEIGHT, SCREEN_HEIGHT)
							 then
							 collision_detected <= '1';
								 else
									 collision_detected <= '0';
								 end if;
 
								 score_d1 <= score_d1;
								 score_d2 <= score_d2;
                                 
                                 if score_d1 /= 9 or score_d2 /= 9 then
								 for I in pipes_x'LOW to pipes_x'HIGH loop 
									 if BIRD_X = pipes_x(I) or (BIRD_X > pipes_x(I) and BIRD_x < pipes_x(I) + SCROLL_WIDTH) then
											if score_d2 = 9 then
											score_d2 <= (others => '0');
											score_d1 <= score_d1 + 1;
											else
											score_d2 <= score_d2 + 1;
											score_d1 <= score_d1;
											end if;
										end if;
									end loop;
                                 end if;

							when GAMEOVER => 
										clouds_x <= clouds_x;
										pipes_x <= pipes_x;
										collision_detected <= '0';
 
										bird_y <= bird_y;
										mouth_y <= mouth_y;
										eye_y <= eye_y;
							end case;
						end if;
					end if;
				end process;
rgb_color <= pixel_color;
in_game <=  '1' when state = INGAME else '0';

end Behavioral;