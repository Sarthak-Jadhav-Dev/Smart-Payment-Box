import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_provider.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(paymentProvider);
    
    final filtered = transactions.where((tx) => 
      tx.senderName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
      tx.amount.toString().contains(_searchQuery)
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or amount',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
        ),
      ),
      body: filtered.isEmpty 
        ? const Center(child: Text('No transactions found'))
        : ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final tx = filtered[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.payment, color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                title: Text('Received from ${tx.senderName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${tx.timestamp.day}/${tx.timestamp.month} • ${tx.sourceApp}'),
                trailing: Text(
                  '+ ₹${tx.amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            },
          ),
    );
  }
}
