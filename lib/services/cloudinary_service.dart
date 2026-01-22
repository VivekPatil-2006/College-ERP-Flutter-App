import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {

  // YOUR CLOUDINARY DETAILS
  static const String cloudName = "diqqlmass";
  static const String uploadPreset = "student_upload";

  static Future<String?> uploadFile(File file) async {

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/raw/upload",
    );

    var request = http.MultipartRequest("POST", url);

    // Upload preset
    request.fields['upload_preset'] = uploadPreset;

    // Attach file
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

    // Send request
    var response = await request.send();

    if (response.statusCode == 200) {

      final responseData = await response.stream.bytesToString();
      final jsonMap = json.decode(responseData);

      // This is the file download URL
      return jsonMap['secure_url'];

    } else {

      print("Cloudinary Upload Failed");
      return null;
    }
  }
}
