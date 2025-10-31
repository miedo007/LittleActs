import 'package:flutter/material.dart';

class GiftSuggestionsScreen extends StatelessWidget {
  const GiftSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      'Small flowers (local florist)',
      'Favorite snack bundle',
      'Handwritten card + coffee pickup',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Gift Suggestions')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            title: Text(items[i]),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // url_launcher later
            },
          ),
        ),
      ),
    );
  }
}
