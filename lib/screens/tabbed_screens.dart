import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/repository.dart';
import '../widgets/common.dart';

const String kAdminPhoneDisplay = '0534211130';
const String kAdminPhoneDial = 'tel:+966534211130';
const String kPrivacyPolicyUrl = 'https://ithar-privacy.cyclic-rotate.workers.dev/';
const String kAccountDeletionUrl = 'https://ithar-privacy.cyclic-rotate.workers.dev/delete-account';

Future<void> _callAdmin() async {
  final uri = Uri.parse(kAdminPhoneDial);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

/// ============================================================
/// Bottom tab bar (الفرص / الإشعارات / ملفي)
/// ============================================================
class BottomTabs extends StatelessWidget {
  final String active;
  final ValueChanged<String> go;
  final int unread;
  const BottomTabs({super.key, required this.active, required this.go, required this.unread});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('matches', 'الفرص', Icons.auto_awesome),
      ('notifs', 'الإشعارات', Icons.notifications_none_rounded),
      ('profile', 'ملفي', Icons.person_outline_rounded),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            children: tabs.map((t) {
              final (id, label, icon) = t;
              final on = active == id;
              final color = on ? AppColors.primary : AppColors.tabInactive;
              return Expanded(
                child: InkWell(
                  onTap: () => go(id),
                  child: SizedBox(
                    height: 48,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                              decoration: BoxDecoration(
                                color: on ? AppColors.tintSoft : Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Icon(icon, color: color, size: 20),
                            ),
                            if (id == 'notifs' && unread > 0)
                              Positioned(
                                top: -4,
                                left: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  constraints: const BoxConstraints(minWidth: 18),
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.rejectedSolid,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('$unread',
                                      style: AppText.tabLabel.copyWith(
                                          color: Colors.white, fontSize: 10)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(label,
                            style: AppText.tabLabel.copyWith(color: color)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// Screen 5 — Matches
/// ============================================================
class MatchesScreen extends StatefulWidget {
  final ValueChanged<String> go;
  final ValueChanged<String> openOpp;
  final VoidCallback onRestart;
  const MatchesScreen({
    super.key,
    required this.go,
    required this.openOpp,
    required this.onRestart,
  });

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  String _filter = 'ngo';

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final list = repo.rankedOpportunities(filter: _filter);
    final ngoName = repo.selectedNgo?.name ?? '';
    final unread = repo.unreadCount;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ItharTopBar(title: 'فرصك المقترحة'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppShadows.hero,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${list.length} فرص تناسبك',
                              style: AppText.buttonBig.copyWith(
                                  color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text('مرتبة حسب محادثتك مع المرشد الذكي',
                              style: AppText.meta.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _filterPill('ngo', 'جمعية $ngoName'),
                  const SizedBox(width: 8),
                  _filterPill('all', 'كل الجمعيات'),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          'لا توجد فرص مفتوحة حالياً في هذه الجمعية. جرّب "كل الجمعيات".',
                          textAlign: TextAlign.center,
                          style: AppText.meta,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                      itemCount: list.length + 1,
                      itemBuilder: (context, i) {
                        if (i == list.length) {
                          return Center(
                            child: TextButton(
                              onPressed: widget.onRestart,
                              child: Text('↺ ابدأ من جديد',
                                  style: AppText.chip.copyWith(color: AppColors.primary)),
                            ),
                          );
                        }
                        return _matchCard(repo, list[i], i == 0);
                      },
                    ),
            ),
            BottomTabs(active: 'matches', go: widget.go, unread: unread),
          ],
        ),
      ),
    );
  }

  Widget _filterPill(String id, String label) {
    final on = _filter == id;
    return GestureDetector(
      onTap: () => setState(() => _filter = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: on ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: on ? AppColors.primary : AppColors.borderInput, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: AppText.chip.copyWith(
                fontSize: 13, color: on ? Colors.white : AppColors.ink)),
      ),
    );
  }

  Widget _matchCard(AppRepository repo, OpportunityMatch m, bool isTop) {
    final op = m.opportunity;
    final ngo = repo.ngoById(op.ngoId);
    final applied = repo.myApplicationFor(op.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => widget.openOpp(op.id),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ngo?.fullName ?? '',
                                style: AppText.chip.copyWith(
                                    fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(op.title,
                                style: AppText.buttonBig.copyWith(
                                    color: AppColors.ink, fontSize: 15, height: 1.35)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      MatchRing(value: m.match),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: AppColors.ink2),
                      const SizedBox(width: 4),
                      Flexible(child: Text(op.location,
                          style: AppText.meta.copyWith(fontSize: 12))),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 13, color: AppColors.ink2),
                      const SizedBox(width: 4),
                      Flexible(child: Text(op.timeText,
                          style: AppText.meta.copyWith(fontSize: 12))),
                    ],
                  ),
                  if (applied != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: StatusPill(status: applied.status, prefix: 'طلبك: '),
                    ),
                ],
              ),
            ),
            if (isTop)
              Positioned(
                top: -8,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('✦ الأعلى تطابقاً',
                      style: AppText.chip.copyWith(
                          fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// Screen 6 — Opportunity detail
/// ============================================================
class OppDetailScreen extends StatefulWidget {
  final String oppId;
  final VoidCallback onBack;
  final VoidCallback onApplied;
  const OppDetailScreen({
    super.key,
    required this.oppId,
    required this.onBack,
    required this.onApplied,
  });

  @override
  State<OppDetailScreen> createState() => _OppDetailScreenState();
}

class _OppDetailScreenState extends State<OppDetailScreen> {
  final _noteCtrl = TextEditingController();
  bool _agree = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final op = repo.opportunityById(widget.oppId);
    if (op == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الفرصة')),
        body: const Center(child: Text('الفرصة غير موجودة')),
      );
    }
    final ngo = repo.ngoById(op.ngoId);
    final applied = repo.myApplicationFor(op.id);
    final filled = repo.filledSeats(op.id);
    final left = (op.seats - filled).clamp(0, op.seats);

    final info = [
      ('المكان', op.location),
      ('الوقت', op.timeText),
      ('تاريخ البدء', op.startDate),
      ('المقاعد المتبقية', '$left من ${op.seats}'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ItharTopBar(title: 'تفاصيل الفرصة', onBack: widget.onBack),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.tintSoft,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            NgoTile(ngo: ngo, size: 40, radius: 12),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ngo?.fullName ?? '',
                                      style: AppText.chip.copyWith(
                                          fontSize: 13, color: AppColors.ink)),
                                  Text(op.field,
                                      style: AppText.meta.copyWith(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(op.title,
                            style: AppText.buttonBig.copyWith(
                                color: AppColors.ink, fontSize: 21, height: 1.35, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.3,
                    children: info
                        .map((e) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border, width: 1.5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(e.$1, style: AppText.meta.copyWith(fontSize: 11)),
                                  const SizedBox(height: 2),
                                  Text(e.$2,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppText.chip.copyWith(
                                          fontSize: 13, color: AppColors.ink)),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('عن الفرصة',
                      style: AppText.buttonBig.copyWith(
                          color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(op.description, style: AppText.meta.copyWith(fontSize: 14, height: 1.8)),
                  if (op.requirements.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text('المتطلبات',
                        style: AppText.buttonBig.copyWith(
                            color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    ...op.requirements.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: const BoxDecoration(
                                    color: AppColors.primary, shape: BoxShape.circle),
                                child: const Icon(Icons.check, color: Colors.white, size: 13),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(s,
                                    style: AppText.body.copyWith(
                                        color: AppColors.ink, fontSize: 14, height: 1.6)),
                              ),
                            ],
                          ),
                        )),
                  ],
                  if (applied == null && left > 0) ...[
                    const SizedBox(height: 18),
                    Text('رسالة لمدير التطوع (اختياري)',
                        style: AppText.buttonBig.copyWith(
                            color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'مثال: عندي خبرة سابقة، ومتاح نهاية الأسبوع',
                        hintStyle: AppText.meta.copyWith(color: AppColors.placeholder),
                        filled: true,
                        fillColor: AppColors.surfaceAlt,
                        contentPadding: const EdgeInsets.all(14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.borderInput, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                      style: AppText.body.copyWith(color: AppColors.ink, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => setState(() => _agree = !_agree),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _agree ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: _agree ? AppColors.primary : AppColors.disabled,
                                width: 2,
                              ),
                            ),
                            child: _agree
                                ? const Icon(Icons.check, color: Colors.white, size: 15)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('أوافق على مشاركة بياناتي مع ${ngo?.fullName ?? ''}',
                                style: AppText.body.copyWith(color: AppColors.ink, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: _footer(repo, op, applied, left),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer(AppRepository repo, Opportunity op, Application? applied, int left) {
    if (applied != null) {
      return Center(child: StatusPill(status: applied.status, prefix: 'حالة طلبك: '));
    }
    if (left == 0) {
      return const BigButton(label: 'اكتملت المقاعد', disabled: true);
    }
    return BigButton(
      label: 'قدّم على هذه الفرصة',
      disabled: !_agree,
      onPressed: () async {
        await repo.applyTo(op.id, note: _noteCtrl.text.trim());
        widget.onApplied();
      },
    );
  }
}

/// ============================================================
/// Screen 7 — Application sent
/// ============================================================
class AppliedScreen extends StatefulWidget {
  final String oppId;
  final ValueChanged<String> go;
  const AppliedScreen({super.key, required this.oppId, required this.go});

  @override
  State<AppliedScreen> createState() => _AppliedScreenState();
}

class _AppliedScreenState extends State<AppliedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final op = repo.opportunityById(widget.oppId);
    final ngo = repo.ngoById(op?.ngoId);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.tintSoft, Colors.white],
          stops: [0.0, 0.55],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ScaleTransition(
                  scale: CurvedAnimation(parent: _c, curve: Curves.easeOutBack),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.tintSoft, spreadRadius: 16),
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.31),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 54),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('تم إرسال طلبك!',
                  textAlign: TextAlign.center,
                  style: AppText.h1.copyWith(fontSize: 26)),
              const SizedBox(height: 8),
              Text(
                'طلبك على «${op?.title ?? ''}» وصل لمدير التطوع في ${ngo?.fullName ?? ''}. بنبلغك أول ما يتم الرد.',
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Column(
                  children: [
                    _step('تم إرسال الطلب', true, 0),
                    _step('مراجعة مدير التطوع', false, 1),
                    _step('التواصل معك وتحديد الموعد', false, 2),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _callAdmin,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('استفسار؟ إدارة التطوع', style: AppText.meta),
                      Text(kAdminPhoneDisplay,
                          textDirection: TextDirection.ltr,
                          style: AppText.buttonBig.copyWith(
                              color: AppColors.primary, fontSize: 15)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BigButton(label: 'متابعة طلباتي', onPressed: () => widget.go('profile')),
              const SizedBox(height: 10),
              BigButton(
                label: 'استعرض فرص أخرى',
                secondary: true,
                onPressed: () => widget.go('matches'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(String label, bool done, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: done ? AppColors.primary : AppColors.border,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 15)
                : Text('${index + 1}',
                    style: AppText.chip.copyWith(color: AppColors.ink2, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: AppText.body.copyWith(
                  fontSize: 14,
                  color: done ? AppColors.ink : AppColors.ink2,
                  fontWeight: done ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}

/// ============================================================
/// Screen 8 — Profile
/// ============================================================
class ProfileScreen extends StatelessWidget {
  final ValueChanged<String> go;
  final ValueChanged<String> openOpp;
  const ProfileScreen({super.key, required this.go, required this.openOpp});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final user = repo.user;
    final mine = repo.myApplications;
    final accepted = mine.where((a) => a.status == 'accepted').length;
    final unread = repo.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 56),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5), width: 3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            (user?.name.isNotEmpty ?? false)
                                ? user!.name.characters.first
                                : 'م',
                            style: AppText.h1.copyWith(color: Colors.white, fontSize: 32),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(user?.name.isNotEmpty == true ? user!.name : 'متطوع',
                            style: AppText.buttonBig.copyWith(
                                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(
                          '${user?.city ?? ''}${(user?.age.isNotEmpty ?? false) ? ' · ${user!.age} سنة' : ''}',
                          style: AppText.meta.copyWith(
                              color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _stat('${mine.length}', 'طلبات'),
                          const SizedBox(width: 10),
                          _stat('$accepted', 'مقبولة'),
                          const SizedBox(width: 10),
                          _stat('${accepted * 4}', 'ساعة تطوع'),
                        ],
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('طلباتي',
                              style: AppText.buttonBig.copyWith(
                                  color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          if (mine.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border, width: 1.5),
                              ),
                              child: Text('ما قدمت على أي فرصة للحين.',
                                  textAlign: TextAlign.center, style: AppText.meta),
                            ),
                          ...mine.map((a) {
                            final op = repo.opportunityById(a.opportunityId);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: op == null ? null : () => openOpp(op.id),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.border, width: 1.5),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(op?.title ?? 'فرصة محذوفة',
                                                style: AppText.chip.copyWith(
                                                    fontSize: 14, color: AppColors.ink, height: 1.4)),
                                            const SizedBox(height: 2),
                                            Text(AppRepository.ago(a.createdAt),
                                                style: AppText.meta.copyWith(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      StatusPill(status: a.status),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          Text('بياناتي',
                              style: AppText.buttonBig.copyWith(
                                  color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border, width: 1.5),
                            ),
                            child: Column(
                              children: [
                                _kv('الاسم', user?.name ?? '—', true),
                                _kv('العمر', user?.age ?? '—', false),
                                _kv('المدينة', user?.city ?? '—', false),
                                _kv('وقت الفراغ',
                                    (user?.availability.isNotEmpty ?? false)
                                        ? user!.availability.join('، ')
                                        : '—',
                                    false),
                                _kv('رقم الجوال', user?.phone ?? '—', false),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _callAdmin,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border, width: 1.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('تواصل مع إدارة التطوع',
                                      style: AppText.chip.copyWith(
                                          color: AppColors.ink, fontSize: 14)),
                                  Text(kAdminPhoneDisplay,
                                      textDirection: TextDirection.ltr,
                                      style: AppText.buttonBig.copyWith(
                                          color: AppColors.primary, fontSize: 15)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _footerLinks(context, repo),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BottomTabs(active: 'profile', go: go, unread: unread),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.stat,
        ),
        child: Column(
          children: [
            Text(value,
                style: AppText.h1.copyWith(color: AppColors.primary, fontSize: 22)),
            const SizedBox(height: 2),
            Text(label, style: AppText.meta.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v, bool first) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: first ? null : const Border(top: BorderSide(color: Color(0xFFF0F2F3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: AppText.meta.copyWith(fontSize: 14)),
          Flexible(
            child: Text(v,
                textAlign: TextAlign.left,
                style: AppText.chip.copyWith(color: AppColors.ink, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _footerLinks(BuildContext context, AppRepository repo) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 18,
      runSpacing: 8,
      children: [
        GestureDetector(
          onTap: () async {
            final uri = Uri.parse(kPrivacyPolicyUrl);
            if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          child: Text('سياسة الخصوصية',
              style: AppText.chip.copyWith(color: AppColors.ink2, fontSize: 13)),
        ),
        GestureDetector(
          onTap: () async {
            final uri = Uri.parse(kAccountDeletionUrl);
            if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          child: Text('طلب حذف بياناتي (ويب)',
              style: AppText.chip.copyWith(color: AppColors.ink2, fontSize: 13)),
        ),
        GestureDetector(
          onTap: () => _confirmDelete(context, repo),
          child: Text('حذف الحساب',
              style: AppText.chip.copyWith(color: AppColors.rejectedSolid, fontSize: 13)),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppRepository repo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('حذف الحساب', style: AppText.topBar),
          content: Text(
            'سيتم حذف حسابك وكل بياناتك (طلباتك، محادثاتك، إشعاراتك) نهائياً. '
            'لا يمكن التراجع عن هذا الإجراء.',
            style: AppText.body.copyWith(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('إلغاء', style: AppText.chip.copyWith(color: AppColors.ink2)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('حذف نهائي',
                  style: AppText.chip.copyWith(color: AppColors.rejectedSolid)),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      await repo.deleteAccount();
      if (context.mounted) go('welcome');
    }
  }
}

/// ============================================================
/// Screen 9 — Notifications
/// ============================================================
class NotificationsScreen extends StatelessWidget {
  final ValueChanged<String> go;
  final ValueChanged<String> openOpp;
  const NotificationsScreen({super.key, required this.go, required this.openOpp});

  Color _color(String type) {
    switch (type) {
      case 'accepted':
        return AppColors.acceptedSolid;
      case 'rejected':
        return AppColors.rejectedSolid;
      case 'new':
        return AppColors.notifNew;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final notifs = repo.notifications;
    final unread = repo.unreadCount;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ItharTopBar(
              title: 'الإشعارات',
              right: unread > 0
                  ? TextButton(
                      onPressed: () => repo.markAllRead(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('قراءة الكل',
                          style: AppText.chip.copyWith(
                              color: AppColors.primary, fontSize: 12)),
                    )
                  : null,
            ),
            Expanded(
              child: notifs.isEmpty
                  ? Center(
                      child: Text('لا توجد إشعارات بعد.', style: AppText.meta))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: notifs.length,
                      itemBuilder: (context, i) {
                        final n = notifs[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              repo.markRead(n);
                              if (n.opportunityId != null &&
                                  repo.opportunityById(n.opportunityId!) != null) {
                                openOpp(n.opportunityId!);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: n.isRead ? Colors.white : AppColors.tintSoft,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: n.isRead ? AppColors.border : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _color(n.type),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      n.type == 'accepted'
                                          ? Icons.check
                                          : n.type == 'rejected'
                                              ? Icons.priority_high
                                              : n.type == 'new'
                                                  ? Icons.campaign_outlined
                                                  : Icons.auto_awesome,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(n.title,
                                                  style: AppText.chip.copyWith(
                                                      fontSize: 14,
                                                      color: AppColors.ink,
                                                      fontWeight: FontWeight.w800)),
                                            ),
                                            Text(AppRepository.ago(n.createdAt),
                                                style: AppText.meta.copyWith(fontSize: 11)),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(n.body,
                                            style: AppText.meta.copyWith(fontSize: 13, height: 1.6)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            BottomTabs(active: 'notifs', go: go, unread: unread),
          ],
        ),
      ),
    );
  }
}
