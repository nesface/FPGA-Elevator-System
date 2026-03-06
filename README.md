# FPGA-Elevator-System
Bu proje, Karadeniz Teknik Üniversitesi Bilgisayar Mühendisliği bölümü kapsamında VHDL dili kullanılarak geliştirilmiş, 4 katlı bir bina için FPGA tabanlı bir asansör kontrol sistemidir.

Temel Özellikler
Algoritma: Çağrıları geliş sırasına göre işleyen FCFS (First-Come, First-Served) mantığı kullanılmıştır.
FSM Mimarisi: Sistem; Bekleme (IDLE), Yukarı, Aşağı, Kapı Açılıyor/Kapanıyor ve Acil Durum dahil 7 temel durumdan oluşur.
Güvenlik: Kapı sensörü engeli, aşırı yük (overload) kontrolü ve acil durdurma (emergency stop) protokolleri donanımsal olarak kilitlenmiştir.
Teknik Detaylar
Dil: VHDL 
Araçlar: Vivado 
Donanım Hedefi: FPGA tabanlı sistemler 
