import 'package:flutter_test/flutter_test.dart';
import 'package:ithar_volunteer/widgets/common.dart';
import 'package:ithar_volunteer/services/ai_guide_service.dart';
import 'package:ithar_volunteer/models/models.dart';

void main() {
  group('StatusPill', () {
    test('maps status labels', () {
      expect(StatusPill.label('pending'), 'قيد المراجعة');
      expect(StatusPill.label('accepted'), 'مقبول');
      expect(StatusPill.label('rejected'), 'غير مقبول');
      expect(StatusPill.label('unknown'), 'قيد المراجعة');
    });
  });

  group('AiGuideService', () {
    test('field chips are the 7 expected fields', () {
      expect(AiGuideService.fieldChips.length, 7);
      expect(AiGuideService.fieldChips.first, 'التعليم');
    });

    test('local guide finishes after 3 user exchanges', () async {
      final p = UserProfile(id: 'u1', phone: '0500000000', name: 'نورة');
      final msgs = <ChatMessage>[
        ChatMessage(id: '1', role: 'user', text: 'أحب التعليم والتدريس'),
        ChatMessage(id: '2', role: 'ai', text: 'تمام'),
        ChatMessage(id: '3', role: 'user', text: 'نهاية الأسبوع'),
        ChatMessage(id: '4', role: 'ai', text: 'تمام'),
        ChatMessage(id: '5', role: 'user', text: 'عندي خبرة'),
      ];
      final reply = await AiGuideService.instance.reply(profile: p, messages: msgs);
      expect(reply.done, isTrue);
      expect((reply.interests['fields'] as List).contains('التعليم'), isTrue);
    });
  });

  group('UserProfile', () {
    test('isComplete requires name, age, city', () {
      final u = UserProfile(id: 'u1', phone: '05');
      expect(u.isComplete, isFalse);
      u
        ..name = 'علي'
        ..age = '30'
        ..city = 'الرياض';
      expect(u.isComplete, isTrue);
    });
  });
}
