import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nudge/features/home/home_tab.dart';
import 'package:nudge/features/partner/partner_summary_tab.dart';
import 'package:nudge/features/love_bank/love_bank_tab.dart';
import 'package:nudge/shared/widgets/calm_background.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final titles = ['Little Acts', 'Partner', 'Love Bank'];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
      body: CalmBackground(
        child: IndexedStack(
          index: _index,
          children: const [HomeTab(), PartnerSummaryTab(), LoveBankTab()],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Partner'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Love Bank'),
        ],
      ),
    );
  }
}
