import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/blur_request.dart';

class FaceBlurService {
  final String baseUrl = 'http://localhost:8000';
  final Dio dio = Dio();

  Future<BlurRequest> processImage({
    required dynamic imageFile,
    required List<String> unblurParts,
    required int blurStrength,
  }) async {
    try {
      // 이미지를 base64로 변환
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // 요청 객체 생성
      final request = BlurRequest(
        originalImage: base64Image,
        unblurParts: unblurParts,
        blurStrength: blurStrength,
      );

      // API 호출
      final response = await dio.post(
        '$baseUrl/process_image',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
        ),
      );

      // 두 이미지를 디코딩
      final String partialBlurBase64 = response.data['partial_blur_image'];
      final String fullBlurBase64 = response.data['full_blur_image'];

      // 블러 처리된 이미지들을 포함한 새로운 BlurRequest 객체 반환
      return request.copyWith(
        partialBlurredImage: base64Decode(partialBlurBase64),
        fullBlurredImage: base64Decode(fullBlurBase64),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // 422 에러는 서버에서 보낸 상세 메시지를 표시
        // '사진에서 얼굴을 찾을 수 없습니다. 얼굴이 잘 나오는 사진을 업로드해주세요.'
        throw Exception(e.response?.data['detail'] ?? '이미지 처리 중 오류가 발생했습니다.');
      }
      throw Exception('이미지 처리 중 오류가 발생했습니다: ${e.message}');
    } catch (e) {
      throw Exception('이미지 처리 중 오류가 발생했습니다: $e');
    }
  }
}
