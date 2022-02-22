import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_database/models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/transaction_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  await Hive.openBox<Transaction>('transactions');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TransactionScreen(),
    );
  }
}
