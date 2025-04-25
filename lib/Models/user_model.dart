class UserModel {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String phone;
  final int remainingAmount;
  final int totalCredit;
  final int totalDebit;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
    this.remainingAmount = 0,
    this.totalCredit = 0,
    this.totalDebit = 0,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'remainingAmount': remainingAmount,
      'totalCredit': totalCredit,
      'totalDebit': totalDebit,
    };

    if (id != null) {
      map['id'] = id !;
    }

    return map;
  }


  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'],
      remainingAmount: map['remainingAmount'],
      totalCredit: map['totalCredit'],
      totalDebit: map['totalDebit'],
    );
  }
}
