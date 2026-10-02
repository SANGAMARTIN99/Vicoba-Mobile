import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/shell/main_shell.dart';
import 'providers/auth_provider.dart';
import 'providers/group_data_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted = prefs.getBool('vicoba_onboarding_completed') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GroupDataProvider()),
      ],
      child: VicobaApp(onboardingCompleted: onboardingCompleted),
    ),
  );
}

class VicobaApp extends StatefulWidget {
  final bool onboardingCompleted;

  const VicobaApp({super.key, required this.onboardingCompleted});

  @override
  State<VicobaApp> createState() => _VicobaAppState();
}

class _VicobaAppState extends State<VicobaApp> {
  @override
  void initState() {
    super.initState();
    // Pre-load active session and group data if authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        context.read<GroupDataProvider>().loadAllData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'VicobaPlus Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('sw', 'TZ'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _resolveInitialScreen(auth),
    );
  }

  Widget _resolveInitialScreen(AuthProvider auth) {
    if (!widget.onboardingCompleted) {
      return const OnboardingScreen();
    }
    if (auth.isAuthenticated) {
      return const MainShell();
    }
    return const LoginScreen();
  }
}
