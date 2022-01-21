----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 10/18/2021 11:58:42 AM
-- Design Name:
-- Module Name: Lab4 - Behavioral
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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

library work;
use work.MusicNotes.all;

ENTITY MusicHandler IS
	PORT (
		clk : IN STD_LOGIC;
--		in_game : in std_logic;
--		score_d2 : in unsigned(3 downto 0);
		volume : in std_logic_vector(23 downto 0);
		mclk : OUT STD_LOGIC;
		bclk : OUT STD_LOGIC;
		mute : OUT STD_LOGIC;
		pblrc : OUT STD_LOGIC;
		pbdat : OUT STD_LOGIC
	);
END MusicHandler;

ARCHITECTURE Behavioral OF MusicHandler IS

	COMPONENT ssm2603_i2s
		PORT (
			clk : IN STD_LOGIC;
			r_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
			l_data : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
			bclk : OUT STD_LOGIC;
			pbdat : OUT STD_LOGIC;
			pblrc : OUT STD_LOGIC;
			mclk : OUT STD_LOGIC;
			mute : OUT STD_LOGIC;
			ready : OUT STD_LOGIC
		);
	END COMPONENT;
    
--    signal playing_buffer, playing : std_logic;
--    signal score_buffer, score : unsigned(3 downto 0);
    
	signal mclk_sig, slow_clk, ready : std_logic := '0';
	signal l_data, r_data : std_logic_vector(23 DOWNTO 0) := (OTHERS => '0');
	signal count : unsigned(23 DOWNTO 0) := (OTHERS => '0');
	
	signal tone_count_1, tone_terminal_count_1 : unsigned(9 DOWNTO 0) := (OTHERS => '0');
	signal tone_count_2, tone_terminal_count_2 : unsigned(9 DOWNTO 0) := (OTHERS => '0');
	signal tone_count_3, tone_terminal_count_3 : unsigned(9 DOWNTO 0) := (OTHERS => '0');
	
    constant MCLK_FREQ : integer := 12288000;
    constant NOTE_LENGTH : integer := MCLK_FREQ/8;
	
	
type notes_array is array (0 to 20*8-1) of unsigned(9 downto 0);
--type coin_array is array (0 to 2) of unsigned(9 downto 0);

signal note_track_1 : notes_array := (
E5,E5,R,E5,R,C5,E5,E5,
G5,G5,R,R,G4,G4,R,R,
C5,C5,R,G4,G4,R,E4,E4,
R,A4,A4,B4,B4,B4F,A4,A4,
G4,E5,G5,G5,A5,A5,F5,G5,
R,E5,E5,C5,D5,B4,B4,R,

R,R,G5,F5S,F5,D5S,D5S,E5,
R,G4S,A4,C5,R,A4,C5,D5,
R,R,G5,F5S,F5,D5S,D5,E5,
R,C6,C6,C6,C6,C6,R,R,
R,R,G5,F5S,F5,D5S,D5S,E5,

R,G4S,A4,C5,R,A4,C5,D5,
R,R,E5F,E5F,R,D5,D5,R,
C5,C5,R,R,R,R,R,R,
C5,C5,R,C5,R,C5,D5,D5,
E5,C5,R,A4,G4,G4,G4,G4,

C5,C5,R,C5,R,C5,D5,E5,
R,R,R,R,R,R,R,R,
C5,C5,R,C5,R,C5,D5,D5,
E5,C5,R,A4,G4,G4,G4,G4
) ;

signal note_track_2 : notes_array := (
D3,D3,R,D3,R,D3,D3,D3,
G3,G3,R,R,G2,G2,R,R,
G3,G3,R,E3,E3,R,C3,C3,
R,F3,F3,G3,G3,G3F,F3,F3,
E3,C4,E4,E4,F4,F4,D4,E4,
R,C4,C4,A3,B3,G3,G3,R,

C3,C3,R,G3,R,R,C4,C4,
F3,F3,R,G3,C4,C4,F3,F3,
C3,C3,R,G3,R,R,G3,C4,
R,G4,G4,G4,G4,G4,G3,F3,
C3,C3,R,G3,R,R,C4,C4,

F3,F3,R,G3,C4,C4,F3,F3,
C3,C3,A3F,A3F,R,B3F,B3F,R,
C4,C4,R,G3,G3,G3,C3,C3,
A2F,A2F,R,E3F,R,R,A3F,A3F,
G3,G3,R,C3,R,R,G2,G2,

A2F,A2F,R,E3F,R,R,A3F,A3F,
G3,G3,R,C3,R,R,G2,G2,
A2F,A2F,R,E3F,R,R,A3F,A3F,
G3,G3,R,C3,R,R,G2,G2
);

--signal coin_track : coin_array := (
--B5, E6, E6
--);

BEGIN
	codec : ssm2603_i2s
	PORT MAP(
		clk => clk, 
		r_data => r_data, 
		l_data => l_data, 
		bclk => bclk, 
		pbdat => pbdat, 
		pblrc => pblrc, 
		mclk => mclk_sig, 
		mute => mute, 
		ready => ready
	);
	
--	clock_domain_cross_proc : process(mclk_sig)
--	begin
--	   IF rising_edge(mclk_sig) then
--	       playing_buffer <= in_game;
--	       playing <= playing_buffer;
--	       score_buffer <= score_d2;
--	       score <= score_buffer;
--	   end if;
--	end process;
	
	slow_clock_proc : PROCESS (mclk_sig)
	BEGIN
		IF rising_edge(mclk_sig) THEN
			IF count = NOTE_LENGTH THEN
				slow_clk <= '1';
				count <= (OTHERS => '0');
			ELSE
				count <= count + 1;
				slow_clk <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	tone_counter_proc : PROCESS (mclk_sig)
	BEGIN
		IF rising_edge(mclk_sig) THEN
			IF ready = '1' THEN
				IF tone_count_1 = tone_terminal_count_1 THEN
					tone_count_1 <= (OTHERS => '0');
				ELSE
					tone_count_1 <= tone_count_1 + 1;
				END IF;
				IF tone_count_2 = tone_terminal_count_2 THEN
					tone_count_2 <= (OTHERS => '0');
				ELSE
					tone_count_2 <= tone_count_2 + 1;
				END IF;
				
				IF tone_count_3 = tone_terminal_count_3 THEN
					tone_count_3 <= (OTHERS => '0');
				ELSE
					tone_count_3 <= tone_count_3 + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	state_proc : PROCESS (mclk_sig)
	variable index : integer := 0;
	BEGIN
		IF rising_edge(mclk_sig) THEN
			IF slow_clk = '1' THEN
			tone_terminal_count_1 <= note_track_1(index);
			tone_terminal_count_2 <= note_track_2(index);
				if index = note_track_1'high then
				index := 0;
				else
				index := index +1;
				end if;
			end if;
		end if;
	end process;
	
--	coin_proc : process(mclk_sig)
--	variable index : integer := 0;
--	variable previous_score : unsigned(3 downto 0) := (others => '0');
--	begin
--	   if rising_edge(mclk_sig) then
--	       if slow_clk = '1' THEN
--	           if index /= 0 or (playing = '1' and previous_score /= score) then
--                   tone_terminal_count_3 <= coin_track(index);	           
--                   if index = coin_track'high then
--                        index := 0;
--                   else
--                        index := index +1;
--                   end if;
--               else 
--                    tone_terminal_count_3 <= (others => '0');
--	           end if;
--	           previous_score := score;
--	       end if;
--	   end if;
--	end process;
	
	l_data <= volume WHEN tone_count_1 > tone_terminal_count_1 / 2  or tone_count_2 > tone_terminal_count_2 / 2 ELSE (OTHERS => '0') ;
	r_data <= volume WHEN tone_count_1 > tone_terminal_count_1 / 2  or tone_count_2 > tone_terminal_count_2 / 2 ELSE (OTHERS => '0') ;

	mclk <= mclk_sig;
 
END Behavioral;