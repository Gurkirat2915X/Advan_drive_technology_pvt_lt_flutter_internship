import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/screens/completed_request.dart';
import 'package:request_app/screens/login.dart';
import 'package:request_app/screens/receiver/reassigned.dart';
import 'package:request_app/widgets/request.dart';

class ReceiverTabs extends ConsumerWidget {
  const ReceiverTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(length: 3, child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Receiver Dashboard"),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            )
          ],
        ),
        bottom: const TabBar(tabs: [
          Tab(text: "Pending Request",),
          Tab(text: "Reassigned",),
          Tab(text: "Completed",)
        ])),
        body: TabBarView(children: [
          Center(child: Requests(),),
          Center(child: ReassignedScreen(),),
          Center(child: CompletedRequest(),)
        ]),
      ),
    
    );
  }
}
