library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VendingMachine_tb is
end entity VendingMachine_tb;

architecture bench of VendingMachine_tb is
    signal clk : std_logic := '0';
    signal Reset : std_logic := '0';
    signal Input1RON, Input5RON, Input10RON: std_logic := '0';
    signal RequestProduct1, RequestProduct2, RequestChange: std_logic := '0';
    signal display_sum : std_logic_vector(4 downto 0);
    signal DispenseProduct1: std_logic := '0';
    signal DispenseProduct2: std_logic := '0';
    signal Give1RONChange, Give5RONChange: std_logic := '0';
    signal MaxMoneyReached : std_logic := '0';
   
    -- Perioada de sincronizare
    constant clock_period : time := 10 ns;

    -- Procedura care simuleaza introducerea unei monezi
    procedure InsertMoney(signal coinInput : out std_logic; value : std_logic) is
    begin
        coinInput <= value;
        wait for clock_period;
        coinInput <= '0';
    end procedure InsertMoney;

    -- Procedura care simuleaza efectuarea unei actiuni (ex retragere rest)
    procedure SimulateAction(signal actionSignal : out std_logic) is
    begin
        actionSignal <= '1';
        wait for clock_period;
        actionSignal <= '0';
    end procedure SimulateAction;
    
begin
    uut: entity work.VendingMachine
        port map (
            clk              => clk,
            Reset            => Reset,
            Input1RON        => Input1RON,
            Input5RON        => Input5RON,
            Input10RON       => Input10RON,
            RequestProduct1   => RequestProduct1,
            RequestProduct2   => RequestProduct2,	
            RequestChange    => RequestChange,
            display_sum     => display_sum,
            DispenseProduct1  => DispenseProduct1,
            DispenseProduct2  => DispenseProduct2,
            Give1RONChange   => Give1RONChange,
            Give5RONChange   => Give5RONChange,
            MaxMoneyReached  => MaxMoneyReached
        );

    clk_process : process
    begin
        while true loop
            clk <= not clk;
            wait for clock_period / 2;
        end loop;
    end process clk_process;

    stimulus_process : process
    begin
        -- Incepem prin a reseta automatul
        SimulateAction(Reset);
        
        -- Aici testam comisionul in cazul in care sunt mai mult de 10 lei si nu a fost cumparat produs
        InsertMoney(Input10RON, '1');  -- Insert 10 Lei
        SimulateAction(RequestChange);
        
        wait for 100 ns;

        --Aici testam ca daca se depaseste suma maxima (ultima bacnota nu este luata)
        InsertMoney(Input5RON, '1');  -- Insert 5 Lei
        InsertMoney(Input1RON, '1');  -- Insert 1 Lei
        InsertMoney(Input10RON, '1'); -- Insert 10 Lei

        --Cerem produs
        SimulateAction(RequestProduct1);

        wait for 100 ns;

        -- Mai inseram bani
        InsertMoney(Input5RON, '1'); -- Insert 5 Lei
        InsertMoney(Input1RON, '1'); -- Insert 1 Lei

        -- Cerem rest
        SimulateAction(RequestChange); 

        wait for 100 ns;

        InsertMoney(Input10RON, '1');  -- Insert 1 Lei
        InsertMoney(Input1RON, '1');  -- Insert 10 Lei
        SimulateAction(RequestChange);
        
        wait for 100 ns;
        
        InsertMoney(Input10RON, '1');
        SimulateAction(RequestProduct2);
        
        wait for 100 ns;
        
        InsertMoney(Input10RON, '1');
        SimulateAction(RequestChange);
      
        wait for 100 ns;
    
        -- Sfarsitul simularii
    end process stimulus_process;
    
end bench;