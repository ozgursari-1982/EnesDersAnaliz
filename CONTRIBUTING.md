# Katkıda Bulunma Rehberi (Contributing Guide)

Almanca Cümle Kurucu projesine katkıda bulunmayı düşündüğünüz için teşekkür ederiz! 🎉

## 🌟 Nasıl Katkıda Bulunabilirsiniz?

### 1. Hata Bildirimi (Bug Report)

Bir hata buldunuz mu?

1. [Issues](https://github.com/ozgursari-1982/EnesDersAnaliz/issues) sayfasını kontrol edin
2. Eğer benzer bir issue yoksa, yeni bir issue açın
3. Hatayı detaylı açıklayın:
   - Hatanın ne olduğu
   - Nasıl tekrarlanabileceği (adım adım)
   - Beklenen davranış
   - Ekran görüntüleri (varsa)

### 2. Yeni Özellik Önerisi (Feature Request)

Yeni bir özellik mi istiyorsunuz?

1. [Issues](https://github.com/ozgursari-1982/EnesDersAnaliz/issues) sayfasından yeni bir issue açın
2. Özelliği detaylı açıklayın
3. Neden yararlı olacağını belirtin
4. Mümkünse örnek kullanım senaryoları ekleyin

### 3. Pull Request Gönderme

Kod katkısı yapmak ister misiniz?

#### Adımlar:

1. **Fork** edin repository'yi
2. **Clone** edin fork'unuzu:
   ```bash
   git clone https://github.com/KULLANICI_ADINIZ/EnesDersAnaliz.git
   ```

3. Yeni bir **branch** oluşturun:
   ```bash
   git checkout -b feature/yeni-ozellik
   ```

4. Değişikliklerinizi yapın

5. **Test** edin:
   ```bash
   flutter test
   flutter analyze
   ```

6. **Commit** edin (anlamlı commit mesajları):
   ```bash
   git commit -m "feat: Yeni özellik eklendi"
   ```

7. **Push** edin:
   ```bash
   git push origin feature/yeni-ozellik
   ```

8. **Pull Request** açın

## 📋 Kod Standartları

### Dart/Flutter Standartları

- **Dart Analysis**: `flutter analyze` hatasız geçmeli
- **Formatting**: `dart format .` kullanın
- **Linting**: `analysis_options.yaml` kurallarına uyun

### Commit Mesajları

Commit mesajlarınızı [Conventional Commits](https://www.conventionalcommits.org/) formatında yazın:

- `feat:` - Yeni özellik
- `fix:` - Hata düzeltmesi
- `docs:` - Dokümantasyon değişikliği
- `style:` - Kod formatı (kod davranışı değişmez)
- `refactor:` - Refactoring
- `test:` - Test ekleme/düzenleme
- `chore:` - Bakım işleri

**Örnek:**
```
feat: Yeni fiil çekimi eklendi
fix: API timeout hatası düzeltildi
docs: README güncellendi
```

### Kod Yapısı

```
lib/
  ├── models/          # Veri modelleri
  ├── services/        # API servisleri
  ├── screens/         # Ekranlar
  ├── widgets/         # Yeniden kullanılabilir widget'lar
  ├── utils/           # Yardımcı fonksiyonlar
  ├── constants/       # Sabitler
  └── providers/       # State management (Riverpod)
```

### Yorum Standartları

- Türkçe yorumlar tercih edilir
- Karmaşık kod bloklarını açıklayın
- Dokümantasyon yorumları (`///`) için Türkçe kullanın

**Örnek:**
```dart
/// Almanca cümle analizi yapar
/// [sentence] - Analiz edilecek cümle
/// Döndürür: Analiz sonucu
Future<String> analyzeSentence(String sentence) async {
  // API'ye istek gönder
  final response = await api.analyze(sentence);
  return response;
}
```

## 🧪 Test Yazma

- Yeni özellikler için test yazın
- Mevcut testlerin geçtiğinden emin olun
- Test coverage'ı artırmaya çalışın

**Test çalıştırma:**
```bash
flutter test
```

## 🔒 Güvenlik

- API anahtarlarını asla commit etmeyin
- `.env` dosyasını kullanın
- Hassas bilgileri paylaşmayın

## 📝 Dokümantasyon

- Yeni özellikler için README'yi güncelleyin
- Kod içi yorumları ekleyin/güncelleyin
- Gerekirse yeni dokümantasyon dosyaları oluşturun

## ❓ Sorular?

Herhangi bir sorunuz varsa:

1. [Issues](https://github.com/ozgursari-1982/EnesDersAnaliz/issues) sayfasında sorun
2. [Discussions](https://github.com/ozgursari-1982/EnesDersAnaliz/discussions) başlatın (varsa)

## 🙏 Teşekkürler!

Projeye katkıda bulunduğunuz için teşekkür ederiz! Her katkı, projeyi daha iyi hale getirir. 💙

---

**Not:** Bu proje eğitim amaçlıdır ve açık kaynak topluluk standartlarını takip eder.
