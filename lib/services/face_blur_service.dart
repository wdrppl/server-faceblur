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

      try {
        final response = await dio.post(
          '$baseUrl/process_image',
          data: request.toJson(),
          options: Options(
            headers: {'Content-Type': 'application/json'},
            responseType: ResponseType.json,
          ),
        );

        final String base64Response = response.data['processed_image'];
        return base64Decode(base64Response);
      } on DioException catch (e) {
        if (e.response?.statusCode == 422) {
          // 422 에러는 얼굴 감지 실패 등 사용자에게 보여줄 수 있는 에러
          throw Exception(e.response?.data['detail'] ?? '이미지 처리 중 오류가 발생했습니다.');
        } else {
          // 그 외 서버 에러
          throw Exception('서버 통신 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
        }
      }
    } catch (e) {
      // throw Exception('이미지 처리 중 오류가 발생했습니다: $e');
      throw Exception('$e');
    }
  }
}
