----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11/09/2021 03:04:54 PM
-- Design Name:
-- Module Name: FlappyBird - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity FlappyBird is
	port (
		sys_clk                                        : in std_logic;
		reset_btn                                      : in std_logic;
		btn                                            : in std_logic;
		A,B                                            : in std_logic;
		enc_btn                                        : in std_logic;
		mclk                                           : out STD_LOGIC;
		bclk                                           : out STD_LOGIC;
		mute                                           : out STD_LOGIC;
		pblrc                                          : out STD_LOGIC;
		pbdat                                          : out STD_LOGIC;
		cs, sdin, nc, sclk, d_cn, resn, vccen, pmoden  : out std_logic;
		SSD_O                                          : inout std_logic_vector(6 downto 0);
		CAT                                            : out std_logic
	);
end FlappyBird;

architecture Behavioral of FlappyBird is

	signal pclk, aclk : std_logic;
	signal A_debounced, B_debounced : std_logic;
    signal volume : std_logic_vector(23 downto 0) := X"7FFFFF";
	signal score_d1, score_d2 : unsigned(3 downto 0) := (others => '0');
	signal in_game : std_logic := '0';
	
	component FrameHandler is
		port (
			clk                                        : in std_logic;
			reset_btn                                  : in std_logic;
			btn                                        : in std_logic;
			cs, sdin, sclk, d_cn, resn, vccen, pmoden  : out std_logic;
			score_d1, score_d2                         : inout unsigned(3 downto 0);
			in_game                                    : out std_logic
		);
	end component;

    component MusicHandler is
		port (
			clk    : in STD_LOGIC;
--			in_game : in std_logic;
--		    score_d2 : in unsigned(3 downto 0);
			volume : in std_logic_vector(23 downto 0);
			mclk   : out STD_LOGIC;
			bclk   : out STD_LOGIC;
			mute   : out STD_LOGIC;
			pblrc  : out STD_LOGIC;
			pbdat  : out STD_LOGIC
		);
	end component;
	
	component Debouncer is
	   port (
	       clk : in  STD_LOGIC;
           Ain : in  STD_LOGIC; 
           Bin : in  STD_LOGIC;
           Aout: out STD_LOGIC;
           Bout: out std_logic 
	   );
	end component;
	
	component Encoder is
	   port (
	        clk: in STD_LOGIC;
            A : in  STD_LOGIC;	
            B : in  STD_LOGIC;
            BTN : in  STD_LOGIC;
            EncOut: inout STD_LOGIC_VECTOR (23 downto 0)
	   );
	end component;
	
	component SSD is
	   port (
	   clk : in std_logic;
	   in_game : in std_logic;
	   D1, D2: in unsigned(3 downto 0);
	   SSD_O : inout std_logic_vector(6 downto 0);
	   CAT : out std_logic
	   );
	end component;
	
begin
	audio_clock_gen : entity work.clk_gen_audio
		port map(
			clk_in1   => sys_clk, 
			clk_out1  => aclk, 
			locked    => open, 
			reset     => '0'
		);

    display_clock_gen : entity work.clk_gen_display
        port map(
            clk_in1   => aclk, 
            clk_out1  => pclk, 
            locked    => open, 
            reset     => '0'
        );

    display : FrameHandler
        port map(
            clk        => pclk, 
            reset_btn  => reset_btn, 
            btn        => btn, 
            cs         => cs, 
            sdin       => sdin, 
            sclk       => sclk, 
            d_cn       => d_cn, 
            resn       => resn, 
            vccen      => vccen, 
            pmoden     => pmoden,
            score_d1 => score_d1,
            score_d2 => score_d2,
            in_game => in_game
    );
    
    enc_debouncer : Debouncer
        port map(
            clk => aclk,
            Ain => A,
            Bin => B,
            Aout=> A_debounced,
            Bout=> B_debounced
        );
        
    volume_encoder : Encoder
        port map (
            clk => aclk,
            A  => A_debounced,
            B => B_debounced,
            BTN => enc_btn,
            EncOut => volume
        );    
    
    audio : MusicHandler
        port map(
            clk    => aclk,
--            in_game => in_game,
--            score_d2 => score_d2,
            volume => volume, 
            mclk   => mclk, 
            bclk   => bclk, 
            mute   => mute, 
            pblrc  => pblrc, 
            pbdat  => pbdat 
	);
    
    score : SSD
        port map(
        clk => pclk,
        in_game => in_game,
        D1 => score_d1,
        D2 => score_d2,
        SSD_O => SSD_O,
        CAT => CAT
    );
    
    nc <= '0';
end Behavioral;