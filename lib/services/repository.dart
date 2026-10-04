import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import 'ithar_db.dart';
import 'ai_guide_service.dart';

/// Central app state: auth, profile, opportunities, applications,
/// notifications and the AI chat session. Backed by Hive.
class AppRepository extends ChangeNotifier {
  final _uuid = const Uuid();

  UserProfile? _user;
  List<Association> _associations = [];
  List<Opportunity> _opportunities = [];
  List<Application> _myApplications = [];
  List<AppNotification> _notifications = [];
  ChatSession? _chatSession;
  bool _busy = false;

  // ---- Getters ----
  UserProfile? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get busy => _busy;
  List<Association> get associations => _associations;
  List<Opportunity> get opportunities => _opportunities;
  List<Application> get myApplications => _myApplications;
  List<AppNotification> get notifications => _notifications;
  ChatSession? get chatSession => _chatSession;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Association? get selectedNgo {
    final id = _user?.selectedNgoId;
    if (id == null) return null;
    for (final a in _associations) {
      if (a.id == id) return a;
    }
    return null;
  }

  Association? ngoById(String? id) {
    if (id == null) return null;
    for (final a in _associations) {
      if (a.id == id) return a;
    }
    return null;
  }

  // ---- Boxes ----
  Box<UserProfile> get _userBox => Hive.box<UserProfile>(ItharDb.users);
  Box<Association> get _assocBox => Hive.box<Association>(ItharDb.associations);
  Box<Opportunity> get _oppBox => Hive.box<Opportunity>(ItharDb.opportunities);
  Box<Application> get _appBox => Hive.box<Application>(ItharDb.applications);
  Box<AppNotification> get _notifBox => Hive.box<AppNotification>(ItharDb.notifications);
  Box<ChatSession> get _chatBox => Hive.box<ChatSession>(ItharDb.chat);
  Box<AiReport> get _reportBox => Hive.box<AiReport>(ItharDb.reports);
  Box get _sessionBox => Hive.box(ItharDb.session);

  // ---- Lifecycle ----
  Future<void> load() async {
    _busy = true;
    notifyListeners();

    _associations = _assocBox.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    _opportunities = _oppBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final uid = _sessionBox.get('currentUserId') as String?;
    if (uid != null && _userBox.containsKey(uid)) {
      _user = _userBox.get(uid);
      await _loadUserData(uid);
    }

    _busy = false;
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    _myApplications = _appBox.values
        .where((a) => a.userId == uid)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _notifications = _notifBox.values
        .where((n) => n.userId == uid)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final sessions = _chatBox.values.where((s) => s.userId == uid).toList();
    _chatSession = sessions.isEmpty
        ? null
        : (sessions..sort((a, b) => b.createdAt.compareTo(a.createdAt))).first;
  }

  // ============================================================
  // AUTH (phone + OTP). In production, sendOtp calls your backend.
  // ============================================================
  Future<String> sendOtp(String phone) async {
    // Demo: generate a 4-digit code locally (no SMS gateway in sandbox).
    // Production: POST /auth/otp → SMS via provider.
    final code = (1000 + Random().nextInt(9000)).toString();
    _sessionBox.put('otp_$phone', code);
    _sessionBox.put('otp_phone', phone);
    return code;
  }

  Future<bool> verifyOtp(String phone, String code) async {
    final stored = _sessionBox.get('otp_$phone') as String?;
    if (stored == null || stored != code) return false;

    // Find or create the user for this phone.
    UserProfile? existing;
    for (final u in _userBox.values) {
      if (u.phone == phone) {
        existing = u;
        break;
      }
    }
    final uid = existing?.id ?? _uuid.v4();
    _user = existing ??
        UserProfile(id: uid, phone: phone, createdAt: DateTime.now());
    await _userBox.put(uid, _user!);
    _sessionBox.put('currentUserId', uid);
    _sessionBox.delete('otp_$phone');

    await _loadUserData(uid);
    await _maybeWelcome();
    notifyListeners();
    return true;
  }

  Future<void> _maybeWelcome() async {
    final uid = _user!.id;
    final has = _notifications.any((n) => n.type == 'info');
    if (!has) {
      final n = AppNotification(
        id: _uuid.v4(),
        userId: uid,
        type: 'info',
        title: 'مرحباً بك في إيثار',
        body: 'أكمل ملفك وتحدث مع المرشد الذكي لتجد فرصتك الأولى.',
      );
      await _notifBox.put(n.id, n);
      _notifications.insert(0, n);
    }
  }

  // ============================================================
  // PROFILE
  // ============================================================
  Future<void> saveProfile({
    required String name,
    required String age,
    required String city,
    required List<String> availability,
  }) async {
    if (_user == null) return;
    _user!
      ..name = name
      ..age = age
      ..city = city
      ..availability = availability
      ..onboarded = true;
    await _user!.save();
    notifyListeners();
  }

  Future<void> selectNgo(String ngoId) async {
    if (_user == null) return;
    _user!.selectedNgoId = ngoId;
    await _user!.save();
    notifyListeners();
  }

  // ============================================================
  // CHAT / AI GUIDE
  // ============================================================
  Future<ChatSession> ensureChatSession() async {
    if (_chatSession != null) return _chatSession!;
    final s = ChatSession(id: _uuid.v4(), userId: _user!.id);
    await _chatBox.put(s.id, s);
    _chatSession = s;
    notifyListeners();
    return s;
  }

  Future<void> _persistChat() async {
    if (_chatSession == null) return;
    await _chatSession!.save();
  }

  /// Returns true while an AI reply is being produced.
  bool _aiThinking = false;
  bool get aiThinking => _aiThinking;

  Future<void> postGreetingIfEmpty() async {
    final s = await ensureChatSession();
    if (s.messages.isNotEmpty) return;
    final first = (_user?.name.trim().isNotEmpty ?? false)
        ? _user!.name.trim().split(' ').first
        : '';
    final greeting =
        'أهلاً $first 👋 أنا مرشدك الذكي في إيثار. احكِ لي بكلماتك: إيش المجال اللي يشدك، وإيش تحب تسوي بالضبط؟ تقدر تختار من الأزرار أو تكتب لي بحرية.';
    s.messages.add(ChatMessage(
      id: _uuid.v4(),
      role: 'ai',
      text: greeting,
      chips: AiGuideService.fieldChips,
    ));
    await _persistChat();
    notifyListeners();
  }

  Future<void> sendChatMessage(String text, {String? chipSource}) async {
    final s = await ensureChatSession();
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Hide chips on the previous AI message.
    for (final m in s.messages) {
      m.chips = null;
    }
    s.messages.add(ChatMessage(id: _uuid.v4(), role: 'user', text: trimmed));
    _aiThinking = true;
    await _persistChat();
    notifyListeners();

    final reply = await AiGuideService.instance.reply(
      profile: _user!,
      messages: List.of(s.messages),
    );

    _aiThinking = false;
    s.messages.add(ChatMessage(id: _uuid.v4(), role: 'ai', text: reply.text));
    if (reply.done) {
      s.done = true;
      s.extractedInterests = reply.interests;
    }
    await _persistChat();
    notifyListeners();
  }

  Future<void> reportAiMessage(ChatMessage msg, String reason) async {
    final s = _chatSession;
    if (s == null) return;
    final idx = s.messages.indexOf(msg);
    final report = AiReport(
      id: _uuid.v4(),
      userId: _user!.id,
      sessionId: s.id,
      messageIndex: idx,
      reason: reason,
    );
    await _reportBox.put(report.id, report);
    msg.reported = true;
    await _persistChat();
    notifyListeners();
  }

  // ============================================================
  // MATCHING
  // ============================================================
  /// Opportunities sorted by match % (naive keyword overlap, mirrored from
  /// the prototype + optional LLM-extracted interest boosts).
  List<OpportunityMatch> rankedOpportunities({String filter = 'ngo'}) {
    final selected = _user?.selectedNgoId;
    final chatText = _chatSession?.userTranscript ?? '';
    final interests = _chatSession?.extractedInterests ?? const {};

    final list = _opportunities
        .where((o) => o.status == 'open')
        .where((o) => filter == 'ngo' ? o.ngoId == selected : true)
        .map((o) => OpportunityMatch(o, _score(o, chatText, selected, interests)))
        .toList()
      ..sort((a, b) => b.match.compareTo(a.match));
    return list;
  }

  int _score(Opportunity opp, String chatText, String? selectedNgo, Map interests) {
    var s = 64;
    if (opp.ngoId == selectedNgo) s += 14;
    final hay = '${opp.title} ${opp.field} ${opp.description}'.toLowerCase();
    final words = chatText
        .toLowerCase()
        .split(RegExp(r'[\s،,.!?]+'))
        .where((w) => w.length > 2);
    var hits = 0;
    for (final w in words) {
      if (hay.contains(w.replaceFirst(RegExp('^ال'), ''))) hits++;
    }
    s += min(20, hits * 5);

    // Boost from structured interests extracted by the guide.
    final fields = (interests['fields'] as List?)?.cast<String>() ?? [];
    final activities = (interests['activities'] as List?)?.cast<String>() ?? [];
    for (final f in fields) {
      if (opp.field.contains(f) || opp.title.contains(f)) s += 6;
    }
    for (final a in activities) {
      if (opp.title.contains(a) || opp.description.contains(a)) s += 4;
    }
    return min(98, s);
  }

  // ============================================================
  // APPLICATIONS
  // ============================================================
  int filledSeats(String oppId) => _appBox.values
      .where((a) => a.opportunityId == oppId && a.status == 'accepted')
      .length;

  Application? myApplicationFor(String oppId) {
    for (final a in _myApplications) {
      if (a.opportunityId == oppId) return a;
    }
    return null;
  }

  Opportunity? opportunityById(String id) {
    for (final o in _opportunities) {
      if (o.id == id) return o;
    }
    return null;
  }

  Future<Application?> applyTo(String oppId, {String note = ''}) async {
    if (_user == null) return null;
    if (myApplicationFor(oppId) != null) return myApplicationFor(oppId);
    final app = Application(
      id: _uuid.v4(),
      opportunityId: oppId,
      userId: _user!.id,
      note: note,
      status: 'pending',
    );
    await _appBox.put(app.id, app);
    _myApplications.insert(0, app);

    final opp = opportunityById(oppId);
    await _pushNotification(
      type: 'sent',
      title: 'تم استلام طلبك',
      body: 'طلبك على "${opp?.title ?? ''}" قيد المراجعة من مدير التطوع.',
      opportunityId: oppId,
    );
    notifyListeners();
    return app;
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================
  Future<void> _pushNotification({
    required String type,
    required String title,
    required String body,
    String? opportunityId,
  }) async {
    final n = AppNotification(
      id: _uuid.v4(),
      userId: _user!.id,
      type: type,
      title: title,
      body: body,
      opportunityId: opportunityId,
    );
    await _notifBox.put(n.id, n);
    _notifications.insert(0, n);
  }

  Future<void> markRead(AppNotification n) async {
    if (n.isRead) return;
    n.readAt = DateTime.now();
    await n.save();
    notifyListeners();
  }

  Future<void> markAllRead() async {
    for (final n in _notifications) {
      if (!n.isRead) {
        n.readAt = DateTime.now();
        await n.save();
      }
    }
    notifyListeners();
  }

  // ============================================================
  // ACCOUNT DELETION (Google Play requirement)
  // Removes user, applications, chats and notifications.
  // ============================================================
  Future<void> deleteAccount() async {
    final uid = _user?.id;
    if (uid == null) return;

    for (final a in _appBox.values.where((a) => a.userId == uid).toList()) {
      await a.delete();
    }
    for (final n in _notifBox.values.where((n) => n.userId == uid).toList()) {
      await n.delete();
    }
    for (final s in _chatBox.values.where((s) => s.userId == uid).toList()) {
      await s.delete();
    }
    for (final r in _reportBox.values.where((r) => r.userId == uid).toList()) {
      await r.delete();
    }
    if (_userBox.containsKey(uid)) await _userBox.delete(uid);

    await _sessionBox.delete('currentUserId');
    _user = null;
    _myApplications = [];
    _notifications = [];
    _chatSession = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _sessionBox.delete('currentUserId');
    _user = null;
    _myApplications = [];
    _notifications = [];
    _chatSession = null;
    notifyListeners();
  }

  /// "ابدأ من جديد" — restart onboarding for the same user.
  Future<void> restartOnboarding() async {
    if (_user == null) return;
    _user!
      ..selectedNgoId = null
      ..onboarded = false;
    await _user!.save();
    _chatSession = null;
    notifyListeners();
  }

  /// Relative time in Arabic (mirrors prototype Store.ago).
  static String ago(DateTime ts) {
    final m = DateTime.now().difference(ts).inMinutes;
    if (m < 1) return 'الآن';
    if (m < 60) return 'قبل $m د';
    final h = (m / 60).round();
    if (h < 24) return 'قبل $h س';
    final d = (h / 24).round();
    return d == 1 ? 'أمس' : 'قبل $d أيام';
  }
}

class OpportunityMatch {
  final Opportunity opportunity;
  final int match;
  OpportunityMatch(this.opportunity, this.match);
}
