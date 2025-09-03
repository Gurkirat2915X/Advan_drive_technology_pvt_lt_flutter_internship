import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:request_app/models/request.dart";
import "package:request_app/providers/auth_provider.dart";
import "package:request_app/providers/requests_provider.dart";

class NewRequestScreen extends ConsumerWidget {
  const NewRequestScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Request'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('New Request Screen Content'),
            ElevatedButton(onPressed: () {
              ref.watch(requestsProvider.notifier).addRequest(
                Request(name: "sdfsf",id: "23", userId: ref.watch(authProvider).id, status: "dfdf", items: [], createdAt: DateTime.now(), receiverId: "receiverId")
              );
            }, child: Text('Submit'))
          ],
        )
      ),
    );
  }
}