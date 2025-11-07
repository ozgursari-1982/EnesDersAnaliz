# Almanca Cümle Kurucu (Deutsch Lernen mit Mari)

Gemini AI destekli Almanca cümle kurucu Flutter uygulaması.

## 🔧 503 API Hatası - ÇÖZÜLMÜŞTİR ✅

### Yapılan Düzeltmeler:

1. ✅ **Model adı güncellendi:** `gemini-pro-latest` → `gemini-1.5-flash`
2. ✅ **Timeout eklendi:** 30 saniye timeout süresi
3. ✅ **Gelişmiş hata yönetimi:** 503, 429, 401, 400 hataları için özel mesajlar
4. ✅ **Güvenlik:** API anahtarı placeholder ile değiştirildi
5. ✅ **Resmi paket eklendi:** `google_generative_ai` paketi `pubspec.yaml`'a eklendi

## 🚀 Kurulum

### 1. Bağımlılıkları Yükleyin

```bash
flutter pub get
```

### 2. API Anahtarı Alın

1. [Google AI Studio](https://makersuite.google.com/app/apikey) adresine gidin
2. "Create API Key" butonuna tıklayın
3. API anahtarınızı kopyalayın

### 3. API Anahtarını Ekleyin

`lib/main.dart` dosyasında **475. satırı** bulun:

```dart
static const String _geminiApiKey = 'BURAYA_API_ANAHTARINIZI_GIRIN';
```

Kendi API anahtarınızla değiştirin:

```dart
static const String _geminiApiKey = 'AIza...'; // Sizin API anahtarınız
```

### 4. Uygulamayı Çalıştırın

```bash
flutter run
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
  └── main.dart          # Ana uygulama dosyası
pubspec.yaml             # Bağımlılıklar
API_KURULUM.md          # Detaylı kurulum rehberi
```

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Pull request göndermekten çekinmeyin.

## 📄 Lisans

Bu proje eğitim amaçlıdır.

---

**Yazan:** Mari AI Asistanı 🤖  
**Son Güncelleme:** Kasım 2025
