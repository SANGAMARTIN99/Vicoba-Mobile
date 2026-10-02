import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vicoba_mobile/main.dart';
import 'package:vicoba_mobile/providers/auth_provider.dart';
import 'package:vicoba_mobile/providers/group_data_provider.dart';
import 'package:vicoba_mobile/providers/locale_provider.dart';
import 'package:vicoba_mobile/providers/theme_provider.dart';

import 'package:vicoba_mobile/presentation/screens/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('VicobaApp loads onboarding smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'vicoba_onboarding_completed': false});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => GroupDataProvider()),
        ],
        child: const VicobaApp(onboardingCompleted: false),
      ),
    );

    await tester.pumpAndSettle();

    // Verify OnboardingScreen is presented
    expect(find.byType(OnboardingScreen), findsOneWidget);
    // Verify localized skip action is available (Ruka in Swahili default, or Skip in English)
    expect(
      find.byWidgetPredicate(
        (w) => w is Text && (w.data == 'Ruka' || w.data == 'Skip'),
      ),
      findsWidgets,
    );
  });
}
