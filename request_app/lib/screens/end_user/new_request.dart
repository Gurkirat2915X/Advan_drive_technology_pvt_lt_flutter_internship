import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:request_app/models/request.dart";
import "package:request_app/models/item.dart";
import "package:request_app/providers/auth_provider.dart";
import "package:request_app/providers/network_provider.dart";
import "package:request_app/providers/requests_provider.dart";
import 'package:request_app/providers/receivers_provider.dart';
import 'package:request_app/providers/item_types_provider.dart';

class NewRequestScreen extends ConsumerWidget {
  const NewRequestScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
      final receivers = ref.watch(receiversProvider);
      final itemTypes = ref.watch(itemTypesProvider);
      final user = ref.watch(authProvider);
      final isConnected = ref.watch(networkProvider);
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      final _formKey = GlobalKey<FormState>();
      final _nameController = TextEditingController();
      String? selectedReceiverId;

      // List of item fields
      final List<Map<String, dynamic>> items = [];

      // Helper to add a new item field
      void addItemField() {
        items.add({
          'nameController': TextEditingController(),
          'type': null,
          'quantityController': TextEditingController(text: '1'),
        });
      }

      // Add one item field by default
      if (items.isEmpty) {
        addItemField();
      }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Request'),
        backgroundColor: isConnected ? null : colorScheme.error,
        foregroundColor: isConnected ? null : colorScheme.onError,
      ),
      body: Column(
        children: [
          // Network status banner
          if (!isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: colorScheme.error.withOpacity(0.2)),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: colorScheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No internet connection. Please check your network.',
                      style: TextStyle(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Request Name'),
                      validator: (val) => val == null || val.isEmpty ? 'Enter a name' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Receiver'),
                      value: selectedReceiverId,
                      items: receivers.map((r) => DropdownMenuItem(
                        value: r['id'],
                        child: Text(r['username'] ?? ''),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedReceiverId = val),
                      validator: (val) => val == null ? 'Select a receiver' : null,
                    ),
                    const SizedBox(height: 24),
                    Text('Items', style: Theme.of(context).textTheme.titleMedium),
                    ...items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: item['nameController'],
                                decoration: const InputDecoration(labelText: 'Item Name'),
                                validator: (val) => val == null || val.isEmpty ? 'Enter item name' : null,
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Item Type'),
                                value: item['type'],
                                items: itemTypes.map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                )).toList(),
                                onChanged: (val) => setState(() => item['type'] = val),
                                validator: (val) => val == null ? 'Select item type' : null,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: item['quantityController'],
                                decoration: const InputDecoration(labelText: 'Quantity'),
                                keyboardType: TextInputType.number,
                                validator: (val) => (val == null || int.tryParse(val) == null || int.parse(val) < 1) ? 'Enter valid quantity' : null,
                              ),
                              if (items.length > 1)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        items.removeAt(idx);
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item'),
                        onPressed: () {
                          setState(() {
                            addItemField();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async{
                        if (!isConnected) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('No internet connection. Please check your network and try again.'),
                              backgroundColor: colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (_formKey.currentState!.validate() && selectedReceiverId != null) {
                          final requestItems = items.map((item) => Item(
                            id: '',
                            name: item['nameController'].text.trim(),
                            type: item['type'],
                            quantity: int.tryParse(item['quantityController'].text) ?? 1,
                            status: 'pending',
                          )).toList();
                          final request = Request(
                            name: _nameController.text.trim(),
                            id: '', 
                            userId: user.id,
                            status: 'pending',
                            items: requestItems,
                            createdAt: DateTime.now(),
                            receiverId: selectedReceiverId ?? '',
                          );
                          try{
                            await ref.read(requestsProvider.notifier).addRequest(request,ref.read(authProvider),ref);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request added!')),
                          );
                          Navigator.of(context).pop();
                          } catch (e) {
                            print('Error adding request: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to add request')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isConnected ? null : colorScheme.surfaceVariant,
                        foregroundColor: isConnected ? null : colorScheme.onSurfaceVariant,
                      ),
                      child: Text(
                        isConnected ? 'Submit Request' : 'No Internet Connection',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
        ],
      ),
    );
  }
}