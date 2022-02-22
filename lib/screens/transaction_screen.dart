import 'package:flutter/material.dart';
import 'package:hive_database/models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../boxes.dart';
import '../widgets/transaction_dialog_widget.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  void dispose() {
    Hive.close();
    // or Hive.box('transactions').close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('hive expense tracker'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<Transaction>>(
        valueListenable: Boxes.getTransactions().listenable(),
        builder: (context, box, _) {
          final transactions = box.values.toList().cast<Transaction>();

          return buildContent(transactions);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => TransactionDialogWidget(
            onClickedDone: addTransaction,
          ),
        ),
      ),
    );
  }

  addTransaction(String name, double amount, bool isExpense) async {
    final transaction = Transaction()
      ..name = name
      ..amount = amount
      ..isExpense = isExpense
      ..createdDate = DateTime.now();

    final box = Boxes.getTransactions();
    box.add(transaction); // auto create key
    // or box.put('myKey', transaction);
  }

  Widget buildContent(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No expenses yet!'),
      );
    }

    final netExpense = transactions.fold<double>(
      0,
      (previousValue, transaction) => transaction.isExpense
          ? previousValue - transaction.amount
          : previousValue + transaction.amount,
    );

    final newExpenseString = '\$ ${netExpense.toStringAsFixed(2)}';
    final color = netExpense > 0 ? Colors.green : Colors.red;

    return Column(
      children: [
        const SizedBox(
          height: 24,
        ),
        Text(
          'Net expense: $newExpenseString',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: color,
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: transactions.length,
            itemBuilder: (BuildContext context, int index) {
              final transaction = transactions[index];

              return buildTransaction(context, transaction);
            },
          ),
        ),
      ],
    );
  }

  Widget buildTransaction(BuildContext context, Transaction transaction) {
    final color = transaction.isExpense ? Colors.red : Colors.green;
    final date = DateFormat.yMMMd().format(transaction.createdDate);
    final amount = '\$ ' + transaction.amount.toStringAsFixed(2);

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Text(
          transaction.name,
          maxLines: 2,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          buildButtons(context, transaction),
        ],
      ),
    );
  }

  buildButtons(BuildContext context, Transaction transaction) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TransactionDialogWidget(
                  transaction: transaction,
                  onClickedDone: (name, amount, isExpense) =>
                      editTransaction(transaction, name, amount, isExpense),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: TextButton.icon(
            onPressed: () => deleteTransaction(transaction),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
          ),
        ),
      ],
    );
  }

  editTransaction(
      Transaction transaction, String name, double amount, bool isExpense) {
    transaction.name = name;
    transaction.amount = amount;
    transaction.isExpense = isExpense;

    transaction.save();

    // or
    // final box = Boxes.getTransactions();
    // box.put(transaction.key, transaction);
  }

  deleteTransaction(Transaction transaction) {
    transaction.delete();

    // or
    // final box = Boxes.getTransactions();
    // box.delete(transaction.key);
  }
}
