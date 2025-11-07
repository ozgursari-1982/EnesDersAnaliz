import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modüller
import 'models/word.dart';
import 'constants/german_words.dart';
import 'services/gemini_service.dart';

void main() async {
  // Environment variables'ı yükle
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  runApp(const ProviderScope(child: MyApp()));
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
  // Zamanlar listesi - constants'tan alınıyor
  final List<String> _times = AppConstants.times;

  String? _selectedTime;
  
  // Tüm kelimeler - constants'tan alınıyor
  List<Word> _allWords = GermanWords.getAllWords();
  
  // Gemini servisi - API anahtarı environment variable'dan alınıyor
  late final GeminiService _geminiService;
  
  @override
  void initState() {
    super.initState();
    // API anahtarını .env dosyasından al
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _geminiService = GeminiService(apiKey: apiKey);
    // Başlangıç mesajını constants'tan al
    _currentFeedback = AppConstants.initialFeedback;
  }
  
  String _currentFeedback = AppConstants.initialFeedback; // Almanca başlangıç mesajı
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

  // Gemini API geri bildirim fonksiyonu - Servisi kullan
  Future<String> _getGeminiFeedback(String sentence) async {
    if (sentence.trim().isEmpty) {
      return 'Mari wartet auf deine Auswahl... 🌟';
    }

    final String constructedSentence = _getCurrentSentenceText();
    
    // Gemini servisini kullanarak cümle analizi yap
    try {
      final feedback = await _geminiService.analyzeSentence(
        constructedSentence,
        _selectedTime,
      );
      return feedback;
    } catch (e) {
      return 'Hata: ${e.toString()}';
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
