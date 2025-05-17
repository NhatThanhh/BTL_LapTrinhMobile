import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:btl_quanlychitieu/screens/profile/edit_profile.dart';
import 'package:btl_quanlychitieu/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloudinary_public/cloudinary_public.dart';


class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class CloudinaryService {
  // Khởi tạo một lần duy nhất
  static final _cloudinary = CloudinaryPublic(
    'dfejmhapw',    // thay bằng Cloud name của bạn
    'upload-hygcdh8r', // upload preset unsigned
    cache: false,
  );

  /// Upload image, trả về secureUrl hoặc null nếu lỗi
  Future<String?> uploadImage(File file) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }
}
class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? user;
  bool isLogoutLoading = false;
  bool isUploading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  Future<void> logOut() async {
    setState(() {
      isLogoutLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (user != null) {
        // Kiểm tra nếu người dùng đăng nhập bằng Google
        if (user!.providerData
            .any((provider) => provider.providerId == 'google.com')) {
          await googleSignIn.signOut(); // Đăng xuất Google
        }
        await FirebaseAuth.instance.signOut(); // Đăng xuất Firebase
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginView()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng xuất. Thử lại'),
        ),
      );
    } finally {
      setState(() {
        isLogoutLoading = false;
      });
    }
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (picked == null) return null;
    return File(picked.path);
  }
// trong class _ProfileScreenState
  Future<void> _pickAndUploadImage() async {
    final file = await _pickImage();      // chọn file
    if (file == null) return;

    setState(() {
      isUploading = true;
    });

    final url = await CloudinaryService().uploadImage(file);
    if (url != null) {
      // cập nhật URL vào Firestore
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .update({'avatarUrl': url});
      // lưu file để preview ngay
      setState(() {
        _imageFile = file;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload ảnh thất bại')),
      );
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Center(

          child: Text(
            'Thông tin cá nhân',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Không tìm thấy dữ liệu'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.black,
                      backgroundImage: userData['avatarUrl'] != null
                          ? NetworkImage(userData['avatarUrl'])
                          : AssetImage('assets/profile_picture.png')
                              as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  userData['username'] ?? '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  userData['email'] ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 16),
                if (isUploading) CircularProgressIndicator(),
                ProfileOption(
                  icon: Icons.edit,
                  title: 'Thay đổi thông tin',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile()),
                    );
                  },
                ),
                Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.shade100,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: isLogoutLoading ? null : logOut,
                  child: isLogoutLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text('Đăng xuất', style: TextStyle( fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOption({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
      onTap: onTap,
    );
  }
}
