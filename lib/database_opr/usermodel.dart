

class UserModel{
  final String? id;
  final String fullName;
  final String email;
  final String password;

  const UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password
  });

  ToJson(){
    return{
      "fullName": fullName,
      "email": email,
      "password": password
    };
  }
}

