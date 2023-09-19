----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:14:32 10/20/2010 
-- Design Name: 
-- Module Name:    bram_reg - Behavioral 
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

-- library UNISIM;
-- use UNISIM.VComponents.all;

entity bram_reg is
generic( 
	ORDER       		: integer := 10;	  	-- Порядок степени двойки адреса.
    width_mem       	: integer := 18		-- Размерность слова.
	); 
Port ( 
    clka				: in std_logic;
    ena  				: in std_logic;	
    addra				: in std_logic_vector((ORDER - 1) downto 0);	
    dia  				: in std_logic_vector((width_mem - 1) downto 0);
	
	clkb				: in std_logic;	
    enb  				: in std_logic;
    addrb				: in std_logic_vector((ORDER - 1) downto 0);
    enb_reg  			: in std_logic;	
    dob_reg				: out std_logic_vector((width_mem - 1) downto 0));
end bram_reg;

architecture Behavioral of bram_reg is

-----------------------------------------------------------
-----------------------------------------------------------
attribute syn_hier 		: string;
attribute syn_hier of Behavioral	: architecture is "fixed";	--	fixed 	hard
attribute KEEP_HIERARCHY            : string;
attribute KEEP_HIERARCHY of Behavioral          : architecture is "TRUE";

-- attribute syn_keep 		: boolean;
-----------------------------------------------------------
-----------------------------------------------------------
type ram_type is array (0 to (2**ORDER - 1)) of std_logic_vector((width_mem - 1) downto 0);											
signal ram : ram_type := (others => (others => '0'));

attribute ram_style : string;
attribute ram_style of ram          : signal is "block";

attribute cascade_height : integer;
attribute cascade_height of ram     : signal is 1;

attribute syn_ramstyle 	: string;
-- attribute syn_ramstyle of ram 		: signal is "block_ram"; 
-- attribute syn_ramstyle of ram 		: signal is "no_rw_check";
attribute syn_ramstyle of Behavioral: architecture is "block_ram";

signal data, data_reg	: std_logic_vector((width_mem - 1) downto 0);		


-----------------------------------------------------------
-----------------------------------------------------------	
  
begin

-----------------------------------------------------------
-----------------------------------------------------------
process(clka)
begin
if (clka'event and clka = '1') then
	if ena = '1' then
		ram(conv_integer(addra)) <= dia;
	end if;
end if;
end process;


-----------------------------------------------------------
-----------------------------------------------------------
process (clkb)
begin
if (clkb'event and clkb = '1') then
    if enb = '1' then
		data 			<= ram(conv_integer(addrb));	  
    end if;
	if enb_reg = '1' then
		data_reg		<= data;
	end if;	
end if;
end process;


-----------------------------------------------------------
-----------------------------------------------------------
dob_reg					<= data_reg;


end Behavioral;

