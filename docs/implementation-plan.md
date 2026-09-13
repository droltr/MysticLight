# İnceleme ve uygulama planı

## Bulgular

Sistemin DMI değeri OpenRGB'nin beklediği metinle birebir eşleşir:
`MSI MAG B850 TOMAHAWK MAX WIFI (MS-7E62)`. USB HID denetleyicisi
`0DB0:0076` kimliğini ve `MYSTIC LIGHT` ürün adını bildirir.

Güncel OpenRGB `master`, ortak `0DB0:0076` algılayıcısını kullanır. İlk feature
report denemesi eski 112/162/185-byte ailelerinden biriyle eşleşmezse okuma
etkinleştirme isteği gönderir ve 761-byte denetleyicisine geçer. Kartın DMI adı
761-byte kart yapılandırma tablosunda zone-based direct mode ile kayıtlıdır.

Kart desteği upstream commit `93830c12eee0e678ebf449b9e4ae80b379db0646`
ile eklenmiştir. Yerel olarak derlenen OpenRGB 1.0 kartı başarıyla kaydetmiş ve
dört bölge bildirmiştir. Bu nedenle eski sürüme yeni PID eklemek veya
`ENABLE_UNTESTED_MYSTIC_LIGHT` seçeneğini açmak gerekli ve doğru değildir.

## Uygulama aşamaları

1. Güncel upstream `master` sürümünü kullan ve sabitlenmiş commit bilgisini test
   kayıtlarında belirt.
2. Resmi Fedora bağımlılıklarıyla izole Toolbox derlemesini tekrarla.
3. `--noautoconnect --list-detailed --very-verbose` ile doğrudan algılamayı
   doğrula; yerel SDK sunucusuna bağlanan test sonuçlarını kabul etme.
4. Arayüzden önce tek bir JARGB bölgesinde düşük parlaklıkta sabit renk dene;
   fiziksel sonucu kullanıcı gözlemiyle doğrula.
5. Renk yazımı çalışmıyorsa mevcut algılama desteğini çoğaltma. MSI Center veya
   SignalRGB USB trafiğini yakala, 761-byte paketleri karşılaştır ve yalnızca
   kanıtlanan board-specific zone/packet farkını uygula.
6. Değişiklik gerekirse `fix/msi-7e62-761-output` gibi bir konu dalı aç, upstream
   stilini koru, tek amaçlı commit oluştur ve önce Draft GitLab MR gönder.

## Kabul ölçütleri

- Kart her temiz başlangıçta MSI 761-byte controller olarak kaydolur.
- JAF ve üç JARGB bölgesi listelenir.
- Seçilen tek bölgede sabit kırmızı, yeşil ve mavi fiziksel olarak doğrulanır.
- OpenRGB kapatılıp açıldığında denetleyici yeniden algılanır.
- Askıya alma/uyanma sonrasında algılama ve renk yazımı yeniden çalışır.
- Test sırasında firmware sürümü, USB seri numarası ve verbose log MR kaydına
  eklenir; kişisel olmayan gereksiz sistem bilgileri paylaşılmaz.

## Riskler

OpenRGB'nin MSI sürücüsünde geçmişte firmware bozma riski yaşanmıştır. Bu nedenle
yalnızca güncel upstream akışı kullanılmalı; I2C Tools ile deneysel yazma,
`ENABLE_UNTESTED_MYSTIC_LIGHT` veya doğrulanmamış ham HID paketleri denenmemelidir.
