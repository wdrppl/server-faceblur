import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/face_blur_service.dart';

class FaceBlurScreenA extends StatefulWidget {
  const FaceBlurScreenA({super.key});

  @override
  FaceBlurScreenAState createState() => FaceBlurScreenAState();
}

class FaceBlurScreenAState extends State<FaceBlurScreenA> {
  final FaceBlurService _service = FaceBlurService();
  File? _imageFile;
  Uint8List? _processedImage;
  Uint8List? _fullBlurredImage;
  // ignore: prefer_final_fields
  List<String> _selectedParts = ['Left'];
  double _blurStrength = 66;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('얼굴 블러 처리'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_imageFile == null)
                  Center(
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '이미지 선택',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_imageFile != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _processedImage != null
                        ? Image.memory(_processedImage!)
                        : Image.file(_imageFile!),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.grey[300],
                    ),
                    child: const Text(
                      '사진 변경하기',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '블러 강도: ${_blurStrength.round()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _blurStrength,
                    min: 60,
                    max: 80,
                    divisions: 10,
                    label: _blurStrength.round().toString(),
                    onChanged: (value) => setState(() => _blurStrength = value),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '블러 해제 영역:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ['Left', 'Mouth', 'Right'].map((part) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _selectedParts.contains(part),
                                onChanged: (selected) {
                                  setState(() {
                                    if (selected ?? false) {
                                      _selectedParts.add(part);
                                    } else {
                                      _selectedParts.remove(part);
                                    }
                                  });
                                },
                              ),
                              Text(part),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _processImage,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                          child: const Text(
                            '블러 처리',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: _processedImage == null
                              ? null
                              : _resetBlur,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.grey[300],
                          ),
                          child: const Text(
                            '블러 리셋',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_fullBlurredImage != null) ...[
                    const SizedBox(height: 20),
                    const Text(
                      '전체 블러 처리된 이미지',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(_fullBlurredImage!),
                    ),
                  ],
                ],
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _processedImage = null;
        _selectedParts = ['Left']; // 기본값을 Left로
      });
    }
  }

  Future<void> _resetBlur() async {
    setState(() {
      _processedImage = null;
      _fullBlurredImage = null;
    });
  }

  Future<void> _processImage() async {
    if (_imageFile == null) return;

    setState(() => _isLoading = true);

    try {
      final processedRequest = await _service.processImage(
        imageFile: _imageFile!,
        unblurParts: _selectedParts,
        blurStrength: _blurStrength.round(),
      );

      setState(() {
        _processedImage = processedRequest.partialBlurredImage;
        _fullBlurredImage = processedRequest.fullBlurredImage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('알림'),
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  '닫기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
            elevation: 24,
          );
        },
        barrierDismissible: false,
      );
    }
  }
}
