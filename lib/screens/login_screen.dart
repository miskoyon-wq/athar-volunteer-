import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../services/repository.dart';
import '../widgets/common.dart';

/// Phone + OTP sign-in. Production: OTP is sent by your backend (SMS gateway).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;
  String? _error;
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  bool get _phoneValid => _phoneCtrl.text.replaceAll(RegExp(r'\D'), '').length >= 9;
  bool get _otpValid => _otpCtrl.text.replaceAll(RegExp(r'\D'), '').length == 4;

  Future<void> _sendOtp() async {
    if (!_phoneValid) {
      setState(() => _error = 'أدخل رقم جوال صحيح (مثال: 05xxxxxxxx)');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = context.read<AppRepository>();
    final code = await repo.sendOtp(_phoneCtrl.text.trim());
    if (!mounted) return;
    setState(() {
      _otpSent = true;
      _loading = false;
      _secondsLeft = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
    _showDemoSnack(code);
  }

  void _showDemoSnack(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.ink,
        duration: const Duration(seconds: 8),
        content: Text(
          'وضع تجريبي: رمز التحقق هو $code',
          style: AppText.meta.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _verify() async {
    if (!_otpValid) {
      setState(() => _error = 'أدخل رمز التحقق المكوّن من 4 أرقام');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = context.read<AppRepository>();
    final ok = await repo.verifyOtp(_phoneCtrl.text.trim(), _otpCtrl.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = 'الرمز غير صحيح، حاول مرة أخرى');
    }
    // On success, the app root listens to repo state and swaps the screen.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      'assets/images/ithar-mark.png',
                      width: 132,
                      height: 132,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('إيثار', textAlign: TextAlign.center,
                    style: AppText.h1.copyWith(color: AppColors.wordmarkTeal, fontSize: 30)),
                Text('التطوع الذكي', textAlign: TextAlign.center,
                    style: AppText.chip.copyWith(color: AppColors.ink2)),
                const SizedBox(height: 32),
                Text('تسجيل الدخول برقم الجوال', style: AppText.screenTitle),
                const SizedBox(height: 6),
                Text('ندخل برقم جوالك ونتحقق برمز لمرة واحدة (OTP).',
                    style: AppText.meta),
                const SizedBox(height: 24),
                Text('رقم الجوال', style: AppText.chip),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  enabled: !_otpSent,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration(
                    hint: '05xxxxxxxx',
                    prefixText: '+966 ',
                  ),
                  style: AppText.body.copyWith(color: AppColors.ink, fontSize: 16),
                ),
                if (_otpSent) ...[
                  const SizedBox(height: 18),
                  Text('رمز التحقق', style: AppText.chip),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(hint: '••••').copyWith(
                      counterText: '',
                      hintStyle: AppText.h1.copyWith(
                        color: AppColors.placeholder, letterSpacing: 8),
                    ),
                    style: AppText.h1.copyWith(fontSize: 24, letterSpacing: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('تغيّر الرقم؟', style: AppText.meta),
                      TextButton(
                        onPressed: _secondsLeft > 0
                            ? null
                            : () {
                                setState(() => _otpSent = false);
                                _otpCtrl.clear();
                              },
                        child: Text(
                          _secondsLeft > 0
                              ? 'إعادة الإرسال بعد $_secondsLeft ث'
                              : 'تعديل الرقم',
                          style: AppText.chip.copyWith(
                            color: _secondsLeft > 0
                                ? AppColors.placeholder
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: AppText.meta.copyWith(color: AppColors.rejectedSolid)),
                ],
                const SizedBox(height: 24),
                BigButton(
                  label: _otpSent ? 'تحقق ودخول' : 'إرسال رمز التحقق',
                  disabled: _loading || (_otpSent ? !_otpValid : !_phoneValid),
                  onPressed: _loading ? null : (_otpSent ? _verify : _sendOtp),
                ),
                if (_loading) ...[
                  const SizedBox(height: 16),
                  const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: AppColors.primary),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                Text(
                  'بالمتابعة أنت توافق على سياسة الخصوصية وشروط الاستخدام. '
                  'نجمع الاسم والعمر والمدينة ورقم الجوال ومحتوى المحادثة لغرض مطابقتك مع الفرص فقط.',
                  textAlign: TextAlign.center,
                  style: AppText.meta.copyWith(fontSize: 12, height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      prefixStyle: AppText.body.copyWith(color: AppColors.ink, fontSize: 16),
      hintStyle: AppText.body.copyWith(color: AppColors.placeholder),
      filled: true,
      fillColor: AppColors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderInput, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
