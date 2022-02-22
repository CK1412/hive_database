import 'package:flutter/material.dart';
import 'package:hive_database/models/transaction.dart';

class TransactionDialogWidget extends StatefulWidget {
  const TransactionDialogWidget({
    Key? key,
    this.transaction,
    required this.onClickedDone,
  }) : super(key: key);

  final Transaction? transaction;
  final Function(String name, double amount, bool isExpense) onClickedDone;

  @override
  State<TransactionDialogWidget> createState() =>
      _TransactionDialogWidgetState();
}

class _TransactionDialogWidgetState extends State<TransactionDialogWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isExpense = true;

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      _nameController.text = transaction.name;
      _amountController.text = transaction.amount.toString();
      _isExpense = transaction.isExpense;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    final title = isEditing ? 'Edit transaction' : 'Add transaction';

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              buildName(),
              const SizedBox(height: 8),
              buildAmount(),
              const SizedBox(height: 8),
              buildRadioButtons(),
            ],
          ),
        ),
      ),
      actions: [
        buildCancelButton(),
        buildAddButton(context, isEditing: isEditing),
      ],
    );
  }

  buildName() => TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter name',
        ),
        validator: (name) =>
            name != null && name.isEmpty ? 'Enter a name' : null,
      );

  buildAmount() => TextFormField(
        controller: _amountController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter amount',
        ),
        validator: (amount) => amount != null && double.tryParse(amount) == null
            ? 'Enter a valid number'
            : null,
        keyboardType: TextInputType.number,
      );

  buildRadioButtons() => Column(
        children: [
          RadioListTile(
              title: const Text('Expense'),
              value: true,
              groupValue: _isExpense,
              onChanged: (value) {
                setState(() {
                  _isExpense = value as bool;
                });
              }),
          RadioListTile(
              title: const Text('Income'),
              value: false,
              groupValue: _isExpense,
              onChanged: (value) {
                setState(() {
                  _isExpense = value as bool;
                });
              }),
        ],
      );

  buildCancelButton() => TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      );

  buildAddButton(BuildContext context, {required bool isEditing}) {
    final text = isEditing ? 'Edit' : 'Save';

    return TextButton(
      onPressed: () async {
        final bool isValid = _formKey.currentState!.validate();
        if (isValid) {
          final name = _nameController.text.trim();
          final amount = double.tryParse(_amountController.text) ?? 0;
          widget.onClickedDone(name, amount, _isExpense);
          Navigator.of(context).pop();
        }
      },
      child: Text(text),
    );
  }
}
