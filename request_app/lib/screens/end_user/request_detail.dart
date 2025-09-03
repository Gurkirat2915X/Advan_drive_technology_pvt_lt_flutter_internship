import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/models/request.dart';

class RequestDetailScreen extends ConsumerWidget {
  final Request request;

  const RequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request Name: ${request.name}'),
            Text('Request ID: ${request.id}'),
            Text('User ID: ${request.userId}'),
            Text('Status: ${request.status}'),
            Text('Created At: ${request.createdAt}'),
            Text('Receiver ID: ${request.receiverId}'),
            const SizedBox(height: 16),
            const Text('Items:'),
            for (var item in request.items)
              Text(' - ${item.name} (ID: ${item.id})'),
          ],
        ),
      ),
    );
  }
}