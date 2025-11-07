import 'package:flutter_test/flutter_test.dart';
import 'package:almanca_cumle_kurucu/constants/german_words.dart';

void main() {
  group('German Words Constants Tests', () {
    test('Zamanlar listesi doğru mu?', () {
      // Act & Assert
      expect(AppConstants.times, hasLength(4));
      expect(AppConstants.times, contains('Present'));
      expect(AppConstants.times, contains('Perfekt'));
      expect(AppConstants.times, contains('Präteritum'));
      expect(AppConstants.times, contains('Future'));
    });

    test('Başlangıç mesajı boş değil mi?', () {
      // Act & Assert
      expect(AppConstants.initialFeedback, isNotEmpty);
      expect(AppConstants.initialFeedback, contains('Mari'));
    });

    test('Zamirler listesi boş değil mi?', () {
      // Act & Assert
      expect(GermanWords.pronouns, isNotEmpty);
      expect(GermanWords.pronouns.length, greaterThan(5));
    });

    test('Fiiller listesi doğru mu?', () {
      // Act & Assert
      expect(GermanWords.verbs, isNotEmpty);
      
      // 'haben' fiili var mı?
      final haben = GermanWords.verbs.firstWhere(
        (word) => word.text == 'haben',
      );
      expect(haben.type, 'verb');
      expect(haben.infinitive, 'haben');
    });

    test('İsimler listesi doğru mu?', () {
      // Act & Assert
      expect(GermanWords.nouns, isNotEmpty);
      
      // 'Apfel' ismi var mı?
      final apfel = GermanWords.nouns.firstWhere(
        (word) => word.text == 'Apfel',
      );
      expect(apfel.type, 'noun');
      expect(apfel.gender, 'masculine');
      expect(apfel.article, 'der');
    });

    test('Zarflar listesi doğru mu?', () {
      // Act & Assert
      expect(GermanWords.adverbs, isNotEmpty);
      
      // 'heute' zarfı var mı?
      final heute = GermanWords.adverbs.firstWhere(
        (word) => word.text == 'heute',
      );
      expect(heute.type, 'adverb');
    });

    test('Bağlaçlar listesi doğru mu?', () {
      // Act & Assert
      expect(GermanWords.conjunctions, isNotEmpty);
      
      // 'und' bağlacı var mı?
      final und = GermanWords.conjunctions.firstWhere(
        (word) => word.text == 'und',
      );
      expect(und.type, 'conjunction');
    });

    test('Edatlar listesi doğru mu?', () {
      // Act & Assert
      expect(GermanWords.prepositions, isNotEmpty);
      
      // 'mit' edatı var mı?
      final mit = GermanWords.prepositions.firstWhere(
        (word) => word.text == 'mit',
      );
      expect(mit.type, 'preposition');
    });

    test('Partisipler listesi doğru mu?', () {
      // Act & Assert
      expect(GermanWords.participles, isNotEmpty);
      
      // 'gegessen' partisip var mı?
      final gegessen = GermanWords.participles.firstWhere(
        (word) => word.text == 'gegessen',
      );
      expect(gegessen.type, 'participle');
      expect(gegessen.properties['verb'], 'essen');
    });

    test('getAllWords tüm kelimeleri döndürüyor mu?', () {
      // Act
      final allWords = GermanWords.getAllWords();

      // Assert
      expect(allWords, isNotEmpty);
      expect(
        allWords.length,
        GermanWords.pronouns.length +
            GermanWords.verbs.length +
            GermanWords.adverbs.length +
            GermanWords.participles.length +
            GermanWords.nouns.length +
            GermanWords.conjunctions.length +
            GermanWords.prepositions.length,
      );
    });

    test('Fiiller doğru çekimlere sahip mi?', () {
      // Arrange
      final haben = GermanWords.verbs.firstWhere(
        (word) => word.text == 'haben',
      );

      // Act & Assert
      expect(haben.conjugations, isNotNull);
      expect(haben.conjugations!['Präsens'], isNotNull);
      expect(haben.conjugations!['Präsens']['ich'], 'habe');
      expect(haben.conjugations!['Präsens']['du'], 'hast');
    });

    test('İsimler doğru kategorilere sahip mi?', () {
      // Arrange
      final apfel = GermanWords.nouns.firstWhere(
        (word) => word.text == 'Apfel',
      );
      final katze = GermanWords.nouns.firstWhere(
        (word) => word.text == 'Katze',
      );

      // Act & Assert
      expect(apfel.category, 'food');
      expect(katze.category, 'animal');
    });
  });
}
