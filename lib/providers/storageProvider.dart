import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;


class StorageProvider with ChangeNotifier{


  Future<String?> uploadImageToCloudinary(File image) async {
    final String cloudName = dotenv.env['CLOUD_NAME']!;
    final String uploadPreset = dotenv.env['UPLOAD_PRESET']!;

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    var request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        image.path,
        filename: path.basename(image.path),
      ));

    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseData.body);
        return jsonResponse['secure_url'];
      } else {
        print('Failed to upload image: ${responseData.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }


}