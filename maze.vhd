library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity maze is
  port (clk          : in std_logic;
        rst          : in std_logic;
        hsync        : out std_logic;
        vsync        : out std_logic;
        red          : out std_logic_vector(3 downto 0);
        green        : out std_logic_vector(3 downto 0);
        blue         : out std_logic_vector(3 downto 0);
        btn1_pressed : in std_logic;
        btn2_pressed : in std_logic;
        btn3_pressed : in std_logic;
        btn4_pressed : in std_logic);
end maze;

architecture bhv of maze is
  
    component rom is
        port (address	:	in std_logic_vector(3 downto 0);
		          data		:	out std_logic_vector(31 downto 0));
    end component rom;
  
  -- clock
  signal c_en :std_logic;

  -- rows
  signal i    :std_logic_vector (10 downto 0);
  signal limI :integer;
  
  -- columns
  signal j    :std_logic_vector (10 downto 0);
  signal limJ :integer;
  
  -- vsync & hsync store
  signal vs, hs :std_logic;
  
  -- register file
  signal rdata  :std_logic_vector(31 downto 0);
  signal addr   :std_logic_vector(3 downto 0);
  
  -- player
  signal playerx :std_logic_vector (3 downto 0);
  signal playery :std_logic_vector (3 downto 0);
  
  -- buttons
  signal old_btn1_pressed : std_logic;
  signal old_btn2_pressed : std_logic;
  signal old_btn3_pressed : std_logic;
  signal old_btn4_pressed : std_logic;
  
  --moves
  signal new_move1 : std_logic;
  signal new_move2 : std_logic;
  signal new_move3 : std_logic;
  signal new_move4 : std_logic;

begin
  
  xr: rom port map(addr, rdata);
    
  ---------------------------------------------
  -- Clock
  ---------------------------------------------
  
  -- 25 MHz Clock Enable with asynchronous reset
  process (clk, rst)
    begin
    if rst='0' then
      c_en<= '0';
    elsif rising_edge(clk) then
      c_en<= not c_en;
    end if;
  end process;
  
  ---------------------------------------------
  -- 0-to-1 edge detector on button_pressed
  ---------------------------------------------
  
  process(clk)
    begin
    if rising_edge(clk) then
      old_btn1_pressed <= btn1_pressed;
      old_btn2_pressed <= btn2_pressed;
      old_btn3_pressed <= btn3_pressed;
      old_btn4_pressed <= btn4_pressed;
    end if;
  end process;
  
  new_move1 <= (not old_btn1_pressed) and btn1_pressed;
  new_move2 <= (not old_btn2_pressed) and btn2_pressed;
  new_move3 <= (not old_btn3_pressed) and btn3_pressed;
  new_move4 <= (not old_btn4_pressed) and btn4_pressed;
  
  ---------------------------------------------
  -- Player's Moves
  ---------------------------------------------
  
  process (clk, rst)
    begin
      if rising_edge(clk) then
        if rst='0' then
          playerx<= (others=>'0');
          playery<= (others=>'0');
        else
          if playery > 0 and playery < 11 then        -- inside vertical borders
            if new_move1 = '1' and rdata(conv_integer(playery - 1)*2) /= '0' and rdata(conv_integer(playery - 1)*2 + 1) /= '0' then
              playery<= playery - 1;
            elsif new_move2 = '1' and rdata(conv_integer(playery + 1)*2) /= '0' and rdata(conv_integer(playery + 1)*2 + 1) /= '0'  then
              playery<= playery + 1;
            end if;
          end if;
          if playerx > 0 and playerx < 15 then     -- inside horizontal borders
            if new_move3 = '1' and rdata(conv_integer(playerx - 1)*2) /= '0' and rdata(conv_integer(playerx - 1)*2 + 1) /= '0' then
              playerx<= playery - 1;
            elsif new_move4 = '1' and rdata(conv_integer(playerx + 1)*2) /= '0' and rdata(conv_integer(playerx + 1)*2 + 1) /= '0'  then
              playerx<= playery + 1;
            end if;
          end if;
        end if;
      end if;
  end process;  

  ---------------------------------------------
  -- Iteration Counter
  --------------------------------------------- 
  
  process (clk, rst)
    begin
    if rst='0' then
      i<= (others=>'0');
      j<= (others=>'0');
      addr<= (others=>'0');
      limI<= 0;
      limJ<= 0; 
    elsif rising_edge(clk) then
		  if c_en='1' then
			
			if i = limI then
			   limI<=limI + 40;
			   if limI = 640 then
				  limI <= 0;
				end if;
			 end if;
			 
			 if j = limJ then
			   limJ<= limJ + 40;
				if limJ = 480 then
				  limJ <= 0;
				end if;
				if j/=0 then
					addr<= addr + 1;
				end if;
			 end if;
		  
			 if i=800 then
				  i<= (others=>'0');
				  if j=524 then
					  j<= (others=>'0');
					  addr<= (others=>'0');
				  else
					  j<=j+1;
				  end if;
			 else
				  i<= i+1;
			 end if;
			 
			 
		end if;
	end if;
end process;

  ---------------------------------------------
  -- HSYNC & VSYNC
  --------------------------------------------- 
  
  -- HSYNC
  process (clk, rst)
    begin
	 if rising_edge(clk) then
		if c_en='1' then
			if i>639 then
				if i<656 then
					-- front porch
					hsync<= '1';
					hs<= '1';
				elsif i<752 then
					-- sync pulse
					hsync<= '0';
					hs<= '0';
				elsif i<799 then
					--back porch - 1
					hsync<= '1';
					hs<= '1';
				elsif i<800 then
					-- back porch last clock
					hsync<= '1';
					hs<= '1';
				end if;
			elsif i<640 then
				hsync<= '1';
				hs<= '1';
			end if;
		end if;
	end if;
  end process;
  
  -- VSYNC
  process (c_en, j, i, clk, vs)
    begin
	 if rising_edge(clk) then
		if c_en='1' then
			if j>479 then
				if j<491 then
					-- front porch
					vsync<= '1';
					vs<= '1'; 
				elsif j<493 then
					-- sync pulse
					vsync<= '0';
					vs<= '0';
				elsif j<523 then
					--back porch - 1
					vsync<='1';
					vs<= '1';
				elsif j<524 then
					-- back porch last clock
					vsync<= '1';
					vs<= '1';
				end if;
			elsif j<480 then
				vsync<= '1';
				vs<= '1';
			end if;
		end if;
	end if;
  end process;
  
  ---------------------------------------------
  -- Panel Display
  --------------------------------------------- 
  
  process (i, j, limI, limJ, c_en, clk)
    begin 
	 if rising_edge(clk) and c_en='1' then
	   if vs='1' and hs='1' then
		  if j<limJ then
			 if i < limI then
			   if rdata(31-(conv_integer(limI / 40)-1)*2)='0' and rdata(30-(conv_integer(limI / 40)-1)*2)='0' then
					red<= "1001";
					green<= "0100";
					blue<= "1101";
				elsif rdata(31-(conv_integer(limI / 40)-1)*2)='0' and rdata(30-(conv_integer(limI / 40)-1)*2)='1' then
					red<= "0000";
					green<= "0000";
					blue<= "0000";
				elsif rdata(31-(conv_integer(limI / 40)-1)*2)='1' and rdata(30-(conv_integer(limI / 40)-1)*2)='0' then
					red<= "0011";
					green<= "0100";
					blue<= "1001";
				else
					red<= "0000";
					green<= "0000";
					blue<= "1111";
				end if;
			end if;
		7end if;
	else
		red<= "0000";
		green<= "0000";
		blue<= "0000";
	end if;
 end if;
 end process;
        
end bhv;