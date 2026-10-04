import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/repository.dart';
import '../widgets/common.dart';

/// Screen 4 — AI guide chat
class ChatScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onShowMatches;
  const ChatScreen({super.key, required this.onBack, required this.onShowMatches});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppRepository>().postGreetingIfEmpty();
    });
    _inputCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _inputCtrl.clear();
    final repo = context.read<AppRepository>();
    await repo.sendChatMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final session = repo.chatSession;
    final messages = session?.messages ?? <ChatMessage>[];
    final thinking = repo.aiThinking;
    final done = session?.done ?? false;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            ItharTopBar(
              title: 'مرشدك الذكي',
              onBack: widget.onBack,
              right: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              ),
            ),
            const ItharProgress(step: 3),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _Disclaimer(),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: messages.length + (thinking ? 1 : 0) + (done && !thinking ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i < messages.length) {
                    return _bubble(repo, messages[i], i);
                  }
                  if (thinking && i == messages.length) {
                    return const _TypingIndicator();
                  }
                  // done CTA
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: widget.onShowMatches,
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: Text('🎯 اعرض الفرص المقترحة', style: AppText.buttonSmall),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                          elevation: 3,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _inputBar(thinking),
          ],
        ),
      ),
    );
  }

  Widget _bubble(AppRepository repo, ChatMessage m, int index) {
    final isAi = m.isAi;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (isAi)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 11),
                  ),
                  const SizedBox(width: 6),
                  Text('المساعد',
                      style: AppText.chip.copyWith(color: AppColors.ink2, fontSize: 12)),
                ],
              ),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAi ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(isAi ? 4 : 20),
                  topLeft: Radius.circular(isAi ? 20 : 4),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                ),
                boxShadow: isAi
                    ? AppShadows.card
                    : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.19),
                        blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Text(
                m.text,
                style: AppText.chat.copyWith(color: isAi ? AppColors.ink : Colors.white),
              ),
            ),
          ),
          if (isAi)
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 4),
              child: m.reported
                  ? Text('شكراً، تم استلام الإبلاغ',
                      style: AppText.meta.copyWith(fontSize: 11, color: AppColors.acceptedSolid))
                  : TextButton.icon(
                      onPressed: () => _reportDialog(repo, m),
                      icon: const Icon(Icons.flag_outlined, size: 13, color: AppColors.placeholder),
                      label: Text('إبلاغ عن هذا الرد',
                          style: AppText.meta.copyWith(fontSize: 11, color: AppColors.placeholder)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
            ),
          if (m.chips != null && m.chips!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: m.chips!.map((c) {
                  return GestureDetector(
                    onTap: () => _send(c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25), width: 1.5),
                      ),
                      child: Text(c,
                          style: AppText.chip.copyWith(color: AppColors.primary)),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _reportDialog(AppRepository repo, ChatMessage m) async {
    const reasons = [
      'محتوى غير لائق أو مسيء',
      'معلومات مضللة أو خاطئة',
      'محتوى غير مرتبط بالتطوع',
      'أخرى',
    ];
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الإبلاغ عن رد المرشد', style: AppText.topBar),
              const SizedBox(height: 6),
              Text('ساعدنا نحسّن المرشد الذكي. اختر سبب الإبلاغ:',
                  style: AppText.meta.copyWith(fontSize: 13)),
              const SizedBox(height: 12),
              ...reasons.map((r) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(r, style: AppText.body.copyWith(color: AppColors.ink, fontSize: 15)),
                    onTap: () => Navigator.pop(ctx, r),
                  )),
            ],
          ),
        ),
      ),
    );
    if (reason != null) {
      await repo.reportAiMessage(m, reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.ink,
          content: Text('تم استلام إبلاغك وسنراجعه.', style: TextStyle(fontFamily: kFontFamily)),
        ),
      );
    }
  }

  Widget _inputBar(bool thinking) {
    final canSend = _inputCtrl.text.trim().isNotEmpty && !thinking;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputCtrl,
              enabled: !thinking,
              textInputAction: TextInputAction.send,
              onSubmitted: (v) => _send(v),
              decoration: InputDecoration(
                hintText: 'اكتب رغبتك بحرية...',
                hintStyle: AppText.meta.copyWith(color: AppColors.placeholder),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: AppColors.borderInput, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              style: AppText.body.copyWith(color: AppColors.ink, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: canSend ? AppColors.primary : AppColors.disabled,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: canSend ? () => _send(_inputCtrl.text) : null,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.tintSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'اقتراحات المرشد إرشادية فقط، والقرار النهائي للقبول يعود لمدير التطوع في الجمعية.',
              style: AppText.meta.copyWith(fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 11),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(4),
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: AppShadows.card,
            ),
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final t = (_c.value + i * 0.15) % 1.0;
                    final dy = t < 0.3 ? -6 * (t / 0.3) * (1 - (t / 0.3)) * 4 : 0.0;
                    return Transform.translate(
                      offset: Offset(0, dy),
                      child: Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
