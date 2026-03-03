import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:todolist_app/constants/app_constant.dart';

class PostImage {
  Future<String?> uploadFile(File file) async {
    const url = AppConstant.endPointUploadFile;
    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.files.addAll([
      await http.MultipartFile.fromPath('file', file.path),
    ]);
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${null}',
    });

    final stream = await request.send();

    final response = await http.Response.fromStream(stream).then((value) {
      if (value.statusCode == 200) {
        return value;
      }
      throw Exception('Failed to load data');
    });

    Map<String, dynamic> result = jsonDecode(response.body);
    dev.log('object ${result['body']['file']}');
    return result['body']['file'];
  }

  Future<String?> post({required File image}) async {
    return await uploadFile(image);
  }
}
