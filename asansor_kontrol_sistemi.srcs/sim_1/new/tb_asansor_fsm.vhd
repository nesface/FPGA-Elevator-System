library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_asansor_fsm is
end entity;

architecture Behavioral of tb_asansor_fsm is

  signal clk          : std_logic := '0';
  signal reset        : std_logic := '0';

  signal kat_cagri    : std_logic_vector(3 downto 0) := (others => '0');
  signal kabin_istek  : std_logic_vector(3 downto 0) := (others => '0');

  signal kapi_kapali  : std_logic := '1';
  signal asiri_yuk    : std_logic := '0';
  signal acil_durdur  : std_logic := '0';

  signal motor_yukari : std_logic;
  signal motor_asagi  : std_logic;
  signal kapi_ac      : std_logic;
  signal kapi_kapat   : std_logic;
  signal mevcut_kat   : std_logic_vector(1 downto 0);

begin

  DUT: entity work.asansor_fsm
    port map (
      clk           => clk,
      reset         => reset,
      kat_cagri     => kat_cagri,
      kabin_istek   => kabin_istek,
      kapi_kapali   => kapi_kapali,
      asiri_yuk     => asiri_yuk,
      acil_durdur   => acil_durdur,
      motor_yukari  => motor_yukari,
      motor_asagi   => motor_asagi,
      kapi_ac       => kapi_ac,
      kapi_kapat    => kapi_kapat,
      mevcut_kat    => mevcut_kat
    );

  clk <= not clk after 10 ns;

  process
  begin
  
    reset <= '1';
    wait for 40 ns;
    reset <= '0';

    wait for 40 ns;
    kat_cagri <= "1000"; 
    wait for 200 ns;
    kat_cagri <= "0000";

    wait for 200 ns;
    kapi_kapali <= '0'; 
    wait for 100 ns;
    kapi_kapali <= '1';

    wait for 200 ns;
    asiri_yuk <= '1';
    wait for 100 ns;
    asiri_yuk <= '0';

    wait for 200 ns;
    acil_durdur <= '1';
    wait for 100 ns;
    acil_durdur <= '0';

    wait;
  end process;

end architecture;
