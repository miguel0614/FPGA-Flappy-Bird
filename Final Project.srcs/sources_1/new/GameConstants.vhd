----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2021 10:07:30 PM
-- Design Name: 
-- Module Name: GameConstants - Behavioral
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

package GameConstants is

	constant CLOUD_COLOR : std_logic_vector(15 downto 0) := X"FFFF";
	constant SKY_COLOR : std_logic_vector(15 downto 0) := X"03FF";
	constant GROUND_COLOR : std_logic_vector(15 downto 0) := X"0660";
	constant PIPE_COLOR : std_logic_vector(15 downto 0) := X"04C0";
	constant BIRD_COLOR : std_logic_vector(15 downto 0) := X"FFE0";
	constant MOUTH_COLOR : std_logic_vector(15 downto 0) := X"F986";
	constant EYE_COLOR : std_logic_vector(15 downto 0) := X"FFFF";
	constant IRIS_COLOR : std_logic_vector(15 downto 0) := X"0000";
	constant BORDER_COLOR : std_logic_vector(15 downto 0) := X"0000";

	constant SCREEN_WIDTH : integer := 96;
	constant SCREEN_HEIGHT : integer := 64;

	constant BIRD_X : integer := SCREEN_WIDTH/4;
	constant BIRD_RADIUS : integer := SCREEN_HEIGHT/16;
	constant BIRD_RADIUS_SQUARED : integer := BIRD_RADIUS ** 2;

	constant EYE_RADIUS : integer := BIRD_RADIUS/4;
	constant EYE_RADIUS_SQUARED : integer := EYE_RADIUS ** 2;
	constant EYE_X : integer := EYE_RADIUS * 2 + BIRD_X;
	constant IRIS_RADIUS : integer := BIRD_RADIUS/8;
	constant IRIS_RADIUS_SQUARED : integer := IRIS_RADIUS ** 2;
	constant MOUTH_X : integer := BIRD_X;
	constant MOUTH_WIDTH : integer := BIRD_RADIUS;
	constant MOUTH_HEIGHT : integer := BIRD_RADIUS/4;

	constant CLOUD_RADIUS : integer := BIRD_RADIUS;
	constant CLOUD_RADIUS_SQUARED : integer := CLOUD_RADIUS ** 2;
	constant CLOUD_EVEN_Y : integer := CLOUD_RADIUS;
	constant CLOUD_ODD_Y : integer := CLOUD_RADIUS * 2 + CLOUD_EVEN_Y;
	constant DISTANCE_BETWEEN_CLOUDS : integer := SCREEN_WIDTH/4;

	constant PIPE_WIDTH : integer := SCREEN_WIDTH/8;
	constant TOP_PIPE_1_HEIGHT : integer := SCREEN_HEIGHT/2;
	constant TOP_PIPE_2_HEIGHT : integer := SCREEN_HEIGHT/4;
	constant TOP_PIPE_3_HEIGHT : integer := SCREEN_HEIGHT/3;
	constant BOTTOM_PIPE_1_HEIGHT : integer := SCREEN_HEIGHT - SCREEN_HEIGHT/8;
	constant BOTTOM_PIPE_2_HEIGHT : integer := SCREEN_HEIGHT - (SCREEN_HEIGHT/8) * 3;
	constant BOTTOM_PIPE_3_HEIGHT : integer := SCREEN_HEIGHT - SCREEN_HEIGHT/4;
	constant GROUND_HEIGHT : integer := SCREEN_HEIGHT - SCREEN_HEIGHT/4;

	constant SCROLL_WIDTH : integer := 1;
	constant JUMP_HEIGHT : integer := SCREEN_HEIGHT/30;
	constant FALL_HEIGHT : integer := SCREEN_HEIGHT/55;
	constant EYE_BORDER_RADIUS : integer := EYE_RADIUS_SQUARED - (EYE_RADIUS - 1) ** 2;
	constant BIRD_BORDER_RADIUS : integer := BIRD_RADIUS_SQUARED - (BIRD_RADIUS - 1) ** 2;
	constant CLOUD_BORDER_RADIUS : integer := CLOUD_RADIUS_SQUARED - (CLOUD_RADIUS - 1) ** 2;

	constant CLK_FREQ : integer := 6250990;
	constant REFRESH_RATE : integer := 30;
	constant CLK_REFRESH_RATE : integer := CLK_FREQ/REFRESH_RATE;

end package GameConstants;