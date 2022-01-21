----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/09/2021 07:33:43 PM
-- Design Name: 
-- Module Name: GameFunctions - Behavioral
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

package GameFunctions is

    function rect_boundry_check(
    x1, x2, x3, y1, y2, y3 : in integer
    )
    return boolean;
    
    function circ_boundry_check(
    x1, x2, y1, y2, radius : in integer
    )
    return boolean;
    
    function rect_border_check(
    x1, x2, x3, y1, y2, y3 : in integer
    )
    return boolean;
    
    function circ_border_check(
    x1, x2, y1, y2, radius, border_radius : in integer
    )
    return boolean;
    
end package GameFunctions;

package body GameFunctions is

    function rect_boundry_check(
    x1, x2, x3, y1, y2, y3 : in integer
    )
    return boolean is
    begin
    return x1 >= x2 and x1 <= x3 and y1 >= y2 and y1 <= y3;
    end;
    
    function circ_boundry_check(
    x1, x2, y1, y2, radius : in integer
    )
    return boolean is
    begin
    return (y1-y2)*(y1-y2) + (x1-x2)*(x1-x2) <= radius;
    end;

    function rect_border_check(
    x1, x2, x3, y1, y2, y3 : in integer
    )
    return boolean is
    begin
    return (x1 >= x2 and x1 <= x3 and (y1 = y2 or y1 = y3)) or ((x1 = x2 or x1 = x3) and y1 >= y2 and y1 <= y3);
    end;
    
    function circ_border_check(
    x1, x2, y1, y2, radius, border_radius : in integer
    )
    return boolean is
    begin
    return (y1-y2)*(y1-y2) + (x1-x2)*(x1-x2) <= radius and (y1-y2)*(y1-y2) + (x1-x2)*(x1-x2) >= radius-border_radius;
    end;
    
end package body GameFunctions;