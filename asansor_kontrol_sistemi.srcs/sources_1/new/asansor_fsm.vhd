library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity asansor_fsm is
  generic(
    KAT_TICK       : natural := 30; 
    KAPI_TICK      : natural := 15;
    KAPI_ACIK_TICK : natural := 50; 
    KUYRUK_BOYUT   : natural := 8  
  );
  port(
    clk   : in  std_logic;
    reset : in  std_logic;


    kat_cagri  : in  std_logic_vector(3 downto 0);
    kabin_istek: in  std_logic_vector(3 downto 0);

    
    kapi_kapali : in std_logic;  
    asiri_yuk   : in std_logic;  
    acil_durdur : in std_logic;  

 
    motor_yukari : out std_logic;
    motor_asagi  : out std_logic;
    kapi_ac      : out std_logic;
    kapi_kapat   : out std_logic;
    mevcut_kat   : out std_logic_vector(1 downto 0)
  );
end entity;

architecture Behavioral of asansor_fsm is

  type durum_tipi is (
    BEKLE,
    KARAR,
    YUKARI_HAREKET,
    ASAGI_HAREKET,
    KAPI_ACILIYOR,
    KAPI_ACIK,
    KAPI_KAPANIYOR,
    ACIL_DURUM
  );

  signal durum, sonraki_durum : durum_tipi;

  signal kat_reg : unsigned(1 downto 0) := (others => '0');

  signal sayac : natural := 0;

  signal istekler : std_logic_vector(3 downto 0);

  type kuyruk_dizi is array(0 to KUYRUK_BOYUT-1) of unsigned(1 downto 0);
  signal kuyruk : kuyruk_dizi;

  signal head  : natural range 0 to KUYRUK_BOYUT-1 := 0;
  signal tail  : natural range 0 to KUYRUK_BOYUT-1 := 0;
  signal adet  : natural range 0 to KUYRUK_BOYUT   := 0;

  signal hedef_kat   : unsigned(1 downto 0) := (others => '0');
  signal hedef_varmi : std_logic := '0';

  function bit2kat(i : integer) return unsigned is
  begin
    return to_unsigned(i, 2);
  end function;

begin
  istekler  <= kat_cagri or kabin_istek;
  mevcut_kat <= std_logic_vector(kat_reg);


  process(clk, reset)
  begin
    if reset = '1' then
      durum <= BEKLE;
      kat_reg <= (others => '0');
      sayac <= 0;

      head <= 0; tail <= 0; adet <= 0;
      hedef_varmi <= '0';
      hedef_kat <= (others => '0');

    elsif rising_edge(clk) then

      if acil_durdur = '1' then
        durum <= ACIL_DURUM;
        sayac <= 0;
        hedef_varmi <= '0';

      else
        durum <= sonraki_durum;

        
        if durum = sonraki_durum then
          sayac <= sayac + 1;
        else
          sayac <= 0;
        end if;

        if durum = YUKARI_HAREKET then
          if sayac >= KAT_TICK then
            if kat_reg < "11" then
              kat_reg <= kat_reg + 1;
            end if;
          end if;

        elsif durum = ASAGI_HAREKET then
          if sayac >= KAT_TICK then
            if kat_reg > "00" then
              kat_reg <= kat_reg - 1;
            end if;
          end if;
        end if;

      
        if adet < KUYRUK_BOYUT then
          if istekler(0) = '1' then
            kuyruk(tail) <= bit2kat(0);
            tail <= (tail + 1) mod KUYRUK_BOYUT;
            adet <= adet + 1;

          elsif istekler(1) = '1' then
            kuyruk(tail) <= bit2kat(1);
            tail <= (tail + 1) mod KUYRUK_BOYUT;
            adet <= adet + 1;

          elsif istekler(2) = '1' then
            kuyruk(tail) <= bit2kat(2);
            tail <= (tail + 1) mod KUYRUK_BOYUT;
            adet <= adet + 1;

          elsif istekler(3) = '1' then
            kuyruk(tail) <= bit2kat(3);
            tail <= (tail + 1) mod KUYRUK_BOYUT;
            adet <= adet + 1;
          end if;
        end if;

        if hedef_varmi = '0' and adet > 0 then
          hedef_kat <= kuyruk(head);
          head <= (head + 1) mod KUYRUK_BOYUT;
          adet <= adet - 1;
          hedef_varmi <= '1';
        end if;

        if durum = KAPI_ACIK and sonraki_durum = KARAR then
          hedef_varmi <= '0';
        end if;

      end if;
    end if;
  end process;

  process(durum, hedef_varmi, hedef_kat, kat_reg, sayac, kapi_kapali, asiri_yuk)
  begin

    motor_yukari <= '0';
    motor_asagi  <= '0';
    kapi_ac      <= '0';
    kapi_kapat   <= '0';

    sonraki_durum <= durum;

    case durum is

      when BEKLE =>
        if hedef_varmi = '1' then
          sonraki_durum <= KARAR;
        else
          sonraki_durum <= BEKLE;
        end if;

      when KARAR =>
        if hedef_varmi = '0' then
          sonraki_durum <= BEKLE;
        else

          if kapi_kapali = '0' then
            sonraki_durum <= KAPI_ACIK;
          else
            if kat_reg < hedef_kat then
              sonraki_durum <= YUKARI_HAREKET;
            elsif kat_reg > hedef_kat then
              sonraki_durum <= ASAGI_HAREKET;
            else

              sonraki_durum <= KAPI_ACILIYOR;
            end if;
          end if;
        end if;

      when YUKARI_HAREKET =>
        if kapi_kapali = '0' then
          sonraki_durum <= KAPI_ACIK;
        else
          motor_yukari <= '1';
          if kat_reg = hedef_kat then
            sonraki_durum <= KAPI_ACILIYOR;
          end if;
        end if;

      when ASAGI_HAREKET =>
        if kapi_kapali = '0' then
          sonraki_durum <= KAPI_ACIK;
        else
          motor_asagi <= '1';
          if kat_reg = hedef_kat then
            sonraki_durum <= KAPI_ACILIYOR;
          end if;
        end if;

      when KAPI_ACILIYOR =>
        kapi_ac <= '1';
        if sayac >= KAPI_TICK then
          sonraki_durum <= KAPI_ACIK;
        end if;

      when KAPI_ACIK =>
        if sayac >= KAPI_ACIK_TICK then
          sonraki_durum <= KAPI_KAPANIYOR;
        end if;

      when KAPI_KAPANIYOR =>
        if asiri_yuk = '1' then
          -- aşırı yük varsa kapanma yok
          sonraki_durum <= KAPI_ACIK;
        else
          kapi_kapat <= '1';
          if sayac >= KAPI_TICK then
            sonraki_durum <= KARAR;
          end if;
        end if;

      when ACIL_DURUM =>
  
        motor_yukari <= '0';
        motor_asagi  <= '0';
        kapi_ac      <= '1';
        kapi_kapat   <= '0';
        sonraki_durum <= ACIL_DURUM;

    end case;
  end process;

end architecture;
