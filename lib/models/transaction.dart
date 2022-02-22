import 'package:hive/hive.dart';
part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  late String name;
  @HiveField(1)
  late DateTime createdDate;
  @HiveField(2)
  late bool isExpense = true; // or income
  @HiveField(3)
  late double amount;
}

// After creating the above lines, we run the command below
// flutter packages pub run build_runner build