/// Almanca kelime modeli
/// Kelimenin türünü ve özelliklerini (cinsiyet, kişi, çoğul/tekil, vb.) tutar
class Word {
  final String text;
  final String type; // örn: 'pronoun', 'verb', 'noun', 'adverb', 'conjunction'
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
          _mapEquals(properties, other.properties);

  @override
  int get hashCode => Object.hash(text, type, properties.entries.map((e) => Object.hash(e.key, e.value) as int).fold<int>(0, (prev, curr) => prev ^ curr));

  // Properties'den kolayca erişim için getter'lar
  String? get person => properties['person'];
  String? get number => properties['number'];
  String? get gender => properties['gender'];
  String? get case_ => properties['case']; // 'case' anahtar kelime olduğu için 'case_' kullandık
  bool? get isFormal => properties['isFormal'];
  String? get infinitive => properties['infinitive'];
  Map<String, dynamic>? get conjugations => properties['conjugations'];
  String? get auxiliary => properties['auxiliary'];
  String? get participle => properties['participle'];
  String? get article => properties['article'];
  bool? get transitive => properties['transitive']; // Fiilin nesne alıp almadığı
  String? get objectCase => properties['objectCase']; // Fiilin aldığı nesnenin durumu (örn. 'accusative', 'dative')
  String? get category => properties['category']; // İsim kategorisi (örn. 'food', 'liquid', 'book')
  String? get objectCategory => properties['objectCategory']; // Fiilin tercih ettiği nesne kategorisi
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
