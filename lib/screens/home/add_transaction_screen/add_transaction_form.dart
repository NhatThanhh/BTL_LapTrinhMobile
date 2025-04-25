import 'package:flutter/material.dart';
import 'package:money_management/utils/appvalidator.dart';
import 'package:money_management/models/transaction_model.dart';
import 'package:money_management/models/user_model.dart';
import 'package:money_management/models/local_db_service.dart';
import 'package:money_management/Models/category_model.dart';
import 'package:money_management/screens/home/add_transaction_screen/category_dropdown.dart';
import 'package:intl/intl.dart';

class AddTransactionForm extends StatefulWidget {
  final int userId; // cần truyền userId từ màn trước
  final VoidCallback? onTransactionAdded;
  const AddTransactionForm({super.key, required this.userId, this.onTransactionAdded});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  var type = "credit";
  String category = "Khác";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var isLoader = false;
  var appValidator = AppValidator();
  final amountEditController = TextEditingController();
  final titleEditController = TextEditingController();
  DateTime? _selectedDate;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });
    try{
      final user = await LocalDbService.instance.getUserById(widget.userId);
      if (user == null) return;

      final amount = int.parse(amountEditController.text);
      final date = _selectedDate ?? DateTime.now();
      final timestamp = date.microsecondsSinceEpoch; //thoi gian thuc te
      final monthYear = DateFormat('M/y').format(date);
      // Get categoryId
      final allCategories = await LocalDbService.instance.getAllCategories();
      final selectedCategory = allCategories.firstWhere(
            (cat) => cat.name == category && cat.type == type,
        orElse: () => CategoryModel(id: null, name: category, type: type),
      );

      int categoryId;
      if (selectedCategory.id == null) {
        categoryId = await LocalDbService.instance.insertCategory(selectedCategory);
      } else {
        categoryId = selectedCategory.id!;
      }

      final tx = TransactionModel(
        title: titleEditController.text,
        amount: amount,
        type: type,
        timestamp: timestamp,
        categoryId: categoryId,
        date: date,
        monthYear: monthYear,
        userId: widget.userId,
      );

      await LocalDbService.instance.insertTransaction(tx);

      // Cập nhật thông tin user
      int newRemaining = user.remainingAmount;
      int newTotalCredit = user.totalCredit;
      int newTotalDebit = user.totalDebit;

      if (type == 'credit') {
        newRemaining += amount;
        newTotalCredit += amount;
      } else {
        newRemaining -= amount;
        newTotalDebit += amount;
      }

      final updatedUser = UserModel(
        id: user.id,
        username: user.username,
        email: user.email,
        password: user.password,
        phone: user.phone,
        remainingAmount: newRemaining,
        totalCredit: newTotalCredit,
        totalDebit: newTotalDebit,
      );
      await LocalDbService.instance.updateUser(updatedUser);
      setState(() {
        isLoader = false;
      });
      widget.onTransactionAdded?.call();
      Navigator.pop(context);
    }catch (e){
      setState(() {
        isLoader = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Giao dịch mới", style: TextStyle(fontSize: 24)),
            TextFormField(
              controller: titleEditController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: appValidator.isEmptyCheck,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextFormField(
              controller: amountEditController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: appValidator.isEmptyCheck,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Số tiền'),
            ),
            TextButton(
              onPressed: _presentDatePicker,
              child: Text(
                _selectedDate == null
                    ? 'Chọn ngày'
                    : 'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            CategoryDropdown(
              cattype: category,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    category = value;
                  });
                }
              },
            ),
            DropdownButtonFormField(
              value: type,
              items: const [
                DropdownMenuItem(
                  child: Text('Thu'),
                  value: 'credit',
                ),
                DropdownMenuItem(
                  child: Text('Chi'),
                  value: 'debit',
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    type = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (!isLoader) _submitForm();
              },
              child: isLoader
                  ? const Center(child: CircularProgressIndicator())
                  : const Text("Thêm giao dịch"),
            )
          ],
        ),
      ),
    );
  }
}
