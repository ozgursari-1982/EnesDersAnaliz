# Almanca Cümle Kurucu (Deutsch Lernen mit Mari)

Gemini AI destekli Almanca cümle kurucu Flutter uygulaması.

## ✨ Yeni Özellikler

### 🔐 Güvenlik İyileştirmeleri
- ✅ API anahtarı environment variable'da saklanıyor
- ✅ `.env` dosyası ile güvenli yapılandırma
- ✅ Hardcoded API anahtarları kaldırıldı

### 🏗️ Modüler Mimari
- ✅ Temiz klasör yapısı (models, services, screens, widgets, utils, constants)
- ✅ Ayrı model dosyaları
- ✅ Servislerin ayrıştırılması
- ✅ Yeniden kullanılabilir bileşenler

### 🧪 Test Altyapısı
- ✅ Model testleri
- ✅ Servis testleri
- ✅ Sabitler testleri
- ✅ Unit test kapsamı

### 📦 State Management
- ✅ Flutter Riverpod entegrasyonu
- ✅ Provider yapısı

### 📚 Dokümantasyon
- ✅ MIT License
- ✅ CONTRIBUTING.md
- ✅ Güncellenmiş README
- ✅ Türkçe kod yorumları

## 🚀 Kurulum

### 1. Bağımlılıkları Yükleyin

```bash
flutter pub get
```

### 2. API Anahtarı Alın

1. [Google AI Studio](https://makersuite.google.com/app/apikey) adresine gidin
2. "Create API Key" butonuna tıklayın
3. API anahtarınızı kopyalayın

### 3. Ortam Değişkenlerini Ayarlayın

`.env.example` dosyasını `.env` olarak kopyalayın:

```bash
cp .env.example .env
```

`.env` dosyasını düzenleyin ve API anahtarınızı ekleyin:

```env
GEMINI_API_KEY=AIza...
```

**⚠️ Önemli:** `.env` dosyası `.gitignore`'da olduğu için Git'e eklenmeyecektir. API anahtarınızı asla paylaşmayın!

### 4. Uygulamayı Çalıştırın

```bash
flutter run
```

### 5. Testleri Çalıştırın

```bash
flutter test
```

## 📱 Özellikler

- ✨ Gemini AI ile gerçek zamanlı dilbilgisi kontrolü
- 🎯 Almanca cümle yapısı (V2, Nebensatz) kontrolü
- 📚 Geniş kelime hazinesi (fiiller, isimler, zarflar, bağlaçlar)
- 🕐 4 farklı zaman desteği (Present, Perfekt, Präteritum, Future)
- 💡 Yapay zeka destekli kelime önerileri
- 🎨 Modern ve kullanıcı dostu arayüz

## 🐛 Yaygın Hatalar ve Çözümleri

### 503 Service Unavailable
**Neden:** Gemini servisi geçici olarak meşgul veya API anahtarı sorunu  
**Çözüm:** 
- 2-5 dakika bekleyin
- API anahtarınızı kontrol edin
- İnternet bağlantınızı kontrol edin

### 429 Too Many Requests
**Neden:** API kota limiti aşıldı  
**Çözüm:** 
- Birkaç saat bekleyin
- Yeni bir API anahtarı oluşturun

### 401/403 Unauthorized
**Neden:** Geçersiz API anahtarı  
**Çözüm:** 
- Yeni bir API anahtarı oluşturun
- API anahtarının doğru kopyalandığını kontrol edin

## 🔐 Güvenlik Uyarısı

⚠️ **API anahtarınızı GitHub'a yüklemeyin!**

Daha güvenli bir yöntem için `API_KURULUM.md` dosyasına bakın.

## 📖 Daha Fazla Bilgi

- [Detaylı API Kurulum Rehberi](./API_KURULUM.md)
- [Gemini API Dokümantasyonu](https://ai.google.dev/docs)
- [Flutter Dokümantasyonu](https://flutter.dev/docs)

## 🎓 Kullanım

1. **Zeitform (Zaman)** seçin
2. **Subjekt (Özne)** seçin (Ich, Du, Er, Sie, vb.)
3. **Verb (Fiil)** seçin
4. İsteğe bağlı olarak zarflar, nesneler ve bağlaçlar ekleyin
5. Mari'nin geri bildirimini okuyun ve cümlenizi geliştirin!

## 🏗️ Proje Yapısı

```
lib/
  ├── models/          # Veri modelleri
  │   └── word.dart    # Kelime modeli
  ├── services/        # API servisleri
  │   └── gemini_service.dart  # Gemini AI servisi
  ├── screens/         # Ekranlar
  │   └── (gelecekte eklenecek)
  ├── widgets/         # Yeniden kullanılabilir bileşenler
  │   └── (gelecekte eklenecek)
  ├── utils/           # Yardımcı fonksiyonlar
  │   └── (gelecekte eklenecek)
  ├── constants/       # Uygulama sabitleri
  │   └── german_words.dart  # Almanca kelime listeleri
  ├── providers/       # State management (Riverpod)
  │   └── (gelecekte eklenecek)
  └── main.dart        # Ana uygulama dosyası

test/
  ├── models/          # Model testleri
  │   └── word_test.dart
  ├── services/        # Servis testleri
  │   └── gemini_service_test.dart
  └── constants/       # Sabitler testleri
      └── german_words_test.dart

.env                   # Environment variables (GIT'E EKLENMEMELİ)
.env.example           # Environment variables şablonu
pubspec.yaml           # Bağımlılıklar
LICENSE                # MIT License
CONTRIBUTING.md        # Katkı rehberi
```

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Pull request göndermekten çekinmeyin.

## 📄 Lisans

Bu proje eğitim amaçlıdır.

---

**Yazan:** Mari AI Asistanı 🤖  
**Son Güncelleme:** Kasım 2025
