--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package data_types is

-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

	constant first : std_logic_vector(3 downto 0):= X"1";
	constant second : std_logic_vector(3 downto 0):= X"2";
	constant third : std_logic_vector(3 downto 0):= X"3";
	constant fourth : std_logic_vector(3 downto 0):= X"4";
	constant fifth : std_logic_vector(3 downto 0):= X"5";
	constant sixth : std_logic_vector(3 downto 0):= X"6";
	constant seventh : std_logic_vector(3 downto 0):= X"7";
	constant eighth : std_logic_vector(3 downto 0):= X"8";
	
	constant dds_A : std_logic_vector(3 downto 0):= X"A";
	constant dds_B : std_logic_vector(3 downto 0):= X"B";
	constant dds_C : std_logic_vector(3 downto 0):= X"C";

end data_types;

package body data_types is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end data_types;
