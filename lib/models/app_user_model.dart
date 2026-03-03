class AppUserModel {
  String? id;
  String? name;
  String? email;
  String? password;
  int? age;
  String? avatar;
  String? createdAt;
  String? updatedAt;
  int? v;

  AppUserModel();

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel()
      ..id = json['_id'] as String
      ..name = json['name'] as String?
      ..email = json['email'] as String
      ..password = json['password'] as String?
      ..age = json['age'] as int?
      ..avatar = json['avatar'] as String?
      ..createdAt = json['createdAt'] as String?
      ..updatedAt = json['updatedAt'] as String?
      ..v = json['__v'] as int?;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'avatar': avatar,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}

class AppUserModel2 {
  String? id;
  String? name;
  String? email;
  String? password;
  int? age;
  String? avatar;
  String? createdAt;
  String? updatedAt;
  int? v;

  AppUserModel2({
    this.id,
    this.name,
    this.email,
    this.password,
    this.age,
    this.avatar,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory AppUserModel2.fromJson(Map<String, dynamic> json) {
    return AppUserModel2(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      age: json['age'] as int?,
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'avatar': avatar,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
