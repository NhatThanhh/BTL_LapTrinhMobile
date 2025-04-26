import 'package:flutter/material.dart';
import '../utils/appvalidator.dart';
import '../models/local_db_service.dart';
import '../models/user_model.dart';

class EditProfileService {
  final LocalDbService _dbService = LocalDbService();
  var appValidator = AppValidator();

  Future<UserModel?> getCurrentUser(int userId) async {
    return await _dbService.getUserById(userId);
  }

  Future<Map<String, dynamic>?> getUserData(int userId) async {
    final user = await _dbService.getUserById(userId);
    return user?.toMap();
  }

  Future<void> editField(
      BuildContext context,
      int userId,
      String field,
      String currentValue,
      bool isAuthField,
      Function(Map<String, dynamic>) onSuccess,
      ) async {
    TextEditingController controller = TextEditingController(text: currentValue);
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sửa $field'),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(labelText: 'Nhập $field mới'),
              validator: (value) => appValidator.validateField(field, value),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  String newValue = controller.text;
                  try {
                    final user = await _dbService.getUserById(userId);
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không tìm thấy người dùng')),
                      );
                      return;
                    }

                    // Tạo UserModel mới với giá trị cập nhật
                    final updatedUser = UserModel(
                      id: user.id,
                      username: field == 'username' ? newValue : user.username,
                      email: field == 'email' ? newValue : user.email,
                      password: field == 'password' ? newValue : user.password,
                      phone: field == 'phone' ? newValue : user.phone,
                      remainingAmount: user.remainingAmount,
                      totalCredit: user.totalCredit,
                      totalDebit: user.totalDebit,
                    );

                    // Cập nhật vào cơ sở dữ liệu
                    await _dbService.updateUser(updatedUser);

                    // Lấy dữ liệu người dùng đã cập nhật
                    final updatedUserData = await _dbService.getUserById(userId);
                    onSuccess(updatedUserData!.toMap());

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$field đã được cập nhật')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cập nhật $field thất bại: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> changePassword(
      BuildContext context,
      int userId,
      Function(Map<String, dynamic>) refreshData,
      ) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thay đổi mật khẩu'),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
                  obscureText: true,
                  validator: appValidator.validatePassword,
                ),
                TextFormField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                  obscureText: true,
                  validator: appValidator.validatePassword,
                ),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
                  obscureText: true,
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return appValidator.validatePassword(value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  String currentPassword = currentPasswordController.text;
                  String newPassword = newPasswordController.text;

                  try {
                    final user = await _dbService.getUserById(userId);
                    if (user == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không tìm thấy người dùng')),
                        );
                      }
                      return;
                    }

                    // Xác thực mật khẩu hiện tại
                    if (user.password != currentPassword) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mật khẩu hiện tại không đúng')),
                        );
                      }
                      return;
                    }

                    // Cập nhật mật khẩu mới
                    final updatedUser = UserModel(
                      id: user.id,
                      username: user.username,
                      email: user.email,
                      password: newPassword,
                      phone: user.phone,
                      remainingAmount: user.remainingAmount,
                      totalCredit: user.totalCredit,
                      totalDebit: user.totalDebit,
                    );

                    await _dbService.updateUser(updatedUser);

                    // Lấy dữ liệu người dùng đã cập nhật
                    final updatedUserData = await _dbService.getUserById(userId);
                    refreshData(updatedUserData!.toMap());

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mật khẩu đã được thay đổi')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Không thể thay đổi mật khẩu: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> restoreData(
      BuildContext context,
      int userId,
      Function(Map<String, dynamic>) refreshData,
      ) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Làm mới dữ liệu'),
          content: const Text(
            'Bạn có chắc chắn muốn làm mới dữ liệu? Hành động này sẽ xóa hết các giao dịch và đặt lại các giá trị tổng.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  // Lấy người dùng hiện tại
                  final user = await _dbService.getUserById(userId);
                  if (user == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không tìm thấy người dùng')),
                      );
                    }
                    return;
                  }

                  // Xóa tất cả giao dịch của người dùng
                  await _dbService.deleteTransactionsByUserId(userId);

                  // Cập nhật user với các giá trị tổng bằng 0
                  final updatedUser = UserModel(
                    id: user.id,
                    username: user.username,
                    email: user.email,
                    password: user.password,
                    phone: user.phone,
                    remainingAmount: 0,
                    totalCredit: 0,
                    totalDebit: 0,
                  );

                  await _dbService.updateUser(updatedUser);

                  // Lấy dữ liệu người dùng đã cập nhật
                  final updatedUserData = await _dbService.getUserById(userId);
                  refreshData(updatedUserData!.toMap());

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã làm mới dữ liệu')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi làm mới dữ liệu: $e')),
                    );
                  }
                }
              },
              child: const Text('Làm mới'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }
}