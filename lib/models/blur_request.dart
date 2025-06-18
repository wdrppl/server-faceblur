import 'dart:typed_data';

class BlurRequest {
  final String originalImage;
  final Uint8List? partialBlurredImage;
  final Uint8List? fullBlurredImage;
  final List<String> unblurParts;
  final int blurStrength;

  BlurRequest({
    required this.originalImage,
    this.partialBlurredImage,
    this.fullBlurredImage,
    required this.unblurParts,
    required this.blurStrength,
  });

  Map<String, dynamic> toJson() {
    return {
      'original_image': originalImage,
      'unblur_parts': unblurParts,
      'blur_strength': blurStrength,
    };
  }

  BlurRequest copyWith({
    String? originalImage,
    Uint8List? partialBlurredImage,
    Uint8List? fullBlurredImage,
    List<String>? unblurParts,
    int? blurStrength,
  }) {
    return BlurRequest(
      originalImage: originalImage ?? this.originalImage,
      partialBlurredImage: partialBlurredImage ?? this.partialBlurredImage,
      fullBlurredImage: fullBlurredImage ?? this.fullBlurredImage,
      unblurParts: unblurParts ?? this.unblurParts,
      blurStrength: blurStrength ?? this.blurStrength,
    );
  }
}
