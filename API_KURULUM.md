# Gemini API Kurulum Rehberi

## 503 Hatası Çözümü

Eğer "API hatası 503" alıyorsanız, aşağıdaki adımları izleyin:

### 1. Yeni API Anahtarı Alın

1. [Google AI Studio](https://makersuite.google.com/app/apikey) adresine gidin
2. Google hesabınızla giriş yapın
3. "Get API Key" veya "Create API Key" butonuna tıklayın
4. Yeni bir API anahtarı oluşturun

### 2. API Anahtarını Kodunuza Ekleyin

`lib/main.dart` dosyasında **474. satırdaki** API anahtarını güncelleyin:

```dart
static const String _geminiApiKey = 'BURAYA_YENİ_API_ANAHTARINIZI_YAPIŞTIRIN';
```

### 3. Model Adını Kontrol Edin

Kodda şu modeli kullanıyoruz:
- ✅ `gemini-1.5-flash` (Önerilen - hızlı ve güvenilir)

Alternatif modeller:
- `gemini-pro` (Daha eski ama stabil)
- `gemini-1.5-pro` (Daha gelişmiş ama daha yavaş)

### 4. API Kotanızı Kontrol Edin

1. [Google Cloud Console](https://console.cloud.google.com/apis/api/generativelanguage.googleapis.com/quotas) adresine gidin
2. Günlük istek limitinizi kontrol edin
3. Ücretsiz planda günde 60 istek yapabilirsiniz

### 5. Yaygın Hatalar ve Çözümleri

#### 503 Service Unavailable
- **Neden:** Gemini servisi geçici olarak kapalı veya meşgul
- **Çözüm:** 2-5 dakika bekleyin ve tekrar deneyin

#### 429 Too Many Requests
- **Neden:** API kota limitini aştınız
- **Çözüm:** Birkaç saat bekleyin veya yeni API anahtarı oluşturun

#### 401 Unauthorized / 403 Forbidden
- **Neden:** API anahtarı geçersiz veya yetkisiz
- **Çözüm:** Yeni bir API anahtarı oluşturun

#### 400 Bad Request
- **Neden:** Geçersiz istek formatı veya yanlış model adı
- **Çözüm:** Model adının `gemini-1.5-flash` olduğundan emin olun

### 6. Güvenlik İpucu

⚠️ **ÖNEMLİ:** API anahtarınızı asla GitHub'a yüklemeyin!

Daha güvenli bir yöntem:
1. Bir `api_key.dart` dosyası oluşturun
2. `.gitignore` dosyasına `api_key.dart` ekleyin
3. API anahtarınızı bu dosyada saklayın

```dart
// api_key.dart
const String geminiApiKey = 'SIZIN_API_ANAHTARINIZ';
```

```dart
// main.dart
import 'api_key.dart';

class _SentenceBuilderPageState extends State<SentenceBuilderPage> {
  static const String _geminiApiKey = geminiApiKey;
  // ...
}
```

### 7. Test Edin

Uygulamayı yeniden başlatın:
```bash
flutter clean
flutter pub get
flutter run
```

## Sorun Devam Ediyorsa

Eğer hata devam ediyorsa, aşağıdaki bilgileri kontrol edin:
- İnternet bağlantınız çalışıyor mu?
- API anahtarınız doğru kopyalandı mı? (başında/sonunda boşluk yok)
- Google AI Studio'da API'niz aktif mi?

## Yardım

Daha fazla yardım için:
- [Gemini API Dokümantasyonu](https://ai.google.dev/docs)
- [Flutter Gemini Paketleri](https://pub.dev/packages/google_generative_ai)

