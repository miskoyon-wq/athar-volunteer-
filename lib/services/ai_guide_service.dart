import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';

/// Result of one AI-guide turn.
class GuideReply {
  final String text;
  final bool done;
  final Map<String, dynamic> interests;
  const GuideReply(this.text, this.done, this.interests);
}

/// ============================================================
/// AI Guide service.
///
/// PRODUCTION (Google Play AI policy):
///   - The LLM MUST be called from YOUR server, never ship the API key.
///   - Add "report this response", rate limiting, and a guidance disclaimer.
///   - The prompt below mirrors the prototype `sendMessage()` exactly.
///
/// This build ships with a safe on-device guide that follows the same protocol
/// (warm simple Arabic, ONE question per turn, [DONE] after 3-4 exchanges,
/// never invents opportunities). If [endpoint] is configured, it will instead
/// call your server-side LLM and fall back to the local guide on failure.
/// ============================================================
class AiGuideService {
  AiGuideService._();
  static final AiGuideService instance = AiGuideService._();

  /// Set this to your server endpoint (e.g. https://api.ithar.sa/guide) that
  /// proxies the LLM. Leave null to use the on-device guide.
  static const String? endpoint = null;

  static const List<String> fieldChips = [
    'التعليم', 'الصحة', 'البيئة', 'الإغاثة', 'كبار السن', 'الأطفال', 'التقنية',
  ];

  static const Map<String, List<String>> _fieldKeywords = {
    'التعليم': ['تعليم', 'تدريس', 'مدرس', 'دروس', 'طالب', 'طلاب', 'تعليمي', 'رياضيات', 'لغة', 'محتوى'],
    'الصحة': ['صحة', 'صحي', 'طبي', 'تمريض', 'إسعاف', 'عيادة', 'توعية صحية'],
    'البيئة': ['بيئة', 'تشجير', 'نظافة', 'إعادة تدوير', 'تطوع بيئي', 'زراعة'],
    'الإغاثة': ['إغاثة', 'إغاثي', 'كوارث', 'غذاء', 'مساعدة', 'تبرع', 'متعفف', 'أسر'],
    'كبار السن': ['كبار السن', 'مسنين', 'مسن', 'كبير', 'رعاية', 'مواساة'],
    'الأطفال': ['أطفال', 'طفل', 'مخيم', 'أنشطة', 'ترفيه', 'صيفي'],
    'التقنية': ['تقنية', 'تصميم', 'برمجة', 'مونتاج', 'تصوير', 'محتوى رقمي', 'جرافيك', 'سوشيال'],
  };

  static const Map<String, List<String>> _availabilityKeywords = {
    'نهاية الأسبوع': ['نهاية الأسبوع', 'ويكند', 'الجمعة', 'السبت'],
    'أيام الأسبوع': ['أيام الأسبوع', 'وسط الأسبوع', 'الأحد', 'الاثنين'],
    'مسائي': ['مسائي', 'مساء', 'بعد العصر', 'بعد المغرب'],
    'صباحي': ['صباحي', 'صباح', 'الصباح'],
    'مرن': ['مرن', 'مرنة', 'وقت حر', 'أي وقت'],
  };

  Future<GuideReply> reply({
    required UserProfile profile,
    required List<ChatMessage> messages,
  }) async {
    // Try server-side LLM if configured.
    if (endpoint != null) {
      try {
        return await _serverReply(endpoint!, profile, messages);
      } catch (e) {
        if (kDebugMode) debugPrint('AI server failed, using local guide: $e');
      }
    }
    // Simulate a short "thinking" latency for the typing indicator.
    await Future.delayed(Duration(milliseconds: 600 + Random().nextInt(500)));
    return _localReply(profile, messages);
  }

  Future<GuideReply> _serverReply(
    String url,
    UserProfile profile,
    List<ChatMessage> messages,
  ) async {
    final history = messages
        .map((m) => '${m.isAi ? 'Guide' : 'User'}: ${m.text}')
        .join('\n');
    final systemPrompt = buildSystemPrompt(profile, history);

    final res = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'system': systemPrompt,
            'profile': {
              'name': profile.name,
              'age': profile.age,
              'city': profile.city,
            },
            'history': messages
                .map((m) => {'role': m.role, 'text': m.text})
                .toList(),
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('guide server ${res.statusCode}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final raw = (data['text'] ?? data['reply'] ?? '').toString();
    final isDone = RegExp(r'\[DONE\]', caseSensitive: false).hasMatch(raw);
    final clean = raw.replaceAll(RegExp(r'\[DONE\]', caseSensitive: false), '').trim();
    return GuideReply(
      clean,
      isDone,
      (data['interests'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  /// Exact prompt from the prototype `sendMessage()`.
  static String buildSystemPrompt(UserProfile p, String history) => '''
أنت مرشد ذكي في تطبيق تطوع اسمه "إيثار". اسم المستخدم ${p.name}، عمره ${p.age}، من ${p.city}.
مهمتك: مساعدته يكتشف الفرصة التطوعية المناسبة له.
- رد بالعربية الفصحى البسيطة، بأسلوب دافئ ومختصر (٢-٣ جمل قصيرة كحد أقصى).
- اسأل سؤال واحد فقط في كل مرة (مجال؟ نوع النشاط؟ وقتك المتاح؟ مهاراتك؟).
- بعد ٣-٤ تبادلات، اذكر أنك جاهز تعرض له الفرص المقترحة واختم ردك بعلامة [DONE].
- لا تخترع فرص أو أسماء جمعيات.
المحادثة حتى الآن:
$history
Guide:''';

  // ---------------- Local on-device guide ----------------
  GuideReply _localReply(UserProfile profile, List<ChatMessage> messages) {
    final userMsgs = messages.where((m) => !m.isAi).toList();
    final transcript = userMsgs.map((m) => m.text).join(' ').trim();
    final exchange = userMsgs.length;

    // Extract structured interests from the whole transcript.
    final fields = _detect(transcript, _fieldKeywords);
    final availability = _detect(transcript, _availabilityKeywords);
    final interests = <String, dynamic>{
      'fields': fields,
      'availability': availability,
      'activities': <String>[],
      'skills': <String>[],
    };

    // After 3-4 exchanges → signal done and invite to matches.
    if (exchange >= 3) {
      final summary = fields.isEmpty
          ? 'وصلتني اهتماماتك'
          : 'واضح إن ميولك في ${_joinAr(fields)}';
      final text =
          '$summary 🌟 خلاص، عندي صورة جيدة عنك! اضغط الزر عشان أعرض لك الفرص المرتبة حسب تطابقها معك. [DONE]';
      return GuideReply(text, true, interests);
    }

    String text;
    if (exchange == 0) {
      // Should not happen (greeting posted first) — safety.
      text = 'احكِ لي: إيش المجال اللي يشدك وإيش تحب تسوي؟';
    } else if (fields.isEmpty) {
      final q = _questionFor(exchange);
      text = 'جميل 👌 $q';
    } else if (exchange == 1) {
      text =
          'حلو اختيارك في ${_joinAr(fields)} 👏 عشان أطابقك بدقة: كم وقت تقدر تخصص أسبوعياً؟';
    } else {
      final avail = availability.isEmpty ? '' : ' ومتاح ${_joinAr(availability)}';
      text =
          'تمام$avail ✨ عندك مهارات أو خبرات معينة تحب تستفيد منها في التطوع؟';
    }
    return GuideReply(text, false, interests);
  }

  String _questionFor(int exchange) {
    switch (exchange % 3) {
      case 1:
        return 'إيش المجال اللي يشدك أكثر: التعليم، الصحة، البيئة، الإغاثة، كبار السن، الأطفال، أو التقنية؟';
      case 2:
        return 'إيش نوع النشاط اللي تفضله: مباشر مع الناس، أو عن بعد؟';
      default:
        return 'إيش وقتك المتاح عادة: نهاية الأسبوع، أيام الأسبوع، صباحي، مسائي، أو مرن؟';
    }
  }

  List<String> _detect(String text, Map<String, List<String>> map) {
    final found = <String>[];
    final lower = text.toLowerCase();
    map.forEach((key, words) {
      for (final w in words) {
        if (lower.contains(w.toLowerCase())) {
          if (!found.contains(key)) found.add(key);
          break;
        }
      }
    });
    return found;
  }

  String _joinAr(List<String> items) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first;
    return '${items.sublist(0, items.length - 1).join('، ')} و${items.last}';
  }
}
