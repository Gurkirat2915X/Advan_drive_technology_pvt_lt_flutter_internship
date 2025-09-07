import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:request_app/models/request.dart";
import "package:request_app/models/item.dart";
import 'package:request_app/providers/receivers_provider.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/providers/requests_provider.dart';
import 'package:request_app/services/socket.dart';

class RequestApprovalScreen extends ConsumerStatefulWidget {
  const RequestApprovalScreen({super.key, required this.request});
  final Request request;

  @override
  ConsumerState<RequestApprovalScreen> createState() =>
      _RequestApprovalScreenState();
}

class _RequestApprovalScreenState extends ConsumerState<RequestApprovalScreen> {
  late List<Map<String, dynamic>> itemStates;
  final List<String> statusOptions = [
    "pending",
    "fulfilled",
    "out_of_stock",
    "reassigned",
  ];
  final Map<int, FocusNode> _focusNodes = {};
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    itemStates = widget.request.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      _focusNodes[index] = FocusNode();
      _controllers[index] = TextEditingController();

      return {
        'item': item,
        'status': item.status,
        'selectedReceiver':
            item.status == 'reassigned' && item.reassignedTo != null
            ? {
                'id': item.reassignedTo!,
                'username': 'Previously Assigned Receiver',
              }
            : null,
        'selectedReceiverId': item.status == 'reassigned'
            ? item.reassignedTo
            : null,
        'reassignmentReason': item.status == 'reassigned'
            ? (item.notes ?? 'Previously reassigned')
            : '',
      };
    }).toList();
  }

  @override
  void dispose() {
    _focusNodes.values.forEach((node) => node.dispose());
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _submitRequest() async {
    print('=== REQUEST SUBMISSION ===');
    print('Request ID: ${widget.request.id}');
    print('Request Name: ${widget.request.name}');

    List<Item> updatedItems = [];

    for (int i = 0; i < itemStates.length; i++) {
      final itemState = itemStates[i];
      final item = itemState['item'] as Item;
      print('Item ${i + 1}:');
      print('  Name: ${item.name}');
      print('  Original Status: ${item.status}');
      print('  New Status: ${itemState['status']}');

      Item updatedItem;

      if (itemState['status'] == 'reassigned' &&
          itemState['selectedReceiver'] != null) {
        print(
          '  Reassigned to: ${itemState['selectedReceiver']['username']} (ID: ${itemState['selectedReceiver']['id']})',
        );

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

    Request updatedRequest = Request(
      id: widget.request.id,
      name: widget.request.name,
      userId: widget.request.userId,
      status: widget.request.status,
      items: updatedItems,
      createdAt: widget.request.createdAt,
      receiverId: widget.request.receiverId,
    );

    try {
      await ref
          .read(requestsProvider.notifier)
          .updateRequestWithReassignments(
            ref.watch(authProvider),
            updatedRequest,
            itemStates,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request processed successfully!')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      print('Error updating request: $error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update request')));
    }
  }

  @override
  Widget build(BuildContext context) {
    SocketService().setRef(ref);

    final receivers = ref.watch(receiversProvider);
    final currentUser = ref.watch(authProvider);

    final availableReceivers = receivers
        .where((receiver) => receiver['id'] != currentUser.id)
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Request Approval",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.assignment,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Request Details",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.request.name,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.request.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.request.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Created: ${_formatDate(widget.request.createdAt)}",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${widget.request.items.length} item${widget.request.items.length != 1 ? 's' : ''} requested",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "User ID: ${widget.request.userId}",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "Items for Review",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...itemStates.asMap().entries.map((entry) {
              final index = entry.key;
              final itemState = entry.value;
              final item = itemState['item'] as Item;
              final bool isItemFulfilled = item.status == 'fulfilled';
              final bool isItemReassigned = item.status == 'reassigned';
              final bool isItemEditable = !isItemFulfilled && !isItemReassigned;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isItemFulfilled
                      ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.green.shade900.withOpacity(0.3)
                            : Colors.green.shade50)
                      : isItemReassigned
                      ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.orange.shade900.withOpacity(0.3)
                            : Colors.orange.shade50)
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isItemFulfilled
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.green.shade400
                              : Colors.green.shade200)
                        : isItemReassigned
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.orange.shade400
                              : Colors.orange.shade200)
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Type: ${item.type}",
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (isItemFulfilled)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
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
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.numbers,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Quantity: ${item.quantity}",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Status: ${item.status.toUpperCase()}",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: _getStatusColor(item.status),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isItemEditable
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Update Status',
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            prefixIcon: Icon(
                              Icons.edit_note,
                              color: isItemEditable
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.5),
                            ),
                            enabled: isItemEditable,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          dropdownColor: Theme.of(context).colorScheme.surface,
                          value: itemState['status'],
                          items: statusOptions
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getStatusIcon(status),
                                        size: 20,
                                        color: _getStatusColor(status),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: _getStatusColor(status),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: isItemEditable
                              ? (newStatus) {
                                  setState(() {
                                    itemState['status'] = newStatus;
                                    if (newStatus != 'reassigned') {
                                      itemState['selectedReceiver'] = null;
                                      itemState['selectedReceiverId'] = null;
                                    } else {
                                      Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () {
                                          if (_focusNodes[index] != null) {
                                            _focusNodes[index]!.requestFocus();
                                          }
                                        },
                                      );
                                    }
                                  });
                                }
                              : null,
                        ),
                      ),

                      if (itemState['status'] == 'reassigned') ...[
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Reassign to Receiver',
                              labelStyle: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              prefixIcon: Icon(
                                Icons.person_add,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            dropdownColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            value: itemState['selectedReceiverId'],
                            items: availableReceivers
                                .map(
                                  (receiver) => DropdownMenuItem<String>(
                                    value: receiver['id'],
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.account_circle,
                                          size: 20,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          receiver['username'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: isItemReassigned
                                ? null
                                : (receiverId) {
                                    setState(() {
                                      itemState['selectedReceiverId'] =
                                          receiverId;

                                      itemState['selectedReceiver'] =
                                          availableReceivers.firstWhere(
                                            (r) => r['id'] == receiverId,
                                            orElse: () => <String, String>{},
                                          );
                                    });
                                  },
                            validator: (value) {
                              if (itemState['status'] == 'reassigned' &&
                                  !isItemReassigned &&
                                  value == null) {
                                return 'Please select a receiver for reassignment';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? [
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                          .withOpacity(0.7),
                                    ]
                                  : [Colors.blue.shade50, Colors.blue.shade100],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.blue.shade200,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.note_add,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Reassignment Note',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline.withOpacity(0.5),
                                  ),
                                ),
                                child: Builder(
                                  builder: (context) {
                                    if (_controllers[index] != null) {
                                      _controllers[index]!.text =
                                          itemState['reassignmentReason'];
                                    }
                                    return TextFormField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      readOnly: isItemReassigned,
                                      decoration: InputDecoration(
                                        labelText: isItemReassigned
                                            ? 'Previous Reassignment Reason'
                                            : 'Reason for Reassignment (Optional)',
                                        hintText: isItemReassigned
                                            ? null
                                            : 'e.g., Out of stock, Wrong department, etc.',
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.all(
                                          16,
                                        ),
                                        suffixIcon: isItemReassigned
                                            ? Icon(
                                                Icons.lock,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              )
                                            : null,
                                      ),
                                      maxLines: 3,
                                      textInputAction: TextInputAction.done,
                                      onChanged: isItemReassigned
                                          ? null
                                          : (value) {
                                              setState(() {
                                                itemState['reassignmentReason'] =
                                                    value;
                                              });
                                            },
                                      validator: (value) {
                                        return null;
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (isItemFulfilled) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade100.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This item has been fulfilled and cannot be edited',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (isItemReassigned) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.shade100.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.assignment_return,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This item has been reassigned to another receiver. Please wait for them to approve or reject it.',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
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
            }),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.dashboard_customize,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              for (var itemState in itemStates) {
                                final item = itemState['item'] as Item;
                                if (item.status != 'fulfilled' &&
                                    item.status != 'reassigned') {
                                  itemState['status'] = 'fulfilled';
                                  itemState['selectedReceiver'] = null;
                                }
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text(
                            "Approve All",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              for (var itemState in itemStates) {
                                final item = itemState['item'] as Item;
                                if (item.status != 'fulfilled' &&
                                    item.status != 'reassigned') {
                                  itemState['status'] = 'out_of_stock';
                                  itemState['selectedReceiver'] = null;
                                }
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text(
                            "Reject All",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        bool isValid = true;
                        for (var itemState in itemStates) {
                          if (itemState['status'] == 'reassigned' &&
                              itemState['selectedReceiver'] == null) {
                            isValid = false;
                            break;
                          }
                        }

                        if (isValid) {
                          _submitRequest();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select receivers for all reassigned items',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text(
                        "Submit Changes",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'fulfilled':
        return Colors.green;
      case 'rejected':
      case 'out_of_stock':
        return Colors.red;
      case 'reassigned':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'fulfilled':
        return Icons.check_circle;
      case 'reassigned':
        return Icons.swap_horiz;
      case 'pending':
        return Icons.pending;
      case 'rejected':
      case 'out_of_stock':
        return Icons.cancel;
      case 'approved':
        return Icons.verified;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
