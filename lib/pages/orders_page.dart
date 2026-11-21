import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/role_provider.dart';
import '../providers/supabase_provider.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  Future<List<Map<String, dynamic>>> _fetch(WidgetRef ref) async {
    final client = ref.read(supabaseProvider);
    final response = await client
        .from('orders')
        .select('*, order_items(*, products(name))')
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<void> _setStatus(
    WidgetRef ref,
    Map<String, dynamic> order,
    String status,
  ) async {
    await ref
        .read(supabaseProvider)
        .from('orders')
        .update({'status': status})
        .eq('id', order['id']);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminProvider);
    return Scaffold(
      appBar: AppBar(
        title: isAdminAsync.value == true
            ? const Text('Admin orders')
            : const Text('My orders'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetch(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          final isAdmin = isAdminAsync.value == true;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (_, index) {
              final order = orders[index];
              final items = (order['order_items'] as List? ?? [])
                  .cast<Map<String, dynamic>>();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order['id']}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Chip(label: Text('${order['status']}')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final item in items)
                        Text(
                          '${item['quantity']} x ${item['products']?['name'] ?? 'Product'}'
                          ' @ ₱${item['unit_price']}',
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Total: ₱${order['total']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                await _setStatus(ref, order, 'processing');
                              },
                              child: const Text('Processing'),
                            ),
                            OutlinedButton(
                              onPressed: () async {
                                await _setStatus(ref, order, 'completed');
                              },
                              child: const Text('Completed'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
