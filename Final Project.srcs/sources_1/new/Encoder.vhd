----------------------------------------------------------------------------------
-- Company: Digilent Inc 2011
-- Engineer: Michelle Yu 
-- Create Date: 16:53:56 08/17/2011
--
-- Module Name: Encoder - Behavioral
-- Project Name: PmodENC
-- Target Devices: Nexys 3
-- Tool versions: Xilinx ISE Design Suite 13.2
--
-- Description:
-- This module defines a component Encoder with a state machine that reads
-- the position of the shaft relative to the starting position. 
--
-- Revision:
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all; -- Needed for shifts

entity Encoder is
	port (
		clk     : in STD_LOGIC;
		-- signals from the pmod
		A       : in STD_LOGIC; 
		B       : in STD_LOGIC;
		BTN     : in STD_LOGIC;
		-- position of the shaft
		EncOut  : inout STD_LOGIC_VECTOR (23 downto 0)
		-- direction indicator

	);
end Encoder;

architecture Behavioral of Encoder is

	type stateType is (idle, R1, R2, R3, L1, L2, L3, add, sub);
	signal curState, nextState : stateType;
	signal volume : unsigned(23 downto 0) := X"0FFFFF";

begin
	--clk and button
	clock : process (clk, BTN)

	begin
		-- if the rotary button is pressed the count resets
		if (BTN = '1') then
			curState <= idle;
			volume <= (others => '0');
		elsif rising_edge(clk) then
			-- detect if the shaft is rotated to right or left
			-- right: add 1 to the position at each click
			-- left: subtract 1 from the position at each click
			if curState /= nextState then
				if (curState = add) then
					if volume < X"7FFFFF" then
						volume <= (volume(22 downto 0) & '1');
					end if;
				elsif (curState = sub) then
					if volume > 0 then
						volume <= ('0' & volume(23 downto 1));
					end if;
				else
					volume <= volume;
				end if;
			else
				volume <= volume;
			end if;
			curState <= nextState;
		end if;
	end process;

	next_state : process (curState, A, B)
	begin
		case curState is
			--detent position
			when idle => 
				if B = '0' then
					nextState <= R1;
				elsif A = '0' then
					nextState <= L1;
				else
					nextState <= idle;
				end if;
				-- start of right cycle
				--R1
			when R1 => 
				if B = '1' then
					nextState <= idle;
				elsif A = '0' then
					nextState <= R2;
				else
					nextState <= R1;
				end if;
				--R2 
			when R2 => 
				if A = '1' then
					nextState <= R1;
				elsif B = '1' then
					nextState <= R3;
				else
					nextState <= R2;
				end if;
				--R3 
			when R3 => 
				if B = '0' then
					nextState <= R2;
				elsif A = '1' then
					nextState <= add;
				else
					nextState <= R3;
				end if;
			when add => 
				nextState <= idle;
				-- start of left cycle
				--L1
			when L1 => 
				if A = '1' then
					nextState <= idle;
				elsif B = '0' then
					nextState <= L2;
				else
					nextState <= L1;
				end if;
				--L2 
			when L2 => 
				if B = '1' then
					nextState <= L1;
				elsif A = '1' then
					nextState <= L3;
				else
					nextState <= L2;
				end if;
				--L3
			when L3 => 
				if A = '0' then
					nextState <= L2;
				elsif B = '1' then
					nextState <= sub;
				else
					nextState <= L3;
				end if;
			when sub => 
				nextState <= idle;
			when others => 
				nextState <= idle;
		end case;
	end process; 
	EncOut <= std_logic_vector(volume);
end Behavioral;