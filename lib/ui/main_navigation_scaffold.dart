import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state_provider.dart';
import 'screens/conversation/conversation_salon_screen.dart';
import 'screens/curriculum/curriculum_screen.dart';
import 'screens/home/home_dashboard_screen.dart';
import 'screens/mastery/dialect_mastery_hub_screen.dart';
import 'screens/settings/settings_screen.dart';

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final appLang = context.watch<AppStateProvider>().displayLanguage;

    final screens = [
      HomeDashboardScreen(onNavigateTab: _onTabSelected),
      const ConversationSalonScreen(),
      const CurriculumScreen(),
      const DialectMasteryHubScreen(),
      const SettingsScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 720;

        if (isTablet) {
          return Scaffold(
            backgroundColor: AppColors.obsidianBase,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onTabSelected,
                  backgroundColor: AppColors.midnightSand,
                  selectedIconTheme: const IconThemeData(color: AppColors.emeraldPrimary),
                  unselectedIconTheme: const IconThemeData(color: AppColors.textMuted),
                  selectedLabelTextStyle: AppTheme.latin(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emeraldLight,
                  ),
                  unselectedLabelTextStyle: AppTheme.latin(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.emeraldPrimary, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.emeraldGlow,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.school, color: AppColors.emeraldLight),
                        ),
                      ),
                    ),
                  ),
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.dashboard_rounded),
                      label: Text(AppStrings.get('navHome', lang: appLang)),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.record_voice_over_rounded),
                      label: Text(AppStrings.get('navConversation', lang: appLang)),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.auto_stories_rounded),
                      label: Text(AppStrings.get('navCurriculum', lang: appLang)),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.translate_rounded),
                      label: Text(AppStrings.get('navMastery', lang: appLang)),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.settings_rounded),
                      label: Text(AppStrings.get('navSettings', lang: appLang)),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1, color: AppColors.slateDivider),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 850),
                      child: IndexedStack(
                        index: _currentIndex,
                        children: screens,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabSelected,
            backgroundColor: AppColors.midnightSand,
            selectedItemColor: AppColors.emeraldPrimary,
            unselectedItemColor: AppColors.textMuted,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_rounded),
                label: AppStrings.get('navHome', lang: appLang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.record_voice_over_rounded),
                label: AppStrings.get('navConversation', lang: appLang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.auto_stories_rounded),
                label: AppStrings.get('navCurriculum', lang: appLang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.translate_rounded),
                label: AppStrings.get('navMastery', lang: appLang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_rounded),
                label: AppStrings.get('navSettings', lang: appLang),
              ),
            ],
          ),
        );
      },
    );
  }
}
