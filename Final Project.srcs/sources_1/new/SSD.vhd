----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11/13/2021 01:03:43 PM
-- Design Name:
-- Module Name: SSD - Behavioral
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

entity SSD is
	port (
		clk     : in std_logic;
		in_game : in std_logic;
		D1, D2  : in unsigned(3 downto 0);
		SSD_O   : inout std_logic_vector(6 downto 0);
		CAT     : out std_logic
	);
end SSD;

architecture Behavioral of SSD is

	function unsigned_to_ssd(val : unsigned(3 downto 0)) return std_logic_vector is
	variable v_ret : std_logic_vector(6 downto 0);
begin
	case val is
		when x"0" => v_ret := "0111111";
		when x"1" => v_ret := "0000110";
		when x"2" => v_ret := "1011011";
		when x"3" => v_ret := "1001111";
		when x"4" => v_ret := "1100110";
		when x"5" => v_ret := "1101101";
		when x"6" => v_ret := "1111101";
		when x"7" => v_ret := "0000111";
		when x"8" => v_ret := "1111111";
		when x"9" => v_ret := "1100111";
		when others => v_ret := "0000000";
	end case; return v_ret;
end function unsigned_to_ssd;

signal count : unsigned(22 downto 0) := (others => '0');
signal toggle : std_logic := '0';
signal digit_select : std_logic := '0';

begin
	-- When CAT = 0 THEN D2 is Selected ELSE D1
	score_handler : process (clk)
	begin
		if rising_edge(clk) then	
			if ((D1 /= 9 or D2 /= 9) and in_game = '1') or toggle = '1' then
				if digit_select = '0' then
					if D1 /= 0 then
						SSD_O <= unsigned_to_ssd(D1);
					else
						SSD_O <= (others => '0');
					end if;
				else
					SSD_O <= unsigned_to_ssd(D2);
				end if;
			else
			SSD_O <= (others => '0');
			end if;
			
			if count = 6250000 then
				count <= (others => '0');
				toggle <= toggle xor '1';
			else
				count <= count + 1;
			end if;
			
			digit_select <= digit_select xor '1';
		
		end if;
	end process;
	
	CAT <= digit_select;
end Behavioral;