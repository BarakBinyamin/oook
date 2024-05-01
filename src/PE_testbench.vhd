library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.std_logic_unsigned.all;

entity PE_testbench is
end PE_testbench;

architecture Behavioral of PE_testbench is
    type test_vector1 is record
        A   :  STD_LOGIC_VECTOR(32-1 downto 0);
        B   :  STD_LOGIC_VECTOR(32-1 downto 0);
        OP  :  STD_LOGIC_VECTOR(2 downto 0);
        C   :  STD_LOGIC_VECTOR(32-1 downto 0);
    end record;
    
    -- Test cases, with c being the expected result
    type test1 is array (natural range <>) of test_vector1;
    constant test1_test : test1 :=(
         (A => x"10000000", B=>x"00000000", OP=>"000", C=>x"10000000" ), -- ADD 10000000 to 0
         (A => x"0000000A", B=>x"00000005", OP=>"001", C=>x"10000032" ), -- MUL 10 n 5 to get 50
         (A => x"0000000A", B=>x"00000005", OP=>"010", C=>x"10000032" ), -- MAC 10 n 5 to get 50
         (A => x"0000000A", B=>x"00000005", OP=>"010", C=>x"10000064" ), -- MAC 10 n 5 to get 100
         (A => x"10000000", B=>x"00000000", OP=>"011", C=>x"00000000" ), -- CLR to get 0
         (A => x"0000000A", B=>x"00000005", OP=>"010", C=>x"10000032" ), -- MAC 10 n 5 to get 50
         (A => x"0000000A", B=>x"00000005", OP=>"100", C=>x"00000000" ), -- Do nothing and check if that does anything to the reg
         (A => x"0000000A", B=>x"00000005", OP=>"010", C=>x"10000064" )  -- MAC 10 n 5 to get 100
    );
    
    signal   clk        : std_logic                       := '0';
    signal   A_driver   : STD_LOGIC_VECTOR(32-1 downto 0) := ( others => '0');
    signal   B_driver   : STD_LOGIC_VECTOR(32-1 downto 0) := ( others => '0');
    signal   OP_driver  : STD_LOGIC_VECTOR(2 downto 0)    := ( others => '0');
    signal   C_internal : STD_LOGIC_VECTOR(32-1 downto 0) := ( others => '0');

    constant clkDelay  : time                             := 10ns;
    
begin
    
    UUT1: entity work.PE
        Port map(
          CLK => clk,
          A   => A_driver,
          B   => B_driver,
          OP  => OP_driver,
          C   => C_internal
        );
    clk_process:process begin
        clk<='0';
        wait for clkDelay/2;
        clk<='1';
        wait for clkDelay/2;
    end process;
    test_process:process begin
        -- test1
        for test_index in 0 to test1_test'length-1 loop
            wait until clk='0';
            A_driver  <= test1_test(test_index).A;
            B_driver  <= test1_test(test_index).B;
            OP_driver <= test1_test(test_index).OP;
            wait for clkDelay;
            assert C_internal = test1_test(test_index).C;
            report "Assert failed in test " & integer'image(test_index) severity error;
        end loop;   
    end process;
    
    assert false severity failure; 
end Behavioral;
