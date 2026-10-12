import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/services/ad_service.dart';
import 'core/services/gemini_service.dart';
import 'core/services/stt_service.dart';
import 'core/services/tts_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/curriculum_repository.dart';
import 'data/repositories/user_preferences_repository.dart';
import 'providers/app_state_provider.dart';
import 'providers/conversation_provider.dart';
import 'providers/curriculum_provider.dart';
import 'providers/monetization_provider.dart';
import 'ui/main_navigation_scaffold.dart';
import 'ui/screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style to dark luxury obsidian
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0E1420),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Repositories
  final preferencesRepository = UserPreferencesRepository();
  final curriculumRepository = CurriculumRepository();

  // Core Services
  final ttsService = ArabicTtsService();
  final speechService = ArabicSpeechService();
  final geminiService = GeminiService();
  final adService = AdService();

  runApp(
    MultiProvider(
      providers: [
        // Services
        ChangeNotifierProvider<ArabicTtsService>.value(value: ttsService),
        ChangeNotifierProvider<ArabicSpeechService>.value(value: speechService),
        ChangeNotifierProvider<GeminiService>.value(value: geminiService),
        ChangeNotifierProvider<AdService>.value(value: adService),

        // Domain State Providers
        ChangeNotifierProvider<AppStateProvider>(
          create: (_) => AppStateProvider(preferencesRepository: preferencesRepository),
        ),
        ChangeNotifierProvider<MonetizationProvider>(
          create: (_) => MonetizationProvider(),
        ),
        ChangeNotifierProxyProvider<MonetizationProvider, CurriculumProvider>(
          create: (context) => CurriculumProvider(
            curriculumRepository: curriculumRepository,
            monetizationProvider: context.read<MonetizationProvider>(),
          ),
          update: (context, wallet, prev) => prev ?? CurriculumProvider(
            curriculumRepository: curriculumRepository,
            monetizationProvider: wallet,
          ),
        ),
        ChangeNotifierProxyProvider<MonetizationProvider, ConversationProvider>(
          create: (context) => ConversationProvider(
            geminiService: geminiService,
            ttsService: ttsService,
            speechService: speechService,
            monetizationProvider: context.read<MonetizationProvider>(),
          ),
          update: (context, wallet, prev) => prev ?? ConversationProvider(
            geminiService: geminiService,
            ttsService: ttsService,
            speechService: speechService,
            monetizationProvider: wallet,
          ),
        ),
      ],
      child: const HalaAiApp(),
    ),
  );
}

class HalaAiApp extends StatefulWidget {
  const HalaAiApp({super.key});

  @override
  State<HalaAiApp> createState() => _HalaAiAppState();
}

class _HalaAiAppState extends State<HalaAiApp> {
  bool _forceShowMain = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    if (!appState.isInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF0B0F17),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF10B981)),
          ),
        ),
      );
    }

    final locale = Locale(appState.displayLanguage);
    final showOnboarding = !appState.isOnboardingCompleted && !_forceShowMain;

    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: locale,
      home: showOnboarding
          ? OnboardingScreen(
              onCompleted: () {
                setState(() => _forceShowMain = true);
              },
            )
          : const MainNavigationScaffold(),
    );
  }
}
