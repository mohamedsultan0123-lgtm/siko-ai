import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/user_profile.dart';

class AiService {
  const AiService();

  Future<String> reply({
    required String userText,
    required UserProfile profile,
  }) async {
    if (AppConfig.geminiApiKey.isEmpty) {
      return _demoReply(userText, profile);
    }

    final uri = Uri.parse(
      '${AppConfig.geminiEndpoint}/${AppConfig.geminiModel}:generateContent?key=${AppConfig.geminiApiKey}',
    );

    final systemPrompt = '''
You are ${profile.safeAssistantName}, a friendly Arabic-first smart assistant.
The user's name is ${profile.userName}.
The user is ${profile.gender == UserGender.female ? 'female' : 'male'} and is currently learning ${profile.learningLanguage}.
Address the user with natural Arabic grammar matching the user's gender. For a female user, use feminine forms such as 'اتعلمي' and 'اختاري'; for a male user, use masculine forms such as 'اتعلم' and 'اختار'.
If English is selected, the preferred variety is ${profile.englishVariant} English.
Respond naturally in Arabic unless the user asks to practice the target language.
For problems, give practical, reasonable, actionable suggestions and clearly state uncertainty where needed.
For language learning, act as a patient tutor: explain in Arabic, give examples, and encourage practice.
When asked who you are, say your name and mention that ${profile.userName} chose the name.
''';

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': userText}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 700,
      },
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return 'حصلت مشكلة في الاتصال بخدمة الذكاء الاصطناعي. جرّب مرة أخرى أو استخدم وضع Demo حالياً.';
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = json['candidates'] as List<dynamic>?;
      final first = candidates?.isNotEmpty == true ? candidates!.first : null;
      final content = first is Map<String, dynamic>
          ? first['content'] as Map<String, dynamic>?
          : null;
      final parts = content?['parts'] as List<dynamic>?;
      final text = parts?.isNotEmpty == true && parts!.first is Map<String, dynamic>
          ? (parts.first as Map<String, dynamic>)['text'] as String?
          : null;

      return text?.trim().isNotEmpty == true
          ? text!.trim()
          : 'لم يصلني رد واضح هذه المرة. جرّب صياغة السؤال بطريقة أخرى.';
    } catch (_) {
      return 'تعذر الاتصال حالياً. تأكد من الإنترنت أو جرّب وضع Demo الموجود داخل التطبيق.';
    }
  }

  String _demoReply(String text, UserProfile profile) {
    final normalized = text.trim().toLowerCase();

    if (normalized.contains('عرف نفسك') || normalized.contains('من انت') ||
        normalized.contains('who are you')) {
      return 'أنا ${profile.safeAssistantName}، مساعدك الذكي. ${profile.userName} هو اللي اختار لي اسم ${profile.safeAssistantName}. أقدر أساعدك في تعلم اللغات، الدردشة، وتنظيم أفكارك.';
    }

    if (normalized.contains('فرنسي') || normalized.contains('french')) {
      return 'خلينا نتعلم خطوة خطوة 🇫🇷. مثال: Bonjour = مرحباً. بعد كده أقدر أعمل لك تدريب قصير ونبدأ من مستواك الحالي.';
    }

    if (normalized.contains('انجليزي') || normalized.contains('english')) {
      return profile.isFemale
          ? 'ممتازة 🇬🇧🇺🇸. أقدر أشرح لكِ الإنجليزية بالعربي، ونحدد هل تريدين النطق الأمريكي أم البريطاني، وبعدها نعمل محادثة قصيرة للتدريب.'
          : 'ممتاز 🇬🇧🇺🇸. أقدر أشرح لك الإنجليزية بالعربي، ونحدد هل تريد النطق الأمريكي أم البريطاني، وبعدها نعمل محادثة قصيرة للتدريب.';
    }

    return 'أنا معاك يا ${profile.userName}. في النسخة الحالية شغالين بوضع Demo لتجربة الواجهة. اكتب مشكلة أو موضوع، وبعد ربط مفتاح AI سأتعامل معه كمحادثة ذكية كاملة.';
  }
}
