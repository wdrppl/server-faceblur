import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/blur_request.dart';

class FaceBlurService {
  final String baseUrl = 'http://0.0.0.0:8000';
  final dio = Dio();

  Future<Uint8List> processImage({
    required File imageFile,
    required List<String> unblurParts,
    required int blurStrength,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final request = BlurRequest(
        base64Image: base64Image,
        unblurParts: unblurParts,
        blurStrength: blurStrength,
      );

      final response = await dio.post(
        '$baseUrl/process_image',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200) {
        final String base64Response = response.data['processed_image'];
        return base64Decode(base64Response);
      } else {
        throw Exception('이미지 처리 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('서버 통신 오류: $e');
    }
  }
}
