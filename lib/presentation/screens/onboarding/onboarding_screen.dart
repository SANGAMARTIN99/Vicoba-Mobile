import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../common/app_buttons.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _items = [
    _OnboardingItem(
      imagePath: 'assets/images/onboarding_community.jpg',
      titleKey: 'onboarding_title_1',
      descKey: 'onboarding_desc_1',
      accentColor: AppColors.primary,
    ),
    _OnboardingItem(
      imagePath: 'assets/images/onboarding_digital.jpg',
      titleKey: 'onboarding_title_2',
      descKey: 'onboarding_desc_2',
      accentColor: AppColors.accent,
    ),
    _OnboardingItem(
      imagePath: 'assets/images/onboarding_growth.jpg',
      titleKey: 'onboarding_title_3',
      descKey: 'onboarding_desc_3',
      accentColor: Color(0xFF10B981),
    ),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vicoba_onboarding_completed', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final item = _items[index];
              return Column(
                children: [
                  // Realistic Image Header with Gradient Fade
                  SizedBox(
                    height: size.height * 0.54,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          item.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.primaryLight,
                              child: const Icon(
                                Icons.groups_rounded,
                                size: 80,
                                color: AppColors.primary,
                              ),
                            );
                          },
                        ),
                        // Gradient Overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.2),
                                  Colors.transparent,
                                  isDark
                                      ? AppColors.darkBg.withValues(alpha: 0.8)
                                      : AppColors.lightBg.withValues(alpha: 0.85),
                                  isDark ? AppColors.darkBg : AppColors.lightBg,
                                ],
                                stops: const [0.0, 0.4, 0.8, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Text Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.translate(item.titleKey),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                              letterSpacing: -0.4,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n.translate(item.descKey),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Top Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: TextButton(
              onPressed: _finishOnboarding,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.35),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                l10n.translate('skip'),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),

          // Bottom Navigation & Page Indicators
          Positioned(
            left: AppDimensions.xxl,
            right: AppDimensions.xxl,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _items.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 28 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Action Button
                if (_currentPage == _items.length - 1)
                  AppPrimaryButton(
                    text: l10n.translate('getStarted'),
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _finishOnboarding,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: AppOutlinedButton(
                          text: l10n.translate('skip'),
                          onPressed: _finishOnboarding,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppPrimaryButton(
                          text: l10n.translate('next'),
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingItem {
  final String imagePath;
  final String titleKey;
  final String descKey;
  final Color accentColor;

  _OnboardingItem({
    required this.imagePath,
    required this.titleKey,
    required this.descKey,
    required this.accentColor,
  });
}
