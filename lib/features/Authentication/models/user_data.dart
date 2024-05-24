// This file is the model for the user data. user data contains the user's name, email, and uid, default theme and default filter.

class UserData {
  late String name;
  late String email;
  late String uid;
  late String defaultTheme;
  late String defaultFilter;

  UserData(
      {required this.name,
      required this.email,
      required this.uid,
      required this.defaultTheme,
      required this.defaultFilter});

  UserData.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    email = map['email'];
    uid = map['uid'];
    defaultTheme = map['defaultTheme'];
    defaultFilter = map['defaultFilter'];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'uid': uid,
      'defaultTheme': defaultTheme,
      'defaultFilter': defaultFilter,
    };
  }
}
