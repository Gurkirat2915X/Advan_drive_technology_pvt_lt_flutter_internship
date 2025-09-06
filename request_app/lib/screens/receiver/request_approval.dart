import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:request_app/models/request.dart";
import "package:request_app/models/item.dart";
import 'package:request_app/providers/receivers_provider.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/providers/requests_provider.dart';

class RequestApprovalScreen extends ConsumerStatefulWidget {
  const RequestApprovalScreen({super.key, required this.request});
  final Request request;

  @override
  ConsumerState<RequestApprovalScreen> createState() => _RequestApprovalScreenState();
}

class _RequestApprovalScreenState extends ConsumerState<RequestApprovalScreen> {
  late List<Map<String, dynamic>> itemStates;
  final List<String> statusOptions = ["pending", "fulfilled", "out_of_stock", "reassigned"];

  @override
  void initState() {
    super.initState();
    // Initialize item states with current values
    itemStates = widget.request.items.map((item) => {
      'item': item,
      'status': item.status,
      'selectedReceiver': null,
      'selectedReceiverId': null,
      'reassignmentReason': '', // Add reason field
    }).toList();
  }

  // Demo function to handle request submission
  void _submitRequest() async {
    print('=== REQUEST SUBMISSION ===');
    print('Request ID: ${widget.request.id}');
    print('Request Name: ${widget.request.name}');
    
    // Create updated items with new statuses
    List<Item> updatedItems = [];
    
    for (int i = 0; i < itemStates.length; i++) {
      final itemState = itemStates[i];
      final item = itemState['item'] as Item;
      print('Item ${i + 1}:');
      print('  Name: ${item.name}');
      print('  Original Status: ${item.status}');
      print('  New Status: ${itemState['status']}');
      
      // Create updated item with new status
      Item updatedItem;
      
      if (itemState['status'] == 'reassigned' && itemState['selectedReceiver'] != null) {
        print('  Reassigned to: ${itemState['selectedReceiver']['username']} (ID: ${itemState['selectedReceiver']['id']})');
        
        // Create item with reassignment info
        updatedItem = Item(
          id: item.id,
          name: item.name,
          type: item.type,
          quantity: item.quantity,
          status: itemState['status'],
        );
      } else {
        updatedItem = Item(
          id: item.id,
          name: item.name,
          type: item.type,
          quantity: item.quantity,
          status: itemState['status'],
        );
      }
      
      updatedItems.add(updatedItem);
    }
    
    // Create updated request object
    Request updatedRequest = Request(
      id: widget.request.id,
      name: widget.request.name,
      userId: widget.request.userId,
      status: widget.request.status, // Backend will calculate the correct status
      items: updatedItems,
      createdAt: widget.request.createdAt,
      receiverId: widget.request.receiverId,
    );
    
    try {
      await ref.read(requestsProvider.notifier).updateRequestWithReassignments(
        ref.watch(authProvider), 
        updatedRequest,
        itemStates
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request processed successfully!')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      print('Error updating request: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final receivers = ref.watch(receiversProvider);
    final currentUser = ref.watch(authProvider);
    
    // Filter out current receiver from available receivers
    final availableReceivers = receivers.where((receiver) => 
      receiver['id'] != currentUser.id
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Approval"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Request Name: ${widget.request.name}", style: Theme.of(context).textTheme.titleLarge),
                    Text("Request Status: ${widget.request.status}"),
                    Text("Created: ${widget.request.createdAt.toString().split('.')[0]}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Items", style: Theme.of(context).textTheme.titleMedium),
            Expanded(
              child: ListView.builder(
                itemCount: itemStates.length,
                itemBuilder: (context, index) {
                  final itemState = itemStates[index];
                  final item = itemState['item'] as Item;
                  final bool isItemFulfilled = item.status == 'fulfilled';
                  final bool isItemReassigned = item.status == 'reassigned';
                  final bool isItemEditable = !isItemFulfilled && !isItemReassigned;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: isItemFulfilled ? Colors.green.shade50 : 
                           isItemReassigned ? Colors.orange.shade50 : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text("${item.name} (${item.type})", 
                                     style: Theme.of(context).textTheme.titleMedium),
                              ),
                              if (isItemFulfilled)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'FULFILLED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (isItemReassigned)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'REASSIGNED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text("Quantity: ${item.quantity}"),
                          Text("Current Status: ${item.status}"),
                          const SizedBox(height: 12),
                          
                          // Status dropdown - disabled if item is already fulfilled or reassigned
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'New Status',
                              enabled: isItemEditable,
                            ),
                            value: itemState['status'],
                            items: statusOptions.map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.toUpperCase()),
                            )).toList(),
                            onChanged: isItemEditable ? (newStatus) {
                              setState(() {
                                itemState['status'] = newStatus;
                                if (newStatus != 'reassigned') {
                                  itemState['selectedReceiver'] = null;
                                  itemState['selectedReceiverId'] = null;
                                }
                              });
                            } : null,
                          ),
                          
                          // Show receiver dropdown if status is reassigned and item is editable
                          if (itemState['status'] == 'reassigned' && isItemEditable) ...[
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Reassign to Receiver'),
                              value: itemState['selectedReceiverId'],
                              items: availableReceivers.map((receiver) => DropdownMenuItem<String>(
                                value: receiver['id'],
                                child: Text(receiver['username'] ?? ''),
                              )).toList(),
                              onChanged: (receiverId) {
                                setState(() {
                                  itemState['selectedReceiverId'] = receiverId;
                                  // Also store the receiver object for easy access
                                  itemState['selectedReceiver'] = availableReceivers.firstWhere(
                                    (r) => r['id'] == receiverId,
                                    orElse: () => <String, String>{},
                                  );
                                });
                              },
                              validator: (value) {
                                if (itemState['status'] == 'reassigned' && value == null) {
                                  return 'Please select a receiver for reassignment';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Reason for Reassignment (Optional)',
                                hintText: 'e.g., Out of stock, Wrong department, etc.',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                              onChanged: (value) {
                                setState(() {
                                  itemState['reassignmentReason'] = value;
                                });
                              },
                              validator: (value) {
                                // Optional field, no validation required
                                return null;
                              },
                            ),
                          ],
                          
                          // Show message if item is fulfilled
                          if (isItemFulfilled) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This item has been fulfilled and cannot be edited',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          // Show message if item is reassigned
                          if (isItemReassigned) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.shade300),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.assignment_return, color: Colors.orange, size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This item has been reassigned to another receiver. Please wait for them to approve or reject it.',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Set all editable items to fulfilled (exclude fulfilled and reassigned)
                      setState(() {
                        for (var itemState in itemStates) {
                          final item = itemState['item'] as Item;
                          if (item.status != 'fulfilled' && item.status != 'reassigned') {
                            itemState['status'] = 'fulfilled';
                            itemState['selectedReceiver'] = null;
                          }
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Approve All"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Set all editable items to out_of_stock (exclude fulfilled and reassigned)
                      setState(() {
                        for (var itemState in itemStates) {
                          final item = itemState['item'] as Item;
                          if (item.status != 'fulfilled' && item.status != 'reassigned') {
                            itemState['status'] = 'out_of_stock';
                            itemState['selectedReceiver'] = null;
                          }
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Reject All"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Validate reassignments
                  bool isValid = true;
                  for (var itemState in itemStates) {
                    if (itemState['status'] == 'reassigned' && itemState['selectedReceiver'] == null) {
                      isValid = false;
                      break;
                    }
                  }
                  
                  if (isValid) {
                    _submitRequest();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select receivers for all reassigned items')),
                    );
                  }
                },
                child: const Text("Submit Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
