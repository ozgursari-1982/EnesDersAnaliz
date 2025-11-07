import 'package:flutter_test/flutter_test.dart';
import 'package:almanca_cumle_kurucu/models/word.dart';

void main() {
  group('Word Model Tests', () {
    test('Word oluşturma testi', () {
      // Arrange & Act
      final word = Word(
        text: 'haben',
        type: 'verb',
        properties: {
          'infinitive': 'haben',
          'transitive': true,
        },
      );

      // Assert
      expect(word.text, 'haben');
      expect(word.type, 'verb');
      expect(word.infinitive, 'haben');
      expect(word.transitive, true);
    });

    test('Word toString testi', () {
      // Arrange
      final word = Word(text: 'Ich', type: 'pronoun');

      // Act & Assert
      expect(word.toString(), 'Ich');
    });

    test('Word eşitlik testi - aynı kelimeler', () {
      // Arrange
      final word1 = Word(
        text: 'haben',
        type: 'verb',
        properties: {'infinitive': 'haben'},
      );
      final word2 = Word(
        text: 'haben',
        type: 'verb',
        properties: {'infinitive': 'haben'},
      );

      // Act & Assert
      expect(word1, equals(word2));
    });

    test('Word eşitlik testi - farklı kelimeler', () {
      // Arrange
      final word1 = Word(text: 'haben', type: 'verb');
      final word2 = Word(text: 'sein', type: 'verb');

      // Act & Assert
      expect(word1, isNot(equals(word2)));
    });

    test('Word properties getter testleri', () {
      // Arrange
      final word = Word(
        text: 'Ich',
        type: 'pronoun',
        properties: {
          'person': '1st',
          'number': 'singular',
          'case': 'nominative',
          'gender': 'masculine',
        },
      );

      // Act & Assert
      expect(word.person, '1st');
      expect(word.number, 'singular');
      expect(word.case_, 'nominative');
      expect(word.gender, 'masculine');
    });

    test('Word fiil özellikleri testi', () {
      // Arrange
      final verb = Word(
        text: 'essen',
        type: 'verb',
        properties: {
          'infinitive': 'essen',
          'transitive': true,
          'objectCase': 'accusative',
          'conjugations': {
            'Präsens': {'ich': 'esse', 'du': 'isst'},
          },
        },
      );

      // Act & Assert
      expect(verb.infinitive, 'essen');
      expect(verb.transitive, true);
      expect(verb.objectCase, 'accusative');
      expect(verb.conjugations, isNotNull);
      expect(verb.conjugations!['Präsens'], isNotNull);
    });

    test('Word isim özellikleri testi', () {
      // Arrange
      final noun = Word(
        text: 'Apfel',
        type: 'noun',
        properties: {
          'gender': 'masculine',
          'case': 'nominative',
          'article': 'der',
          'category': 'food',
        },
      );

      // Act & Assert
      expect(noun.gender, 'masculine');
      expect(noun.case_, 'nominative');
      expect(noun.article, 'der');
      expect(noun.category, 'food');
    });

    test('Word boş properties testi', () {
      // Arrange
      final word = Word(text: 'und', type: 'conjunction');

      // Act & Assert
      expect(word.properties, isEmpty);
      expect(word.person, isNull);
      expect(word.gender, isNull);
    });
  });
}
