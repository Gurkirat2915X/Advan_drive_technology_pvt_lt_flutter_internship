
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/providers/requests_provider.dart';
import 'package:request_app/screens/end_user/request_detail.dart';

class CompletedRequest extends ConsumerWidget{
  const CompletedRequest({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text("Completed Requests"),
          for(var request in ref.watch(requestsProvider))
          request.status == "approved" ? TextButton(onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RequestDetailScreen(request: request),
                ),
              );
            }, child: Text(request.name)):SizedBox(height: 0,)
        ],
      ),
    );
  }
}