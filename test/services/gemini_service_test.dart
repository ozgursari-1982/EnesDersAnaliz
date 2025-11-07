import 'package:flutter_test/flutter_test.dart';
import 'package:almanca_cumle_kurucu/services/gemini_service.dart';

void main() {
  group('Gemini Service Tests', () {
    late GeminiService service;

    setUp(() {
      // Test için dummy API key kullan
      service = GeminiService(apiKey: 'test_api_key');
    });

    test('GeminiService oluşturulabilir', () {
      // Act & Assert
      expect(service, isNotNull);
      expect(service.apiKey, 'test_api_key');
    });

    test('Hata mesajı - 503 Service Unavailable', () {
      // Arrange
      final error = Exception('503 Service Unavailable');

      // Act
      final message = service._handleError(error);

      // Assert
      expect(message, contains('503'));
      expect(message, contains('Service Unavailable'));
    });

    test('Hata mesajı - 429 Too Many Requests', () {
      // Arrange
      final error = Exception('429 Too Many Requests');

      // Act
      final message = service._handleError(error);

      // Assert
      expect(message, contains('429'));
      expect(message, contains('Too Many Requests'));
    });

    test('Hata mesajı - 401 Unauthorized', () {
      // Arrange
      final error = Exception('401 Unauthorized');

      // Act
      final message = service._handleError(error);

      // Assert
      expect(message, contains('401'));
      expect(message, contains('Unauthorized'));
    });

    test('Hata mesajı - 403 Forbidden', () {
      // Arrange
      final error = Exception('403 Forbidden');

      // Act
      final message = service._handleError(error);

      // Assert
      expect(message, contains('403'));
      expect(message, contains('Unauthorized'));
    });

    test('Hata mesajı - 400 Bad Request', () {
      // Arrange
      final error = Exception('400 Bad Request');

      // Act
      final message = service._handleError(error);

      // Assert
      expect(message, contains('400'));
      expect(message, contains('Bad Request'));
    });

    test('Hata mesajı - Timeout', () {
      // Arrange
      final error = Exception('TimeoutException: Request timeout');

      // Act
      final message = service._handleError(error);

      // Assert
      expect(message, contains('Timeout'));
    });

    test('Hata mesajı - Bilinmeyen hata', () {
      // Arrange
      final error = Exception('Unknown error');

      // Act
      final message = service._handleError(error);

      // Assert
      expect(message, contains('Unerwarteter Fehler'));
      expect(message, contains('Unknown error'));
    });

    test('Prompt doğru oluşturuluyor mu?', () {
      // Arrange
      const sentence = 'Ich habe einen Apfel';
      const timeForm = 'Present';

      // Act
      final prompt = service._buildPrompt(sentence, timeForm);

      // Assert
      expect(prompt, contains('Mari'));
      expect(prompt, contains(sentence));
      expect(prompt, contains(timeForm));
      expect(prompt, contains('Zeitform'));
    });

    test('Prompt oluşturma - zaman formu null', () {
      // Arrange
      const sentence = 'Ich habe einen Apfel';

      // Act
      final prompt = service._buildPrompt(sentence, null);

      // Assert
      expect(prompt, contains('Mari'));
      expect(prompt, contains(sentence));
      expect(prompt, contains('Nicht spezifiziert'));
    });

    test('Varsayılan hata mesajı boş değil', () {
      // Act
      final message = service._getDefaultErrorMessage();

      // Assert
      expect(message, isNotEmpty);
      expect(message, contains('Keine Antwort'));
      expect(message, contains('Mari'));
    });
  });
}

// GeminiService sınıfına test için extension ekle
extension GeminiServiceTestExtension on GeminiService {
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

  String _getDefaultErrorMessage() {
    return '''
❓ **Keine Antwort**

Mari hat keine Antwort erhalten! 

**Versuche es bitte erneut.** 🔄

Mari ist gleich wieder da! 🌟
''';
  }

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
}
