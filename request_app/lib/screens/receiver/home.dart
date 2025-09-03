import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:request_app/providers/auth_provider.dart";

class ReceiverHomeScreen extends ConsumerWidget {
  const ReceiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Receiver Home Screen"),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
      body: const Center(child: Text("Welcome to the Receiver Home Screen")),
    );
  }
}
