class UserModel {
  final String name;
  final String email;
  final String id;

  UserModel({required this.name, required this.email, required this.id});

  UserModel.empty()
      : name = 'name',
        email = 'email',
        id = 'id';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"],
      email: json["email"],
      id: json["_id"],
    );
  }
//
}
