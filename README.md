# MSI MAG B850 Tomahawk Max WiFi için OpenRGB

Bu çalışma alanı, MSI MAG B850 TOMAHAWK MAX WIFI (MS-7E62 v2.0)
anakartındaki Mystic Light denetleyicisini güncel OpenRGB ile derlemek ve
doğrulamak için hazırlanmıştır.

## Sonuç

- Anakart: `MSI MAG B850 TOMAHAWK MAX WIFI (MS-7E62)`
- Mystic Light USB aygıtı: `0DB0:0076`
- HID yolu: `/dev/hidraw12` (yeniden başlatmalarda numara değişebilir)
- Protokol: OpenRGB `761-byte` MSI motherboard controller
- Destek: OpenRGB upstream `master` içinde mevcut
- Doğrulanan bölgeler: `JAF`, `JARGB 1`, `JARGB 2`, `JARGB 3`

Kaynak kod `openrgb/` altında upstream Git deposu olarak tutulur. OpenRGB
donanıma doğrudan komut gönderdiği için renk yazma testlerinden önce bağlantıların
ve seçilen cihazın doğrulanması gerekir.

## Derleme

Mevcut `fedora-build` Toolbox konteynerinde:

```bash
./scripts/build-openrgb.sh
```

Oluşan ikili: `openrgb/build/openrgb`

## Güvenli tanılama

```bash
./scripts/diagnose-msi.sh
```

Komut, çalışan yerel OpenRGB sunucusuna bağlanmamak için `--noautoconnect`
kullanır ve ayrı bir geçici yapılandırma diziniyle ayrıntılı cihaz listesini
yazar. Cihaz algılama sırasında upstream MSI HID el sıkışması yapılır; rastgele
SMBus/I2C yazmaları yapılmaz.

## Git iş akışı

OpenRGB katkıları kendi GitLab fork'undaki konu dalından gönderilmelidir; upstream
`master` doğrudan değiştirilmemeli ve güncellemeler merge yerine rebase ile
alınmalıdır. Bu kartın temel desteği zaten upstream'e birleştiği için şu anda
gönderilecek yeni bir kaynak kod patch'i yoktur. İşlevsel bir LED yazma sorunu
gözlenirse değişiklik yalnızca MSI 761-byte denetleyicisi kapsamında tutulmalı,
donanım logları ve test sonucu ile taslak merge request açılmalıdır.

Detaylı bulgular ve sonraki adımlar için [docs/implementation-plan.md](docs/implementation-plan.md)
dosyasına bakın.
