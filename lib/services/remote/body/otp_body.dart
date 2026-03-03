class OtpBody {
  String? email;

  OtpBody();

  // factory OtpBody.fromJson(Map<String, dynamic> json) =>
  //     OtpBody()..email = json['email'];

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}
