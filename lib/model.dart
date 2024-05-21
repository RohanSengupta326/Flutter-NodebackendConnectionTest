class UserModel {
  final String accountType;
  final String name;
  final String email;
  final String displayPicture;

  UserModel(
      {required this.accountType,
      required this.name,
      required this.email,
      required this.displayPicture});

  UserModel.empty()
      : accountType = 'accountType',
        name = 'name',
        email = 'email',
        displayPicture = '';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accountType: json['accountType'],
      name: json["name"],
      email: json["email"],
      displayPicture: json['displayPicture'],
    );
  }
//
}
