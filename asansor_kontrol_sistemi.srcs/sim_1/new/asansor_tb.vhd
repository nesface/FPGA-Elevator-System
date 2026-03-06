library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.asansor_paket.all;

entity asansor_tb is
end entity;

architecture tb of asansor_tb is

    -- UUT (Unit Under Test)
    component asansor_kontrol is
        port(
            clk          : in  std_logic;
            reset        : in  std_logic;

            cagri_dis    : in  std_logic_vector(KAT_SAYISI-1 downto 0);
            cagri_ic     : in  std_logic_vector(KAT_SAYISI-1 downto 0);

            kapi_sensoru : in  std_logic;
            asiri_yuk    : in  std_logic;
            acil_stop    : in  std_logic;

            motor_yon    : out std_logic_vector(1 downto 0);
            kapi_durum   : out std_logic_vector(1 downto 0);
            mevcut_kat   : out std_logic_vector(1 downto 0);
            durum_dbg    : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Giriş sinyalleri
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';

    signal cagri_dis    : std_logic_vector(KAT_SAYISI-1 downto 0) := (others => '0');
    signal cagri_ic     : std_logic_vector(KAT_SAYISI-1 downto 0) := (others => '0');

    signal kapi_sensoru : std_logic := '0';
    signal asiri_yuk    : std_logic := '0';
    signal acil_stop    : std_logic := '0';

    -- Çıkış sinyalleri
    signal motor_yon    : std_logic_vector(1 downto 0);
    signal kapi_durum   : std_logic_vector(1 downto 0);
    signal mevcut_kat   : std_logic_vector(1 downto 0);
    signal durum_dbg    : std_logic_vector(3 downto 0);

    -- Clock
    constant clk_period : time := 10 ns;

    -- Buton bas-bırak procedure (daha uzun tuttuk ki waveform'da görünür olsun)
    procedure bas_dis(signal v: out std_logic_vector; idx: integer; sure: time) is
        variable tmp : std_logic_vector(KAT_SAYISI-1 downto 0);
    begin
        tmp := (others => '0');
        tmp(idx) := '1';
        v <= tmp;
        wait for sure;
        v <= (others => '0');
    end procedure;

    procedure bas_ic(signal v: out std_logic_vector; idx: integer; sure: time) is
        variable tmp : std_logic_vector(KAT_SAYISI-1 downto 0);
    begin
        tmp := (others => '0');
        tmp(idx) := '1';
        v <= tmp;
        wait for sure;
        v <= (others => '0');
    end procedure;

begin

    -- UUT bağla
    uut: asansor_kontrol
        port map(
            clk => clk,
            reset => reset,
            cagri_dis => cagri_dis,
            cagri_ic => cagri_ic,
            kapi_sensoru => kapi_sensoru,
            asiri_yuk => asiri_yuk,
            acil_stop => acil_stop,
            motor_yon => motor_yon,
            kapi_durum => kapi_durum,
            mevcut_kat => mevcut_kat,
            durum_dbg => durum_dbg
        );

    -- Clock üretimi
    clk_process: process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- Test senaryoları
    stim: process
    begin
        ------------------------------------------------------------
        -- RESET
        ------------------------------------------------------------
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 2 us;

        ------------------------------------------------------------
        -- SENARYO 1: Kabin içinden 3. kata istek (hareket + kapı)
        ------------------------------------------------------------
        bas_ic(cagri_ic, 3, 5 us);
        wait for 80 us;  -- hareket + kapı döngüsü için bekle

        ------------------------------------------------------------
        -- SENARYO 2: FCFS testi
        -- Önce 1. kat çağrısı (dış), sonra 2. kat çağrısı (dış).
        ------------------------------------------------------------
        bas_dis(cagri_dis, 1, 5 us);
        wait for 10 us;
        bas_dis(cagri_dis, 2, 5 us);
        wait for 120 us;

        ------------------------------------------------------------
        -- SENARYO 3: Kapı engel sensörü testi
        -- Kapı kapanırken engel ver -> tekrar açmalı
        ------------------------------------------------------------
        bas_dis(cagri_dis, 0, 5 us);
        wait for 30 us;        -- kapı kapanma aşamasına yaklaşsın diye
        kapi_sensoru <= '1';   -- engel
        wait for 15 us;
        kapi_sensoru <= '0';   -- engel kalktı
        wait for 80 us;

        ------------------------------------------------------------
        -- SENARYO 4: Aşırı yük testi
        -- Kapı açıkken asiri_yuk=1 -> kapı kapanmamalı
        ------------------------------------------------------------
        bas_ic(cagri_ic, 2, 5 us);
        wait for 40 us;        -- kapı açıldı varsayımı
        asiri_yuk <= '1';
        wait for 40 us;        -- bu sürede kapı kapanmamalı
        asiri_yuk <= '0';
        wait for 80 us;

        ------------------------------------------------------------
        -- SENARYO 5: Acil stop testi
        -- Acil stop aktif olunca motor durmalı, kapı açık kalmalı
        ------------------------------------------------------------
        bas_dis(cagri_dis, 3, 5 us);
        wait for 20 us;        -- hareket başladı varsayımı

        acil_stop <= '1';
        wait for 20 us;
        acil_stop <= '0';

        wait for 80 us;

        wait;
    end process;

end architecture;
