import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/validate.dart';

class EditProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var appValidator = Validate();

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<Map<String, dynamic>?> getUserData(User user) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();
    return userDoc.data() as Map<String, dynamic>?;
  }

  Future<void> editField(
      BuildContext context,
      User user,
      String field,
      String currentValue,
      bool isAuthField,
      Function(Map<String, dynamic>) onSuccess) async {
    TextEditingController _controller =
        TextEditingController(text: currentValue);
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sửa $field'),
          content: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(hintText: 'Nhập $field mới'),
              validator: (value) {
                return appValidator.validateField(field, value);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String newValue = _controller.text;
                  try {
                    if (isAuthField) {
                      if (field == 'email') {
                        await user!.verifyBeforeUpdateEmail(newValue);
                        await _firestore
                            .collection('users')
                            .doc(user!.uid)
                            .update({field: newValue});
                      } else if (field == 'password') {
                        await user!.updatePassword(newValue);
                      }
                    } else {
                      await _firestore
                          .collection('users')
                          .doc(user!.uid)
                          .update({field: newValue});
                    }
                    DocumentSnapshot updatedUserDoc = await _firestore
                        .collection('users')
                        .doc(user.uid)
                        .get();
                    onSuccess(updatedUserDoc.data() as Map<String, dynamic>);
                    Navigator.pop(context);
                  } catch (e) {
                    print('Cập nhật $field thất bại: $e');
                  }
                }
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> changePassword(
      BuildContext context, User user, Function refreshData) async {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thay đổi mật khẩu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(labelText: 'Mật khẩu hiện tại'),
                obscureText: true,
              ),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'Mật khẩu mới'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                String currentPassword = _currentPasswordController.text;
                String newPassword = _newPasswordController.text;
                String confirmPassword = _confirmPasswordController.text;

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mật khẩu mới không giống nhau')),
                  );
                  return;
                }

                try {
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentPassword,
                  );

                  await user.reauthenticateWithCredential(credential);

                  await user.updatePassword(newPassword);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mật khẩu đã được thay đổi')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không thể thay đổi mật khẩu: $e')),
                  );
                }
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> restoreData(
      BuildContext context, User user, Function refreshData) async {
    final _firestore = FirebaseFirestore.instance;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Làm mới dữ liệu'),
          content: Text(
              'Bạn có chắc chắn muốn làm mới dữ liệu? Hành động này sẽ xóa hết các giao dịch và cập nhật lại các giá trị tổng.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Đóng dialog

                QuerySnapshot transactionsSnapshot = await _firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection("transactions")
                    .get();

                // Sao chép giao dịch vào backup collection
                WriteBatch batch = _firestore.batch();
                for (DocumentSnapshot doc in transactionsSnapshot.docs) {
                  batch.set(
                    _firestore
                        .collection('users')
                        .doc(user.uid)
                        .collection('backup')
                        .doc(doc.id),
                    doc.data()!,
                  );
                }

                await batch.commit();

                // Tạo một batch mới để xóa
                WriteBatch deleteBatch = _firestore.batch();
                for (DocumentSnapshot doc in transactionsSnapshot.docs) {
                  deleteBatch.delete(doc.reference);
                }

                await deleteBatch.commit();

                await _firestore.collection('users').doc(user.uid).update({
                  'totalCredit': 0,
                  'totalDebit': 0,
                  'remainingAmount': 0,
                });

                // Fetch updated user data
                DocumentSnapshot updatedUserDoc =
                    await _firestore.collection('users').doc(user.uid).get();
                refreshData(updatedUserDoc.data() as Map<String, dynamic>);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã làm mới dữ liệu'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('Làm mới'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
              },
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }
}
