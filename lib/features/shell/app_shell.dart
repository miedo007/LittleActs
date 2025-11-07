import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_tab.dart';
import '../partner/partner_summary_tab.dart';
import '../love_bank/love_bank_tab.dart';
import '../account/account_tab.dart';
import '../../shared/widgets/calm_background.dart';
import '../../shared/style/palette.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final Set<int> _built = {0};

  @override
  void initState() {
    super.initState();
    _markCompleted();
  }

  Future<void> _markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_setup', true);
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Little Acts', 'Partner', 'Love Bank', 'Account'];
    final children = <Widget>[
      const HomeTab(),
      const PartnerSummaryTab(),
      const LoveBankTab(),
      const AccountTab(),
    ];
    _built.add(_index);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
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
      bottomNavigationBar: Builder(builder: (context) {
        final cs = Theme.of(context).colorScheme;
        final iconTheme = MaterialStateProperty.resolveWith<IconThemeData>(
          (states) => states.contains(MaterialState.selected)
              ? const IconThemeData(color: Colors.white)
              : IconThemeData(color: cs.onSurfaceVariant),
        );
        final labelStyle = MaterialStateProperty.resolveWith<TextStyle>(
          (states) => states.contains(MaterialState.selected)
              ? TextStyle(color: AppColors.button, fontWeight: FontWeight.w700)
              : TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
        );
        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              indicatorColor: AppColors.button,
              surfaceTintColor: Colors.transparent,
              iconTheme: iconTheme,
              labelTextStyle: labelStyle,
            ),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_outlined), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people_outline), label: 'Partner'),
                NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite_border), label: 'Love Bank'),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_outline), label: 'Account'),
              ],
            ),
          ),
        );
      }),
    );
  }
}
