library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.std_logic_unsigned.ALL;
entity source is
  Port (
  --clk is clock
   clk, rst, echo, man : in std_logic;
   trig, digSelect : out std_logic;
   sevenSeg : out std_logic_vector(6 downto 0)
   );
end source;
architecture Behavioral of source is
type statetype is (S0,S1,S2,S3,S4);
signal state : statetype := S0;
-- Count is internal counter distINC is final inches distance and dist is the computed distance that can be displayed (only the last digit basically)
signal count, distINC,distCM, dist, dist2 : integer := 0;
-- These registers are used to prevent multi driver error ( i hate that error )
signal trigRegister, digSelectReg : std_logic := '0';
signal sevenSegReg : std_logic_vector(6 downto 0) := "0111111";
-- Turning the frequency into the a unit of measurement given the speed of sound
constant freq : integer := 125000000;
constant trigUS : integer := 10 * (freq/1000000);
constant usToINC : integer := 148 * integer(freq/(1000000));
constant usToCM : integer := 58 * integer(freq/(1000000));

begin

process(clk)
    begin
    if rst ='1' then
    state <=S0;
--    dist <= 0;
    count <= 0;
    distINC <= 0;
    trigRegister <= '0';
    sevenSegReg <= "0111111";
--    sevenSegReg2 <= "0111111";
    elsif rising_edge(clk) then
    
        case state is
            when S0 =>
--                digSelectReg <= not digSelectReg;
                trigRegister <= '1';
                if count < trigUS then
                    count <= count+1;
                else
                    trigRegister <= '0';
                    count <= 0;
                    state <= S1;
                end if;
                
                
                
             when S1 =>
                if echo = '1' then
                    distINC <= 0;
                    count <= 0;
                    state <= S2;
                 end if;
                 
                 
                 
              when S2 =>
                if echo = '1' then 
                    count <= count+1;
                    
                    -- timeout else if
                elsif count > (freq/1000) then
                count <= 0;
                state <= S0;
                
                else
                        distINC <= count / usToINC;
                        distCM <= count /usToCM;
                        count <= 0;   
                    state <= S3;
              
                end if;    
                
                
                
                      
                when S3 =>
                if man = '1' then 
--                dist <= (distINC * 2) + (distINC / 2);
                -- CM to inches
--                dist <= 2*(dist / 5);
                dist <= distCM mod 10;    
                dist2 <= ((distCM mod 100) - (distCM mod 10))/10;            
                else
                dist <= distINC mod 10;
                dist2 <= ((distINC mod 100) - (distINC mod 10))/10;            
                end if;
                count <= 0;
                state <= S4;
                
              when S4 =>
                
                if count < trigUS*6 then
                    count <= count+1;
                    state <= S4;
                else
                    count <= 0;
                    state <= S0;
                end if;
                
                end case;
                
                
                
                
                if digSelectReg <= '1' then
                case (dist) is
                            when 0 => sevenSegReg <= "0111111";
                            when 1 => sevenSegReg <= "0000110";
                            when 2 => sevenSegReg <= "1011011";
                            when 3 => sevenSegReg <= "1001111";
                            when 4 => sevenSegReg <= "1100110";
                            when 5 => sevenSegReg <= "1101101";
                            when 6 => sevenSegReg <= "1111101";
                            when 7 => sevenSegReg <= "0000111";
                            when 8 => sevenSegReg <= "1111111";
                            when 9 => sevenSegReg <= "1101111";
                            when others => sevenSegReg <= "0111111";
                        end case;
            else
                 case (dist2) is
                            when 0 => sevenSegReg <= "0111111";
                            when 1 => sevenSegReg <= "0000110";
                            when 2 => sevenSegReg <= "1011011";
                            when 3 => sevenSegReg <= "1001111";
                            when 4 => sevenSegReg <= "1100110";
                            when 5 => sevenSegReg <= "1101101";
                            when 6 => sevenSegReg <= "1111101";
                            when 7 => sevenSegReg <= "0000111";
                            when 8 => sevenSegReg <= "1111111";
                            when 9 => sevenSegReg <= "1101111";
                            when others => sevenSegReg <= "0111111";
                        end case; 
                        
                        
                end if;
--                end case;
                
              end if;
                                  end process;

          trig <= trigRegister;
          digSelect <= digSelectReg;
          sevenSeg <= sevenSegReg;

end Behavioral;
