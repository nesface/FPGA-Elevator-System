library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package asansor_paket is
    constant KAT_SAYISI : integer := 4;

    type t_durum is (
        BEKLEME,
        YUKARI_GIDIYOR,
        ASAGI_GIDIYOR,
        KAPI_ACILIYOR,
        KAPI_ACIK,
        KAPI_KAPANIYOR,
        ACIL_DURUM
    );

    constant SIMULASYON_MODU : boolean := true;

    constant KAT_GECIS_SURESI : integer :=
        20 when SIMULASYON_MODU else 200_000_000;

    constant KAPI_ACMA_SURESI : integer :=
        10 when SIMULASYON_MODU else 100_000_000;

    constant KAPI_ACIK_KALMA_SURESI : integer :=
        30 when SIMULASYON_MODU else 300_000_000;

    constant KAPI_KAPAMA_SURESI : integer :=
        10 when SIMULASYON_MODU else 100_000_000;
end package asansor_paket;

package body asansor_paket is
end package body asansor_paket;
