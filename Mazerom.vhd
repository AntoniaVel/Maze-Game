library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity Mazerom is
   port (
           button1: in std_logic;
			  button2: in std_logic;
			  button3: in std_logic;
			  button4: in std_logic;
           clk   : in std_logic;
           rst     : in std_logic;
           hsync   : out std_logic;
           vsync   : out std_logic;
           red     : out std_logic_vector(3 downto 0);
           green   : out std_logic_vector(3 downto 0);
           blue    : out std_logic_vector(3 downto 0)
           );
           
end Mazerom;

architecture RTL of Mazerom is
  type ram is array (0 to 11) of std_logic_vector(31 downto 0);
  --signal data    :std_logic_vector(31 downto 0);
 
  signal hcount  : std_logic_vector ( 3 downto 0);
  signal address : std_logic_vector(3 downto 0);
  signal clk_25  : std_logic;
  signal hpos    : integer range 0 to 799;
  signal vpos    : integer range 0 to 523;
  signal b       : std_logic_vector (1 downto 0);
  signal game : ram;
  signal vposition :std_logic_vector(3 downto 0);
  signal hposition :std_logic_vector(3 downto 0);
  signal last :std_logic_vector(1 downto 0);
  signal old_button1:std_logic_vector(1 downto 0);
  signal old_button2:std_logic_vector(1 downto 0);
  signal old_button3:std_logic_vector(1 downto 0);
  signal old_button4:std_logic_vector(1 downto 0);
  signal up : std_logic;
  signal down :std_logic;
  signal lft :std_logic;
  signal rght :std_logic;
  
  begin
  
  up <= (not old_button1(0)) and old_button1(1);
  down <= (not old_button2(0)) and old_button2(1);
  lft <= (not old_button3(0)) and old_button3(1);
  rght <= (not old_button4(0)) and old_button4(1);
  
  process(clk)
		begin
			if rising_edge(clk) then
				if clk_25='1'then
					old_button1(0) <= button1;
					old_button2(0) <= button2;
					old_button3(0) <= button3;
					old_button4(0) <= button4;
					old_button1(1) <= old_button1(0);
					old_button2(1) <= old_button2(0);
					old_button3(1) <= old_button3(0);
					old_button4(1) <= old_button4(0);
				end if;
			end if;
	end process;		
	 
  process(clk, rst)
     begin
       if rst = '0' then
         clk_25<= '0';
       elsif rising_edge(clk) then
         clk_25 <= not(clk_25);
     end if;
  end process;
  
  process(clk,rst)
    begin
      if rst='0' then 
        hpos<=0;
        vpos<=0;
      else
        if rising_edge(clk) then
			   if (clk_25='1') then
          if(hpos<799) then
             hpos<=hpos+1;
			    else 
             hpos<=0;
					   if(vpos<523) then
                  vpos<=vpos+1;
             else
               vpos<=0;
             end if;       
          end if;
			 end if;
	    end if;
	   end if;
       if (hpos>655 and hpos<752) then
           hsync <= '0';
         else
           hsync <= '1';
      end if;
      if  (vpos>490 and vpos<493) then 
           vsync <= '0';
         else 
            vsync <= '1';   
      end if;
    end process;
    
    process(clk,rst,hpos,vpos)
      begin
        if rst = '0' then
          address <= (others=>'0');
			hcount<="0000";
			
     else
	  if rising_edge(clk) then 
        if (clk_25='1') then      
            if (hpos<640 and vpos<480) then

				  hcount<=std_logic_vector(to_unsigned(hpos/40,hcount'length));
				  address<=std_logic_vector(to_unsigned(vpos/40,address'length));
				              
	            --else
					--address<="1111";
						     
            end if;
          end if; 
         end if;      
      end if;
    		
       end process;
      
       process(game)
         begin
         b<=game(conv_integer(address))((15-conv_integer(hcount))*2+1) & game(conv_integer(address))((15-conv_integer(hcount))*2);   
     if (hpos<640 and vpos<480) then

		case b is 
		 
       when "00" => red <="0000";
                    green <="0000";
                    blue <="0000";
       when "01" => red <="1111";
                    green <="1111";
                    blue <="1111";
       when "10" => red <="0000";
                    green <="0000";
                    blue <="1111";
       when "11" => red <="0000";
                    green <="1111";
                    blue <="0000";
      when others =>red <="1000";
                    green <="0100";
                    blue <="0010";  
      end case;
        
	else 
	                 red <="0000";
                    green <="0000";
                    blue <="0000";
	end if;	  
		  end process;
		    
     process(clk,rst)
      begin
			if rst='0' then
              game(0)<= "11000101010100010101010101000001";
              game(1)<= "01000101000000010101000000000000";
              game(2)<= "01000101010100010101000101010110";
              game(3)<= "01000101010100010000000101000101";
              game(4)<= "01010101010100010101000101000101";
              game(5)<= "01010101010100010101000101000101";
              game(6)<= "00000000010100010101000101000000";
              game(7)<= "01010101010100010101000101000101";
				  game(8)<= "01010101010100010101010101000101";
              game(9)<= "01010000000000010101010101000101";
              game(10)<="01010101010100010000000000000001";
              game(11)<="01010101010101010101010101010101";
				  last<="10";
				  hposition<="0000";
				  vposition<="0000";
			else
			 if rising_edge(clk) then
			  if clk_25= '1' then
					if up='1' then
						if vposition > 0 then 
							if (game(conv_integer(vposition-1))((15-conv_integer(hposition))*2+1) /= '0') or (game(conv_integer(vposition-1))((15-conv_integer(hposition))*2) /='0') then 
							   
								game(conv_integer(vposition-1))((15-conv_integer(hposition))*2+1)<='1'; 
								game(conv_integer(vposition-1))((15-conv_integer(hposition))*2)<= '1';
								vposition<=vposition-1;
								last<=game(conv_integer(vposition-1))((15-conv_integer(hposition))*2+1) & game(conv_integer(vposition-1))((15-conv_integer(hposition))*2);
								game(conv_integer(vposition))((15-conv_integer(hposition))*2+1)<=last(1) ;
								game(conv_integer(vposition))((15-conv_integer(hposition))*2)<=last(0);
							end if;
						end if;	
					elsif down ='1' then
						if vposition < 11 then 
							if game(conv_integer(vposition+1))((15-conv_integer(hposition))*2+1) /='0' or game(conv_integer(vposition+1))((15-conv_integer(hposition))*2) /= '0' then
								game(conv_integer(vposition+1))((15-conv_integer(hposition))*2+1)<='1';
								game(conv_integer(vposition+1))((15-conv_integer(hposition))*2)<= '1';
								vposition<=vposition + 1;
								last<=game(conv_integer(vposition + 1))((15-conv_integer(hposition))*2+1) & game(conv_integer(vposition+1))((15-conv_integer(hposition))*2);
								game(conv_integer(vposition))((15-conv_integer(hposition))*2+1)<=last(1);
								game(conv_integer(vposition))((15-conv_integer(hposition))*2)<=last(0);
							end if;
						end if;
					elsif rght ='1' then
						if hposition < 15  then 
							if game(conv_integer(vposition))((15-conv_integer(hposition))*2-1) /='0' or game(conv_integer(vposition))((15-conv_integer(hposition))*2-2) /= '0' then
								game(conv_integer(vposition))((15-conv_integer(hposition))*2-1)<='1';
								game(conv_integer(vposition))((15-conv_integer(hposition))*2-2)<= '1';
								hposition<=hposition + 1;
								last<=game(conv_integer(vposition))((15-conv_integer(hposition))*2-1) & game(conv_integer(vposition))((15-conv_integer(hposition))*2-2);
								game(conv_integer(vposition))((15-conv_integer(hposition))*2+1) <= last(1);
								game(conv_integer(vposition))((15-conv_integer(hposition))*2)<=last(0);
							end if;
						end if;
					elsif lft= '1' then
					if hposition > 0  then 
							if game(conv_integer(vposition))((15-conv_integer(hposition))*2+3) /='0' or game(conv_integer(vposition))((15-conv_integer(hposition))*2+2) /= '0' then
								game(conv_integer(vposition))((15-conv_integer(hposition))*2+3)<= '1';
								game(conv_integer(vposition))((15-conv_integer(hposition))*2+2)<= '1';
								hposition<=hposition - 1;
								last<=game(conv_integer(vposition))((15-conv_integer(hposition))*2+3) & game(conv_integer(vposition))((15-conv_integer(hposition))*2+2);
								game(conv_integer(vposition))((15-conv_integer(hposition))*2+1)<=last(1);
								game(conv_integer(vposition))((15-conv_integer(hposition))*2)<=last(0);
							end if;
						end if;
					end if;
				  end if;
			 end if;
			end if;
				
      end process;
end RTL;