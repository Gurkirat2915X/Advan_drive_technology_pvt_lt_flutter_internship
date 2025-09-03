import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/widgets/end_user/request.dart';


class EndUserTabs extends ConsumerWidget {
  const EndUserTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text('End User Dashboard'),
               const Spacer(),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Requests'),
              Tab(text: 'Completed Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: EndUserRequestWidget()),
            Center(child: Text('Profile Tab')),
          ],
        ),
      ),
    );
  }
}