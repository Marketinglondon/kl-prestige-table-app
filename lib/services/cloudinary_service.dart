import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';

class CloudinaryService {
  static Future<String?> subirImagen(File imagen) async {
    try {
      final uri = Uri.parse(AppConfig.cloudinaryUploadUrl);
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = AppConfig.cloudinaryUploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', imagen.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['secure_url'] as String?;
      } else {
        print('Error subiendo imagen: $responseBody');
        return null;
      }
    } catch (e) {
      print('Excepción subiendo imagen: $e');
      return null;
    }
  }

  static Future<List<String>> subirImagenes(List<File> imagenes) async {
    List<String> urls = [];
    for (final imagen in imagenes) {
      final url = await subirImagen(imagen);
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }
}
