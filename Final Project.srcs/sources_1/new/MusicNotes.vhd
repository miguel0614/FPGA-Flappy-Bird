----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2021 10:15:07 PM
-- Design Name: 
-- Module Name: MusicNotes - Behavioral
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
USE IEEE.NUMERIC_STD.ALL;

package MusicNotes is

constant SAMPLING_RATE : integer := 48000;
	
	constant A2F :UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/104 ,10);
	constant A3 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/220 ,10);
	constant A3F :UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/208 ,10);
	constant A4 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/440 ,10);
	constant A5 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/880 ,10);
	constant B3 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/247 ,10);
	constant B3F :UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/233 ,10);
	constant B4 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/494 ,10);
	constant B4F :UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/466,10);
	constant B5 :UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/988,10);
	constant C3 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/131,10);
	constant C4 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/262 ,10);
	constant C5 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/523 ,10);
	constant C6 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/1047 ,10);
	constant D3 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/147 ,10);
	constant D4 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/294 ,10);
	constant D5 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/587 ,10);
	constant D5S :UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/622 ,10);
	constant E3 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/165 ,10);
	constant E3F :UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/156 ,10);
	constant E4 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/330 ,10);
	constant E5 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/659 ,10);
	constant E5F :UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/622 ,10);
	constant E6 :UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/1319 ,10);
	constant F3 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/175 ,10);
	constant F4 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/349 ,10);
	constant F5 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/698 ,10);
	constant F5S :UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/740 ,10);
	constant G2 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/98 ,10);
	constant G3 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/196 ,10);
	constant G3F :UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/185 ,10);
	constant G4 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/392 ,10);
	constant G4S :UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/415 ,10);
	constant G5 : UNSIGNED(9 DOWNTO 0) := to_unsigned(SAMPLING_RATE/784 ,10);
	constant R : UNSIGNED(9 DOWNTO 0):= (others => '0');

end package MusicNotes;