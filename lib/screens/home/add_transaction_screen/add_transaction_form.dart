import 'package:flutter/material.dart';
import 'package:money_management/utils/appvalidator.dart';
import 'package:money_management/models/transaction_model.dart';
import 'package:money_management/models/user_model.dart';
import 'package:money_management/models/local_db_service.dart';
import 'package:money_management/Models/category_model.dart';
import 'package:money_management/screens/home/add_transaction_screen/category_dropdown.dart';
import 'package:intl/intl.dart';

class AddTransactionForm extends StatefulWidget {
  final int userId;
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
  DateTime? _selectedDate = DateTime.now();

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final Color primaryColor = Color(0xFF4285F4);
  final Color creditColor = Color(0xFF34A853);
  final Color debitColor = Color(0xFFEA4335);

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Color(0xFF2C3E50),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
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
      try {
        final user = await LocalDbService.instance.getUserById(widget.userId);
        if (user == null) return;

        final amount = int.parse(amountEditController.text.replaceAll(RegExp(r'[^0-9]'), ''));
        final date = _selectedDate ?? DateTime.now();
        final timestamp = date.microsecondsSinceEpoch;
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Giao dịch đã được thêm thành công!'),
              ],
            ),
            backgroundColor: type == 'credit' ? creditColor : debitColor,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (e) {
        setState(() {
          isLoader = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Lỗi: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _formatCurrency() {
    String text = amountEditController.text;
    if (text.isEmpty) return;

    // Chỉ giữ lại số
    text = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) {
      amountEditController.text = '';
      return;
    }

    int amount = int.parse(text);
    // Định dạng tiền tệ và bỏ phần thập phân
    String formattedAmount = currencyFormat.format(amount).split(',')[0];

    // Cập nhật text field với vị trí con trỏ phù hợp
    amountEditController.value = TextEditingValue(
      text: formattedAmount,
      selection: TextSelection.collapsed(offset: formattedAmount.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with animation
              Container(
                margin: EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle,
                      color: primaryColor,
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Giao dịch mới",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),

              // Chọn loại giao dịch (Credit/Debit)
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            type = 'credit';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: type == 'credit' ? creditColor.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: type == 'credit' ? creditColor : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.arrow_circle_up,
                                color: creditColor,
                                size: 28,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Khoản thu',
                                style: TextStyle(
                                  color: type == 'credit' ? creditColor : Colors.grey.shade600,
                                  fontWeight: type == 'credit' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            type = 'debit';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: type == 'debit' ? debitColor.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: type == 'debit' ? debitColor : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.arrow_circle_down,
                                color: debitColor,
                                size: 28,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Khoản chi',
                                style: TextStyle(
                                  color: type == 'debit' ? debitColor : Colors.grey.shade600,
                                  fontWeight: type == 'debit' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tiêu đề giao dịch
              Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: titleEditController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: appValidator.isEmptyCheck,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề',
                    prefixIcon: Icon(Icons.title, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.05),
                  ),
                ),
              ),

              // Số tiền
              Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: amountEditController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: appValidator.isEmptyCheck,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _formatCurrency();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Số tiền',
                    prefixIcon: Icon(Icons.monetization_on, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.05),
                  ),
                ),
              ),

              // Chọn ngày
              Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: _presentDatePicker,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: primaryColor),
                        SizedBox(width: 12),
                        Text(
                          _selectedDate == null
                              ? 'Chọn ngày'
                              : 'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Chọn danh mục
              Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 1),
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.05),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Icon(Icons.category, color: primaryColor),
                        SizedBox(width: 8),
                        Expanded(
                          child: CategoryDropdown(
                            cattype: category,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  category = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Nút thêm giao dịch
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (!isLoader) _submitForm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: type == 'credit' ? creditColor : debitColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoader
                    ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(type == 'credit' ? Icons.arrow_circle_up : Icons.arrow_circle_down),
                    SizedBox(width: 8),
                    Text(
                      type == 'credit' ? "Thêm khoản thu" : "Thêm khoản chi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}