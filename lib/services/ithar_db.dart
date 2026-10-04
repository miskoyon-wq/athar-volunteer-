import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

/// Hive box names + adapter registration + seed data.
class ItharDb {
  static const String users = 'users';
  static const String associations = 'associations';
  static const String opportunities = 'opportunities';
  static const String applications = 'applications';
  static const String notifications = 'notifications';
  static const String chat = 'chat_sessions';
  static const String reports = 'ai_reports';
  static const String session = 'session';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(AssociationAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(OpportunityAdapter());
    Hive.registerAdapter(ApplicationAdapter());
    Hive.registerAdapter(AppNotificationAdapter());
    Hive.registerAdapter(ChatMessageAdapter());
    Hive.registerAdapter(ChatSessionAdapter());
    Hive.registerAdapter(AiReportAdapter());

    await Hive.openBox<Association>(associations);
    await Hive.openBox<UserProfile>(users);
    await Hive.openBox<Opportunity>(opportunities);
    await Hive.openBox<Application>(applications);
    await Hive.openBox<AppNotification>(notifications);
    await Hive.openBox<ChatSession>(chat);
    await Hive.openBox<AiReport>(reports);
    await Hive.openBox(session);
  }

  /// Seed associations + opportunities + demo applications (other users) + notifications.
  static Future<void> seedIfEmpty() async {
    final assocBox = Hive.box<Association>(associations);
    final oppBox = Hive.box<Opportunity>(opportunities);
    final appsBox = Hive.box<Application>(applications);
    final notifBox = Hive.box<AppNotification>(notifications);

    if (assocBox.isEmpty) {
      final list = [
        Association(id: 'misk', name: 'مسك', fullName: 'جمعية مسك لإكرام الموتى', tag: 'إكرام الموتى'),
        Association(id: 'ihsan', name: 'إحسان', fullName: 'جمعية إحسان', tag: 'إغاثة'),
        Association(id: 'ata', name: 'عطاء', fullName: 'جمعية عطاء للخدمات المجتمعية', tag: 'خدمات مجتمعية'),
        Association(id: 'nama', name: 'نماء', fullName: 'جمعية نماء', tag: 'تنمية'),
        Association(id: 'rahma', name: 'الرحمة', fullName: 'جمعية الرحمة', tag: 'رعاية'),
      ];
      for (final a in list) {
        await assocBox.put(a.id, a);
      }
    }

    if (oppBox.isEmpty) {
      final now = DateTime.now();
      DateTime d(int days) => now.subtract(Duration(days: days));
      final opps = <Opportunity>[
        Opportunity(
          id: 'o1', ngoId: 'misk', field: 'إكرام الموتى',
          title: 'المساعدة في تغسيل وتكفين الموتى (رجال)',
          location: 'الرياض · مغسلة الجمعية', timeText: 'مناوبات حسب الحاجة',
          seats: 10, startDate: '2026-10-15', createdAt: d(9),
          description: 'المشاركة مع فريق الجمعية في تجهيز المتوفين وفق الأحكام الشرعية، تحت إشراف مغسّل معتمد. يتم تدريب المتطوع الجديد قبل المشاركة.',
          requirements: ['اجتياز دورة التغسيل (توفرها الجمعية)', 'الالتزام بالسرية واحترام خصوصية الأسر', 'العمر ١٨ سنة فأكثر'],
        ),
        Opportunity(
          id: 'o2', ngoId: 'misk', field: 'إكرام الموتى',
          title: 'المساعدة في تغسيل وتكفين الموتى (نساء)',
          location: 'الرياض · القسم النسائي', timeText: 'مناوبات حسب الحاجة',
          seats: 8, startDate: '2026-10-15', createdAt: d(8),
          description: 'المشاركة مع فريق القسم النسائي في تجهيز المتوفيات وفق الأحكام الشرعية، تحت إشراف مغسّلة معتمدة.',
          requirements: ['اجتياز دورة التغسيل (توفرها الجمعية)', 'الالتزام بالسرية', 'العمر ١٨ سنة فأكثر'],
        ),
        Opportunity(
          id: 'o3', ngoId: 'misk', field: 'إكرام الموتى',
          title: 'تنظيم ومرافقة الجنائز',
          location: 'الرياض · المقابر', timeText: 'نهاية الأسبوع',
          seats: 15, startDate: '2026-10-10', createdAt: d(6),
          description: 'تنظيم دخول وخروج المشيعين، إرشاد الزوار، وتوزيع المياه في المقابر خلال أوقات الدفن.',
          requirements: ['اللياقة البدنية', 'حسن التعامل مع الناس'],
        ),
        Opportunity(
          id: 'o4', ngoId: 'misk', field: 'الدعم الاجتماعي',
          title: 'مواساة ودعم أسر المتوفين',
          location: 'الرياض', timeText: 'مسائي · ٤ ساعات أسبوعياً',
          seats: 6, startDate: '2026-10-20', createdAt: d(4),
          description: 'التواصل مع أسر المتوفين بعد الوفاة، وتقديم المساندة المعنوية وإرشادهم للإجراءات والخدمات المتاحة.',
          requirements: ['مهارات تواصل عالية', 'يفضل خلفية في الإرشاد الأسري أو الاجتماعي'],
        ),
        Opportunity(
          id: 'o5', ngoId: 'misk', field: 'التقنية',
          title: 'إعداد محتوى توعوي عن أحكام الجنائز',
          location: 'عن بعد', timeText: 'مرن',
          seats: 4, startDate: '2026-10-12', createdAt: d(2),
          description: 'تصميم وكتابة محتوى توعوي للمنصات الرقمية للجمعية بالتنسيق مع اللجنة الشرعية.',
          requirements: ['مهارات تصميم أو كتابة', 'الإلمام بأدوات التصميم'],
        ),
        Opportunity(
          id: 'o6', ngoId: 'ihsan', field: 'التعليم',
          title: 'مدرس رياضيات لطلاب متعففين',
          location: 'الرياض · حي النرجس', timeText: '٣ ساعات / أسبوع',
          seats: 5, startDate: '2026-10-11', createdAt: d(7),
          description: 'تقديم دروس تقوية في الرياضيات لطلاب المرحلة المتوسطة من الأسر المتعففة.',
          requirements: ['إتقان مادة الرياضيات'],
        ),
        Opportunity(
          id: 'o7', ngoId: 'ata', field: 'التعليم',
          title: 'إعداد محتوى تعليمي رقمي',
          location: 'عن بعد', timeText: 'مرن',
          seats: 6, startDate: '2026-10-18', createdAt: d(5),
          description: 'إعداد دروس مصورة قصيرة لمنصة الجمعية التعليمية.',
          requirements: ['مهارات تصوير أو مونتاج'],
        ),
        Opportunity(
          id: 'o8', ngoId: 'nama', field: 'الأطفال',
          title: 'مساعدة في مخيم صيفي للأطفال',
          location: 'جدة', timeText: 'أسبوعين متتاليين',
          seats: 12, startDate: '2026-11-01', createdAt: d(3),
          description: 'الإشراف على أنشطة الأطفال في المخيم.',
          requirements: ['حب العمل مع الأطفال'],
        ),
      ];
      for (final o in opps) {
        await oppBox.put(o.id, o);
      }
    }

    if (appsBox.isEmpty) {
      final now = DateTime.now();
      DateTime ago(int h) => now.subtract(Duration(hours: h));
      final apps = <Application>[
        Application(id: 'a1', opportunityId: 'o1', userId: 'seed_u1', note: 'أخذت دورة تغسيل في ١٤٤٥هـ وأرغب بالمشاركة.', status: 'pending', createdAt: ago(48)),
        Application(id: 'a2', opportunityId: 'o3', userId: 'seed_u2', status: 'pending', createdAt: ago(24)),
        Application(id: 'a3', opportunityId: 'o2', userId: 'seed_u3', note: 'متفرغة أيام الأسبوع صباحاً.', status: 'pending', createdAt: ago(5)),
        Application(id: 'a4', opportunityId: 'o3', userId: 'seed_u4', status: 'accepted', createdAt: ago(96)),
        Application(id: 'a5', opportunityId: 'o5', userId: 'seed_u5', note: 'مصممة جرافيك.', status: 'accepted', createdAt: ago(72)),
        Application(id: 'a6', opportunityId: 'o4', userId: 'seed_u6', status: 'rejected', createdAt: ago(144)),
      ];
      for (final a in apps) {
        await appsBox.put(a.id, a);
      }
    }

    // New-opportunity notifications are created per-user on login (see repository).
    if (notifBox.isEmpty) {
      // nothing global here
    }
  }
}
