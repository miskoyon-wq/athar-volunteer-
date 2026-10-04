import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'services/repository.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screens.dart';
import 'screens/chat_screen.dart';
import 'screens/tabbed_screens.dart';

class ItharApp extends StatelessWidget {
  const ItharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'إيثار - التطوع الذكي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const AppRoot(),
    );
  }
}

/// Top-level state machine: routes between login, onboarding and the tabbed area.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  // Onboarding sub-steps: welcome -> ngo -> info -> chat
  String _onboardStep = 'welcome';
  // Tabbed area: matches | notifs | profile
  String _tab = 'matches';
  // Detail overlay
  String? _oppId;
  bool _appliedView = false;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();

    if (repo.busy && repo.user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // Not logged in -> login
    if (!repo.isLoggedIn) {
      return const LoginScreen();
    }

    final user = repo.user!;

    // Logged in but not onboarded -> onboarding flow
    if (!user.onboarded) {
      switch (_onboardStep) {
        case 'ngo':
          return ChooseNgoScreen(
            onBack: () => setState(() => _onboardStep = 'welcome'),
            onNext: () => setState(() => _onboardStep = 'info'),
          );
        case 'info':
          return BasicInfoScreen(
            onBack: () => setState(() => _onboardStep = 'ngo'),
            onNext: () => setState(() => _onboardStep = 'chat'),
          );
        case 'chat':
          return ChatScreen(
            onBack: () => setState(() => _onboardStep = 'info'),
            onShowMatches: () => setState(() => _onboardStep = 'welcome'),
          );
        case 'welcome':
        default:
          return WelcomeScreen(
            onStart: () => setState(() => _onboardStep = 'ngo'),
            onSignIn: () => setState(() => _onboardStep = 'ngo'),
          );
      }
    }

    // Onboarded -> tabbed area (+ detail overlay)
    if (_oppId != null) {
      if (_appliedView) {
        return AppliedScreen(
          oppId: _oppId!,
          go: (tab) => setState(() {
            _appliedView = false;
            _oppId = null;
            _tab = tab;
          }),
        );
      }
      return OppDetailScreen(
        oppId: _oppId!,
        onBack: () => setState(() => _oppId = null),
        onApplied: () => setState(() => _appliedView = true),
      );
    }

    switch (_tab) {
      case 'notifs':
        return NotificationsScreen(
          go: (t) => setState(() => _tab = t),
          openOpp: (id) => setState(() => _oppId = id),
        );
      case 'profile':
        return ProfileScreen(
          go: (t) => setState(() => _tab = t),
          openOpp: (id) => setState(() => _oppId = id),
        );
      case 'matches':
      default:
        return MatchesScreen(
          go: (t) => setState(() => _tab = t),
          openOpp: (id) => setState(() => _oppId = id),
          onRestart: () => setState(() => _onboardStep = 'welcome'),
        );
    }
  }
}
