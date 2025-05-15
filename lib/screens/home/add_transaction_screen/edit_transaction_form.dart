import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:btl_quanlychitieu/screens/home/add_transaction_screen/category_dropdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? transactionData;

  const EditTransactionScreen({
    Key? key,
    this.userData,
    this.transactionData,
  }) : super(key: key);

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  var type = "credit";
  var category = "Khác";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var isLoader = false;
  var amountEditController = TextEditingController();
  var titleEditController = TextEditingController();
  DateTime? _selectedDate;

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final Color primaryColor = Color(0xFF4285F4);
  final Color creditColor = Color(0xFF34A853);
  final Color debitColor = Color(0xFFEA4335);

  @override
  void initState() {
    super.initState();

    if (widget.transactionData != null) {
      titleEditController.text = widget.transactionData!['title'];
      amountEditController.text = widget.transactionData!['amount'].toString();
      _selectedDate = widget.transactionData!['date']?.toDate();
      category = widget.transactionData!['category'];
      type = widget.transactionData!['type'];

      // Format số tiền khi hiển thị
      _formatCurrency();
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

      // Giữ nguyên logic gốc
      final String transactionId = widget.transactionData!['id'];

      // Xử lý khi có định dạng tiền tệ
      String amountText = amountEditController.text;
      amountText = amountText.replaceAll(RegExp(r'[^0-9]'), '');
      final int newAmount = int.parse(amountText);

      final DateTime date = _selectedDate ?? DateTime.now();
      final int newTimestamp = date.microsecondsSinceEpoch;

      final existingTransactionDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .get();

      final existingTransactionData = existingTransactionDoc.data()!;
      final int oldAmount = existingTransactionData['amount'];
      final String oldType = existingTransactionData['type'];
      final int oldTimestamp = existingTransactionData['timestamp'];

      int creditChange = 0;
      int debitChange = 0;

      if (oldType == 'credit') {
        creditChange = -oldAmount;
      } else {
        debitChange = -oldAmount;
      }

      if (newAmount > 0) {
        if (type == 'credit') {
          creditChange += newAmount;
        } else {
          debitChange += newAmount;
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .update({
        'amount': newAmount,
        'type': type,
        'totalAmount': newAmount,
        'date': date,
        'timestamp': oldTimestamp,
        'category': category,
      });


      final userDoc =
      FirebaseFirestore.instance.collection('users').doc(userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDoc);
        final userData = userSnapshot.data()!;

        int totalCredit = (userData['totalCredit'] as int) + creditChange;
        int totalDebit = (userData['totalDebit'] as int) + debitChange;
        int remainingAmount = totalCredit - totalDebit;

        transaction.update(userDoc, {
          'totalCredit': totalCredit,
          'totalDebit': totalDebit,
          'remainingAmount': remainingAmount,
        });
      });

      Navigator.pop(context);
      setState(() {
        isLoader = false;
      });

      // Thêm thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Giao dịch đã được cập nhật thành công!'),
            ],
          ),
          backgroundColor: type == 'credit' ? creditColor : debitColor,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                margin: EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: primaryColor,
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Chỉnh sửa giao dịch",
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tiêu đề';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số tiền';
                    }
                    // Loại bỏ định dạng tiền tệ để kiểm tra
                    String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (int.tryParse(numericValue) == null) {
                      return 'Số tiền phải là số nguyên';
                    }
                    return null;
                  },
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

              // Nút lưu thay đổi
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
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text(
                      "Lưu thay đổi",
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