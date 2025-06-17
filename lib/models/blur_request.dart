class BlurRequest {
  final String base64Image;
  final List<String> unblurParts;
  final int blurStrength;

  BlurRequest({
    required this.base64Image,
    required this.unblurParts,
    required this.blurStrength,
  });

  Map<String, dynamic> toJson() => {
    'image': base64Image,
    'unblur_parts': unblurParts,
    'blur_strength': blurStrength,
  };
}
