import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../services/repository.dart';
import '../widgets/common.dart';

/// Screen 1 — Welcome
class WelcomeScreen extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onSignIn;
  const WelcomeScreen({super.key, required this.onStart, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.tintSoft, Colors.white],
          stops: [0.0, 0.6],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: AppShadows.logo,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.asset(
                          'assets/images/ithar-mark.png',
                          width: 168,
                          height: 168,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('إيثار',
                        style: AppText.h1.copyWith(
                            color: AppColors.wordmarkTeal, fontSize: 30)),
                    Text('التطوع الذكي', style: AppText.chip.copyWith(color: AppColors.ink2)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('عطاؤك اليوم أثر يبقى', style: AppText.h1),
                    const SizedBox(height: 12),
                    Text(
                      'انضم إلى آلاف المتطوعين. دردش مع مساعدنا الذكي وسنجد لك الفرصة المثالية.',
                      style: AppText.body,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _FeatureChip('✦ مطابقة ذكية'),
                        _FeatureChip('✦ +٢٠٠ جمعية'),
                        _FeatureChip('✦ فرص قريبة منك'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BigButton(label: 'ابدأ التطوع', onPressed: onStart),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: onSignIn,
                  child: RichText(
                    text: TextSpan(
                      style: AppText.buttonSmall.copyWith(
                          color: AppColors.ink2, fontWeight: FontWeight.w400),
                      children: const [
                        TextSpan(text: 'لديك حساب؟ '),
                        TextSpan(
                          text: 'تسجيل الدخول',
                          style: TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String text;
  const _FeatureChip(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.tintSoft,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text, style: AppText.chip.copyWith(color: AppColors.primary)),
    );
  }
}

/// Screen 2 — Choose association
class ChooseNgoScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  const ChooseNgoScreen({super.key, required this.onBack, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final ngos = repo.associations;
    final selected = repo.user?.selectedNgoId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ItharTopBar(title: 'اختر الجمعية', onBack: onBack),
            const ItharProgress(step: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مع أي جمعية تحب تتطوع؟', style: AppText.screenTitle),
                  const SizedBox(height: 6),
                  Text('تقدر تختار وحدة بس الحين وتغيرها لاحقاً', style: AppText.meta),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: ngos.length,
                itemBuilder: (context, i) {
                  final n = ngos[i];
                  final sel = selected == n.id;
                  final opsCount = repo.opportunities.where((o) => o.ngoId == n.id).length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => repo.selectNgo(n.id),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.tintSoft : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            NgoTile(ngo: n, colorIndex: i),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(n.name,
                                          style: AppText.buttonBig.copyWith(
                                              color: AppColors.ink, fontSize: 16)),
                                      const SizedBox(width: 8),
                                      TagChip(n.tag),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(n.fullName, style: AppText.meta.copyWith(fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('$opsCount فرصة متاحة',
                                      style: AppText.chip.copyWith(color: AppColors.primary, fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: sel ? AppColors.primary : Colors.transparent,
                                border: Border.all(
                                  color: sel ? AppColors.primary : AppColors.disabled,
                                  width: 2,
                                ),
                              ),
                              child: sel
                                  ? const Icon(Icons.check, color: Colors.white, size: 15)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: BigButton(
                label: 'تابع',
                disabled: selected == null,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen 3 — Basic info
class BasicInfoScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  const BasicInfoScreen({super.key, required this.onBack, required this.onNext});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final Set<String> _avail = {};
  static const _availOptions = ['نهاية الأسبوع', 'أيام الأسبوع', 'مسائي', 'صباحي', 'مرن'];

  @override
  void initState() {
    super.initState();
    final u = context.read<AppRepository>().user;
    if (u != null) {
      _nameCtrl.text = u.name;
      _ageCtrl.text = u.age;
      _cityCtrl.text = u.city;
      _avail.addAll(u.availability);
    }
    for (final c in [_nameCtrl, _ageCtrl, _cityCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  bool get _complete =>
      _nameCtrl.text.trim().isNotEmpty &&
      _ageCtrl.text.trim().isNotEmpty &&
      _cityCtrl.text.trim().isNotEmpty;

  Future<void> _saveAndNext() async {
    await context.read<AppRepository>().saveProfile(
          name: _nameCtrl.text.trim(),
          age: _ageCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          availability: _avail.toList(),
        );
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ItharTopBar(title: 'بياناتك الأساسية', onBack: widget.onBack),
            const ItharProgress(step: 2),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('عرّفنا بنفسك 👋', style: AppText.screenTitle),
                  const SizedBox(height: 6),
                  Text('معلومات سريعة عشان نطابقك مع الفرص المناسبة', style: AppText.meta),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                children: [
                  _field('الاسم الكامل', _nameCtrl, 'مثال: نورة العتيبي'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _field('العمر', _ageCtrl, '25', numeric: true)),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: _field('المدينة', _cityCtrl, 'الرياض')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('وقت الفراغ عندك', style: AppText.chip),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availOptions.map((c) {
                      final sel = _avail.contains(c);
                      return GestureDetector(
                        onTap: () => setState(() {
                          sel ? _avail.remove(c) : _avail.add(c);
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: sel ? AppColors.primary : AppColors.borderInput,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            c,
                            style: AppText.chip.copyWith(
                                color: sel ? Colors.white : AppColors.ink),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: BigButton(
                label: 'ابدأ الدردشة',
                disabled: !_complete,
                onPressed: _saveAndNext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint,
      {bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.chip),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            keyboardType: numeric ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppText.body.copyWith(color: AppColors.placeholder),
              filled: true,
              fillColor: AppColors.surfaceAlt,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: ctrl.text.isNotEmpty ? AppColors.primary : AppColors.borderInput,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            style: AppText.body.copyWith(color: AppColors.ink, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
