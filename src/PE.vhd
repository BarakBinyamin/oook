library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.std_logic_unsigned.all;

entity PE is
  Port ( CLK : in STD_LOGIC;
         A   : in STD_LOGIC_VECTOR(32-1 downto 0);
         B   : in STD_LOGIC_VECTOR(32-1 downto 0);
         OP  : in STD_LOGIC_VECTOR(2 downto 0);
         C   : out STD_LOGIC_VECTOR(32-1 downto 0)
       );
end PE;

architecture Behavioral of PE is
    -- inrenal signals
     signal add_out  : STD_LOGIC_VECTOR(32-1 downto 0) := ( others => '0');
     signal big_mul  : STD_LOGIC_VECTOR(64-1 downto 0) := ( others => '0'); 
     signal mul_out  : STD_LOGIC_VECTOR(32-1 downto 0) := ( others => '0');
     signal temp_mac : STD_LOGIC_VECTOR(32-1 downto 0) := ( others => '0');
     signal mac_out  : STD_LOGIC_VECTOR(32-1 downto 0) := ( others => '0'); 
     signal temp_c   :  STD_LOGIC_VECTOR(32-1 downto 0) := ( others => '0'); 
begin

-- 000  ADD
-- 001  MUL
-- 010  MAC
-- 011  CLR
-- ELSE NOP

 -- Functionality
 temp_mac <= mac_out when falling_edge(CLK);                 -- Register
 add_out <= A + B;
 big_mul<= A * B;
 mul_out <= big_mul(31 downto 0);
 
 with OP select 
     mac_out <= temp_mac + big_mul(31 downto 0) when "010", -- MAC
               (others => '0')     when "011",              -- CLEAR
                mac_out            when others;             -- HOLD
 with OP select 
        temp_c <= add_out           when "000",               -- ADD
                  mul_out           when "001",               -- MUL
                  mac_out           when "010",               -- MAC
                 (others => '0')    when others;              -- NOP
   
   C <= temp_c when rising_edge(CLK);                         -- CLK'd output

end Behavioral;
