import 'package:flutter/material.dart';
import 'package:money_management/utils/appvalidator.dart';
import 'package:money_management/models/transaction_model.dart';
import 'package:money_management/models/user_model.dart';
import 'package:money_management/Models/category_model.dart';
import 'package:money_management/models/local_db_service.dart';
import 'package:money_management/screens/home/add_transaction_screen/category_dropdown.dart';
import 'package:intl/intl.dart';

class EditTransactionScreen extends StatefulWidget {
  final int userId;
  final TransactionModel transaction;

  const EditTransactionScreen({
    Key? key,
    required this.userId,
    required this.transaction,
  }) : super(key: key);

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  var type = "credit";
  String category = "Khác";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var isLoader = false;
  var appValidator = AppValidator();
  final amountEditController = TextEditingController();
  final titleEditController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    titleEditController.text = widget.transaction.title;
    amountEditController.text = widget.transaction.amount.toString();
    _selectedDate = widget.transaction.date;
    type = widget.transaction.type;
    _loadCategoryName();
  }

  Future<void> _loadCategoryName() async {
    final categoryModel = await LocalDbService.instance.getCategoryById(widget.transaction.categoryId);
    if (categoryModel != null) {
      setState(() {
        category = categoryModel.name;
      });
    }
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
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

      final user = await LocalDbService.instance.getUserById(widget.userId);
      if (user == null) return;

      final newAmount = int.parse(amountEditController.text);
      final date = _selectedDate ?? DateTime.now();
      final timestamp = date.microsecondsSinceEpoch;
      final monthYear = DateFormat('M/y').format(date);

      // Lấy categoryId
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

      // Tạo TransactionModel mới
      final updatedTransaction = TransactionModel(
        id: widget.transaction.id,
        title: titleEditController.text,
        amount: newAmount,
        type: type,
        timestamp: timestamp,
        categoryId: categoryId,
        date: date,
        monthYear: monthYear,
        userId: widget.userId,
      );

      // Cập nhật giao dịch
      await LocalDbService.instance.updateTransaction(updatedTransaction);

      // Cập nhật thông tin user
      int newRemaining = user.remainingAmount;
      int newTotalCredit = user.totalCredit;
      int newTotalDebit = user.totalDebit;

      // Hoàn tác ảnh hưởng của giao dịch cũ
      if (widget.transaction.type == 'credit') {
        newRemaining -= widget.transaction.amount;
        newTotalCredit -= widget.transaction.amount;
      } else {
        newRemaining += widget.transaction.amount;
        newTotalDebit -= widget.transaction.amount;
      }

      // Áp dụng ảnh hưởng của giao dịch mới
      if (type == 'credit') {
        newRemaining += newAmount;
        newTotalCredit += newAmount;
      } else {
        newRemaining -= newAmount;
        newTotalDebit += newAmount;
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

      Navigator.pop(context);

      setState(() {
        isLoader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Chỉnh sửa giao dịch", style: TextStyle(fontSize: 24)),
              TextFormField(
                controller: titleEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: appValidator.isEmptyCheck,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
              ),
              TextFormField(
                controller: amountEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Số tiền phải là số nguyên';
                  }
                  return null;
                },
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
                    value: 'credit',
                    child: Text('Thu'),
                  ),
                  DropdownMenuItem(
                    value: 'debit',
                    child: Text('Chi'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      type = value.toString();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (!isLoader) {
                    _submitForm();
                  }
                },
                child: isLoader
                    ? const Center(child: CircularProgressIndicator())
                    : const Text("Lưu thay đổi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}