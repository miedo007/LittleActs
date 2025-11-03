import 'package:go_router/go_router.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../features/partner_profile/partner_profile_wizard.dart';
import '../features/partner_profile/love_language_quiz_screen.dart';
import '../features/partner_profile/quiz_results_teaser_screen.dart';
import '../features/milestones/milestone_planner_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/gifts/gift_suggestions_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/paywall/paywall_screen.dart';
import '../features/settings/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const AppShell(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/partner',
      name: 'partnerProfile',
      builder: (context, state) => const PartnerProfileScreen(),
    ),
    GoRoute(
      path: '/quiz',
      name: 'loveLanguageQuiz',
      builder: (context, state) => const LoveLanguageQuizScreen(),
    ),
    GoRoute(
      path: '/quiz/teaser',
      name: 'quizTeaser',
      builder: (context, state) => const QuizResultsTeaserScreen(),
    ),
    GoRoute(
      path: '/milestones',
      name: 'milestonePlanner',
      builder: (context, state) => const MilestonePlannerScreen(),
    ),
    GoRoute(
      path: '/gifts',
      name: 'giftSuggestions',
      builder: (context, state) => const GiftSuggestionsScreen(),
    ),
    GoRoute(
      path: '/progress',
      name: 'progress',
      builder: (context, state) => const ProgressScreen(),
    ),
    // Paywall
    GoRoute(
      path: '/paywall',
      name: 'paywall',
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
