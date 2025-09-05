import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/models/user.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/providers/requests_provider.dart';
import 'package:request_app/screens/end_user/new_request.dart';
import 'package:request_app/screens/receiver/request_approval.dart';

class Requests extends ConsumerWidget {
  const Requests({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User user = ref.watch(authProvider);
    return Column(
      children: [
        Text("Request Widget"),
        SingleChildScrollView(
          child: Column(
            children: [
          if (user.role == "end_user") ...[
            const Text("End User Requests"),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NewRequestScreen(),
                  ),
                );
              },
              child: const Text('New Request'),
            ),
            for (var request in ref.watch(requestsProvider))
              (request.status == "pending" ||
                      request.status == "partially_fulfilled")
                  ? Text(request.name)
                  : const SizedBox(height: 0),
          ] else ...[
            const Text("Receiver Requests"),
            for (var request in ref.watch(requestsProvider))
              (request.status == "pending" ||
                      request.status == "partially_fulfilled")
                  ? TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                RequestApprovalScreen(request: request),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(request.name),
                          Text(request.status)
                        ],
                      ),
                    )
                  : const SizedBox(height: 0),
          ],
            ],
          ),
        ),
      ],
    );
  }
}
