----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:21:53 04/27/2012 
-- Design Name: 
-- Module Name:    rst_controll - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity async_reset16 is
generic (
    length_rst         	: integer := 16);
Port ( 
	clk					: in std_logic;
	in_reset			: in std_logic;
	in_locked			: in std_logic;

	out_rst				: out std_logic;
	out_locked			: out std_logic);
end async_reset16;

architecture Behavioral of async_reset16 is

-----------------------------------------------------------
-----------------------------------------------------------
attribute syn_hier 		: string;
attribute syn_hier of Behavioral	: architecture is "hard";

-- attribute syn_keep 		: boolean;
-----------------------------------------------------------
-----------------------------------------------------------
signal async_rst		: std_logic;
signal lock_shift		: std_logic_vector((length_rst - 1) downto 0) := (others => '0');


-----------------------------------------------------------
-----------------------------------------------------------

begin

-----------------------------------------------------------
-----------------------------------------------------------
async_rst				<= (in_reset or (not in_locked));


-----------------------------------------------------------
-----------------------------------------------------------
process (clk, async_rst)					
begin 
if async_rst = '1' then
	lock_shift			<= (others => '0');
elsif (clk = '1' and clk'event) then
	lock_shift			<= (lock_shift((length_rst - 2) downto 0)&'1');
end if;
end process;


-----------------------------------------------------------
-----------------------------------------------------------
out_rst					<= (not lock_shift(length_rst - 1));
out_locked				<= lock_shift(length_rst - 1);


end Behavioral;

