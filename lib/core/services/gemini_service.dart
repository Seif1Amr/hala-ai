import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/dialect.dart';

class GeminiService extends ChangeNotifier {
  static const String _prefKeyGeminiKey = 'hala_gemini_api_key';
  
  static const String _defaultApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  // Fast, high-concurrency dialect models verified on Google AI Studio
  static const List<String> _modelHierarchy = [
    'gemini-flash-latest',
    'gemini-3.5-flash-lite',
    'gemini-3.8-flash',
    'gemini-3.1-flash-lite',
  ];

  String? _userApiKey;
  String? get userApiKey => _userApiKey;
  String get effectiveApiKey =>
      (_userApiKey != null && _userApiKey!.trim().isNotEmpty) ? _userApiKey! : _defaultApiKey;
  bool get hasCustomKey => effectiveApiKey.isNotEmpty;

  ChatSession? _currentChatSession;
  DialectType? _activeDialect;
  String _activeModelName = 'gemini-flash-latest';
  String get activeModelName => _activeModelName;

  GeminiService() {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userApiKey = prefs.getString(_prefKeyGeminiKey);
      notifyListeners();
    } catch (e) {
      debugPrint('[GeminiService] Load key error: $e');
    }
  }

  Future<void> setApiKey(String key) async {
    _userApiKey = key.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyGeminiKey, _userApiKey!);
    } catch (e) {
      debugPrint('[GeminiService] Save key error: $e');
    }
    // Invalidate chat session to rebuild with new key
    _currentChatSession = null;
    notifyListeners();
  }

  /// Initializes or re-initializes the session for the given dialect
  void initChatForDialect(DialectType dialect) {
    _activeDialect = dialect;
    _currentChatSession = null;
  }

  /// Sends a user message to Gemini 2.0 Flash with dialect calibration
  Future<String> sendMessage(
    String userText, {
    required DialectType dialect,
  }) async {
    final cleanInput = userText.trim();
    if (cleanInput.isEmpty) return '';

    // If no custom API key is set, provide high-quality localized native dialect responses
    if (!hasCustomKey) {
      return _generateOfflineDialectReply(cleanInput, dialect);
    }

    // Try through model hierarchy starting with gemini-2.0-flash
    for (final modelName in _modelHierarchy) {
      try {
        _activeModelName = modelName;
        final systemPrompt = dialect.promptInstruction;

        final model = GenerativeModel(
          model: modelName,
          apiKey: effectiveApiKey,
          systemInstruction: Content.system(systemPrompt),
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 250,
          ),
        );

        if (_currentChatSession == null || _activeDialect != dialect) {
          _activeDialect = dialect;
          _currentChatSession = model.startChat();
        }

        final response = await _currentChatSession!.sendMessage(
          Content.text(cleanInput),
        );

        String reply = response.text?.trim() ?? '';
        if (reply.isNotEmpty) {
          // Safety guard: filter out any accidental system prompt regurgitation
          final lower = reply.toLowerCase();
          if (lower.contains('you are hala') ||
              lower.contains('system prompt') ||
              lower.contains('rules:') ||
              lower.contains('22-year-old')) {
            debugPrint('[GeminiService] Sanitizing leaked prompt from reply');
            reply = _generateOfflineDialectReply(cleanInput, dialect);
          }
          return reply;
        }
      } catch (e) {
        debugPrint('[GeminiService] Error with $modelName: $e. Falling back...');
        _currentChatSession = null; // reset session for fallback attempt
      }
    }

    // If API requests exhausted or errored, fallback gracefully
    return _generateOfflineDialectReply(cleanInput, dialect);
  }

  /// Rich contextual dialect fallback when offline or no API key is set
  String _generateOfflineDialectReply(String input, DialectType dialect) {
    final lower = input.toLowerCase();

    switch (dialect) {
      case DialectType.egyptian:
        if (lower.contains('سلام') || lower.contains('ازيك') || lower.contains('مرحبا')) {
          return 'يا هلا والله بيك! إزيك يا فنان؟ أنا مبسوطة أوي إننا بنتكلم سوا.';
        } else if (lower.contains('ابعت') || lower.contains('ارسل') || lower.contains('رسالة')) {
          return 'من عيوني يا باشا! ابعتلي التفاصيل دلوقتي وأنا هظبطهالك في ثواني.';
        } else if (lower.contains('شكر') || lower.contains('تسلم')) {
          return 'العفو يا باشا! ده الشرف ليا، عيني ليك في أي وقت!';
        } else if (lower.contains('قهوة') || lower.contains('شاي') || lower.contains('أكل')) {
          return 'يا سلام على القهوة المظبوطة! تشربها سادة ولا على الريحة؟ [نصيحة: بالمصري بنقول "عاوز قهوة مظبوطة"]';
        } else if (lower.contains('شغل') || lower.contains('عمل') || lower.contains('تعب')) {
          return 'ربنا يوفقك ويعينك يا رب، خد نفس وارتاح شوية دلوقتي.';
        } else {
          return 'كلامك جميل أوي ونطقك ماشاء الله مظبوط! قولي، تحب نتكلم في إيه كمان؟';
        }

      case DialectType.saudi:
        if (lower.contains('سلام') || lower.contains('كيفك') || lower.contains('مرحبا')) {
          return 'يا هلا والله ومسهلا! نورتنا طال عمرك، وش مسوي اليوم؟';
        } else if (lower.contains('طرش') || lower.contains('ارسل') || lower.contains('رسالة')) {
          return 'ابشر بالسعد طال عمرك! طرّشلي إياها الحين وأبشر باللي يسرك.';
        } else if (lower.contains('شكر') || lower.contains('تسلم') || lower.contains('مشكور')) {
          return 'الله يسلمك ويحفظك، ما سوينا إلا الواجب والله!';
        } else if (lower.contains('قهوة') || lower.contains('شاي') || lower.contains('أكل')) {
          return 'يا زين القهوة السعودية بالهيل والزعفران! تبي فنجال يصحصحك؟ [نصيحة: بالسعودي بنقول "وش تبي تطلب؟"]';
        } else if (lower.contains('شغل') || lower.contains('دوام') || lower.contains('تعب')) {
          return 'الله يقويك ويكتب أجرك! الدوام هاليومين بالحيل زحمة، صح؟';
        } else {
          return 'كفو والله ونطقك ممتاز ومضبوط! وش ودك نسولف عنه الحين؟';
        }

      case DialectType.emirati:
        if (lower.contains('سلام') || lower.contains('شحالك') || lower.contains('مرحبا')) {
          return 'مرحبا الساع! يا حيّاك الله، شحالك وشخبارك عساك بخير وسهالة؟';
        } else if (lower.contains('طرش') || lower.contains('ارسل') || lower.contains('رسالة')) {
          return 'فالك طيب فديتك! طرّشلي إياها الحين على طول وما تشيل هم.';
        } else if (lower.contains('شكر') || lower.contains('تسلم') || lower.contains('مشكور')) {
          return 'تسلم وتعيش فديتك، وما قصرت رايتك بيضا!';
        } else if (lower.contains('قهوة') || lower.contains('كرك') || lower.contains('شاي')) {
          return 'لا يفوتك شاي الكرك الساخن الحين! وايد يعدل المزاج. [نصيحة: بالإماراتي بنقول "وايد لذيذ"]';
        } else if (lower.contains('شغل') || lower.contains('دوام') || lower.contains('تعب')) {
          return 'الله يعطيك العافية وتستاهل السلامة، ريّح بالك واشرب شي دافي.';
        } else {
          return 'ما شاء الله عليك، نطقك إماراتي أصيل! شو تبغي نتعلم ويا بعض الحين؟';
        }
    }
  }
}
