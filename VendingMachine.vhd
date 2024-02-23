library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VendingMachine is
    Port (
        clk: in std_logic;
        Input1RON, Input5RON, Input10RON : in std_logic;
        RequestProduct1,RequestProduct2, RequestChange : in std_logic;
        display_sum : out std_logic_vector(4 downto 0);
        DispenseProduct1, DispenseProduct2 : out std_logic;
        Give1RONChange, Give5RONChange : out std_logic;
        MaxMoneyReached : out std_logic;
        Reset : in std_logic 
    );
end entity VendingMachine;

architecture Behavioral of VendingMachine is
    type MachineState is (Idle, WaitingForMoney, DispensingProduct1, DispensingProduct2, DispensingChange);
    signal currentState : MachineState := Idle;
    signal nextState : MachineState := Idle;
    signal accumulatedSum : integer := 0;
    signal productPrice1 : integer := 3;
    signal ProductPrice2 : integer:= 7;
    signal productPurchased : boolean;

begin
    
-- metoda asincrona
process (clk)
    begin
        if Reset = '1' then
            -- resetam datele aparatului
            accumulatedSum <= 0; 
            productPurchased <= false;
            nextState <= Idle;
            
            Give1RONChange <= '0';
            Give5RONChange <= '0';
            DispenseProduct1 <= '0';
            DispenseProduct2 <= '0';
            MaxMoneyReached <= '0'; 
            display_sum <= "00000"; 
        else 
            -- trecem la starea urmatoare:
            currentState <= nextState;
            
            if rising_edge(clk) then
                --Actualizam display-ul
                --Convertim variabila "ccumulatedSum" de la tip "integer" la tip "std_logic_vector(4 downto 0)";
                display_sum <= std_logic_vector(to_unsigned(accumulatedSum, 5));
                
                ---- initializam starea "default" de afisare pentru toate semnalele 
                Give1RONChange <= '0';
                Give5RONChange <= '0';
                DispenseProduct1 <= '0';
                DispenseProduct2 <= '0';
                MaxMoneyReached <= '0';  
            case currentState is
                when Idle =>
                    productPurchased <= false;
                    if Input1RON = '1' then
                        accumulatedSum <= accumulatedSum + 1;
                        nextState <= WaitingForMoney;
                    elsif Input5RON = '1' then
                        accumulatedSum <= accumulatedSum + 5;
                        nextState <= WaitingForMoney;
                    elsif Input10RON = '1' then
                        accumulatedSum <= accumulatedSum + 10;
                        nextState <= WaitingForMoney;
                    else
                        nextState <= Idle;
                    end if;

                when WaitingForMoney =>
                    if Input1RON = '1' then
                        if (accumulatedSum < 15) then
                            accumulatedSum <= accumulatedSum + 1;
                        else
                            MaxMoneyReached <= '1';
                        end if;
                    elsif Input5RON = '1' then
                        if (accumulatedSum < 10) then
                            accumulatedSum <= accumulatedSum + 5;
                        else
                            MaxMoneyReached <= '1';
                        end if;
                    elsif Input10RON = '1' then
                        if (accumulatedSum < 5) then
                            accumulatedSum <= accumulatedSum + 10;
                        else
                            MaxMoneyReached <= '1';
                        end if;
                    elsif RequestProduct1 = '1' then
                        nextState <= DispensingProduct1;
	                elsif RequestProduct2 = '1' then
	                    nextState <= DispensingProduct2;
                    elsif RequestChange = '1' then
                        -- Verificam aplicarea comisionului
                        if accumulatedSum >= 10 then
                            if not productPurchased then
                                accumulatedSum <= accumulatedSum - 1;
                            end if;
                        end if;
                        nextState <= DispensingChange;
                    else
                        nextState <= WaitingForMoney;
                    end if;

                when DispensingProduct1 =>
                    if accumulatedSum >= productPrice1 then
                        accumulatedSum <= accumulatedSum - productPrice1;
                        DispenseProduct1 <= '1';
                        -- Marcam faptul ca produsul a fost cumparat cel putin o data
                        productPurchased <= true; 
                    end if;
                    nextState <= WaitingForMoney;

                when DispensingProduct2 =>
                    if accumulatedSum >= productPrice2 then
                        accumulatedSum <= accumulatedSum - productPrice2;
                        DispenseProduct2 <= '1';
                        productPurchased <= true; 
                    end if;
                    nextState <= WaitingForMoney;

                when DispensingChange =>
                    if accumulatedSum >= 5 then
                        Give5RONChange <= '1';
                        accumulatedSum <= accumulatedSum - 5;
                    else
                        Give5RONChange <= '0';
                    end if;

                    if accumulatedSum > 0 and accumulatedSum < 5 then
                        Give1RONChange <= '1';
                        accumulatedSum <= accumulatedSum - 1;
                    else
                        Give1RONChange <= '0';
                    end if;
                    
                    --automatul ramane in starea "WaitingForMoney" pana cand a eliberat tot restul
                    if (accumulatedSum = 0) then
                        nextState <= Idle;
                    else
                        nextState <= DispensingChange;
                    end if;

                when others =>
                    nextState <= Idle;
            end case;
            
            end if;
        end if;
    end process;


end Behavioral;