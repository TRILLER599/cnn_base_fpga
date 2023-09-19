----------------------------------------------------------------------------------
-- Company:         
-- Engineer:       Tsimur Zalilau
-- 
-- Create Date:    08/21/2023 
-- Design Name: 
-- Module Name:    FIFO_Fast_Ind - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 1.0 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FIFO_Fast_Ind is
generic( 
	ORDER       		: integer := 9;	  	    -- Порядок степени двойки адреса.	
    width_mem       	: integer := 32;		-- Размерность слова.
	threshold_full		: integer := 255;		-- Порог full
	Internal_RST_WR    	: integer := 0;
	Internal_RST_RD    	: integer := 1    
	); 
port ( 
	clk_wr				: in std_logic; 
	clk_rd				: in std_logic;     
    in_rst_wr			: in std_logic; 
    in_rst_rd			: in std_logic;  
	
    in_write 			: in std_logic; 
    in_data 			: in std_logic_vector((width_mem - 1) downto 0);
    in_read 			: in std_logic; 
    out_data 			: out std_logic_vector((width_mem - 1) downto 0);
    
    out_empty 			: out std_logic;		
	out_write_ready		: out std_logic);	
end FIFO_Fast_Ind;

architecture Behavioral of FIFO_Fast_Ind is

-----------------------------------------------------------
-----------------------------------------------------------
attribute syn_hier 		: string;
attribute syn_hier of Behavioral	: architecture is "hard";

attribute syn_keep 		: boolean;
attribute KEEP          : string;	
-- attribute DONT_TOUCH    : string;
-----------------------------------------------------------
-----------------------------------------------------------
signal fase_write		: std_logic_vector(6 downto 0) := "0000001";	
type w7c4_type is array (0 to 3) of std_logic_vector(6 downto 0);
signal level_write		: w7c4_type := (others => (others => '0'));	
signal event_write		: std_logic_vector(6 downto 0) := "0000000";		
signal count_write		: std_logic_vector(2 downto 0) := "000";

signal diff_cambio	    : std_logic_vector(ORDER downto 0);	
attribute syn_keep of diff_cambio : signal is true;	
attribute KEEP of diff_cambio : signal is "TRUE";
-- attribute DONT_TOUCH of diff_cambio : signal is "TRUE"; -- label is "TRUE"
signal difference 		: std_logic_vector(ORDER downto 0);	


-----------------------------------------------------------
-----------------------------------------------------------
signal write_ready      : std_logic;

signal need_read, enable_read, internal_read		    : std_logic;		

signal empty 			: std_logic;
signal presence         : std_logic_vector(2 downto 0);	
signal presence_long	: std_logic_vector(5 downto 0);	

signal pip_update       : std_logic;
type data_type is array (1 to 3) of std_logic_vector((width_mem - 1) downto 0);											
signal data 		    : data_type;


-----------------------------------------------------------
-----------------------------------------------------------	
signal controll_rst_wr	: std_logic_vector(1 downto 0);
signal controll_rst_rd	: std_logic_vector(1 downto 0);
signal rst_wr			: std_logic;
signal rst_rd			: std_logic;


-----------------------------------------------------------
-----------------------------------------------------------
component bram_reg
generic( 
	ORDER       		: integer;	  		-- Порядок степени двойки адреса.	
    width_mem       	: integer			-- Размерность слова.
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
end component;		

signal addra_bram		: std_logic_vector((ORDER - 1) downto 0);			
signal addrb_bram		: std_logic_vector((ORDER - 1) downto 0);	
signal pd_ram_data	    : std_logic_vector((width_mem - 1) downto 0);


-----------------------------------------------------------
-----------------------------------------------------------

begin

-----------------------------------------------------------
-----------------------------------------------------------
gen_rst_wr_ctrl : if Internal_RST_WR /= 0 generate 

    process (clk_wr)				
    begin 
    if (clk_wr = '1' and clk_wr'event) then
        controll_rst_wr <= (controll_rst_wr(0)&in_rst_wr);
    end if;
    end process;  
	rst_wr				<= controll_rst_wr(1);
 
end generate gen_rst_wr_ctrl;

gen_rst_wr : if Internal_RST_WR = 0 generate 
	controll_rst_wr(0)	<= in_rst_wr;
	controll_rst_wr(1)	<= controll_rst_wr(0);    
	rst_wr				<= controll_rst_wr(1);
end generate gen_rst_wr;


----
gen_rst_rd_ctrl : if Internal_RST_RD /= 0 generate 

    process (clk_rd)				
    begin 
    if (clk_rd = '1' and clk_rd'event) then
        controll_rst_rd <= (controll_rst_rd(0)&in_rst_rd);
    end if;
    end process;
	rst_rd				<= controll_rst_rd(1);
    
end generate gen_rst_rd_ctrl;

gen_rst_rd : if Internal_RST_RD = 0 generate 
	controll_rst_rd(0)	<= in_rst_rd;
	controll_rst_rd(1)	<= controll_rst_rd(0);    
	rst_rd				<= controll_rst_rd(1);
end generate gen_rst_rd;


-----------------------------------------------------------
-----------------------------------------------------------
u_BRam_Data : bram_reg
generic map( 
	ORDER       		=> ORDER,
    width_mem       	=> width_mem
	) 
port map( 
	clka				=> clk_wr,
	ena  				=> in_write,	
	addra				=> addra_bram,
	dia  				=> in_data,
	
	clkb				=> clk_rd,
	enb  				=> enable_read,	
	addrb				=> addrb_bram,
	enb_reg  			=> internal_read,	
	dob_reg				=> pd_ram_data);


-----------------------------------------------------------
----------------------------------------------------------- 
process (clk_wr)				
begin 
if (clk_wr = '1' and clk_wr'event) then
	if rst_wr = '1' then
		addra_bram		<= (others => '0');	
		fase_write		<= "0000001";		
	else
		if in_write = '1' then		
			addra_bram	<= (addra_bram + 1);			
		else
			addra_bram	<= addra_bram;			
		end if;	
		
		if in_write = '1' then
			fase_write	<= (fase_write(5 downto 0)&fase_write(6));
		else
			fase_write  <= fase_write;
		end if;				
	end if;	
	----------------	не сбрасываю	----------------
	----------------
    for i in 0 to 6 loop
        if in_write = '1' then
            if fase_write(i) = '1' then
                level_write(0)(i)   <= (not level_write(0)(i));
            else
                level_write(0)(i)   <= level_write(0)(i);
            end if;	
        else
            level_write(0)(i)	    <= level_write(0)(i);
        end if;	
    end loop;
    
end if;
end process;


process (clk_rd)	
variable count_write_t	: std_logic_vector(2 downto 0);					
begin 
if (clk_rd = '1' and clk_rd'event) then
	----------------	не сбрасываю	----------------
	----------------
	level_write(1)		<= level_write(0);
	level_write(2)		<= level_write(1);
	level_write(3)		<= level_write(2);	
	
	count_write_t		:= "000";	
	for i in 0 to 6 loop
		if level_write(2)(i) /= level_write(3)(i) then
			event_write(i)			<= '1';
		else
			event_write(i)			<= '0';
		end if;	
		count_write_t	:= (count_write_t + ('0'&event_write(i)));
	end loop;
	count_write			<= count_write_t;    
    
end if;
end process;


-----------------------------------------------------------
----------------------------------------------------------- 
diff_cambio(ORDER downto 3) <= (others => '1') 
                                when ((enable_read = '1') and (count_write = 0)) 
                                else (others => '0');                    
diff_cambio(2 downto 0) <= count_write when enable_read = '0'
                                else (count_write + "111");	

process (clk_rd)				
begin 
if (clk_rd = '1' and clk_rd'event) then
	if rst_rd = '1' then
		difference		<= (others => '1');			
	else                          
        difference      <= difference + diff_cambio; 
    end if;
	----------------	не сбрасываю	----------------
	----------------
end if;
end process;

-----------------------------------------------------------
-----------------------------------------------------------
-- Одноклоковая часть в домене clk_rd, идентичная реализации
-- FIFO_Fast.h для С++
-----------------------------------------------------------
-----------------------------------------------------------
enable_read             <= need_read and (not difference(ORDER));

process (clk_rd)			
begin 
if (clk_rd = '1' and clk_rd'event) then
	if rst_rd = '1' then
		addrb_bram		<= (others => '0');			
	else
		if enable_read = '1' then
			addrb_bram	<= (addrb_bram + 1);			
		else
			addrb_bram	<= addrb_bram;		
		end if;			
	end if;	
	----------------	не сбрасываю	----------------
	---------------- 
    internal_read       <= enable_read;
    
end if;
end process;


-----------------------------------------------------------
-----------------------------------------------------------
presence_long			<= ((not empty)& presence& internal_read& enable_read);

process (clk_rd)	
variable presence_count	: std_logic_vector(2 downto 0);		
begin 
if (clk_rd = '1' and clk_rd'event) then
	----------------	не сбрасываю	----------------
	----------------
	presence_count		:= "000";
	for i in 0 to 5 loop
		if presence_long(i) = '1' then
			presence_count			:= (presence_count + 1);
		else
			presence_count			:= presence_count;
		end if;	
	end loop;
	----------------	сбрасываю	    ----------------
	----------------
	if rst_rd = '1' then
		need_read		<= '0';			
	else
        if (presence_count< 4) or (in_read = '1') then
            need_read	    <= '1';
        else
            need_read	    <= '0';
        end if;
    end if;	

end if;
end process;


-----------------------------------------------------------
-----------------------------------------------------------
pip_update              <= empty or ((not empty) and in_read);

process (clk_rd)		
begin 
if (clk_rd = '1' and clk_rd'event) then
	if rst_rd = '1' then
		empty 			<= '1';
		presence	    <= "000";
	else	
		if pip_update = '1' then
            empty       <= not (presence(2) or presence(1) or presence(0));
            
            presence(2) <= presence(2) and presence(1);
            
            if presence(2) = '1' then
                presence(1) <= presence(0);
            else
                presence(1) <= presence(1) and presence(0);
            end if;
            
            presence(0) <= internal_read;
        else
            empty       <= empty;
            
            presence(2) <= presence(2) or presence(1);
            
            if presence(2) = '1' then
                presence(1) <= presence(1) or presence(0);
            else    
                presence(1) <= presence(0);
            end if;
            
            if presence(2 downto 1) = "11" then
                presence(0) <= presence(0) or internal_read;
            else
                presence(0) <= internal_read;
            end if;
        end if;
	end if;	
	----------------	не сбрасываю	----------------
	----------------
    if pip_update = '1' then
        if presence(2) = '1' then
            data(3)     <= data(2);
        elsif presence(1) = '1' then
            data(3)     <= data(1);
        else
            data(3)     <= pd_ram_data;
        end if;	
    end if;	
    
	if pip_update = '1' then
        if presence(2 downto 1) = "11" then
            data(2)     <= data(1);
        end if;	
        if (presence(2 downto 1) /= "00") and (presence(0) = '1') then
            data(1)     <= pd_ram_data;
        end if;	
    else
        if presence(2 downto 1) = "01" then
            data(2)     <= data(1);
        end if;	
        if (presence(2 downto 1) /= "11") and (presence(0) = '1') then
            data(1)     <= pd_ram_data;
        end if;	     
    end if;	
    
end if;
end process;


-----------------------------------------------------------
-----------------------------------------------------------
gen_write_ready : if threshold_full /= 0 generate 

    process (clk_rd)		
    begin 
    if (clk_rd = '1' and clk_rd'event) then
        ----------------	не сбрасываю	----------------
        ----------------		
        if ((difference(ORDER)='0') and (difference((ORDER - 1) downto 0)> threshold_full)) then
            write_ready <= '0';
        else
            write_ready <= '1';
        end if;	
        
    end if;
    end process;
    
end generate gen_write_ready;

gen_write_ready_n : if threshold_full = 0 generate
    write_ready         <= '1';
end generate gen_write_ready_n;

-----------------------------------------------------------
-----------------------------------------------------------

out_data 				<= data(3);
out_empty 				<= empty;	
out_write_ready	        <= write_ready;


end Behavioral;

