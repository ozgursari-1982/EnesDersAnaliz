import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Word {
  final String text;
  final String type; // e.g., 'pronoun', 'verb', 'noun', 'adverb', 'conjunction'
  final Map<String, dynamic> properties;

  Word({required this.text, required this.type, this.properties = const {}});

  @override
  String toString() => text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Word &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          type == other.type &&
          _mapEquals(properties, other.properties); // Map karşılaştırması için yardımcı fonk.

  @override
  int get hashCode => Object.hash(text, type, properties.entries.map((e) => Object.hash(e.key, e.value) as int).fold<int>(0, (prev, curr) => prev ^ curr));

  // properties'den kolayca erişim için getter'lar
  String? get person => properties?['person'];
  String? get number => properties?['number'];
  String? get gender => properties?['gender'];
  String? get case_ => properties?['case']; // 'case' anahtar kelime olduğu için 'case_' kullandık
  bool? get isFormal => properties?['isFormal'];
  String? get infinitive => properties?['infinitive'];
  Map<String, dynamic>? get conjugations => properties?['conjugations'];
  String? get auxiliary => properties?['auxiliary'];
  String? get participle => properties?['participle'];
  String? get article => properties?['article'];
  bool? get transitive => properties?['transitive']; // Fiilin nesne alıp almadığı
  String? get objectCase => properties?['objectCase']; // Fiilin aldığı nesnenin durumu (örn. 'accusative', 'dative')
  String? get category => properties?['category']; // İsim kategorisi (örn. 'food', 'liquid', 'book')
  String? get objectCategory => properties?['objectCategory']; // Fiilin tercih ettiği nesne kategorisi
}

// Harita karşılaştırması için yardımcı fonksiyon
bool _mapEquals(Map? a, Map? b) {
  if (a == b) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) {
      return false;
    }
  }
  return true;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deutsch Lernen mit Mari',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101622),
        primaryColor: const Color(0xFF135bec),
        textTheme: GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF135bec),
          background: const Color(0xFF101622),
          surface: const Color(0xFF192233),
        ),
      ),
      home: const SentenceBuilderPage(),
    );
  }
}

class SentenceBuilderPage extends StatefulWidget {
  const SentenceBuilderPage({super.key});

  @override
  State<SentenceBuilderPage> createState() => _SentenceBuilderPageState();
}

class _SentenceBuilderPageState extends State<SentenceBuilderPage> {
  // Zamanlar
  final List<String> _times = [
    'Present',
    'Perfekt',
    'Präteritum',
    'Future',
  ];

  String? _selectedTime;
  List<Word> _allWords = [
    Word(text: 'Ich', type: 'pronoun', properties: {'person': '1st', 'number': 'singular', 'case': 'nominative'}),
    Word(text: 'Du', type: 'pronoun', properties: {'person': '2nd', 'number': 'singular', 'case': 'nominative'}),
    Word(text: 'Er', type: 'pronoun', properties: {'person': '3rd', 'number': 'singular', 'gender': 'masculine', 'case': 'nominative'}),
    Word(text: 'Sie', type: 'pronoun', properties: {'person': '3rd', 'number': 'singular', 'gender': 'feminine', 'case': 'nominative'}),
    Word(text: 'Es', type: 'pronoun', properties: {'person': '3rd', 'number': 'singular', 'gender': 'neuter', 'case': 'nominative'}),
    Word(text: 'Wir', type: 'pronoun', properties: {'person': '1st', 'number': 'plural', 'case': 'nominative'}),
    Word(text: 'Ihr', type: 'pronoun', properties: {'person': '2nd', 'number': 'plural', 'case': 'nominative'}),
    Word(text: 'Sie', type: 'pronoun', properties: {'person': '3rd', 'number': 'plural', 'case': 'nominative', 'isFormal': true}), // Formal Sie
    Word(text: 'sie', type: 'pronoun', properties: {'person': '3rd', 'number': 'plural', 'case': 'nominative', 'isFormal': false}), // informal sie

    // Akuzatif zamirler (şimdilik sadece 'mich' ve 'dich' ekleyelim)
    Word(text: 'mich', type: 'pronoun', properties: {'person': '1st', 'number': 'singular', 'case': 'accusative'}),
    Word(text: 'dich', type: 'pronoun', properties: {'person': '2nd', 'number': 'singular', 'case': 'accusative'}),

    Word(text: 'haben', type: 'verb', properties: {
      'infinitive': 'haben',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'general', // Genel bir kategori ekledim
      'conjugations': {
        'Präsens': {'ich': 'habe', 'du': 'hast', 'er/sie/es': 'hat', 'wir': 'haben', 'ihr': 'habt', 'sie/Sie': 'haben'},
        'Präteritum': {'ich': 'hatte', 'du': 'hattest', 'er/sie/es': 'hatte', 'wir': 'hatten', 'ihr': 'hattet', 'sie/Sie': 'hatten'},
        'Perfekt': {'ich': 'habe', 'du': 'hast', 'er/sie/es': 'hat', 'wir': 'haben', 'ihr': 'habt', 'sie/Sie': 'haben'}
      }
    }),
    Word(text: 'sein', type: 'verb', properties: {
      'infinitive': 'sein',
      'transitive': false,
      'objectCategory': 'state_movement', // Durum veya hareket fiilleri için
      'conjugations': {
        'Präsens': {'ich': 'bin', 'du': 'bist', 'er/sie/es': 'ist', 'wir': 'sind', 'ihr': 'seid', 'sie/Sie': 'sind'},
        'Präteritum': {'ich': 'war', 'du': 'warst', 'er/sie/es': 'war', 'wir': 'waren', 'ihr': 'wart', 'sie/Sie': 'waren'},
        'Perfekt': {'ich': 'bin', 'du': 'bist', 'er/sie/es': 'ist', 'wir': 'sind', 'ihr': 'seid', 'sie/Sie': 'sind'}
      }
    }),
    Word(text: 'essen', type: 'verb', properties: {
      'infinitive': 'essen',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'food',
      'conjugations': {
        'Präsens': {'ich': 'esse', 'du': 'isst', 'er/sie/es': 'isst', 'wir': 'essen', 'ihr': 'esst', 'sie/Sie': 'essen'},
        'Präteritum': {'ich': 'aß', 'du': 'aßt', 'er/sie/es': 'aß', 'wir': 'aßen', 'ihr': 'aßt', 'sie/Sie': 'aßen'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gegessen'}
      }
    }),
    Word(text: 'trinken', type: 'verb', properties: {
      'infinitive': 'trinken',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'liquid',
      'conjugations': {
        'Präsens': {'ich': 'trinke', 'du': 'trinkst', 'er/sie/es': 'trinkt', 'wir': 'trinken', 'ihr': 'trinkt', 'sie/Sie': 'trinken'},
        'Präteritum': {'ich': 'trank', 'du': 'trankst', 'er/sie/es': 'trank', 'wir': 'tranken', 'ihr': 'trankt', 'sie/Sie': 'tranken'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'getrunken'}
      }
    }),
    Word(text: 'gehen', type: 'verb', properties: {
      'infinitive': 'gehen',
      'transitive': false,
      'objectCategory': 'movement',
      'conjugations': {
        'Präsens': {'ich': 'gehe', 'du': 'gehst', 'er/sie/es': 'geht', 'wir': 'gehen', 'ihr': 'geht', 'sie/Sie': 'gehen'},
        'Präteritum': {'ich': 'ging', 'du': 'gingst', 'er/sie/es': 'ging', 'wir': 'gingen', 'ihr': 'gingt', 'sie/Sie': 'gingen'},
        'Perfekt': {'auxiliary': 'sein', 'participle': 'gegangen'}
      }
    }),
    Word(text: 'fragen', type: 'verb', properties: {
      'infinitive': 'fragen',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'person_information',
      'conjugations': {
        'Präsens': {'ich': 'frage', 'du': 'fragst', 'er/sie/es': 'fragt', 'wir': 'fragen', 'ihr': 'fragt', 'sie/Sie': 'fragen'},
        'Präteritum': {'ich': 'fragte', 'du': 'fragtest', 'er/sie/es': 'fragte', 'wir': 'fragten', 'ihr': 'fragtet', 'sie/Sie': 'fragten'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gefragt'}
      }
    }),
    Word(text: 'helfen', type: 'verb', properties: {
      'infinitive': 'helfen',
      'transitive': true,
      'objectCase': 'dative',
      'objectCategory': 'person',
      'conjugations': {
        'Präsens': {'ich': 'helfe', 'du': 'hilfst', 'er/sie/es': 'hilft', 'wir': 'helfen', 'ihr': 'helft', 'sie/Sie': 'helfen'},
        'Präteritum': {'ich': 'half', 'du': 'halfst', 'er/sie/es': 'half', 'wir': 'halfen', 'ihr': 'halft', 'sie/Sie': 'halfen'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'geholfen'}
      }
    }),
    Word(text: 'werden', type: 'verb', properties: { // Future tense auxiliary verb
      'infinitive': 'werden',
      'objectCategory': 'future_event', // Gelecek zaman için
      'conjugations': {
        'Präsens': {'ich': 'werde', 'du': 'wirst', 'er/sie/es': 'wird', 'wir': 'werden', 'ihr': 'werdet', 'sie/Sie': 'werden'},
        'Präteritum': {'ich': 'wurde', 'du': 'wurdest', 'er/sie/es': 'wurde', 'wir': 'wurden', 'ihr': 'wurdet', 'sie/Sie': 'wurden'}
      }
    }),

    Word(text: 'gestern', type: 'adverb', properties: {'time': 'past'}),
    Word(text: 'heute', type: 'adverb', properties: {'time': 'present'}),
    Word(text: 'morgen', type: 'adverb', properties: {'time': 'future'}),

    Word(text: 'aufgestanden', type: 'participle', properties: {'verb': 'aufstehen', 'auxiliary': 'sein', 'objectCategory': 'movement'}),
    Word(text: 'gegessen', type: 'participle', properties: {'verb': 'essen', 'auxiliary': 'haben', 'objectCategory': 'food'}),
    Word(text: 'getrunken', type: 'participle', properties: {'verb': 'trinken', 'auxiliary': 'haben', 'objectCategory': 'liquid'}),
    Word(text: 'gegangen', type: 'participle', properties: {'verb': 'gehen', 'auxiliary': 'sein', 'objectCategory': 'movement'}),
    Word(text: 'gefragt', type: 'participle', properties: {'verb': 'fragen', 'auxiliary': 'haben', 'objectCategory': 'person_information'}),
    Word(text: 'geholfen', type: 'participle', properties: {'verb': 'helfen', 'auxiliary': 'haben', 'objectCategory': 'person'}),
    Word(text: 'gefüttert', type: 'participle', properties: {'verb': 'füttern', 'auxiliary': 'haben', 'objectCategory': 'animal'}),
    Word(text: 'gefahren', type: 'participle', properties: {'verb': 'fahren', 'auxiliary': 'haben', 'objectCategory': 'vehicle'}),

    Word(text: 'Apfel', type: 'noun', properties: {'gender': 'masculine', 'case': 'nominative', 'article': 'der', 'category': 'food'}),
    Word(text: 'Buch', type: 'noun', properties: {'gender': 'neuter', 'case': 'nominative', 'article': 'das', 'category': 'book_document'}),
    Word(text: 'Katze', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'animal'}),

    // Akuzatif isimler (örnek olarak)
    Word(text: 'einen Apfel', type: 'noun', properties: {'gender': 'masculine', 'case': 'accusative', 'article': 'einen', 'category': 'food'}),
    Word(text: 'ein Buch', type: 'noun', properties: {'gender': 'neuter', 'case': 'accusative', 'article': 'ein', 'category': 'book_document'}),
    Word(text: 'eine Katze', type: 'noun', properties: {'gender': 'feminine', 'case': 'accusative', 'article': 'eine', 'category': 'animal'}),

    // Datif isimler (örnek olarak)
    Word(text: 'dem Mann', type: 'noun', properties: {'gender': 'masculine', 'case': 'dative', 'article': 'dem', 'category': 'person'}),
    Word(text: 'dem Kind', type: 'noun', properties: {'gender': 'neuter', 'case': 'dative', 'article': 'dem', 'category': 'person'}),
    Word(text: 'der Frau', type: 'noun', properties: {'gender': 'feminine', 'case': 'dative', 'article': 'der', 'category': 'person'}),
    Word(text: 'sehen', type: 'verb', properties: {
      'infinitive': 'sehen',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'general_object', // Genel bir nesne kategorisi
      'conjugations': {
        'Präsens': {'ich': 'sehe', 'du': 'siehst', 'er/sie/es': 'sieht', 'wir': 'sehen', 'ihr': 'seht', 'sie/Sie': 'sehen'},
        'Präteritum': {'ich': 'sah', 'du': 'sahst', 'er/sie/es': 'sah', 'wir': 'sahen', 'ihr': 'saht', 'sie/Sie': 'sahen'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gesehen'}
      }
    }),
    Word(text: 'gesehen', type: 'participle', properties: {'verb': 'sehen', 'auxiliary': 'haben', 'objectCategory': 'general_object'}),
    // Yeni fiiller
    Word(text: 'kaufen', type: 'verb', properties: {
      'infinitive': 'kaufen',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'general_item', // Genel öğe
      'conjugations': {
        'Präsens': {'ich': 'kaufe', 'du': 'kaufst', 'er/sie/es': 'kauft', 'wir': 'kaufen', 'ihr': 'kauft', 'sie/Sie': 'kaufen'},
        'Präteritum': {'ich': 'kaufte', 'du': 'kauftest', 'er/sie/es': 'kaufte', 'wir': 'kauften', 'ihr': 'kauftet', 'sie/Sie': 'kauften'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gekauft'}
      }
    }),
    Word(text: 'lesen', type: 'verb', properties: {
      'infinitive': 'lesen',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'book_document',
      'conjugations': {
        'Präsens': {'ich': 'lese', 'du': 'liest', 'er/sie/es': 'liest', 'wir': 'lesen', 'ihr': 'lest', 'sie/Sie': 'lesen'},
        'Präteritum': {'ich': 'las', 'du': 'last', 'er/sie/es': 'las', 'wir': 'lasen', 'ihr': 'last', 'sie/Sie': 'lasen'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gelesen'}
      }
    }),
    Word(text: 'schreiben', type: 'verb', properties: {
      'infinitive': 'schreiben',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'text_content', // Metin içeriği
      'conjugations': {
        'Präsens': {'ich': 'schreibe', 'du': 'schreibst', 'er/sie/es': 'schreibt', 'wir': 'schreiben', 'ihr': 'schreibt', 'sie/Sie': 'schreiben'},
        'Präteritum': {'ich': 'schrieb', 'du': 'schriebst', 'er/sie/es': 'schrieb', 'wir': 'schrieben', 'ihr': 'schriebt', 'sie/Sie': 'schrieben'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'geschrieben'}
      }
    }),
    Word(text: 'sprechen', type: 'verb', properties: {
      'infinitive': 'sprechen',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'language_topic', // Dil veya konu
      'conjugations': {
        'Präsens': {'ich': 'spreche', 'du': 'sprichst', 'er/sie/es': 'spricht', 'wir': 'sprechen', 'ihr': 'sprecht', 'sie/Sie': 'sprechen'},
        'Präteritum': {'ich': 'sprach', 'du': 'sprachst', 'er/sie/es': 'sprach', 'wir': 'sprachen', 'ihr': 'spracht', 'sie/Sie': 'sprachen'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gesprochen'}
      }
    }),
    Word(text: 'bleiben', type: 'verb', properties: {
      'infinitive': 'bleiben',
      'transitive': false,
      'objectCategory': 'location_state', // Konum veya durum
      'conjugations': {
        'Präsens': {'ich': 'bleibe', 'du': 'bleibst', 'er/sie/es': 'bleibt', 'wir': 'bleiben', 'ihr': 'bleibt', 'sie/Sie': 'bleiben'},
        'Präteritum': {'ich': 'blieb', 'du': 'bliebst', 'er/sie/es': 'blieb', 'wir': 'blieben', 'ihr': 'bliebt', 'sie/Sie': 'blieben'},
        'Perfekt': {'auxiliary': 'sein', 'participle': 'geblieben'}
      }
    }),
    // Yeni fiiller: füttern ve fahren
    Word(text: 'füttern', type: 'verb', properties: {
      'infinitive': 'füttern',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'animal',
      'conjugations': {
        'Präsens': {'ich': 'füttere', 'du': 'fütterst', 'er/sie/es': 'füttert', 'wir': 'füttern', 'ihr': 'füttert', 'sie/Sie': 'füttern'},
        'Präteritum': {'ich': 'fütterte', 'du': 'füttertest', 'er/sie/es': 'fütterte', 'wir': 'fütterten', 'ihr': 'füttertet', 'sie/Sie': 'fütterten'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gefüttert'}
      }
    }),
    Word(text: 'fahren', type: 'verb', properties: {
      'infinitive': 'fahren',
      'transitive': true, // Nesne alabilir (örn: ein Auto fahren)
      'objectCase': 'accusative',
      'objectCategory': 'vehicle',
      'conjugations': {
        'Präsens': {'ich': 'fahre', 'du': 'fährst', 'er/sie/es': 'fährt', 'wir': 'fahren', 'ihr': 'fahrt', 'sie/Sie': 'fahren'},
        'Präteritum': {'ich': 'fuhr', 'du': 'fuhrst', 'er/sie/es': 'fuhr', 'wir': 'fuhren', 'ihr': 'fuhrt', 'sie/Sie': 'fuhren'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gefahren'} // Nesne aldığında 'haben' kullanılır. Hareketi belirtiyorsa 'sein' olabilir.
      }
    }),
    // Yeni isimler
    Word(text: 'Haus', type: 'noun', properties: {'gender': 'neuter', 'case': 'nominative', 'article': 'das', 'category': 'building'}),
    Word(text: 'Auto', type: 'noun', properties: {'gender': 'neuter', 'case': 'nominative', 'article': 'das', 'category': 'vehicle'}),
    Word(text: 'Lehrer', type: 'noun', properties: {'gender': 'masculine', 'case': 'nominative', 'article': 'der', 'category': 'person'}),
    Word(text: 'Schüler', type: 'noun', properties: {'gender': 'masculine', 'case': 'nominative', 'article': 'der', 'category': 'person'}),
    Word(text: 'Freund', type: 'noun', properties: {'gender': 'masculine', 'case': 'nominative', 'article': 'der', 'category': 'person'}),
    Word(text: 'Freundin', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'person'}),
    Word(text: 'Schule', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'building'}),
    Word(text: 'Arbeit', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'activity'}),
    // Akuzatif isimler (ek)
    Word(text: 'ein Haus', type: 'noun', properties: {'gender': 'neuter', 'case': 'accusative', 'article': 'ein', 'category': 'building'}),
    Word(text: 'einen Lehrer', type: 'noun', properties: {'gender': 'masculine', 'case': 'accusative', 'article': 'einen', 'category': 'person'}),
    Word(text: 'eine Freundin', type: 'noun', properties: {'gender': 'feminine', 'case': 'accusative', 'article': 'eine', 'category': 'person'}),
    Word(text: 'ein Bier', type: 'noun', properties: {'gender': 'neuter', 'case': 'accusative', 'article': 'ein', 'category': 'liquid'}), // Yeni
    Word(text: 'ein Auto', type: 'noun', properties: {'gender': 'neuter', 'case': 'accusative', 'article': 'ein', 'category': 'vehicle'}), // Yeni
    // Datif isimler (ek)
    Word(text: 'dem Lehrer', type: 'noun', properties: {'gender': 'masculine', 'case': 'dative', 'article': 'dem', 'category': 'person'}),
    Word(text: 'der Schule', type: 'noun', properties: {'gender': 'feminine', 'case': 'dative', 'article': 'der', 'category': 'building'}),
    Word(text: 'dem Freund', type: 'noun', properties: {'gender': 'masculine', 'case': 'dative', 'article': 'dem', 'category': 'person'}),
    Word(text: 'dem Buch', type: 'noun', properties: {'gender': 'neuter', 'case': 'dative', 'article': 'dem', 'category': 'book_document'}),
    // Bağlaçlar
    Word(text: 'und', type: 'conjunction', properties: {'connects': 'same_case'}), // Aynı durumdaki cümleleri/kelimeleri bağlar
    Word(text: 'aber', type: 'conjunction', properties: {'connects': 'same_case'}),
    Word(text: 'oder', type: 'conjunction', properties: {'connects': 'same_case'}),
    Word(text: 'weil', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
    Word(text: 'dass', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
    Word(text: 'ob', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
    // Edatlar (şimdilik sadece basit örnekler)
    Word(text: 'mit', type: 'preposition', properties: {'case': 'dative'}),
    Word(text: 'in', type: 'preposition', properties: {'case': 'dative_accusative'}), // İki durumlu edat
    Word(text: 'für', type: 'preposition', properties: {'case': 'accusative'}),
    // Yeni bağlaçlar
    Word(text: 'als', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end', 'context': 'past_single_event'}),
    Word(text: 'wenn', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end', 'context': 'present_future_repeated_past'}),
    Word(text: 'bevor', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
    Word(text: 'nachdem', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
    Word(text: 'obwohl', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
    Word(text: 'während', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
    Word(text: 'da', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
    Word(text: 'falls', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
    Word(text: 'solange', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
    Word(text: 'sobald', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
    Word(text: 'denn', type: 'conjunction', properties: {'connects': 'main_clause'}),
    Word(text: 'sondern', type: 'conjunction', properties: {'connects': 'main_clause'}),
    Word(text: 'entweder ... oder', type: 'conjunction', properties: {'connects': 'alternatives'}),
    Word(text: 'weder ... noch', type: 'conjunction', properties: {'connects': 'neg_alternatives'}),
    Word(text: 'sowohl ... als auch', type: 'conjunction', properties: {'connects': 'both_options'}),
    // Yeni edatlar
    Word(text: 'an', type: 'preposition', properties: {'case': 'dative_accusative', 'meaning': 'on_at_vertical'}),
    Word(text: 'auf', type: 'preposition', properties: {'case': 'dative_accusative', 'meaning': 'on_at_horizontal'}),
    Word(text: 'hinter', type: 'preposition', properties: {'case': 'dative_accusative', 'meaning': 'behind'}),
    Word(text: 'neben', type: 'preposition', properties: {'case': 'dative_accusative', 'meaning': 'next_to'}),
    Word(text: 'über', type: 'preposition', properties: {'case': 'dative_accusative', 'meaning': 'over_above'}),
    Word(text: 'unter', type: 'preposition', properties: {'case': 'dative_accusative', 'meaning': 'under_below'}),
    Word(text: 'vor', type: 'preposition', properties: {'case': 'dative_accusative', 'meaning': 'in_front_of_before'}),
    Word(text: 'zwischen', type: 'preposition', properties: {'case': 'dative_accusative', 'meaning': 'between'}),
    Word(text: 'durch', type: 'preposition', properties: {'case': 'accusative', 'meaning': 'through'}),
    Word(text: 'gegen', type: 'preposition', properties: {'case': 'accusative', 'meaning': 'against_towards'}),
    Word(text: 'ohne', type: 'preposition', properties: {'case': 'accusative', 'meaning': 'without'}),
    Word(text: 'um', type: 'preposition', properties: {'case': 'accusative', 'meaning': 'around_at_time'}),
    Word(text: 'aus', type: 'preposition', properties: {'case': 'dative', 'meaning': 'from_out_of'}),
    Word(text: 'bei', type: 'preposition', properties: {'case': 'dative', 'meaning': 'at_with_near'}),
    Word(text: 'von', type: 'preposition', properties: {'case': 'dative', 'meaning': 'from_by_of'}),
    Word(text: 'zu', type: 'preposition', properties: {'case': 'dative', 'meaning': 'to_at_home'}),
    // Yeni zarflar
    Word(text: 'oft', type: 'adverb', properties: {'time': 'frequency'}),
    Word(text: 'manchmal', type: 'adverb', properties: {'time': 'frequency'}),
    Word(text: 'immer', type: 'adverb', properties: {'time': 'frequency'}),
    Word(text: 'nie', type: 'adverb', properties: {'time': 'frequency'}),
    Word(text: 'gern', type: 'adverb', properties: {'manner': 'liking'}),
    Word(text: 'sehr', type: 'adverb', properties: {'degree': 'very'}),
    Word(text: 'hier', type: 'adverb', properties: {'place': 'here'}),
    Word(text: 'dort', type: 'adverb', properties: {'place': 'there'}),
    Word(text: 'deshalb', type: 'adverb', properties: {'reason': 'therefore'}),
    // Yeni fiiller
    Word(text: 'lernen', type: 'verb', properties: {
      'infinitive': 'lernen',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'subject_skill',
      'conjugations': {
        'Präsens': {'ich': 'lerne', 'du': 'lernst', 'er/sie/es': 'lernt', 'wir': 'lernen', 'ihr': 'lernt', 'sie/Sie': 'lernen'},
        'Präteritum': {'ich': 'lernte', 'du': 'lerntest', 'er/sie/es': 'lernte', 'wir': 'lernten', 'ihr': 'lerntet', 'sie/Sie': 'lernten'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gelernt'}
      }
    }),
    Word(text: 'studieren', type: 'verb', properties: {
      'infinitive': 'studieren',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'subject_field',
      'conjugations': {
        'Präsens': {'ich': 'studiere', 'du': 'studierst', 'er/sie/es': 'studiert', 'wir': 'studieren', 'ihr': 'studiert', 'sie/Sie': 'studieren'},
        'Präteritum': {'ich': 'studierte', 'du': 'studiertest', 'er/sie/es': 'studierte', 'wir': 'studierten', 'ihr': 'studiertet', 'sie/Sie': 'studierten'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'studiert'}
      }
    }),
    Word(text: 'arbeiten', type: 'verb', properties: {
      'infinitive': 'arbeiten',
      'transitive': false,
      'objectCategory': 'general', // Nesne almaz ama yer/zaman zarfı alabilir
      'conjugations': {
        'Präsens': {'ich': 'arbeite', 'du': 'arbeitest', 'er/sie/es': 'arbeitet', 'wir': 'arbeiten', 'ihr': 'arbeitet', 'sie/Sie': 'arbeiten'},
        'Präteritum': {'ich': 'arbeitete', 'du': 'arbeitetest', 'er/sie/es': 'arbeitete', 'wir': 'arbeiteten', 'ihr': 'arbeitetet', 'sie/Sie': 'arbeiteten'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gearbeitet'}
      }
    }),
    Word(text: 'reisen', type: 'verb', properties: {
      'infinitive': 'reisen',
      'transitive': false,
      'objectCategory': 'movement', // Hedef veya yer zarfı alabilir
      'conjugations': {
        'Präsens': {'ich': 'reise', 'du': 'reist', 'er/sie/es': 'reist', 'wir': 'reisen', 'ihr': 'reist', 'sie/Sie': 'reisen'},
        'Präteritum': {'ich': 'reiste', 'du': 'reistest', 'er/sie/es': 'reiste', 'wir': 'reisten', 'ihr': 'reistet', 'sie/Sie': 'reisten'},
        'Perfekt': {'auxiliary': 'sein', 'participle': 'gereist'} // Yer değişikliği olduğu için 'sein'
      }
    }),
    Word(text: 'wissen', type: 'verb', properties: {
      'infinitive': 'wissen',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'information',
      'conjugations': {
        'Präsens': {'ich': 'weiß', 'du': 'weißt', 'er/sie/es': 'weiß', 'wir': 'wissen', 'ihr': 'wisst', 'sie/Sie': 'wissen'},
        'Präteritum': {'ich': 'wusste', 'du': 'wusstest', 'er/sie/es': 'wusste', 'wir': 'wussten', 'ihr': 'wusstet', 'sie/Sie': 'wussten'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gewusst'}
      }
    }),
    Word(text: 'kennen', type: 'verb', properties: {
      'infinitive': 'kennen',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'person_place_thing',
      'conjugations': {
        'Präsens': {'ich': 'kenne', 'du': 'kennst', 'er/sie/es': 'kennt', 'wir': 'kennen', 'ihr': 'kennt', 'sie/Sie': 'kennen'},
        'Präteritum': {'ich': 'kannte', 'du': 'kanntest', 'er/sie/es': 'kannte', 'wir': 'kannten', 'ihr': 'kanntet', 'sie/Sie': 'kannten'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gekannt'}
      }
    }),
    // Yeni isimler
    Word(text: 'Freude', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'emotion'}),
    Word(text: 'Glück', type: 'noun', properties: {'gender': 'neuter', 'case': 'nominative', 'article': 'das', 'category': 'abstract'}),
    Word(text: 'Angst', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'emotion'}),
    Word(text: 'Zeit', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'time'}),
    Word(text: 'Geld', type: 'noun', properties: {'gender': 'neuter', 'case': 'nominative', 'article': 'das', 'category': 'finance'}),
    Word(text: 'Stadt', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'location'}),
    Word(text: 'Land', type: 'noun', properties: {'gender': 'neuter', 'case': 'nominative', 'article': 'das', 'category': 'location'}),
    // Yeni partisip eklemeleri
    Word(text: 'gelernt', type: 'participle', properties: {'verb': 'lernen', 'auxiliary': 'haben', 'objectCategory': 'subject_skill'}),
    Word(text: 'studiert', type: 'participle', properties: {'verb': 'studieren', 'auxiliary': 'haben', 'objectCategory': 'subject_field'}),
    Word(text: 'gearbeitet', type: 'participle', properties: {'verb': 'arbeiten', 'auxiliary': 'haben', 'objectCategory': 'general'}),
    Word(text: 'gereist', type: 'participle', properties: {'verb': 'reisen', 'auxiliary': 'sein', 'objectCategory': 'movement'}),
    Word(text: 'gewusst', type: 'participle', properties: {'verb': 'wissen', 'auxiliary': 'haben', 'objectCategory': 'information'}),
    Word(text: 'gekannt', type: 'participle', properties: {'verb': 'kennen', 'auxiliary': 'haben', 'objectCategory': 'person_place_thing'}),
  ];
  // API anahtarınızı buraya girin veya çevre değişkeninden alın
  static const String _geminiApiKey = 'AIzaSyDTbMcxi7Cl0_IFq1XGCUsu818HTlOIDOI';
  String _currentFeedback = "Hallo! 👋 Ich bin Mari, deine Deutsch-Lehrerin!\n\nBaue zuerst deinen Satz mit den Wörtern oben, dann drücke auf den Button 'An Mari'.\n\nIch analysiere dann deinen Satz Schritt für Schritt! 🎓"; // Almanca başlangıç mesajı
  bool _isLoadingFeedback = false; // Loading durumu için

  // Ana cümle için state değişkenleri
  Word? _selectedSubject; // Seçilen özne
  Word? _selectedAuxiliaryVerb; // Seçilen yardımcı fiil (haben, sein, werden)
  Word? _selectedMainVerb; // Seçilen ana fiil
  Word? _selectedParticiple; // Seçilen partisip (Perfekt için)
  List<Word> _selectedObjects = []; // Seçilen nesneler (isim veya zamir)
  List<Word> _selectedAdverbs = []; // Seçilen zarflar
  Word? _selectedConjunction; // Seçilen bağlaç
  Word? _selectedObjectPronoun; // Seçilen nesne zamiri (mich, dich, vb.)

  // Yan cümle (Nebensatz) için state değişkenleri
  Word? _subClauseSubject; // Yan cümle öznesi
  Word? _subClauseAuxiliaryVerb; // Yan cümle yardımcı fiili
  Word? _subClauseMainVerb; // Yan cümle ana fiili
  Word? _subClauseParticiple; // Yan cümle partisipi
  List<Word> _subClauseObjects = []; // Yan cümle nesneleri
  List<Word> _subClauseAdverbs = []; // Yan cümle zarfları
  Word? _subClauseObjectPronoun; // Yan cümle nesne zamiri

  // Debounce mekanizması kaldırıldı - artık sadece butona basınca API çağrısı yapılacak
  // Timer? _debounceTimer;
  // final Duration _debounceDuration = const Duration(milliseconds: 1500);

  // Cümleyi oluşturan parçalardan birleştirir
  String _getCurrentSentenceText() {
    final List<String> currentSentenceParts = [];
    
    // Ana cümle (Hauptsatz) - V2 pozisyonu (fiil ikinci sırada)
    if (_selectedSubject != null) currentSentenceParts.add(_selectedSubject!.text);
    
    // V2: Yardımcı fiil veya ana fiil ikinci pozisyonda olmalı
    if (_selectedAuxiliaryVerb != null) {
      currentSentenceParts.add(_selectedAuxiliaryVerb!.text);
    } else if (_selectedMainVerb != null) {
      currentSentenceParts.add(_selectedMainVerb!.text);
    }
    
    // Zarflar, nesne zamiri, nesneler
    currentSentenceParts.addAll(_selectedAdverbs.map((word) => word.text));
    if (_selectedObjectPronoun != null) currentSentenceParts.add(_selectedObjectPronoun!.text);
    if (_selectedObjects.isNotEmpty) currentSentenceParts.addAll(_selectedObjects.map((word) => word.text));
    
    // Perfekt için: partisip veya mastar fiil cümle sonunda
    if (_selectedParticiple != null) {
      currentSentenceParts.add(_selectedParticiple!.text);
    } else if (_selectedAuxiliaryVerb != null && _selectedMainVerb != null) {
      // Eğer hem yardımcı fiil hem ana fiil varsa, ana fiil sonda (Future için: werden + infinitiv)
      currentSentenceParts.add(_selectedMainVerb!.text);
    }
    
    // Bağlaç
    if (_selectedConjunction != null) {
      currentSentenceParts.add(_selectedConjunction!.text);
      
      // Yan cümle (Nebensatz) - Eğer bağlaç yan cümle başlatıyorsa
      bool isSubordinatingConjunction = _selectedConjunction!.properties?['introduces'] == 'subordinate_clause';
      
      if (isSubordinatingConjunction) {
        // Yan cümle: Özne + Nesne/Zarflar + Fiil (sonda)
        if (_subClauseSubject != null) currentSentenceParts.add(_subClauseSubject!.text);
        currentSentenceParts.addAll(_subClauseAdverbs.map((word) => word.text));
        if (_subClauseObjectPronoun != null) currentSentenceParts.add(_subClauseObjectPronoun!.text);
        if (_subClauseObjects.isNotEmpty) currentSentenceParts.addAll(_subClauseObjects.map((word) => word.text));
        if (_subClauseParticiple != null) currentSentenceParts.add(_subClauseParticiple!.text);
        // Yan cümlede fiil sonda olur
        if (_subClauseMainVerb != null) currentSentenceParts.add(_subClauseMainVerb!.text);
        if (_subClauseAuxiliaryVerb != null) currentSentenceParts.add(_subClauseAuxiliaryVerb!.text);
      } else {
        // Koordinasyon bağlacı (und, aber, oder) - normal kelime sırası
        if (_subClauseSubject != null) currentSentenceParts.add(_subClauseSubject!.text);
        if (_subClauseAuxiliaryVerb != null) currentSentenceParts.add(_subClauseAuxiliaryVerb!.text);
        currentSentenceParts.addAll(_subClauseAdverbs.map((word) => word.text));
        if (_subClauseObjectPronoun != null) currentSentenceParts.add(_subClauseObjectPronoun!.text);
        if (_subClauseObjects.isNotEmpty) currentSentenceParts.addAll(_subClauseObjects.map((word) => word.text));
        if (_subClauseParticiple != null) currentSentenceParts.add(_subClauseParticiple!.text);
        if (_subClauseMainVerb != null) currentSentenceParts.add(_subClauseMainVerb!.text);
      }
    }

    return currentSentenceParts.join(' ');
  }

  Future<void> _listGeminiModels() async {
    final String url = 'https://generativelanguage.googleapis.com/v1beta/models?key=$_geminiApiKey';
    print('Gemini ListModels API URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      print('Gemini ListModels Yanıt Durum Kodu: ${response.statusCode}');
      print('Gemini ListModels Yanıt Gövdesi: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> models = data['models'] ?? [];
        for (var model in models) {
          print('Model Adı: ${model['name']}, Desteklenen Metotlar: ${model['supportedGenerationMethods']}');
        }
      } else {
        print('ListModels API hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('ListModels API isteği sırasında bir hata oluştu: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    print('initState çağrıldı.'); // Debug print
    _selectedTime = 'Present'; // Varsayılan olarak şimdiki zamanı ayarla
    _filterWords(); // Başlangıçta kelimeleri filtrele
    // _updateFeedback() kaldırıldı - artık sadece butona basınca çağrılacak
  }

  void _clearSentence() {
    setState(() {
      _filterWords(); // Kelime seçeneklerini güncelle
      // Feedback'i başlangıç mesajına sıfırla
      _currentFeedback = "Hallo! 👋 Ich bin Mari, deine Deutsch-Lehrerin!\n\nBaue zuerst deinen Satz mit den Wörtern oben, dann drücke auf den Button 'An Mari'.\n\nIch analysiere dann deinen Satz Schritt für Schritt! 🎓";
      _isLoadingFeedback = false;
      // Ana cümle
      _selectedSubject = null;
      _selectedAuxiliaryVerb = null;
      _selectedMainVerb = null;
      _selectedParticiple = null;
      _selectedObjects.clear();
      _selectedAdverbs.clear();
      _selectedConjunction = null;
      _selectedObjectPronoun = null;
      // Yan cümle
      _subClauseSubject = null;
      _subClauseAuxiliaryVerb = null;
      _subClauseMainVerb = null;
      _subClauseParticiple = null;
      _subClauseObjects.clear();
      _subClauseAdverbs.clear();
      _subClauseObjectPronoun = null;
    });
  }

  // Gemini API geri bildirim fonksiyonu (Resmi paket kullanıyor - 400 hatası düzeltildi!)
  Future<String> _getGeminiFeedback(String sentence) async {
    if (sentence.trim().isEmpty) {
      return 'Mari wartet auf deine Auswahl... 🌟';
    }

    final String constructedSentence = _getCurrentSentenceText();
    
    // Resmi Google Generative AI paketini kullan (Gemini 2.5 - En yeni model!)
    final model = GenerativeModel(
      model: 'gemini-2.5-flash', // 2025'in en yeni ve hızlı modeli!
      apiKey: _geminiApiKey,
    );

    final prompt = """Hallo! 👋 Ich bin Mari, deine Deutsch-Lehrerin!

Ein Schüler hat einen deutschen Satz gebildet und wartet auf meine detaillierte Analyse. Meine Aufgabe ist es, den Satz **Schritt für Schritt** und **sehr detailliert** auf Deutsch zu analysieren.

📋 **SCHRITT-FÜR-SCHRITT ANALYSE-SCHEMA:**

**1. SATZSTRUKTUR-ANALYSE**
   • Satztyp bestimmen (Hauptsatz / Nebensatz / zusammengesetzter Satz)
   • Wortstellung überprüfen:
     - Hauptsatz: V2-Position (Verb an 2. Stelle?)
     - Nebensatz: Verb am Ende? (nach weil, dass, ob, als, wenn usw.)
   • Korrekte Struktur und eventuelle Fehler erklären

**2. SUBJEKT-ANALYSE**
   • Subjekt identifizieren
   • Eigenschaften des Subjekts erklären (Person, Singular/Plural, Genus)
   • Fehler beim Subjekt korrigieren

**3. VERB-ANALYSE**
   • Infinitiv des Verbs bestimmen
   • Konjugation für die gewählte Zeit überprüfen
   • Subjekt-Verb-Kongruenz kontrollieren
   • Hilfsverb-Verwendung überprüfen (haben/sein/werden)
   • Korrekte Konjugation erklären

**4. OBJEKT- UND KASUS-ANALYSE**
   • Objekte im Satz identifizieren
   • Kasus jedes Objekts überprüfen (Nominativ/Akkusativ/Dativ)
   • Welchen Kasus verlangt das Verb? (z.B.: helfen → Dativ)
   • Ist die Artikelverwendung korrekt? (der/die/das, den/die/das, dem/der/dem)
   • Fehler korrigieren und erklären

**5. ZEIT-ANALYSE**
   • Gewählte Zeit: ${_selectedTime ?? 'Present'}
   • Ist die erforderliche Struktur für diese Zeit verwendet?
   • Perfekt: haben/sein + Partizip II
   • Präteritum: Vergangenheitskonjugation
   • Futur: werden + Infinitiv
   • Fehler korrigieren

**6. GESAMTBEWERTUNG**
   • Ist der Satz semantisch korrekt?
   • Was bedeutet der Satz?
   • Gesamtnote: ⭐⭐⭐⭐⭐ (von 5 Sternen)

**7. VORSCHLÄGE**
   3-5 Vorschläge zur Verbesserung des Satzes:
   • Neue Wörter
   • Nebensatz-Beispiele
   • Alternative Strukturen

**Beispiel-Analyse:**
Satz: "Ich habe gestern einen Apfel"
Zeit: Perfekt

1️⃣ SATZSTRUKTUR: Hauptsatz (V2-Position korrekt) ✓
2️⃣ SUBJEKT: "Ich" (1. Person Singular) ✓
3️⃣ VERB: "haben" korrekt konjugiert (habe) ✓
4️⃣ OBJEKT: "einen Apfel" (Akkusativ, maskulin) ✓
5️⃣ ZEIT: ❌ FEHLER! Partizip II fehlt für Perfekt
   → Richtig: "Ich habe gestern einen Apfel **gegessen**"
   → Erklärung: Perfekt = haben/sein + Partizip II
6️⃣ BEWERTUNG: Satz zu 70% korrekt, nur Partizip fehlt
   Bedeutung: "Ich habe gestern einen Apfel gegessen"
   Note: ⭐⭐⭐⭐☆
7️⃣ VORSCHLÄGE: gegessen, gekauft, weil ich Hunger hatte, mit Genuss

---

📝 **ZU ANALYSIERENDER SATZ:**
"$constructedSentence"

⏰ **GEWÄHLTE ZEIT:** ${_selectedTime ?? 'Present'}

---

Jetzt werde ich diesen Satz mit dem 7-Schritte-Schema detailliert analysieren. Ich erkläre jeden Schritt klar und verständlich auf Deutsch. Los geht's! 🎓""";

    try {
      print('Gemini API çağrısı yapılıyor... Model: gemini-2.5-flash (2025 en yeni!)'); // Debug
      
      final content = [Content.text(prompt)];
      
      // Safety settings ekle - eğitim amaçlı içerik için
      final safetySettings = [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ];
      
      final response = await model.generateContent(
        content,
        safetySettings: safetySettings,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 3000, // Detaylı analiz için artırıldı (1000 → 3000)
        ),
      ).timeout(const Duration(seconds: 45)); // Detaylı analiz için timeout artırıldı (30→45 saniye)

      // GÜÇLÜ YANIT PARSE MEKANIZMASI
      print('API yanıtı alındı. Güvenli parse başlıyor...'); // Debug
      
      // 1. Candidates kontrolü
      if (response.candidates.isEmpty) {
        print('⚠️ Candidates listesi boş'); // Debug
        if (response.promptFeedback != null) {
          print('Prompt feedback: ${response.promptFeedback}'); // Debug
          return '⚠️ Der Inhalt wurde vom Sicherheitsfilter blockiert.\n\nGrund: ${response.promptFeedback?.blockReason ?? "Unbekannt"}\n\nLösung: Versuche einen einfacheren Satz zu bilden.';
        }
        return '⚠️ API hat keine Antwort gegeben. Versuche es mit anderen Wörtern.';
      }
      
      final candidate = response.candidates.first;
      print('Finish reason: ${candidate.finishReason}'); // Debug
      print('Parts sayısı: ${candidate.content.parts.length}'); // Debug
      
      // 2. Finish reason kontrolü
      if (candidate.finishReason == FinishReason.safety || 
          candidate.finishReason == FinishReason.recitation) {
        return '⚠️ Antwort aus Sicherheitsgründen blockiert.\n\nGrund: ${candidate.finishReason}\n\nLösung: Versuche eine andere Satzstruktur.';
      }
      
      // 3. Parts'ı doğrudan TextPart olarak parse et (GÜVENLI YÖNTEM)
      try {
        if (candidate.content.parts.isNotEmpty) {
          for (var part in candidate.content.parts) {
            print('Part tipi: ${part.runtimeType}'); // Debug
            
            if (part is TextPart) {
              final textPart = part as TextPart;
              if (textPart.text.isNotEmpty) {
                print('✅ TextPart ile yanıt alındı (${textPart.text.length} karakter)'); // Debug
                return textPart.text;
              }
            }
          }
        }
        print('⚠️ Hiçbir TextPart bulunamadı'); // Debug
      } catch (parseError) {
        print('⚠️ TextPart parse hatası: $parseError'); // Debug
      }
      
      // 4. Son çare: response.text ile dene (try-catch ile)
      try {
        final text = response.text;
        if (text != null && text.isNotEmpty) {
          print('✅ response.text ile yanıt alındı'); // Debug
          return text;
        }
      } catch (responseTextError) {
        print('⚠️ response.text hatası: $responseTextError'); // Debug
      }
      
      // 5. Hiçbir şey çalışmadıysa
      print('❌ Tüm parse yöntemleri başarısız oldu'); // Debug
      return "⚠️ API hat geantwortet, aber der Text konnte nicht gelesen werden.\n\nFinish reason: ${candidate.finishReason}\nParts: ${candidate.content.parts.length}\n\nBitte versuche es erneut oder wähle andere Wörter.";
    } on TimeoutException {
      return '⚠️ Zeitüberschreitung (45 Sekunden).\n\nMögliche Ursachen:\n• Langsame Internetverbindung\n• API-Server ist ausgelastet\n\nLösung: Versuche es erneut oder bilde einen kürzeren Satz.';
    } on FormatException catch (e) {
      print('🔴 FormatException: $e'); // Debug
      return '⚠️ Antwortformat-Fehler!\n\nMögliche Ursachen:\n• API-Antwort nicht im erwarteten Format\n• Inhalt vom Sicherheitsfilter blockiert\n• Neuer API-Schlüssel? Warte 2-3 Minuten\n\nLösung: Versuche es mit anderen Wörtern.';
    } catch (e) {
      print('Gemini API hatası: $e'); // Debug
      print('Hata tipi: ${e.runtimeType}'); // Hata tipini göster
      
      // Hata türüne göre kullanıcı dostu mesajlar
      final errorMsg = e.toString().toLowerCase();
      
      if (errorMsg.contains('api_key') || errorMsg.contains('invalid') || errorMsg.contains('401') || errorMsg.contains('403')) {
        return '⚠️ API-Schlüssel ungültig oder nicht autorisiert.\n\nLösung:\n1. Wenn der Schlüssel neu ist, warte 2-3 Minuten\n2. Überprüfe, ob der Schlüssel aktiv ist\n3. Neuer API-Schlüssel: https://makersuite.google.com/app/apikey';
      } else if (errorMsg.contains('quota') || errorMsg.contains('429') || errorMsg.contains('resource_exhausted')) {
        return '⚠️ API-Kontingent überschritten.\n\nLösung:\n1. Warte 1-2 Stunden\n2. Versuche einen anderen API-Schlüssel';
      } else if (errorMsg.contains('model') || errorMsg.contains('404') || errorMsg.contains('not found')) {
        return '⚠️ Modell nicht gefunden.\n\nModell: gemini-2.5-flash\n\nLösung: Schließe die App vollständig und öffne sie erneut.';
      } else if (errorMsg.contains('network') || errorMsg.contains('connection') || errorMsg.contains('socket')) {
        return '⚠️ Internetverbindungsproblem.\n\nLösung:\n1. Überprüfe deine WLAN/Mobilfunkverbindung\n2. Deaktiviere VPN falls aktiv';
      } else if (errorMsg.contains('blocked') || errorMsg.contains('safety') || errorMsg.contains('recitation')) {
        return '⚠️ Inhalt vom Sicherheitsfilter blockiert.\n\nLösung: Versuche andere Wörter oder einen einfacheren Satz.';
      } else if (errorMsg.contains('format')) {
        return '⚠️ Datenformat-Fehler.\n\nDetails: $e\n\nLösung:\n1. Starte die App neu\n2. Überprüfe den API-Schlüssel\n3. Überprüfe die Internetverbindung';
      } else {
        return '⚠️ Unerwarteter Fehler:\n\nFehler: ${e.runtimeType}\nDetails: $e\n\nLösung:\n1. Starte die App neu\n2. Überprüfe den API-Schlüssel\n3. Versuche einen anderen API-Schlüssel';
      }
    }
  }

  // Manuel olarak Mari'ye sorma fonksiyonu (butona basınca çalışacak)
  Future<void> _askMari() async {
    final sentence = _getCurrentSentenceText();
    
    if (sentence.trim().isEmpty) {
      setState(() {
        _currentFeedback = "⚠️ Bitte bilde zuerst einen Satz!\n\nWähle Wörter wie Subjekt, Verb usw. und drücke dann auf 'An Mari'. 🎯";
      });
      return;
    }

    setState(() {
      _isLoadingFeedback = true;
      _currentFeedback = "Mari analysiert deinen Satz detailliert... ⏳\n\nDies kann 30-45 Sekunden dauern. Bitte warte einen Moment! 😊";
    });

    print('_askMari çağrıldı. Cümle: $sentence'); // Debug print

    try {
      final feedback = await _getGeminiFeedback(sentence);
      
      setState(() {
        _currentFeedback = feedback;
        _isLoadingFeedback = false;
      });

      // Önerileri ayrıştır (opsiyonel - kelime listesine eklemek için)
      List<String>? rawSuggestions;
      print('RegExp ile öneriler ayrıştırılıyor...'); // Debug print
      final RegExp suggestionRegExp = RegExp(r'Öneriler: (.*?)(?=\n|$)');
      final Match? match = suggestionRegExp.firstMatch(_currentFeedback);

      if (match != null) {
        final String suggestionsText = match.group(1)!;
        rawSuggestions = suggestionsText.split(', ').map((s) => s.split(' (').first).toList();
        print('Ayrıştırılan öneriler: $rawSuggestions'); // Debug print
      }

      _filterWords(aiSuggestedTexts: rawSuggestions);

      print('_askMari tamamlandı.'); // Debug print
    } catch (e) {
      setState(() {
        _currentFeedback = "⚠️ Ein Fehler ist aufgetreten: $e\n\nBitte versuche es erneut. 🔄";
        _isLoadingFeedback = false;
      });
    }
  }

  String _getConjugatedVerb(Word verb, Word pronoun, String tense) {
    if (verb.properties == null || pronoun.properties == null) return verb.text;

    final conjugations = verb.properties!['conjugations'] as Map<String, dynamic>?;
    if (conjugations == null || !conjugations.containsKey(tense)) return verb.text;

    final tenseConjugations = conjugations[tense] as Map<String, String>;
    final person = pronoun.properties!['person'];
    final number = pronoun.properties!['number'];
    final gender = pronoun.properties!['gender'];
    final isFormal = pronoun.properties!['isFormal'];

    // Özneye göre çekimi bul
    String subjectKey = '';
    if (person == '1st' && number == 'singular') subjectKey = 'ich';
    else if (person == '2nd' && number == 'singular') subjectKey = 'du';
    else if (person == '3rd' && number == 'singular') {
      if (gender == 'masculine' || gender == 'feminine' || gender == 'neuter') {
        subjectKey = 'er/sie/es';
      }
    }
    else if (person == '1st' && number == 'plural') subjectKey = 'wir';
    else if (person == '2nd' && number == 'plural') subjectKey = 'ihr';
    else if (person == '3rd' && number == 'plural') {
      if (isFormal == true) {
        subjectKey = 'sie/Sie'; // Formal Sie
      } else {
        subjectKey = 'sie/Sie'; // informal sie
      }
    }

    return tenseConjugations[subjectKey] ?? verb.text;
  }

  void _filterWords({List<String>? aiSuggestedTexts}) {
    print('_filterWords çağrıldı. AI önerileri: ${aiSuggestedTexts ?? 'null'}'); // Debug print, null kontrolü eklendi
    // Bu fonksiyonun önceki karmaşık filtreleme mantığı artık _getPossibleX metodları tarafından yönetiliyor.
    // Sadece AI önerilerini işleyen kısmı burada kalacak.

    // Yapay zeka önerilerini mevcut kelimelere ekle
    if (aiSuggestedTexts != null && aiSuggestedTexts.isNotEmpty) {
      print('Yapay zeka önerileri işleniyor...'); // Debug print
      for (String suggestionText in aiSuggestedTexts) {
        // Eğer öneri kelimesi _allWords içinde (herhangi bir type ile) zaten yoksa, yeni bir Word objesi olarak ekle
        if (!_allWords.any((word) => word.text == suggestionText)) {
          _allWords.add(Word(text: suggestionText, type: 'suggestion')); // Yeni kelime olarak eklendi
          print('Eklendi (yeni AI önerisi): $suggestionText'); // Debug print
        } else {
          print('AI önerisi mevcut kelimelerde zaten var: $suggestionText');
        }
      }
      print('Yapay zeka önerileri _allWords listesine eklendi. Toplam kelime: ${_allWords.length}'); // Debug print
    }
    // _availableWords listesi artık UI tarafından kullanılmıyor, bu yüzden güncellemeyi kaldırdık.
    // Bu fonksiyon çağrıldığında, sadece AI önerilerini işler.
  }

  // Yerel kural tabanlı _giveFeedback metodunu kaldırıyorum
  /*
  String _giveFeedback() {
    if (_currentSentence.isEmpty) {
      return 'Cümle kurmaya başlayın!';
    }

    final Word? subjectPronoun = _currentSentence.cast<Word?>().firstWhere(
        (word) => word?.type == 'pronoun' && word?.case_ == 'nominative',
        orElse: () => null
    );
    final Word? mainVerb = _currentSentence.cast<Word?>().firstWhere(
        (word) => word?.type == 'verb' && (word?.infinitive != 'haben' && word?.infinitive != 'sein'),
        orElse: () => null
    );
    final Word? auxiliaryVerb = _currentSentence.cast<Word?>().firstWhere(
        (word) => word?.type == 'verb' && (word?.infinitive == 'haben' || word?.infinitive == 'sein'),
        orElse: () => null
    );
    final Word? participle = _currentSentence.cast<Word?>().firstWhere(
        (word) => word?.type == 'participle',
        orElse: () => null
    );

    // Cümlede özne yoksa
    if (subjectPronoun == null) {
      return 'Cümlede bir özne (nominatif zamir veya isim) bulunmalıdır.';
    }

    // Perfekt/Plusquamperfekt zamanı kontrolleri
    if (_selectedTime == 'Perfekt' || _selectedTime == 'Plusquamperfekt') {
      if (auxiliaryVerb == null) {
        return 'Perfekt/Plusquamperfekt cümlede bir yardımcı fiil (haben/sein) olmalı.';
      }
      if (participle == null) {
        return 'Perfekt/Plusquamperfekt cümlede bir partisip olmalı.';
      }

      // Yardımcı fiil çekim kontrolü
      if (auxiliaryVerb != null && subjectPronoun != null) {
        final expectedAuxiliary = _getConjugatedVerb(auxiliaryVerb, subjectPronoun, 'Präsens');
        if (auxiliaryVerb.text != expectedAuxiliary) {
          return 'Yardımcı fiil çekimi yanlış. \'${subjectPronoun.text}\' için doğru çekim \'${expectedAuxiliary}\' olmalıydı.';
        }
      }

      // Partisip ve yardımcı fiil uyumu
      if (participle != null && auxiliaryVerb != null) {
        if (participle.auxiliary != auxiliaryVerb.infinitive) {
          return '\'${participle.text}\' partisipi \'${participle.auxiliary}\' yardımcı fiilini gerektirir, ancak siz \'${auxiliaryVerb.infinitive}\' kullandınız.';
        }
      }

      // Partisipin sonda olma kontrolü
      if (participle != null && _currentSentence.last != participle) {
        return 'Perfekt veya Plusquamperfekt zamanlarında partisip cümle sonunda olmalı.';
      }

      // Eğer bir ana fiil varsa (mastar haliyle), bu zaman için gereksizdir
      if (mainVerb != null) {
        return 'Perfekt/Plusquamperfekt cümlede ana fiil (mastar hali) bulunmamalıdır.';
      }

    } else { // Präsens veya Präteritum için
      if (mainVerb == null) {
        return 'Bu zaman için cümlede bir ana fiil olmalı.';
      }
      if (mainVerb != null && subjectPronoun != null) {
        final expectedVerb = _getConjugatedVerb(mainVerb, subjectPronoun, _selectedTime ?? 'Präsens');
        if (mainVerb.text != expectedVerb) {
          return 'Fiil çekimi yanlış. \'${subjectPronoun.text}\' için \'${_selectedTime ?? 'Präsens'}\' zamanında \'${mainVerb.infinitive}\' fiilinin doğru çekimi \'${expectedVerb}\' olmalıydı.';
        }
      }
      // Eğer yardımcı fiil veya partisip varsa, bu zamanlar için gereksizdir
      if (auxiliaryVerb != null || participle != null) {
        return 'Bu zaman için yardımcı fiil veya partisip bulunmamalıdır.';
      }
    }

    // Fiil-nesne uyumu (transitive fiiller için)
    for (int i = 0; i < _currentSentence.length; i++) {
      final word = _currentSentence[i];
      if (word.type == 'verb' && word.transitive == true && word.objectCase != null) {
        // Bu fiilden sonra beklenen nesneyi bulmaya çalış
        final objectCandidate = _currentSentence.skip(i + 1).cast<Word?>().firstWhere(
            (w) => (w?.type == 'noun' || (w?.type == 'pronoun' && w?.case_ != 'nominative')) && w?.case_ == word.objectCase,
            orElse: () => null
        );
        if (objectCandidate == null) {
          return '\'${word.text}\' fiili bir \'${word.objectCase}\' nesnesi gerektiriyor.';
        }
      }
    }

    // Makale-isim uyumu kontrolü (basit bir başlangıç)
    for (int i = 0; i < _currentSentence.length; i++) {
      final word = _currentSentence[i];
      if (word.type == 'noun' && word.article != null) {
        // Eğer isim bir makale ile birlikteyse, makale doğru mu kontrol et
        // Basit bir kontrol: sadece kelime metninin doğru makaleyi içerip içermediği
        if (!word.text.startsWith(word.article!)) {
          return '\'${word.text}\' için makale yanlış olabilir. Doğru makale \'${word.article}\' olmalıydı.';
        }
      }
    }

    // Basit kelime sırası kontrolü (özne, fiil, nesne)
    // Bu, daha fazla geliştirme gerektiren basit bir başlangıçtır.
    final int? subjectIndex = _currentSentence.indexOf(subjectPronoun ?? Word(text: '', type: '')); // eğer bulunamazsa -1 döner
    final int? verbIndex = _currentSentence.indexOf(mainVerb ?? auxiliaryVerb ?? Word(text: '', type: ''));

    if (subjectIndex != -1 && verbIndex != -1) {
      if (_selectedTime != 'Perfekt' && _selectedTime != 'Plusquamperfekt') { // V2 kelime sırası sadece Präsens/Präteritum için
        if (verbIndex != 1) {
          return 'Ana cümlelerde fiil genellikle ikinci pozisyonda olmalıdır.';
        }
      }
    }

    return 'Harika! Cümle doğru görünüyor.';
  }
  */

  // Yeni yardımcı metodlar
  Widget _buildDropdown({
    required String hintText,
    required Word? value,
    required List<Word> options,
    required ValueChanged<Word?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              hintText,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF192233),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF324467),
                width: 1,
              ),
            ),
            child: DropdownButtonFormField<Word>(
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              dropdownColor: const Color(0xFF192233),
              value: value,
              onChanged: onChanged,
              hint: Text(
                hintText,
                style: GoogleFonts.lexend(
                  color: const Color(0xFF92a4c9),
                  fontSize: 14,
                ),
              ),
              style: GoogleFonts.lexend(
                color: Colors.white,
                fontSize: 14,
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF92a4c9),
              ),
              items: options.map<DropdownMenuItem<Word>>((Word word) {
                return DropdownMenuItem<Word>(
                  value: word,
                  child: Text(
                    word.text,
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Word> _getPossibleSubjects() {
    return _allWords.where((word) =>
        (word.type == 'pronoun' && word.case_ == 'nominative') ||
        (word.type == 'noun' && word.case_ == 'nominative')
    ).map((word) {
      // İsimse, makale ile birleştir ve 3. tekil şahıs özelliklerini ekle
      String displayText = word.text;
      if (word.type == 'noun' && word.article != null) {
        displayText = '${word.article!} ${word.text}';
      }
      // Orijinal özelliklerini koruyarak yeni bir Word nesnesi oluştur
      return Word(
        text: displayText,
        type: word.type,
        properties: Map<String, dynamic>.from(word.properties)
          ..['person'] = (word.type == 'noun' ? '3rd' : word.person)
          ..['number'] = (word.type == 'noun' ? 'singular' : word.number),
      );
    }).toList();
  }

  List<Word> _getPossibleAuxiliaryVerbs() {
    // Tüm yardımcı fiilleri döndür, filtreleme yok
    return _allWords.where((word) =>
        word.type == 'verb' && (word.infinitive == 'haben' || word.infinitive == 'sein' || word.infinitive == 'werden')
    ).map((verb) {
      // Yardımcı fiilleri özne seçimine göre çekimle
      String conjugatedText = verb.text; // Varsayılan olarak mastar hali
      if (_selectedSubject != null) {
        conjugatedText = _getConjugatedVerb(verb, _selectedSubject!, 'Präsens'); // Yardımcı fiiller hep Präsens olarak çekimlenir
      }
      return Word(text: conjugatedText, type: verb.type, properties: Map<String, dynamic>.from(verb.properties)..['infinitive'] = verb.infinitive);
    }).toList();
  }

  List<Word> _getPossibleMainVerbs() {
    if (_selectedSubject == null) return [];

    // Tüm ana fiilleri döndür ve özneye göre çekimle
    return _allWords.where((word) =>
        word.type == 'verb' && word.infinitive != 'haben' && word.infinitive != 'sein' && word.infinitive != 'werden'
    ).map((verb) {
      String conjugatedText = verb.text; // Varsayılan olarak mastar hali
      
      if (_selectedTime == 'Future') {
        conjugatedText = verb.infinitive!; // Gelecek zamanda mastar hali
      } else if (_selectedSubject != null && _selectedTime != null) {
        // Präsens veya Präteritum için özneye göre çekimle
        String tenseKey = _selectedTime == 'Präteritum' ? 'Präteritum' : 'Präsens';
        conjugatedText = _getConjugatedVerb(verb, _selectedSubject!, tenseKey);
      }
      
      return Word(text: conjugatedText, type: verb.type, properties: Map<String, dynamic>.from(verb.properties ?? {})..['infinitive'] = verb.infinitive);
    }).toList();
  }

  List<Word> _getPossibleParticiples() {
    // Tüm partisipleri döndür, filtreleme yok
    return _allWords.where((word) => word.type == 'participle').toList();
  }

  List<Word> _getPossibleObjects() {
    // Tüm akuzatif ve datif isimleri döndür, filtreleme yok
    return _allWords.where((word) =>
        word.type == 'noun' && (word.case_ == 'accusative' || word.case_ == 'dative')
    ).map((word) => Word(
        text: word.text,
        type: word.type,
        properties: Map<String, dynamic>.from(word.properties)
    )).toList();
  }

  List<Word> _getPossibleAdverbs() {
    // Tüm zarfları döndür, filtreleme yok
    return _allWords.where((word) => word.type == 'adverb').toList();
  }

  // Nesne zamirleri için seçenekler
  List<Word> _getPossibleObjectPronouns() {
    // Tüm akuzatif ve datif zamirleri döndür, filtreleme yok
    return _allWords.where((word) =>
        word.type == 'pronoun' && (word.case_ == 'accusative' || word.case_ == 'dative')
    ).toList();
  }

  List<Word> _getPossibleConjunctions() {
    // Tüm bağlaçları döndür, filtreleme yok
    return _allWords.where((word) => word.type == 'conjunction').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101622),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Mari's avatar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB9o9iKhf7HxgBx5O-UDqu3ROLmvtIK66QTCYFGe2Epl-bBo0HDf3OQRnrJQnUOYMZlh1wKTIn00idt4LS7LtcUIigVyo08HkNmrlhIrKq_1M3CMbPXT_m1xcQlgmNlcEMWiu25hItqVrmw_7-pUa8cVAnofnB2W0C2wgGtZZi7kBTtpVB1Gjs64AzpQCKAcq5nqZD82a4Z4OFUDHMpir3b2eA1vcQIuqHVA21kn831CHHYRWm61yVXa0PBtftrg77OrEYtN_BuFHk'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Deutsch Lernen mit Mari',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Sentence Display Area
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF192233),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getCurrentSentenceText().isEmpty ? 'Baue hier deinen Satz... ✨' : _getCurrentSentenceText(),
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          // Yeni cümle kurma arayüzü
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Zaman seçimi
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Zeitform',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF192233),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF324467),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            dropdownColor: const Color(0xFF192233),
                            value: _selectedTime,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedTime = newValue;
                                _filterWords();
                                // _updateFeedback() kaldırıldı
                              });
                            },
                            hint: Text(
                              'Zeitform wählen',
                              style: GoogleFonts.lexend(
                                color: const Color(0xFF92a4c9),
                                fontSize: 14,
                              ),
                            ),
                            style: GoogleFonts.lexend(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF92a4c9),
                            ),
                            items: _times.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: GoogleFonts.lexend(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Özne seçimi
                  _buildDropdown( // Yeni yardımcı metodu çağır
                    hintText: 'Subjekt',
                    value: _selectedSubject, 
                    options: _getPossibleSubjects(), 
                    onChanged: (Word? newValue) {
                      setState(() {
                        _selectedSubject = newValue;
                        _filterWords(); // Seçim değiştiğinde kelimeleri filtrele
                        // _updateFeedback() kaldırıldı - sadece butona basınca çağrılacak
                      });
                    },
                  ),
                  // Yardımcı Fiil seçimi (zamanlara göre görünür olacak)
                  _buildDropdown(
                      hintText: 'Hilfsverb',
                      value: _selectedAuxiliaryVerb,
                      options: _getPossibleAuxiliaryVerbs(),
                      onChanged: (Word? newValue) {
                        setState(() {
                          _selectedAuxiliaryVerb = newValue;
                          _filterWords();
                          // _updateFeedback() kaldırıldı
                        });
                      },
                    ),
                  // Ana Fiil seçimi
                  _buildDropdown(
                    hintText: 'Verb',
                    value: _selectedMainVerb,
                    options: _getPossibleMainVerbs(),
                    onChanged: (Word? newValue) {
                      setState(() {
                        _selectedMainVerb = newValue;
                        _filterWords();
                        // _updateFeedback() kaldırıldı
                      });
                    },
                  ),
                  // Zarflar - fiilden hemen sonra
                   _buildDropdown(
                    hintText: 'Adverb',
                    value: _selectedAdverbs.isNotEmpty ? _selectedAdverbs.first : null,
                    options: _getPossibleAdverbs(),
                    onChanged: (Word? newValue) {
                      setState(() {
                        _selectedAdverbs = newValue != null ? [newValue] : [];
                        _filterWords();
                        // _updateFeedback() kaldırıldı
                      });
                    },
                  ),
                  // Nesne Zamiri Seçimi
                  _buildDropdown(
                    hintText: 'Objektpronomen',
                    value: _selectedObjectPronoun,
                    options: _getPossibleObjectPronouns(),
                    onChanged: (Word? newValue) {
                      setState(() {
                        _selectedObjectPronoun = newValue;
                        _filterWords();
                        // _updateFeedback() kaldırıldı
                      });
                    },
                  ),
                  // Nesne Seçimi
                  _buildDropdown(
                    hintText: 'Objekt',
                    value: _selectedObjects.isNotEmpty ? _selectedObjects.first : null,
                    options: _getPossibleObjects(),
                    onChanged: (Word? newValue) {
                      setState(() {
                        _selectedObjects = newValue != null ? [newValue] : [];
                        _filterWords();
                        // _updateFeedback() kaldırıldı
                      });
                    },
                  ),
                  // Partisip seçimi (Perfekt zamanı için) - cümle sonunda
                  _buildDropdown(
                      hintText: 'Partizip II',
                      value: _selectedParticiple,
                      options: _getPossibleParticiples(),
                      onChanged: (Word? newValue) {
                        setState(() {
                          _selectedParticiple = newValue;
                          _filterWords();
                          // _updateFeedback() kaldırıldı
                        });
                      },
                    ),
                  // Bağlaç Seçimi
                  _buildDropdown(
                    hintText: 'Konjunktion',
                    value: _selectedConjunction,
                    options: _getPossibleConjunctions(),
                    onChanged: (Word? newValue) {
                      setState(() {
                        _selectedConjunction = newValue;
                        _filterWords();
                        // _updateFeedback() kaldırıldı
                      });
                    },
                  ),
                  
                  // Yan cümle bölümü - Bağlaç seçildiğinde göster
                  if (_selectedConjunction != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFF324467),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'Nebensatz',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF135bec),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFF324467),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Yan cümle özne seçimi
                    _buildDropdown(
                      hintText: 'Subjekt (Nebensatz)',
                      value: _subClauseSubject,
                      options: _getPossibleSubjects(),
                      onChanged: (Word? newValue) {
                        setState(() {
                          _subClauseSubject = newValue;
                          _filterWords();
                          // _updateFeedback() kaldırıldı
                        });
                      },
                    ),
                    // Yan cümle yardımcı fiil
                    _buildDropdown(
                      hintText: 'Hilfsverb (Nebensatz)',
                      value: _subClauseAuxiliaryVerb,
                      options: _getPossibleAuxiliaryVerbs(),
                      onChanged: (Word? newValue) {
                setState(() {
                          _subClauseAuxiliaryVerb = newValue;
                          _filterWords();
                          // _updateFeedback() kaldırıldı
                });
            },
                    ),
                    // Yan cümle ana fiil
                    _buildDropdown(
                      hintText: 'Verb (Nebensatz)',
                      value: _subClauseMainVerb,
                      options: _subClauseSubject != null ? _allWords.where((word) =>
                          word.type == 'verb' && word.infinitive != 'haben' && word.infinitive != 'sein' && word.infinitive != 'werden'
                      ).map((verb) {
                        String conjugatedText = verb.text;
                        if (_selectedTime == 'Future') {
                          conjugatedText = verb.infinitive!;
                        } else if (_subClauseSubject != null && _selectedTime != null) {
                          String tenseKey = _selectedTime == 'Präteritum' ? 'Präteritum' : 'Präsens';
                          conjugatedText = _getConjugatedVerb(verb, _subClauseSubject!, tenseKey);
                        }
                        return Word(text: conjugatedText, type: verb.type, properties: Map<String, dynamic>.from(verb.properties ?? {})..['infinitive'] = verb.infinitive);
                      }).toList() : [],
                      onChanged: (Word? newValue) {
                        setState(() {
                          _subClauseMainVerb = newValue;
                          _filterWords();
                          // _updateFeedback() kaldırıldı
                        });
                      },
                    ),
                    // Yan cümle partisip
                    _buildDropdown(
                      hintText: 'Partizip II (Nebensatz)',
                      value: _subClauseParticiple,
                      options: _getPossibleParticiples(),
                      onChanged: (Word? newValue) {
                        setState(() {
                          _subClauseParticiple = newValue;
                          _filterWords();
                          // _updateFeedback() kaldırıldı
                        });
                      },
                    ),
                    // Yan cümle nesne
                    _buildDropdown(
                      hintText: 'Objekt (Nebensatz)',
                      value: _subClauseObjects.isNotEmpty ? _subClauseObjects.first : null,
                      options: _getPossibleObjects(),
                      onChanged: (Word? newValue) {
                        setState(() {
                          _subClauseObjects = newValue != null ? [newValue] : [];
                          _filterWords();
                          // _updateFeedback() kaldırıldı
                        });
                      },
                    ),
                    // Yan cümle nesne zamiri
                    _buildDropdown(
                      hintText: 'Objektpronomen (Nebensatz)',
                      value: _subClauseObjectPronoun,
                      options: _getPossibleObjectPronouns(),
                      onChanged: (Word? newValue) {
                        setState(() {
                          _subClauseObjectPronoun = newValue;
                          _filterWords();
                          // _updateFeedback() kaldırıldı
                        });
                      },
                    ),
                    // Yan cümle zarf
                    _buildDropdown(
                      hintText: 'Adverb (Nebensatz)',
                      value: _subClauseAdverbs.isNotEmpty ? _subClauseAdverbs.first : null,
                      options: _getPossibleAdverbs(),
                      onChanged: (Word? newValue) {
                        setState(() {
                          _subClauseAdverbs = newValue != null ? [newValue] : [];
                          _filterWords();
                          // _updateFeedback() kaldırıldı
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Mari'ye Sor Butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoadingFeedback ? null : _askMari,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF135bec),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF135bec).withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isLoadingFeedback 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 24),
                label: Text(
                  _isLoadingFeedback ? 'Mari analysiert...' : 'An Mari',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          
          // AI Feedback Card
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF192233),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF135bec).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF135bec).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF135bec),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Maris Analyse",
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: SingleChildScrollView(
                    child: Text(
                      _currentFeedback,
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        height: 1.5,
                        color: const Color(0xFFd1d5db),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearSentence,
        tooltip: 'Satz löschen', // zaten Almanca
        backgroundColor: const Color(0xFF135bec),
        child: const Icon(Icons.clear, color: Colors.white),
      ),
    );
  }
}
