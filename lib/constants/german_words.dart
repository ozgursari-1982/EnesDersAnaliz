import '../models/word.dart';

/// Almanca cümle kurucu için sabit değerler
/// Bu dosya tüm Almanca kelime listelerini ve uygulama sabitlerini içerir

class AppConstants {
  // Zamanlar (Zeitformen)
  static const List<String> times = [
    'Present',
    'Perfekt',
    'Präteritum',
    'Future',
  ];

  // Başlangıç mesajı
  static const String initialFeedback = 
      "Hallo! 👋 Ich bin Mari, deine Deutsch-Lehrerin!\n\n"
      "Baue zuerst deinen Satz mit den Wörtern oben, dann drücke auf den Button 'An Mari'.\n\n"
      "Ich analysiere dann deinen Satz Schritt für Schritt! 🎓";
}

/// Almanca kelime listeleri
/// Tüm zamir, fiil, isim, zarf ve bağlaçlar
class GermanWords {
  // Zamirler (Pronouns)
  static final List<Word> pronouns = [
    Word(text: 'Ich', type: 'pronoun', properties: {'person': '1st', 'number': 'singular', 'case': 'nominative'}),
    Word(text: 'Du', type: 'pronoun', properties: {'person': '2nd', 'number': 'singular', 'case': 'nominative'}),
    Word(text: 'Er', type: 'pronoun', properties: {'person': '3rd', 'number': 'singular', 'gender': 'masculine', 'case': 'nominative'}),
    Word(text: 'Sie', type: 'pronoun', properties: {'person': '3rd', 'number': 'singular', 'gender': 'feminine', 'case': 'nominative'}),
    Word(text: 'Es', type: 'pronoun', properties: {'person': '3rd', 'number': 'singular', 'gender': 'neuter', 'case': 'nominative'}),
    Word(text: 'Wir', type: 'pronoun', properties: {'person': '1st', 'number': 'plural', 'case': 'nominative'}),
    Word(text: 'Ihr', type: 'pronoun', properties: {'person': '2nd', 'number': 'plural', 'case': 'nominative'}),
    Word(text: 'Sie', type: 'pronoun', properties: {'person': '3rd', 'number': 'plural', 'case': 'nominative', 'isFormal': true}), // Formal Sie
    Word(text: 'sie', type: 'pronoun', properties: {'person': '3rd', 'number': 'plural', 'case': 'nominative', 'isFormal': false}), // informal sie
    // Akuzatif zamirler
    Word(text: 'mich', type: 'pronoun', properties: {'person': '1st', 'number': 'singular', 'case': 'accusative'}),
    Word(text: 'dich', type: 'pronoun', properties: {'person': '2nd', 'number': 'singular', 'case': 'accusative'}),
  ];

  // Fiiller (Verbs)
  static final List<Word> verbs = [
    Word(text: 'haben', type: 'verb', properties: {
      'infinitive': 'haben',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'general',
      'conjugations': {
        'Präsens': {'ich': 'habe', 'du': 'hast', 'er/sie/es': 'hat', 'wir': 'haben', 'ihr': 'habt', 'sie/Sie': 'haben'},
        'Präteritum': {'ich': 'hatte', 'du': 'hattest', 'er/sie/es': 'hatte', 'wir': 'hatten', 'ihr': 'hattet', 'sie/Sie': 'hatten'},
        'Perfekt': {'ich': 'habe', 'du': 'hast', 'er/sie/es': 'hat', 'wir': 'haben', 'ihr': 'habt', 'sie/Sie': 'haben'}
      }
    }),
    Word(text: 'sein', type: 'verb', properties: {
      'infinitive': 'sein',
      'transitive': false,
      'objectCategory': 'state_movement',
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
    Word(text: 'werden', type: 'verb', properties: {
      'infinitive': 'werden',
      'objectCategory': 'future_event',
      'conjugations': {
        'Präsens': {'ich': 'werde', 'du': 'wirst', 'er/sie/es': 'wird', 'wir': 'werden', 'ihr': 'werdet', 'sie/Sie': 'werden'},
        'Präteritum': {'ich': 'wurde', 'du': 'wurdest', 'er/sie/es': 'wurde', 'wir': 'wurden', 'ihr': 'wurdet', 'sie/Sie': 'wurden'}
      }
    }),
    Word(text: 'sehen', type: 'verb', properties: {
      'infinitive': 'sehen',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'general_object',
      'conjugations': {
        'Präsens': {'ich': 'sehe', 'du': 'siehst', 'er/sie/es': 'sieht', 'wir': 'sehen', 'ihr': 'seht', 'sie/Sie': 'sehen'},
        'Präteritum': {'ich': 'sah', 'du': 'sahst', 'er/sie/es': 'sah', 'wir': 'sahen', 'ihr': 'saht', 'sie/Sie': 'sahen'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gesehen'}
      }
    }),
    Word(text: 'kaufen', type: 'verb', properties: {
      'infinitive': 'kaufen',
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'general_item',
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
      'objectCategory': 'text_content',
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
      'objectCategory': 'language_topic',
      'conjugations': {
        'Präsens': {'ich': 'spreche', 'du': 'sprichst', 'er/sie/es': 'spricht', 'wir': 'sprechen', 'ihr': 'sprecht', 'sie/Sie': 'sprechen'},
        'Präteritum': {'ich': 'sprach', 'du': 'sprachst', 'er/sie/es': 'sprach', 'wir': 'sprachen', 'ihr': 'spracht', 'sie/Sie': 'sprachen'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gesprochen'}
      }
    }),
    Word(text: 'bleiben', type: 'verb', properties: {
      'infinitive': 'bleiben',
      'transitive': false,
      'objectCategory': 'location_state',
      'conjugations': {
        'Präsens': {'ich': 'bleibe', 'du': 'bleibst', 'er/sie/es': 'bleibt', 'wir': 'bleiben', 'ihr': 'bleibt', 'sie/Sie': 'bleiben'},
        'Präteritum': {'ich': 'blieb', 'du': 'bliebst', 'er/sie/es': 'blieb', 'wir': 'blieben', 'ihr': 'bliebt', 'sie/Sie': 'blieben'},
        'Perfekt': {'auxiliary': 'sein', 'participle': 'geblieben'}
      }
    }),
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
      'transitive': true,
      'objectCase': 'accusative',
      'objectCategory': 'vehicle',
      'conjugations': {
        'Präsens': {'ich': 'fahre', 'du': 'fährst', 'er/sie/es': 'fährt', 'wir': 'fahren', 'ihr': 'fahrt', 'sie/Sie': 'fahren'},
        'Präteritum': {'ich': 'fuhr', 'du': 'fuhrst', 'er/sie/es': 'fuhr', 'wir': 'fuhren', 'ihr': 'fuhrt', 'sie/Sie': 'fuhren'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gefahren'}
      }
    }),
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
      'objectCategory': 'general',
      'conjugations': {
        'Präsens': {'ich': 'arbeite', 'du': 'arbeitest', 'er/sie/es': 'arbeitet', 'wir': 'arbeiten', 'ihr': 'arbeitet', 'sie/Sie': 'arbeiten'},
        'Präteritum': {'ich': 'arbeitete', 'du': 'arbeitetest', 'er/sie/es': 'arbeitete', 'wir': 'arbeiteten', 'ihr': 'arbeitetet', 'sie/Sie': 'arbeiteten'},
        'Perfekt': {'auxiliary': 'haben', 'participle': 'gearbeitet'}
      }
    }),
    Word(text: 'reisen', type: 'verb', properties: {
      'infinitive': 'reisen',
      'transitive': false,
      'objectCategory': 'movement',
      'conjugations': {
        'Präsens': {'ich': 'reise', 'du': 'reist', 'er/sie/es': 'reist', 'wir': 'reisen', 'ihr': 'reist', 'sie/Sie': 'reisen'},
        'Präteritum': {'ich': 'reiste', 'du': 'reistest', 'er/sie/es': 'reiste', 'wir': 'reisten', 'ihr': 'reistet', 'sie/Sie': 'reisten'},
        'Perfekt': {'auxiliary': 'sein', 'participle': 'gereist'}
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
  ];

  // Zarflar (Adverbs)
  static final List<Word> adverbs = [
    Word(text: 'gestern', type: 'adverb', properties: {'time': 'past'}),
    Word(text: 'heute', type: 'adverb', properties: {'time': 'present'}),
    Word(text: 'morgen', type: 'adverb', properties: {'time': 'future'}),
    Word(text: 'oft', type: 'adverb', properties: {'time': 'frequency'}),
    Word(text: 'manchmal', type: 'adverb', properties: {'time': 'frequency'}),
    Word(text: 'immer', type: 'adverb', properties: {'time': 'frequency'}),
    Word(text: 'nie', type: 'adverb', properties: {'time': 'frequency'}),
    Word(text: 'gern', type: 'adverb', properties: {'manner': 'liking'}),
    Word(text: 'sehr', type: 'adverb', properties: {'degree': 'very'}),
    Word(text: 'hier', type: 'adverb', properties: {'place': 'here'}),
    Word(text: 'dort', type: 'adverb', properties: {'place': 'there'}),
    Word(text: 'deshalb', type: 'adverb', properties: {'reason': 'therefore'}),
  ];

  // Partisipler (Participles)
  static final List<Word> participles = [
    Word(text: 'aufgestanden', type: 'participle', properties: {'verb': 'aufstehen', 'auxiliary': 'sein', 'objectCategory': 'movement'}),
    Word(text: 'gegessen', type: 'participle', properties: {'verb': 'essen', 'auxiliary': 'haben', 'objectCategory': 'food'}),
    Word(text: 'getrunken', type: 'participle', properties: {'verb': 'trinken', 'auxiliary': 'haben', 'objectCategory': 'liquid'}),
    Word(text: 'gegangen', type: 'participle', properties: {'verb': 'gehen', 'auxiliary': 'sein', 'objectCategory': 'movement'}),
    Word(text: 'gefragt', type: 'participle', properties: {'verb': 'fragen', 'auxiliary': 'haben', 'objectCategory': 'person_information'}),
    Word(text: 'geholfen', type: 'participle', properties: {'verb': 'helfen', 'auxiliary': 'haben', 'objectCategory': 'person'}),
    Word(text: 'gefüttert', type: 'participle', properties: {'verb': 'füttern', 'auxiliary': 'haben', 'objectCategory': 'animal'}),
    Word(text: 'gefahren', type: 'participle', properties: {'verb': 'fahren', 'auxiliary': 'haben', 'objectCategory': 'vehicle'}),
    Word(text: 'gesehen', type: 'participle', properties: {'verb': 'sehen', 'auxiliary': 'haben', 'objectCategory': 'general_object'}),
    Word(text: 'gelernt', type: 'participle', properties: {'verb': 'lernen', 'auxiliary': 'haben', 'objectCategory': 'subject_skill'}),
    Word(text: 'studiert', type: 'participle', properties: {'verb': 'studieren', 'auxiliary': 'haben', 'objectCategory': 'subject_field'}),
    Word(text: 'gearbeitet', type: 'participle', properties: {'verb': 'arbeiten', 'auxiliary': 'haben', 'objectCategory': 'general'}),
    Word(text: 'gereist', type: 'participle', properties: {'verb': 'reisen', 'auxiliary': 'sein', 'objectCategory': 'movement'}),
    Word(text: 'gewusst', type: 'participle', properties: {'verb': 'wissen', 'auxiliary': 'haben', 'objectCategory': 'information'}),
    Word(text: 'gekannt', type: 'participle', properties: {'verb': 'kennen', 'auxiliary': 'haben', 'objectCategory': 'person_place_thing'}),
  ];

  // İsimler (Nouns)
  static final List<Word> nouns = [
    // Nominatif isimler
    Word(text: 'Apfel', type: 'noun', properties: {'gender': 'masculine', 'case': 'nominative', 'article': 'der', 'category': 'food'}),
    Word(text: 'Buch', type: 'noun', properties: {'gender': 'neuter', 'case': 'nominative', 'article': 'das', 'category': 'book_document'}),
    Word(text: 'Katze', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'animal'}),
    Word(text: 'Haus', type: 'noun', properties: {'gender': 'neuter', 'case': 'nominative', 'article': 'das', 'category': 'building'}),
    Word(text: 'Auto', type: 'noun', properties: {'gender': 'neuter', 'case': 'nominative', 'article': 'das', 'category': 'vehicle'}),
    Word(text: 'Lehrer', type: 'noun', properties: {'gender': 'masculine', 'case': 'nominative', 'article': 'der', 'category': 'person'}),
    Word(text: 'Schüler', type: 'noun', properties: {'gender': 'masculine', 'case': 'nominative', 'article': 'der', 'category': 'person'}),
    Word(text: 'Freund', type: 'noun', properties: {'gender': 'masculine', 'case': 'nominative', 'article': 'der', 'category': 'person'}),
    Word(text: 'Freundin', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'person'}),
    Word(text: 'Schule', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'building'}),
    Word(text: 'Arbeit', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'activity'}),
    Word(text: 'Freude', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'emotion'}),
    Word(text: 'Glück', type: 'noun', properties: {'gender': 'neuter', 'case': 'nominative', 'article': 'das', 'category': 'abstract'}),
    Word(text: 'Angst', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'emotion'}),
    Word(text: 'Zeit', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'time'}),
    Word(text: 'Geld', type: 'noun', properties: {'gender': 'neuter', 'case': 'nominative', 'article': 'das', 'category': 'finance'}),
    Word(text: 'Stadt', type: 'noun', properties: {'gender': 'feminine', 'case': 'nominative', 'article': 'die', 'category': 'location'}),
    Word(text: 'Land', type: 'noun', properties: {'gender': 'neuter', 'case': 'nominative', 'article': 'das', 'category': 'location'}),
    // Akuzatif isimler
    Word(text: 'einen Apfel', type: 'noun', properties: {'gender': 'masculine', 'case': 'accusative', 'article': 'einen', 'category': 'food'}),
    Word(text: 'ein Buch', type: 'noun', properties: {'gender': 'neuter', 'case': 'accusative', 'article': 'ein', 'category': 'book_document'}),
    Word(text: 'eine Katze', type: 'noun', properties: {'gender': 'feminine', 'case': 'accusative', 'article': 'eine', 'category': 'animal'}),
    Word(text: 'ein Haus', type: 'noun', properties: {'gender': 'neuter', 'case': 'accusative', 'article': 'ein', 'category': 'building'}),
    Word(text: 'einen Lehrer', type: 'noun', properties: {'gender': 'masculine', 'case': 'accusative', 'article': 'einen', 'category': 'person'}),
    Word(text: 'eine Freundin', type: 'noun', properties: {'gender': 'feminine', 'case': 'accusative', 'article': 'eine', 'category': 'person'}),
    Word(text: 'ein Bier', type: 'noun', properties: {'gender': 'neuter', 'case': 'accusative', 'article': 'ein', 'category': 'liquid'}),
    Word(text: 'ein Auto', type: 'noun', properties: {'gender': 'neuter', 'case': 'accusative', 'article': 'ein', 'category': 'vehicle'}),
    // Datif isimler
    Word(text: 'dem Mann', type: 'noun', properties: {'gender': 'masculine', 'case': 'dative', 'article': 'dem', 'category': 'person'}),
    Word(text: 'dem Kind', type: 'noun', properties: {'gender': 'neuter', 'case': 'dative', 'article': 'dem', 'category': 'person'}),
    Word(text: 'der Frau', type: 'noun', properties: {'gender': 'feminine', 'case': 'dative', 'article': 'der', 'category': 'person'}),
    Word(text: 'dem Lehrer', type: 'noun', properties: {'gender': 'masculine', 'case': 'dative', 'article': 'dem', 'category': 'person'}),
    Word(text: 'der Schule', type: 'noun', properties: {'gender': 'feminine', 'case': 'dative', 'article': 'der', 'category': 'building'}),
    Word(text: 'dem Freund', type: 'noun', properties: {'gender': 'masculine', 'case': 'dative', 'article': 'dem', 'category': 'person'}),
    Word(text: 'dem Buch', type: 'noun', properties: {'gender': 'neuter', 'case': 'dative', 'article': 'dem', 'category': 'book_document'}),
  ];

  // Bağlaçlar (Conjunctions)
  static final List<Word> conjunctions = [
    Word(text: 'und', type: 'conjunction', properties: {'connects': 'same_case'}),
    Word(text: 'aber', type: 'conjunction', properties: {'connects': 'same_case'}),
    Word(text: 'oder', type: 'conjunction', properties: {'connects': 'same_case'}),
    Word(text: 'weil', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
    Word(text: 'dass', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
    Word(text: 'ob', type: 'conjunction', properties: {'introduces': 'subordinate_clause', 'verb_position': 'end'}),
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
  ];

  // Edatlar (Prepositions)
  static final List<Word> prepositions = [
    Word(text: 'mit', type: 'preposition', properties: {'case': 'dative'}),
    Word(text: 'in', type: 'preposition', properties: {'case': 'dative_accusative'}),
    Word(text: 'für', type: 'preposition', properties: {'case': 'accusative'}),
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
  ];

  /// Tüm kelimeleri birleştirilmiş liste olarak döndür
  static List<Word> getAllWords() {
    return [
      ...pronouns,
      ...verbs,
      ...adverbs,
      ...participles,
      ...nouns,
      ...conjunctions,
      ...prepositions,
    ];
  }
}
