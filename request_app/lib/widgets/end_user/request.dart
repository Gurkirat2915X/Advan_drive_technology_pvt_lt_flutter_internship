
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/models/request.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/providers/requests_provider.dart';
import 'package:request_app/screens/end_user/new_request.dart';
import 'package:request_app/screens/end_user/request_detail.dart';

class EndUserRequestWidget extends ConsumerWidget{
  const EndUserRequestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text('End User Request Widget'),
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
          ElevatedButton(onPressed: (){
            ref.watch(requestsProvider.notifier).addRequest(
              Request(
                name:"sdsf",
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: ref.watch(authProvider).id,
                status: 'pending',
                items: [
                
                ],
                receiverId: "receiverId",
                createdAt: DateTime.now(),
              )
            );
          }, child: const Text('New Request (demo)')),
          for( var request in ref.watch(requestsProvider))
            TextButton(onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RequestDetailScreen(request: request),
                ),
              );
            }, child: Text(request.name))
        ],
      ),
    );
  }
}