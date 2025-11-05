import 'package:flutter/material.dart';
import '../home/home_tab.dart';
import '../partner/partner_summary_tab.dart';
import '../love_bank/love_bank_tab.dart';
import '../../shared/widgets/calm_background.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final Set<int> _built = {0};

  @override
  Widget build(BuildContext context) {
    final titles = ['Little Acts', 'Partner', 'Love Bank'];
    final children = <Widget>[
      const HomeTab(),
      const PartnerSummaryTab(),
      const LoveBankTab(),
    ];
    _built.add(_index);
    return Scaffold(
      body: CalmBackground(
        child: Stack(
          children: [
            for (int i = 0; i < children.length; i++)
              Offstage(
                offstage: _index != i,
                child: TickerMode(enabled: _index == i, child: _built.contains(i) ? children[i] : const SizedBox.shrink()),
              ),
          ],
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
