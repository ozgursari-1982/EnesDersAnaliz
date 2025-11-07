import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemini AI servisi
/// API ile iletişim kurmak ve cümle analizleri yapmak için kullanılır
class GeminiService {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiService({required this.apiKey}) {
    // Gemini modelini başlat - gemini-1.5-flash kullan (hızlı ve güvenilir)
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  /// Almanca cümle analizi yap
  /// [sentence] - Analiz edilecek cümle
  /// [timeForm] - Kullanılan zaman formu (Present, Perfekt, vb.)
  /// Döndürür: Mari'nin cümle hakkındaki geri bildirimi
  Future<String> analyzeSentence(String sentence, String? timeForm) async {
    try {
      // Prompt hazırla
      final prompt = _buildPrompt(sentence, timeForm);
      
      // API'ye istek gönder
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(
        content,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 800,
        ),
      ).timeout(const Duration(seconds: 30));

      // Yanıtı döndür
      if (response.text != null) {
        return response.text!;
      } else {
        return _getDefaultErrorMessage();
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Prompt oluştur
  String _buildPrompt(String sentence, String? timeForm) {
    return '''
Du bist Mari, eine freundliche und geduldige Deutschlehrerin. 

Analysiere diesen deutschen Satz: "$sentence"
Zeitform: ${timeForm ?? 'Nicht spezifiziert'}

Gib eine detaillierte Analyse mit:
1. Ist die Satzstruktur korrekt? (V2-Position, Nebensatz, etc.)
2. Grammatikalische Korrektheit (Konjugation, Fälle, Artikel)
3. Passt die Zeitform?
4. Konkrete Verbesserungsvorschläge
5. Ein Beispiel, wie der Satz besser sein könnte

Sei freundlich, ermutigend und nutze Emojis! 🎓
Antworte auf Deutsch mit einfachen Erklärungen.
''';
  }

  /// Hata mesajlarını işle
  String _handleError(Object error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('503')) {
      return '''
❌ **Service Unavailable (503)**

Oh nein! Der Gemini-Service ist gerade überlastet. 

**Was kannst du tun?**
- ⏰ Warte 2-5 Minuten und versuche es erneut
- 🔄 Prüfe deine Internetverbindung
- 🔑 Überprüfe deinen API-Schlüssel

Mari wartet auf dich! 💙
''';
    } else if (errorStr.contains('429')) {
      return '''
⚠️ **Too Many Requests (429)**

Du hast das API-Limit erreicht!

**Lösungen:**
- ⏳ Warte einige Stunden
- 🔑 Erstelle einen neuen API-Schlüssel

Bis bald! 👋
''';
    } else if (errorStr.contains('401') || errorStr.contains('403')) {
      return '''
🔒 **Unauthorized (401/403)**

Dein API-Schlüssel ist ungültig!

**Bitte:**
- 🔑 Erstelle einen neuen Schlüssel auf https://makersuite.google.com/app/apikey
- ✅ Stelle sicher, dass der Schlüssel korrekt kopiert wurde

Mari kann dir nicht helfen ohne gültigen Schlüssel! 😢
''';
    } else if (errorStr.contains('400')) {
      return '''
📝 **Bad Request (400)**

Etwas stimmt mit der Anfrage nicht.

**Tipps:**
- 🔍 Überprüfe deinen Satz
- 🔄 Versuche es mit einem einfacheren Satz

Mari ist verwirrt! 🤔
''';
    } else if (errorStr.contains('timeout')) {
      return '''
⏱️ **Timeout**

Die Anfrage hat zu lange gedauert!

**Lösungen:**
- 🔄 Versuche es erneut
- 📶 Prüfe deine Internetverbindung
- ✂️ Verwende einen kürzeren Satz

Mari wartet geduldig! ⏰
''';
    } else {
      return '''
❌ **Unerwarteter Fehler**

Es ist ein Fehler aufgetreten: ${error.toString()}

**Bitte:**
- 🔄 Versuche es erneut
- 📶 Prüfe deine Internetverbindung
- 🔑 Überprüfe deinen API-Schlüssel

Mari ist für dich da! 💪
''';
    }
  }

  /// Varsayılan hata mesajı
  String _getDefaultErrorMessage() {
    return '''
❓ **Keine Antwort**

Mari hat keine Antwort erhalten! 

**Versuche es bitte erneut.** 🔄

Mari ist gleich wieder da! 🌟
''';
  }
}
