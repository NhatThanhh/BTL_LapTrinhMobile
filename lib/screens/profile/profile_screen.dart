import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:money_management/models/local_db_service.dart';
import 'package:money_management/screens/login_screen.dart';
import 'package:money_management/screens/profile/edit_profile.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final VoidCallback? onDataRestored;
  const ProfileScreen({super.key, required this.userId, this.onDataRestored});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalDbService _dbService = LocalDbService();
  Map<String, dynamic>? userData;
  bool isLogoutLoading = false;
  bool isUploading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _dbService.getUserById(widget.userId);
    setState(() {
      userData = user?.toMap();
    });
  }

  Future<void> logOut() async {
    setState(() {
      isLogoutLoading = true;
    });

    try {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginView()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi đăng xuất. Thử lại')),
        );
      }
    } finally {
      setState(() {
        isLogoutLoading = false;
      });
    }
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  //
  //   if (pickedFile != null && context.mounted) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //     });
  //     await _uploadImage();
  //   }
  // }

  // Future<void> _uploadImage() async {
  //   if (_imageFile == null) return;
  //   setState(() {
  //     isUploading = true;
  //   });
  //
  //   try {
  //     // Lưu ảnh vào thư mục ứng dụng
  //     final directory = await getApplicationDocumentsDirectory();
  //     final avatarPath =
  //         '${directory.path}/user_avatars/${widget.userId}.jpg';
  //     final file = await _imageFile!.copy(avatarPath);
  //
  //     // Cập nhật avatarPath trong UserModel
  //     await _dbService.updateUserAvatar(widget.userId, file.path);
  //
  //     // Làm mới dữ liệu người dùng
  //     await _loadUserData();
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Lỗi tải ảnh: $e')),
  //       );
  //     }
  //   } finally {
  //     setState(() {
  //       isUploading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Thông tin cá nhân',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.black,
                  backgroundImage: userData!['avatarPath'] != null
                      ? FileImage(File(userData!['avatarPath']))
                      : const AssetImage('assets/profile_picture.png')
                  as ImageProvider,
                ),
                // Positioned(
                //   bottom: 0,
                //   right: 0,
                //   child: GestureDetector(
                //     onTap: _pickImage,
                //     child: const CircleAvatar(
                //       radius: 18,
                //       backgroundColor: Colors.white,
                //       child: CircleAvatar(
                //         radius: 16,
                //         backgroundColor: Colors.blue,
                //         child: Icon(
                //           Icons.edit,
                //           color: Colors.white,
                //           size: 16,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              userData!['username'] ?? '',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              userData!['email'] ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (isUploading) const CircularProgressIndicator(),
            ProfileOption(
              icon: Icons.edit,
              title: 'Thay đổi thông tin',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditProfile(userId: widget.userId,
                          onDataRestored: widget.onDataRestored,
                        ),
                  ),
                );
              },
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade100,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: isLogoutLoading ? null : logOut,
              child: isLogoutLoading
                  ? const CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
      onTap: onTap,
    );
  }
}