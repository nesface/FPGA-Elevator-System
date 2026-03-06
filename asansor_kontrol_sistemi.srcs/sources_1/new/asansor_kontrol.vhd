library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.asansor_paket.all;

entity asansor_kontrol is
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
end entity;

architecture rtl of asansor_kontrol is

    signal durum : t_durum := BEKLEME;

    signal kat_reg   : integer range 0 to KAT_SAYISI-1 := 0;
    signal hedef_kat : integer range 0 to KAT_SAYISI-1 := 0;

    signal sayac : integer := 0;

    type t_kuyruk is array(0 to KAT_SAYISI-1) of integer range -1 to KAT_SAYISI-1;
    signal kuyruk : t_kuyruk := (others => -1);
    signal kuyruk_doluluk : integer range 0 to KAT_SAYISI := 0;

    signal istekler : std_logic_vector(KAT_SAYISI-1 downto 0);

    -- iç çıkışlar (OUT okunamaz, o yüzden iç sinyal)
    signal kapi_durum_i : std_logic_vector(1 downto 0) := "00";
    signal motor_yon_i  : std_logic_vector(1 downto 0) := "00";

begin
    istekler   <= cagri_dis or cagri_ic;

    mevcut_kat <= std_logic_vector(to_unsigned(kat_reg, 2));

    -- dışarı bağla
    kapi_durum <= kapi_durum_i;
    motor_yon  <= motor_yon_i;

    process(clk, reset)
        variable zaten_var : boolean;
    begin
        if reset = '1' then
            durum <= BEKLEME;
            kat_reg <= 0;
            hedef_kat <= 0;
            sayac <= 0;
            kuyruk <= (others => -1);
            kuyruk_doluluk <= 0;

            motor_yon_i  <= "00";
            kapi_durum_i <= "00";

        elsif rising_edge(clk) then

            if acil_stop = '1' then
                durum <= ACIL_DURUM;
                motor_yon_i  <= "00";
                kapi_durum_i <= "10";
                sayac <= 0;

            else
                -- istekleri kuyruga ekle
                for i in 0 to KAT_SAYISI-1 loop
                    if istekler(i) = '1' then
                        zaten_var := false;
                        for k in 0 to KAT_SAYISI-1 loop
                            if kuyruk(k) = i then
                                zaten_var := true;
                            end if;
                        end loop;

                        if (zaten_var = false) and (kuyruk_doluluk < KAT_SAYISI) then
                            kuyruk(kuyruk_doluluk) <= i;
                            kuyruk_doluluk <= kuyruk_doluluk + 1;
                        end if;
                    end if;
                end loop;

                case durum is

                    when BEKLEME =>
                        motor_yon_i  <= "00";
                        kapi_durum_i <= "00";
                        sayac <= 0;

                        if kuyruk(0) /= -1 then
                            hedef_kat <= kuyruk(0);

                            if kuyruk(0) > kat_reg then
                                durum <= YUKARI_GIDIYOR;
                            elsif kuyruk(0) < kat_reg then
                                durum <= ASAGI_GIDIYOR;
                            else
                                durum <= KAPI_ACILIYOR;
                            end if;
                        end if;

                    when YUKARI_GIDIYOR =>
                        -- kapı kapalı değilken motor çalışmasın
                        if kapi_durum_i = "00" then
                            motor_yon_i <= "01";
                        else
                            motor_yon_i <= "00";
                        end if;

                        if sayac < KAT_GECIS_SURESI then
                            sayac <= sayac + 1;
                        else
                            sayac <= 0;
                            kat_reg <= kat_reg + 1;

                            if (kat_reg + 1) = hedef_kat then
                                motor_yon_i <= "00";
                                durum <= KAPI_ACILIYOR;
                            end if;
                        end if;

                    when ASAGI_GIDIYOR =>
                        if kapi_durum_i = "00" then
                            motor_yon_i <= "10";
                        else
                            motor_yon_i <= "00";
                        end if;

                        if sayac < KAT_GECIS_SURESI then
                            sayac <= sayac + 1;
                        else
                            sayac <= 0;
                            kat_reg <= kat_reg - 1;

                            if (kat_reg - 1) = hedef_kat then
                                motor_yon_i <= "00";
                                durum <= KAPI_ACILIYOR;
                            end if;
                        end if;

                    when KAPI_ACILIYOR =>
                        motor_yon_i  <= "00";
                        kapi_durum_i <= "01";

                        if sayac < KAPI_ACMA_SURESI then
                            sayac <= sayac + 1;
                        else
                            sayac <= 0;
                            durum <= KAPI_ACIK;
                        end if;

                    when KAPI_ACIK =>
                        motor_yon_i  <= "00";
                        kapi_durum_i <= "10";

                        if asiri_yuk = '1' then
                            sayac <= 0;
                        else
                            if sayac < KAPI_ACIK_KALMA_SURESI then
                                sayac <= sayac + 1;
                            else
                                sayac <= 0;
                                durum <= KAPI_KAPANIYOR;
                            end if;
                        end if;

                    when KAPI_KAPANIYOR =>
                        motor_yon_i  <= "00";
                        kapi_durum_i <= "11";

                        if kapi_sensoru = '1' then
                            sayac <= 0;
                            durum <= KAPI_ACILIYOR;
                        elsif asiri_yuk = '1' then
                            sayac <= 0;
                            durum <= KAPI_ACIK;
                        else
                            if sayac < KAPI_KAPAMA_SURESI then
                                sayac <= sayac + 1;
                            else
                                sayac <= 0;
                                kapi_durum_i <= "00";

                                -- FCFS kaydır
                                for k in 0 to KAT_SAYISI-2 loop
                                    kuyruk(k) <= kuyruk(k+1);
                                end loop;
                                kuyruk(KAT_SAYISI-1) <= -1;

                                if kuyruk_doluluk > 0 then
                                    kuyruk_doluluk <= kuyruk_doluluk - 1;
                                end if;

                                durum <= BEKLEME;
                            end if;
                        end if;

                    when ACIL_DURUM =>
                        motor_yon_i  <= "00";
                        kapi_durum_i <= "10";
                        sayac <= 0;
                        durum <= BEKLEME;

                    when others =>
                        durum <= BEKLEME;

                end case;
            end if;
        end if;
    end process;

    with durum select
        durum_dbg <=
            "0000" when BEKLEME,
            "0001" when YUKARI_GIDIYOR,
            "0010" when ASAGI_GIDIYOR,
            "0011" when KAPI_ACILIYOR,
            "0100" when KAPI_ACIK,
            "0101" when KAPI_KAPANIYOR,
            "0110" when ACIL_DURUM,
            "1111" when others;

end architecture;
